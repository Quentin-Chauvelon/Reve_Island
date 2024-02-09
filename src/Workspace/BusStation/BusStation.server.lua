local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local BusStopBindableEvent = ServerStorage:WaitForChild("BusStop")
local MoneyBindableEvent = ServerStorage:WaitForChild("Money")
local ExperienceBindableEvent = ServerStorage:WaitForChild("Experience")
local WarnBindableEvent = ServerStorage:WaitForChild("Warn")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BusStationRemoteEvent = ReplicatedStorage:WaitForChild("BusStation")

local debounce = false

local PlayerList = {} -- [1] = IsAtBusStop, [2] = AreDoorsOpen, [3] = CanCloseDoors, [4] = Line
local BusRoutes = {
	[1] = {1,2,3,4,5,6,7},
	[2] = {8,9,10,11,12,13,14},
	[3] = {15,16,17,18,19,20,21}
}

local Stops = {"Casino", "Mines", "Pet shop", "Car dealership", "Farm", "Villa", "Mountain", "Bank", "Hospital", "Creche", "Garage", "Police station", "Forest", "Port", "Fire station", "School", "Lake", "Volcano", "Race track", "Delivery", "Factory"}

-- REMOTE PLAYER FROM THE TABLE WHEN LEAVING

Players.PlayerRemoving:Connect(function(plr)
	if PlayerList[plr.Name] then
		PlayerList[plr.Name] = nil
	end
end)


-- BUS STATION REMOTE EVENT

