local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeliveryTruckRemoteEvent = ReplicatedStorage:WaitForChild("DeliveryTruck")

local Delivery = workspace.Delivery
local ToggleHouseGUI = script.Parent.Frame.ToggleHouseGui
local SupplyCenter = Delivery.SupplyCenter
local DeliveryGui = script.Parent.Delivery
local GPS = script.Parent.GPS
local lplr = game.Players.LocalPlayer

local PreviousHouse = nil
local PreviousYPosition = nil
local HouseVisible = nil
local bagdebounce = false
local toggledebounce = false
local clickdebounce = false

SupplyCenter.Conveyors.First.AssemblyLinearVelocity = Vector3.new(8,0,0)
SupplyCenter.Conveyors.FirstToSecondTransition.AssemblyLinearVelocity = Vector3.new(0,0,-8)
SupplyCenter.Conveyors.Second.AssemblyLinearVelocity = Vector3.new(0,0,-8)
SupplyCenter.Conveyors.SecondToThirdTransition.AssemblyLinearVelocity = Vector3.new(8,0,0)
SupplyCenter.Conveyors.Third.AssemblyLinearVelocity = Vector3.new(8,0,0)


-- IF PLAYER CLICKS ON ONE OF THE HOUSES BUTTONS GUI

local function OnHouseClick(Number, YPosition) -- get the number (which house) and the yposition (of the mouse to know where to start the tweening from)
	if not clickdebounce then
		clickdebounce = true
		
		if PreviousHouse then -- use the previous house to close it with a tween (check if previous house)
			HouseVisible = PreviousHouse.Visible -- variable use to know if the menu is open or close when clicking on the same button multiple times (otherwise curent and previous house are the same, so it closes and reopens which looks bad)
			PreviousHouse.Order:TweenSizeAndPosition(UDim2.new(0,0,0,0), UDim2.new(0.76,0,0,PreviousYPosition), nil, nil, 0.2)
			wait(0.2)
			PreviousHouse.Visible = false
		end
		
		local CurrentHouse = script.Parent.Houses["House"..Number]
		if CurrentHouse == PreviousHouse and HouseVisible == true then -- if the house clicked is the same than before and it's already on, then do nothing
		else
			CurrentHouse.Order.Position = UDim2.new(0.76,0,0,YPosition)
			CurrentHouse.Visible = true
			CurrentHouse.Order:TweenSizeAndPosition(UDim2.new(0.3,0,0.7,0), UDim2.new(0.425,0,0.57,0), nil, nil, 0.3)
			wait(0.3)
			PreviousHouse = CurrentHouse -- change the current house to previous house
			PreviousYPosition = YPosition -- get the Y position to close the previous house
		end

		wait(0.1)
		clickdebounce = false
	end
end


-- WHEN PLAYERS CLICKS ON THE EYE BUTTON TO OPEN/CLOSE THE HOUSE BUTTONS GUI

local function OnToggleGui()
	if not toggledebounce then
		toggledebounce = true
		
		if ToggleHouseGUI.GuiOn.Value == true then -- if the gui is on, turn it off
			ToggleHouseGUI.GuiOn.Value = false
			ToggleHouseGUI.TextLabel.Text = "X" -- add a cross at the center of the eye
			
			if PreviousHouse then -- check if previous house is not nil otherwise it wouldn't work
				HouseVisible = PreviousHouse.Visible -- see previous function (above)
				PreviousHouse.Order:TweenSizeAndPosition(UDim2.new(0,0,0,0), UDim2.new(0.76,0,0,PreviousYPosition), nil, nil, 0.1)
				wait(0.1)
				PreviousHouse.Visible = false
			end -- close the menu if one is open before closing the gui
			
			script.Parent.Frame:TweenPosition(UDim2.new(1.01,0,0.98,0, nil, nil, 0.5))
			
			if DeliveryGui.Visible == true then
				DeliveryGui.Frame:TweenPosition(UDim2.new(0.5,0,0.95,0), nil, nil, 0.5)
				DeliveryGui.TextLabel:TweenPosition(UDim2.new(0,0,0.13,0), nil, nil, 0.5)
			end -- move the delivery gui to the left if it is visible
			wait(0.5)
			
		else -- if it's off, turn it on
			ToggleHouseGUI.GuiOn.Value = true
			
			if DeliveryGui.Visible == false then
				script.Parent.Frame:TweenPosition(UDim2.new(0.747,0,0.98,0, nil, nil, 0.5))
			end
			
			script.Parent.Frame:TweenPosition(UDim2.new(0.747,0,0.98,0, nil, nil, 0.5))
			ToggleHouseGUI.TextLabel.Text = "" -- remove the cross ("X")
			
			if DeliveryGui.Visible == true then
				DeliveryGui.Frame:TweenPosition(UDim2.new(0.37,0,0.95,0), nil, nil, 0.5)
				DeliveryGui.TextLabel:TweenPosition(UDim2.new(-0.13,0,0.13,0), nil, nil, 0.5)
			end -- move the delivery gui back to the center if it is invisible
			wait(0.5)
		end
		
		wait(0.1)
		toggledebounce = false
	end
