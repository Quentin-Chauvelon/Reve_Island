local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableEvent = ServerStorage:WaitForChild("Money")
local ExperienceBindableEvent = ServerStorage:WaitForChild("Experience")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeliveryTruckRemoteEvent = ReplicatedStorage:WaitForChild("DeliveryTruck")

local SupplyCenter = workspace.Delivery.SupplyCenter
local MealButtons = SupplyCenter.MealButtons
local NumberOfMeals = 0
local HouseMealSum = 0
local TruckIsInSupplyCenter = false
local debounce = false
local DeliveryTriggerDebounce = false

local PlayerList = {}


-- CREATHE THE TABLE FOR EACH PLAYER

Players.PlayerRemoving:Connect(function(plr)
	if PlayerList[plr.Name] then
		PlayerList[plr.Name] = nil
	end
end)


-- FUNCTION TO RESET EVERYTHING WHEN THE PLAYER HAS DELIVERED ALL HOUSES OR LEAVES THE JOB

local function Reset(plr)
	PlayerList[plr.Name] = nil -- remove the player table, so that he can start again

	workspace:FindFirstChild(plr.Name).Humanoid.Sit = false -- unsit player
	wait(0.1)
	workspace:FindFirstChild(plr.Name).HumanoidRootPart.CFrame = SupplyCenter.PlayerPlacementOut.CFrame -- tp player to the supply center

	if workspace.Delivery.Trucks:FindFirstChild(plr.Name.."sTruck") then
		workspace.Delivery.Trucks:FindFirstChild(plr.Name.."sTruck"):Destroy() -- destroy the player truck
	end

	--if SupplyCenter.ItemsNeededMoney:FindFirstChild(plr.Name) then -- destroy the items needed money value if found
	--	SupplyCenter.ItemsNeededMoney:FindFirstChild(plr.Name):Destroy()
	--end

	plr.PlayerGui.Delivery:Destroy()					
	local DeliveryGuiClone = game.ServerStorage.DeliveryGuiClone:Clone()
	DeliveryGuiClone.Parent = plr.PlayerGui
	DeliveryGuiClone.Name = "Delivery"

	DeliveryTruckRemoteEvent:FireClient(plr, "Reset")
end


-- WHEN PLAYER ENTERS THE SUPPLY CENTER

