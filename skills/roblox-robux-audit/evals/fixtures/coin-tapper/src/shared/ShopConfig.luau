--!strict
-- Coin Tapper Simulator: everything sold for Robux.
-- Coins are spent on eggs (EggService), passes are kept forever.

local ShopConfig = {}

ShopConfig.PRODUCTS = {
	StarterPack = {
		id = 1820001001,
		robux = 99,
		name = "STARTER PACK",
		desc = "Golden Cat pet + 5,000 coins + VIP chat tag!",
		coins = 5000,
		pet = "GoldenCat",
	},
	Coins1k = { id = 1820001002, robux = 49, name = "1,000 Coins", coins = 1000 },
	Coins10k = { id = 1820001003, robux = 149, name = "10,000 Coins", coins = 10000 },
	Coins50k = { id = 1820001004, robux = 399, name = "50,000 Coins", coins = 50000 },
}

ShopConfig.PASSES = {
	DoubleCoins = { id = 90001, robux = 199, name = "2x COINS", desc = "Double coins on EVERYTHING, forever!" },
	LuckyEgg = { id = 90002, robux = 299, name = "LUCKY EGG", desc = "A free Mystery Egg every day!" },
}

return ShopConfig
