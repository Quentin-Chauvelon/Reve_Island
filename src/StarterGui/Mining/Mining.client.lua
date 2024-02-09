local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MiningRemoteEvent = ReplicatedStorage:WaitForChild("Mining")
local MinesRemoteEvent = ReplicatedStorage:WaitForChild("Mines")
local ConfirmationRemoteEvent = ReplicatedStorage:WaitForChild("BuyConfirmation")

local lplr = game.Players.LocalPlayer

local Mines = workspace.Mines
local Camera = workspace.CurrentCamera

local MiningGui = lplr.PlayerGui.Mining
local OresGivenGui = MiningGui:WaitForChild("OresGiven")
local OresMinersGui = MiningGui:WaitForChild("OresMiners")
local SwordSelectGui = MiningGui:WaitForChild("SwordSelect")
local BowSelectGui = MiningGui:WaitForChild("BowSelect")
local ElevatorGui = MiningGui:WaitForChild("Elevator")
local SellGui = MiningGui:WaitForChild("Sell"):WaitForChild("Frame")

local FirstSell = false

local CloseSellGui

local OresTable = {Stone = 0, Coal = 50, Iron = 200, Olivine = 750, Amethyst = 1600, Cobalt = 4250}
local PricesTable = {
	Swords = {Stone = 0, Coal = 4500, Iron = 10000, Olivine = 35000, Amethyst = 60000, Cobalt = 130000},
	Bow = 300000
}
local SellPrices = {Stone = 0, Coal = 25, Iron = 33, Olivine = 42, Amethyst = 55, Cobalt = 70}


-- PLAYER SETS AN AMOUNT OF ORES TO GIVE TO THE MINERS

OresMinersGui.Frame.Amount:GetPropertyChangedSignal("Text"):Connect(function()
	OresMinersGui.Frame.Amount.Text = OresMinersGui.Frame.Amount.Text:gsub("%D+", "")
end)


-- PLAYER CLICKS THE FILL BUTTON ON THE GIVE ORES MINERS GUI
OresMinersGui.Frame.Fill.MouseButton1Down:Connect(function()

	local OresLeftToGive = 0
	local Ore = OresMinersGui.Ore.Value

	if Ore and OresTable[Ore] and lplr.Mining.OresGiven:FindFirstChild(Ore) then
		OresLeftToGive = OresTable[Ore] - lplr.Mining.OresGiven:FindFirstChild(Ore).Value -- get the amount of ores left to give to the miner

		-- If player has less ores than what's left to give to the miner
		if lplr.Mining.Ores:FindFirstChild(Ore).Value and OresLeftToGive > lplr.Mining.Ores:FindFirstChild(Ore).Value then
			OresLeftToGive = lplr.Mining.Ores:FindFirstChild(Ore).Value
		end
	end

	OresMinersGui.Frame.Amount.Text = tostring(OresLeftToGive) -- set the amount text to the amount of ores left to give to the miner
end)


-- PLAYER CLICKS ON THE GIVE BUTTON ON THE GIVE ORES MINERS GUI

OresMinersGui.Frame.Give.MouseButton1Down:Connect(function()
	OresMinersGui:TweenPosition(UDim2.new(0.5,0,1.5,0)) -- tween the gui down
	wait(1)

	MiningRemoteEvent:FireServer("GiveOres", OresMinersGui.Ore.Value, tonumber(OresMinersGui.Frame.Amount.Text)) -- fire the server to give the ores to the miner

	OresMinersGui.Visible = false -- hide the gui
	OresMinersGui.Frame.Amount.Text = "" -- reset the amount text
end)


-- PLAYER CLICKS ON THE CANCEL BUTTON ON THE GIVE ORES MINERS GUI
OresMinersGui.Frame.Cancel.MouseButton1Down:Connect(function()
	OresMinersGui:TweenPosition(UDim2.new(0.5,0,1.5,0)) -- tween the gui down
	wait(1)
	OresMinersGui.Visible = false -- hide the gui
	OresMinersGui.Frame.Amount.Text = "" -- reset the amount text
end)



-- MINING REMOTE EVENT FIRED FROM SERVER (USED FOR ALL THAT IS MINING RELATED (PICKAXES, SWORDS, BOWS, ORES))

