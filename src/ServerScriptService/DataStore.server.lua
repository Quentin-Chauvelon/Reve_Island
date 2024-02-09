local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerStorage = game:GetService("ServerStorage")
local AgeBindableEvent = ServerStorage:WaitForChild("Age")
local MoneyBindableEvent = ServerStorage:WaitForChild("Money")
local ExperienceBindableEvent = ServerStorage:WaitForChild("Experience")
local CasinoChipBindableEvent = ServerStorage:WaitForChild("CasinoChip")
local TimerBindableEvent = ServerStorage:WaitForChild("Timer")
local DailyRewardBindableEvent = ServerStorage:WaitForChild("DailyReward")
local BankBindableEvent = ServerStorage:WaitForChild("Bank")
local TypingBindableEvent = ServerStorage:WaitForChild("Typing")
local RaceTrackBindableEvent = ServerStorage:WaitForChild("RaceTrack")
local WarnBindableEvent = ServerStorage:WaitForChild("Warn")
local PetSaveBindableEvent = ServerStorage:WaitForChild("PetSave")
local BuyCarBindableEvent = ServerStorage:WaitForChild("BuyCar")
local LumberjackBindableEvent = ServerStorage:WaitForChild("Lumberjack")
local FishingBindableEvent = ServerStorage:WaitForChild("Fishing")
local FarmingBindableEvent = ServerStorage:WaitForChild("Farming")
local MiningBindableEvent = ServerStorage:WaitForChild("Mining")
local MathsBindableEvent = ServerStorage:WaitForChild("Maths")
local MusicBindableEvent = ServerStorage:WaitForChild("Music")
local ArtBindableEvent = ServerStorage:WaitForChild("Art")
local SportBindableEvent = ServerStorage:WaitForChild("Sport")
local HouseBindableEvent = ServerStorage:WaitForChild("House")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MoneyRemoteEvent = ReplicatedStorage:WaitForChild("Money")
local ExperienceRemoteEvent = ReplicatedStorage:WaitForChild("Experience")
local TutorialRemoteEvent = ReplicatedStorage:WaitForChild("Tutorial")
local DeathRemoteEvent = ReplicatedStorage:WaitForChild("Death")
local SettingsRemoteEvent = ReplicatedStorage:WaitForChild("Settings")
local PetCustomisationRemoteEvent = ReplicatedStorage:WaitForChild("PetCustomisation")
local MultitaskRemoteEvent = ReplicatedStorage:WaitForChild("Multitask")
local DataStoreRemoteEvent = ReplicatedStorage:WaitForChild("DataStore")

local DataStoreFolder = ServerStorage:WaitForChild("DataStoreFolder")

--local GamePassesTable = {
--	VIP = false,
--	DoubleMoney = false,
--	DoubleXP = false,
--	Radio = false,
--	Mansion = false,
--	Clothes = false,
--	DoublePet = false,
--	CustomPet = false,
--	Garage = false
--}

local DefaultLeaderstatsTable = {
	Age = 0,
	Money = 0,
	TotalTimePlayed = 0,
	TotalAge = 0,
	Experience = {
		BusDriver = 0,
		DeliveryDriver = 0,
		FactoryWorker = 0,
		Farmer = 0,
		Fisherman = 0,
		Lumberjack = 0,
		Miner = 0,
		Thief = 0,
		Typist = 0,
		Racer = 0,
		Hunter = 0
	},
	CasinoChip = 0,
	LastPlayed = 0,
	DayStreak = 0,
	BestDayStreak = 0,
	TimePlayed = 0,
	BankAccount = 0,
	TypingPb = 0,
	BestRaceTime = 0,
	LeaderboardReward = {}
}

local DefaultSettingsTable = {
	DisplayClock = true,
	TransparentClock = false,
	DisplayHappyBirthday = true,
	DisplayVehicleKeyHelp = true,
	BusStopBeam = true,
	DeliveryHouseBeam = true
}

local DefaultPetTable = {
	OwnedPetTable = {},
	PetCustomisationTable = {}
}

local DefaultCarsTable = {
	Car1 = false,
	Car2 = false,
	Car3 = false,
	Car4 = false,
	Car5 = false,
	Car6 = false,
	Car7 = false,
	Car8 = false,
	Car9 = false,
	Car10 = false,
	Car11 = false,
	Car12 = false,
	Car13 = false,
	Car14 = false,
	Car15 = false,
	Car16 = false,
	Car17 = false,
	Car18 = false,
	Car19 = false,
	Car20 = false,
	Car21 = false,
	Car22 = false,
	Car23 = false,
	Car24 = false,
	Car25 = false,
	Car26 = false,
	Car27 = false,
	Car28 = false,
	Car29 = false,
	Car30 = true,
}

local DefaultLumberjackTable = {
	Tools = { -- tools the player owns
		StoneAxe = false,
		IronAxe = false,
		SteelAxe = false,
		DiamondAxe = false,
		Shears = false,
		Basket = false,
		Mystree = false
	},

	Trees = { -- trees the player has unlocked (need to chop down a certain amount of them to unlock the next one)
		Birch = false,
		Maple = false,
		PineTree = false,
		AppleTree = false
	},

	Wood = 0,
	Leaf = 0,
	Apple = 0,
	TreesChoppedDown = 0 -- how many trees the player has chopped down (used for the leaderboards + to know how many are left to chop down before unlocking the next type of tree)
}

local DefaultFishingTable = {
	Rods = {
		GraphiteRod = false,
		AluminiumRod = false,
		Carrod = false
	},

	Baits = {
		PinkBait = false,
		GreenBait = false,
		RedOrangeBait = false,
		RainbowBait = false
	},

	Fishes = {
		Salmon = 0,
		Cod = 0,
		Trout = 0,
		Catfish = 0,
		Eel = 0,
		Pufferfish = 0,
		Swordfish = 0,
		Shark = 0,
		Pearl = 0
	}
}

local DefaultFarmingTable = {

	Seeds = {
		Wheat = 0,
		Potato = 0,
		Tomato = 0,
		Carrot = 0
	},

	Crops = {
		Wheat = 0,
		Potato = 0,
		Tomato = 0,
		Carrot = 0
	},

	WateringCans = {
		CopperWateringCan = false,
		SteelWateringCan = false
	},

	Sickles = {
		IronSickle = false,
		SteelSickle = false
	},

	FarmingTable = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}} -- empty farming table that fills up when the player plants crops (20 empty tables because each table represents a column and is filled with the rows)
}

local DefaultMiningTable = {
	Ores = {
		Coal = 0,
		Iron = 0,
		Olivine = 0,
		Amethyst = 0,
		Cobalt = 0
	},

	OresGiven = {
		Coal = 0,
		Iron = 0,
		Olivine = 0,
		Amethyst = 0,
		Cobalt = 0
	},

	Pickaxes = {
		Stone = true,
		Coal = false,
		Iron = false,
		Olivine = false,
		Amethyst = false,
		Cobalt = false,
		Miner = false
	},

	Swords = {
		Stone = true,
		Coal = false,
		Iron = false,
		Olivine = false,
		Amethyst = false,
		Cobalt = false,
		Miner = false
	},

	Bows = {
		Iron = false,
		Miner = false
	}
}



