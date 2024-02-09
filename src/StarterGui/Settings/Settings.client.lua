local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SettingsRemoteEvent = ReplicatedStorage:WaitForChild("Settings")

local TweenService = game:GetService("TweenService")

local lplr = game.Players.LocalPlayer
local SettingGui = lplr.PlayerGui:WaitForChild("Settings")
local DisplayClock = SettingGui:WaitForChild("Frame"):WaitForChild("DisplayClock"):WaitForChild("Frame"):WaitForChild("DisplayClock")
local TransparentClock = SettingGui.Frame:WaitForChild("TransparentClock"):WaitForChild("Frame"):WaitForChild("TransparentClock")
local DisplayHappyBirthday = SettingGui.Frame:WaitForChild("DisplayHappyBirthday"):WaitForChild("Frame"):WaitForChild("DisplayHappyBirthday")
local DisplayVehicleKeyHelp = SettingGui.Frame:WaitForChild("DisplayVehicleKeyHelp"):WaitForChild("Frame"):WaitForChild("DisplayVehicleKeyHelp")
local BusStopBeam = SettingGui.Frame:WaitForChild("BusStopBeam"):WaitForChild("Frame"):WaitForChild("BusStopBeam")
local DeliveryHouseBeam = SettingGui.Frame:WaitForChild("DeliveryHouseBeam"):WaitForChild("Frame"):WaitForChild("DeliveryHouseBeam")

local SettingsOpen = false
local debounce = false


-- SETTINGS BUTTON CLICK

SettingGui.Button.MouseButton1Down:Connect(function()
	if not debounce then
		debounce = true
		
		if SettingsOpen == false then -- if gui is closed
			SettingsOpen = true -- gui is open
			
			local RotateButton = TweenService:Create(SettingGui.Button, TweenInfo.new(0.5), {Rotation = 180})
			RotateButton:Play() -- rotate the settings button 180°

			SettingGui.Frame.Visible = true
			SettingGui.Frame:TweenSizeAndPosition(UDim2.new(0.37,0,0.521,0), UDim2.new(0.99,0,0.1,0), nil, nil, 0.5)
			wait(1)
			
		else -- if gui is open
			SettingsOpen = false -- gui is closed
			
			local RotateButton = TweenService:Create(SettingGui.Button, TweenInfo.new(0.5), {Rotation = 0})
			RotateButton:Play() -- rotate the settings button -180°
			
			SettingGui.Frame:TweenSizeAndPosition(UDim2.new(0.06,0,0.03,0), UDim2.new(0.99,0,0.02,0), nil, nil, 0.5)
			wait(0.5)
			SettingGui.Frame.Visible = false
			wait(1)
		end	
		debounce = false
	end
end)


DisplayClock.MouseButton1Down:Connect(function()
	
	if lplr.Settings.DisplayClock.Value == true then
		SettingsRemoteEvent:FireServer("DisplayClock", false)
		DisplayClock.TextTransparency = 1
		lplr.PlayerGui.Stats.Frame.Clock.Visible = false
	else
		SettingsRemoteEvent:FireServer("DisplayClock", true)
		DisplayClock.TextTransparency = 0
		lplr.PlayerGui.Stats.Frame.Clock.Visible = true
	end
end)

TransparentClock.MouseButton1Down:Connect(function()
	if lplr.Settings.TransparentClock.Value == true then
		SettingsRemoteEvent:FireServer("TransparentClock", false)
		TransparentClock.TextTransparency = 1
		lplr.PlayerGui.Stats.Frame.Clock.BackgroundTransparency = 0
	else
		SettingsRemoteEvent:FireServer("TransparentClock", true)
		TransparentClock.TextTransparency = 0
		lplr.PlayerGui.Stats.Frame.Clock.BackgroundTransparency = 1
	end
end)

DisplayHappyBirthday.MouseButton1Down:Connect(function()
	if lplr.Settings.DisplayHappyBirthday.Value == true then
		SettingsRemoteEvent:FireServer("DisplayHappyBirthday", false)
		DisplayHappyBirthday.TextTransparency = 1
	else
		SettingsRemoteEvent:FireServer("DisplayHappyBirthday", true)
		DisplayHappyBirthday.TextTransparency = 0
	end
end)

DisplayVehicleKeyHelp.MouseButton1Down:Connect(function()
	if lplr.Settings.DisplayVehicleKeyHelp.Value == true then
		SettingsRemoteEvent:FireServer("DisplayVehicleKeyHelp", false)
		DisplayVehicleKeyHelp.TextTransparency = 1
	else
		SettingsRemoteEvent:FireServer("DisplayVehicleKeyHelp", true)
		DisplayVehicleKeyHelp.TextTransparency = 0
	end
end)

BusStopBeam.MouseButton1Down:Connect(function()
	if lplr.Settings.BusStopBeam.Value == true then
		SettingsRemoteEvent:FireServer("BusStopBeam", false)
		BusStopBeam.TextTransparency = 1
	else
		SettingsRemoteEvent:FireServer("BusStopBeam", true)
		BusStopBeam.TextTransparency = 0
	end
end)

DeliveryHouseBeam.MouseButton1Down:Connect(function()
	if lplr.Settings.DeliveryHouseBeam.Value == true then
		SettingsRemoteEvent:FireServer("DeliveryHouseBeam", false)
		DeliveryHouseBeam.TextTransparency = 1
	else
		SettingsRemoteEvent:FireServer("DeliveryHouseBeam", true)
		DeliveryHouseBeam.TextTransparency = 0
	end
end)