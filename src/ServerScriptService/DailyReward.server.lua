local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local CasinoChipBindableEvent = ServerStorage:WaitForChild("CasinoChip")
local ExperienceBindableEvent = ServerStorage:WaitForChild("Experience")
local DailyRewardBindableEvent = ServerStorage:WaitForChild("DailyReward")


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DailyRewardRemoteEvent = ReplicatedStorage:WaitForChild("DailyReward")

local NumberOfRewards = 43

local ShufflePossibiblities = { -- table to get a random shuffle (out of all the possible shuffles)
	Shuffle1 = {1,2,3},
	Shuffle2 = {1,3,2},
	Shuffle3 = {2,1,3},
	Shuffle4 = {2,3,1},
	Shuffle5 = {3,1,2},
	Shuffle6 = {3,2,1}
}

local DayStreakTable = {}

local PlayerList = {} -- used to store the rewards of the players

local PossibleRewards = { -- table to get a random rewards and search the RewardsDetails table to get the details of the rewards (strings are inside tables so that there is equal change to get every type of reward although there is 18x more experience reward than casino chips but same chance to get both)
	{
		"Money1",
		"Money2",
		"Money3",
		"Money4",
		"Money5",
		"Money6",
		"Money7",
		"Money8",
		"Money9",
		"Money10",
		"Money11"
	},

	{
		"CasinoChip1",
		"CasinoChip2",
		"CasinoChip3",
		"CasinoChip4",
		"CasinoChip5",
		"CasinoChip6",
		"CasinoChip7",
		"CasinoChip8",
		"CasinoChip9",
		"CasinoChip10",
		"CasinoChip11",
		"CasinoChip12",
		"CasinoChip13",
		"CasinoChip14",
		"CasinoChip15"
	},

	{
		"BusDriverExperience1",
		"BusDriverExperience2",
		"BusDriverExperience3",
		"BusDriverExperience4",

		"DeliveryDriverExperience1",
		"DeliveryDriverExperience2",
		"DeliveryDriverExperience3",
		"DeliveryDriverExperience4",

		"FactoryWorker1",
		"FactoryWorker2",
		"FactoryWorker3",
		"FactoryWorker4",

		"Farmer1",
		"Farmer2",
		"Farmer3",
		"Farmer4",

		"Fisherman1",
		"Fisherman2",
		"Fisherman3",
		"Fisherman4",

		"Lumberjack1",
		"Lumberjack2",
		"Lumberjack3",
		"Lumberjack4",

		"Miner1",
		"Miner2",
		"Miner3",
		"Miner4",

		"Thief1",
		"Thief2",
		"Thief3",
		"Thief4",

		"Typist1",
		"Typist2",
		"Typist3",
		"Typist4",
		
		"Hunter1",
		"Hunter2",
		"Hunter3",
		"Hunter4",
		
		"Racer1",		
		"Racer2",		
		"Racer3",		
		"Racer4"
	}
}

