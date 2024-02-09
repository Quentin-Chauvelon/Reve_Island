local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GarageRemoteEvent = ReplicatedStorage:WaitForChild("Garage")

local lplr = game.Players.LocalPlayer
local GarageGui = script.Parent:WaitForChild("Frame")


-- PLAYER ENTERED THE GARAGE

GarageRemoteEvent.OnClientEvent:Connect(function()
	
	GarageGui.Visible = true
	
	local Palette = GarageGui.Body.PaletteTemplate:Clone()
	
	-- For all colors on the palette
	for i,v in ipairs(Palette:GetChildren()) do
		if v:IsA("ImageButton") then
			v.MouseButton1Down:Connect(function()
				
				GarageRemoteEvent:FireServer("Body", v.BackgroundColor3)
			end)
		end
	end
	
	Palette.Name = "Palette"
	Palette.Visible = true
	Palette.Parent = GarageGui.Body
end)


-- PLAYER CHANGES HIS REGISTRATION NUMBER

GarageGui.Registration.Choose.MouseButton1Down:Connect(function()
	GarageRemoteEvent:FireServer("Registration", GarageGui.Registration.RegistrationNumber.Text)
end)



-- PLAYER CLICKS THE LEAVE BUTTON IN THE GARAGE

GarageGui.Leave.MouseButton1Down:Connect(function() -- fire server to let it know that the player wants to leave the garage
	
	if GarageGui.Body:FindFirstChild("Palette") then
		GarageGui.Body:FindFirstChild("Palette"):Destroy()
	end
	
	GarageGui.Registration.RegistrationNumber.Text = ""
	GarageGui.Visible = false
	
	GarageRemoteEvent:FireServer("Leave")
end)


-- PLAYER CLICKS THE SKATEBOARD BUTTON

script.Parent.SkateBoard.MouseButton1Down:Connect(function()
	GarageRemoteEvent:FireServer("SkateBoard")
end)


-- If the player is not using a mouse, move the button up
if UserInputService.TouchEnabled then
	script.Parent.SkateBoard.Position = UDim2.new(0.99,0,0.65,0)
end