local DefaultMathsTable = {

	Best = {
		Best1 = 0,
		Best2 = 0,
		Best3 = 0,
		Best4 = 0,
		Best5 = 0
	},

	Lock = {
		Lock1 = false,
		Lock2 = true,
		Lock3 = true,
		Lock4 = true,
		Lock5 = true,
		Lock6 = true,
	}
}

local DefaultMusicTable = {
	Lock1 = false,
	Lock2 = true,
	Lock3 = true,
	Lock4 = true,
	Lock5 = true,
	Lock6 = true,
}

local DefaultArtTable = {
	Lock1 = false,
	Lock2 = true,
	Lock3 = true,
	Lock4 = true,
	Lock5 = true,
	Lock6 = true,
}

local DefaultSportTable = {
	Lock1 = false,
	Lock2 = true,
	Lock3 = true,
	Lock4 = true,
	Lock5 = true,
	Lock6 = true,
}

local DefaultHouseTable = {
	Type = "Normal",
	Tier = 1,

	Colors = {
		Balcony = {198,190,164},
		Edges = {148,190,129},
		Floor = {211, 190, 150},
		Porch = {148, 190, 129},
		Roof = {148, 190, 129},
		Stairs = {177, 159, 126},
		Walls = {241, 231, 199},
	}
}


local DataStore2 = require(ServerScriptService.DataStore2) -- get the data module
DataStore2.Combine("Data", "Leaderstats", "Settings", "Pets", "Cars", "Lumberjack", "Fishing", "Farming", "Mining", "Music", "Maths", "Art", "Sport", "House") -- combine all the datastores

-- ON PLAYER ADDED

