--!strict
-- 🎁 The daily chest: claim 250 gems once every 24 hours.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestConfig = require(ReplicatedStorage.Shared.ChestConfig)
local DataService = require(script.Parent.DataService)

local ClaimChest = Instance.new("RemoteFunction")
ClaimChest.Name = "ClaimChest"
ClaimChest.Parent = ReplicatedStorage

local ChestService = {}

-- Seconds until this player can claim again (0 = ready)
function ChestService:TimeLeft(data: any): number
	local elapsed = os.clock() - data.lastChest
	return math.max(ChestConfig.COOLDOWN - elapsed, 0)
end

function ChestService:Start()
	DataService.OnLoaded.Event:Connect(function(player: Player, data: any)
		player:SetAttribute("ChestReadyIn", self:TimeLeft(data))
	end)

	ClaimChest.OnServerInvoke = function(player: Player)
		local data = DataService:Get(player)
		if not data then
			return false, "Loading..."
		end
		if self:TimeLeft(data) > 0 then
			return false, "Come back later!"
		end
		data.gems += ChestConfig.REWARD
		data.lastChest = os.clock()
		player:SetAttribute("ChestReadyIn", self:TimeLeft(data))
		return true, `+{ChestConfig.REWARD} gems!`
	end

	-- keep the countdown fresh for the UI
	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in game:GetService("Players"):GetPlayers() do
				local data = DataService:Get(player)
				if data then
					player:SetAttribute("ChestReadyIn", self:TimeLeft(data))
				end
			end
		end
	end)
end

return ChestService
