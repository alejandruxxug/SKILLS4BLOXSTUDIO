--!strict
-- 🎧 AUDITION (admin only): pick the game's sounds BY EAR, in context. Self-contained: builds its
-- own ScreenGui, so restyle it with your game's UI kit if you like.
--   ▶ 3     plays take 3 alone (music plays on its real track, babble says a sentence)
--   ✓ / +   keeps (✓) or drops that take; grey + = an extra candidate, tap to add it
--           (applied live via Sounds.override)
--   ▶ MOMENT plays the real moment (a celebration tier, the hero hit...) with what you kept
-- Every change is saved on the player as the attribute "AuditionPicks" (JSON: pool → kept ids)
-- and printed, so it can be baked back into SoundBank.luau ("bake my audition picks").
--
-- Usage (only for admins!):
--   local panel = AuditionPanel.new(music, CONFIG)   -- music = your Music instance (or nil)
--   panel:Toggle()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Sounds = require(script.Parent.Sounds)

export type Moment = { title: string, pools: { string }, plays: { { any } } } -- plays: { label, fn }
export type Config = {
	moments: { Moment },
	candidates: { [string]: { number } }?, -- extra takes per pool, off until kept
	music: { [string]: boolean }?, -- pools that are music tracks
	onClose: (() -> ())?, -- e.g. return to the phase's music
}

-- An example config: adapt the pools and moments to your game
local EXAMPLE: Config = {
	moments = {
		{
			title = "💰 WINS",
			pools = { "WinBell", "WinTail", "Ding", "Clap", "Cheer" },
			plays = {
				{
					"TINY",
					function()
						Sounds.celebrate("tiny", { noFatigue = true })
					end,
				},
				{
					"NICE",
					function()
						Sounds.celebrate("nice", { noFatigue = true })
					end,
				},
				{
					"BIG",
					function()
						Sounds.celebrate("big", { noFatigue = true })
					end,
				},
				{
					"STREAK ×5",
					function()
						for i = 1, 5 do
							task.delay((i - 1) * 0.55, function()
								Sounds.celebrate("nice", { pitch = Sounds.streakWin(), noFatigue = true })
							end)
						end
						task.delay(3, Sounds.streakLoss)
					end,
				},
			},
		},
		{
			title = "🏆 HERO HIT",
			pools = { "Fanfare", "Riser", "Snap", "Punch", "Sparkle", "Applause" },
			plays = {
				{
					"HUGE",
					function()
						Sounds.celebrate("huge")
					end,
				},
				{
					"+ RISER",
					function()
						Sounds.celebrate("huge", { riser = true })
					end,
				},
			},
		},
		{ title = "🎵 MUSIC", pools = { "MusicMain", "MusicCalm", "MusicVictory" }, plays = {} },
	},
	candidates = {},
	music = { MusicMain = true, MusicCalm = true, MusicVictory = true },
}

local AuditionPanel = {}
AuditionPanel.__index = AuditionPanel
AuditionPanel.EXAMPLE = EXAMPLE

local GREEN = Color3.fromRGB(46, 160, 90)
local BLUE = Color3.fromRGB(52, 120, 220)
local GREY = Color3.fromRGB(90, 90, 100)
local DARK = Color3.fromRGB(28, 26, 40)

local function button(parent: Instance, text: string, width: number, color: Color3, order: number): TextButton
	local b = Instance.new("TextButton")
	b.Name = text
	b.LayoutOrder = order
	b.Size = UDim2.fromOffset(width, 26)
	b.BackgroundColor3 = color
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Text = text
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = b
	b.Parent = parent
	return b
end

local function label(parent: Instance, text: string, size: number, width: number?, order: number): TextLabel
	local l = Instance.new("TextLabel")
	l.LayoutOrder = order
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.GothamBold
	l.TextSize = size
	l.TextColor3 = Color3.new(1, 1, 1)
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Text = text
	if width then
		l.Size = UDim2.fromOffset(width, 26)
	else
		l.AutomaticSize = Enum.AutomaticSize.XY
	end
	l.Parent = parent
	return l
end

local function row(parent: Instance, order: number): Frame
	local f = Instance.new("Frame")
	f.LayoutOrder = order
	f.BackgroundTransparency = 1
	f.Size = UDim2.new(1, -8, 0, 30)
	f.AutomaticSize = Enum.AutomaticSize.Y
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Wraps = true
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = f
	f.Parent = parent
	return f
end