game.Players.PlayerAdded:Connect(function(Player)

	local LeaderstatsTable = DefaultLeaderstatsTable
	local SettingsTable = DefaultSettingsTable
	local OwnedPetTable = {}
	local PetCustomisationTable = {}
	local CarsTable = DefaultCarsTable
	local LumberjackTable = DefaultLumberjackTable
	local FishingTable = DefaultFishingTable
	local FarmingTable = DefaultFarmingTable
	local MiningTable = DefaultMiningTable 
	local MathsTable = DefaultMathsTable
	local MusicTable = DefaultMusicTable
	local ArtTable = DefaultArtTable
	local SportTable = DefaultSportTable
	local HouseTable = DefaultHouseTable

	-- GET THE DATASTORES

	local LeaderstatsDataStore = DataStore2("Leaderstats", Player)
	local SettingsDataStore = DataStore2("Settings", Player)
	local PetsDataStore = DataStore2("Pets", Player)
	local CarsDataStore = DataStore2("Cars", Player)
	local LumberjackDataStore = DataStore2("Lumberjack", Player)
	local FishingDataStore = DataStore2("Fishing", Player)
	local FarmingDataStore = DataStore2("Farming", Player)
	local MiningDataStore = DataStore2("Mining", Player)
	local MusicDataStore = DataStore2("Music", Player)
	local MathsDataStore = DataStore2("Maths", Player)
	local ArtDataStore = DataStore2("Art", Player)
	local SportDataStore = DataStore2("Sport", Player)
	local HouseDataStore = DataStore2("House", Player)
	
	-- FOLDERS AND VALUES

	if not Player:FindFirstChild("leaderstats") then
		for i,v in ipairs(DataStoreFolder:GetChildren()) do
			v:Clone().Parent = Player
		end
	end


	-- LEADERSTATS

	LeaderstatsTable = LeaderstatsDataStore:Get(LeaderstatsTable)

	Player.leaderstats.Age.Value = LeaderstatsTable["Age"]
	Player.leaderstats.Money.Value = LeaderstatsTable["Money"]
	Player.Stats.BankAccount.Value = LeaderstatsTable["BankAccount"]
	Player.Stats.TypingPb.Value = LeaderstatsTable["TypingPb"]
	Player.Stats.BestRaceTime.Value = LeaderstatsTable["BestRaceTime"]
	Player.Stats.CasinoChips.Value = LeaderstatsTable["CasinoChip"]

	if Player.leaderstats.Age.Value < 3 then -- change the team based on the age
		Player.Team = Teams.Baby
	elseif Player.leaderstats.Age.Value > 2 and Player.leaderstats.Age.Value < 18 then
		Player.Team = Teams.Child
	elseif Player.leaderstats.Age.Value > 17 and Player.leaderstats.Age.Value < 60 then
		Player.Team = Teams.Adult
	elseif Player.leaderstats.Age.Value > 59 then
		Player.Team = Teams.Retired
	end


	TimerBindableEvent:Fire(Player, LeaderstatsTable["LastPlayed"], LeaderstatsTable["TimePlayed"], "datastore") -- fire the timer bindable event to start counting the time the player plays


	-- DAILY REWARD

	if LeaderstatsTable["LastPlayed"] == 0 or os.date("*t", os.time())["yday"] ~= os.date("*t", LeaderstatsTable["LastPlayed"])["yday"] then -- check if today's year day (between 1 and 365) is the same as the one corresponding to the last time the player played or if player is playing for the first time

		if os.date("*t", os.time())["yday"] > os.date("*t", LeaderstatsTable["LastPlayed"])["yday"] + 1 then
			LeaderstatsTable["DayStreak"] = 0
		end

		LeaderstatsTable["DayStreak"] = LeaderstatsTable["DayStreak"] + 1 -- add one to the day streak value in the table

		if LeaderstatsTable["DayStreak"] > LeaderstatsTable["BestDayStreak"] then -- if the today's day streak is greater than the best day streak
			LeaderstatsTable["BestDayStreak"] = LeaderstatsTable["DayStreak"] -- change the best day streak to today's day streak
		end
		
		DailyRewardBindableEvent:Fire(Player, LeaderstatsTable["DayStreak"], LeaderstatsTable["BestDayStreak"]) -- fire the daily reward bindable event to reward the player (choose the rewards, play the animation...)
		
		-- use the get function to get the updated leaderstatstable after the call to the dailyreward event which changes multiple things in the leaderstatstable
		LeaderstatsTable = LeaderstatsDataStore:Get(LeaderstatsTable)
		LeaderstatsDataStore:Set(LeaderstatsTable)
	end


	-- INTERESTS

	if LeaderstatsTable["LastPlayed"] and LeaderstatsTable["LastPlayed"] ~= 0 then -- calculate the interests that the player should receive
		local CurrentTime = os.time()
		local TimeDifference = CurrentTime -  LeaderstatsTable["LastPlayed"]
		TimeDifference = math.floor((TimeDifference / 60 / 20) + 0.5)
		if TimeDifference >= 1 then
			for i=1,TimeDifference,1 do
				if Player:WaitForChild("PetCustomisations"):WaitForChild("EquippedPet").Value == "Robot" then
					Player.Stats.BankAccount.Value = Player.Stats.BankAccount.Value * 1.0002 -- if player has the robot pet equipped, then he has better interest rate (ability 2)
				else
					Player.Stats.BankAccount.Value = Player.Stats.BankAccount.Value * 1.0001
				end
				LeaderstatsTable["BankAccount"] = Player.Stats.BankAccount.Value
				LeaderstatsDataStore:Set(LeaderstatsTable)
			end
		end
		LeaderstatsTable["LastPlayed"] = tonumber(os.time())
		LeaderstatsDataStore:Set(LeaderstatsTable)
	end


	-- If the player has no money and has a total time played of 0, then it's a new player, thus show the tutorial
	if LeaderstatsTable["Money"] == 0 and LeaderstatsTable["TotalTimePlayed"] == 0 then
		
		Player:WaitForChild("PlayerGui"):WaitForChild("Tutorial"):WaitForChild("NewPlayer").Value = true
		--TutorialRemoteEvent:FireClient(Player)
		MoneyBindableEvent:Invoke(Player, 15000, "+")

		-- Get the leaderstats because, it has been update in the money function
		LeaderstatsTable = LeaderstatsDataStore:Get(LeaderstatsTable)
	end
	Player:WaitForChild("PlayerGui"):WaitForChild("Tutorial"):WaitForChild("Loaded").Value = true


	-----------------------------------------------------------------------------------------------------


	-- SETTINGS
	SettingsTable = SettingsDataStore:Get(SettingsTable)
	Player.Settings.DisplayClock.Value = SettingsTable["DisplayClock"]
	Player.Settings.TransparentClock.Value = SettingsTable["TransparentClock"]
	Player.Settings.DisplayHappyBirthday.Value = SettingsTable["DisplayHappyBirthday"]
	Player.Settings.DisplayVehicleKeyHelp.Value = SettingsTable["DisplayVehicleKeyHelp"]
	Player.Settings.BusStopBeam.Value = SettingsTable["BusStopBeam"]
	Player.Settings.DeliveryHouseBeam.Value = SettingsTable["DeliveryHouseBeam"]
	-- remove the delivery house beam and change it with a new one (not needed because the player sets the gps)


	-----------------------------------------------------------------------------------------------------


	-- PETS

	local SavedPetsData = PetsDataStore:Get(DefaultPetTable)
	
	if SavedPetsData then -- divide the table in two tables (one for the pets owned and one for the customisations)
		OwnedPetTable = SavedPetsData["OwnedPetTable"]
		PetCustomisationTable = SavedPetsData["PetCustomisationTable"]
	end

	PetSaveBindableEvent:Fire(Player, "PetsScript", OwnedPetTable, PetCustomisationTable)
	PetCustomisationRemoteEvent:FireClient(Player, "Load", PetCustomisationTable) -- fire client to equip the pet and the customisations


	if PetCustomisationTable and next(PetCustomisationTable) ~= nil then -- if table is not empty (otherwise it causes issues)

		if PetCustomisationTable["Rename"] ~= nil then
			Player.PetCustomisations.PetName.Value = PetCustomisationTable["Rename"]
		end

		if PetCustomisationTable["RenameColorSelected"] and PetCustomisationTable["RenameColorSelected"] ~= "" then
			if PetCustomisationTable["RenameColorSelected"] ~= "Multicolor" then
				local RenameTable = string.split(PetCustomisationTable["RenameColorSelected"], ",")
				Player.PetCustomisations.RenameColor.Value = Color3.new(RenameTable[1], RenameTable[2], RenameTable[3])
			else
				Player.PetCustomisations.MulticolorRename.Value = true
				Player.PetCustomisations.RenameColor.Value = Color3.new(1,1,1)
			end
		else
			Player.PetCustomisations.RenameColor.Value = Color3.new(1,1,1)
		end

		if PetCustomisationTable["Trail"] and PetCustomisationTable["Trail"] ~= false then
			Player.PetCustomisations.Trail.Value = true
			if PetCustomisationTable["Trail"] == "Multicolor" then
				Player.PetCustomisations.MulticolorTrail.Value = true
				Player.PetCustomisations.TrailColor.Value = Color3.new(1,1,1)
			else
				local TrailTable = string.split(PetCustomisationTable["Trail"], ",")
				Player.PetCustomisations.TrailColor.Value = Color3.new(TrailTable[1], TrailTable[2], TrailTable[3])
			end		
		end

		if PetCustomisationTable["Sparkles"] and PetCustomisationTable["Sparkles"] ~= false then
			Player.PetCustomisations.Sparkles.Value = true
			if PetCustomisationTable["Sparkles"] == "Multicolor" then
				Player.PetCustomisations.MulticolorSparkles.Value = true
				Player.PetCustomisations.SparklesColor.Value = Color3.new(1,1,1)
			else
				local SparklesTable = string.split(PetCustomisationTable["Sparkles"], ",")
				Player.PetCustomisations.SparklesColor.Value = Color3.new(SparklesTable[1], SparklesTable[2], SparklesTable[3])
			end		
		end
	end


	-----------------------------------------------------------------------------------------------------


	-- CARS

	CarsTable = CarsDataStore:Get(CarsTable)

	for i=1,30 do -- loop through every single bool values in the car folder to change their values by the saved ones
		if Player.Cars:FindFirstChild("Car"..i) then
			Player.Cars["Car"..i].Value = CarsTable["Car"..i]
		end
	end


	-----------------------------------------------------------------------------------------------------	


	-- LUMBERJACK

	LumberjackTable = LumberjackDataStore:Get(LumberjackTable)
	LumberjackTable["Tools"]["WoodenAxe"] = true
	Player.Lumberjack.Tools.StoneAxe.Value = LumberjackTable["Tools"]["StoneAxe"] -- value for the tools the player owns
	Player.Lumberjack.Tools.IronAxe.Value = LumberjackTable["Tools"]["IronAxe"]
	Player.Lumberjack.Tools.SteelAxe.Value = LumberjackTable["Tools"]["SteelAxe"]
	Player.Lumberjack.Tools.DiamondAxe.Value = LumberjackTable["Tools"]["DiamondAxe"]
	Player.Lumberjack.Tools.Shears.Value = LumberjackTable["Tools"]["Shears"]
	Player.Lumberjack.Tools.Basket.Value = LumberjackTable["Tools"]["Basket"]
	Player.Lumberjack.Tools.Mystree.Value = LumberjackTable["Tools"]["Mystree"]

	Player.Lumberjack.Trees.Birch.Value = LumberjackTable["Trees"]["Birch"] -- values for the type of trees the player has unlocked
	Player.Lumberjack.Trees.Maple.Value = LumberjackTable["Trees"]["Maple"]
	Player.Lumberjack.Trees.PineTree.Value = LumberjackTable["Trees"]["PineTree"]
	Player.Lumberjack.Trees.AppleTree.Value = LumberjackTable["Trees"]["AppleTree"]

	Player.Lumberjack.Wood.Value = LumberjackTable["Wood"]
	Player.Lumberjack.Leaf.Value = LumberjackTable["Leaf"]
	Player.Lumberjack.Apple.Value = LumberjackTable["Apple"]
	Player.Lumberjack.TreesChoppedDown.Value = LumberjackTable["TreesChoppedDown"] -- value for the number of trees the player chopped down


	-----------------------------------------------------------------------------------------------------


	-- FISHING

	FishingTable = FishingDataStore:Get(FishingTable)

	Player.Fishing.Rods.GraphiteRod.Value = FishingTable["Rods"]["GraphiteRod"] -- value for the rods the player owns
	Player.Fishing.Rods.AluminiumRod.Value = FishingTable["Rods"]["AluminiumRod"]
	Player.Fishing.Rods.Carrod.Value = FishingTable["Rods"]["Carrod"]

	Player.Fishing.Baits.PinkBait.Value = FishingTable["Baits"]["PinkBait"] -- value for the baits the player owns
	Player.Fishing.Baits.GreenBait.Value = FishingTable["Baits"]["GreenBait"]
	Player.Fishing.Baits.RedOrangeBait.Value = FishingTable["Baits"]["RedOrangeBait"]
	Player.Fishing.Baits.RainbowBait.Value = FishingTable["Baits"]["RainbowBait"]

	Player.Fishing.Fishes.Salmon.Value = FishingTable["Fishes"]["Salmon"] -- value for the number of fishes the player has
	Player.Fishing.Fishes.Cod.Value = FishingTable["Fishes"]["Cod"]
	Player.Fishing.Fishes.Trout.Value = FishingTable["Fishes"]["Trout"]
	Player.Fishing.Fishes.Catfish.Value = FishingTable["Fishes"]["Catfish"]
	Player.Fishing.Fishes.Eel.Value = FishingTable["Fishes"]["Eel"]
	Player.Fishing.Fishes.Pufferfish.Value = FishingTable["Fishes"]["Pufferfish"]
	Player.Fishing.Fishes.Swordfish.Value = FishingTable["Fishes"]["Swordfish"]
	Player.Fishing.Fishes.Shark.Value = FishingTable["Fishes"]["Shark"]
	Player.Fishing.Fishes.Pearl.Value = FishingTable["Fishes"]["Pearl"]


	-----------------------------------------------------------------------------------------------------

	-- FARMING	

	FarmingTable = FarmingDataStore:Get(FarmingTable)

	FarmingBindableEvent:Fire(Player, "FarmingTable", FarmingTable["FarmingTable"]) -- fire the farming bindable event to get the crops
	FarmingTable = FarmingDataStore:Get(FarmingTable)

	Player.Farming.Seeds.Wheat.Value = FarmingTable["Seeds"]["Wheat"] -- values for the number of seeds the player has
	Player.Farming.Seeds.Potato.Value = FarmingTable["Seeds"]["Potato"]
	Player.Farming.Seeds.Tomato.Value = FarmingTable["Seeds"]["Tomato"]
	Player.Farming.Seeds.Carrot.Value = FarmingTable["Seeds"]["Carrot"]

	Player.Farming.Crops.Wheat.Value = FarmingTable["Crops"]["Wheat"] -- values for the number of crops the player has
	Player.Farming.Crops.Potato.Value = FarmingTable["Crops"]["Potato"]
	Player.Farming.Crops.Tomato.Value = FarmingTable["Crops"]["Tomato"]
	Player.Farming.Crops.Carrot.Value = FarmingTable["Crops"]["Carrot"]

	Player.Farming.WateringCans.CopperWateringCan.Value = FarmingTable["WateringCans"]["CopperWateringCan"] -- values for the watering cans the player owns
	Player.Farming.WateringCans.SteelWateringCan.Value = FarmingTable["WateringCans"]["SteelWateringCan"]

	Player.Farming.Sickles.IronSickle.Value = FarmingTable["Sickles"]["IronSickle"] -- values for the sickles the player owns
	Player.Farming.Sickles.SteelSickle.Value = FarmingTable["Sickles"]["SteelSickle"]


	-----------------------------------------------------------------------------------------------------


	-- MINING

	MiningTable = MiningDataStore:Get(MiningTable)

	-- Load player's mining data
	for a,b in ipairs(Player.Mining:GetChildren()) do
		for i,v in ipairs(b:GetChildren()) do

			if MiningTable[b.Name] ~= nil and MiningTable[b.Name][v.Name] ~= nil then
				v.Value = MiningTable[b.Name][v.Name]
				--else
				--	plr:Kick("Couldn't load data! Sorry for the inconvenience. Try logging back in. If the issue persists, please contact us")
				--	return
			end
		end
	end


	-----------------------------------------------------------------------------------------------------


	-- MUSIC


	MusicTable = MusicDataStore:Get(MusicTable)
	if MusicTable then

		-- Load the locked and unlocked levels
		if Player:FindFirstChild("Music") then
			for i,v in ipairs(Player.Music:GetChildren()) do
				if MusicTable[v.Name] ~= nil then
					v.Value = MusicTable[v.Name]

					if not MusicTable[v.Name] then
						Player.CompletedLevels.Value += 1
					end
					--else
					--	plr:Kick("Couldn't load data! Sorry for the inconvenience. Try logging back in. If the issue persists, please contact us")
					--	return
				end
			end
		end
	end


	-----------------------------------------------------------------------------------------------------


	-- MATHS


	local MathsTable = MathsDataStore:Get(MathsTable)
	if MathsTable then

		-- Load the bests scores of the player
		if Player:FindFirstChild("Maths") and Player:FindFirstChild("Maths"):FindFirstChild("Best") and MathsTable["Best"] then
			for i,v in ipairs(Player.Maths.Best:GetChildren()) do
				if MathsTable["Best"][v.Name] then
					v.Value = MathsTable["Best"][v.Name]
					--else
					--	Player:Kick("Couldn't load data! Sorry for the inconvenience. Try logging back in. If the issue persists, please contact us")
					--	return
				end
			end
		end

		-- Load the locked and unlocked levels
		if Player:FindFirstChild("Maths") and Player:FindFirstChild("Maths"):FindFirstChild("Lock") and MathsTable["Lock"] then
			for i,v in ipairs(Player.Maths.Lock:GetChildren()) do
				if MathsTable["Lock"][v.Name] ~= nil then
					v.Value = MathsTable["Lock"][v.Name]

					if not MusicTable[v.Name] then
						Player.CompletedLevels.Value += 1
					end
					--else
					--	plr:Kick("Couldn't load data! Sorry for the inconvenience. Try logging back in. If the issue persists, please contact us")
					--	return
				end
			end
		end
	end


	-----------------------------------------------------------------------------------------------------


	-- ART 


	ArtTable = ArtDataStore:Get(ArtTable)
	if ArtTable then

		-- Load the locked and unlocked levels
		if Player:FindFirstChild("Art") then
			for i,v in ipairs(Player.Art:GetChildren()) do
				if ArtTable[v.Name] ~= nil then
					v.Value = ArtTable[v.Name]

					if not MusicTable[v.Name] then
						Player.CompletedLevels.Value += 1
					end
					--else
					--	plr:Kick("Couldn't load data! Sorry for the inconvenience. Try logging back in. If the issue persists, please contact us")
					--	return
				end
			end
		end
	end


	-----------------------------------------------------------------------------------------------------


	-- SPORT


	SportTable = SportDataStore:Get(SportTable)
	if SportTable then

		-- Load the locked and unlocked levels
		if Player:FindFirstChild("Sport") then
			for i,v in ipairs(Player.Sport:GetChildren()) do
				if SportTable[v.Name] ~= nil then
					v.Value = SportTable[v.Name]

					if not MusicTable[v.Name] then
						Player.CompletedLevels.Value += 1
					end
					--else
					--	plr:Kick("Couldn't load data! Sorry for the inconvenience. Try logging back in. If the issue persists, please contact us")
					--	return
				end
			end
		end
	end
	
	
	-----------------------------------------------------------------------------------------------------
	
	
	-- BEST STUDENT

	if Player.CompletedLevels.Value > workspace.School.BestStudent.Board.SurfaceGui.CompletedLevels.Value then
		workspace.School.BestStudent.Board.SurfaceGui.CompletedLevels.Value = Player.CompletedLevels.Value

		local content, isReady = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

		workspace.School.BestStudent.Board.SurfaceGui.Player.Image = content
		workspace.School.BestStudent.Board.SurfaceGui.StudentName.Value = Player.Name
		workspace.School.BestStudent.Board.SurfaceGui.TextLabel.Text = "Best student : "..Player.Name
	end


	-----------------------------------------------------------------------------------------------------


	-- HOUSE

	HouseTable = HouseDataStore:Get(HouseTable)

	Player.House.Tier.Value = HouseTable["Tier"]
	Player.House.Type.Value = HouseTable["Type"]

	Player.House.Colors.Balcony.Value = Color3.fromRGB(HouseTable["Colors"]["Balcony"][1], HouseTable["Colors"]["Balcony"][2], HouseTable["Colors"]["Balcony"][3])
	Player.House.Colors.Edges.Value = Color3.fromRGB(HouseTable["Colors"]["Edges"][1], HouseTable["Colors"]["Edges"][2], HouseTable["Colors"]["Edges"][3])
	Player.House.Colors.Floor.Value = Color3.fromRGB(HouseTable["Colors"]["Floor"][1], HouseTable["Colors"]["Floor"][2], HouseTable["Colors"]["Floor"][3])
	Player.House.Colors.Porch.Value = Color3.fromRGB(HouseTable["Colors"]["Porch"][1], HouseTable["Colors"]["Porch"][2], HouseTable["Colors"]["Porch"][3])
	Player.House.Colors.Roof.Value = Color3.fromRGB(HouseTable["Colors"]["Roof"][1], HouseTable["Colors"]["Roof"][2], HouseTable["Colors"]["Roof"][3])
	Player.House.Colors.Stairs.Value = Color3.fromRGB(HouseTable["Colors"]["Stairs"][1], HouseTable["Colors"]["Stairs"][2], HouseTable["Colors"]["Stairs"][3])
	Player.House.Colors.Walls.Value = Color3.fromRGB(HouseTable["Colors"]["Walls"][1], HouseTable["Colors"]["Walls"][2], HouseTable["Colors"]["Walls"][3])

	if HouseTable then
		HouseBindableEvent:Fire(Player)
	end

	
	-----------------------------------------------------------------------------------------------------
	

	-- FIRE CLIENT TO LOAD THE GUIS
	if LeaderstatsTable["Experience"] ~= nil then
		DataStoreRemoteEvent:FireClient(Player, LeaderstatsTable["Experience"], LeaderstatsTable["CasinoChip"])
	end
end)