local RewardsDetails = { -- used to get the image and the name that should be displayed (can't use a single table because it is a dictionnary and you can't get a random number in a dictionnary)
	-- put all the rewards here with format : NameOfTheReward = {NameOfTheImageToClone (string), TextToDisplayUnderTheImage (string), ColorToUse (Color3)}

	Money1 = {
		"Money", -- name of the image in the frame (to clone it)
		"$1000", -- text to display under the image
		Color3.fromRGB(34, 125, 45), -- color for the outline and the text
		1, -- index to indentify the type of reward (1 = money, 2 = casino chips and 3 = experience)
		1000 -- amonut of money to give the player
	},
	Money2 = {
		"Money",
		"$2500",
		Color3.fromRGB(34, 125, 45),
		1,
		2500
	},
	Money3 = {
		"Money",
		"$5000",
		Color3.fromRGB(34, 125, 45),
		1,
		5000
	},
	Money4 = {
		"Money",
		"$7500",
		Color3.fromRGB(34, 125, 45),
		1,
		7500
	},
	Money5 = {
		"Money",
		"$10000",
		Color3.fromRGB(34, 125, 45),
		1,
		10000
	},
	Money6 = {
		"Money",
		"$12500",
		Color3.fromRGB(34, 125, 45),
		1,
		12500
	},
	Money7 = {
		"Money",
		"$15000",
		Color3.fromRGB(34, 125, 45),
		1,
		15000
	},
	Money8 = {
		"Money",
		"$17500",
		Color3.fromRGB(34, 125, 45),
		1,
		17500
	},
	Money9 = {
		"Money",
		"$20000",
		Color3.fromRGB(34, 125, 45),
		1,
		20000
	},
	Money10 = {
		"Money",
		"$25000",
		Color3.fromRGB(34, 125, 45),
		1,
		25000
	},
	Money11 = {
		"Money",
		"$30000",
		Color3.fromRGB(34, 125, 45),
		1,
		30000
	},
	
	
	CasinoChip1 = {
		"CasinoChip",
		"+1",
		Color3.fromRGB(75, 75, 75),
		2, -- index corresponding to the casino chips
		1 -- number of casino chips the player should receive
	},
	CasinoChip2 = {
		"CasinoChip",
		"+2",
		Color3.fromRGB(75, 75, 75),
		2,
		2
	},
	CasinoChip3 = {
		"CasinoChip",
		"+3",
		Color3.fromRGB(75, 75, 75),
		2,
		3
	},
	CasinoChip4 = {
		"CasinoChip",
		"+4",
		Color3.fromRGB(75, 75, 75),
		2,
		4
	},
	CasinoChip5 = {
		"CasinoChip",
		"+5",
		Color3.fromRGB(75, 75, 75),
		2,
		5
	},
	CasinoChip6 = {
		"CasinoChip",
		"+6",
		Color3.fromRGB(75, 75, 75),
		2,
		6
	},
	CasinoChip7 = {
		"CasinoChip",
		"+7",
		Color3.fromRGB(75, 75, 75),
		2,
		7
	},
	CasinoChip8 = {
		"CasinoChip",
		"+8",
		Color3.fromRGB(75, 75, 75),
		2,
		8
	},
	CasinoChip9 = {
		"CasinoChip",
		"+9",
		Color3.fromRGB(75, 75, 75),
		2,
		9
	},
	CasinoChip10 = {
		"CasinoChip",
		"+10",
		Color3.fromRGB(75, 75, 75),
		2,
		10
	},
	CasinoChip11 = {
		"CasinoChip",
		"+11",
		Color3.fromRGB(75, 75, 75),
		2,
		11
	},
	CasinoChip12 = {
		"CasinoChip",
		"+12",
		Color3.fromRGB(75, 75, 75),
		2,
		12
	},
	CasinoChip13 = {
		"CasinoChip",
		"+13",
		Color3.fromRGB(75, 75, 75),
		2,
		13
	},
	CasinoChip14 = {
		"CasinoChip",
		"+14",
		Color3.fromRGB(75, 75, 75),
		2,
		14
	},
	CasinoChip15 = {
		"CasinoChip",
		"+15",
		Color3.fromRGB(75, 75, 75),
		2,
		15
	},

	BusDriverExperience1 = {
		"BusDriverExperience", 
		"¤1000",
		Color3.fromRGB(47, 130, 182),
		3, -- index corresponding to the experience
		"BusDriver", -- job to fire the event
		1000 -- amount of experience to give to the player
	},
	BusDriverExperience2 = {
		"BusDriverExperience", 
		"¤2500",
		Color3.fromRGB(47, 130, 182),
		3,
		"BusDriver",
		2500
	},
	BusDriverExperience3 = {
		"BusDriverExperience", 
		"¤5000",
		Color3.fromRGB(47, 130, 182),
		3,
		"BusDriver",
		5000
	},
	BusDriverExperience4 = {
		"BusDriverExperience", 
		"¤10000",
		Color3.fromRGB(47, 130, 182),
		3,
		"BusDriver",
		10000
	},

	DeliveryDriverExperience1 = {
		"DeliveryDriverExperience", 
		"¤1000",
		Color3.fromRGB(47, 130, 182),
		3,
		"DeliveryDriver",
		1000
	},
	DeliveryDriverExperience2 = {
		"DeliveryDriverExperience", 
		"¤2500",
		Color3.fromRGB(47, 130, 182),
		3,
		"DeliveryDriver",
		2500
	},
	DeliveryDriverExperience3 = {
		"DeliveryDriverExperience", 
		"¤5000",
		Color3.fromRGB(47, 130, 182),
		3,
		"DeliveryDriver",
		5000
	},
	DeliveryDriverExperience4 = {
		"DeliveryDriverExperience", 
		"¤10000",
		Color3.fromRGB(47, 130, 182),
		3,
		"DeliveryDriver",
		10000
	},

	FactoryWorker1 = {
		"FactoryWorkerExperience", 
		"¤1000",
		Color3.fromRGB(47, 130, 182),
		3,
		"FactoryWorker",
		1000
	},
	FactoryWorker2 = {
		"FactoryWorkerExperience", 
		"¤2500",
		Color3.fromRGB(47, 130, 182),
		3,
		"FactoryWorker",
		2500
	},
	FactoryWorker3 = {
		"FactoryWorkerExperience", 
		"¤5000",
		Color3.fromRGB(47, 130, 182),
		3,
		"FactoryWorker",
		5000
	},
	FactoryWorker4 = {
		"FactoryWorkerExperience", 
		"¤10000",
		Color3.fromRGB(47, 130, 182),
		3,
		"FactoryWorker",
		10000
	},

	Farmer1 = {
		"FarmerExperience", 
		"¤1000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Farmer",
		1000
	},
	Farmer2 = {
		"FarmerExperience", 
		"¤2500",
		Color3.fromRGB(47, 130, 182),
		3,
		"Farmer",
		2500
	},
	Farmer3 = {
		"FarmerExperience", 
		"¤5000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Farmer",
		5000
	},
	Farmer4 = {
		"FarmerExperience", 
		"¤10000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Farmer",
		10000
	},

	Fisherman1 = {
		"FishermanExperience", 
		"¤1000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Fisherman",
		1000
	},
	Fisherman2 = {
		"FishermanExperience", 
		"¤2500",
		Color3.fromRGB(47, 130, 182),
		3,
		"Fisherman",
		2500
	},
	Fisherman3 = {
		"FishermanExperience", 
		"¤5000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Fisherman",
		5000
	},
	Fisherman4 = {
		"FishermanExperience", 
		"¤10000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Fisherman",
		10000
	},

	Lumberjack1 = {
		"LumberjackExperience", 
		"¤1000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Lumberjack",
		1000
	},
	Lumberjack2 = {
		"LumberjackExperience", 
		"¤2500",
		Color3.fromRGB(47, 130, 182),
		3,
		"Lumberjack",
		2500
	},
	Lumberjack3 = {
		"LumberjackExperience", 
		"¤5000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Lumberjack",
		5000
	},
	Lumberjack4 = {
		"LumberjackExperience", 
		"¤10000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Lumberjack",
		10000
 	},

	Miner1 = {
		"MinerExperience", 
		"¤1000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Miner",
		1000
	},
	Miner2 = {
		"MinerExperience", 
		"¤2500",
		Color3.fromRGB(47, 130, 182),
		3,
		"Miner",
		2500
	},
	Miner3 = {
		"MinerExperience", 
		"¤5000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Miner",
		5000
	},
	Miner4 = {
		"MinerExperience", 
		"¤10000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Miner",
		10000
	},

	Thief1 = {
		"ThiefExperience", 
		"¤1000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Thief",
		1000
	},
	Thief2 = {
		"ThiefExperience", 
		"¤2500",
		Color3.fromRGB(47, 130, 182),
		3,
		"Thief",
		2500
	},
	Thief3 = {
		"ThiefExperience", 
		"¤5000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Thief",
		5000
	},
	Thief4 = {
		"ThiefExperience", 
		"¤10000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Thief",
		10000
	},

	Typist1 = {
		"TypistExperience", 
		"¤1000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Typist",
		1000
	},
	Typist2 = {
		"TypistExperience", 
		"¤2500",
		Color3.fromRGB(47, 130, 182),
		3,
		"Typist",
		2500
	},
	Typist3 = {
		"TypistExperience", 
		"¤5000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Typist",
		5000
	},
	Typist4 = {
		"TypistExperience", 
		"¤10000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Typist",
		10000
	},
	
	Hunter1 = {
		"HunterExperience", 
		"¤1000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Hunter",
		1000
	},
	Hunter2 = {
		"HunterExperience", 
		"¤2500",
		Color3.fromRGB(47, 130, 182),
		3,
		"Hunter",
		2500
	},
	Hunter3 = {
		"HunterExperience", 
		"¤5000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Hunter",
		5000
	},
	Hunter4 = {
		"HunterExperience", 
		"¤10000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Hunter",
		10000
	},

	Racer1 = {
		"RacerExperience", 
		"¤1000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Racer",
		1000
	},
	Racer2 = {
		"RacerExperience", 
		"¤2500",
		Color3.fromRGB(47, 130, 182),
		3,
		"Racer",
		2500
	},
	Racer3 = {
		"RacerExperience", 
		"¤5000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Racer",
		5000
	},
	Racer4 = {
		"RacerExperience", 
		"¤10000",
		Color3.fromRGB(47, 130, 182),
		3,
		"Racer",
		10000
	},
}