BusStationRemoteEvent.OnServerEvent:Connect(function(plr, Type, Line, Spot, Color)

	if Type and typeof(Type) == "string" then
		
		if Type == "Customisations" then

			if Line and Spot and Color then

				if typeof(Line) == "number" and typeof(Spot) == "number" and typeof(Color) == "Color3" then

					if Line >= 1 and Line <= 3 then -- line can only be 1, 2 or 3
						if Spot >= 1 and Spot <= 5 then -- spot can only be 1, 2, 3, 4 or 5
							if Spot < 3 then -- only one part to change the color of

								if Spot == 1 then -- change the name to search in the workspace
									Spot = "Bottom"
								else Spot = "Middle" end

								workspace.BusStation.Buses:FindFirstChild("Bus"..Line).Body:FindFirstChild(Spot).Color = Color -- change the color	
							else
								if Spot == 3 then
									Spot = "Top"
								elseif Spot == 4 then -- change the name to search in the workspace
									Spot = "Seats"
								else
									Spot = "Interior"
								end

								--local ColorTable = string.split(Color, ",") -- get the rgb values based on the color string

								for i,v in ipairs(workspace.BusStation.Buses:FindFirstChild("Bus"..Line).Body:FindFirstChild(Spot):GetChildren()) do -- for every part of the given spot, change the color
									--v.Color = Color3.new(ColorTable[1], ColorTable[2], ColorTable[3])
									v.Color = Color
								end

							end

						else WarnBindableEvent:Fire(plr, "Important", "fired the bus station remote event with Spot = "..Spot..", although it can only be 1, 2, 3, 4 or 5", "BusStation", os.time()) end
					else WarnBindableEvent:Fire(plr, "Important", "fired the bus station remote event with Line = "..Line..", although it can only be 1, 2 or 3", "BusStation", os.time()) end
				else WarnBindableEvent:Fire(plr, "Normal", "fired the bus station remote event with unexpected types of value (Type : "..Type..", Line : "..Line..", Spot : "..Spot..", Color : "..Color, "BusStation", os.time()) end
			else WarnBindableEvent:Fire(plr, "Normal", "fired the bus station remote event with nil values", "BusStation", os.time()) end
			
			
		-- PLAYER RESETS THE COLOR OF THE BUS

		elseif Type == "Reset" then
			
			if Line and typeof(Line) == "number" and Line >= 1 and Line <=3 then
			
				local ResetBus = workspace.BusStation.Buses:FindFirstChild("Bus"..Line) -- find the bus 
				local ResetColor = nil

				if Line == 1 then -- find the color needed
					ResetColor = Color3.new(1,0,0)
				elseif Line == 2 then
					ResetColor = Color3.fromRGB(52,142,64)
				else
					ResetColor = Color3.fromRGB(13,105,172)
				end

				if ResetBus and ResetColor then -- reset the color of the bus
					ResetBus.Body.Bottom.Color = ResetColor
					ResetBus.Body.Middle.Color = Color3.new(1,1,1)

					for i,v in ipairs(ResetBus.Body.Top:GetChildren()) do
						v.Color = ResetColor
					end

					for i,v in ipairs(ResetBus.Body.Seats:GetChildren()) do
						v.Color = Color3.fromRGB(239,184,56)
					end

					for i,v in ipairs(ResetBus.Body.Interior:GetChildren()) do
						v.Color = Color3.fromRGB(99,95,98)
					end
				end
			end
			

		-- PLAYER OPENS THE BUS DOORS	

		elseif Type == "OpenDoors" then
			if PlayerList[plr.Name][1] ~= 0 and PlayerList[plr.Name][2] == false then -- if player is at bus stop and the doors are not open
				local BusStop = workspace.BusStation.BusStops:FindFirstChild("Stop"..tostring(PlayerList[plr.Name][1])) -- find the bus stop
				
				if BusStop then -- if bus stop found, then raycast to see if the bus is actually at the bus stop
					local Raycast1Result = workspace:Raycast(BusStop.Caster1.Position, (BusStop.Caster1Direction.Position - BusStop.Caster1.Position).Unit*45)
					local Raycast2Result = workspace:Raycast(BusStop.Caster2.Position, (BusStop.Caster2Direction.Position - BusStop.Caster2.Position).Unit*45)

					if Raycast1Result or Raycast2Result then -- if one of them touches something
						
						coroutine.wrap(function() -- couroutine because of the wait
							for i,v in ipairs(workspace.Cars:GetChildren()) do -- get the bus the player is driving
								if v:GetAttribute("VehicleType") == "Bus" and v.Driver.Value == plr.Name then -- if the driver value is the same as the player name
									
									--v.Body.FrontLeftDoorOpen.Orientation = Vector3.new(0,-180,0) -- set the orientation, otherwise it always moves out of place
									--v.Body.FrontRightDoorOpen.Orientation = Vector3.new(0,-180,0)
									--v.Body.MiddleLeftDoorOpen.Orientation = Vector3.new(0,-180,0)
									--v.Body.MiddleRightDoorOpen.Orientation = Vector3.new(0,-180,0)
									--v.Body.BackLeftDoorOpen.Orientation = Vector3.new(0,-180,0)
									--v.Body.BackRightDoorOpen.Orientation = Vector3.new(0,-180,0)
									
									v.Body.Center.Anchored = true -- anchor bus so that the player can't move
									v.Body.Doors.FrontLeftDoor.Root.Anchored = true -- anchor doors to tween them
									v.Body.Doors.FrontRightDoor.Root.Anchored = true
									v.Body.Doors.MiddleLeftDoor.Root.Anchored = true
									v.Body.Doors.MiddleRightDoor.Root.Anchored = true
									v.Body.Doors.BackLeftDoor.Root.Anchored = true
									v.Body.Doors.BackRightDoor.Root.Anchored = true
									
									local Tween1 = TweenService:Create(v.Body.Doors.FrontLeftDoor.Root, TweenInfo.new(1), {CFrame = v.Body.FrontLeftDoorOpen.CFrame})
									local Tween2 = TweenService:Create(v.Body.Doors.FrontRightDoor.Root, TweenInfo.new(1), {CFrame = v.Body.FrontRightDoorOpen.CFrame})
									local Tween3 = TweenService:Create(v.Body.Doors.MiddleLeftDoor.Root, TweenInfo.new(1), {CFrame = v.Body.MiddleLeftDoorOpen.CFrame})
									local Tween4 = TweenService:Create(v.Body.Doors.MiddleRightDoor.Root, TweenInfo.new(1), {CFrame = v.Body.MiddleRightDoorOpen.CFrame})
									local Tween5 = TweenService:Create(v.Body.Doors.BackLeftDoor.Root, TweenInfo.new(1), {CFrame = v.Body.BackLeftDoorOpen.CFrame})
									local Tween6 = TweenService:Create(v.Body.Doors.BackRightDoor.Root, TweenInfo.new(1), {CFrame = v.Body.BackRightDoorOpen.CFrame})

									Tween1:Play() -- plays the tweens
									Tween2:Play()
									Tween3:Play()
									Tween4:Play()
									Tween5:Play()
									Tween6:Play()
								end
							end

							PlayerList[plr.Name][2] = true -- doors are open
							wait(math.random(3,12)) -- wait between 3 and 12 seconds (to simulate passengers getting into the bus)
							PlayerList[plr.Name][3] = true -- player can close doors
							plr.PlayerGui.BusStation.Frame.Stop.TextTransparency = 1
						end)()

					else -- if player touched the bus stops but moved and is not here anymore
						PlayerList[plr.name][1] = 0 -- player is not at bus stop
					end
				end
			end
			
			
		-- PLAYER CLOSES THE BUS DOORS
			
		elseif Type == "CloseDoors" then
			if PlayerList[plr.Name][3] == true then -- if player can close doors
				for i,v in ipairs(workspace.Cars:GetChildren()) do -- get the bus the player is driving
					if v:GetAttribute("VehicleType") == "Bus" and v.Driver.Value == plr.Name then -- if the driver value is the same as the player name

						local Tween1 = TweenService:Create(v.Body.Doors.FrontLeftDoor.Root, TweenInfo.new(1), {CFrame = v.Body.FrontLeftDoorClose.CFrame})
						local Tween2 = TweenService:Create(v.Body.Doors.FrontRightDoor.Root, TweenInfo.new(1), {CFrame = v.Body.FrontRightDoorClose.CFrame})
						local Tween3 = TweenService:Create(v.Body.Doors.MiddleLeftDoor.Root, TweenInfo.new(1), {CFrame = v.Body.MiddleLeftDoorClose.CFrame})
						local Tween4 = TweenService:Create(v.Body.Doors.MiddleRightDoor.Root, TweenInfo.new(1), {CFrame = v.Body.MiddleRightDoorClose.CFrame})
						local Tween5 = TweenService:Create(v.Body.Doors.BackLeftDoor.Root, TweenInfo.new(1), {CFrame = v.Body.BackLeftDoorClose.CFrame})
						local Tween6 = TweenService:Create(v.Body.Doors.BackRightDoor.Root, TweenInfo.new(1), {CFrame = v.Body.BackRightDoorClose.CFrame})

						Tween1:Play() -- play the tweens
						Tween2:Play()
						Tween3:Play()
						Tween4:Play()
						Tween5:Play()
						Tween6:Play()
						wait(1) -- wait for the doors to finish their tween before unanchoring them
						
						v.Body.Center.Anchored = false -- anchor bus so that the player can't move
						v.Body.Doors.FrontLeftDoor.Root.Anchored = false -- anchor doors to tween them
						v.Body.Doors.FrontRightDoor.Root.Anchored = false
						v.Body.Doors.MiddleLeftDoor.Root.Anchored = false
						v.Body.Doors.MiddleRightDoor.Root.Anchored = false
						v.Body.Doors.BackLeftDoor.Root.Anchored = false
						v.Body.Doors.BackRightDoor.Root.Anchored = false
						
						if plr.Settings.BusStopBeam.Value == true then
							if PlayerList[plr.Name]["Routes"][2] then -- set the beam for the next stop
								v.Body.Windshield.Beam.Attachment1 = workspace.BusStation.BusStops:FindFirstChild("Stop"..PlayerList[plr.Name]["Routes"][2]).Attachment
							end
						end
					end
				end
				
				MoneyBindableEvent:Invoke(plr, 350, "+") -- give $100 to player
				ExperienceBindableEvent:Fire(plr, "BusDriver", 24) -- give player famring experience
				
				table.remove(PlayerList[plr.Name]["Routes"], 1) -- remove the bus stop from the list so player can go to the next one
				
				-- Show the next stop
				if #PlayerList[plr.Name]["Routes"] > 0 then
					if Stops[PlayerList[plr.Name]["Routes"][1]] then
						plr.PlayerGui.BusStation.Frame.NextStop.Text = Stops[PlayerList[plr.Name]["Routes"][1]]
					end
					
				else
					plr.PlayerGui.BusStation.Frame.NextStop.Text = "Bus station"
				end
				
				PlayerList[plr.Name][1] = 0 -- player is not at station
				PlayerList[plr.Name][2] = false -- doors are closed
				PlayerList[plr.Name][3] = false -- player can't close doors
			end
			
		elseif Type == "DeleteBus" then -- if player clicks the bin button to delete the bus
			
			local DeleteRaycastResult1 = workspace:Raycast(workspace.BusStation.DeleteCaster1.Position, (workspace.BusStation.DeleteCasterDirection1.Position - workspace.BusStation.DeleteCaster1.Position).Unit*40)
			local DeleteRaycastResult2 = workspace:Raycast(workspace.BusStation.DeleteCaster2.Position, (workspace.BusStation.DeleteCasterDirection2.Position - workspace.BusStation.DeleteCaster2.Position).Unit*40) 
			
			if DeleteRaycastResult1 and DeleteRaycastResult2 then -- if both raycast hit something
				if DeleteRaycastResult1.Instance.Name == "Block" and DeleteRaycastResult2.Instance.Name == "Block" then -- if they hit the block part of the bus
					DeleteRaycastResult1.Instance.Parent.Parent:Destroy() -- destroy the bus
					MoneyBindableEvent:Invoke(plr, 10, "+") -- give $50 to player
				end
			end
		end
	end
end)


