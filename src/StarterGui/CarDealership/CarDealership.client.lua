local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuyCarRemoteEvent = ReplicatedStorage:WaitForChild("BuyCar")

local lplr = game.Players.LocalPlayer
local CarDealerShipGui = lplr.PlayerGui:WaitForChild("CarDealership"):WaitForChild("Frame")
local CurrentCar = 1
--local TweenCompleted = true
--local FireFunction = true
--local RotateCar = false
--local TweenCar = 0
local debounce = false


--local Folder = Instance.new("Folder", lplr)
--Folder.Name = "CarsOwned"

--local Car = Instance.new("BoolValue", Folder)
--Car.Name = "Ambulance"

--local Car = Instance.new("BoolValue", Folder)
--Car.Name = "Aventador"

--local Car = Instance.new("BoolValue", Folder)
--Car.Name = "Bus"
--Car.Value = true


local CarTable = { -- [1] = CarName (for the values in the settings),[2] = CarName (to display on the gui), [3] = Stats

	-- Stats :
	-- [1] = TopSpeed (MaxSpeed attribute), Min : 0, Max : 250
	-- [2] = Acceleration (DrivingTorque attribute), Min : 0, Max : 90 000
	-- [3] = ReverseSpeed (ReverseSpeeed attribute), Min : 0, Max : 150
	-- [4] = Handling (MaxSteer attribute), Min : 0.2 or 1 (0.2 doesn't turn enough, 1 turns too much), Max : 0.6
	-- [5] = CrashResistance (StrutSpringStiffnessFront and StrutSpringStiffnessRear attributes), Min : 0, Max : 28000 (27000 for the rear one)
	
	
	[1] = {
		"Car1",
		"Bicycle",
		100000,
		
		--[[
		Stats :
			Top speed : 55
			Acceleration : 7500
			Reverse speed : 10
			Handling : 0.4
			Crash resistance : 2000
		--]]
		
		CarStats = {
			0.22,
			0.31,
			0.067,
			0.67,
			0.07
		}
	},

	[2] = {
		"Car2",
		"Nimi",
		250000,
		
		--[[
		Stats :
			Top speed : 110
			Acceleration : 12 500
			Reverse speed : 20
			Handling : 0.5
			Crash resistance : 10 000
		--]]
		
		CarStats = {
			0.44,
			0.139,
			0.133,
			0.833,
			0.36
		}
	},

	[3] = {
		"Car3",
		"Sedan",
		500000,
		
		--[[
		Stats :
			Top speed : 150
			Acceleration : 25 000
			Reverse speed : 50
			Handling : 0.6
			Crash resistance : 25 000
		--]]
		
		CarStats = {
			0.6,
			0.278,
			0.333,
			0.95,
			0.893
		}
	}
}


-- DETERMINE THE COLOR AT A GIVEN TIME OF A COLOR SEQUENCE

local function GetColorFromColorSequence(Time) -- see https://developer.roblox.com/en-us/api-reference/datatype/ColorSequence#evaluation for more explanation on how this function works
	
	local cs = ColorSequence.new{ -- color sequence used for the stats
		ColorSequenceKeypoint.new(0, Color3.new(0,1,0)),
		ColorSequenceKeypoint.new(0.5, Color3.new(1,1,0)),
		ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
	}

	-- If we are at 0, 0.5 or 1, we already know the values, because they are the keypoints
	if Time == 0 then return Color3.new(0,1,0) end
	if Time == 0.5 then return Color3.new(1,1,0) end
	if Time == 1 then return Color3.new(1,0,0) end

	for i = 1, #cs.Keypoints - 1 do

		local this = cs.Keypoints[i]
		local next = cs.Keypoints[i + 1]

		if Time >= this.Time and Time < next.Time then

			local alpha = (Time - this.Time) / (next.Time - this.Time)

			local ColorAtTimeX = Color3.new(
				(next.Value.R - this.Value.R) * alpha + this.Value.R,
				(next.Value.G - this.Value.G) * alpha + this.Value.G,
				(next.Value.B - this.Value.B) * alpha + this.Value.B
			) 
			
			if Time > 0.5 then -- if Time > 0.5, add a yellow color at 0.5 in the colorsequence, otherwise the gradient looks ugly (not a nice transition from green to red)
				return ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.new(0,1,0)),
					ColorSequenceKeypoint.new(0.5, Color3.new(1,1,0)),
					ColorSequenceKeypoint.new(1, ColorAtTimeX)
				}
				
			else -- if Time < 0.5, don't need to add a yellow color at 0.5
				return ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.new(0,1,0)),
					ColorSequenceKeypoint.new(1, ColorAtTimeX)
				}
			end
		end
	end
end


-- ARROW CLICK FUNCTION

