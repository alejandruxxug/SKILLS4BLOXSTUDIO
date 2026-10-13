--!strict
-- Mystery Eggs: 2,500 coins each, a random pet inside.

local DataService = require(script.Parent.DataService)
local PetService = require(script.Parent.PetService)
local ShopService = require(script.Parent.ShopService)

local EGG_PRICE = 2500
local ODDS = { { "Cat", 60 }, { "Dog", 30 }, { "Dragon", 9 }, { "Unicorn", 1 } }

local EggService = {}

local function roll(): string
	local n = math.random() * 100
	for _, entry in ODDS do
		n -= entry[2]
		if n <= 0 then
			return entry[1]
		end
	end
	return ODDS[1][1]
end

function EggService:Hatch(player: Player)
	local data = DataService:Get(player)
	if not data or data.coins < EGG_PRICE then
		return nil
	end
	data.coins -= EGG_PRICE
	local pet = roll()
	PetService:Give(player, pet)
	return pet
end

-- 🥚 LUCKY EGG pass: one free egg per day
function EggService:DailyLuckyEgg(player: Player)
	local data = DataService:Get(player)
	if not data or not ShopService:HasPass(player, "LuckyEgg") then
		return nil
	end
	local today = math.floor(os.time() / 86400)
	if data.lastLuckyEgg >= today then
		return nil
	end
	data.lastLuckyEgg = today
	local pet = roll()
	PetService:Give(player, pet)
	return pet
end

EggService.ODDS = ODDS
return EggService
