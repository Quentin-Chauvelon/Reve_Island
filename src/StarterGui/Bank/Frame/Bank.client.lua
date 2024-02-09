local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BankRemoteEvent = ReplicatedStorage:WaitForChild("Bank")
local lplr = game.Players.LocalPlayer
local BankGui = lplr.PlayerGui:WaitForChild("Bank"):WaitForChild("Frame")

local WalkSpeed = 16
local debounce = false


-- CHECK IF THE PLAYER IS TYPING A NUMBER

--BankGui.Withdraw.Amount:GetPropertyChangedSignal("Text"):Connect(function()
--	BankGui.Withdraw.Amount.Text = BankGui.Withdraw.Amount.Text:gsub('%D+', '') -- remove any text that isn't a decimal
--end)


-- PLAYER TRIGGERS THE BANK GUI

workspace.Bank.Trigger.Touched:Connect(function(hit)

	if Players:FindFirstChild(hit.Parent.Name) and Players[hit.Parent.Name] == lplr then
		if not debounce then
			debounce = true

			WalkSpeed = workspace[lplr.Name].Humanoid.WalkSpeed
			workspace[lplr.Name].Humanoid.WalkSpeed = 0
			workspace[lplr.Name].HumanoidRootPart.Anchored = true

			BankGui.MoneyDisplay.Money.Text = "$"..lplr.Stats.BankAccount.Value -- change the money in the bank account to the player
			BankGui.Visible = true
			BankGui:TweenPosition(UDim2.new(0.5,0,0.5,0), nil, nil, 0.5)
			wait(0.5)		
		end
	end
end)


-- PLAYER CLICKS ON THE WITHDRAW BUTTON

BankGui.Buttons.Withdraw.MouseButton1Down:Connect(function()
	BankGui.Buttons.Visible = false
	BankGui.Withdraw.Visible = true
	BankGui.Withdraw.Maximum.Text = "You can withdraw between $1 and $"..lplr.Stats.BankAccount.Value -- change the maximum withdraw text
	BankGui.Back.Visible = true
end)


-- PLAYER WITHDRAWS MONEY

BankGui.Withdraw.Withdraw.MouseButton1Down:Connect(function()
	if BankGui.Withdraw.Amount.Text ~= "" then

		BankRemoteEvent:FireServer("Withdraw", BankGui.Withdraw.Amount.Text) -- remove money from the bank account		
		BankGui.Withdraw.Amount.Text = "" -- remove the text in the amount textbox
		
		wait(0.5)
		lplr.PlayerGui.Bank.Frame.MoneyDisplay.Money.Text = "$"..tostring(lplr.Stats.BankAccount.Value)
		lplr.PlayerGui.Bank.Frame.Withdraw.Maximum.Text = "You can withdraw between $1 and $"..tostring(lplr.Stats.BankAccount.Value)
	end
end)


-- PLAYER CLICKS ON THE DEPOSIT BUTTON

BankGui.Buttons.Deposit.MouseButton1Down:Connect(function()
	BankGui.Buttons.Visible = false
	BankGui.Deposit.Visible = true
	
	BankGui.Deposit.Maximum.Text = "You can deposit between $1 and $"..lplr.leaderstats.Money.Value -- change the maximum deposit text
	
	BankGui.Back.Visible = true
end)


-- PLAYER DEPOSITS MONEY

BankGui.Deposit.Deposit.MouseButton1Down:Connect(function()
	if BankGui.Deposit.Amount.Text ~= "" then
		
		BankRemoteEvent:FireServer("Deposit", BankGui.Deposit.Amount.Text) -- add money to the bank account
		BankGui.Withdraw.Amount.Text = "" -- remove the text in the amount textbox
		
		wait(0.5)
		lplr.PlayerGui.Bank.Frame.MoneyDisplay.Money.Text = "$"..tostring(lplr.Stats.BankAccount.Value)
		lplr.PlayerGui.Bank.Frame.Deposit.Maximum.Text = "You can deposit between $1 and $"..tostring(lplr.Stats.BankAccount.Value)
	end
end)


-- PLAYER CLICKS ON THE BACK BUTTON

local function Back()
	BankGui.Withdraw.Visible = false -- set visible properties to go back
	BankGui.Deposit.Visible = false	
	BankGui.Buttons.Visible = true
end


-- PLAYER CLICKS ON THE CLOSE BUTTON

local function Close()
	workspace[lplr.Name].HumanoidRootPart.CFrame = workspace.Bank.PlayerPlacement.CFrame
	workspace[lplr.Name].Humanoid.WalkSpeed =  WalkSpeed
	workspace[lplr.Name].HumanoidRootPart.Anchored = false

	BankGui:TweenPosition(UDim2.new(0.5,0,1.5,0), nil, nil, 0.5)
	wait(0.5)
	BankGui.Visible = false

	BankGui.Withdraw.Visible = false -- set visible properties to close
	BankGui.Deposit.Visible = false	
	BankGui.Buttons.Visible = true
	
	debounce = false
end


-- CLICKS TO FIRE THE BACK AND CLOSE FUNCTION

BankGui.Back.TextButton.MouseButton1Down:Connect(Back)
BankGui.Back.Arrow.MouseButton1Down:Connect(Back)

BankGui.Close.TextButton.MouseButton1Down:Connect(Close)
BankGui.Close.Cross.MouseButton1Down:Connect(Close)