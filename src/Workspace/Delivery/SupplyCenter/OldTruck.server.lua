-- move all the local truck script in here (adapt it to server (use the spawnedtrucks list ?) (watch video)
-- check if truck leaves the supply center, if hit.Parent or hit.Parent.Parent or hit.Parent.Parent.Parent... + add a if truck leave, otherwise when the player touches, there might be an error

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeliveryTruckRemoteEvent = ReplicatedStorage:WaitForChild("DeliveryTruck")

local SupplyCenter = workspace.Delivery.SupplyCenter
local TruckIsInSupplyCenter = false
local debounce = false

local PlayerList = {}
local SpawnedTrucks = {}


-- CREATHE THE TABLE FOR EACH PLAYER

Players.PlayerAdded:Connect(function(plr)
	PlayerList[plr.Name] = {} -- index : [1] = House, [2] = Delivering, [3] = CanDeliver
	table.insert(PlayerList[plr.Name], 1, 0)
	table.insert(PlayerList[plr.Name], 2, false)
	table.insert(PlayerList[plr.Name], 2, false)
end)

Players.PlayerRemoving:Connect(function(plr)
	PlayerList[plr.Name] = nil
end)


-- WHEN A PLAYER SEATS IN A TRUCK

DeliveryTruckRemoteEvent.OnServerEvent:Connect(function(plr, Type)
	if Type == "Spawn" then
		if not TruckIsInSupplyCenter then
			local Truck = ServerStorage.DeliveryTruck:Clone()
			Truck.Name = plr.Name.."sTruck"
			table.insert(SpawnedTrucks, 1, Truck.Name)
			Truck.Parent = game.Workspace.Delivery
			Truck:SetPrimaryPartCFrame(game.Workspace.Delivery.SupplyCenter.TruckPlacement.CFrame)
			Truck.Owner.Value = plr.Name
			Players:FindFirstChild(plr.Name).PlayerGui.Delivery.Truck.Disabled = false
			SupplyCenter.SpawnTruck.BrickColor = BrickColor.new("Really red")
			SupplyCenter.SpawnTruck.SurfaceGui.Spawn.Visible = false
			TruckIsInSupplyCenter = true
			
			for i,v in next, SpawnedTrucks do
				local Truck = workspace.Delivery:FindFirstChild(v)
				if Truck then
					
					-- WHEN A PLAYER GETS IN THE TRUCK
					
					Truck.Chassis.VehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
						local GPS = plr.PlayerGui.Delivery.GPS
						if Truck.Chassis.VehicleSeat.Occupant then
							if Truck.Chassis.VehicleSeat.Occupant.Parent.Name == Truck.Owner.Value then -- if the seat occupant (driver) is the owner of the vehicle
								GPS.Visible = true
								GPS:TweenSizeAndPosition(UDim2.new(1,0,1,0), UDim2.new(0.5,0,0,0, nil, nil, 0.5))
							else
								wait(0.1)
								local HumanoidRootPart = Truck.Chassis.VehicleSeat.Occupant.Parent.HumanoidRootPart
								Truck.Chassis.VehicleSeat.Occupant.Parent.Humanoid.Sit = false
								GPS:TweenSizeAndPosition(UDim2.new(0,0,0,0), UDim2.new(0.5,0,0.85,0), nil, nil, 0.5)
								wait(0.5)
								GPS.Visible = false
								HumanoidRootPart.Position = HumanoidRootPart.Position + Vector3.new(0,8,0)
							end
						else
							GPS:TweenSizeAndPosition(UDim2.new(0,0,0,0), UDim2.new(0.5,0,0.85,0), nil, nil, 0.5)
							wait(0.5)
							GPS.Visible = false
						end
					end)
					
					-- WHEN A PLAYER TRIGGERS THE DELIVERY TRIGGER (AT THE BACK OF THE TRUCK) TO DELIVER A HOUSE

					Truck.Body.DeliveryTrigger.Touched:Connect(function(hit)
						if hit.Parent.Name == Truck.Owner.Value then
							if not debounce then
								debounce = true
								for i,v in ipairs(game.Workspace.Delivery.HousesTrigger:GetChildren()) do
									v.Position = v.Position - Vector3.new(0,0.1,0)
								end
								wait()
								for i,v in ipairs(game.Workspace.Delivery.HousesTrigger:GetChildren()) do
									v.Position = v.Position + Vector3.new(0,0.1,0)
								end
								
									
								if PlayerList[plr.Name][1] ~= 0 then
									
									local DeliveryGui = plr.PlayerGui.Delivery.Delivery
									DeliveryGui.Visible = true
									DeliveryGui:TweenSize(UDim2.new(1,0,1,0), nil, nil, 0.5)
									--if ToggleHouseGui.GuiOn.Value == true then
									--	for i,v in ipairs(script.Parent.Houses:GetChildren()) do
									--		v.Order:TweenPosition(UDim2.new(0.76,0,0.5,0), nil, nil, 0.1)
									--		v.Order:TweenSize(UDim2.new(0,0,0,0), nil, nil, 0.1)
									--	end
									--	script.Parent.Frame:TweenPosition(UDim2.new(1.01,0,0.5,0), nil, nil, 0.5)
									--end -- close the frame gui (gui overlaping otherwise)
									wait(0.5)
									PlayerList[plr.Name][2] = true
									repeat wait(1) until PlayerList[plr.Name][2] == false
									DeliveryGui:TweenSizeAndPosition(UDim2.new(0,0,0,0), UDim2.new(0.5,0,0.5,0), nil, nil, 0.5)
									wait(0.5)
									DeliveryGui.Visible = false
									PlayerList[plr.Name][1] = 0
								--else
									-- removed because sometimes the house.value would be 0 while the truck was acutally in the house parking spot

									--DeliveryGui.Parent.NotHouse.Visible = true
									--DeliveryGui.Parent.NotHouse:TweenPosition(UDim2.new(0.5,0,0.92,0), nil, nil, 1)
									--wait(5)
									--DeliveryGui.Parent.NotHouse:TweenPosition(UDim2.new(0.5,0,1,0), nil, nil, 1)
									--wait(3)
									--DeliveryGui.Parent.NotHouse.Visible = false
								end	
							end
							debounce = false
						end
					end)
				end
			end
			
			local Timer = 20
			SupplyCenter.SpawnTruck.SurfaceGui.Timer.Visible = true

			repeat
				wait(1)
				Timer = Timer - 1
				SupplyCenter.SpawnTruck.SurfaceGui.Timer.Text = Timer
			until TruckIsInSupplyCenter == false or Timer == 0 -- wait for player who spawned the truck to leave the supply center or wait for the timer to reach 0

			if Timer == 0 then
				if plr.Character.Humanoid.SeatPart ~= nil and plr.Character.Humanoid.SeatPart:IsA("VehicleSeat") then plr.Character.Humanoid.Sit = false end -- kick player out of the seat
				wait(0.1)
				game.Workspace.Delivery:FindFirstChild(plr.Name.."sTruck"):Destroy()
				Players:FindFirstChild(plr.Name).PlayerGui.Delivery.Truck.Disabled = true
			end
			
			SupplyCenter.SpawnTruck.SurfaceGui.Spawn.Visible = true
			SupplyCenter.SpawnTruck.SurfaceGui.Timer.Visible = false
			SupplyCenter.SpawnTruck.SurfaceGui.Timer.Text = "20"
			SupplyCenter.SpawnTruck.Color = Color3.fromRGB(0, 200, 0)
		end


	elseif Type == "Delete" then
		game.Workspace.Delivery:FindFirstChild(plr.Name.."sTruck"):Destroy()
		Players:FindFirstChild(plr.Name).PlayerGui.Delivery.Truck.Disabled = true
		local TablePosition = table.find(SpawnedTrucks, plr.Name.."sTruck")
		table.remove(SpawnedTrucks, TablePosition)
		
	-- PLAYER IS CLICKS ON THE DELIVER BUTTON FROM THE DELIVERY GUI	
	elseif Type == "Delivering" then
		
		
		
	elseif Type == "Close" then
		
	end
end)


-- WHEN TRUCK LEAVES THE SUPPLY CENTER

SupplyCenter.TruckOutTrigger.Touched:Connect(function(hit)
	if TruckIsInSupplyCenter then
		if hit.Parent.Name == "Body" then
			TruckIsInSupplyCenter = false
		end
	end
	--if hit.Parent.Parent.Name == hit.Parent.Parent:FindFirstChild("Owner").Value.."sTruck" and hit.Parent:IsA("Model") then
	--	TruckIsInSupplyCenter = false
	--end
end)


-- HOUSES TRIGGER WHEN THE DELIVERY TRUCK TOUCHES THE TRIGGER (PLAYER IS AT HOUSE)

for i,v in ipairs(workspace.Delivery.HousesTrigger:GetChildren()) do
	v.Touched:Connect(function(hit)
		if hit.Parent:FindFirstChild("Owner") then
			PlayerList[hit.Parent:FindFirstChild("Owner")][1] = v.HouseValue.Value
		end
	end)
end

