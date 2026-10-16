--!strict
-- The sound engine. Every sound is a POOL of takes (SoundBank.luau), and every play is a little
-- different, so the game keeps its signature sounds without them wearing out:
--
--   A  shuffle bag     a name deals all its takes before repeating, never the same one twice in a row
--   B  micro-jitter    pitch ±3 %, volume ±8 % on every one-shot (brand stings marked `exact` skip it)
--   C  signature+tail  the WinBell stays, the WinTail under it rotates (see celebrate)
--   D  tiers           Sounds.celebrate("tiny" | "nice" | "big" | "huge"): the size of the sound
--                      matches the size of the moment, so Fanfare stays special
--   E  fatigue         a celebration within FATIGUE seconds of the last plays one tier lighter
--   F  streak ladder   back-to-back wins climb a major scale (Sounds.streakWin / streakLoss)
--
-- Hero hits (Sounds.hero): riser → ~150 ms of silence (the music ducks to nothing) → snap +
-- body + punch + sparkle all at once.
--
-- The mix: three volume groups under SoundService (AudioMusic · AudioAmbience · AudioSfx, plus
-- AudioSfxDry for UI clicks). A group's volume = its mix level × the player's slider × Master.
-- The music ducks under the effects on its own (a sidechain compressor keyed off AudioSfx), and
-- the effects get the reverb of the room you're in (Sounds.setRoom: call it as the player moves).
-- Stingers that know their key are transposed to the key of the music that's playing.

local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local ContentProvider = game:GetService("ContentProvider")

local SoundBank = require(script.Parent.SoundBank)

local Sounds = {}

export type Def = SoundBank.Entry & { id: number }

-- name → its pool, plus `id` = the signature take (a loading screen can preload these)
Sounds.Bank = {} :: { [string]: Def }
for name, entry in SoundBank do
	local def = table.clone(entry) :: any
	def.id = entry.ids[1]
	Sounds.Bank[name] = def
end

Sounds.BUILT_IN = {
	[0] = "rbxasset://sounds/impact_explosion_03.mp3", -- Impact
} :: { [number]: string }

local JITTER_PITCH = 0.06 -- total spread (±3 %)
local JITTER_VOLUME = 0.16 -- total spread (±8 %)
local FATIGUE = 1.5 -- seconds: a celebration this soon after another (truly stacked) plays one tier lighter
local MAX_SHIFT = 3 -- semitones a stinger may be transposed to fit the music
local RISER_LEAD = 1.0 -- seconds of riser before a hero hit
local SILENCE = 0.15 -- the gap before the hit
local LADDER = { 0, 2, 4, 5, 7, 9, 11, 12 } -- major scale, in semitones

-- ── groups & the mix ─────────────────────────────────────────────────────────────────────

local GROUP_VOLUME = { Music = 0.6, Ambience = 0.7, Sfx = 1, SfxDry = 1 }
local CHANNEL_OF = { SfxDry = "Sfx" } -- which ⚙️ slider moves a group
local groups: { [string]: SoundGroup } = {}

export type Channel = "Master" | "Music" | "Ambience" | "Sfx"
local userVolume: { [string]: number } = { Master = 1, Music = 1, Ambience = 1, Sfx = 1 }

local function applyVolume(name: string)
	local g = groups[name]
	if g then
		local channel = CHANNEL_OF[name] or name
		g.Volume = (GROUP_VOLUME[name] or 1) * (userVolume[channel] or 1) * userVolume.Master
	end
end

-- An effect on a group, reused if the place already saved one (Edit previews leave them behind)
local function effect(g: SoundGroup, className: string, props: { [string]: any }): Instance
	local fx = g:FindFirstChildOfClass(className) or Instance.new(className)
	for k, v in props do
		(fx :: any)[k] = v
	end
	fx.Parent = g
	return fx
end

local reverb: ReverbSoundEffect? = nil

export type Room = "Hall" | "Outdoor" | "Small"