end

ToggleHouseGUI.MouseButton1Click:Connect(OnToggleGui) -- trigger if players clicks on the "eye" button to show/hide the gui


-- IF PLAYER CLICKS A MEAL (EVENT FIRED FROM THE SERVER)

DeliveryTruckRemoteEvent.OnClientEvent:Connect(function(Type, MealClicked, MealNumber, NumberNeeded, Money)
	
	if Type == "ItemNeeded" then -- player clicked an item that was needed
		
		local Item = SupplyCenter.ScrollingMenu1.SurfaceGui.Frame:FindFirstChild("Item"..MealNumber) -- try to find clicked meal on the first scrolling TV
		if not Item then -- if clicked meal is not on the first scrolling TV
			Item = SupplyCenter.ScrollingMenu2.SurfaceGui.Frame:FindFirstChild("Item"..MealNumber) -- try to find clicked meal on the second scrolling TV
		end

		Item.Needed.Text = "Needed : "..NumberNeeded

		repeat wait(0.1) until bagdebounce == false -- wait for the previous bag to move before creating a new one
		if not bagdebounce then
			bagdebounce = true

			local MealClone = SupplyCenter.DeliveryBag:Clone() -- create a bag
			MealClone.Parent = SupplyCenter.DeliveryBags
			MealClone.SurfaceGui.Item.Text = MealClicked
			MealClone.CanCollide = true
			MealClone.Anchored = false
			wait(0.8)
			bagdebounce = false
		end

		if SupplyCenter.ItemsNeededMoney:FindFirstChild(lplr.Name) then
			SupplyCenter.MoneyDisplay.SurfaceGui.TextLabel.Text = "$"..SupplyCenter.ItemsNeededMoney:FindFirstChild(lplr.Name).Value -- change the amount of money on the display that the player should earn
		end
		
		
	elseif Type == "LowerMoney" then -- lower by $10 the money the player should earn
		
		if SupplyCenter.ItemsNeededMoney:FindFirstChild(lplr.Name) then
			SupplyCenter.MoneyDisplay.SurfaceGui.TextLabel.Text = "$"..SupplyCenter.ItemsNeededMoney:FindFirstChild(lplr.Name).Value -- change the amount of money on the display that the player should earn
		end
		
		
	elseif Type == "Start" then -- if the player started the delivery
		
		for i,v in ipairs(workspace.Delivery.HousesParking:GetChildren()) do -- show the blue parking spots
			v.Transparency = 0.6
		end
		
		
	elseif Type == "Reset" then -- if the player left the job or delivered all the meals to the houses
		
		for i,v in ipairs(SupplyCenter.ScrollingMenu1.SurfaceGui.Frame:GetChildren()) do -- change all the items needed text on the tv to "0"
			v.Needed.Text = "0"
		end
		
		for i,v in ipairs(SupplyCenter.ScrollingMenu2.SurfaceGui.Frame:GetChildren()) do
			v.Needed.Text = "0"
		end
		
		for i,v in ipairs(workspace.Delivery.HousesParking:GetChildren()) do -- hide the blue parking spots
			v.Transparency = 1
		end
		
	elseif Type == "OpenDeliveryGui" then
		DeliveryGui.TextLabel.Text = "What do you want to deliver to house "..MealClicked.." ?"
		DeliveryGui.Visible = true
		DeliveryGui:TweenSize(UDim2.new(1,0,1,0), nil, nil, 0.5)
		
	elseif Type == "HideDeliveryGui" then
		DeliveryGui:TweenSizeAndPosition(UDim2.new(0,0,0,0), UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5) -- tween the delivery frame
	end
end)


-- WHEN PLAYER CLICKS THE GPS BUTTON

GPS.Frame.TextButton.MouseButton1Click:Connect(function()
	if ToggleHouseGUI.GuiOn.Value == true then OnToggleGui() end -- fire the function to close the gui only if it is on
	if GPS.IsGPSOn.Value == true then
		GPS.IsGPSOn.Value = false
		GPS.Buttons:TweenSizeAndPosition(UDim2.new(0,0,0,0), UDim2.new(0.5,0,0.85,0), nil, nil, 0.2)
		wait(0.3)
	else
		GPS.IsGPSOn.Value = true
		GPS.Buttons.Visible = true
		GPS.Buttons:TweenSizeAndPosition(UDim2.new(0.8,0,0.7,0), UDim2.new(0.5,0,0.118,0), nil, nil, 0.4)
		wait(0.5)
	end
end)


-- SET GPS TO HOUSE

