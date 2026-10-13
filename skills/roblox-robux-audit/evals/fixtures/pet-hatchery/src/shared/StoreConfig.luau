--!strict
-- Pet Hatchery: Robux items. Gems buy pets in the Gem Shop (fixed pets, no random).
-- Eggs are bought with gems too and are random.

local StoreConfig = {}

StoreConfig.STARTER_HOURS = 24 -- the starter pack is offered for 24 h after the first join

StoreConfig.PRODUCTS = {
	Starter = { id = 3300001, robux = 79, name = "STARTER PACK", desc = "A Rare Fox + 300 gems. One time only!", gems = 300, pet = "Fox" },
	Gems100 = { id = 3300002, robux = 99, name = "100 Gems", gems = 100 },
	-- the Gem Shop's "buy with Robux" buttons: one product per price, the server remembers which pet
	ShopPet99 = { id = 3300010, robux = 99, name = "SHOP PET (99)" },
	ShopPet199 = { id = 3300011, robux = 199, name = "SHOP PET (199)" },
	TripleHatch = { id = 3300020, robux = 35, name = "TRIPLE HATCH", desc = "Keep all 3 pets from your next hatch" },
}

StoreConfig.PASSES = {
	AutoHatch = { id = 77001, robux = 149, name = "AUTO HATCH", desc = "Hatch eggs automatically" },
	DailyEgg = { id = 77002, robux = 199, name = "DAILY EGG", desc = "1 free Basic Egg every day (odds: Common 70%, Rare 25%, Epic 5%)" },
}

StoreConfig.MAX_PETS = 60

return StoreConfig