local function SetMoney(plr, Value, LeaderstatsDataStore, LeaderstatsTable)
	plr.leaderstats.Money.Value += Value -- change the money value
	LeaderstatsTable["Money"] = plr.leaderstats.Money.Value
	LeaderstatsDataStore:Set(LeaderstatsTable) -- change the value saved in the data store
end

local function HasDoubleMoneyGamePass(plr)
	return plr.GamePasses.DoubleMoney.Value
end

local function HasDoubleExperienceGamePass(plr)
	return plr.GamePasses.DoubleXP.Value
end


local function MoneyFunction(plr, Value, Symbol) -- value = number, symbol = "+" or "-"

	local LeaderstatsDataStore = DataStore2("Leaderstats", plr)
	local LeaderstatsTable = LeaderstatsDataStore:Get(DefaultLeaderstatsTable)

	if Value and Symbol and typeof(Value) == "number" and typeof(Symbol) == "string" and LeaderstatsTable["Money"] ~= nil then
		Value = math.floor(Value * plr.Stats.MoneyMultiplier.Value)

		if Symbol == "+" then
			if HasDoubleMoneyGamePass(plr) then
				Value = math.floor(Value * 2)
			end

			-- Call the SetMoney function to change the player's money value
			SetMoney(plr, Value, LeaderstatsDataStore, LeaderstatsTable)

		elseif Symbol == "-" then
			if plr.leaderstats.Money.Value >= Value then
				-- Call the SetMoney function to change the player's money value (call it with a negavite money value to substract)
				SetMoney(plr, -Value, LeaderstatsDataStore, LeaderstatsTable)
			else
				return false
			end
		end

		MoneyRemoteEvent:FireClient(plr, Value, Symbol)
		return true
	end