workspace.BusStation.Bus1Checker.Touched:Connect(function(hit) -- when raycast touches the bus, check with the bus checker if you can spawn one
	workspace.BusStation.Bus1Checker.SpawnBus.Value = false
end)

workspace.BusStation.Bus2Checker.Touched:Connect(function(hit)
	workspace.BusStation.Bus2Checker.SpawnBus.Value = false
end)

workspace.BusStation.Bus3Checker.Touched:Connect(function(hit)
	workspace.BusStation.Bus3Checker.SpawnBus.Value = false
end)


-- SET ROUTES (ORDER IN WHICH THE PLAYER HAS TO GO TO THE BUS STOPS)

BusStopBindableEvent.Event:Connect(function(plr, Line)

	if PlayerList[plr.Name] then -- if player already entered a bus
		
		-- Reset the table
		PlayerList[plr.Name][1] = 0		
		PlayerList[plr.Name][2] = false
		PlayerList[plr.Name][3] = false	
		PlayerList[plr.Name][4] = Line -- change the line value in the table
		PlayerList[plr.Name]["Routes"] = BusRoutes[Line] -- change the route table

		-- Show the next stop
		if #PlayerList[plr.Name]["Routes"] > 0 and Stops[PlayerList[plr.Name]["Routes"][1]] then
			plr.PlayerGui.BusStation.Frame.NextStop.Text = Stops[PlayerList[plr.Name]["Routes"][1]]
		end


	else -- if player didn't enter a bus yet

		-- Remove the players that disconnected from the table
		for i,v in pairs(PlayerList) do
			if not Players:FindFirstChild(i) then
				PlayerList[i] = nil
			end
		end
		
		PlayerList[plr.Name] = {} -- create a table for the player with the line and a table for the route (order player has to take the bus stops)
		table.insert(PlayerList[plr.Name], 1, 0)
		table.insert(PlayerList[plr.Name], 2, false)
		table.insert(PlayerList[plr.Name], 3, false)
		table.insert(PlayerList[plr.Name], 4, Line)
		PlayerList[plr.Name]["Routes"] = BusRoutes[Line]
		
		-- Show the next stop
		if #PlayerList[plr.Name]["Routes"] > 0 and Stops[PlayerList[plr.Name]["Routes"][1]] then
			plr.PlayerGui.BusStation.Frame.NextStop.Text = Stops[PlayerList[plr.Name]["Routes"][1]]
		end
	end
	
	if plr.Settings.BusStopBeam.Value == true then
		if PlayerList[plr.Name]["Routes"][1] then -- if player has at least one more bus stop to go, set the beam
			for i,v in ipairs(workspace.Cars:GetChildren()) do
				if v:GetAttribute("VehicleType") == "Bus" and v.Driver.Value == plr.Name then
					v.Body.Windshield.Beam.Attachment1 = workspace.BusStation.BusStops:FindFirstChild("Stop"..PlayerList[plr.Name]["Routes"][1]).Attachment
				end
			end
			
		-- Remove the beam if the player completed his route
		else
			for i,v in ipairs(workspace.Cars:GetChildren()) do
				if v:GetAttribute("VehicleType") == "Bus" and v.Driver.Value == plr.Name then
					v.Body.Windshield.Beam.Attachment1 = nil
				end
			end
		end
	end
end)


