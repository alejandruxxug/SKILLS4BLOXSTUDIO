--!strict
-- The 💰 SHOP screen.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShopConfig = require(ReplicatedStorage.Shared.ShopConfig)

local ShopUI = {}

-- what each coin card shows under its price
local CARDS = {
	{ key = "Coins1k", price = "R$ 49", tag = nil },
	{ key = "Coins10k", price = "R$ 99", tag = nil },
	{ key = "Coins50k", price = "R$ 399", tag = "BEST VALUE", was = "WAS R$ 999" },
}

function ShopUI:Build(frame: Frame)
	for i, card in CARDS do
		local product = ShopConfig.PRODUCTS[card.key]
		local button = Instance.new("TextButton")
		button.Name = card.key
		button.Text = `{product.name}\n{card.price}`
		button.Position = UDim2.fromOffset((i - 1) * 140, 0)
		button.Size = UDim2.fromOffset(130, 160)
		button.Parent = frame
		if card.was then
			local was = Instance.new("TextLabel")
			was.Text = card.was -- shown crossed out above the price
			was.Parent = button
		end
		if card.tag then
			local tag = Instance.new("TextLabel")
			tag.Text = card.tag
			tag.Parent = button
		end
		button.Activated:Connect(function()
			MarketplaceService:PromptProductPurchase(Players.LocalPlayer, product.id)
		end)
	end

	-- passes
	for key, pass in ShopConfig.PASSES do
		local button = Instance.new("TextButton")
		button.Name = key
		button.Text = `{pass.name}\n{pass.desc}\nR$ {pass.robux}`
		button.Parent = frame
		button.Activated:Connect(function()
			MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, pass.id)
		end)
	end

	-- 🎁 starter pack banner
	local starter = ShopConfig.PRODUCTS.StarterPack
	local banner = Instance.new("TextButton")
	banner.Name = "Starter"
	banner.Text = `{starter.name}: {starter.desc} R$ {starter.robux}`
	banner.Parent = frame
	banner.Activated:Connect(function()
		MarketplaceService:PromptProductPurchase(Players.LocalPlayer, starter.id)
	end)
end

return ShopUI