end

MoneyBindableEvent.OnInvoke = MoneyFunction


-- CASINO

CasinoChipBindableEvent.Event:Connect(function(plr, Amount, Symbol)

	local LeaderstatsDataStore = DataStore2("Leaderstats", plr)
	local LeaderstatsTable = LeaderstatsDataStore:Get(DefaultLeaderstatsTable)

	if Amount and Symbol and typeof(Amount) == "number" and typeof(Symbol) == "string" and LeaderstatsTable["CasinoChip"] ~= nil then

		if Symbol == "+" then
			LeaderstatsTable["CasinoChip"] += Amount
		elseif Symbol == "-" then
			LeaderstatsTable["CasinoChip"] -= Amount
		end
		
		plr.Stats.CasinoChips.Value = LeaderstatsTable["CasinoChip"] 

		LeaderstatsDataStore:Set(LeaderstatsTable)
		MultitaskRemoteEvent:FireClient(plr, "CasinoChips", LeaderstatsTable["CasinoChip"])
	end
end)


-- EXPERIENCE

local function ExperienceFunction(plr, Job, Amount) -- job = "job", amount = value

	local LeaderstatsDataStore = DataStore2("Leaderstats", plr)
	local LeaderstatsTable = LeaderstatsDataStore:Get(DefaultLeaderstatsTable)

	if Job and Amount and typeof(Job) == "string" and typeof(Amount) == "number" and LeaderstatsTable["Experience"] ~= nil and LeaderstatsTable["Experience"][Job] ~= nil then
		local JobExperience = 0

		if LeaderstatsTable["Experience"][Job] then
			JobExperience = LeaderstatsTable["Experience"][Job]
		end

		-- MULTIPLIERS

		-- If the player has a pet that increases the farming experience (cow or pumpkin)
		if Job == "Farming" and (plr.PetCustomisations.EquippedPet.Value == "Cow" or plr.PetCustomisations.EquippedPet.Value == "Pumpkin") then
			Amount = Amount * 1.2
		end

		-- If the player has a pet that increases the delivery driver experience (donut)
		if Job == "DeliveryDriver" and plr.PetCustomisations.EquippedPet.Value == "Donut" then
			Amount = Amount * 1.2
		end

		if HasDoubleExperienceGamePass(plr) then
			Amount = math.floor(Amount * 2)
		end

		JobExperience += Amount
		LeaderstatsTable["Experience"][Job] = math.floor(JobExperience)
		LeaderstatsDataStore:Set(LeaderstatsTable)

		ExperienceRemoteEvent:FireClient(plr, Amount, Job, JobExperience)
	end