-- FIRED FROM THE DATASTORE TO MAKE THE PLAYER GET HIS DAILY REWARD

DailyRewardBindableEvent.Event:Connect(function(plr, DayStreak, BestDayStreak) -- if the player should get the daily rewards, this bindable event will be fired from the server

	if not PlayerList[plr.Name] then -- if the player hasn't received the reward yet
		PlayerList[plr.Name] = {}
		plr.PlayerGui:WaitForChild("DailyReward").Enabled = true
	end
	
	DayStreakTable[plr.Name] = DayStreak
	
	local DailyRewardGui = plr.PlayerGui:WaitForChild("DailyReward"):WaitForChild("Frame")

	for i=1,3 do -- loop 3 times for the 3 rewards
		
		local RandomRewardType = math.random(1, #PossibleRewards) -- randomly choose a reward type (money, casino chip or experience)
		
		local RandomReward = math.random(1, #PossibleRewards[RandomRewardType]) -- choose a random reward from the reward type
		
		PlayerList[plr.Name]["Rewards"..i] = PossibleRewards[RandomRewardType][RandomReward] -- store the player rewards in the player list table to know what the player should received
		local RewardImage = DailyRewardGui.Images:FindFirstChild(RewardsDetails[PossibleRewards[RandomRewardType][RandomReward]][1]) -- find the image that has been randomly picked from the table
		if RewardImage then -- if the image has been found
			RewardImage = RewardImage:Clone() -- clone the image to display it
			RewardImage.Name = "Reward"..i
			
			if DayStreak < 7 then -- if player has been playing for less than 7 days, parent the images to the image labels
				
				RewardImage.Parent = DailyRewardGui.Rewards.RewardsImages:FindFirstChild("Reward"..i) -- parent it to one of the three reward images labels
				
				DailyRewardGui.Rewards.RewardsNames:FindFirstChild("Name"..i).Text = RewardsDetails[PossibleRewards[RandomRewardType][RandomReward]][2] -- change the text that are under the images

				DailyRewardGui.Rewards.RewardsImages:FindFirstChild("Reward"..i).ImageColor3 = RewardsDetails[PossibleRewards[RandomRewardType][RandomReward]][3] -- change the color of the outline of the color3
				DailyRewardGui.Rewards.RewardsNames:FindFirstChild("Name"..i).TextColor3 = RewardsDetails[PossibleRewards[RandomRewardType][RandomReward]][3] -- change the color of the texts
				
			else -- otherwise parent it to the image buttons
				
				RewardImage.Parent = DailyRewardGui.ButtonsRewards.RewardsImages:FindFirstChild("Reward"..i) -- parent it to one of the three reward images buttons
				
				DailyRewardGui.ButtonsRewards.RewardsNames:FindFirstChild("Name"..i).Text = RewardsDetails[PossibleRewards[RandomRewardType][RandomReward]][2] -- change the text that are under the images

				DailyRewardGui.ButtonsRewards.RewardsImages:FindFirstChild("Reward"..i).ImageColor3 = RewardsDetails[PossibleRewards[RandomRewardType][RandomReward]][3] -- change the color of the outline of the color3
				DailyRewardGui.ButtonsRewards.RewardsNames:FindFirstChild("Name"..i).TextColor3 = RewardsDetails[PossibleRewards[RandomRewardType][RandomReward]][3] -- change the color of the texts
			end		
		end
	end
	
	DailyRewardGui.Rewards.RewardsNames.Name1.Size =  UDim2.new(0, DailyRewardGui.Rewards.RewardsImages.Reward1.AbsoluteSize.X, 0.6, 0) -- change the offset size of the name to the absolute size of the images (so that it is aligned with the images)
	DailyRewardGui.Rewards.RewardsNames.Name2.Size =  UDim2.new(0, DailyRewardGui.Rewards.RewardsImages.Reward1.AbsoluteSize.X, 0.6, 0)
	DailyRewardGui.Rewards.RewardsNames.Name3.Size =  UDim2.new(0, DailyRewardGui.Rewards.RewardsImages.Reward1.AbsoluteSize.X, 0.6, 0)
	
	if DayStreak == 31 and BestDayStreak < 31 then -- if player has played for 1 month for the first time

		-- player has played for 1 month

	elseif DayStreak == 365 and BestDayStreak < 365 then -- if player has played for 1 year for the first time

		-- player has played for 1 year

	elseif DayStreak < 7 then -- if player has been playing for less than 7 days in a row
		DailyRewardGui.Day.Text = "Day "..tostring(DayStreak) -- display the number of days he has been playing for
		
		PlayerList[plr.Name]["Shuffle"] = ShufflePossibiblities["Shuffle"..math.random(1,6)] -- select a random shuffle to apply to the rewards of the player
		
		for i=1,3 do -- loop through the shuffled rewards

			local RewardImage = DailyRewardGui.Rewards.RewardsImages:FindFirstChild("Reward"..i) -- find each reward image and name
			local RewardName = DailyRewardGui.Rewards.RewardsNames:FindFirstChild("Name"..i)

			if RewardImage and RewardName then
				RewardImage = RewardImage:Clone() -- clone the image
				RewardImage.Parent = DailyRewardGui.ShuffledRewards.RewardsImages -- change the parent to the shuffled rewards images
				RewardImage.LayoutOrder = PlayerList[plr.Name]["Shuffle"][i] -- change the layout order to shuffle the images

				RewardName = RewardName:Clone() -- clone the name
				RewardName.Parent = DailyRewardGui.ShuffledRewards.RewardsNames -- change the parent to the shuffled rewards names
				RewardName.LayoutOrder = PlayerList[plr.Name]["Shuffle"][i] -- change the layout order to shuffles the names
			end
		end
		
		DailyRewardGui.Rewards.Visible = true -- show the rewards frame so that the player can randomly choose a reward
				DailyRewardRemoteEvent:FireClient(plr, PlayerList[plr.Name]["Shuffle"]) -- fire the client with the shuffle table
		
	elseif DayStreak >= 7 then -- if player has been playing for at least 7 days in a row
		DailyRewardGui.TextLabel.Text = "Choose one the following reward"
		DailyRewardGui.Day.Text = "Day 7+" -- display text : "Day 7+"
		DailyRewardGui.Choose.Visible = false
		DailyRewardGui.WaitForReward.Visible = true
		
		DailyRewardGui.ButtonsRewards.Visible = true -- show the buttons rewards frame so that the player can choose a reward
	end
end)


-- DAILY REWARD REMOTE EVENT FIRED FROM THE CLIENT

DailyRewardRemoteEvent.OnServerEvent:Connect(function(plr, ClickedReward)
	
	if PlayerList[plr.Name] then -- if the player should received reward (if datastore has fired the daily reward bindable event)

		if ClickedReward and typeof(ClickedReward) == "number" and ClickedReward >= 1 and ClickedReward <= 3 then -- check if the clicked reward is between 1 and 3
			
			local PlayerRewardDetails = 1
			
			if DayStreakTable[plr.Name] < 7 then
				PlayerRewardDetails = RewardsDetails[PlayerList[plr.Name]["Rewards"..table.find(PlayerList[plr.Name]["Shuffle"], ClickedReward)]]	 -- find the details table corresponding to the shuffled reward the player clicked
			else
				PlayerRewardDetails = RewardsDetails[PlayerList[plr.Name]["Rewards"..ClickedReward]] -- get the reward corresponding to the clicked reward
			end
			
			local PlayerReward = PlayerRewardDetails[4] -- get the number index of the reward

			if PlayerReward == 1 then -- if player got the money reward
				MoneyBindableFunction:Invoke(plr, PlayerRewardDetails[5], "+") -- fire the money bindable function with the money corresponding to the reward in the table

			elseif PlayerReward == 2 then -- if player got the casino chips reward
				CasinoChipBindableEvent:Fire(plr, PlayerRewardDetails[5], "+") -- fire the casino bindable event with the number corresponding to the reward in the table1

			elseif PlayerReward == 3 then -- if player got the experience reward
				ExperienceBindableEvent:Fire(plr, PlayerRewardDetails[5], PlayerRewardDetails[6]) -- fire the experience bindable event with the job and amount corresponding to the reward in the table
			end

			PlayerList[plr.Name] = nil -- remove the player from the player list so that even if the event is fired again, the player won't get the reward

			plr.PlayerGui.DailyReward.Enabled = false
		end
	end
end)