MiningRemoteEvent.OnClientEvent:Connect(function(Type, Param1)

	if Type == "GiveOres" then

		local Ore = Param1

		-- Show the gui to give ores to the miners
		if OresTable[Ore] and lplr.Mining.Ores:FindFirstChild(Ore) and lplr.Mining.OresGiven:FindFirstChild(Ore) then
			OresMinersGui.Visible = true

			OresMinersGui.Owned.Text = "You have "..lplr.Mining.Ores:FindFirstChild(Ore).Value.." ores"
			OresMinersGui.Give.Text = "Give "..(OresTable[Ore] - lplr.Mining.OresGiven:FindFirstChild(Ore).Value).." more ores to the miner to get his pickaxe"
			OresMinersGui.Total.Text = "Total : "..lplr.Mining.OresGiven:FindFirstChild(Ore).Value.." / "..OresTable[Ore]
			OresMinersGui.Ore.Value = Ore
			OresMinersGui:TweenPosition(UDim2.new(0.5,0,0.55,0))
		end
	end
end)


-- MINES REMOTE EVENT FIRED FROM SERVER (USED FOR ALL THAT IS MINES RELATED (ELEVATOR, MOBS, ROCK PET, AMETHYST MINECARTS, COBALT LAVA...))

MinesRemoteEvent.OnClientEvent:Connect(function(Type)

	-- Player takes the elevator
	if Type == "Elevator" then		
		ElevatorGui.Visible = true -- show the elevator gui
		ElevatorGui:TweenPosition(UDim2.new(0.5,0,0.55,0))

	elseif Type == "LoadOres" then

		-- Load and change all the ores given miners texts
		for i,v in ipairs(lplr.Mining.OresGiven:GetChildren()) do

			if OresGivenGui:FindFirstChild(v.Name) and OresTable[v.Name] then

				-- Change the amount of ores give texts
				if v.Value < OresTable[v.Name] then
					OresGivenGui:FindFirstChild(v.Name).Amount.Text = tostring(v.Value).." / "..tostring(OresTable[v.Name])
				else
					OresGivenGui:FindFirstChild(v.Name).Amount.Text = OresTable[v.Name].." / "..tostring(OresTable[v.Name])
					OresGivenGui:FindFirstChild(v.Name).Amount.TextColor3 = Color3.fromRGB(0, 190, 6)
				end
			end
		end		
	end
end)


-- PLAYER CLICKS A BUTTON IN THE ELEVATOR TO CHANGE LAYER

for i,v in ipairs(ElevatorGui.Layers:GetChildren()) do
	if v:IsA("ImageButton") then
		v.MouseButton1Down:Connect(function()

			MinesRemoteEvent:FireServer("Elevator", v.Name) -- fire server to tp to layer

			-- Hide the elevator gui
			ElevatorGui:TweenPosition(UDim2.new(0.5,0,1.5,0))
			wait(1)
			ElevatorGui.Visible = false
		end)
	end
end


-- HIDE THE SWORD OR BOW GUI

local function HideGui(ToolType, Gui, TeleportPart)
	-- Reset the sword gui and the camera
	Gui.Visible = false
	Gui.Buy.Visible = false

	if ToolType == "Sword" then
		if Gui:FindFirstChildWhichIsA("StringValue") then
			Gui:FindFirstChildWhichIsA("StringValue").Value = ""
		end

		for i,v in ipairs(Mines.SwordRack.SwordSelect:GetChildren()) do
			-- Make the swords unclickable
			if v:FindFirstChild("ClickDetector") then
				v:FindFirstChild("ClickDetector").MaxActivationDistance = 0
			end
		end

	elseif ToolType == "Bow" then
		Mines.BowRack.BowSelect.ClickDetector.MaxActivationDistance = 0
	end

	Camera.CameraType = Enum.CameraType.Custom

	-- Unfreeze player
	if workspace:FindFirstChild(lplr.Name) then
		workspace:FindFirstChild(lplr.Name):FindFirstChild("HumanoidRootPart").Anchored = false
		workspace:FindFirstChild(lplr.Name):FindFirstChild("HumanoidRootPart").CFrame = TeleportPart.CFrame
	end
end


-- PLAYER WALKS IN THE SWORD SELECT AND BUY CIRCLE

