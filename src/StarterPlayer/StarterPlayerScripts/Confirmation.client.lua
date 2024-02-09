local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ConfirmationRemoteEvent = ReplicatedStorage:WaitForChild("BuyConfirmation")
local lplr = game.Players.LocalPlayer
local ConfirmationGui = lplr.PlayerGui:WaitForChild("BuyConfirmation"):WaitForChild("Confirmation")


-- THE PLAYER IS TRYING TO BUY SOMETHING BUT MUST CONFIRM FIRST

ConfirmationRemoteEvent.OnClientEvent:Connect(function(Item)
	ConfirmationGui.Item.Text = "Are you sure you want to buy : "..Item.." ?" 
	ConfirmationGui.Visible = true
	ConfirmationGui:TweenSize(UDim2.new(0.5,0,0.2,0), nil, nil, 0.3)
end)


-- HIDE GUI

local function HideGui()
	ConfirmationGui:TweenSize(UDim2.new(0,0,0,0), nil, nil, 0.3)
	wait(1)
	ConfirmationGui.Visible = false
end


-- PLAYER CLICKS THE YES BUTTON

ConfirmationGui.Yes.MouseButton1Down:Connect(function()
	script.Confirm.Value = 2
	HideGui()
end)


-- PLAYER CLICKS THE NO BUTTON

ConfirmationGui.No.MouseButton1Down:Connect(function()
	script.Confirm.Value = 1
	HideGui()
end)