workspace.Delivery.DeliveryTrigger.Touched:Connect(function(hit)

	if hit.Name == "HumanoidRootPart" then
		local plr = Players:GetPlayerFromCharacter(hit.Parent)

		if plr and not PlayerList[plr.Name] then
			PlayerList[plr.Name] = {} -- index : [1] = HousesMenu, [2] = ItemsNeeded, [3] = TruckLoad, [4], = ItemsDelivering, [5] = TotalMeals, [6] = House, [7] = Delivering, [8] = CanDeliver

			PlayerList[plr.Name]["HousesMenu"] = { -- tables to store the menu for each house
				House1 = {},
				House2 = {},
				House3 = {},
				House4 = {},
				House5 = {},
				House6 = {},
				House7 = {},
				House8 = {},
				House9 = {},
				House10 = {},
				House11 = {},
				House12 = {},
				House13 = {},
				House14 = {},
				House15 = {},
				House16 = {},
				House17 = {},
				House18 = {},
				House19 = {},
				House20 = {}
			}

			PlayerList[plr.Name]["MealsSum"] = { -- table to store the sum of items needed for each house
				House1 = 0,
				House2 = 0,
				House3 = 0,
				House4 = 0,
				House5 = 0,
				House6 = 0,
				House7 = 0,
				House8 = 0,
				House9 = 0,
				House10 = 0,
				House11 = 0,
				House12 = 0,
				House13 = 0,
				House14 = 0,
				House15 = 0,
				House16 = 0,
				House17 = 0,
				House18 = 0,
				House19 = 0,
				House20 = 0
			}

			PlayerList[plr.Name]["ItemsNeeded"] = { -- table to know the items needed when player clicks on the meal buttons
				[1] = 0,
				[2] = 0,
				[3] = 0,
				[4] = 0,
				[5] = 0,
				[6] = 0,
				[7] = 0,
				[8] = 0,
				[9] = 0,
				[10] = 0,
				[11] = 0,
				[12] = 0
			}

			PlayerList[plr.Name]["TruckLoad"] = {}
			PlayerList[plr.Name]["ItemsDelivering"] = {}
			table.insert(PlayerList[plr.Name], 5, 0) -- number of meals in total, used to know when player has loaded all the needed meals in the truck
			table.insert(PlayerList[plr.Name], 6, 0)
			table.insert(PlayerList[plr.Name], 7, false)
			table.insert(PlayerList[plr.Name], 8, false)

			if not debounce then
				debounce = true

				DeliveryTruckRemoteEvent:FireClient(plr, "Start") -- fire the client to show the blue parking spots

				plr.PlayerGui.Delivery.Frame.Visible = true

				for i=1,20 do -- create a random amount of order between 1 and 5 for each house
					local Meals = math.random(1,100)

					if Meals <= 30 then -- 30%
						NumberOfMeals = 1
					elseif Meals > 30 and Meals <= 70 then -- 40%
						NumberOfMeals = 2
					elseif Meals > 70 and Meals <= 90 then -- 20%
						NumberOfMeals = 3
					elseif Meals > 90 and Meals <= 99 then -- 9%
						NumberOfMeals = 4
					else -- 1%
						NumberOfMeals = 5
					end

					PlayerList[plr.Name][5] = PlayerList[plr.Name][5] + NumberOfMeals -- get the total number of meals for the player

					for y=1,NumberOfMeals do -- for each order, select a random meal

						local RandomMeal = math.random(1,12)
						table.insert(PlayerList[plr.Name]["HousesMenu"]["House"..i], RandomMeal) -- insert the meal into the corresponding house in the table
						PlayerList[plr.Name]["ItemsNeeded"][RandomMeal] = PlayerList[plr.Name]["ItemsNeeded"][RandomMeal] + 1

						if RandomMeal <=6 then -- if meal is on the first scrolling TV then change the number of meal needed
							local ItemNeeded = SupplyCenter.ScrollingMenu1.SurfaceGui.Frame:FindFirstChild("Item"..RandomMeal)
							local NumberNeeded = MealButtons:FindFirstChild(ItemNeeded.TextLabel.Text)
							NumberNeeded.Needed.Value = NumberNeeded.Needed.Value + 1
							ItemNeeded.Needed.Text = "Needed : "..NumberNeeded.Needed.Value
						else
							local ItemNeeded = SupplyCenter.ScrollingMenu2.SurfaceGui.Frame:FindFirstChild("Item"..RandomMeal)
							local NumberNeeded = MealButtons:FindFirstChild(ItemNeeded.TextLabel.Text)
							NumberNeeded.Needed.Value = NumberNeeded.Needed.Value + 1
							ItemNeeded.Needed.Text = "Needed : "..NumberNeeded.Needed.Value
						end

						local ItemClone = plr.PlayerGui.Delivery.Items:FindFirstChild("Item"..RandomMeal):Clone() -- clone the items to show the house menu gui
						ItemClone.Parent = plr.PlayerGui.Delivery.Houses:FindFirstChild("House"..i).Order:FindFirstChild("Item"..y)
					end
				end

				for i,v in next, PlayerList[plr.Name]["HousesMenu"] do -- get the sum of all the items for each house

					HouseMealSum = 0

					for a,b in next, v do -- loop through each meal of each house of the houses menu table

						HouseMealSum = HouseMealSum + b -- add each item number to the house meal sum
						PlayerList[plr.Name]["MealsSum"][i] = HouseMealSum -- set house meal sum to the house in the meals sum table
					end
				end

				local ItemsNeededMoney = Instance.new("IntValue")
				ItemsNeededMoney.Name = plr.Name
				ItemsNeededMoney.Value = 100
				ItemsNeededMoney.Parent = SupplyCenter.ItemsNeededMoney

				wait(0.1)
				debounce = false	
			end
		end
	end
end)


-- IF PLAYER CLICKS A MEAL