Mines.SwordRack.CircleIn.Touched:Connect(function(hit)
	if hit.Parent.Name == lplr.Name then

		Camera.CameraType = Enum.CameraType.Scriptable
		TweenService:Create(Camera, TweenInfo.new(1), {CFrame = Mines.SwordRack.SwordCamera.CFrame}):Play()

		-- Make the swords clickable to select or buy them
		for i,v in ipairs(Mines.SwordRack.SwordSelect:GetChildren()) do
			if v:FindFirstChild("ClickDetector") then
				v:FindFirstChild("ClickDetector").MaxActivationDistance = 30
			end
		end

		-- Freeze and teleport player
		if workspace:FindFirstChild(lplr.Name) then
			workspace:FindFirstChild(lplr.Name):FindFirstChild("HumanoidRootPart").Anchored = true
		end

		wait(1)

		SwordSelectGui.Visible = true
	end
end)


-- GET ALL THE SWORDS CLICK EVENT ON THE SWORD RACK (TO SELECT OR BUY THEM)

for i,v in ipairs(Mines.SwordRack.SwordSelect:GetChildren()) do
	v.ClickDetector.MouseClick:Connect(function() -- player clicks one of the swords

		if lplr.Mining.Swords:FindFirstChild(v.Name) then -- if the sword has been found in the player's folder
			MiningGui.SwordSelect.Sword.Value = v.Name -- set the value to know which sword the player clicked

			-- If the player already owns the sword, give it to him
			if lplr.Mining.Swords:FindFirstChild(v.Name).Value == true then
				HideGui("Sword", SwordSelectGui, Mines.SwordRack.TeleportOut)
				MiningRemoteEvent:FireServer("Sword", v.Name)

				-- If the player doesn't own the sword, show the gui to buy it
			else
				SwordSelectGui.Buy.Sword.Text = v.Name.." sword :"

				if PricesTable["Swords"][v.Name] then
					SwordSelectGui.Buy.Price.Text = "$"..PricesTable["Swords"][v.Name]
				end

				SwordSelectGui.Buy.Visible = true
			end
		end
	end)
end


-- PLAYER CLICKS THE CLOSE BUTTON TO HIDE THE SWORD GUI
SwordSelectGui.Close.MouseButton1Down:Connect(function()
	HideGui("Sword", SwordSelectGui, Mines.SwordRack.TeleportOut)
end)



-- PLAYER CLICKS THE BUY BUTTON TO BUY A SWORD

SwordSelectGui.Buy.Buy.MouseButton1Down:Connect(function()

	-- Get confirmation that player indeed wants to buy the sword
	ConfirmationRemoteEvent:FireServer(MiningGui.SwordSelect.Sword.Value.." sword", PricesTable["Swords"][MiningGui.SwordSelect.Sword.Value]) -- fire the server to confirm the purchase of the item

	if lplr.PlayerScripts:FindFirstChild("Confirmation") and lplr.PlayerScripts:FindFirstChild("Confirmation").Confirm then

		-- Wait for the player to click on one of the buttons
		repeat wait(1) until lplr.PlayerScripts:FindFirstChild("Confirmation").Confirm.Value ~= 0

		-- If the player clicked the yes button
		if lplr.PlayerScripts:FindFirstChild("Confirmation").Confirm.Value == 2 then
			MiningRemoteEvent:FireServer("Sword", MiningGui.SwordSelect.Sword.Value) -- fire the server to buy the tool
			HideGui("Sword", SwordSelectGui, Mines.SwordRack.TeleportOut)
		end

		lplr.PlayerScripts:FindFirstChild("Confirmation").Confirm.Value = 0 -- reset the value
	end
end)


-- PLAYER WALKS IN THE BOW SELECT AND BUY CIRCLE

Mines.BowRack.CircleIn.Touched:Connect(function(hit)
	if hit.Parent.Name == lplr.Name then
	Camera.CameraType = Enum.CameraType.Scriptable
	TweenService:Create(Camera, TweenInfo.new(1), {CFrame = Mines.BowRack.BowCamera.CFrame}):Play()

	-- Make the bow clickable to select or buy them
	Mines.BowRack.BowSelect.ClickDetector.MaxActivationDistance = 30

	-- Freeze the player
	if workspace:FindFirstChild(lplr.Name) then
		workspace:FindFirstChild(lplr.Name):FindFirstChild("HumanoidRootPart").Anchored = true
	end

	wait(1)

		BowSelectGui.Visible = true
		end
end)