local function OnArrowClick(Direction)

	if CarDealerShipGui.CarDisplay.ViewportFrame:FindFirstChild(CarTable[CurrentCar][1]) then -- find the previous car in the viewportframe if there is one
		CarDealerShipGui.CarDisplay.ViewportFrame:FindFirstChild(CarTable[CurrentCar][1]):Destroy() --- destroy it if found
	end

	if Direction == "Left" then -- if player clicked the left arrow
		if CurrentCar > 1 then -- if the current car is not the first one (make sure that it is more than one, because can't be 0)
			CurrentCar = CurrentCar - 1
		else
			CurrentCar = #CarTable -- max number of car (last one)
		end

	elseif Direction == "Right" then -- if player clicked the right arrow
		if CurrentCar < #CarTable then -- if the current car is not the last one (make sure that it is less than 3 (the max number of car))
			CurrentCar = CurrentCar + 1
		else
			CurrentCar = 1 -- min number of car (first one)
		end
	end

	if lplr.Cars:FindFirstChild(CarTable[CurrentCar][1]) then -- find the car in the player cars owned
		if lplr.Cars:FindFirstChild(CarTable[CurrentCar][1]).Value == true then -- if the value is true, the player owns the car, if it's false, he doesn't

			CarDealerShipGui.Owned.Visible = true -- show the owned text label
			CarDealerShipGui.Buy.Visible = false -- hide the buy button

		else
			CarDealerShipGui.Buy.Visible = true -- show the buy button
			CarDealerShipGui.Owned.Visible = false -- hide the owned text label
		end
	end

	CarDealerShipGui.CarName.TextLabel.Text = CarTable[CurrentCar][2] -- change the name of the car

	CarDealerShipGui.Price.Text = "$"..tostring(CarTable[CurrentCar][3])

	CarDealerShipGui.Stats.Stats.TopSpeed.Frame.Frame:TweenSize(UDim2.new(CarTable[CurrentCar]["CarStats"][1], 0, 0.5, 0), nil, Enum.EasingStyle.Quint, 0.4) -- tween the stats
	CarDealerShipGui.Stats.Stats.Acceleration.Frame.Frame:TweenSize(UDim2.new(CarTable[CurrentCar]["CarStats"][2], 0, 0.5, 0), nil, Enum.EasingStyle.Quint, 0.4)
	CarDealerShipGui.Stats.Stats.ReverseSpeed.Frame.Frame:TweenSize(UDim2.new(CarTable[CurrentCar]["CarStats"][3], 0, 0.5, 0), nil, Enum.EasingStyle.Quint, 0.4)
	CarDealerShipGui.Stats.Stats.Handling.Frame.Frame:TweenSize(UDim2.new(CarTable[CurrentCar]["CarStats"][4], 0, 0.5, 0), nil, Enum.EasingStyle.Quint, 0.4)
	CarDealerShipGui.Stats.Stats.CrashResistance.Frame.Frame:TweenSize(UDim2.new(CarTable[CurrentCar]["CarStats"][5], 0, 0.5, 0), nil, Enum.EasingStyle.Quint, 0.4)
	
	CarDealerShipGui.Stats.Stats.TopSpeed.Frame.Frame.UIGradient.Color = GetColorFromColorSequence(CarTable[CurrentCar]["CarStats"][1]) -- change the uigradient color sequence of the stats
	CarDealerShipGui.Stats.Stats.Acceleration.Frame.Frame.UIGradient.Color = GetColorFromColorSequence(CarTable[CurrentCar]["CarStats"][2])
	CarDealerShipGui.Stats.Stats.ReverseSpeed.Frame.Frame.UIGradient.Color = GetColorFromColorSequence(CarTable[CurrentCar]["CarStats"][3])
	CarDealerShipGui.Stats.Stats.Handling.Frame.Frame.UIGradient.Color = GetColorFromColorSequence(CarTable[CurrentCar]["CarStats"][4])
	CarDealerShipGui.Stats.Stats.CrashResistance.Frame.Frame.UIGradient.Color = GetColorFromColorSequence(CarTable[CurrentCar]["CarStats"][5])
	
	local DisplayCar = workspace.CarDealership.Cars:FindFirstChild(CarTable[CurrentCar][1]):Clone() -- clone the car to the viewportframe to display it
	
	DisplayCar.Parent = CarDealerShipGui.CarDisplay.ViewportFrame -- change the car's parent to the viewportframe
	
	--repeat RunService.Heartbeat:Wait() until RotateCar == false -- wait until the rotate car value is false so that the coroutine and the loop can end (otherwise, rotate car is set back to true before the coroutine and so the loop starts again, and two coroutines are now running, which errors because the )
	
	--RotateCar = true -- variable to know when to rotate the car
	--TweenCompleted = true
	
	--while RotateCar == true do -- while player hasn't clicked on of the arrow or the close button, keep tweening the car
		
	--	if TweenCompleted == true then -- if the tween has finished, restart it
			
	--		coroutine.wrap(function() -- coroutine so that the while loop can still run without having to wait for the tween (wouldn't work otherwise when trying to click on the arrows, couldn't stop tween which would then accumulate and create lag)
	--			TweenCompleted = false -- tween is not finished anymore
	--			TweenCar = TweenService:Create(DisplayCar.PrimaryPart, TweenInfo.new(3, Enum.EasingStyle.Linear), {Orientation = DisplayCar.PrimaryPart.Orientation - Vector3.new(0,90,0)}) -- remake the tween each time because it uses the current orientation of the car and so it has to be updated each time
	--			TweenCar:Play()

	--			TweenCar.Completed:Connect(function() -- once the tween is completed, change the TweenCompleted variable to true
	--				TweenCompleted = true
	--			end)
	--		end)()
	--	end
	--	RunService.Heartbeat:Wait()
	--end

	--FireFunction = true -- ready to fire the function again (coroutine is finished and won't fire again (otherwise lag))
end


-- BUY CAR TRIGGER

workspace.CarDealership.ATM1.Button.ClickDetector.MouseClick:Connect(function()
	workspace.CarDealership.ATM1.Button.ClickDetector.MaxActivationDistance = 0 -- disable the click detectors by changing their max activation distance to 0
	workspace.CarDealership.ATM2.Button.ClickDetector.MaxActivationDistance = 0
	CarDealerShipGui.Visible = true
	OnArrowClick(CurrentCar)
end)

workspace.CarDealership.ATM2.Button.ClickDetector.MouseClick:Connect(function()
	CarDealerShipGui.Visible = true
	OnArrowClick(CurrentCar)
end)

-- ON ARROW BUTTONS CLICK

CarDealerShipGui.LeftArrow.MouseButton1Down:Connect(function()
	--RotateCar = false -- stop rotating the while loop
	
	--repeat RunService.Heartbeat:Wait() until FireFunction == true -- loop until the coroutine has finished running (stop tweening)
	--FireFunction = false -- can't fire function anymore
	OnArrowClick("Left")
end)


-- BUY BUTTON CLICK

CarDealerShipGui.Buy.MouseButton1Down:Connect(function()
	BuyCarRemoteEvent:FireServer(CarTable[CurrentCar][1])
end)


-- IF PLAYER HAS SUCCESSFULLY BOUGHT A CAR

BuyCarRemoteEvent.OnClientEvent:Connect(function() -- if player bought the car, show the owned text
	CarDealerShipGui.Owned.Visible = true
	CarDealerShipGui.Buy.Visible = false
end)


-- CLOSE BUTTON CLICK

CarDealerShipGui.RightArrow.MouseButton1Down:Connect(function()
	--RotateCar = false -- stop the while loop
	
	--repeat RunService.Heartbeat:Wait() until FireFunction == true -- loop until the coroutine has finished running (stop tweening)
	--FireFunction = false -- can't fire funcition anymore
	OnArrowClick("Right")
end)


-- CLOSE BUTTON CLICK

CarDealerShipGui.Close.MouseButton1Down:Connect(function()
	workspace.CarDealership.ATM1.Button.ClickDetector.MaxActivationDistance = 10 -- reset the max activation distance so that the player can use the click detectors again
	workspace.CarDealership.ATM2.Button.ClickDetector.MaxActivationDistance = 10
	--RotateCar = false -- stop rotating the car
	CarDealerShipGui.Visible = false

end)

--TweenService:Create(game.StarterGui.CarDealership.Frame.CarDisplay.ViewportFrame.Sedan.PrimaryPart, TweenInfo.new(3, Enum.EasingStyle.Linear), {Orientation = game.StarterGui.CarDealership.Frame.CarDisplay.ViewportFrame.Sedan.PrimaryPart.Orientation - Vector3.new(0,360,0)}):Play()
--game.TweenService:Create(game.StarterGui.CarDealership.Frame.CarDisplay.ViewportFrame.Sedan.PrimaryPart, TweenInfo.new(3, Enum.EasingStyle.Linear), {Orientation = game.StarterGui.CarDealership.Frame.CarDisplay.ViewportFrame.Sedan.PrimaryPart.Orientation - Vector3.new(0,360,0)}):Play()
--game.TweenService:Create(workspace.Sedan.PrimaryPart, TweenInfo.new(3, Enum.EasingStyle.Linear), {Orientation = workspace.Sedan.PrimaryPart.Orientation - Vector3.new(0,360,0)}):Play()
--game.TweenService:Create(workspace.Sedan.PrimaryPart, TweenInfo.new(3, Enum.EasingStyle.Linear), {
--	CFrame = workspace.Sedan.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(180),0)
--}):Play()

--game.TweenService:Create(game.StarterGui.CarDealership.Frame.CarDisplay.ViewportFrame.Sedan.PrimaryPart, TweenInfo.new(3, Enum.EasingStyle.Linear), {CFrame = game.StarterGui.CarDealership.Frame.CarDisplay.ViewportFrame.Sedan.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(90),0)}):Play()