--!strict
-- 🪙 Round coins. Kept by UserId so a quick reconnect (wifi blip) doesn't lose your round.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CollectCoin = Instance.new("RemoteEvent")
CollectCoin.Name = "CollectCoin"
CollectCoin.Parent = ReplicatedStorage

local CoinService = {
	_coins = {} :: { [number]: number }, -- UserId → coins this round
}

local function leaderstats(player: Player): IntValue
	local stats = player:FindFirstChild("leaderstats") or Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player
	local coins = stats:FindFirstChild("Coins") :: IntValue? or Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = stats
	return coins :: IntValue
end

function CoinService:Reset(player: Player)
	self._coins[player.UserId] = 0
	leaderstats(player).Value = 0
end

function CoinService:Add(player: Player, amount: number)
	local total = (self._coins[player.UserId] or 0) + amount
	self._coins[player.UserId] = total
	leaderstats(player).Value = total
end

-- Highest first: { { userId, coins } }
function CoinService:Standings(): { { userId: number, coins: number } }
	local list = {}
	for userId, coins in self._coins do
		table.insert(list, { userId = userId, coins = coins })
	end
	table.sort(list, function(a, b)
		return a.coins > b.coins
	end)
	return list
end

function CoinService:Start()
	Players.PlayerAdded:Connect(function(player)
		leaderstats(player).Value = self._coins[player.UserId] or 0
	end)

	CollectCoin.OnServerEvent:Connect(function(player: Player, coin: any)
		if typeof(coin) ~= "Instance" or not coin:IsDescendantOf(workspace.Coins) then
			return
		end
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not root or (root.Position - (coin :: BasePart).Position).Magnitude > 12 then
			return
		end
		coin:Destroy()
		self:Add(player, 1)
	end)
end

return CoinService