-- GET THE BOW CLICK EVENT ON THE BOW RACK (TO SELECT OR BUY THEM)

Mines.BowRack.BowSelect.ClickDetector.MouseClick:Connect(function() -- player clicks one of the swords

	-- If the player already owns the bow, give it to him
	if lplr.Mining.Bows.Iron.Value == true then
		HideGui("Bow", BowSelectGui, Mines.BowRack.TeleportOut)
		MiningRemoteEvent:FireServer("Bow")

		-- If the player doesn't own the sword, show the gui to buy it
	else
		BowSelectGui.Buy.Visible = true
	end
end)


-- PLAYER CLICKS THE CLOSE BUTTON TO HIDE THE SWORD GUI
BowSelectGui.Close.MouseButton1Down:Connect(function()
	HideGui("Bow", BowSelectGui, Mines.BowRack.TeleportOut)
end)



-- PLAYER CLICKS THE BUY BUTTON TO BUY A SWORD

BowSelectGui.Buy.Buy.MouseButton1Down:Connect(function()

	-- Get confirmation that player indeed wants to buy the sword
	ConfirmationRemoteEvent:FireServer(" bow", PricesTable["Bow"]) -- fire the server to confirm the purchase of the item

	if lplr.PlayerScripts:FindFirstChild("Confirmation") and lplr.PlayerScripts:FindFirstChild("Confirmation").Confirm then

		-- Wait for the player to click on one of the buttons
		repeat wait(1) until lplr.PlayerScripts:FindFirstChild("Confirmation").Confirm.Value ~= 0

		-- If the player clicked the yes button
		if lplr.PlayerScripts:FindFirstChild("Confirmation").Confirm.Value == 2 then
			MiningRemoteEvent:FireServer("Bow") -- fire the server to buy the tool
			HideGui("Bow", BowSelectGui, Mines.BowRack.TeleportOut)
		end

		lplr.PlayerScripts:FindFirstChild("Confirmation").Confirm.Value = 0 -- reset the value
	end
end)


-- SELL CIRCLE TRIGGER TOUCHED

Mines.Sell.CircleIn.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) and hit.Parent.Name == lplr.Name then

		-- Show gui
		MiningGui.Sell.Visible = true
		MiningGui.Sell:TweenPosition(UDim2.new(0.5,0,0.5,0))

		if not FirstSell then
			FirstSell = true

			for i,v in ipairs(SellGui:GetChildren()) do
				if v:IsA("Frame") then

					-- Change the total number of ores the player has
					v.Total.Text = "Total : "..tostring(lplr.Mining.Ores[v.Name].Value)

					-- When player types an amount, change the money earnt accordingly and remove anything that isn't a number
					v.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
						v.TextBox.Text = v.TextBox.Text:gsub("%D+", "")

						if v.TextBox.Text and tonumber(v.TextBox.Text) and SellPrices[v.Name] then
							v.MoneyEarnt.Text = "+ $"..tostring(SellPrices[v.Name] * tonumber(v.TextBox.Text))
						end
					end)

					-- Player clicks the sell button
					v.Sell.MouseButton1Down:Connect(function()
						if lplr.Mining.Ores:FindFirstChild(v.Name) and tonumber(v.TextBox.Text) then

							-- If the player is not trying to sell more ores than he has
							if lplr.Mining.Ores[v.Name].Value >= tonumber(v.TextBox.Text) then
								MiningRemoteEvent:FireServer("Sell", v.Name, tonumber(v.TextBox.Text))

								-- Reset guis
								v.Total.Text = "Total : "..tostring(lplr.Mining.Ores[v.Name].Value - tonumber(v.TextBox.Text))
								v.MoneyEarnt.Text = "$ +0"
								v.TextBox.Text = ""
							end
						end
					end)
				end
			end
		end	


		-- CLOSE SELL GUI

		CloseSellGui = MiningGui.Sell.Close.MouseButton1Down:Connect(function()
			CloseSellGui:Disconnect()
			
			-- Teleport player away
			if workspace:FindFirstChild(lplr.Name) then
				workspace[lplr.Name].HumanoidRootPart.CFrame = Mines.TeleportOut.CFrame
			end

			-- Hide gui
			MiningGui.Sell:TweenPosition(UDim2.new(0.5,0,1.5,0))
			wait(1)
			MiningGui.Sell.Visible = false
		end)
	end
end)