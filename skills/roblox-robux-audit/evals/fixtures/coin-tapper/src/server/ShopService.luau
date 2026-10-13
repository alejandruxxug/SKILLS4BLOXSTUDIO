--!strict
-- Robux purchases: developer products (ProcessReceipt) and passes.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShopConfig = require(ReplicatedStorage.Shared.ShopConfig)
local DataService = require(script.Parent.DataService)
local PetService = require(script.Parent.PetService)

local ShopService = { passes = {} :: { [Player]: { [string]: boolean } } }

local function productById(id: number)
	for key, product in ShopConfig.PRODUCTS do
		if product.id == id then
			return key, product
		end
	end
	return nil, nil
end

function ShopService:HasPass(player: Player, key: string): boolean
	return self.passes[player] ~= nil and self.passes[player][key] == true
end

function ShopService:Grant(player: Player, key: string, product: any)
	local data = DataService:Get(player)
	data.coins += product.coins or 0
	if key == "StarterPack" then
		data.gotStarter = true
		PetService:Give(player, product.pet)
		player:SetAttribute("VIP", true)
	end
end

function ShopService:Start()
	MarketplaceService.ProcessReceipt = function(receipt)
		local player = Players:GetPlayerByUserId(receipt.PlayerId)
		if not player then
			-- they left, nothing to give
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		local key, product = productById(receipt.ProductId)
		if not key then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		self:Grant(player, key, product)
		DataService:Save(player)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	Players.PlayerAdded:Connect(function(player)
		self.passes[player] = {}
		for key, pass in ShopConfig.PASSES do
			local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, pass.id)
			if ok and owns then
				self.passes[player][key] = true
			end
		end
	end)
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, bought)
		if not bought then
			return
		end
		for key, pass in ShopConfig.PASSES do
			if pass.id == passId then
				self.passes[player][key] = true
			end
		end
	end)

	-- 🎁 players who bought the Starter Pack on the website get it when they join
	ReplicatedStorage.Remotes.ClaimStarterBonus.OnServerEvent:Connect(function(player, boughtOnWeb)
		local data = DataService:Get(player)
		if boughtOnWeb and data and not data.gotStarter then
			self:Grant(player, "StarterPack", ShopConfig.PRODUCTS.StarterPack)
		end
	end)
end

return ShopService
