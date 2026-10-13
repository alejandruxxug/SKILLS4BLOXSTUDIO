--!strict
-- 💎 The Gem Shop: 6 fixed pets on a rotating shelf (changes every 10 min).
-- Pay with gems, or with Robux (one product per price; we remember which pet you tapped).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SaveService = require(script.Parent.SaveService)

local GemShopService = {
	pending = {} :: { [Player]: { pet: string, price: number } }, -- the pet a Robux buy is for
}

local SHELF_PRICES = { Fox = 99, Owl = 99, Panda = 199, Tiger = 199 } -- gems, or the same number of R$

function GemShopService:BuyWithGems(player: Player, pet: string): boolean
	local data = SaveService.data[player]
	local price = SHELF_PRICES[pet]
	if not data or not price or data.gems < price then
		return false
	end
	data.gems -= price
	table.insert(data.pets, pet)
	return true
end

-- the client calls this right before prompting ShopPet<price>
function GemShopService:StartRobux(player: Player, pet: string): boolean
	local price = SHELF_PRICES[pet]
	if not price then
		return false
	end
	self.pending[player] = { pet = pet, price = price }
	return true
end

function GemShopService:GrantRobux(player: Player, key: string, robux: number): boolean
	local data = SaveService.data[player]
	local deal = self.pending[player]
	self.pending[player] = nil
	if deal and ("ShopPet" .. deal.price) == key then
		table.insert(data.pets, deal.pet)
	else
		-- no deal waiting (it rotated?): pay them back in gems, plus a little sorry bonus
		data.gems += robux * 2
		ReplicatedStorage.Remotes.Toast:FireClient(player, "Sorry! Here are some gems instead 💎")
	end
	return true
end

function GemShopService:Start()
	ReplicatedStorage.Remotes.StartGemShopRobux.OnServerInvoke = function(player, pet)
		return typeof(pet) == "string" and self:StartRobux(player, pet)
	end
end

return GemShopService
