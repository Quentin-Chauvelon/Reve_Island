local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local ExperienceBindableEvent = ServerStorage:WaitForChild("Experience")
local FarmingBindableEvent = ServerStorage:WaitForChild("Farming")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FarmingRemoteEvent = ReplicatedStorage:WaitForChild("Farming")

local PricesTable = {
	Wheat = 5,
	Potato = 7,
	Tomato = 10,
	Carrot = 14,

	CopperWateringCan = 150000,
	SteelWateringCan = 500000,

	IronSickle = 150000,
	SteelSickle = 500000
}

local SellTable = {
	Wheat = 8,
	Potato = 13,
	Tomato = 22,
	Carrot = 36,
}

local GrowthTimes = {
	Wheat = {60,75},
	Potato = {90,125},
	Tomato = {150,200},
	Carrot = {240,300},	
}

local FarmingTable = {}
local GrownTable = {}


-- GET THE FARMING TABLE FOR A PLAYER THAT JOINED THE GAME

FarmingBindableEvent.Event:Connect(function(plr, Type, Table)
	if Type == "FarmingTable" and not FarmingTable[plr.Name] and next(Table) then
		
		FarmingTable[plr.Name] = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}
		
		FarmingRemoteEvent:FireClient(plr, "LoadCrops", Table) -- fire the client to clone the models
		
		for i,v in pairs(Table) do
			for a,b in pairs(v) do
				FarmingTable[plr.Name][i][tonumber(a)] = b
				
				if GrowthTimes[b["Crop"]] and b["Watered"] == true then
					FarmingTable[plr.Name][i][tonumber(a)]["Time"] = os.time() + math.random(GrowthTimes[b["Crop"]][1], GrowthTimes[b["Crop"]][2])
				else
					FarmingTable[plr.Name][i][tonumber(a)]["Time"] = 0
				end
				FarmingTable[plr.Name][i][tonumber(a)]["Watered"] = nil
			end
		end
	end
end)


-- PLAYER GETS IN THE CIRCLE

local function ShowFarmingBuyGui(FarmingGui)
	if FarmingGui.Visible == false then -- if the gui is not shown yet
		FarmingGui.Visible = true
		FarmingGui.WateringCans.Visible = false
		FarmingGui.Sickles.Visible = false
		FarmingGui.Crops.Visible = true
		FarmingGui.Crops.SellFrame.Visible = false
		FarmingGui.Crops.BuyFrame.Visible = true
		FarmingGui:TweenPosition(UDim2.new(0.5,0,0.55,0))
	end	
end

workspace.Farm.Barn.Circle.InTrigger.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) then -- get the player that touched the trigger
		local FarmingGui = Players:FindFirstChild(hit.Parent.Name).PlayerGui.Farming
		
		-- Update all the player's seeds and crops values
		for i,v in ipairs(Players:FindFirstChild(hit.Parent.Name).Farming.Seeds:GetChildren()) do
			if FarmingGui.Buy.Crops.BuyFrame:FindFirstChild(v.Name) then
				FarmingGui.Buy.Crops.BuyFrame:FindFirstChild(v.Name).Total.Text = "Total : "..tostring(v.Value)
			end
		end
		
		for i,v in ipairs(Players:FindFirstChild(hit.Parent.Name).Farming.Crops:GetChildren()) do
			if FarmingGui.Buy.Crops.SellFrame:FindFirstChild(v.Name) then
				FarmingGui.Buy.Crops.SellFrame:FindFirstChild(v.Name).Total.Text = "Total : "..tostring(v.Value)
			end
		end
		
		if FarmingGui.Select.Visible == true then
			coroutine.wrap(function()
				FarmingGui.Select.Dropdown:TweenSize(UDim2.new(1,0,0,0), nil, nil, 0.3)
				wait(0.3)
				FarmingGui.Select:TweenPosition(UDim2.new(-0.2,0,0.26,0), nil, nil, 0.5)
				wait(0.5)
				FarmingGui.Select.Visible = false

				ShowFarmingBuyGui(FarmingGui.Buy)			
			end)()
		else
			ShowFarmingBuyGui(FarmingGui.Buy)
		end
	end
end)


-- PLAYER GETS OUT OF THE CIRCLE

local function ShowFarmingSelectGui(FarmingGui)
	coroutine.wrap(function()
		FarmingGui.Visible = true
		FarmingGui:TweenPosition(UDim2.new(0.01,0,0.26,0), nil, nil, 0.5)
		wait(0.5)
		FarmingGui.Dropdown:TweenSize(UDim2.new(1,0,0.85,0), nil, nil, 0.3)
	end)()
end

for i,v in ipairs(workspace.Farm.Barn.Circle.OutTriggers:GetChildren()) do
	v.Touched:Connect(function(hit)
		if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) then -- get the player that touched the trigger
			local FarmingGui = Players:FindFirstChild(hit.Parent.Name).PlayerGui.Farming
			if FarmingGui.Buy.Visible == true then
				coroutine.wrap(function()
					FarmingGui.Buy:TweenPosition(UDim2.new(0.5,0,1.5,0)) -- tween the position down
					wait(1)
					FarmingGui.Buy.Visible = false -- hide the tools selection gui

					ShowFarmingSelectGui(FarmingGui.Select) -- show the farming select gui
				end)()
			end
		end
	end)
end


-- PLAYER GETS OUT OF THE FARM

for i,v in ipairs(workspace.Farm.FarmBorders:GetChildren()) do
	v.Touched:Connect(function(hit) -- player touched one of the farm borders
		if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) then -- get the player that touched the trigger

			local plr = Players:FindFirstChild(hit.Parent.Name)

			--for i,v in pairs(PricesTable) do -- loop through the prices table (could have used another table), used this one because it has all the tools name
			--	if plr.Backpack:FindFirstChild(i) then
			--		plr.Backpack:FindFirstChild(i):Destroy()
			--	end
			--end
			
			for i,v in ipairs(plr.Backpack:GetChildren()) do
				v:Destroy()
			end
			
			if hit.Parent:FindFirstChildOfClass("Tool") then
				hit.Parent:FindFirstChildOfClass("Tool"):Destroy()
			end

			plr.PlayerGui.Farming.Select.Visible = false
			plr.PlayerGui.Farming.Select.Position = UDim2.new(-0.2,0,0.26,0)
			plr.PlayerGui.Farming.Select.Dropdown.Size = UDim2.new(1,0,0,0)
			plr.PlayerGui.Farming.WateringCanFill.Visible = false
			plr.PlayerGui.Farming.WateringCanFill.Position = UDim2.new(1.05,0,0.61,0)	
			plr.PlayerGui.Farming.Buy.Visible = false
			plr.PlayerGui.Farming.Buy.Position = UDim2.new(0.5,0,1.5,0)
		end
	end)
