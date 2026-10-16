--!strict
-- The music director: named tracks (one looping Sound each) with crossfades.
--   set(mix)       which tracks play, 0..1 each (eased over FADE seconds)
--   roll(name)     pick the next take of a playlist; it swaps in once that track is silent, so
--                  every round / day / night gets a new song, never the one you just heard
--   duck(s, lvl)   push the music down for a sting (Sounds.duck routes here)
--   tapeStop(hold) the songs wind down like a tape, stay silent `hold` s, then come back
--   setTension(on) a ticking layer fades in and the main song speeds up a little
--   audition(name, id)  🎧 put one take on a track right now
-- The loudest song with a known key sets Sounds' music key, so stingers play in key.
--
-- Usage:  local music = Music.new({ "MusicMain", "MusicCalm", "MusicVictory" }, {
--             tension = "TickTock", tensionSong = "MusicMain" })
--         music:set({ MusicMain = 1 })

local RunService = game:GetService("RunService")

local Sounds = require(script.Parent.Sounds)

local FADE = 1.5 -- seconds for a crossfade
local TENSION_PITCH = 1.06
local TAPE_DOWN = 0.45 -- seconds for the tape to wind down
local TAPE_UP = 0.6 -- and to come back

local Music = {}
Music.__index = Music

export type Options = {
	tension: string?, -- a clock / ticking track: not a song, ignores set() and the tape
	tensionSong: string?, -- the song that speeds up under tension
}

export type Music = typeof(setmetatable(
	{} :: {
		_tracks: { [string]: Sound },
		_target: { [string]: number }, -- 0..1 of each track's base volume
		_current: { [string]: number }, -- the take each track is playing
		_pending: { [string]: number }, -- a rolled take, swapped in once the track is silent
		_options: Options,
		_duckUntil: number,
		_duckLevel: number,
		_pitch: number,
		_tapeStart: number, -- os.clock() a tape-stop began (0 = none)
		_tapeHold: number,
	},
	Music
))

local function pick(name: string, avoid: number?): number
	local pool = Sounds.poolOf(name)
	if #pool == 1 then
		return pool[1]
	end
	local id
	repeat
		id = pool[math.random(#pool)]
	until id ~= avoid
	return id
end

function Music.new(songs: { string }, options: Options?): Music
	local o: Options = options or {}
	local names = table.clone(songs)
	if o.tension then
		table.insert(names, o.tension)
	end
	local tracks, current, target = {}, {}, {}
	for _, name in names do
		local id = pick(name) -- a new player starts on any take, not always the same one
		tracks[name] = Sounds.loop(name, id)
		current[name] = id
		target[name] = 0
	end
	local self = setmetatable({
		_tracks = tracks,
		_target = target,
		_current = current,
		_pending = {},
		_options = o,
		_duckUntil = 0,
		_duckLevel = 1,
		_pitch = 1,
		_tapeStart = 0,
		_tapeHold = 0,
	}, Music)
	Sounds.setDucker(function(seconds: number, level: number)
		self:duck(seconds, level)
	end)
	RunService.Heartbeat:Connect(function(dt)
		self:_step(dt)
	end)
	return self
end

function Music.set(self: Music, mix: { [string]: number })
	for name in self._tracks do
		if name ~= self._options.tension then
			self._target[name] = mix[name] or 0
		end
	end
end

function Music.roll(self: Music, name: string)
	if self._tracks[name] then
		self._pending[name] = pick(name, self._current[name])
	end
end

function Music.audition(self: Music, name: string, id: number)
	local sound = self._tracks[name]
	if not sound then
		return
	end
	sound:Stop()
	sound.SoundId = `rbxassetid://{id}`
	self._current[name] = id
	self._pending[name] = nil
	self:set({ [name] = 1 })
end

function Music.duck(self: Music, seconds: number, level: number)
	self._duckUntil = math.max(self._duckUntil, os.clock() + seconds)
	self._duckLevel = level
end

function Music.tapeStop(self: Music, hold: number)
	self._tapeStart = os.clock()
	self._tapeHold = hold
end

function Music.setTension(self: Music, on: boolean)
	local clock = self._options.tension
	if clock then
		self._target[clock] = if on then 1 else 0
	end
	self._pitch = if on then TENSION_PITCH else 1
end

-- The tape-stop right now: (volume 0..1, speed factor)
function Music._tape(self: Music): (number, number)
	if self._tapeStart == 0 then
		return 1, 1
	end
	local t = os.clock() - self._tapeStart
	if t < TAPE_DOWN then
		local a = t / TAPE_DOWN
		return 1 - a, 1 - 0.65 * a -- winds down to 35 % speed as it fades
	elseif t < TAPE_DOWN + self._tapeHold then
		return 0, 0.35
	elseif t < TAPE_DOWN + self._tapeHold + TAPE_UP then
		return (t - TAPE_DOWN - self._tapeHold) / TAPE_UP, 1
	end
	self._tapeStart = 0
	return 1, 1
end

function Music._step(self: Music, dt: number)
	local duck = if os.clock() < self._duckUntil then self._duckLevel else 1
	local tapeVolume, tapeSpeed = self:_tape()
	local taping = self._tapeStart ~= 0
	local k = math.min(dt / FADE, 1)
	local loudest, loudestName = 0.02, nil :: string?
	for name, sound in self._tracks do
		local base = sound:GetAttribute("BaseVolume") :: number
		local isClock = name == self._options.tension
		local goal = base * self._target[name] * (if isClock then 1 else duck * tapeVolume)
		if taping and not isClock then
			sound.Volume = math.min(sound.Volume, goal) -- the tape-stop IS the effect: no easing down
		end
		sound.Volume += (goal - sound.Volume) * math.min(k * 3, 1)
		local pending = self._pending[name]
		if pending and self._target[name] == 0 and sound.Volume < 0.005 then
			sound:Stop()
			sound.SoundId = `rbxassetid://{pending}`
			self._current[name] = pending
			self._pending[name] = nil
		end
		if goal > 0.001 and not sound.IsPlaying then
			sound:Play()
		elseif goal <= 0.001 and sound.Volume < 0.005 and sound.IsPlaying and not taping then
			sound:Pause()
		end
		if not isClock then
			local speed = tapeSpeed * (if name == self._options.tensionSong then self._pitch else 1)
			local rate = if taping then 12 else 2
			sound.PlaybackSpeed += (speed - sound.PlaybackSpeed) * math.min(dt * rate, 1)
			if self._target[name] > loudest then
				loudest, loudestName = self._target[name], name
			end
		end
	end
	-- stingers follow the key of the song that's playing (when we know it)
	Sounds.setMusicKey(if loudestName then Sounds.keyOf(loudestName, self._current[loudestName]) else nil)
end

return Music
