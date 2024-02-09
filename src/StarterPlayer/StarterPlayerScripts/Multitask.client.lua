local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MoneyRemoteEvent = ReplicatedStorage:WaitForChild("Money")
local MultitaskRemoteEvent = ReplicatedStorage:WaitForChild("Multitask")

local lplr = game.Players.LocalPlayer
local AddMoney = lplr.PlayerGui:WaitForChild("Stats"):WaitForChild("Frame"):WaitForChild("Money"):WaitForChild("AddMoney")
AddMoney:WaitForChild("Money")

local TweenSpeed = TweenInfo.new(0.3)
local ShowMoney = TweenService:Create(AddMoney, TweenSpeed, {Position = UDim2.new(1.2,0,0.5,0)})
local HideMoney = TweenService:Create(AddMoney, TweenSpeed, {Position = UDim2.new(0,0,0.5,0)})

local DeliveryTVStarted


-- MONEY

MoneyRemoteEvent.OnClientEvent:Connect(function(Value, Symbol)
	
	lplr.PlayerGui.Stats.Frame.Money.Money.Text = "$"..tostring(lplr.leaderstats.Money.Value) -- set the money gui value to the player's money
	
	-- ANIMATION TO SHOW THE MONEY THE PLAYER EARNT OR SPENT
	
	if AddMoney:FindFirstChild("Money") then
		AddMoney.Money.Text = Symbol.." $"..Value
	else
		AddMoney:WaitForChild("Money").Text = Symbol.." $"..Value
	end
	
	AddMoney.Visible = true
	ShowMoney:Play()
	wait(5)
	HideMoney:Play()
	wait(0.3)
	AddMoney.Visible = false
end)


-- SCROLLING TV

DeliveryTVStarted = workspace.Delivery.DeliveryTrigger.Touched:Connect(function()
	DeliveryTVStarted:Disconnect()
	
	coroutine.wrap(function()
		while true do
			for i=1,5 do
				game.Workspace.Delivery.SupplyCenter.ScrollingMenu1.SurfaceGui.Frame:TweenPosition(UDim2.new(0,0,-i,0))
				game.Workspace.Delivery.SupplyCenter.ScrollingMenu2.SurfaceGui.Frame:TweenPosition(UDim2.new(0,0,-i,0))
				wait(3)
			end
			for i=4,0,-1 do
				game.Workspace.Delivery.SupplyCenter.ScrollingMenu1.SurfaceGui.Frame:TweenPosition(UDim2.new(0,0,-i,0))
				game.Workspace.Delivery.SupplyCenter.ScrollingMenu2.SurfaceGui.Frame:TweenPosition(UDim2.new(0,0,-i,0))
				wait(3)
			end
		end
	end)()
end)


-- CASINO CHIPS

-- when the player spends or earns a casino chip, update the text on the wall of the casino
MultitaskRemoteEvent.OnClientEvent:Connect(function(Type, numberOfChips)

	if Type and Type == "CasinoChips" then
		if numberOfChips and typeof(numberOfChips) == "number" then
			workspace.Casino.CasinoChips.SurfaceGui.TextLabel.Text = tostring(numberOfChips)
		end
	end
end)