local function SetGPS(House)
	local Truck = workspace.Delivery.Trucks:FindFirstChild(lplr.Name.."sTruck")
	
	if Truck then
		
		local Beam = Truck.Body.HouseTrigger:FindFirstChild("Beam")
		local HouseParking = workspace.Delivery.HousesParking:FindFirstChild("House"..House)
		local Previous
		local Button = GPS.Buttons:FindFirstChild("House"..House)
		
		if Beam and HouseParking and Button then -- if the both the beam and the house parking have been found

			if not Button.Delivered.Value then -- if player hasn't delivered to the house yet

				if GPS.Buttons.PreviousHouse.Value == tonumber(House) then -- if the player is trying to set the gps to the same house
					Beam.Attachment1 = nil -- then remove it
					GPS.Buttons.PreviousHouse.Value = 0
					Button.UIGradient.Color = ColorSequence.new {
						ColorSequenceKeypoint.new(0, Color3.fromRGB(80,140,212)), -- change the color of the button to grey
						ColorSequenceKeypoint.new(1, Color3.fromRGB(96, 170, 255))
					}

				else -- if player is trying to set the gps to a new house
					Beam.Attachment1 = HouseParking.Attachment -- change the attachment of the beam to the house parking

					if GPS.Buttons.PreviousHouse.Value ~= 0 then -- if the gps was already set to a house, change the color of the previous house button to blue
						
						local PreviousButton = GPS.Buttons:FindFirstChild("House"..GPS.Buttons.PreviousHouse.Value)
						PreviousButton.UIGradient.Color = ColorSequence.new {
							ColorSequenceKeypoint.new(0, Color3.fromRGB(80,140,212)), -- change the color of the previous button to grey
							ColorSequenceKeypoint.new(1, Color3.fromRGB(96, 170, 255))
						}
					end

					GPS.Buttons.PreviousHouse.Value = tonumber(House)

					Button.UIGradient.Color = ColorSequence.new { -- change the color of the button to green
						ColorSequenceKeypoint.new(0, Color3.fromRGB(17,162,31)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(26,255,49))
					}
				end
			end
		end
	end
end

-- GET ALL THE GPS HOUSE BUTTONS CLICK

for i,v in ipairs(GPS.Buttons:GetChildren()) do
	if v:IsA("TextButton") then
		v.MouseButton1Down:Connect(function()
			SetGPS(string.sub(v.Name, 6, 7))
		end)
	end
end


-- IF PLAYER SPAWNS A TRUCK

SupplyCenter.SpawnTruck.SurfaceGui.Spawn.MouseButton1Click:Connect(function()
		DeliveryTruckRemoteEvent:FireServer("Spawn") -- spawn truck
		SupplyCenter.DeliveryBags:ClearAllChildren() -- delete all bags
end)


-- DESTROY DELIVERY BAGS

SupplyCenter.DeliveryBagDestroy.Touched:Connect(function(hit)
	if hit.Name == "DeliveryBag" and hit:IsA("UnionOperation") then -- destroy bag when it falls in the bags tray
		hit:Destroy()
	end
end)


-- GET ALL THE ADD OR REMOVE ITEM FOR DELIVERY CLICKS

for i,v in ipairs(DeliveryGui.Frame:GetChildren()) do
	if v:IsA("Frame") then
		v.Plus.MouseButton1Down:Connect(function()
			
			DeliveryTruckRemoteEvent:FireServer("DeliverItem", tonumber(string.sub(v.Name, 5, 6)), "Add")
		end)
		
		v.Minus.MouseButton1Down:Connect(function()
			DeliveryTruckRemoteEvent:FireServer("DeliverItem", tonumber(string.sub(v.Name, 5, 6)), "Remove")
		end)
	end
end
	
	
-- GET ALL THE HOUSES BUTTON CLICK EVENT

for i,v in ipairs(script.Parent.Frame.ScrollingFrame.Frame:GetChildren()) do
	if v:IsA("TextButton") then -- if v is a button
		v.MouseButton1Click:Connect(function() -- bind the event
			OnHouseClick(string.sub(v.Name, 6, 7), v.AbsolutePosition.Y)
		end)
	end
end


-- PLAYER CLICKS THE CLOSE BUTTON (DELIVERY GUI)

DeliveryGui.Hide.MouseButton1Down:Connect(function()
	DeliveryTruckRemoteEvent:FireServer("Close")
	DeliveryGui:TweenSizeAndPosition(UDim2.new(0,0,0,0), UDim2.new(0.5,0,0.5,0), nil, nil, 0.5)
	wait(0.5)
	DeliveryGui.Visible = false
end)


-- PLAYER CLICKS THE DELIVER BUTTON TO START THE DELIVERY

script.Parent.DeliverButton.TextButton.MouseButton1Down:Connect(function()
	DeliveryTruckRemoteEvent:FireServer("StartDelivery")
end)


-- PLAYER CLICKS THE DELIVER BUTTON TO COMPLETE THE DELIVERY (DELIVERY GUI)

DeliveryGui.Deliver.MouseButton1Down:Connect(function()
	DeliveryTruckRemoteEvent:FireServer("Delivering")
end)