local function OnMealClick(plr, MealClicked, MealNumber)

	local PlayerMoney = SupplyCenter.ItemsNeededMoney:FindFirstChild(plr.Name) -- find the int value which contains the money the player should earn
	if PlayerMoney then
		if PlayerList[plr.Name]["ItemsNeeded"][MealNumber] ~= 0 then --- if the item the player clicked is needed
			PlayerList[plr.Name]["ItemsNeeded"][MealNumber] = PlayerList[plr.Name]["ItemsNeeded"][MealNumber] - 1 -- remove 1 needed from the item
			PlayerList[plr.Name][5] = PlayerList[plr.Name][5] - 1 -- remove 1 from the total number of meals

			table.insert(PlayerList[plr.Name]["TruckLoad"], 1, MealNumber)

			DeliveryTruckRemoteEvent:FireClient(plr, "ItemNeeded", MealClicked, MealNumber, PlayerList[plr.Name]["ItemsNeeded"][MealNumber], PlayerMoney.Value)

			if PlayerList[plr.Name][5] == 0 and PlayerMoney.Value ~= 0 then -- if player has prepared all the meals and has money to earn
				MoneyBindableEvent:Invoke(plr, PlayerMoney.Value, "+")
				PlayerMoney:Destroy()
			end

		else
			if PlayerMoney.Value > 0 then -- if player still has money to earn
				PlayerMoney.Value = PlayerMoney.Value - 10 -- remove $10
				DeliveryTruckRemoteEvent:FireClient(plr, "LowerMoney", nil, nil, nil, PlayerMoney.Value)
			end
		end
	end
end


-- GET ALL THE BUTTONS CLICK EVENT

for i,v in ipairs(MealButtons:GetChildren()) do
	v:FindFirstChildWhichIsA("ClickDetector").MouseClick:Connect(function(plr)
		OnMealClick(plr, v.Name, tonumber(v:FindFirstChildWhichIsA("ClickDetector").Name))
	end)
end


-- WHEN PLAYER FIRES THE DELIVERY TRUCK REMOTE EVENT

