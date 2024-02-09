local Players = game:GetService("Players")
local MarketPlaceService = game:GetService("MarketplaceService")


-- CHECK IF THE PLAYER OWNS THE GAMEPASSES WHEN JOINING

Players.PlayerAdded:Connect(function(plr)
	
	-- Money
	local HasDoubleMoneyPass = false

	local success, errormessage = pcall(function()
		HasDoubleMoneyPass = MarketPlaceService:UserOwnsGamePassAsync(plr.UserId, 42479448)
	end)

	if success and HasDoubleMoneyPass then
		if plr:FindFirstChild("GamePasses") and plr.GamePasses:FindFirstChild("DoubleMoney") then
			plr.GamePasses.DoubleMoney.Value = true
		end
	end

	-- Experience
	local HasDoubleXPPass = false

	local success, errormessage = pcall(function()
		HasDoubleXPPass = MarketPlaceService:UserOwnsGamePassAsync(plr.UserId, 42480055)
	end)

	if success and HasDoubleXPPass then
		if plr:FindFirstChild("GamePasses") and plr.GamePasses:FindFirstChild("DoubleXP") then
			plr.GamePasses.DoubleXP.Value = true
		end
	end

	-- Radio
	local HasRadioPass = false

	local success, errormessage = pcall(function()
		HasRadioPass = MarketPlaceService:UserOwnsGamePassAsync(plr.UserId, 42480240)
	end)

	if success and HasRadioPass then
		if plr:FindFirstChild("GamePasses") and plr.GamePasses:FindFirstChild("Radio") then
			plr.GamePasses.Radio.Value = true
		end
	end
end)


-- Activate the game pass the player bougth

local function ActivateGamePass(plr, GamePassName)
	if plr:FindFirstChild("GamePasses") and plr.GamePasses:FindFirstChild(GamePassName) then
		plr.GamePasses[GamePassName].Value = true
	end
end



-- Player completes a game pass purchase

local function onPromptGamePassPurchaseFinished(plr, purchasedPassID, purchaseSuccess)

	if purchaseSuccess == true then
		
		if purchasedPassID == 42479448 then
			ActivateGamePass(plr, "DoubleMoney")
			
		elseif purchasedPassID == 42480055 then
			ActivateGamePass(plr, "DoubleXP")
			
		elseif purchasedPassID == 42480240 then
			ActivateGamePass(plr, "Radio")
		end		
	end
end

-- Fire the onPromptGamePassPurchaseFinished when a purchase finishes
MarketPlaceService.PromptGamePassPurchaseFinished:Connect(onPromptGamePassPurchaseFinished)