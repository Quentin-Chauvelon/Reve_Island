local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreRemoteEvent = ReplicatedStorage:WaitForChild("DataStore")
local FirstFire = true

local lplr = game.Players.LocalPlayer

-- LOAD ALL THE GUIS WHEN PLAYER JOINS THE GAME OR RESET HIS CHARACTER

local function LoadGui(ExperienceTable, CasinoChip)
	
	
	-- Leaderstats
	lplr.PlayerGui:WaitForChild("Stats"):WaitForChild("Frame"):WaitForChild("Money"):WaitForChild("Money").Text = "$"..tostring(lplr.leaderstats.Money.Value)
	lplr.PlayerGui:WaitForChild("Computer"):WaitForChild("Screen"):WaitForChild("Competitive"):WaitForChild("Pb").Text = "Best : "..tostring(lplr.Stats.TypingPb.Value).."s"


	-- Experience
	local SummaryExperienceGui = lplr.PlayerGui:WaitForChild("Experience"):WaitForChild("Summary")

	if ExperienceTable then
		for i,v in pairs(ExperienceTable) do
			SummaryExperienceGui:WaitForChild(i)

			local JobExperience = v
			local MaxExperience = 0
			local ExperienceLevel = 0

			if JobExperience < 100 then
				MaxExperience = 100
				ExperienceLevel = 1

			elseif JobExperience >= 100 and JobExperience < 400 then
				JobExperience = JobExperience - 100
				MaxExperience = 300
				ExperienceLevel = 2


			elseif JobExperience >= 400 and JobExperience < 1000 then
				JobExperience = JobExperience - 400
				MaxExperience = 600
				ExperienceLevel = 3

			elseif JobExperience >= 1000 and JobExperience < 2200 then
				JobExperience = JobExperience - 1000
				MaxExperience = 1200
				ExperienceLevel = 4

			elseif JobExperience >= 2200 and JobExperience < 5200 then
				JobExperience = JobExperience - 2200
				MaxExperience = 3000
				ExperienceLevel = 5

			elseif JobExperience >= 5200 and JobExperience < 11200 then
				JobExperience = JobExperience - 5200
				MaxExperience = 6000
				ExperienceLevel = 6

			elseif JobExperience >= 11200 and JobExperience < 26200 then
				JobExperience = JobExperience - 11200
				MaxExperience = 15000
				ExperienceLevel = 7

			elseif JobExperience >= 26200 and JobExperience < 56200 then
				JobExperience = JobExperience - 26200
				MaxExperience = 30000
				ExperienceLevel = 8

			elseif JobExperience >= 56200 and JobExperience < 101200 then
				JobExperience = JobExperience - 56200
				MaxExperience = 45000
				ExperienceLevel = 9

			elseif JobExperience >= 101200 and JobExperience < 161200 then
				JobExperience = JobExperience - 101200
				MaxExperience = 60000
				ExperienceLevel = 10

			elseif JobExperience >= 161200 then
				JobExperience = 60000
				MaxExperience = 60000
				ExperienceLevel = "MAX"
			end

			SummaryExperienceGui[i].Experience.Text = tostring(JobExperience).." / "..tostring(MaxExperience)
			SummaryExperienceGui[i].Frame.ProgressBar.Size = UDim2.new((JobExperience / MaxExperience),0,1,0)
			SummaryExperienceGui[i].Level.Text = "Level "..ExperienceLevel
		end
	end


	-- Settings
	if lplr.Settings.DisplayClock.Value == false then
		lplr.PlayerGui.Settings.Frame.DisplayClock.Frame.DisplayClock.TextTransparency = 1
		lplr.PlayerGui.Stats.Frame.Clock.Visible = false
	end

	if lplr.Settings.TransparentClock.Value == true then
		lplr.PlayerGui.Settings.Frame.TransparentClock.Frame.TransparentClock.TextTransparency = 0
		lplr.PlayerGui.Stats.Frame.Clock.BackgroundTransparency = 1
	end

	if lplr.Settings.DisplayHappyBirthday.Value == false then
		lplr.PlayerGui.Settings.Frame.DisplayHappyBirthday.Frame.DisplayHappyBirthday.TextTransparency = 1
	end

	if lplr.Settings.DisplayVehicleKeyHelp.Value == false then
		lplr.PlayerGui.Settings.Frame.DisplayVehicleKeyHelp.Frame.DisplayVehicleKeyHelp.TextTransparency = 1
	end

	if lplr.Settings.BusStopBeam.Value == false then
		lplr.PlayerGui.Settings.Frame.BusStopBeam.Frame.BusStopBeam.TextTransparency = 1
	end

	if lplr.Settings.DeliveryHouseBeam.Value == false then
		lplr.PlayerGui.Settings.Frame.BusStopBeam.Frame.BusStopBeam.TextTransparency = 1
	end


	-- Lumberjack
	local ToolsGui = lplr.PlayerGui:WaitForChild("Lumberjack"):WaitForChild("Select"):WaitForChild("Tools")

	for i,v in ipairs(lplr.Lumberjack.Tools:GetChildren()) do
		if v.Value then
			ToolsGui:WaitForChild(v.Name).Locked.Visible = false
			ToolsGui[v.Name].Select.Visible = true
			ToolsGui[v.Name].Bubble.BackgroundColor3 = Color3.fromRGB(255,235,0)
		end
	end

	local TreesToUnlockGui = lplr.PlayerGui.Lumberjack:WaitForChild("UnlockTrees"):WaitForChild("TreesToUnlock")
	lplr.PlayerGui.Lumberjack.UnlockTrees:WaitForChild("AllTreesUnlocked"):WaitForChild("TextLabel")

	if lplr.Lumberjack.TreesChoppedDown.Value <= 890 then
		if lplr.Lumberjack.TreesChoppedDown.Value < 10 then
			TreesToUnlockGui.ImageLabel.TextLabel.Text = tostring(lplr.Lumberjack.TreesChoppedDown.Value).." / 10" -- add one to the tree counter (x / x)
			TreesToUnlockGui.ImageLabel.Frame.Size = UDim2.new((lplr.Lumberjack.TreesChoppedDown.Value / 10),0,1,0) -- make the progress bar bigger
			TreesToUnlockGui.ToUnlock.Text = "Chop down 10 trees to unlock the birch trees"

		elseif lplr.Lumberjack.TreesChoppedDown.Value < 40 then
			TreesToUnlockGui.ImageLabel.TextLabel.Text = tostring(lplr.Lumberjack.TreesChoppedDown.Value - 10).." / 30" -- add one to the tree counter (x / x)
			TreesToUnlockGui.ImageLabel.Frame.Size = UDim2.new(((lplr.Lumberjack.TreesChoppedDown.Value - 10) / 30),0,1,0) -- make the progress bar bigger
			TreesToUnlockGui.ToUnlock.Text = "Chop down 30 trees to unlock the maple trees"

		elseif lplr.Lumberjack.TreesChoppedDown.Value < 140 then
			TreesToUnlockGui.ImageLabel.TextLabel.Text = tostring(lplr.Lumberjack.TreesChoppedDown.Value - 40).." / 100" -- add one to the tree counter (x / x)
			TreesToUnlockGui.ImageLabel.Frame.Size = UDim2.new(((lplr.Lumberjack.TreesChoppedDown.Value - 40) / 100),0,1,0) -- make the progress bar bigger
			TreesToUnlockGui.ToUnlock.Text = "Chop down 100 trees to unlock the pine trees"			

		elseif lplr.Lumberjack.TreesChoppedDown.Value < 890 then
			TreesToUnlockGui.ImageLabel.TextLabel.Text = tostring(lplr.Lumberjack.TreesChoppedDown.Value - 140).." / 750" -- add one to the tree counter (x / x)
			TreesToUnlockGui.ImageLabel.Frame.Size = UDim2.new(((lplr.Lumberjack.TreesChoppedDown.Value - 140) / 750),0,1,0) -- make the progress bar bigger
			TreesToUnlockGui.ToUnlock.Text = "Chop down 750 trees to unlock the apple trees"

		end

		TreesToUnlockGui.Visible = true -- show the trees to unlock progress bar
	else
		lplr.PlayerGui.Lumberjack.UnlockTrees.AllTreesUnlocked.TextLabel.Text = tostring(lplr.Lumberjack.TreesChoppedDown.Value)
		lplr.PlayerGui.Lumberjack.UnlockTrees.AllTreesUnlocked.Visible = true -- show the all trees unlocked sign
	end


	-- Fishing
	lplr.PlayerGui:WaitForChild("Fishing"):WaitForChild("Select"):WaitForChild("Rods") -- wait for the rods frame to load
	lplr.PlayerGui.Fishing.Select:WaitForChild("Baits") -- wait for the baits frame to load

	local RodGui = lplr.PlayerGui.Fishing.Select.Rods

	for i,v in ipairs(lplr.Fishing.Rods:GetChildren()) do -- if the player owns the rod, hide the locked image and show the select button
		if v.Value == true and v.Name ~= "EquippedBait" then
			RodGui:WaitForChild(v.Name).Locked.Visible = false
			RodGui[v.Name].Select.Visible = true
		end
	end

	local BaitGui = lplr.PlayerGui.Fishing.Select.Baits

	for i,v in ipairs(lplr.Fishing.Baits:GetChildren()) do -- if the player owns the bait, hide the locked image and show the select button
		if v.Value == true then
			BaitGui:WaitForChild(v.Name).Locked.Visible = false
			BaitGui[v.Name].Select.Visible = true

		end
	end


	-- Farming
	local DropdownGui = lplr.PlayerGui:WaitForChild("Farming"):WaitForChild("Select"):WaitForChild("Dropdown")
	DropdownGui:WaitForChild("Seeds") -- wait for the seeds frame to load
	DropdownGui:WaitForChild("WateringCans") -- wait for the watering cans frame to load
	DropdownGui:WaitForChild("Sickles") -- wait for the sickles frame to load

	local BuyGui = lplr.PlayerGui:WaitForChild("Farming"):WaitForChild("Buy")
	BuyGui:WaitForChild	("Crops"):WaitForChild("BuyFrame")
	BuyGui:WaitForChild("Crops"):WaitForChild("SellFrame")
	BuyGui:WaitForChild("WateringCans")
	BuyGui:WaitForChild("Sickles")

	for i,v in ipairs(lplr.Farming.Seeds:GetChildren()) do
		if DropdownGui.Seeds.ScrollingFrame:WaitForChild(v.Name) then
			DropdownGui.Seeds.ScrollingFrame:FindFirstChild(v.Name).AmountOwned.Text = tostring(v.Value) -- change the amount of crops the player has
		end

		if BuyGui.Crops.BuyFrame:WaitForChild(v.Name) then
			BuyGui.Crops.BuyFrame:FindFirstChild(v.Name).Total.Text = "Total : "..tostring(v.Value) -- change the total number of seeds the player has
		end
	end

	for i,v in ipairs(lplr.Farming.Crops:GetChildren()) do		
		if BuyGui.Crops.SellFrame:WaitForChild(v.Name) then
			BuyGui.Crops.SellFrame:FindFirstChild(v.Name).Total.Text = "Total : "..tostring(v.Value) -- change the total number of crops the player has
		end
	end

	for i,v in ipairs(lplr.Farming.WateringCans:GetChildren()) do
		if v.Value == true then
			if DropdownGui.WateringCans:FindFirstChild(v.Name) then
				DropdownGui.WateringCans:FindFirstChild(v.Name).BackgroundColor3 = Color3.fromRGB(255,242,204) -- change the background from grey to beige if the player owns the watering can
			end

			if BuyGui.WateringCans:WaitForChild(v.Name) then -- if the player owns the watering can, hide the buy button and the price and show the owned image
				BuyGui.WateringCans:FindFirstChild(v.Name).Buy.Visible = false
				BuyGui.WateringCans:FindFirstChild(v.Name).Owned.Visible = true
				BuyGui.WateringCans:FindFirstChild(v.Name).Price.Visible = false
			end
		end
	end

	for i,v in ipairs(lplr.Farming.Sickles:GetChildren()) do
		if v.Value == true then
			if DropdownGui.Sickles:FindFirstChild(v.Name) then
				DropdownGui.Sickles:FindFirstChild(v.Name).BackgroundColor3 = Color3.fromRGB(255,242,204) -- change the background from grey to beige if the player owns the sickle
			end

			if BuyGui.Sickles:WaitForChild(v.Name) then
				BuyGui.Sickles:FindFirstChild(v.Name).Buy.Visible = false -- if the player owns the sickle, hide the buy button and the price and show the owned image
				BuyGui.Sickles:FindFirstChild(v.Name).Owned.Visible = true
				BuyGui.Sickles:FindFirstChild(v.Name).Price.Visible = false
			end
		end
	end
	
	if CasinoChip and typeof(CasinoChip) == "number" then
		workspace.Casino.CasinoChips.SurfaceGui.TextLabel.Text = tostring(CasinoChip)
	end
	
	if FirstFire then
		FirstFire = false
	end
end


-- Call the load gui function when the player joins the game
DataStoreRemoteEvent.OnClientEvent:Connect(LoadGui)

-- Call the load gui function when the player resets his character
lplr.CharacterAdded:Connect(function()
	if not FirstFire then
		LoadGui()
	end
end)