-- BUS STOPS TOUCHED

for i,v in ipairs(workspace.BusStation.BusStops:GetChildren()) do -- get the touched events for all the bus stops
	v.Touched:Connect(function(hit)
		if not debounce then
			debounce = true
			if hit.Parent.Name == "Interior" and hit.Parent.Parent.Name == "Body" then -- if hit is the bus
				if hit.Parent.Parent.Parent.Driver.Value then -- if there is a driver

					local Player = hit.Parent.Parent.Parent.Driver.Value -- get the player who is driving
					if Player and PlayerList[Player] then

						if v.BusStop.Value == PlayerList[Player]["Routes"][1] then -- if the BusStop the player went is the first one he has to get to
							if PlayerList[Player][1] == 0 then -- if player isn't already at the bus stop
								PlayerList[Player][1] = v.BusStop.Value -- player is at bus stop
								Players[Player].PlayerGui.BusStation.Frame.Stop.TextTransparency = 0 --show the STOP sign								
							end
						end
					end
				end
			end
			wait(0.2)
			debounce = false
		end
	end)
end


-- RAYCAST FUNCTION TO CHECK IF THE BUS HAS BEEN TAKEN

coroutine.wrap(function()
	while true do
		for i=1,3 do
			local RaycastResult = workspace:Raycast(workspace.BusStation:FindFirstChild("Bus"..tostring(i).."Caster").Position, (workspace.BusStation:FindFirstChild("Bus"..i.."Caster").Position - workspace.BusStation:FindFirstChild("Bus"..i.."CasterDirection").Position).Unit*-50) -- raycast to see if there is a bus

			if not RaycastResult then -- if raycast doesn't touch anything

				workspace.BusStation:FindFirstChild("Bus"..tostring(i).."Checker").Position = Vector3.new(workspace.BusStation:FindFirstChild("Bus"..i.."Checker").Position.X, 21.5, workspace.BusStation:FindFirstChild("Bus"..i.."Checker").Position.Z) -- move the part to the top of the bus, so that if there is something, it doesn't spawn one
				wait(0.5) -- wait so that the part can fire the touch event before next code
				workspace.BusStation:FindFirstChild("Bus"..tostring(i).."Checker").Position = Vector3.new(workspace.BusStation:FindFirstChild("Bus"..i.."Checker").Position.X, -60.25, workspace.BusStation:FindFirstChild("Bus"..i.."Checker").Position.Z) -- move the part under the map, so that it doesn't check for the bus anymore

				if workspace.BusStation:FindFirstChild("Bus"..tostring(i).."Checker").SpawnBus.Value == true then -- if no bus has been touched

					wait(0.1) -- wait for the part to be moved before setting back the value, so that it doesn't fire another event

					--if workspace.BusStation.Buses:FindFirstChild("Bus"..tostring(i)) then
						--local plr = workspace.BusStation.Buses["Bus"..tostring(i)].Driver.Value
						
						--workspace.BusStation.Buses["Bus"..tostring(i)].Name = plr -- change the name of the previous to spawn a new one, otehrwise two bus would have the same name
						
						-- If the player already has a car, destroy it
						--if workspace.Cars:FindFirstChild(plr) then
						--	workspace.Cars[plr]:Destroy()
						--end
						
						-- Parent the bus to the cars folder
						--workspace.BusStation.Buses[plr].Parent = workspace.Cars
					--end

					local SpawnBus = ServerStorage.Bus:Clone() -- clone the bus from the server storage
					SpawnBus.Name = "Bus"..tostring(i) -- change the name of the bus, so that players can customize it later
					SpawnBus:SetPrimaryPartCFrame(workspace.BusStation:FindFirstChild("Bus"..tostring(i).."Placement").CFrame) -- move it to the right spot
					SpawnBus.Line.Value = i

					local Color = Color3.new(1,1,1) -- change the color of the bus, based on the line	
					if i == 1 then
						Color = Color3.new(1,0,0)
					elseif i == 2 then
						Color = Color3.fromRGB(52,142,64)
					else
						Color = Color3.fromRGB(13,105,172)
					end

					SpawnBus.Body.Bottom.Color = Color -- change the bottom part color
					for i,v in ipairs(SpawnBus.Body.Top:GetChildren()) do -- change the top parts color
						v.Color = Color
					end			
					
					if i == 1 then
						SpawnBus.Body.FrontDestinationBoard.SurfaceGui.TextLabel.Text = "DESTINATION : MOUNTAIN"
					elseif i == 2 then
						SpawnBus.Body.FrontDestinationBoard.SurfaceGui.TextLabel.Text = "DESTINATION : PORT"
					else
						SpawnBus.Body.FrontDestinationBoard.SurfaceGui.TextLabel.Text = "DESTINATION : FACTORY"
					end
					
					SpawnBus.Parent = workspace.BusStation.Buses -- change the bus parent to the bus station

				else
					workspace.BusStation:FindFirstChild("Bus"..i.."Checker").SpawnBus.Value = true
				end
			end
			wait(5)
		end
	end
end)()


