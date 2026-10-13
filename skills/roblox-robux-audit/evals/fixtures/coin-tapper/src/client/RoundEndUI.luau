--!strict
-- The end-of-round screen (the coin-rush minigame).

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShopConfig = require(ReplicatedStorage.Shared.ShopConfig)

local RoundEndUI = {}

function RoundEndUI:Show(result: { won: boolean, coinsLeft: number })
	if result.won then
		print("🎉 You won the coin rush!")
		return
	end
	-- lost the round and broke: get them straight back in
	if result.coinsLeft < 100 then
		print("😢 Out of coins? Get back in the game!")
		MarketplaceService:PromptProductPurchase(Players.LocalPlayer, ShopConfig.PRODUCTS.Coins1k.id)
	end
end

return RoundEndUI
