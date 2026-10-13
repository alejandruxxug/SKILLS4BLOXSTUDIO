--!strict
-- Where coins come from: tapping, quests and the daily chest.

local DataService = require(script.Parent.DataService)
local ShopService = require(script.Parent.ShopService)

local CoinService = {}

function CoinService:Tap(player: Player)
	local data = DataService:Get(player)
	if not data then
		return
	end
	local amount = 1
	if ShopService:HasPass(player, "DoubleCoins") then
		amount *= 2
	end
	data.coins += amount
end

function CoinService:QuestReward(player: Player, reward: number)
	local data = DataService:Get(player)
	if data then
		data.coins += reward
	end
end

function CoinService:DailyChest(player: Player)
	local data = DataService:Get(player)
	if data then
		data.coins += 250
	end
end

return CoinService