function Sounds.group(name: string): SoundGroup
	local existing = groups[name]
	if existing then
		return existing
	end
	local found = SoundService:FindFirstChild(`Audio{name}`)
	local g = if found and found:IsA("SoundGroup") then found else Instance.new("SoundGroup")
	g.Name = `Audio{name}`
	g.Parent = SoundService
	groups[name] = g
	applyVolume(name)
	if name == "Music" then
		-- the music gets out of the way of every effect, on its own
		effect(g, "CompressorSoundEffect", {
			SideChain = Sounds.group("Sfx"),
			Threshold = -28,
			Ratio = 3,
			Attack = 0.02,
			Release = 0.35,
			GainMakeup = 0,
		})
		-- and leaves the mids to voices and stings
		effect(g, "EqualizerSoundEffect", { LowGain = 0, MidGain = -2.5, HighGain = 0 })
	elseif name == "Sfx" then
		reverb = effect(g, "ReverbSoundEffect", {}) :: ReverbSoundEffect
		Sounds.setRoom("Outdoor")
	end
	return g
end

-- The player's volume for a channel (0..1). "Master" scales every group.
function Sounds.setVolume(channel: Channel, volume: number)
	userVolume[channel] = math.clamp(volume, 0, 1)
	for name in groups do
		applyVolume(name)
	end
end

function Sounds.getVolume(channel: Channel): number
	return userVolume[channel] or 1
end

-- Room reverb on the effects. Call it as the player walks between places (rename the rooms to yours).
local ROOMS: { [string]: { [string]: number } } = {
	Hall = { DecayTime = 2.2, Density = 1, Diffusion = 1, DryLevel = 0, WetLevel = -12 }, -- big echoey hall
	Outdoor = { DecayTime = 0.8, Density = 0.6, Diffusion = 0.8, DryLevel = 0, WetLevel = -26 }, -- open air
	Small = { DecayTime = 1.4, Density = 1, Diffusion = 0.5, DryLevel = 0, WetLevel = -10 }, -- tight, slappy
}
local room: Room? = nil

function Sounds.setRoom(name: Room)
	if room == name then
		return
	end
	room = name
	local fx = reverb
	if fx then
		for k, v in ROOMS[name] do
			(fx :: any)[k] = v
		end
	end
end

-- ── the music's key (stingers get transposed to it) ──────────────────────────────────────

local musicKey: number? = nil

function Sounds.setMusicKey(key: number?)
	musicKey = key
end

function Sounds.keyOf(name: string, id: number): number?
	local def = Sounds.Bank[name]
	local keys = def and def.keys
	return keys and keys[id]
end

-- ── ducking (Music registers itself) ─────────────────────────────────────────────────────

local ducker: ((seconds: number, level: number) -> ())? = nil

function Sounds.setDucker(fn: (seconds: number, level: number) -> ())
	ducker = fn
end

function Sounds.duck(seconds: number, level: number)
	local fn = ducker
	if fn then
		fn(seconds, level)
	end
end

-- ── A: the shuffle bag ───────────────────────────────────────────────────────────────────

local bags: { [string]: { number } } = {}
local lastTake: { [string]: number } = {}
local overrides: { [string]: { number } } = {} -- 🎧 audition: a temporary pool

-- 🎧 Replace a name's pool until cleared (nil). Used by the audition panel.
function Sounds.override(name: string, ids: { number }?)
	overrides[name] = ids :: any
	bags[name] = nil
end

function Sounds.poolOf(name: string): { number }
	return overrides[name] or Sounds.Bank[name].ids
end