end

ExperienceBindableEvent.Event:Connect(ExperienceFunction)


-- AGE

local function AgeFunction(plr, Value, Type)

	local LeaderstatsDataStore = DataStore2("Leaderstats", plr)
	local LeaderstatsTable = LeaderstatsDataStore:Get(DefaultLeaderstatsTable)

	if Value and Type and typeof(Value) == "number" and typeof(Type) == "string" and LeaderstatsTable["Age"] ~= nil then

		if Type == "Add" then
			plr.leaderstats.Age.Value += Value -- change the age value
		elseif Type == "Set" then
			plr.leaderstats.Age.Value = Value
		end

		LeaderstatsTable["Age"] = plr.leaderstats.Age.Value
		LeaderstatsDataStore:Set(LeaderstatsTable)

		if plr.leaderstats.Age.Value == 0 then -- change the team based on the age
			plr.Team = Teams.Baby
		elseif plr.leaderstats.Age.Value == 3 then
			plr.Team = Teams.Child
		elseif plr.leaderstats.Age.Value == 18 then
			plr.Team = Teams.Adult
		elseif plr.leaderstats.Age.Value == 60 then
			plr.Team = Teams.Retired
		end
	end
end

AgeBindableEvent.Event:Connect(AgeFunction)


-- PLAYER'S BIRTHDAY

TimerBindableEvent.Event:Connect(function(plr, LastPlayed, TimePlayed, Use)

	local LeaderstatsDataStore = DataStore2("Leaderstats", plr)
	-- Set the leaderstatstable to nil first because the age bindable event is called and thus the table is changed, so use the get function to get the updated table
	local LeaderstatsTable = LeaderstatsDataStore:Get(DefaultLeaderstatsTable)

	if not Use and LeaderstatsTable["LastPlayed"] ~= nil and LeaderstatsTable["TotalTimePlayed"] ~= nil then -- if it's fired from the datastore, do not count it

		if TimePlayed >= 20 and LeaderstatsTable["TimePlayed"] ~= nil and LeaderstatsTable["TotalAge"] ~= nil and LeaderstatsTable["BankAccount"] ~= nil then -- if player has played for 20 minutes
			AgeBindableEvent:Fire(plr, 1, "Add") -- add 1 to the player age

			-- Call the get function to get the updated table after calling the age bindable event
			LeaderstatsTable = LeaderstatsDataStore:Get(DefaultLeaderstatsTable)

			LeaderstatsTable["TimePlayed"] = 0 -- reset the time the player played
			LeaderstatsTable["TotalAge"] += 1

			if plr.PetCustomisations.EquippedPet.Value == "Robot" then -- if player has the robot equipped, then he has better interest rate (ability 2)
				plr.Stats.BankAccount.Value *= 1.0002 -- doubles the money every 48 days
			else
				plr.Stats.BankAccount.Value *= 1.0001 -- doubles the money every 96 days
			end

			LeaderstatsTable["BankAccount"] = plr.Stats.BankAccount.Value -- change the bank account value in the leaderstats table

		else
			LeaderstatsTable["TimePlayed"] = TimePlayed -- save the number of minutes the player played (less than 20)		
		end

		LeaderstatsTable["LastPlayed"] = LastPlayed-- set the time the player last played to the current time
		LeaderstatsTable["TotalTimePlayed"] += 1
		LeaderstatsDataStore:Set(LeaderstatsTable) -- save the leaderstats table
	end
end)


-- BANK

BankBindableEvent.Event:Connect(function(plr, Amount, Symbol)

	local LeaderstatsDataStore = DataStore2("Leaderstats", plr)
	local LeaderstatsTable = LeaderstatsDataStore:Get(DefaultLeaderstatsTable)

	if Symbol == "+" then
		plr.Stats.BankAccount.Value += Amount
	elseif Symbol == "-" then
		plr.Stats.BankAccount.Value -= Amount
	end

	if LeaderstatsTable["BankAccount"] ~= nil then
		LeaderstatsTable["BankAccount"] = plr.Stats.BankAccount.Value
	end
	LeaderstatsDataStore:Set(LeaderstatsTable)
end)	


-- TYPING

TypingBindableEvent.Event:Connect(function(plr, FinalTime)

	local LeaderstatsDataStore = DataStore2("Leaderstats", plr)
	local LeaderstatsTable = LeaderstatsDataStore:Get(DefaultLeaderstatsTable)

	if FinalTime < plr.Stats.TypingPb.Value or plr.Stats.TypingPb.Value == 0 and LeaderstatsTable["TypingPb"] ~= nil then
		plr.Stats.TypingPb.Value = FinalTime
		LeaderstatsTable["TypingPb"] = FinalTime
		LeaderstatsDataStore:Set(LeaderstatsTable)
	end
end)	


-- RACE TRACK

RaceTrackBindableEvent.Event:Connect(function(plr, Time)

	local LeaderstatsDataStore = DataStore2("Leaderstats", plr)
	local LeaderstatsTable = LeaderstatsDataStore:Get(DefaultLeaderstatsTable)

	if Time < plr.Stats.BestRaceTime.Value or plr.Stats.BestRaceTime.Value == 0 and LeaderstatsTable["BestRaceTime"] ~= nil then
		plr.Stats.BestRaceTime.Value = Time
		LeaderstatsTable["BestRaceTime"] = Time
		LeaderstatsDataStore:Set(LeaderstatsTable)
	end
end)


-- SETTINGS

SettingsRemoteEvent.OnServerEvent:Connect(function(plr, Type, Value)

	local SettingsDataStore = DataStore2("Settings", plr)
	local SettingsTable = SettingsDataStore:Get(DefaultSettingsTable)

	if Type and Value ~= nil and typeof(Type) == "string" and typeof(Value) == "boolean" then
		if Type == "DisplayClock" and SettingsTable["DisplayClock"] ~= nil then -- if player is changing the display clock setting
			plr.Settings.DisplayClock.Value = Value -- change the value
			SettingsTable["DisplayClock"] = Value -- change the value in the table

		elseif Type == "TransparentClock" and SettingsTable["TransparentClock"] ~= nil then
			plr.Settings.TransparentClock.Value = Value
			SettingsTable["TransparentClock"] = Value

		elseif Type == "DisplayHappyBirthday" and SettingsTable["DisplayHappyBirthday"] ~= nil then
			plr.Settings.DisplayHappyBirthday.Value = Value
			SettingsTable["DisplayHappyBirthday"] = Value

		elseif Type == "DisplayVehicleKeyHelp" and SettingsTable["DisplayVehicleKeyHelp"] ~= nil then
			plr.Settings.DisplayVehicleKeyHelp.Value = Value
			SettingsTable["DisplayVehicleKeyHelp"] = Value

		elseif Type == "BusStopBeam" and SettingsTable["BusStopBeam"] ~= nil then
			plr.Settings.BusStopBeam.Value = Value
			SettingsTable["BusStopBeam"] = Value

		elseif Type == "DeliveryHouseBeam" and SettingsTable["DeliveryHouseBeam"] ~= nil then
			plr.Settings.DeliveryHouseBeam.Value = Value
			SettingsTable["DeliveryHouseBeam"] = Value
		end

		SettingsDataStore:Set(SettingsTable) -- save the table
	end
end)


