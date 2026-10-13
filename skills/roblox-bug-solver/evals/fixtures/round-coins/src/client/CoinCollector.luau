--!strict
-- Touching a coin asks the server to collect it (the server checks the distance).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local CollectCoin = ReplicatedStorage:WaitForChild("CollectCoin") :: RemoteEvent

local function watch(coin: Instance)
	if coin:IsA("BasePart") then
		coin.Touched:Connect(function(hit)
			if player.Character and hit:IsDescendantOf(player.Character) then
				CollectCoin:FireServer(coin)
			end
		end)
	end
end

for _, coin in workspace:WaitForChild("Coins"):GetChildren() do
	watch(coin)
end
workspace.Coins.ChildAdded:Connect(watch)