DeliveryTruckRemoteEvent.OnServerEvent:Connect(function(plr, Type, Item, Add)

	if Type and typeof(Type) == "string" then

		if Type == "Spawn" then

			if PlayerList[plr.Name] and PlayerList[plr.Name][5] == 0 and not workspace.Delivery.Trucks:FindFirstChild(plr.Name.."sTruck") then

				if not TruckIsInSupplyCenter then -- if truck is not in the supply center
					TruckIsInSupplyCenter = true
					local Truck = ServerStorage.DeliveryTruck:Clone()
					Truck.Name = plr.Name.."sTruck"
					Truck.Parent = game.Workspace.Delivery.Trucks
					Truck:SetPrimaryPartCFrame(game.Workspace.Delivery.SupplyCenter.TruckPlacement.CFrame)
					Truck.Owner.Value = plr.Name
					SupplyCenter.SpawnTruck.BrickColor = BrickColor.new("Really red")
					SupplyCenter.SpawnTruck.SurfaceGui.Spawn.Visible = false

					local TweenOpenDoor = TweenService:Create(SupplyCenter.WarehouseDoor.PrimaryPart, TweenInfo.new(2.5), {CFrame = SupplyCenter.WarehouseDoorOpen.CFrame})
					TweenOpenDoor:Play() -- open the garage door

					for i,v in ipairs(workspace.Delivery.Trucks:GetChildren()) do
						-- get all the events when a player seats in a truck
						v.Chassis.VehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
							local GPS = plr.PlayerGui.Delivery.GPS
							--local DeliverButton = plr.PlayerGui.DeliverButton
							
							if v:FindFirstChild("Chassis") then
								if v.Chassis.VehicleSeat.Occupant then
									if v.Chassis.VehicleSeat.Occupant.Parent.Name == Truck.Owner.Value then -- if the seat occupant (driver) is the owner of the vehicle
										
										--DeliverButton.Visible = true
										--DeliverButton:TweenSizeAndPosition(UDim2.new(1,0,1,0), UDim2.new(0.5,0,0,0), nil, nil, 0.5)
										
										plr.PlayerGui.Delivery.DeliverButton.Visible = true
										GPS.Visible = true
										GPS:TweenSizeAndPosition(UDim2.new(1,0,1,0), UDim2.new(0.5,0,0,0), nil, nil, 0.5)
										
									else
										coroutine.wrap(function()
											
											wait(0.1)
											v.Chassis.VehicleSeat.Occupant.Parent.Humanoid.Sit = false
											
											GPS:TweenSizeAndPosition(UDim2.new(1,0,1,0), UDim2.new(0.5,0,0,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5)
											--DeliverButton:TweenSizeAndPosition(UDim2.new(1,0,1,0), UDim2.new(0.5,0,0,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5)
											wait(0.5)
											GPS.Visible = false
											plr.PlayerGui.Delivery.DeliverButton.Visible = false
											--DeliverButton.Visible = false
											
											v.Chassis.VehicleSeat.Occupant.Parent.HumanoidRootPart.Position = v.Chassis.VehicleSeat.Occupant.Parent.HumanoidRootPart.Position + Vector3.new(0,8,0)
										end)()
									end
								else
									GPS:TweenSizeAndPosition(UDim2.new(0,0,0,0), UDim2.new(0.5,0,0.85,0), nil, nil, 0.5)
									wait(0.5)
									GPS.Visible = false
									plr.PlayerGui.Delivery.DeliverButton.Visible = false
								end
							end
						end)

						-- WHEN A PLAYER TRIGGERS THE DELIVERY TRIGGER (AT THE BACK OF THE TRUCK) TO DELIVER A HOUSE

						--v.Body.DeliveryTrigger.Touched:Connect(function(hit)

							--if not debounce then
							--	debounce = true

							--	if hit.Parent.Name ~= "Pal Hair" then
							--		if hit.Parent.Name == v.Owner.Value then

							--			if PlayerList[plr.Name][7] == false then -- if player is not delivering

							--				for i,v in ipairs(game.Workspace.Delivery.HousesTrigger:GetChildren()) do
							--					v.Position = v.Position - Vector3.new(0,1,0)
							--				end
							--				wait(0.1)
							--				for i,v in ipairs(game.Workspace.Delivery.HousesTrigger:GetChildren()) do
							--					v.Position = v.Position + Vector3.new(0,1,0)
							--				end

							--				if PlayerList[plr.Name][6] ~= 0 and PlayerList[plr.Name]["HousesMenu"]["House"..PlayerList[plr.Name][6]] and #PlayerList[plr.Name]["HousesMenu"]["House"..PlayerList[plr.Name][6]] ~= 0 then

							--					local DeliveryGui = plr.PlayerGui.Delivery.Delivery
							--					DeliveryGui.TextLabel.Text = "What do you want to deliver to house "..PlayerList[plr.Name][6].." ?"
							--					DeliveryGui.Visible = true
							--					DeliveryGui:TweenSize(UDim2.new(1,0,1,0), nil, nil, 0.5)
							--					--if ToggleHouseGui.GuiOn.Value == true then
							--					--	for i,v in ipairs(script.Parent.Houses:GetChildren()) do
							--					--		v.Order:TweenPosition(UDim2.new(0.76,0,0.5,0), nil, nil, 0.1)
							--					--		v.Order:TweenSize(UDim2.new(0,0,0,0), nil, nil, 0.1)
							--					--	end
							--					--	script.Parent.Frame:TweenPosition(UDim2.new(1.01,0,0.5,0), nil, nil, 0.5)
							--					--end -- close the frame gui (gui overlaping otherwise)
							--					wait(0.5)
							--					PlayerList[plr.Name][7] = true
							--					--repeat wait(1) until PlayerList[plr.Name][7] == false
							--					--DeliveryGui:TweenSizeAndPosition(UDim2.new(0,0,0,0), UDim2.new(0.5,0,0.5,0), nil, nil, 0.5)
							--					--wait(0.5)
							--					--DeliveryGui.Visible = false
							--					--PlayerList[plr.Name][6] = 0
							--					--else
							--					-- removed because sometimes the house.value would be 0 while the truck was acutally in the house parking spot

							--					--DeliveryGui.Parent.NotHouse.Visible = true
							--					--DeliveryGui.Parent.NotHouse:TweenPosition(UDim2.new(0.5,0,0.92,0), nil, nil, 1)
							--					--wait(5)
							--					--DeliveryGui.Parent.NotHouse:TweenPosition(UDim2.new(0.5,0,1,0), nil, nil, 1)
							--					--wait(3)
							--					--DeliveryGui.Parent.NotHouse.Visible = false
							--				end	
							--			end
							--		end
							--	end

							--	wait(0.1)
							--	debounce = false
							--end
						--end)
					end
				end

				local Timer = 20
				SupplyCenter.SpawnTruck.SurfaceGui.Timer.Visible = true

				coroutine.wrap(function()
					repeat
						wait(1)
						Timer = Timer - 1
						SupplyCenter.SpawnTruck.SurfaceGui.Timer.Text = Timer
					until TruckIsInSupplyCenter == false or Timer == 0 -- wait for player who spawned the truck to leave the supply center or wait for the timer to reach 0

					if Timer == 0 then
						if plr.Character.Humanoid.SeatPart ~= nil and plr.Character.Humanoid.SeatPart:IsA("VehicleSeat") then plr.Character.Humanoid.Sit = false end -- kick player out of the seat
						wait(0.1)

						if workspace.Delivery.Trucks:FindFirstChild(plr.Name.."sTruck") then
							workspace.Delivery.Trucks:FindFirstChild(plr.Name.."sTruck"):Destroy()
						end

						TruckIsInSupplyCenter = false
						--Players:FindFirstChild(plr.Name).PlayerGui.Delivery.DeliveryScript.Disabled = true
					end

					local TweenCloseDoor = TweenService:Create(SupplyCenter.WarehouseDoor.PrimaryPart, TweenInfo.new(2.5), {CFrame = SupplyCenter.WarehouseDoorClose.CFrame})
					TweenCloseDoor:Play()

					SupplyCenter.SpawnTruck.SurfaceGui.Spawn.Visible = true
					SupplyCenter.SpawnTruck.SurfaceGui.Timer.Visible = false
					SupplyCenter.SpawnTruck.SurfaceGui.Timer.Text = "20"
					SupplyCenter.SpawnTruck.Color = Color3.fromRGB(0, 200, 0)
				end)()
			end


		elseif Type == "Delete" then
			game.Workspace.Delivery.Trucks:FindFirstChild(plr.Name.."sTruck"):Destroy()
			--Players:FindFirstChild(plr.Name).PlayerGui.Delivery.Truck.Disabled = true


			-- PLAYER CLICKS THE PLUS OR MINUS BUTTON TO ADD THE ITEM TO THE DELIVERY

		elseif Type == "DeliverItem" then

			if Item and Add and typeof(Item) == "number" and typeof(Add) == "string" and Item >= 1 and Item <= 12 then

				if PlayerList[plr.Name][6] ~= 0 then -- if player is at a house

					if Add == "Add" then -- if player clicked the plus button to add an item

						local IsInTruckLoad = table.find(PlayerList[plr.Name]["TruckLoad"], Item)

						if IsInTruckLoad then -- search in the truck load table to see if the item is in the truck load

							local IsInHouseMenu = table.find(PlayerList[plr.Name]["HousesMenu"]["House"..PlayerList[plr.Name][6]], Item)

							if IsInHouseMenu then -- search in the house menu table to see if the item the player is clicking was ordered by a house

								local NumberOfMeals = plr.PlayerGui.Delivery.Delivery.Frame:FindFirstChild("Item"..tostring(Item)).NumberOfMeal
								if NumberOfMeals then -- if the text label to display the number of meals the player is delivering has been found

									NumberOfMeals.Text = tostring(tonumber(NumberOfMeals.Text) + 1) -- add 1 to the number of meals item text
									table.remove(PlayerList[plr.Name]["TruckLoad"], IsInTruckLoad) -- remove the item from the truck load
									table.remove(PlayerList[plr.Name]["HousesMenu"]["House"..PlayerList[plr.Name][6]], IsInHouseMenu) -- remove the item from the house menu
									table.insert(PlayerList[plr.Name]["ItemsDelivering"], 1, Item) -- add the item to the delivering table
								end

							else
								coroutine.wrap(function()
									plr.PlayerGui.Delivery.NotOrder.Visible = true
									plr.PlayerGui.Delivery.NotOrder:TweenPosition(UDim2.new(0.5,0,0.02,0), nil, nil, 1)
									wait(5)
									plr.PlayerGui.Delivery.NotOrder:TweenPosition(UDim2.new(0.5,0,-0.2,0), nil, nil, 1)
									wait(3)
									plr.PlayerGui.Delivery.NotOrder.Visible = false								
								end)()
							end	
						else
							coroutine.wrap(function()
								plr.PlayerGui.Delivery.NotLoad.Visible = true
								plr.PlayerGui.Delivery.NotLoad:TweenPosition(UDim2.new(0.5,0,0.02,0), nil, nil, 1)
								wait(5)
								plr.PlayerGui.Delivery.NotLoad:TweenPosition(UDim2.new(0.5,0,-0.2,0), nil, nil, 1)
								wait(3)
								plr.PlayerGui.Delivery.NotLoad.Visible = false								
							end)()
						end		


					elseif Add == "Remove" then -- if player clicked the minus button to remove an item

						local IsInDeliveringTable = table.find(PlayerList[plr.Name]["ItemsDelivering"], Item) -- if player added the item and wants to remove it

						if IsInDeliveringTable then

							local NumberOfMeals = plr.PlayerGui.Delivery.Delivery.Frame:FindFirstChild("Item"..tostring(Item)).NumberOfMeal
							if NumberOfMeals then

								NumberOfMeals.Text = tostring(tonumber(NumberOfMeals.Text) - 1) -- remove 1 to the number of meals item text
								table.remove(PlayerList[plr.Name]["ItemsDelivering"], IsInDeliveringTable)
								table.insert(PlayerList[plr.Name]["TruckLoad"], 1, Item)
								table.insert(PlayerList[plr.Name]["HousesMenu"]["House"..PlayerList[plr.Name][6]], 1, Item)							
							end
						end
					end
				end
			end
			
			
		elseif Type == "StartDelivery" then
			
			if not debounce then
				debounce = true

				if PlayerList[plr.Name][7] == false then -- if player is not delivering

					for i,v in ipairs(game.Workspace.Delivery.HousesTrigger:GetChildren()) do
						v.Position = v.Position - Vector3.new(0,1,0)
					end
					wait(0.1)
					for i,v in ipairs(game.Workspace.Delivery.HousesTrigger:GetChildren()) do
						v.Position = v.Position + Vector3.new(0,1,0)
					end

					if PlayerList[plr.Name][6] ~= 0 and PlayerList[plr.Name]["HousesMenu"]["House"..PlayerList[plr.Name][6]] and #PlayerList[plr.Name]["HousesMenu"]["House"..PlayerList[plr.Name][6]] ~= 0 then
						DeliveryTruckRemoteEvent:FireClient(plr, "OpenDeliveryGui", PlayerList[plr.Name][6])						

						wait(0.5)
						PlayerList[plr.Name][7] = true
					end	
				end

				wait(0.1)
				debounce = false
			end
			

			-- PLAYER CLICKS ON THE DELIVER BUTTON FROM THE DELIVERY GUI	


		elseif Type == "Delivering" then

			local MealSum = 0

			for i,v in ipairs(PlayerList[plr.Name]["ItemsDelivering"]) do -- sum of all the iterms in the items delivering table
				MealSum = MealSum + v
			end

			if MealSum == PlayerList[plr.Name]["MealsSum"]["House"..PlayerList[plr.Name][6]] then -- if the sum of the items is equal to the sum of all the items in the meals sum table

				PlayerList[plr.Name]["ItemsDelivering"] = {} -- reset the items delivering table
				MoneyBindableEvent:Invoke(plr, 250, "+")
				ExperienceBindableEvent:Fire(plr, "DeliveryDriver", 3)

				for i,v in ipairs(plr.PlayerGui.Delivery.Delivery.Frame:GetChildren()) do -- change all text labels text to "0"
					if v:IsA("Frame") then
						v.NumberOfMeal.Text = "0"
					end
				end
				
				DeliveryTruckRemoteEvent:FireClient(plr, "HideDeliveryGui")

				local GPSButton = plr.PlayerGui.Delivery.GPS.Buttons:FindFirstChild("House"..PlayerList[plr.Name][6]) -- find the gps button corresponding to the house the player is at

				if GPSButton then -- if the gps button was found
					GPSButton.UIGradient.Color = ColorSequence.new { -- change the color sequence to grey
						ColorSequenceKeypoint.new(0, Color3.fromRGB(178,184,202)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(224,232,255))
					}
				end

				GPSButton.Delivered.Value = true -- change the delivered bool value to true, so the player can't set the gps to this house anymore (because it has already been delivered)

				PlayerList[plr.Name][7] = false -- player is not delivering anymore
				PlayerList[plr.Name][6] = 0

				local Sum = 0

				if PlayerList[plr.Name]["TruckLoad"] == 0 then -- check if the truck load is equal to 0 (this would mean that the player has delivered every house)

					for i,v in ipairs(PlayerList[plr.Name]["HousesMenu"]) do -- to be sure that the player delivered all the houses, check if all menus are empty
						if #v ~= 0 then
							Sum = Sum + #v
							--return

						end

					end
					MoneyBindableEvent:Invoke(plr, 2000, "+")
					ExperienceBindableEvent:Fire(plr, "DeliveryDriver", 24)

					Reset(plr) -- call the reset function					
				end
			else
				coroutine.wrap(function() -- delivery is not complete
					plr.PlayerGui.Delivery.NotComplete.Visible = true
					plr.PlayerGui.Delivery.NotComplete:TweenPosition(UDim2.new(0.5,0,0.02,0), nil, nil, 1)
					wait(5)
					plr.PlayerGui.Delivery.NotComplete:TweenPosition(UDim2.new(0.5,0,-0.2,0), nil, nil, 1)
					wait(3)
					plr.PlayerGui.Delivery.NotComplete.Visible = false
				end)()
			end

		elseif Type == "Close" then

			if #PlayerList[plr.Name]["ItemsDelivering"] > 0 then -- if the table is not empty

				for i,v in ipairs(PlayerList[plr.Name]["ItemsDelivering"]) do -- loop through every item in the items delivering table

					table.insert(PlayerList[plr.Name]["TruckLoad"], 1, v) -- add the item back to the truck load table
					table.insert(PlayerList[plr.Name]["HousesMenu"]["House"..PlayerList[plr.Name][6]], 1, v) -- add the item back to the houses menu table

					if i == #PlayerList[plr.Name]["ItemsDelivering"] then -- if we looped through every single item in the table (i = the index (the last one is the only one that matters here) and #PlayerList[plr.Name]["ItemsDelivering"] is the total number of meals in the table
						PlayerList[plr.Name]["ItemsDelivering"] = {} -- reset the items delivering table
					end
				end
			end

			for i,v in ipairs(plr.PlayerGui.Delivery.Delivery.Frame:GetChildren()) do -- change all text labels text to "0"
				if v:IsA("Frame") then
					v.NumberOfMeal.Text = "0"
				end
			end

			PlayerList[plr.Name][7] = false -- player is not delivering anymore
		end
	end
end)


-- WHEN TRUCK LEAVES THE SUPPLY CENTER

SupplyCenter.TruckOutTrigger.Touched:Connect(function(hit)
	if TruckIsInSupplyCenter then
		if hit.Name == "HouseTrigger" and hit.Parent.Name == "Body" then
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

		if not DeliveryTriggerDebounce then
			DeliveryTriggerDebounce = true

			if hit.Parent.Name == "Body" and hit.Parent.Parent.Parent.Name == "Trucks" then
				local Player = hit.Parent.Parent:FindFirstChild("Owner").Value -- get the name of the player

				if Player and PlayerList[Player] then -- if the player has been found and the player is in the table
					PlayerList[Player][6] = v.HouseValue.Value -- set the house the player is at in the table
				end
			end

			wait(0.1)
			DeliveryTriggerDebounce = false
		end
	end)
end


-- WHEN THE PLAYER LEAVES THE JOB

SupplyCenter.LeaveJob.Touched:Connect(function(hit)
	if not debounce then
		debounce = true

		if Players:FindFirstChild(hit.Parent.Name) then -- if hit is a player
			Reset(Players:FindFirstChild(hit.Parent.Name)) -- call the reset function		
		end

		wait(0.1)
		debounce = false
	end
end)