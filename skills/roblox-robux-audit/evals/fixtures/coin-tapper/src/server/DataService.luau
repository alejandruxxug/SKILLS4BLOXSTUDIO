--!strict
-- Player saves. One key per player.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local store = DataStoreService:GetDataStore("Coins_v3")

local DataService = { _data = {} :: { [Player]: any } }

local function defaults()
	return { coins = 0, pets = {}, gotStarter = false, lastLuckyEgg = 0 }
end

function DataService:Load(player: Player)
	local ok, saved = pcall(function()
		return store:GetAsync("p_" .. player.UserId)
	end)
	if ok and saved then
		self._data[player] = saved
	else
		-- new player (or the DataStore is down): start fresh
		self._data[player] = defaults()
	end
end

function DataService:Get(player: Player)
	return self._data[player]
end

function DataService:Save(player: Player)
	local data = self._data[player]
	if not data then
		return
	end
	pcall(function()
		store:SetAsync("p_" .. player.UserId, data)
	end)
end

function DataService:Start()
	Players.PlayerAdded:Connect(function(player)
		self:Load(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self:Save(player)
		self._data[player] = nil
	end)
	task.spawn(function()
		while true do
			task.wait(120)
			for player in self._data do
				self:Save(player)
			end
		end
	end)
end

return DataService