local function deal(name: string): number
	local pool = Sounds.poolOf(name)
	if #pool == 1 then
		return pool[1]
	end
	local bag = bags[name]
	if not bag or #bag == 0 then
		local fresh = table.clone(pool)
		for i = #fresh, 2, -1 do
			local j = math.random(i)
			fresh[i], fresh[j] = fresh[j], fresh[i]
		end
		-- we deal from the end: never start a new bag with the take that just played
		if fresh[#fresh] == lastTake[name] then
			fresh[1], fresh[#fresh] = fresh[#fresh], fresh[1]
		end
		bags[name] = fresh
		bag = fresh
	end
	-- a stinger with keys: deal the next take that sits close to the music's key, if there is one
	local list = bag :: { number }
	local pickAt = #list
	local keys = Sounds.Bank[name].keys
	if keys and musicKey then
		for i = #list, 1, -1 do
			local key = keys[list[i]]
			if key and list[i] ~= lastTake[name] and math.abs((musicKey - key + 6) % 12 - 6) <= 2 then
				pickAt = i
				break
			end
		end
	end
	local id = table.remove(list, pickAt) :: number
	lastTake[name] = id
	return id
end

-- ── making & playing ─────────────────────────────────────────────────────────────────────

local function make(name: string, id: number): Sound
	local d = Sounds.Bank[name]
	assert(d, `unknown sound {name}`)
	local s = Instance.new("Sound")
	s.Name = name
	s.SoundId = Sounds.BUILT_IN[id] or `rbxassetid://{id}`
	s.Volume = d.volume
	s.SoundGroup = Sounds.group(if d.dry then "SfxDry" else d.group)
	return s
end

export type PlayOptions = {
	at: Vector3?, -- positional (in the world); otherwise it plays in your ears
	volume: number?, -- × the bank volume
	pitch: number?,
	delay: number?,
	exact: boolean?, -- skip the jitter this time
	id: number?, -- force one take (🎧 audition)
	tail: number?, -- play only the last `tail` seconds (risers that must END on the hit)
	slice: number?, -- play a random `slice`-second piece (babble syllables)
}

-- One-shot. With `delay` it plays later.
function Sounds.play(name: string, options: PlayOptions?)
	local o: PlayOptions = options or {}
	local function go()
		local def = Sounds.Bank[name]
		local id = o.id or deal(name)
		local s = make(name, id)
		local pitch = o.pitch or 1
		local volume = o.volume or 1
		if not (def.exact or o.exact) then
			pitch *= 1 + (math.random() - 0.5) * JITTER_PITCH
			volume *= 1 + (math.random() - 0.5) * JITTER_VOLUME
		end
		local key = Sounds.keyOf(name, id)
		if key and musicKey then
			local shift = (musicKey - key + 6) % 12 - 6
			if math.abs(shift) <= MAX_SHIFT then
				pitch *= 2 ^ (shift / 12)
			end
		end
		s.Volume *= volume
		s.PlaybackSpeed = pitch
		if o.at then
			local holder = Instance.new("Part")
			holder.Name = "AudioSound"
			holder.Anchored = true
			holder.CanCollide = false
			holder.CanQuery = false
			holder.CanTouch = false
			holder.Transparency = 1
			holder.Size = Vector3.one
			holder.CFrame = CFrame.new(o.at)
			holder.Parent = workspace
			s.RollOffMaxDistance = 220
			s.Parent = holder
			Debris:AddItem(holder, 12)
		else
			s.Parent = SoundService
			Debris:AddItem(s, 12)
		end
		if o.tail and s.TimeLength > 0 then
			s.TimePosition = math.max(0, s.TimeLength - o.tail * pitch)
		end
		local slice = o.slice
		if slice then
			if s.TimeLength > slice then
				s.TimePosition = math.random() * (s.TimeLength - slice)
			end
			task.delay(slice / pitch, function()
				s:Stop()
			end)
		end
		s:Play()
	end
	if o.delay and o.delay > 0 then
		task.delay(o.delay, go)
	else
		go()
	end
end

-- A looping sound you control (music, ambience). Starts silent; fade it in yourself.
function Sounds.loop(name: string, id: number?): Sound
	local s = make(name, id or Sounds.poolOf(name)[1])
	s.Looped = true
	s:SetAttribute("BaseVolume", s.Volume)
	s.Volume = 0
	s.Parent = SoundService
	return s
end

-- Load some names' takes in the background (so `tail` knows each riser's length)
function Sounds.preload(names: { string })
	task.spawn(function()
		local list = {}
		for _, name in names do
			for _, id in Sounds.poolOf(name) do
				if id ~= 0 then
					table.insert(list, `rbxassetid://{id}`)
				end
			end
		end
		pcall(function()
			ContentProvider:PreloadAsync(list)
		end)
	end)
end

-- ── hero hits ────────────────────────────────────────────────────────────────────────────

export type HeroOptions = {
	body: string?, -- the signature sound on the hit (e.g. "Fanfare", a top-rarity sting)
	riser: boolean?, -- build up first (then the silence)
	crowd: boolean?, -- cheer + applause after the hit
	pitch: number?,
	volume: number?,
}

-- Snap + body + punch + sparkle at the same instant. Returns the seconds until the hit, so the
-- caller can land its visuals on it.
function Sounds.hero(o: HeroOptions): number
	local hitIn = 0
	local v = o.volume or 1
	if o.riser then
		hitIn = RISER_LEAD + SILENCE
		Sounds.play("Riser", { tail = RISER_LEAD + 0.05, volume = v })
		Sounds.duck(RISER_LEAD, 0.35) -- room for the build-up
		task.delay(RISER_LEAD, function()
			Sounds.duck(SILENCE, 0.02) -- the silence before the hit
		end)
	end
	task.delay(hitIn, function()
		Sounds.duck(2.5, 0.3)
		Sounds.play("Snap", { volume = v })
		if o.body then
			Sounds.play(o.body, { pitch = o.pitch, volume = v })
		end
		Sounds.play("Punch", { volume = 0.9 * v })
		Sounds.play("Sparkle", { delay = 0.06, volume = v })
		if o.crowd then
			Sounds.play("Cheer", { delay = 0.15, volume = v })
			Sounds.play("Applause", { delay = 0.4, volume = 0.8 * v })
		end
	end)
	return hitIn
end

-- ── D + E: celebration tiers with fatigue ────────────────────────────────────────────────

export type Tier = "tiny" | "nice" | "big" | "huge"
local TIER_INDEX: { [string]: number } = { tiny = 1, nice = 2, big = 3, huge = 4 }
local TIER_NAMES: { Tier } = { "tiny", "nice", "big", "huge" }
local lastCelebration = -math.huge

export type CelebrateOptions = {
	pitch: number?, -- e.g. the streak ladder
	volume: number?,
	riser: boolean?, -- huge only: build up first
	body: string?, -- huge only: the stinger (default Fanfare)
	noFatigue: boolean?,
}

-- Play a celebration sized to the moment. Returns the tier it actually played and the seconds
-- until its hit (non-zero only for a huge with a riser).
function Sounds.celebrate(tier: Tier, options: CelebrateOptions?): (Tier, number)
	local o: CelebrateOptions = options or {}
	local i = TIER_INDEX[tier]
	local now = os.clock()
	if i < 4 and not o.noFatigue and now - lastCelebration < FATIGUE then
		i = math.max(1, i - 1) -- stacked moments: one tier lighter, so nothing piles up
	end
	lastCelebration = now
	local v = o.volume or 1
	local pitch = o.pitch or 1
	local hitIn = 0
	if i == 1 then
		Sounds.play("Ding", { pitch = pitch, volume = v })
		Sounds.play("Clap", { volume = 0.5 * v, delay = 0.04 })
	elseif i == 2 then
		Sounds.play("WinBell", { pitch = pitch, volume = v })
		Sounds.play("WinTail", { delay = 0.08, volume = v })
	elseif i == 3 then
		Sounds.duck(1.8, 0.45)
		Sounds.play("WinBell", { pitch = pitch, volume = v })
		Sounds.play("WinTail", { delay = 0.08, volume = v })
		Sounds.play("Punch", { volume = 0.6 * v })
		Sounds.play("Cheer", { delay = 0.2, volume = v })
	else
		hitIn = Sounds.hero({ body = o.body or "Fanfare", riser = o.riser, crowd = true, volume = v })
	end
	return TIER_NAMES[i], hitIn
end

-- ── F: the streak ladder ─────────────────────────────────────────────────────────────────

local streak = 0

-- A win: climb one step. Returns the pitch for this win's sound.
function Sounds.streakWin(): number
	streak = math.min(streak + 1, #LADDER)
	return 2 ^ (LADDER[streak] / 12)
end

-- A loss: back to the bottom. A run of 2+ ends with a "bwomp".
function Sounds.streakLoss()
	if streak >= 2 then
		Sounds.play("Bwomp")
	end
	streak = 0
end

function Sounds.streak(): number
	return streak
end

Sounds.preload({ "Riser", "Snap", "Punch", "Sparkle", "Ding", "WinBell", "WinTail", "Cheer" })

return Sounds
