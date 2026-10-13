--!strict
-- 🛒 The store: the starter banner with its countdown, gems, passes.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

local StoreUI = {}

local shownAt = os.clock() -- when this screen was first built (each join)

local function countdownText(): string
	local left = math.max(0, StoreConfig.STARTER_HOURS * 3600 - (os.clock() - shownAt))
	return string.format("LIMITED: %02d:%02d:%02d", left // 3600, (left % 3600) // 60, left % 60)
end

local function buy(key: string, id: number, isPass: boolean)
	if not ReplicatedStorage.Remotes.CanBuy:InvokeServer(key) then
		return
	end
	if isPass then
		MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, id)
	else
		MarketplaceService:PromptProductPurchase(Players.LocalPlayer, id)
	end
end

function StoreUI:Build(frame: Frame)
	local starter = StoreConfig.PRODUCTS.Starter
	local banner = Instance.new("TextButton")
	banner.Text = `{starter.name} · {starter.desc} · R$ {starter.robux}`
	banner.Parent = frame
	local timer = Instance.new("TextLabel")
	timer.Parent = banner
	task.spawn(function()
		while banner.Parent do
			timer.Text = countdownText()
			task.wait(1)
		end
	end)
	banner.Activated:Connect(function()
		buy("Starter", starter.id, false)
	end)

	for key, pass in StoreConfig.PASSES do
		local b = Instance.new("TextButton")
		b.Text = `{pass.name}\n{pass.desc}\nR$ {pass.robux}`
		b.Parent = frame
		b.Activated:Connect(function()
			buy(key, pass.id, true)
		end)
	end
end

-- 🃏 TRIPLE HATCH, offered on the hatch screen when you pick 2–3 pets
function StoreUI:BuyTripleHatch()
	buy("TripleHatch", StoreConfig.PRODUCTS.TripleHatch.id, false)
end

-- 💎 Gem Shop R$ button: remember the pet, then prompt its price's product
function StoreUI:BuyShopPetWithRobux(pet: string, price: number)
	if ReplicatedStorage.Remotes.StartGemShopRobux:InvokeServer(pet) then
		MarketplaceService:PromptProductPurchase(Players.LocalPlayer, StoreConfig.PRODUCTS["ShopPet" .. price].id)
	end
end

return StoreUI
