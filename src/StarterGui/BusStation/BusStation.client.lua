local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BusStationRemoteEvent = ReplicatedStorage:WaitForChild("BusStation")

local ExteriorPane = workspace.BusStation.ExteriorColor.Pane.SurfaceGui:WaitForChild("Frame")
local InteriorPane = workspace.BusStation.InteriorColor.Pane.SurfaceGui:WaitForChild("Frame")
local ExteriorLineSelection = ExteriorPane:WaitForChild("LineSelection")
local InteriorLineSelection = InteriorPane:WaitForChild("LineSelection")
local ExteriorPartSelection = ExteriorPane:WaitForChild("PartSelection")
local InteriorPartSelection = InteriorPane:WaitForChild("PartSelection")
local ExteriorColorSelection = ExteriorPane:WaitForChild("ColorSelection")
local InteriorColorSelection = InteriorPane:WaitForChild("ColorSelection")

local lplr = game.Players.LocalPlayer
local BusStationGui = lplr.PlayerGui:WaitForChild("BusStation"):WaitForChild("Frame")

local ExteriorCurrentLine = 1
local ExteriorCurrentPart = 1

local InteriorCurrentLine = 1
local InteriorCurrentPart = 1
local InteriorPartSide = 1 -- 0 = left, 1 = center, 2 = right

local debounce = false


-- IF THE PLAYER USES A TOUCHSCREEN, MOVE THE NEXT STOP GUI DOWN OTHERWISE, IT IS BEING OVERLAPPED BY THE BUS BUTTONS AT THE TOP
if game:GetService("UserInputService").TouchEnabled then
	BusStationGui:WaitForChild("NextStop").Position = UDim2.new(0.5,0,0.38,0)
	BusStationGui:WaitForChild("TextLabel").Position = UDim2.new(0.5,0,0.23,0)
end


-- SELECT THE LINE (Exterior)

ExteriorLineSelection.LeftArrow.Activated:Connect(function()
	if not debounce then
		debounce = true

		ExteriorLineSelection.Lines:TweenPosition(UDim2.new((ExteriorLineSelection.Lines.Position.X.Scale + 0.954),0,0,0), nil, nil, 0.5)
		wait(0.5)
		
		if ExteriorCurrentLine > 1 then
			ExteriorCurrentLine = ExteriorCurrentLine - 1
		else
			ExteriorCurrentLine = 3
			ExteriorLineSelection.Lines.Position = UDim2.new(-1.408,0,0,0)
		end
		
		debounce = false
	end
end)

ExteriorLineSelection.RightArrow.Activated:Connect(function()
	if not debounce then
		debounce = true
		
		ExteriorLineSelection.Lines:TweenPosition(UDim2.new((ExteriorLineSelection.Lines.Position.X.Scale - 0.954),0,0,0), nil, nil, 0.5)		
		wait(0.5)
		
		if ExteriorCurrentLine < 3 then
			ExteriorCurrentLine = ExteriorCurrentLine + 1
		else
			ExteriorCurrentLine = 1
			ExteriorLineSelection.Lines.Position = UDim2.new(0.5,0,0,0)
		end
		
		debounce = false
	end
end)


-- SELECT THE PART (Exterior)

ExteriorPartSelection.LeftArrow.Activated:Connect(function()
	if not debounce then
		debounce = true

		ExteriorPartSelection.Parts:TweenPosition(UDim2.new((ExteriorPartSelection.Parts.Position.X.Scale + 1.0905),0,0,0), nil, nil, 0.5)
		wait(0.5)

		if ExteriorCurrentPart > 1 then
			ExteriorCurrentPart = ExteriorCurrentPart - 1
		else
			ExteriorCurrentPart = 3
			ExteriorPartSelection.Parts.Position = UDim2.new(-1.408,0,0,0)
		end
		
		debounce = false
	end
end)

ExteriorPartSelection.RightArrow.Activated:Connect(function()
	if not debounce then
		debounce = true

		ExteriorPartSelection.Parts:TweenPosition(UDim2.new((ExteriorPartSelection.Parts.Position.X.Scale - 1.0905),0,0,0), nil, nil, 0.5)		
		wait(0.5)

		if ExteriorCurrentPart < 3 then
			ExteriorCurrentPart = ExteriorCurrentPart + 1
		else
			ExteriorCurrentPart = 1
			ExteriorPartSelection.Parts.Position = UDim2.new(0.5,0,0,0)
		end
		
		debounce = false
	end
end)


-- SELECT THE LINE (Interior)