function AuditionPanel.new(music: any, config: Config?)
	local self = setmetatable({}, AuditionPanel)
	self._music = music
	self._config = config or EXAMPLE
	self._kept = {} :: { [string]: { [number]: boolean } }

	local gui = Instance.new("ScreenGui")
	gui.Name = "Audition"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 50
	gui.Enabled = false
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	self._gui = gui

	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.new(0.9, 0, 0.8, 0)
	panel.BackgroundColor3 = DARK
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = panel
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize = Vector2.new(760, 520)
	limit.Parent = panel
	panel.Parent = gui

	local close = button(panel, "✕", 30, GREY, 0)
	close.Position = UDim2.new(1, -36, 0, 6)
	close.Activated:Connect(function()
		self:Toggle(false)
	end)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "List"
	scroll.Position = UDim2.fromOffset(10, 40)
	scroll.Size = UDim2.new(1, -20, 1, -50)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 4)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.VerticalAlignment = Enum.VerticalAlignment.Top
	list.Parent = scroll
	scroll.Parent = panel
	self._scroll = scroll

	local order = 0
	local function nextOrder(): number
		order += 1
		return order
	end
	label(panel, "🎧 AUDITION", 20, 300, 0).Position = UDim2.fromOffset(12, 6)
	for _, moment in self._config.moments do
		local head = row(scroll, nextOrder())
		label(head, moment.title, 18, nil, 0).TextColor3 = Color3.fromRGB(255, 205, 70)
		for i, play in moment.plays do
			button(head, `▶ {play[1]}`, 92, GREEN, i).Activated:Connect(play[2])
		end
		for _, pool in moment.pools do
			self:_poolRow(scroll, pool, nextOrder())
		end
	end
	local foot = row(scroll, nextOrder())
	button(foot, "■ STOP MUSIC", 120, Color3.fromRGB(200, 60, 60), 1).Activated:Connect(function()
		if self._config.onClose then
			self._config.onClose()
		end
	end)
	label(
		foot,
		"▶ = hear a take · ✓ = kept (tap to drop) · + = add it · grey = extra candidate",
		13,
		nil,
		2
	)
	return self
end

function AuditionPanel:_poolRow(parent: Instance, pool: string, order: number)
	local def = Sounds.Bank[pool]
	if not def then
		warn(`🎧 no pool named {pool}`)
		return
	end
	local kept: { [number]: boolean } = {}
	for _, id in Sounds.poolOf(pool) do
		kept[id] = true
	end
	self._kept[pool] = kept
	local takes = table.clone(def.ids)
	for _, id in (self._config.candidates or {})[pool] or {} do
		table.insert(takes, id)
	end
	local r = row(parent, order)
	label(r, pool, 14, 112, 0)
	for i, id in takes do
		local playB = button(r, `▶{i}`, 36, BLUE, i * 2 - 1)
		local keepB = button(r, "", 24, GREEN, i * 2)
		local function paint()
			local on = kept[id] == true
			keepB.Text = if on then "✓" else "+"
			keepB.BackgroundColor3 = if on then GREEN else GREY
			playB.BackgroundColor3 = if on then BLUE else GREY
		end
		paint()
		playB.Activated:Connect(function()
			self:_hear(pool, id)
		end)
		keepB.Activated:Connect(function()
			if kept[id] then
				local count = 0
				for _ in kept do
					count += 1
				end
				if count <= 1 then
					return -- a pool needs at least one take
				end
				kept[id] = nil
			else
				kept[id] = true
			end
			paint()
			self:_apply(pool)
		end)
	end
end

function AuditionPanel:_hear(pool: string, id: number)
	local isMusic = (self._config.music or {})[pool]
	if isMusic and self._music then
		self._music:audition(pool, id)
	elseif pool == "Babble" then
		for i = 1, 14 do
			task.delay(i * 0.065, function()
				Sounds.play(
					"Babble",
					{ id = id, slice = 0.08 + math.random() * 0.04, pitch = 0.9 + math.random() * 0.2 }
				)
			end)
		end
	else
		Sounds.play(pool, { id = id, exact = true })
	end
end

function AuditionPanel:_apply(pool: string)
	local ids = {}
	-- keep the bank's order (the signature first), then the candidates
	for _, id in Sounds.Bank[pool].ids do
		if self._kept[pool][id] then
			table.insert(ids, id)
		end
	end
	for _, id in (self._config.candidates or {})[pool] or {} do
		if self._kept[pool][id] then
			table.insert(ids, id)
		end
	end
	Sounds.override(pool, ids)
	local picks = {}
	for name in self._kept do
		picks[name] = Sounds.poolOf(name)
	end
	Players.LocalPlayer:SetAttribute("AuditionPicks", HttpService:JSONEncode(picks))
	print(`🎧 {pool} = {HttpService:JSONEncode(ids)}`)
end

function AuditionPanel:Toggle(on: boolean?)
	local show = if on == nil then not self._gui.Enabled else on
	self._gui.Enabled = show
	if show then
		self._scroll.CanvasPosition = Vector2.zero
	elseif self._config.onClose then
		self._config.onClose()
	end
end

return AuditionPanel