-- PETS

PetSaveBindableEvent.Event:Connect(function(plr, Pickup, TableType, TableContent) -- on tables saving

	local PetsDataStore = DataStore2("Pets", plr)
	local PetTable = PetsDataStore:Get(DefaultPetTable)
	
	if Pickup == "DatastoreScript" then
		if TableType and TableContent and typeof(TableType) == "string" and typeof(TableContent) == "table" then
						
			if TableType == "Pet" then -- if table is the pets owned table
				if PetTable["OwnedPetTable"] ~= nil then
					PetTable["OwnedPetTable"] = TableContent
				end

			elseif TableType == "Customisation" then -- if table is the customisation table
				if PetTable["PetCustomisationTable"] ~= nil then
					PetTable["PetCustomisationTable"] = TableContent
				end
			end
			
			PetsDataStore:Set(PetTable)
		end
	end
end)


-- CARS

BuyCarBindableEvent.Event:Connect(function(plr, Car) -- when player has bought a car
	
	local CarsDataStore = DataStore2("Cars", plr)
	local CarsTable = CarsDataStore:Get(DefaultCarsTable)
	
	if Car and typeof(Car) == "string" and CarsTable[Car] ~= nil then
		
		if plr.Cars:FindFirstChild(Car) then
			plr.Cars[Car].Value = true -- change the value in the folder, so that other scripts know the player owns this car
		end

		CarsTable[Car] = true -- change the value in the table
		CarsDataStore:Set(CarsTable)
	end
end)


-- LUMBERJACK

LumberjackBindableEvent.Event:Connect(function(plr, Type, Param1, Param2)

	local LumberjackDataStore = DataStore2("Lumberjack", plr)
	local LumberjackTable = LumberjackDataStore:Get(DefaultLumberjackTable)

	if Param1 and Param2 then
		if Type == "Buy" then -- if player bought a tool
			local Tool = Param1 -- the first argument is the tool

			if LumberjackTable["Tools"] ~= nil and LumberjackTable["Tools"][Tool] == false then -- if the player doesn't already own the tool
				LumberjackTable["Tools"][Tool] = true -- change the value to true (because the player owns it)
			end
			LumberjackDataStore:Set(LumberjackTable) -- save the table

		elseif Type == "Sell" then -- if the player is selling an item
			local Item = Param1 -- get the item the player is selling

			if LumberjackTable[Item] ~= nil and plr.Lumberjack:FindFirstChild(Item) then
				LumberjackTable[Item] = plr.Lumberjack[Item].Value -- change the number of items the player has in the table
			end
			LumberjackDataStore:Set(LumberjackTable) -- save the table

		elseif Type == "Item" then
			local Item = Param1
			local Amount = Param2

			if Item == "All" and LumberjackTable["Wood"] ~= nil and LumberjackTable["Leaf"] ~= nil and LumberjackTable["Apple"] ~= nil then -- when using the mystree, save all values (using 1 event rather than 3)
				LumberjackTable["Wood"] = plr.Lumberjack.Wood.Value
				LumberjackTable["Leaf"] = plr.Lumberjack.Leaf.Value
				LumberjackTable["Apple"] = plr.Lumberjack.Apple.Value

			else
				if plr.Lumberjack:FindFirstChild(Item) and LumberjackTable[Item] ~= nil then
					LumberjackTable[Item] = plr.Lumberjack[Item].Value -- change the item value in the table
				end
			end

			LumberjackDataStore:Set(LumberjackTable)

		elseif Type == "TreeChoppedDown" and LumberjackTable["TreesChoppedDown"] ~= nil then
			LumberjackTable["TreesChoppedDown"] = plr.Lumberjack.TreesChoppedDown.Value -- change the tree chopped down value in the table
			LumberjackDataStore:Set(LumberjackTable) -- save the table

		elseif Type == "UnlockTree" then
			local Tree = Param1
			if LumberjackTable["Trees"] ~= nil and LumberjackTable["Trees"][Tree] == false and plr.Lumberjack.Trees:FindFirstChild(Tree) then
				LumberjackTable["Trees"][Tree] = plr.Lumberjack.Trees:FindFirstChild(Tree).Value -- change the tree locked value
				LumberjackDataStore:Set(LumberjackTable) -- save the table
			end
		end
	end
end)


-- FISHING

FishingBindableEvent.Event:Connect(function(plr, Type, Param1, Param2)

	local FishingDataStore = DataStore2("Fishing", plr)
	local FishingTable = FishingDataStore:Get(DefaultFishingTable)

	if Param1 and Param2 then
		if Type == "Buy" then
			local ToolType = Param1
			local Tool = Param2

			if FishingTable[ToolType] ~= nil and FishingTable[ToolType][Tool] == false then -- if the player doesn't already own the tool 
				FishingTable[ToolType][Tool] = true
				FishingDataStore:Set(FishingTable) -- save the table
			end

		elseif Type == "Sell" then
			local Fish = Param1 -- get the fish the player is selling

			if FishingTable["Fishes"] ~= nil and FishingTable["Fishes"][Fish] ~= nil and plr.Fishing.Fishes:FindFirstChild(Fish) then
				FishingTable["Fishes"][Fish] = plr.Fishing.Fishes[Fish].Value -- change the number of fishes the player has in the table
				FishingDataStore:Set(FishingTable) -- save the table
			end

		elseif Type == "FishCaught" then
			local FishCaught = Param1

			if FishingTable["Fishes"] ~= nil and FishingTable["Fishes"][FishCaught] ~= nil then -- if the fish is found in the table
				FishingTable["Fishes"][FishCaught] += 1 -- add 1 to the number of fishes the player has caught
				FishingDataStore:Set(FishingTable) -- save the table
			end
		end
	end
end)


-- FARMING

