--!strict
-- Session-locked saves (UpdateAsync + lock). One save at a time per player.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local store = DataStoreService:GetDataStore("Hatchery_v1")
local LOCK_EXPIRE = 600
local LOCK_WAIT = 20

local SaveService = {
	data = {} :: { [Player]: any },
	offline = {} :: { [Player]: boolean }, -- load failed: never saved, play on with fresh data
	busy = {} :: { [Player]: boolean },
	inFlight = 0,
}

local function key(player: Player)
	return "u" .. player.UserId
end

local function defaults()
	return { gems = 0, pets = {}, receipts = {}, firstJoin = 0, gotStarter = false, tripleCredits = 0, dailyEggDay = 0 }
end

function SaveService:Load(player: Player)
	local deadline = os.clock() + LOCK_WAIT
	for _ = 1, 12 do
		local busy = false
		local loaded
		local ok = pcall(function()
			store:UpdateAsync(key(player), function(old)
				local lock = old and old._lock
				if lock and lock.job ~= game.JobId and os.time() - lock.t < LOCK_EXPIRE and os.clock() < deadline then
					busy = true
					return nil
				end
				local value = old or defaults()
				value._lock = { job = game.JobId, t = os.time() }
				loaded = value
				return value
			end)
		end)
		if ok and not busy then
			self.data[player] = loaded
			return
		end
		task.wait(2)
	end
	self.offline[player] = true
	self.data[player] = defaults()
end

-- true when the DataStore has the current data
function SaveService:Save(player: Player, release: boolean?): boolean
	while self.busy[player] do
		task.wait()
	end
	local data = self.data[player]
	if not data or self.offline[player] then
		return false
	end
	self.busy[player] = true
	self.inFlight += 1
	local copy = table.clone(data)
	copy._lock = if release then nil else { job = game.JobId, t = os.time() }
	local lost = false
	local ok = pcall(function()
		store:UpdateAsync(key(player), function(old)
			if not old or not old._lock or old._lock.job ~= game.JobId then
				lost = true
				return nil
			end
			return copy
		end)
	end)
	self.inFlight -= 1
	self.busy[player] = nil
	if lost then
		self.offline[player] = true
	end
	return ok and not lost
end

function SaveService:Start()
	Players.PlayerAdded:Connect(function(p)
		self:Load(p)
	end)
	Players.PlayerRemoving:Connect(function(p)
		self:Save(p, true)
		self.data[p] = nil
		self.offline[p] = nil
	end)
	game:BindToClose(function()
		for p in self.data do
			task.spawn(self.Save, self, p, true)
		end
		local deadline = os.clock() + 25
		repeat
			task.wait(0.2)
		until self.inFlight == 0 or os.clock() > deadline
	end)
end

return SaveService