InteriorLineSelection.LeftArrow.Activated:Connect(function()
	if not debounce then
		debounce = true

		InteriorLineSelection.Lines:TweenPosition(UDim2.new((InteriorLineSelection.Lines.Position.X.Scale + 0.954),0,0,0), nil, nil, 0.5)
		wait(0.5)
		
		if InteriorCurrentLine > 1 then
			InteriorCurrentLine = InteriorCurrentLine - 1
		else
			InteriorCurrentLine = 3
			InteriorLineSelection.Lines.Position = UDim2.new(-1.408,0,0,0)
		end
		
		--if InteriorLineSide == 0 then
		--	if InteriorCurrentLine == 3 then
		--		InteriorCurrentLine = 1
		--		InteriorLineSelection.Lines.Position = UDim2.new(0.5,0,0,0)
		--		InteriorLineSide = 1
		--	else
		--		InteriorCurrentLine = InteriorCurrentLine + 1
		--	end

		--elseif InteriorLineSide == 1 then
		--	InteriorLineSide = 0
		--	InteriorCurrentLine = 2

		--elseif InteriorLineSide == 2 then
		--	InteriorCurrentLine = InteriorCurrentLine - 1
		--	if InteriorCurrentLine == 1 then
		--		InteriorLineSide = 1
		--	end
		--end

		debounce = false
	end
end)

InteriorLineSelection.RightArrow.Activated:Connect(function()
	if not debounce then
		debounce = true

		InteriorLineSelection.Lines:TweenPosition(UDim2.new((InteriorLineSelection.Lines.Position.X.Scale - 0.954),0,0,0), nil, nil, 0.5)		
		wait(0.5)

		if InteriorCurrentLine < 3 then
			InteriorCurrentLine = InteriorCurrentLine + 1
		else
			InteriorCurrentLine = 1
			InteriorLineSelection.Lines.Position = UDim2.new(0.5,0,0,0)
		end

		debounce = false
	end
end)


-- SELECT THE PART (Interior)

InteriorPartSelection.LeftArrow.Activated:Connect(function()
	if not debounce then
		debounce = true

		InteriorPartSelection.Parts:TweenPosition(UDim2.new((InteriorPartSelection.Parts.Position.X.Scale + 1.0905),0,0,0), nil, nil, 0.5)
		wait(0.5)

		if InteriorPartSide == 0 then
			InteriorCurrentPart = 1
			InteriorPartSelection.Parts.Position = UDim2.new(0.5,0,0,0)
			InteriorPartSide = 1

		elseif InteriorPartSide == 1 then
			InteriorPartSide = 0
			InteriorCurrentPart = 2

		elseif InteriorPartSide == 2 then
			InteriorCurrentPart = InteriorCurrentPart - 1
			if InteriorCurrentPart == 1 then
				InteriorPartSide = 1
			end
		end
		
		debounce = false
	end
end)

InteriorPartSelection.RightArrow.Activated:Connect(function()
	if not debounce then
		debounce = true

		InteriorPartSelection.Parts:TweenPosition(UDim2.new((InteriorPartSelection.Parts.Position.X.Scale - 1.0905),0,0,0), nil, nil, 0.5)		
		wait(0.5)

		if InteriorPartSide == 0 then
			InteriorCurrentPart = InteriorCurrentPart - 1
			if InteriorCurrentPart == 1 then
				InteriorPartSide = 1
			end

		elseif InteriorPartSide == 1 then
			InteriorPartSide = 2
			InteriorCurrentPart = 2

		elseif InteriorPartSide == 2 then
			InteriorCurrentPart = 1
			InteriorPartSelection.Parts.Position = UDim2.new(0.5,0,0,0)
			InteriorPartSide = 1
		end
		
		debounce = false
	end
end)

-- DETECT THE COLOR CLICK

for i,v in ipairs(ExteriorColorSelection:GetChildren()) do
	if v:IsA("ImageButton") then
		v.Activated:Connect(function() -- on button clicked, fire the server to change the color
			BusStationRemoteEvent:FireServer("Customisations", ExteriorCurrentLine, ExteriorCurrentPart, v.BackgroundColor3)
		end)
	end
end

for i,v in ipairs(InteriorColorSelection:GetChildren()) do
	if v:IsA("ImageButton") then
		v.Activated:Connect(function()
			BusStationRemoteEvent:FireServer("Customisations", InteriorCurrentLine, (InteriorCurrentPart + 3), v.BackgroundColor3)
		end)
	end
end


-- RESET THE COLOR OF THE BUS

ExteriorPane.Reset.Activated:Connect(function()
	BusStationRemoteEvent:FireServer("Reset", ExteriorCurrentLine, nil, nil)
end)

InteriorPane.Reset.Activated:Connect(function()
	BusStationRemoteEvent:FireServer("Reset", InteriorCurrentLine, nil, nil)
end)


-- OPEN DOORS BUTTON

BusStationGui.OpenDoors.MouseButton1Click:Connect(function()
	BusStationRemoteEvent:FireServer("OpenDoors", nil, nil, nil)
end)

-- CLOSE DOORS BUTTON

BusStationGui.CloseDoors.MouseButton1Click:Connect(function()
	BusStationRemoteEvent:FireServer("CloseDoors", nil, nil, nil)
end)


-- DELETE BUTTON

workspace.BusStation.BinButton.SurfaceGui.ImageButton.MouseButton1Down:Connect(function()
	BusStationRemoteEvent:FireServer("DeleteBus", nil, nil, nil)
end)