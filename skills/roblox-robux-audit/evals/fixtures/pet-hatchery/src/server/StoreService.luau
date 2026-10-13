--!strict
-- Robux purchases.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local SaveService = require(script.Parent.SaveService)
local GemShopService = require(script.Parent.GemShopService)

local StoreService = {
	passes = {} :: { [Player]: { [string]: boolean } },
	restricted = {} :: { [Player]: boolean },
}

local function productKey(id: number): string?
	for key, p in StoreConfig.PRODUCTS do
		if p.id == id then
			return key
		end
	end
	return nil
end

function StoreService:HasPass(player: Player, key: string): boolean
	return self.passes[player] ~= nil and self.passes[player][key] == true
end

function StoreService:StarterOffered(player: Player): boolean
	local data = SaveService.data[player]
	return data ~= nil and not data.gotStarter
end

-- returns false if it can't be granted right now
function StoreService:Grant(player: Player, key: string): boolean
	local data = SaveService.data[player]
	local p = StoreConfig.PRODUCTS[key]
	if key == "Starter" then
		data.gotStarter = true
		table.insert(data.pets, p.pet)
		data.gems += p.gems
	elseif key == "Gems100" then
		data.gems += p.gems
	elseif key == "ShopPet99" or key == "ShopPet199" then
		return GemShopService:GrantRobux(player, key, p.robux)
	elseif key == "TripleHatch" then
		data.tripleCredits += 1
	end
	return true
end

function StoreService:Start()
	MarketplaceService.ProcessReceipt = function(receipt)
		local player = Players:GetPlayerByUserId(receipt.PlayerId)
		local data = player and SaveService.data[player]
		if not player or not data then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		local id = tostring(receipt.PurchaseId)
		if table.find(data.receipts, id) then
			return if SaveService:Save(player)
				then Enum.ProductPurchaseDecision.PurchaseGranted
				else Enum.ProductPurchaseDecision.NotProcessedYet
		end
		local key = productKey(receipt.ProductId)
		if not key then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		if #data.pets >= StoreConfig.MAX_PETS and (key == "Starter" or key == "ShopPet99" or key == "ShopPet199") then
			-- no room for the pet
			ReplicatedStorage.Remotes.Toast:FireClient(player, "Your pet inventory is full!")
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		if not self:Grant(player, key) then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		table.insert(data.receipts, id)
		if #data.receipts > 50 then
			table.remove(data.receipts, 1)
		end
		if not SaveService:Save(player) then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	Players.PlayerAdded:Connect(function(player)
		self.passes[player] = {}
		self.restricted[player] = true
		task.spawn(function()
			local ok, info = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, player)
			self.restricted[player] = not ok or info.ArePaidRandomItemsRestricted
		end)
		for key, pass in StoreConfig.PASSES do
			task.spawn(function()
				for attempt = 1, 4 do
					local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, pass.id)
					if ok then
						if owns then
							self.passes[player][key] = true
						end
						return
					end
					task.wait(attempt)
				end
			end)
		end
	end)
	-- passes bought in game are picked up on the next join (UserOwnsGamePassAsync above)

	ReplicatedStorage.Remotes.CanBuy.OnServerInvoke = function(player, key)
		if key == "DailyEgg" and self.restricted[player] then
			return false
		end
		if key == "Starter" then
			return self:StarterOffered(player)
		end
		return true
	end
end

return StoreService