end


-- PLAYER GETS IN ONE OF THE FIELDS

workspace.Farm.FieldEntrance.Touched:Connect(function(hit) -- player touched one of the fields entrance triggers
	if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) then -- get the player that touched the trigger
		ShowFarmingSelectGui(Players:FindFirstChild(hit.Parent.Name).PlayerGui.Farming.Select) -- show the farming select gui
	end
end)


-- REFILL THE WATERING CAN

workspace.Farm.Well.Circle.Touched:Connect(function(hit)
	if hit.Name == "LeftFoot" or hit.Name == "RightFoot" and Players:FindFirstChild(hit.Parent.Name) then -- player's foot touches the circle
		local WateringCanFillGui = Players:FindFirstChild(hit.Parent.Name).PlayerGui.Farming.WateringCanFill

		if WateringCanFillGui and WateringCanFillGui.Empty.Value == true then -- if the gui was found and the watering can is empty

			local plr = workspace:FindFirstChild(hit.Parent.Name)

			if plr and plr:FindFirstChild("Humanoid") and plr:FindFirstChildOfClass("Tool") and plr:FindFirstChildOfClass("Tool"):FindFirstChild("FillingAnimation") then -- if the tool  was found and it's a watering can (if it has the filling animation)
				local FillingAnimation = plr:FindFirstChild("Humanoid"):LoadAnimation(plr:FindFirstChildOfClass("Tool"):FindFirstChild("FillingAnimation"))
				FillingAnimation:Play() -- play the animation

				FillingAnimation:GetMarkerReachedSignal("WateringCanFilling"):Connect(function() -- pause the animation to keep the player in place while refilling
					FillingAnimation:AdjustSpeed(0) -- pause the animation

					if plr:FindFirstChild("HumanoidRootPart") then -- if the humanoid root part was found
						plr:FindFirstChild("HumanoidRootPart").Anchored = true -- freeze player

						WateringCanFillGui.BackgroundColor3 = Color3.new(1,1,1) -- change the background color to beige
						WateringCanFillGui.WaterLevel:TweenSize(UDim2.new(1,0,1,0), nil, nil, 10) -- tween the water level up to refill (in 10s)

						coroutine.wrap(function()
							wait(10) -- wait for the tween to end

							WateringCanFillGui.FillValue.Value = 100 -- watering can filled
							WateringCanFillGui.Empty.Value = false -- watering can not empty 
							FillingAnimation:AdjustSpeed(1) -- restart the animation
							plr:FindFirstChild("HumanoidRootPart").Anchored = false -- unfreeze player
						end)()
					end
				end)
			end
		end
	end
end)


-- PLAYER ACTIVATES THE TOOL