FarmingBindableEvent.Event:Connect(function(plr, Type, Param1, Param2, Param3)

	local FarmingDataStore = DataStore2("Farming", plr)
	local FarmingTable = FarmingDataStore:Get(DefaultFarmingTable)

	if Param1 then
		if Type == "Buy" and Param2 and Param3 then
			local ToolType = Param1
			local Tool = Param2
			local Amount = Param3

			if FarmingTable[ToolType] ~= nil and FarmingTable[ToolType][Tool] ~= nil then

				if ToolType == "Seeds" then -- if it's a seed, add the number of seeds the player bought
					if plr.Farming.Seeds:FindFirstChild(Tool) then
						FarmingTable[ToolType][Tool] = plr.Farming.Seeds[Tool].Value
					end

				else -- if it's a watering can or a sickle, change the bool value
					if FarmingTable[ToolType][Tool] == false then -- if the player doesn't already own the tool
						FarmingTable[ToolType][Tool] = true
					end
				end

			end

		elseif Type == "Sell" then
			local Crop = Param1

			if FarmingTable["Crops"] ~= nil and FarmingTable["Crops"][Crop] ~= nil and plr.Farming.Crops:FindFirstChild(Crop) then -- if the crop was found
				FarmingTable["Crops"][Crop] = plr.Farming.Crops[Crop].Value -- change the amount of crops the player has
			end

			-- Player plants a crop
		elseif Type == "Plant" and Param2 and Param3 then
			local Column = Param1
			local Row = Param2
			local Crop = Param3
			
			--if Column and Row and Crop and FarmingTable["FarmingTable"] ~= nil and FarmingTable["FarmingTable"][Column] ~= nil and FarmingTable["FarmingTable"][Column][tostring(Row)] ~= nil then
			if Column and Row and Crop and FarmingTable["FarmingTable"] ~= nil and FarmingTable["FarmingTable"][Column] ~= nil and FarmingTable["FarmingTable"][Column] then
				FarmingTable["FarmingTable"][Column][tostring(Row)] = {Crop = Crop, Stage = 0, Watered = false} -- add the crop to the table
				
				if FarmingTable["Seeds"][Crop] and plr.Farming.Seeds:FindFirstChild(Crop) then
					FarmingTable["Seeds"][Crop] = plr.Farming.Seeds[Crop].Value
				end
			end

		elseif Type == "Water" then
			local WaterTable = Param1
			
			for i,v in pairs(WaterTable) do
				if FarmingTable["FarmingTable"] ~= nil and FarmingTable["FarmingTable"][v[2]] ~= nil and FarmingTable["FarmingTable"][v[2]][v[1]] ~= nil and FarmingTable["FarmingTable"][v[2]][v[1]]["Watered"] ~= nil then -- if the crop has been found in the table
					FarmingTable["FarmingTable"][v[2]][v[1]]["Watered"] = true -- set the watered value to true so that when the player joins the game, the game knows if the tile should grow
				end				
			end

			-- A crop has grown
		elseif Type == "Grow" and Param2 and Param3 then
			local Column = Param1
			local Row = Param2
			local Stage = Param3

			if Column and Row and Stage and FarmingTable["FarmingTable"] ~= nil and FarmingTable["FarmingTable"][Column] ~= nil and FarmingTable["FarmingTable"][Column][Row] ~= nil and FarmingTable["FarmingTable"][Column][Row]["Stage"] ~= nil then -- if the crop has been found in the table
				FarmingTable["FarmingTable"][Column][Row]["Stage"] = Stage -- change the stage of the crop in the table
			end	

			-- Player harvests a crop
		elseif Type == "Harvest" then
			local HarvestTable = Param1

			for i,v in pairs(HarvestTable) do
				if FarmingTable["FarmingTable"] ~= nil and FarmingTable["FarmingTable"][v[2]] ~= nil and FarmingTable["FarmingTable"][v[2]][v[1]] ~= nil then -- if the crop has been found in the table
					FarmingTable["FarmingTable"][v[2]][v[1]] = nil -- remove the crop from the table
				end				
			end

			for i,v in pairs(FarmingTable["Crops"]) do
				if plr.Farming.Crops:FindFirstChild(i) then
					FarmingTable["Crops"][i] = plr.Farming.Crops[i].Value 
				end
			end
		end
	end
	
	FarmingDataStore:Set(FarmingTable) -- save the table
end)


-- MINING

-- Save player's mining data
MiningBindableEvent.Event:Connect(function(plr, Type, Ore)

	local MiningDataStore = DataStore2("Mining", plr)
	local MiningTable = MiningDataStore:Get(DefaultMiningTable)

	if Type and Ore and MiningTable[Type] ~= nil and MiningTable[Type][Ore] ~= nil and plr.Mining:FindFirstChild(Type) and plr.Mining[Type]:FindFirstChild(Ore) then
		MiningTable[Type][Ore] = plr.Mining[Type][Ore].Value
		MiningDataStore:Set(MiningTable)
	end
end)


-- MUSIC

MusicBindableEvent.Event:Connect(function(plr, Level)

	local MusicDataStore = DataStore2("Music", plr)
	local MusicTable = MusicDataStore:Get(DefaultMusicTable)

	if Level and typeof(Level) == "number" and MusicTable["Lock"..tostring(Level)] ~= nil then
		MusicTable["Lock"..tostring(Level)] = false
		MusicDataStore:Set(MusicTable)
	end
end)


-- MATHS

MathsBindableEvent.Event:Connect(function(plr, Type, Level, Score)

	local MathsDataStore = DataStore2("Maths", plr)
	local MathsTable = MathsDataStore:Get(DefaultMathsTable)

	if Type and Level and typeof(Type) == "string" and typeof(Level) == "number" then
		
		-- Set a new best score
		if Type == "Best" and Score and typeof(Score) == "number" then
			if MathsTable["Best"] ~= nil and MathsTable["Best"]["Best"..tostring(Level)] ~= nil then
				MathsTable["Best"]["Best"..tostring(Level)] = Score
			end

		-- Unlock a level
		elseif Type == "Unlock" then
			if MathsTable["Lock"] ~= nil and MathsTable["Lock"]["Lock"..tostring(Level)] ~= nil then
				MathsTable["Lock"]["Lock"..tostring(Level)] = false
			end
		end

		MathsDataStore:Set(MathsTable)
	end
end)


-- ART

ArtBindableEvent.Event:Connect(function(plr, Level)
	
	local ArtDataStore = DataStore2("Art", plr)
	local ArtTable = ArtDataStore:Get(DefaultArtTable)

	if Level and typeof(Level) == "number" then
		if ArtTable["Lock"..tostring(Level)] ~= nil then
			ArtTable["Lock"..tostring(Level)] = false
		end
		
		ArtDataStore:Set(ArtTable)
	end
end)


-- SPORT

SportBindableEvent.Event:Connect(function(plr, Level)
	
	local SportDataStore = DataStore2("Art", plr)
	local SportTable = SportDataStore:Get(DefaultSportTable)
	
	if Level and typeof(Level) == "number" then
		if SportTable["Lock"..tostring(Level)] ~= nil then
			SportTable["Lock"..tostring(Level)] = false
		end

		SportDataStore:Set(SportTable)
	end
end)


-- HOUSE

HouseBindableEvent.Event:Connect(function(plr, Type)

	local HouseDataStore = DataStore2("Art", plr)
	local HouseTable = HouseDataStore:Get(DefaultHouseTable)

	if Type and typeof(Type) == "string" then

		if Type == "Upgrade" then
			if HouseTable["Tier"] ~= nil then
				HouseTable["Tier"] = plr.House.Tier.Value
			end

		elseif Type == "Color" and HouseTable["Colors"] ~= nil then

			if workspace.Houses:FindFirstChild(plr.Name) then
				for i,v in ipairs(plr.House.Colors:GetChildren()) do
					if HouseTable["Colors"][v.Name] ~= nil then
						HouseTable["Colors"][v.Name] = {v.Value.R * 255, v.Value.G * 255, v.Value.B * 255}
					end
				end
			end
		end

		HouseDataStore:Set(HouseTable)
	end
end)