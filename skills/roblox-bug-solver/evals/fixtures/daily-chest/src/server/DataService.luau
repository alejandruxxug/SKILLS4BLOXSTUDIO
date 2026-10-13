--!strict
-- Loads and saves each player's data (one key per player).
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local store = DataStoreService:GetDataStore("PlayerData_v2")

local DataService = {
	_data = {} :: { [Player]: any },
	OnLoaded = Instance.new("BindableEvent"),
}

local function defaults()
	return { gems = 0, lastChest = 0 }
end

function DataService:Get(player: Player)
	return self._data[player]
end

function DataService:Start()
	Players.PlayerAdded:Connect(function(player)
		local ok, saved = pcall(function()
			return store:GetAsync(`u_{player.UserId}`)
		end)
		local data = defaults()
		if ok and typeof(saved) == "table" then
			for k, v in saved do
				data[k] = v
			end
		end
		self._data[player] = data
		self.OnLoaded:Fire(player, data)
	end)

	Players.PlayerRemoving:Connect(function(player)
		local data = self._data[player]
		if data then
			pcall(function()
				store:SetAsync(`u_{player.UserId}`, data)
			end)
		end
		self._data[player] = nil
	end)

	game:BindToClose(function()
		for player, data in self._data do
			pcall(function()
				store:SetAsync(`u_{player.UserId}`, data)
			end)
		end
	end)
end

return DataService
