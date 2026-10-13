--!strict
-- 🥚 Hatching: an egg shows 3 pets, you keep 1 (or all 3 with a TRIPLE HATCH credit).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SaveService = require(script.Parent.SaveService)
local StoreService = require(script.Parent.StoreService)

local HatchService = { table = {} :: { [Player]: { string } } }

local BASIC = { { "Mouse", 70 }, { "Fox", 25 }, { "Dragon", 5 } }
local EGG_GEMS = 50

local function roll(): string
	local n = math.random() * 100
	for _, e in BASIC do
		n -= e[2]
		if n <= 0 then
			return e[1]
		end
	end
	return BASIC[1][1]
end

function HatchService:Open(player: Player, free: boolean?)
	local data = SaveService.data[player]
	if not data then
		return nil
	end
	if not free then
		if data.gems < EGG_GEMS then
			return nil
		end
		data.gems -= EGG_GEMS
	end
	self.table[player] = { roll(), roll(), roll() }
	return self.table[player]
end

-- `picks` = which of the 3 to keep. Keeping more than 1 uses a TRIPLE HATCH credit.
function HatchService:Keep(player: Player, picks: { number })
	local data = SaveService.data[player]
	local shown = self.table[player]
	if not data or not shown or #picks < 1 then
		return false, "?"
	end
	if #picks > 1 then
		if data.tripleCredits < 1 then
			return false, "Buy TRIPLE HATCH to keep more!"
		end
		data.tripleCredits -= 1
	end
	if #data.pets + #picks > 60 then
		return false, "Inventory full!"
	end
	for _, i in picks do
		table.insert(data.pets, shown[i])
	end
	self.table[player] = nil
	return true, ""
end

-- 📅 DAILY EGG pass: a free Basic egg once per day
function HatchService:DailyEgg(player: Player)
	local data = SaveService.data[player]
	if not data or not StoreService:HasPass(player, "DailyEgg") or StoreService.restricted[player] then
		return nil
	end
	local day = math.floor(os.time() / 86400)
	if data.dailyEggDay >= day then
		return nil
	end
	data.dailyEggDay = day
	return self:Open(player, true)
end

function HatchService:Start()
	ReplicatedStorage.Remotes.KeepPets.OnServerInvoke = function(player, picks)
		if typeof(picks) ~= "table" then
			return false, "?"
		end
		for _, i in picks do
			if typeof(i) ~= "number" or i < 1 or i > 3 then
				return false, "?"
			end
		end
		return self:Keep(player, picks)
	end
end

return HatchService
