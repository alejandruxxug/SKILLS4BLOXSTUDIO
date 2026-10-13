--!strict
-- The chest button: shows a countdown, or CLAIM! when ready.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local button = player:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("ChestButton") :: TextButton

local function format(seconds: number): string
	local h = math.floor(seconds / 3600)
	local m = math.floor(seconds % 3600 / 60)
	return string.format("%02d:%02d", h, m)
end

local function refresh()
	local left = player:GetAttribute("ChestReadyIn") or 0
	-- the countdown is rounded down to minutes, so it can show 00:00 for up to 59 seconds
	button.Text = if left <= 0 then "CLAIM!" else format(left)
end

player:GetAttributeChangedSignal("ChestReadyIn"):Connect(refresh)
refresh()

button.Activated:Connect(function()
	local ok, message = ReplicatedStorage:WaitForChild("ClaimChest"):InvokeServer()
	button.Text = message
	task.wait(1.5)
	refresh()
end)
