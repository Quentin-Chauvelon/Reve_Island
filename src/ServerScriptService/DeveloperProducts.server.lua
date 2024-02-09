local MarketPlaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")

-- Data store for tracking purchases that were successfully processed
local purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")

-- Table setup containing product IDs and functions for handling purchases
local productFunctions = {}


-- GIVE A CERTAIN AMOUNT OF MONEY TO THE PLAYER BASED ON WHAT HE BOUGHT
local function GiveMoneyDeveloperProduct(plr, Amount)
	MoneyBindableFunction:Invoke(plr, Amount, "+")
end


-- $50 000 MONEY PRODUCT
productFunctions[1251123370] = function(receipt, plr)
	local OldMoney = plr.leaderstats.Money.Value
	GiveMoneyDeveloperProduct(plr, 50000)
	if OldMoney ~= plr.leaderstats.Money.Value then
		return true
	end
end

-- $100 000 MONEY PRODUCT
productFunctions[1251126281] = function(receipt, plr)
	local OldMoney = plr.leaderstats.Money.Value
	GiveMoneyDeveloperProduct(plr, 100000)
	if OldMoney ~= plr.leaderstats.Money.Value then
		return true
	end
end

-- $250 000 MONEY PRODUCT
productFunctions[1251126280] = function(receipt, plr)
	local OldMoney = plr.leaderstats.Money.Value
	GiveMoneyDeveloperProduct(plr, 250000)
	if OldMoney ~= plr.leaderstats.Money.Value then
		return true
	end
end

-- $1 000 000 MONEY PRODUCT
productFunctions[1251126282] = function(receipt, plr)
	local OldMoney = plr.leaderstats.Money.Value
	GiveMoneyDeveloperProduct(plr, 1000000)
	if OldMoney ~= plr.leaderstats.Money.Value then
		return true
	end
end


-- The core 'ProcessReceipt' callback function
local function processReceipt(receiptInfo)

	-- Determine if the product was already granted by checking the data store  
	local playerProductKey = receiptInfo.PlayerId.."_"..receiptInfo.PurchaseId
	
	local purchased = false
	local success, errorMessage = pcall(function()
		purchased = purchaseHistoryStore:GetAsync(playerProductKey)
	end)
	
	-- If purchase was recorded, the product was already granted
	if success and purchased then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif not success then
		--error("Data store error:" .. errorMessage)
	end

	-- Find the player who made the purchase in the server
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- The player probably left the game
		-- If they come back, the callback will be called again
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Look up handler function from 'productFunctions' table above
	local handler = productFunctions[receiptInfo.ProductId]

	-- Call the handler function and catch any errors
	local success, result = pcall(handler, receiptInfo, player)
	if not success or not result then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Record transaction in data store so it isn't granted again
	local success, errorMessage = pcall(function()
		purchaseHistoryStore:SetAsync(playerProductKey, true)
	end)
	if not success then
		--error("Cannot save purchase data: " .. errorMessage)
	end
	
	
	-- IMPORTANT: Tell Roblox that the game successfully handled the purchase
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Set the callback; this can only be done once by one script on the server! 
MarketPlaceService.ProcessReceipt = processReceipt