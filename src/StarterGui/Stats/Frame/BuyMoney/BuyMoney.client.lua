local MarketPlaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local lplr = game.Players.LocalPlayer

local BuyMoneyGui = script.Parent
local BuyMoneyButton = script.Parent.Parent.Money.BuyMoney


-- OPEN OR CLOSE THE BUY MONEY GUI

BuyMoneyButton.MouseButton1Down:Connect(function()
	
	-- If the gui is open, close it otherwise open it
	if BuyMoneyGui.Visible then
		BuyMoneyGui:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5)
		TweenService:Create(BuyMoneyButton, TweenInfo.new(0.5), {Rotation = 0}):Play()
		wait(0.5)
		BuyMoneyGui.Visible = false

	else
		BuyMoneyGui.Visible = true
		BuyMoneyGui:TweenPosition(UDim2.new(0.5,0,0.475,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5)
		TweenService:Create(BuyMoneyButton, TweenInfo.new(0.5), {Rotation = 315}):Play()
	end
end)



-- PLAYER CLICKS THE MONEY GAMEPASS BUTTON

BuyMoneyGui.MoneyGamepass.MouseButton1Down:Connect(function()
	if lplr.GamePasses.DoubleMoney.Value then

		-- If the player already owns the pass, he can't buy it again
		script.Parent.DoubleMoneyOwned.Visible = true
		script.Parent.MoneyGamepass.Visible = false
		wait(6)
		script.Parent.MoneyGamepass.Visible = true
		script.Parent.DoubleMoneyOwned.Visible = false
	else
		MarketPlaceService:PromptGamePassPurchase(lplr, 42479448)
	end
end)


-- PROMPT THE PURCHASE OF THE DEVELOPER PRODUCTS WHEN ONE OF THE BUY MONEY BUTTONS IS CLICKED

local function PromptPurchase(productID)
	MarketPlaceService:PromptProductPurchase(lplr, productID)
end


-- PLAYER CLICKS THE $50 000 MONEY BUTTON

BuyMoneyGui.Frame.Money1.MouseButton1Down:Connect(function()
	PromptPurchase(1260353045)
end)

-- PLAYER CLICKS THE $100 000 MONEY BUTTON

BuyMoneyGui.Frame.Money2.MouseButton1Down:Connect(function()
	PromptPurchase(1260353043)
end)

-- PLAYER CLICKS THE $250 000 MONEY BUTTON

BuyMoneyGui.Frame.Money3.MouseButton1Down:Connect(function()
	PromptPurchase(1260353041)
end)

-- PLAYER CLICKS THE $1 000 000 MONEY BUTTON

BuyMoneyGui.Frame.Money4.MouseButton1Down:Connect(function()
	PromptPurchase(1260353039)
end)
