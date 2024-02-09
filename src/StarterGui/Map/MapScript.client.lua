local LocalizationService = game:GetService("LocalizationService")

local MapGui = script.Parent:WaitForChild("Frame")

local CloseGui, TogglePins


-- WHEN PLAYER CLICKS THE FULLSCREEN BUTTON ON THE MAP AT THE SPAWN

workspace.Spawn.Map.Fullscreen.SurfaceGui:WaitForChild("Fullscreen").Activated:Connect(function()
	if not MapGui.IsFullScreen.Value then
		MapGui.IsFullScreen.Value = true
		
		-- Show the legend in english or french based on the roblox language of the player
		if string.sub(game.Players.LocalPlayer.LocaleId, 0, 2) == "fr" then
			MapGui.FR.Position = UDim2.new(0.5, math.floor(MapGui.Map.AbsoluteSize.X / 2), 0.5, 0)
			MapGui.FR.Visible = true
		else
			MapGui.EN.Position = UDim2.new(0.5, math.floor(MapGui.Map.AbsoluteSize.X / 2), 0.5, 0)
			MapGui.EN.Visible = true
		end

		MapGui.Visible = true
		
		-- Hide gui and disconnect events when player clicks the close button
		CloseGui = MapGui.Close.MouseButton1Down:Connect(function()
			
			MapGui.Visible = false
			MapGui.IsFullScreen.Value = false
			
			-- Disconnect events
			CloseGui:Disconnect()
			TogglePins:Disconnect()
		end)
		
		
		-- Toggle the pins on the map
		TogglePins = MapGui.PinToggle.MouseButton1Down:Connect(function()
			
			if MapGui.PinToggle.Hidden.Value then
				MapGui.PinToggle.Hidden.Value = false
				
				MapGui.PinToggle.Frame:TweenPosition(UDim2.new(0.75,0,0.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.2)
				MapGui.PinToggle.BackgroundColor3 = Color3.fromRGB(88, 194, 49)

				MapGui.Pins.Visible = true
				
			else
				MapGui.PinToggle.Hidden.Value = true
				
				MapGui.PinToggle.Frame:TweenPosition(UDim2.new(-0.1,0,0.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.2)
				MapGui.PinToggle.BackgroundColor3 = Color3.fromRGB(184,184,184)

				MapGui.Pins.Visible = false
			end
			
		end)
		
		MapGui.PinToggle.Position = UDim2.new(0.5, -MapGui.Map.AbsoluteSize.X / 2 + 40, 0.5, -MapGui.Map.AbsoluteSize.Y / 2 + 15)
	end
end)