local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FarmingRemoteEvent = ReplicatedStorage:WaitForChild("Farming")

local lplr = game.Players.LocalPlayer

local FarmingGui = script.Parent
local SelectGui = FarmingGui:WaitForChild("Select")
local DropdownGui = SelectGui:WaitForChild("Dropdown")
local WateringCanFillGui = FarmingGui:WaitForChild("WateringCanFill")
local BuyGui = FarmingGui:WaitForChild("Buy")

local Camera = workspace.CurrentCamera
local Mouse = lplr:GetMouse()

local SelectGuiTable = {"Plant", "Water", "Harvest", "Seeds", "WateringCans", "Sickles"}
local SelectGuiPosition = 1

local BuyCropsMultiplier = {5,7,10,14}
local SellCropsMultiplier = {8,13,22,36}


-- SELECT GUI ARROWS CLICK

local function HideAllSelectGui()
	SelectGui.Plant.Visible = false
	SelectGui.Water.Visible = false
	SelectGui.Harvest.Visible = false
	
	for i,v in ipairs(DropdownGui:GetChildren()) do
		if v:IsA("Frame") then
			v.Visible = false
		end
	end
end

SelectGui.LeftArrow.MouseButton1Down:Connect(function()
	HideAllSelectGui()
	SelectGuiPosition -= 1 -- go to the previous image
	
	if SelectGuiPosition == 0 then -- if it is 0, there are no more image before
		SelectGuiPosition = #SelectGuiTable / 2 -- go back to the last one
	end
	
	if SelectGui:FindFirstChild(SelectGuiTable[SelectGuiPosition]) and DropdownGui:FindFirstChild(SelectGuiTable[SelectGuiPosition + 3]) then
		SelectGui:FindFirstChild(SelectGuiTable[SelectGuiPosition]).Visible = true -- show the title image and the corresponding dropdown frame
		DropdownGui:FindFirstChild(SelectGuiTable[SelectGuiPosition + (#SelectGuiTable / 2)]).Visible = true
	end
end)

SelectGui.RightArrow.MouseButton1Down:Connect(function()
	HideAllSelectGui()
	SelectGuiPosition += 1 -- go to the next image

	if SelectGuiPosition == (#SelectGuiTable / 2) + 1 then -- if it is the end of the table + 1, there are no images after
		SelectGuiPosition = 1 -- go back to the first one
	end

	if SelectGui:FindFirstChild(SelectGuiTable[SelectGuiPosition]) and DropdownGui:FindFirstChild(SelectGuiTable[SelectGuiPosition + 3]) then
		SelectGui:FindFirstChild(SelectGuiTable[SelectGuiPosition]).Visible = true -- show the title image and the corresponding dropdown frame
		DropdownGui:FindFirstChild(SelectGuiTable[SelectGuiPosition + (#SelectGuiTable / 2)]).Visible = true
	end
end)


-- GET ALL THE CLICKED EVENTS TO EQUIP THE SEEDS, WATERING CANS AND SICKLES

-- SEEDS
for i,v in ipairs(DropdownGui.Seeds.ScrollingFrame:GetChildren()) do
	if v:IsA("ImageButton") then
		v.MouseButton1Down:Connect(function()
			FarmingRemoteEvent:FireServer("Equip", "Seeds", v.Name)
		end)
	end
end

-- WATERING CANS
for i,v in ipairs(DropdownGui.WateringCans:GetChildren()) do
	if v:IsA("ImageButton") then
		v.MouseButton1Down:Connect(function()
			FarmingRemoteEvent:FireServer("Equip", "WateringCans", v.Name)
		end)
	end
end

-- SICKLES
for i,v in ipairs(DropdownGui.Sickles:GetChildren()) do
	if v:IsA("ImageButton") then
		v.MouseButton1Down:Connect(function()
			FarmingRemoteEvent:FireServer("Equip", "Sickles", v.Name)
		end)
	end
end


-- PLAYER CLICKS ON THE NAVIGATION BUTTONS

local function HideAllBuyGui() -- hide all buy guis
	BuyGui.Crops.Visible = false
	BuyGui.WateringCans.Visible = false
	BuyGui.Sickles.Visible = false
end

for i,v in ipairs(BuyGui.NavigationButtons:GetChildren()) do
	if v:IsA("ImageButton") then	
		v.MouseButton1Down:Connect(function()
			HideAllBuyGui() -- hide all the buy guis to the display the right one
			if BuyGui:FindFirstChild(v.Name) then
				BuyGui:FindFirstChild(v.Name).Visible = true
			end
		end)
	end
end


-- PLAYER CLICKS ON THE BUY OR SELL BUTTON IN THE CROPS BUY GUI

-- BUY
BuyGui.Crops.Buy.MouseButton1Down:Connect(function()
	BuyGui.Crops.SellFrame.Visible = false
	BuyGui.Crops.BuyFrame.Visible = true
end)

-- SELL
BuyGui.Crops.Sell.MouseButton1Down:Connect(function()
	BuyGui.Crops.BuyFrame.Visible = false
	BuyGui.Crops.SellFrame.Visible = true
end)


-- PLAYER BUYS CROPS 

for i,v in ipairs(BuyGui.Crops.BuyFrame:GetChildren()) do
	if v:IsA("Frame") then

		if lplr.Farming.Seeds:FindFirstChild(v.Name) then
			v.Total.Text = "Total : "..tostring(lplr.Farming.Seeds:FindFirstChild(v.Name).Value) -- display the total number of items the player has

			v.Amount:GetPropertyChangedSignal("Text"):Connect(function()
				v.Amount.Text = v.Amount.Text:gsub("%D+", "")

				if v.Amount.Text ~= "" then
					if BuyCropsMultiplier[v.LayoutOrder] then -- use the layout order to know which multiplier corresponds to which crop (wheat has a layout order of 1 and is in position 1 in the table)
						v.Price.Text = "Price : $"..tostring(tonumber(v.Amount.Text) * BuyCropsMultiplier[v.LayoutOrder])
					end
				end
			end)

			v.Buy.MouseButton1Down:Connect(function()
				if v.Amount.Text ~= "" then
					local Amount = tonumber(v.Amount.Text) -- get the amount of seeds the player is trying to buy
					
					FarmingRemoteEvent:FireServer("Buy", "Seeds", v.Name, tonumber(v.Amount.Text))
					v.Total.Text = "Total : "..lplr.Farming.Seeds:FindFirstChild(v.Name).Value -- update the number of items the player has
					v.Amount.Text = "" -- reset the text box
				end
			end)
		end
	end
end


-- PLAYER SELLS CROPS

for i,v in ipairs(BuyGui.Crops.SellFrame:GetChildren()) do
	if v:IsA("Frame") then

		if lplr.Farming.Crops:FindFirstChild(v.Name) then
			v.Total.Text = "Total : "..tostring(lplr.Farming.Crops:FindFirstChild(v.Name).Value) -- display the total number of items the player has

			v.Amount:GetPropertyChangedSignal("Text"):Connect(function()
				v.Amount.Text = v.Amount.Text:gsub("%D+", "")

				if v.Amount.Text ~= "" then
					if SellCropsMultiplier[v.LayoutOrder] then -- use the layout order to know which multiplier corresponds to which crop (wheat has a layout order of 1 and is in position 1 in the table)
						v.MoneyEarnt.Text = "+ $"..tostring(tonumber(v.Amount.Text) * SellCropsMultiplier[v.LayoutOrder])
					end
				end
			end)

			v.Sell.MouseButton1Down:Connect(function()
				if v.Amount.Text ~= "" then
					local Amount = tonumber(v.Amount.Text) -- get the amount of seeds the player is trying to sell

					FarmingRemoteEvent:FireServer("Sell", v.Name, tonumber(v.Amount.Text))
					v.Total.Text = "Total : "..lplr.Farming.Crops:FindFirstChild(v.Name).Value -- update the number of items the player has
					v.Amount.Text = "" -- reset the text box
				end
			end)
		end
	end
end


-- PLAYER BUYS A WATERING CAN

for i,v in ipairs(BuyGui.WateringCans:GetChildren()) do
	if v:IsA("Frame") then
		v.Buy.MouseButton1Down:Connect(function()
			FarmingRemoteEvent:FireServer("Buy", "WateringCans", v.Name)
		end)
	end
end


-- PLAYER BUYS A SICKLE

for i,v in ipairs(BuyGui.Sickles:GetChildren()) do
	if v:IsA("Frame") then
		v.Buy.MouseButton1Down:Connect(function()
			FarmingRemoteEvent:FireServer("Buy", "Sickles", v.Name)
		end)
	end
end


-- PLAYER CLICKS ON A FARM TILE

Mouse.Button1Down:Connect(function()
	if SelectGui.Visible == true then -- check if the player is in the farm (the player can only have a tool equipped if the gui is visible), might be a better to know if the player is in the farm (connect when gui gets visible and disconnect when the player leaves the farm and reconnect after if he comes back....)
		if Mouse.Target and Mouse.Target.Name == "Floor" and Mouse.Target.Parent.Parent.Name == "FarmTiles" then -- if the player clicked on a tile
			FarmingRemoteEvent:FireServer("FarmTileClicked", Mouse.Target)
		end
		if Mouse.Target.Name == "HitBox" and Mouse.Target.Parent.Parent.Parent.Name == "FarmTiles" then
			FarmingRemoteEvent:FireServer("FarmTileClicked", Mouse.Target.Parent.Parent:FindFirstChild("Floor"))
		end
	end
end)


-- PLAYER TAPS ON A FARM TILE

UIS.TouchTapInWorld:Connect(function(Position, Processed)
	if SelectGui.Visible == true then -- check if the player is in the farm (the player can only have a tool equipped if the gui is visible), might be a better to know if the player is in the farm (connect when gui gets visible and disconnect when the player leaves the farm and reconnect after if he comes back....)
		local ray = Camera:ViewportPointToRay(Position.X, Position.Y, 0) -- fire a ray from the player's camera to where the player clicked
		FarmingRemoteEvent:FireServer("FarmTileTapped", ray)
	end
end)


-- PLAYER PLANTED A SEED OR A CROP GREW

FarmingRemoteEvent.OnClientEvent:Connect(function(Type, Param1, Param2, Param3)

	if Type == "Plant" then -- if the player is planting a seed
		local FarmTile = Param1
		local Seed = Param2

		if FarmTile and typeof(FarmTile) == "string" and Seed and typeof(Seed) == "string" then
			local Crop = ReplicatedStorage.CropsStages:FindFirstChild(Seed.."S0") -- find the crop in the replicated storage

			if Crop and workspace.Farm.FarmTiles:FindFirstChild(FarmTile) then -- if the crop model and the farm tile has been found
				Crop = Crop:Clone() -- clone the crop
				Crop:SetPrimaryPartCFrame(workspace.Farm.FarmTiles:FindFirstChild(FarmTile).CropPosition.CFrame * CFrame.Angles(0,math.rad(math.random(0,360)),0)) -- move it to the right farm tile and give it a random orientation so that it looks more natural
				Crop:FindFirstChild("HitBox").Orientation = Vector3.new(0,0,0) -- keep the hitbox orientation at 0,0,0, otherwise if it turns with the seed, it gets over the other tiles, and player will then click on the wrong tile				
				Crop.Parent = workspace.Farm.FarmTiles:FindFirstChild(FarmTile)
			end
		end
		
	elseif Type == "Water" then
		
		local FarmTileTable = Param1
				
		if FarmTileTable and typeof(FarmTileTable == "table") then -- farm tile table is a table and is not empty
			for i,v in pairs(FarmTileTable) do -- loop through the farm tile table that the player should water
				if workspace.Farm.FarmTiles:FindFirstChild("L"..v[1].."C"..v[2]) then -- if the farm tile was found
					workspace.Farm.FarmTiles:FindFirstChild("L"..v[1].."C"..v[2]).Floor.BrickColor = BrickColor.new("Burnt Sienna") -- change the color to a darker brown (as if it was wet) 
				end
			end
		end


	elseif Type == "Grow" then
		
		local FarmTile = Param1
		local Seed = Param2
		local Stage = Param3
				
		if workspace.Farm.FarmTiles:FindFirstChild(FarmTile) and workspace.Farm.FarmTiles:FindFirstChild(FarmTile):FindFirstChild(Seed.."S"..(Stage - 1)) then
			workspace.Farm.FarmTiles:FindFirstChild(FarmTile):FindFirstChild(Seed.."S"..(Stage - 1)):Destroy()
			
			local Crop = ReplicatedStorage.CropsStages:FindFirstChild(Seed.."S"..Stage)

			if Crop then
				Crop = Crop:Clone()
				Crop:SetPrimaryPartCFrame(workspace.Farm.FarmTiles:FindFirstChild(FarmTile).CropPosition.CFrame * CFrame.Angles(0,math.rad(math.random(0,360)),0)) -- move it to the right farm tile and give it a random orientation so that it looks more natural
				Crop:FindFirstChild("HitBox").Orientation = Vector3.new(0,0,0) -- keep the hitbox orientation at 0,0,0, otherwise if it turns with the seed, it gets over the other tiles, and player will then click on the wrong tile				
				Crop.Parent = workspace.Farm.FarmTiles:FindFirstChild(FarmTile)
			end
		end
		
	elseif Type == "Harvest" then
		
		local FarmTileTable = Param1
		
		if FarmTileTable then
			for i,v in pairs(FarmTileTable) do
				
				local FarmTile = workspace.Farm.FarmTiles:FindFirstChild("L"..tonumber(v[1]).."C"..v[2])
				
				if FarmTile and FarmTile:FindFirstChildOfClass("Model") then
					FarmTile:FindFirstChildOfClass("Model"):Destroy()
					FarmTile.Floor.Color = Color3.fromRGB(147, 86, 48)
				end 
			end
		end
		
	elseif Type == "LoadCrops" then
		
		local FarmingTable = Param1
		
		for i,v in pairs(FarmingTable) do
			for a,b in pairs(v) do
				
				if ReplicatedStorage.CropsStages:FindFirstChild(b["Crop"].."S"..b["Stage"]) and workspace.Farm.FarmTiles:FindFirstChild("L"..a.."C"..i) then
					
					local Crop = ReplicatedStorage.CropsStages:FindFirstChild(b["Crop"].."S"..b["Stage"]):Clone()
					Crop:SetPrimaryPartCFrame(workspace.Farm.FarmTiles:FindFirstChild("L"..a.."C"..i).CropPosition.CFrame * CFrame.Angles(0,math.rad(math.random(0,360)),0)) -- move it to the right farm tile and give it a random orientation so that it looks more natural
					Crop:FindFirstChild("HitBox").Orientation = Vector3.new(0,0,0) -- keep the hitbox orientation at 0,0,0, otherwise if it turns with the seed, it gets over the other tiles, and player will then click on the wrong tile				
					Crop.Parent = workspace.Farm.FarmTiles:FindFirstChild("L"..a.."C"..i)
					
					if b["Watered"] and b["Watered"] == true then
						workspace.Farm.FarmTiles:FindFirstChild("L"..a.."C"..i).Floor.BrickColor = BrickColor.new("Burnt Sienna")
					end
				end
			end
		end
	end
end)


--[[

select x position = 0.01
dropdown y size = 0.85
watering can fill x position = 0.99
buy y position = 0.55

-- in each folder :
-- player : string
-- stage : int
-- row : int
-- column : int
-- crop : string


every 5 seconds :
if there are values in the 0 folder, change the stage, fire the client to change the model and choose a new random number based on the crops and then put it in the right folder, roudn the number : 5 * math.floor(number / 5) 
0 folder name = 300, for i = 5,300,5, if not findfirstchil(i-5)  then findfirstchild(i).Name = i-5
--]]