-- CODE TO CREATE ALL THE NO COLLIDE CONSTRAINT FOR THE BLOCK PART OF THE BUS (used to make sure that if a player gets out of a car, he doesn't end up inside the bus, where he would be trapped)

--for i,v in ipairs(workspace.BusStation.Bus.Body:GetChildren()) do
--	if v:IsA("Part") or v:IsA("UnionOperation") and v~= "Block" then
--		local NoCollide = Instance.new("NoCollisionConstraint", workspace.BusStation.Bus.Body.Block)
--		NoCollide.Part0 = workspace.BusStation.Bus.Body.Block
--		NoCollide.Part1 = v
--	end
--end

--for i,v in ipairs(workspace.BusStation.Bus.Body.Interior:GetChildren()) do
--	local NoCollide = Instance.new("NoCollisionConstraint", workspace.BusStation.Bus.Body.Block)
--	NoCollide.Part0 = workspace.BusStation.Bus.Body.Block
--	NoCollide.Part1 = v
--end

--for i,v in ipairs(workspace.BusStation.Bus.Body.Doors:GetChildren()) do
--	if v:IsA("Part") then
--		local NoCollide = Instance.new("NoCollisionConstraint", workspace.BusStation.Bus.Body.Block)
--		NoCollide.Part0 = workspace.BusStation.Bus.Body.Block
--		NoCollide.Part1 = v
--	end
--end

--for i,v in ipairs(workspace.BusStation.Bus.Chassis:GetChildren()) do
--	if v:IsA("Part") or v:IsA("VehicleSeat") then
--		local NoCollide = Instance.new("NoCollisionConstraint", workspace.BusStation.Bus.Body.Block)
--		NoCollide.Part0 = workspace.BusStation.Bus.Body.Block
--		NoCollide.Part1 = v
--		if v.Name == "TorsionBar" then
--			for a,b in ipairs(v:GetChildren()) do
--				if b:IsA("Part") then
--					local NoCollide = Instance.new("NoCollisionConstraint", workspace.BusStation.Bus.Body.Block)
--					NoCollide.Part0 = workspace.BusStation.Bus.Body.Block
--					NoCollide.Part1 = b
--				end
--			end
--		end
--	end
--end

--for i,v in ipairs(workspace.BusStation.Bus.Chassis:GetChildren()) do
--	if v:IsA("Model") then
--		for a,b in ipairs(v:GetChildren()) do
--			local NoCollide = Instance.new("NoCollisionConstraint", workspace.BusStation.Bus.Body.Block)
--			NoCollide.Part0 = workspace.BusStation.Bus.Body.Block
--			NoCollide.Part1 = b
--			if b.Name == "SteeringKnuckleArm" then
--				local NoCollide = Instance.new("NoCollisionConstraint", workspace.BusStation.Bus.Body.Block)
--				NoCollide.Part0 = workspace.BusStation.Bus.Body.Block
--				NoCollide.Part1 = b.Arm
--			end
--		end
--	end
--end