local function ToolActivated(plr, FarmTile)

	if workspace:FindFirstChild(plr.Name) and workspace:FindFirstChild(plr.Name):FindFirstChildOfClass("Tool") then

		local Tool = workspace:FindFirstChild(plr.Name):FindFirstChildOfClass("Tool")
		local ToolType = Tool.ToolType.Value

		local Animation = nil
		if plr.Character and plr.Character:FindFirstChild("Humanoid") and Tool:FindFirstChild("Animation") then
			Animation = plr.Character:FindFirstChild("Humanoid"):LoadAnimation(Tool:FindFirstChild("Animation"))
		end

		if ToolType == "Seeds" then
			if FarmingTable[plr.Name] and FarmingTable[plr.Name][FarmTile.Column.Value] and not FarmingTable[plr.Name][FarmTile.Column.Value][FarmTile.Row.Value] and not GrownTable[plr.Name.."L"..FarmTile.Row.Value.."C"..FarmTile.Column.Value] then -- if the table and column were found and the row table doesn't exist then the player has not planted something on the tile yet
				if GrowthTimes[Tool.Name] then -- if the seed is found in the growh times table

					FarmingTable[plr.Name][FarmTile.Column.Value][FarmTile.Row.Value] = {Crop = Tool.Name, Stage = 0, Time = 0} -- create a table for the tile with the seed, growth stage 0 and a time of 0 (time to wait before growing to the next stage, set once the seed is watered)  
					if plr.Farming.Seeds:FindFirstChild(Tool.Name) then
						plr.Farming.Seeds:FindFirstChild(Tool.Name).Value -= 1 -- remove 1 seed from the player folder

						if Animation then
							Animation:Play() -- play the use animation
						end

						if plr.PlayerGui.Farming.Select.Dropdown.Seeds.ScrollingFrame:FindFirstChild(Tool.Name) then
							plr.PlayerGui.Farming.Select.Dropdown.Seeds.ScrollingFrame:FindFirstChild(Tool.Name).AmountOwned.Text = plr.Farming.Seeds:FindFirstChild(Tool.Name).Value -- remove 1 to the amount owned text in the select gui
						end			

						if plr.Farming.Seeds:FindFirstChild(Tool.Name).Value == 0 then -- if the player doesn't have anymore seeds
							Tool:Destroy() -- detroy the seed tool
						end
					end
					
					FarmingBindableEvent:Fire(plr, "Plant", FarmTile.Column.Value, FarmTile.Row.Value, Tool.Name)
					FarmingRemoteEvent:FireClient(plr, "Plant", FarmTile.Name, Tool.Name) -- fire the client to plant the seed (done on client because everyone uses the same field)
				end
			end

		elseif ToolType == "WateringCans" then

			local WaterTileTable = {} -- table to store the tile that shoud get watered (the copper watering can waters a 2x2 zone, and the steel one, a 3x3 zone)

			local Row = FarmTile.Row.Value
			local Column = FarmTile.Column.Value
						
			if FarmingTable[plr.Name] and FarmingTable[plr.Name][Column] and FarmingTable[plr.Name][Column][Row] and FarmingTable[plr.Name][Column][Row]["Time"] == 0 then -- if the tile was found in the table, it means that the player has planted a seed
				table.insert(WaterTileTable, 1, {Row, Column})	
			end				

			if Row and Column then
				if Tool.Name == "CopperWateringCan" then -- if it's the copper watering can
					if (Row - 1) > 0 and FarmingTable[plr.Name][Column][Row - 1] and FarmingTable[plr.Name][Column][Row - 1]["Time"] == 0 then -- get the tile above the first one (min : 1)
						table.insert(WaterTileTable, 1, {Row - 1, Column}) -- add the tile to the table
					end

					if (Column + 1) < 21 and FarmingTable[plr.Name][Column + 1][Row] and FarmingTable[plr.Name][Column + 1][Row]["Time"] == 0 then -- get the tile on the left of the first one (max : 20)
						table.insert(WaterTileTable, 1, {Row, Column + 1}) -- add the tile to the table
					end

					if (Row - 1) > 0 and (Column + 1) < 21 and FarmingTable[plr.Name][Column + 1][Row - 1] and FarmingTable[plr.Name][Column + 1][Row - 1]["Time"] == 0 then -- get the tiel at the top right corner
						table.insert(WaterTileTable, 1, {Row - 1, Column + 1}) -- add the tile to the table
					end

				elseif Tool.Name == "SteelWateringCan" then -- if it's the steel watering can

					if (Row - 1) > 0 and FarmingTable[plr.Name][Column][Row - 1] and FarmingTable[plr.Name][Column][Row - 1]["Time"] == 0 then -- get the tile above the first one (min : 0)
						table.insert(WaterTileTable, 1, {Row -1, Column})
					end

					if (Column + 1) < 21 and FarmingTable[plr.Name][Column + 1][Row] and FarmingTable[plr.Name][Column + 1][Row]["Time"] == 0 then -- get the tile on the right of the first one (max : 20)
						table.insert(WaterTileTable, 1, {Row, Column + 1})
					end

					if (Row - 1) > 0 and (Column + 1) < 21 and FarmingTable[plr.Name][Column + 1][Row - 1] and FarmingTable[plr.Name][Column + 1][Row - 1]["Time"] == 0 then -- get the tile in the top right corner
						table.insert(WaterTileTable, 1, {Row - 1, Column + 1})
					end

					if (Row + 1) < 51 and FarmingTable[plr.Name][Column][Row + 1] and FarmingTable[plr.Name][Column][Row + 1]["Time"] == 0 then -- get the tile under of the first one (max : 50)
						table.insert(WaterTileTable, 1, {Row + 1, Column})
					end

					if (Row + 1) < 51 and (Column + 1) < 21 and FarmingTable[plr.Name][Column + 1][Row + 1] and FarmingTable[plr.Name][Column + 1][Row + 1]["Time"] == 0 then -- get the tile in the bottom right corner
						table.insert(WaterTileTable, 1, {Row + 1, Column + 1})
					end					

					if (Column - 1) > 0 and FarmingTable[plr.Name][Column - 1][Row] and FarmingTable[plr.Name][Column - 1][Row]["Time"] == 0 then -- get the tile on the left of the first one (min : 0)
						table.insert(WaterTileTable, 1, {Row, Column - 1})
					end

					if (Column - 1) > 0 and FarmingTable[plr.Name][Column - 1][Row + 1] and FarmingTable[plr.Name][Column - 1][Row + 1]["Time"] == 0 then -- get the tile in the bottom left corner
						table.insert(WaterTileTable, 1, {Row + 1, Column - 1})
					end

					if (Row - 1) > 0 and FarmingTable[plr.Name][Column - 1][Row - 1] and FarmingTable[plr.Name][Column - 1][Row - 1]["Time"] == 0 then -- get the tile in the top left corner
						table.insert(WaterTileTable, 1, {Row - 1, Column - 1})
					end

					-- FIRST METHOD (DOESN'T WORK ANYMORE BECAUSE IF THE TOP AND RIGHT TILE HAVE NO SEEDS, BUT THE TOP RIGHT CORNER ONE HAS, IT STILL WON'T BE WATERED)
					--if (Row - 1) > 0 and FarmingTable[plr.Name]["L"..tostring(Row - 1).."C"..String[2]] then -- get the tile above the first one (min : 0)
					--	table.insert(WaterTileTable, 1, "L"..tostring(Row - 1).."C"..String[2])
					--	if (Column + 1) < 21 and FarmingTable[plr.Name]["L"..tostring(Row - 1).."C"..tostring(Column + 1)] then -- get the tile on the right of the first one (max : 20)
					--		table.insert(WaterTileTable, 1, "L"..tostring(Row - 1).."C"..tostring(Column + 1)) -- if the 2 previous one are true then add the top right corner
					--	end
					--end

					--if (Column + 1) < 21 and FarmingTable[plr.Name]["L"..String[1].."C"..tostring(Column + 1)] then -- get the tile on the right of the first one (max : 20)
					--	table.insert(WaterTileTable, 1, "L"..String[1].."C"..tostring(Column + 1))
					--	if (Row + 1) < 51 and FarmingTable[plr.Name]["L"..tostring(Row + 1).."C"..tostring(Column + 1)] then -- get the tile under of the first one (max : 50)
					--		table.insert(WaterTileTable, 1, "L"..tostring(Row + 1).."C"..tostring(Column + 1)) -- if the 2 previous one are true then add the bottom right corner
					--	end
					--end

					--if (Row + 1) < 51 and FarmingTable[plr.Name]["L"..tostring(Row + 1).."C"..String[2]] then -- get the tile under of the first one (max : 50)
					--	table.insert(WaterTileTable, 1, "L"..tostring(Row + 1).."C"..String[2])
					--	if (Column - 1) > 0 and FarmingTable[plr.Name]["L"..tostring(Row + 1).."C"..tostring(Column - 1)] then -- get the tile on the left of the first one (min : 0)
					--		table.insert(WaterTileTable, 1, "L"..tostring(Row + 1).."C"..tostring(Column - 1)) -- if the 2 previous one are true then add the bottom left corner
					--	end
					--end

					--if (Column - 1) > 0 and FarmingTable[plr.Name]["L"..String[1].."C"..tostring(Column - 1)] then -- get the tile on the left of the first one (min : 0)
					--	table.insert(WaterTileTable, 1, "L"..String[1].."C"..tostring(Column - 1))
					--	if (Row - 1) > 0 and FarmingTable[plr.Name]["L"..tostring(Row - 1).."C"..tostring(Column - 1)] then -- get the tile above the first one (min : 0)
					--		table.insert(WaterTileTable, 1, "L"..tostring(Row - 1).."C"..tostring(Column - 1)) -- if the 2 previous one are true then add the top left corner
					--	end
					--end


					--[[
					SECOND METHOD BUT SEEMS SLOWER IN BENCHMARK (PROBABLY OUTDATED SINCE THERE WERE CHANGES MADE ON THE FIRST METHOD)
					FOR 100 TESTS : AROUND THE SAME TIME (0.0025 FOR BOTH)
					FOR 1000 TESTS : FIRST METHOD A BIT FASTER
					FOR 10 000 TESTS : FIRST METHOD : 0.2s, SECOND METHOD : 4.5s
					FOR 20 000 TESTS : FIRST METHOD : 0.45s, SECOND METHOD : 19s
					IT SEEMS LIKE THE MORE YOU DO IT, THE SLOWER THE SECOND METHOD IS
					local Top, Bottom, Left, Right = nil
					if (Row - 1) > 0 and FarmingTable[plr.Name][FarmTile] then
						Top = true
						table.insert(WaterTileTable, 1, "L"..tostring(Row - 1).."C"..String[2])
					end
					if (Row + 1) < 51 and FarmingTable[plr.Name][FarmTile] then
						Bottom = true
						table.insert(WaterTileTable, 1, "L"..tostring(Row + 1).."C"..String[2])
					end 
					if (Column - 1) > 0 and FarmingTable[plr.Name][FarmTile] then
						Left = true
						table.insert(WaterTileTable, 1, "L"..String[1].."C"..tostring(Column - 1))
					end
					if (Column + 1) < 21 and FarmingTable[plr.Name][FarmTile] then
						Right = true
						table.insert(WaterTileTable, 1, "L"..String[1].."C"..tostring(Column + 1))
					end

					if Top and Right and FarmingTable[plr.Name][FarmTile] then
						table.insert(WaterTileTable, 1, "L"..tostring(Row - 1).."C"..tostring(Column + 1))
					end
					if Right and Bottom and FarmingTable[plr.Name][FarmTile] then
						table.insert(WaterTileTable, 1, "L"..tostring(Row + 1).."C"..tostring(Column + 1))
					end
					if Bottom and Left and FarmingTable[plr.Name][FarmTile] then
						table.insert(WaterTileTable, 1, "L"..tostring(Row + 1).."C"..tostring(Column - 1))
					end
					if Left and Top and FarmingTable[plr.Name][FarmTile] then
						table.insert(WaterTileTable, 1, "L"..tostring(Row - 1).."C"..tostring(Column - 1))
					end
					--]]
				end
			end

			local WateringCanFillGui = plr.PlayerGui.Farming.WateringCanFill

			if WateringCanFillGui then -- if the watering can fill gui was found and the watering can is not empty

				if Animation then
					Animation:Play() -- play the use animation
				end

				for i,v in pairs(WaterTileTable) do

					if WateringCanFillGui.Empty.Value == false then
						WateringCanFillGui.FillValue.Value -= 1 -- decrease the fill value by 1 for each tile in the water tile table
						WateringCanFillGui.WaterLevel:TweenSize(UDim2.new(1,0, (WateringCanFillGui.FillValue.Value / 100), 0)) -- change the water level size gui to the fill value
					end

					if WateringCanFillGui.FillValue.Value <= 0 then -- if the watering has no more water in it
						WateringCanFillGui.Empty.Value = true -- set the empty value to true (to refill later)
						WateringCanFillGui.WaterLevel.Size = UDim2.new(1,0,0,0)
						WateringCanFillGui.BackgroundColor3 = Color3.new(1,0,0) -- change the background color to red
						break
					end
					
					FarmingTable[plr.Name][v[2]][v[1]]["Time"] = os.time() + math.random(GrowthTimes[FarmingTable[plr.Name][v[2]][v[1]]["Crop"]][1], GrowthTimes[FarmingTable[plr.Name][v[2]][v[1]]["Crop"]][2]) -- give a random growth time to the seed depending of the type of crop
					
					if plr:FindFirstChild("PetCustomisations") and plr:FindFirstChild("PetCustomisations"):FindFirstChild("Equipped") and plr:FindFirstChild("PetCustomisations"):FindFirstChild("Equipped").Value == "Pumpkin" then
						FarmingTable[plr.Name][v[2]][v[1]]["Time"] = math.floor(FarmingTable[plr.Name][v[2]][v[1]]["Time"] * 0.9) 
					end
					
					v[1] = tostring(v[1])
				end
								
				if WateringCanFillGui.Empty.Value == false then
					FarmingBindableEvent:Fire(plr, "Water", WaterTileTable) -- fire the client to save the tile watered
					FarmingRemoteEvent:FireClient(plr, "Water", WaterTileTable) -- fire the client to change the color of the tile (darker brown as if it was wet)
				end
			end

			-- If the player is using a sickle
		elseif ToolType == "Sickles" then

			local HarvestTileTable = {} -- table to store the tile that shoud get watered (the copper watering can waters a 2x2 zone, and the steel one, a 3x3 zone)

			local Row = FarmTile.Row.Value
			local Column = FarmTile.Column.Value
			
			if GrownTable[plr.Name.."L"..Row.."C"..Column] then -- if the tile was found in the table, it means that the player has planted a seed
				table.insert(HarvestTileTable, 1, {Row, Column})					
			end

			if Row and Column then
				if Tool.Name == "IronSickle" then -- if it's the iron sickle
					if (Row - 1) > 0 and GrownTable[plr.Name.."L"..(Row - 1).."C"..Column ] then -- get the tile above the first one (min : 1)
						table.insert(HarvestTileTable, 1, {Row - 1, Column}) -- add the tile to the table
					end

					if (Column + 1) < 21 and GrownTable[plr.Name.."L"..Row.."C"..(Column + 1)] then -- get the tile on the left of the first one (max : 20)
						table.insert(HarvestTileTable, 1, {Row, Column + 1}) -- add the tile to the table
					end

					if (Row - 1) > 0 and (Column + 1) < 21 and GrownTable[plr.Name.."L"..(Row - 1).."C"..(Column + 1)] then -- get the tiel at the top right corner
						table.insert(HarvestTileTable, 1, {Row - 1, Column + 1}) -- add the tile to the table
					end

				elseif Tool.Name == "SteelSickle" then -- if it's the steel sickle

					if (Row - 1) > 0 and GrownTable[plr.Name.."L"..(Row - 1).."C"..Column] then -- get the tile above the first one (min : 0)
						table.insert(HarvestTileTable, 1, {Row -1, Column})
					end

					if (Column + 1) < 21 and GrownTable[plr.Name.."L"..Row.."C"..(Column + 1)] then -- get the tile on the right of the first one (max : 20)
						table.insert(HarvestTileTable, 1, {Row, Column + 1})
					end

					if (Row - 1) > 0 and (Column + 1) < 21 and GrownTable[plr.Name.."L"..(Row - 1).."C"..(Column + 1)] then -- get the tile in the top right corner
						table.insert(HarvestTileTable, 1, {Row - 1, Column + 1})
					end

					if (Row + 1) < 51 and GrownTable[plr.Name.."L"..(Row + 1).."C"..Column] then -- get the tile under of the first one (max : 50)
						table.insert(HarvestTileTable, 1, {Row + 1, Column})
					end

					if (Row + 1) < 51 and (Column + 1) < 21 and GrownTable[plr.Name.."L"..Row.."C"..Column - 1] then -- get the tile in the bottom right corner
						table.insert(HarvestTileTable, 1, {Row + 1, Column + 1})
					end					

					if (Column - 1) > 0 and GrownTable[plr.Name.."L"..Row.."C"..(Column - 1)] then -- get the tile on the left of the first one (min : 0)
						table.insert(HarvestTileTable, 1, {Row, Column - 1})
					end

					if (Column - 1) > 0 and GrownTable[plr.Name.."L"..(Row + 1).."C"..(Column - 1)] then -- get the tile in the bottom left corner
						table.insert(HarvestTileTable, 1, {Row + 1, Column - 1})
					end

					if (Row - 1) > 0 and GrownTable[plr.Name.."L"..(Row - 1).."C"..(Column - 1)] then -- get the tile in the top left corner
						table.insert(HarvestTileTable, 1, {Row - 1, Column - 1})
					end
				end

				if Animation then
					Animation:Play() -- play the use animation
				end


				if PricesTable[GrownTable[plr.Name.."L"..Row.."C"..Column]] then
					MoneyBindableFunction:Invoke(plr, PricesTable[GrownTable[plr.Name.."L"..Row.."C"..Column]], "+") -- player gets the money for the crop he harvested
				end	
				
				for i,v in pairs(HarvestTileTable) do
					if GrownTable[plr.Name.."L"..v[1].."C"..v[2]] and plr.Farming.Crops:FindFirstChild(GrownTable[plr.Name.."L"..v[1].."C"..v[2]]) then
						plr.Farming.Crops:FindFirstChild(GrownTable[plr.Name.."L"..v[1].."C"..v[2]]).Value += 1
						ExperienceBindableEvent:Fire(plr, "Farmer", 1) -- give player famring experience
					end
					
					v[1] = tostring(v[1]) -- change the row value to a string for the datastore (because it can't save numerical values as keys) 
					
					GrownTable[plr.Name.."L"..v[1].."C"..v[2]] = nil -- remove the crop from the grown table
				end
				
				FarmingBindableEvent:Fire(plr, "Harvest", HarvestTileTable)
				FarmingRemoteEvent:FireClient(plr, "Harvest", HarvestTileTable) -- fire the client to remove the crop (destroy it) + make the tile's brown lighter (as if dry)
			end
		end
	end
end


-- PLAYER FIRES THE FARMING REMOTE EVENT

FarmingRemoteEvent.OnServerEvent:Connect(function(plr, Type, Param1, Param2, Param3)
	if Type == "Buy" then

		local ToolType = Param1
		local Tool = Param2
		local Amount = Param3

		if ToolType and typeof(ToolType) == "string" and Tool and typeof(Tool) == "string" then
			if plr.Farming:FindFirstChild(ToolType) and plr.Farming:FindFirstChild(ToolType):FindFirstChild(Tool) then -- if the tool has been found

				if ToolType ~= "Seeds" and plr.Farming:FindFirstChild(ToolType):FindFirstChild(Tool).Value == true then -- if the tool is a watering can or a sickle and the player already owns it, then return
					return	
				end

				local Price = PricesTable[Tool]

				if Price then
					if ToolType == "Seeds" and Amount and typeof(Amount) == "number" then -- if the tool is a seed
						Price *= Amount -- multiply the unit price by the amount of seeds the player wants to buy
					end

					local EnoughMoney = MoneyBindableFunction:Invoke(plr, Price, "-") -- check if player has enough money to buy the tool
					if EnoughMoney == true then
												
						if ToolType == "Seeds" and Amount and typeof(Amount) == "number" then 
							plr.Farming:FindFirstChild(ToolType):FindFirstChild(Tool).Value += Amount -- player has Amount more seeds

							if plr.PlayerGui.Farming.Buy.Crops.BuyFrame:FindFirstChild(Tool) then -- if the tool has been found
								plr.PlayerGui.Farming.Buy.Crops.BuyFrame:FindFirstChild(Tool).Total.Text = "Total : "..tostring(plr.Farming.Seeds:FindFirstChild(Tool).Value) -- change the total number of seeds the player has in the buy gui
							end

							if plr.PlayerGui.Farming.Select.Dropdown.Seeds.ScrollingFrame:FindFirstChild(Tool) then -- if the tool has been found
								plr.PlayerGui.Farming.Select.Dropdown.Seeds.ScrollingFrame:FindFirstChild(Tool).AmountOwned.Text = tostring(plr.Farming:FindFirstChild(ToolType):FindFirstChild(Tool).Value) -- change the number of seeds the player has in the select gui
							end
							
						else
							plr.Farming:FindFirstChild(ToolType):FindFirstChild(Tool).Value = true -- player now owns the tool

							if plr.PlayerGui.Farming.Buy:FindFirstChild(ToolType) and plr.PlayerGui.Farming.Buy:FindFirstChild(ToolType):FindFirstChild(Tool) then -- if the tool gui has been found
								plr.PlayerGui.Farming.Buy:FindFirstChild(ToolType):FindFirstChild(Tool).Buy.Visible = false -- hide the buy button
								plr.PlayerGui.Farming.Buy:FindFirstChild(ToolType):FindFirstChild(Tool).Price.Visible = false -- hide the price
								plr.PlayerGui.Farming.Buy:FindFirstChild(ToolType):FindFirstChild(Tool).Owned.Visible = true -- show the owned image
							end

							if plr.PlayerGui.Farming.Select.Dropdown:FindFirstChild(ToolType):FindFirstChild(Tool) then -- if the tool has been found
								plr.PlayerGui.Farming.Select.Dropdown:FindFirstChild(ToolType):FindFirstChild(Tool).BackgroundColor3 = Color3.fromRGB(255,242,204) -- change the background color to beige
								plr.PlayerGui.Farming.Select.Dropdown:FindFirstChild(ToolType):FindFirstChild(Tool).AutoButtonColor = true -- sets the auto button color to true, so that it becomes grey on hover
							end
						end
						
						FarmingBindableEvent:Fire(plr, "Buy", ToolType, Tool, Amount) -- fire the server to save the crops for the player
					end
				end
			end
		end

	elseif Type == "Sell" then

		local Crop = Param1
		local AmountSold = Param2

		if Crop and typeof(Crop) == "string" and AmountSold and typeof(AmountSold) == "number" then
			if plr.Farming.Crops:FindFirstChild(Crop) and AmountSold <= plr.Farming.Crops:FindFirstChild(Crop).Value then -- if the player is not trying to sell more crops than he has

				if SellTable[Crop] then -- if the crop was found in the sell table
					plr.Farming.Crops:FindFirstChild(Crop).Value -= AmountSold -- change the amount of crops the player has

					if plr.PlayerGui.Farming.Buy.Crops.SellFrame:FindFirstChild(Crop) then
						plr.PlayerGui.Farming.Buy.Crops.SellFrame:FindFirstChild(Crop).Total.Text = "Total : "..plr.Farming.Crops:FindFirstChild(Crop).Value
					end

					MoneyBindableFunction:Invoke(plr, AmountSold * SellTable[Crop], "+")
					FarmingBindableEvent:Fire(plr, "Sell", Crop) -- fire the server to save the crops for the player
				end
			end
		end

	elseif Type == "Equip" then

		local ToolType = Param1
		local Tool = Param2
		if Tool and typeof(Tool) == "string" and ToolType and typeof(ToolType) == "string" then
			if ServerStorage.FarmingTools:FindFirstChild(Tool) then -- if the tool was found in the farming tools folder 
				if ToolType == "Seeds" then
					if plr.Farming:FindFirstChild(ToolType) and plr.Farming:FindFirstChild(ToolType):FindFirstChild(Tool) and plr.Farming:FindFirstChild(ToolType):FindFirstChild(Tool).Value == 0 then -- if the player doesn't have any seeds, return
						return
					end
				else
					if plr.Farming:FindFirstChild(ToolType) and plr.Farming:FindFirstChild(ToolType):FindFirstChild(Tool) and plr.Farming:FindFirstChild(ToolType):FindFirstChild(Tool).Value == false then -- if the player doesn't own the tool, return
						return
					end
				end
				for i,v in ipairs(plr.Backpack:GetChildren()) do -- for all tools in the player backpack
					if v:FindFirstChild("ToolType") and v:FindFirstChild("ToolType").Value == ToolType then -- if the player already has a tool of the same type in his backapck but not equipped
						v:Destroy() -- destroy it

						if plr.PlayerGui.Farming.Select.Dropdown:FindFirstChild(ToolType) and plr.PlayerGui.Farming.Select.Dropdown:FindFirstChild(ToolType):FindFirstChild(v.Name) then -- if the toolgui was found in the select gui
							plr.PlayerGui.Farming.Select.Dropdown:FindFirstChild(ToolType):FindFirstChild(v.Name).BackgroundColor3 = Color3.fromRGB(255, 242, 204) -- change the color back to beige
						end

						if v.Name == Tool then -- if it's the same tool , hide the watering fill can gui
							if plr.PlayerGui.Farming.WateringCanFill.Visible == true then -- if the watering fill can gui is visible
								coroutine.wrap(function()
									plr.PlayerGui.Farming.WateringCanFill:TweenPosition(UDim2.new(1.05,0,0.61,0), nil, nil, 0.5) -- hide it
									wait(0.5)
									plr.PlayerGui.Farming.WateringCanFill.Visible = false
								end)()
							end
							return
						end
					end
				end

				if plr.Character:FindFirstChildOfClass("Tool") and plr.Character:FindFirstChildOfClass("Tool"):FindFirstChild("ToolType") and plr.Character:FindFirstChildOfClass("Tool"):FindFirstChild("ToolType").Value == ToolType then  -- if the player already has a tool of the same type equipped

					if plr.PlayerGui.Farming.Select.Dropdown:FindFirstChild(ToolType) and plr.PlayerGui.Farming.Select.Dropdown:FindFirstChild(ToolType):FindFirstChild(plr.Character:FindFirstChildOfClass("Tool").Name) then -- if the toolgui was found in the select gui
						plr.PlayerGui.Farming.Select.Dropdown:FindFirstChild(ToolType):FindFirstChild(plr.Character:FindFirstChildOfClass("Tool").Name).BackgroundColor3 = Color3.fromRGB(255, 242, 204) -- change the color back to beige
					end

					if plr.Character:FindFirstChildOfClass("Tool").Name == Tool then -- if it's the same tool , hide the watering fill can gui
						plr.Character:FindFirstChildOfClass("Tool"):Destroy()
						if plr.PlayerGui.Farming.WateringCanFill.Visible == true then -- if the watering fill can gui is visible
							coroutine.wrap(function()
								plr.PlayerGui.Farming.WateringCanFill:TweenPosition(UDim2.new(1.05,0,0.61,0), nil, nil, 0.5) -- hide it
								wait(0.5)
								plr.PlayerGui.Farming.WateringCanFill.Visible = false
							end)()
						end
						return
					end

					plr.Character:FindFirstChildOfClass("Tool"):Destroy()
				end

				local ToolClone = ServerStorage.FarmingTools:FindFirstChild(Tool):Clone() -- clone the tool
				ToolClone.Parent = plr.Backpack

				if plr.PlayerGui.Farming.Select.Dropdown:FindFirstChild(ToolType) and plr.PlayerGui.Farming.Select.Dropdown:FindFirstChild(ToolType):FindFirstChild(Tool) then -- if the toolgui was found in the select gui
					plr.PlayerGui.Farming.Select.Dropdown:FindFirstChild(ToolType):FindFirstChild(Tool).BackgroundColor3 = Color3.fromRGB(55, 189, 45) -- change the background color to green
				end

				if ToolClone:FindFirstChild("ToolType") and ToolClone:FindFirstChild("ToolType").Value == "WateringCans" then -- if the tool is a watering can
					if plr.PlayerGui.Farming.WateringCanFill.Visible == false then -- if it is not shown yet
						plr.PlayerGui.Farming.WateringCanFill.Visible = true -- show it
						plr.PlayerGui.Farming.WateringCanFill:TweenPosition(UDim2.new(0.99,0,0.61,0))
					end
				end

				--if plr.Backpack:FindFirstChild(Tool) then -- if the player already has the tool in his backpack but unequipped
				--	plr.Backpack:FindFirstChild(Tool):Destroy() -- destroy it

				--	if plr.PlayerGui.Farming.WateringCanFill.Visible == true then -- if the watering fill can gui is visible
				--		coroutine.wrap(function()
				--			plr.PlayerGui.Farming.WateringCanFill:TweenPosition(UDim2.new(1.05,0,0.61,0), nil, nil, 0.5) -- hide it
				--			wait(0.5)
				--			plr.PlayerGui.Farming.WateringCanFill.Visible = false
				--		end)()
				--	end

				--elseif plr.Character:FindFirstChild(Tool) then -- if the player already has the tool equipped
				--	plr.Character:FindFirstChild(Tool):Destroy() -- destroy it

				--	if plr.PlayerGui.Farming.WateringCanFill.Visible == true then -- if the watering fill can gui is visible
				--		coroutine.wrap(function()
				--			plr.PlayerGui.Farming.WateringCanFill:TweenPosition(UDim2.new(1.05,0,0.61,0), nil, nil, 0.5) -- hide it
				--			wait(0.5)
				--			plr.PlayerGui.Farming.WateringCanFill.Visible = false
				--		end)()
				--	end
			end
		end

	elseif Type == "FarmTileClicked" then -- player clicked on a farm tile with his mouse	

		local Target = Param1

		if Target and Target.Name == "Floor" and Target.Parent.Parent.Name == "FarmTiles" then -- if the player clicked on the farm tiles floor or a crop
			ToolActivated(plr, Target.Parent)
		elseif Target and Target.Name == "HitBox" and Target.Parent.Parent.Parent.Name == "FarmTiles" then -- if the player clicked on a crop
			ToolActivated(plr, Target.Parent.Parent)
		end

	elseif Type == "FarmTileTapped" then -- player tapped a farm tile

		local ray = Param1		
		if ray and typeof(ray) == "Ray" then

			local Result = workspace:Raycast(ray.Origin, ray.Direction * 60, RaycastParams.new())
			
			if Result and Result.Instance.Name == "Floor" and Result.Instance.Parent.Parent.Name == "FarmTiles" then -- if the player tapped the farm tiles floor or a crop
				ToolActivated(plr, Result.Instance.Parent)
			end
		end
	end
end)


-- REMOVE THE PLAYER FROM THE TABLE WHEN HE DISCONNECTS

Players.PlayerRemoving:Connect(function(plr)
	if FarmingTable[plr.Name] then
		FarmingTable[plr.Name] =  nil
	end
end)


-- GROW CROPS

coroutine.wrap(function()
	while true do
		if next(FarmingTable) ~= nil then

			for i,v in pairs(FarmingTable) do -- for each player in the farming table
				for y,c in pairs(v) do -- for each column
					for a,r in pairs(c) do -- for each line of each column
						if r["Time"] ~= 0 and os.time() >= r["Time"] then -- if the crop is ready to grow

							-- When the crop ready to be harvested, remove from the farming table and add it to the grow table
							if r["Stage"] >= 3 then -- if the stage is 3 then the crop is fully grown
								GrownTable[i.."L"..a.."C"..y] = r["Crop"] -- add it with the crop, the player, the row and the column
								c[a] = nil
							else
								r["Stage"] += 1 -- add 1 to the stage (to get to the next one)

								if GrowthTimes[r["Crop"]] then -- if the growh time for the crop were found
									r["Time"] = os.time() + math.random(GrowthTimes[r["Crop"]][1], GrowthTimes[r["Crop"]][2]) -- get a random time to wait before next growth based on the crop planted
								end
							end
							
							if Players:FindFirstChild(i) then
								FarmingBindableEvent:Fire(Players:FindFirstChild(i), "Grow", y, tostring(a), r["Stage"])
								FarmingRemoteEvent:FireClient(Players:FindFirstChild(i), "Grow", "L"..a.."C"..y, r["Crop"], r["Stage"]) -- fire the client to change the crop model
							end
						end
					end
					RunService.Heartbeat:Wait() -- wait one frame (for 20 000 crops (all player having their field full), it would take about 6.67s at 60fps to loop through the whole farming table)
				end
				wait(4 / #Players:GetPlayers())
			end
		else
			wait(1)
		end	
	end
end)()


--local RunService = game:GetService("RunService")
--local Table = {
--	a = {},
--	b = {},
--	c = {},
--	d = {},
--	e = {},
--	f = {},
--	g = {},
--	h = {},
--	i = {},
--	j = {},
--	k = {},
--	l = {},
--	m = {},
--	n = {},
--	o = {},
--	p = {},
--	q = {},
--	r = {},
--	s = {},
--  t = {}
--}
--for i,v in pairs(Table) do
--	for i = 1,20 do
--		v["C"..i] = {}
--		for y = 1,50 do
--			v["C"..i]["C"..i.."L"..y] = {Time = 0, Watered = false, Stage = 0, Crop = "Wheat"}
--		end
--	end
--end

--wait(12)
--wait(3)

--coroutine.wrap(function()
--	while true do
--		for i,v in pairs(Table) do
--			for a,b in pairs(v) do
--				for y,z in pairs(b) do
--					if z["Time"] > tick() then
--						return
--					end
--				end
--				RunService.Hearbeat:Wait()
--			end
--		end
--	end
--end)()


--[[

-- FIRST METHOD :
Table for each player and then loop through the table to get each crop
replace "squarebrackets" by two square brackets (removed otherwise it was closing the comment)

GET DATA :
FarmingBindableEvent.Event:Connect(function(plr, Type, Table)
	if Type == "FarmingTable" and not FarmingTable[plr.Name] and next(Table) then
		FarmingTable[plr.Name] = Table
	end
end)

PLANT :
FarmingTable[plr.Name][FarmTile] = {Crop = Tool.Name, Stage = 0, Watered = false, Time = 0} -- create a table for the tile with the seed, not watered, growth stage 0 and a time of 0 (time to wait before growing to the next stage, set once the seed is watered)  

GROW :
coroutine.wrap(function()
	while true do
		if next(FarmingTable) ~= nil then
			
			for i,v in pairs(FarmingTable) do
				if Players:FindFirstChild(i) and Players:FindFirstChild(i).PlayerGui.Farming.LastGrowthTime.Value == 0 then -- if the player just logged in, he has no last growh time value
					Players:FindFirstChild(i).PlayerGui.Farming.LastGrowthTime.Value = tick() -- change the last growth time value to the current time
				end
				
				local LastGrowthTime = tick() - Players:FindFirstChild(i).PlayerGui.Farming.LastGrowthTime.Value -- get the las time it has grown
				
				for a,b in pairs(v) do
					if b["Watered"] == true then -- if the tile is watered
						b["Time"] -= LastGrowthTime -- reduce the time before growth by the time it has last grown

						if b["Time"] <= 0 then -- if the time <= 0 then the crop will grow

							if b["Stage"] == 3 then -- if the stage is 3 then the crop is fully grown
								b["Watered"] = false -- unwater the tile so that the crop stops growing

							else
								b["Stage"] += 1 -- add 1 to the stage (to get to the next one)
								
								if GrowthTimes[b["Crop"squarebrackets then -- if the growh time for the crop were found
	b["Time"] = math.random(GrowthTimes[b["Crop"squarebrackets[1], GrowthTimes[b["Crop"squarebrackets[2]) -- get a random time to wait before next growth based on the crop planted
end

FarmingRemoteEvent:FireClient(Players:FindFirstChild(i), "Grow", a, b["Crop"], b["Stage"]) -- fire the client to change the crop model
end
end
end
Players:FindFirstChild(i).PlayerGui.Farming.LastGrowthTime.Value = tick() -- change the last growth time value to the current time
end
print(FarmingTable)
wait(0.5)
end
else
	wait(1)
end
end
end)()



-- SECOND METHOD :
in the farming table, have 60 tables named from 5 to 300 with a step of 5 and then the crops inside of each table which represents the number of seconds left before it grows
when planting a seed, loop thorugh all 60 tables to check if there's not somethin already planted on the tile
every 5 seconds or so, loop thourgh, decrease all 60 table indexes by 5 (10 --> 5 + add an empty table with the index 300) and grow all the crops inside the 0 table
MAYBE BE BETTER THAN THE METHOD THAT'S BEING USED (faster for growing the plant (I think ?), slower for planting seeds)



-- BENCHMARK

-- FOR 10 000 :
-- TABLE 1 : 10^-3
-- TABLE 2 : 10^-2
-- TABLE 3 : 10^-1

local Table1, Table2, Table3 = {}, {}, {}
local Counter, Value = 1, 0
for i=1000,1,-1 do
	table.insert(Table1, 1, "Crop"..i)
end
for i=10,1,-1 do
	Table2[i] = {}
	for y=100,1,-1 do
		table.insert(Table2[i], 1, "Crop"..(1000 - ((100 * i) - y)))
	end
end
for i=300,0,-5 do
	Table3[i] = {}
	for y=16,1,-1 do
		table.insert(Table3[i], 1, "Crop"..(1000 - ((16 * Counter) - y)))
	end
	Counter += 1
end
table.insert(Table3[0], 1, "Crop1")

local t =tick()
for i=1,10000 do
	Value = Table1["Crop1"]
end
print("Crop 1, table 1 ", tick() - t)

t = tick()
for i=1,10000 do
	Value = Table1["Crop1000"]
end
print("Crop 1000, table 1 ", tick() - t)

t = tick()
for i=1,10000 do
	for i,v in pairs(Table2) do
		if v["Crop1"] then
			Value = v["Crop1"]
		end
	end
end
print("Crop 1, table 2 ", tick() - t)

t = tick()
for i=1,10000 do
	for i,v in pairs(Table2) do
		if v["Crop1000"] then
			Value = v["Crop1000"]
		end
	end
end
print("Crop 1000, table 2 ", tick() - t)

t = tick()
for i=1,10000 do
	for i,v in pairs(Table3) do
		if v["Crop1"] then
			Value = v["Crop1"]
		end
	end
end
print("Crop 1, table 3 ", tick() - t)

t = tick()
for i=1,10000 do
	for i,v in pairs(Table3) do
		if v["Crop1000"] then
			Value = v["Crop1000"]
		end
	end
end
print("Crop 1000, table 3 ", tick() - t)

-- 0.001s to find 10 000 random values in the table 2
-- 0,88s to find 10 000 random values in the table 3 

local Table2, Table3, RandomTable, Counter= {}, {}, {}, 1

for i=200,1,-1 do
	Table2[i] = {}
	for y=50,1,-1 do
		table.insert(Table2[i], 1, "Crop"..(10000 - ((50 * i) - y)))
	end
end

for i=300,0,-5 do
	Table3[i] = {}
	for y=166,1,-1 do
		table.insert(Table3[i], 1, "Crop"..(10000 - ((166 * Counter) - y)))
	end
	Counter += 1
end
table.insert(Table3[0], 1, "Crop1")

for i = 1,10000 do
	table.insert(RandomTable, 1, math.random(1,10000))
end
local t = tick()
for i,v in pairs(RandomTable) do
	for a,b in pairs(Table3) do
		if b["Crop"..v] then
			continue
		end
	end
end

-- 0,00013 to loop through a "chunk" of 50 values
local RunService = game:GetService("RunService")
local Table2 = {}
for i=200,1,-1 do
	Table2[i] = {}
	for y=50,1,-1 do
		table.insert(Table2[i], 1, "Crop"..(10000 - ((50 * i) - y)))
	end
end

local t = tick()
for i,v in pairs(Table2) do
	for a,b in pairs(v) do
		if b < tostring(tick()) then
			return
		end
	end
	wait(0.1)
end
print(tick() - t)

local RunService = game:GetService("RunService")
local Table2 = {}
for i=200,1,-1 do
	Table2[i] = {}
	for y=50,1,-1 do
		table.insert(Table2[i], 1, "Crop"..(10000 - ((50 * i) - y)))
	end
end
local t = tick()
for i,v in pairs(Table2) do
	for a,b in pairs(v) do
		if b < tostring(tick()) then
			return
		end
	end
	RunService.Heartbeat:Wait()
end
print(tick() - t)
--]]