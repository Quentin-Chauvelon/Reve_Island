local DataStoreService = game:GetService("DataStoreService")

local ServerStorage = game:GetService("ServerStorage")
local FactoryBindableEvent = ServerStorage:WaitForChild("Factory")
local RacingBindableEvent = ServerStorage:WaitForChild("RaceTrack")
local TypingBindableEvent = ServerStorage:WaitForChild("Typing")
local MoneyBindableEvent = ServerStorage:WaitForChild("Money")
local ExperienceBindableEvent = ServerStorage:WaitForChild("Experience")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LeaderboardRemoteEvent = ReplicatedStorage:WaitForChild("Leaderboard")

local PlayerList = {}


local Date = "%m/%y"
local Key = os.date(Date, os.time())

local TypingKey = "Typing/"..Key -- get the date : MM/YY

local TypingLastWeekKey = string.sub(Key, 1,2) -- get the last week from typing key
TypingLastWeekKey = tostring(tonumber(TypingLastWeekKey)-1)
TypingLastWeekKey = TypingLastWeekKey.."/%y" -- add the year
TypingLastWeekKey = "Typing/"..os.date(TypingLastWeekKey, os.time()) -- get last week date : MM/YY

--local FactoryKey = "Factory/"..Key -- get the date : MM/YY

--local FactoryLastWeekKey = string.sub(Key, 1,2) -- get the last week from typing key
--FactoryLastWeekKey = tostring(tonumber(FactoryLastWeekKey)-1)
--FactoryLastWeekKey = FactoryLastWeekKey.."/%y" -- add the year
--FactoryLastWeekKey = "Factory/"..os.date(FactoryLastWeekKey, os.time()) -- get last week date : MM/YY

local RacingKey = "Racing/"..Key -- get the date : MM/YY

local RacingLastWeekKey = string.sub(Key, 1,2) -- get the last week from typing key
RacingLastWeekKey = tostring(tonumber(RacingLastWeekKey)-1)
RacingLastWeekKey = RacingLastWeekKey.."/%y" -- add the year
RacingLastWeekKey = "Racing/"..os.date(RacingLastWeekKey, os.time()) -- get last week date : MM/YY

local Typing = DataStoreService:GetOrderedDataStore(TypingKey)
local LastWeekTyping = DataStoreService:GetOrderedDataStore(TypingLastWeekKey)
--local Factory = DataStoreService:GetOrderedDataStore(FactoryKey)
--local LastWeekFactory = DataStoreService:GetOrderedDataStore(FactoryLastWeekKey)
local Racing = DataStoreService:GetOrderedDataStore(RacingKey)
local LastWeekRacing = DataStoreService:GetOrderedDataStore(RacingLastWeekKey)
local RewardLeaderboard = DataStoreService:GetDataStore("RewardLeaderboard")


-- DISPLAY THE TYPING LEADERBOARD

local function TypingLeaderboard()
	local TypingPages = Typing:GetSortedAsync(true, 99) -- 99 players from best to worse
	local TypingTop100 = TypingPages:GetCurrentPage() -- get first page

	for rank, data in ipairs(TypingTop100) do -- loop through all players
		local Frame = workspace.ComputerRoom.Leaderboard.SurfaceGui.Frame.ScrollingFrame:FindFirstChild(rank)
		Frame.Rank.Text = rank
		local username = "Loading..."
		pcall(function()
			username = game.Players:GetNameFromUserIdAsync(data.key)
		end)
		Frame.PlayerName.Text = username
		Frame.Time.Text = (data.value/1000).."s" -- divide by 1000 because can only save integer to datastore

		if rank == 99 then
			workspace.ComputerRoom.Leaderboard.LowestTime.Value = (data.value/1000)
		end
	end

	if not TypingPages.IsFinished then
		TypingPages:AdvanceToNextPageAsync()
		TypingTop100 = TypingPages:GetCurrentPage()
		for rank, data in ipairs(TypingTop100) do -- loop through all players
			Typing:RemoveAsync(data.key)
		end
	end
end


-- LAST WEEK DATA LEADERBOARD

local function LastWeekTypingLeaderboard()
	local LastWeekTypingPages = LastWeekTyping:GetSortedAsync(true, 3) -- 3 best players last week
	local TypingTop3 = LastWeekTypingPages:GetCurrentPage() -- get first page
	
	for rank, data in ipairs(TypingTop3) do
		local LastWeekTypingGui = workspace.ComputerRoom.LastWeek.SurfaceGui.Frame
		local username = "Loading..."

		if rank == 1 then
			LastWeekTypingGui["1st"].Rank.Text = rank

			pcall(function()
				username = game.Players:GetNameFromUserIdAsync(data.key)
			end)
			LastWeekTypingGui["1st"].PlayerName.Text = username
			LastWeekTypingGui["1st"].Time.Text = (data.value/1000)

		elseif rank == 2 then
			LastWeekTypingGui["2nd"].Rank.Text = rank
			pcall(function()
				username = game.Players:GetNameFromUserIdAsync(data.key)
			end)
			LastWeekTypingGui["2nd"].PlayerName.Text = username
			LastWeekTypingGui["2nd"].Time.Text = (data.value/1000)

		elseif rank == 3 then
			LastWeekTypingGui["3rd"].Rank.Text = rank
			pcall(function()
				username = game.Players:GetNameFromUserIdAsync(data.key)
			end)
			LastWeekTypingGui["3rd"].PlayerName.Text = username
			LastWeekTypingGui["3rd"].Time.Text = (data.value/1000)
		end
	end
end

LastWeekTypingLeaderboard() -- call the function to display the top 3 best times from last week


-- REWARD LEADERBOARD

--game.Players.PlayerAdded:Connect(function(plr)
--	local RewardTypingPages = LastWeekTyping:GetSortedAsync(true, 99) -- 99 bets players last week
--	local RewardTypingTop100 = RewardTypingPages:GetCurrentPage() -- get first page
	
--	plr.CharacterAdded:Wait()
--	for rank, data in ipairs(RewardTypingTop100) do
--		if tonumber(plr.UserId) == tonumber(data.key) then

--			local MoneyToClaim = 75000
--			local ExperienceToClaim = 1500
--			-- change experience to claim (default value)
--			-- in the leaderboard local script, add the experience remote function fire
--			if rank == 1 then
--				MoneyToClaim = 500000
--				ExperienceToClaim = 20000
--			elseif rank == 2 then
--				MoneyToClaim = 350000
--				ExperienceToClaim = 15000
--			elseif rank == 3 then
--				MoneyToClaim = 250000
--				ExperienceToClaim = 10000
--			elseif rank >= 4 and rank < 11 then
--				MoneyToClaim = 175000
--				ExperienceToClaim = 7500
--			elseif rank >= 11 and rank < 26 then
--				MoneyToClaim = 125000
--				ExperienceToClaim = 5000
--			elseif rank >= 26 and rank < 51 then
--				MoneyToClaim = 100000
--				ExperienceToClaim = 3000
--			else
--				MoneyToClaim = 75000
--				ExperienceToClaim = 1500
--			end

--			LeaderboardRemoteEvent:FireClient(plr, MoneyToClaim, ExperienceToClaim, rank, "typing") -- fire client to show gui to claim money and experience
--			LastWeekTyping:RemoveAsync(data.key) -- remove data from player (so that he doesn't claim the rewards multiple times
--			break	
--		end
--	end
--end)


-- PLAYER TIME ON LEADERBOARD

TypingBindableEvent.Event:Connect(function(plr, Time)
	local UserId = plr.UserId
	local FinalTime = Time*1000 -- x1000 to get an integer
	if Time < workspace.ComputerRoom.Leaderboard.LowestTime.Value or workspace.ComputerRoom.Leaderboard.LowestTime.Value == 0 then -- if player has a better time than the 99th in the leaderboard
		
		local BestTime = nil
		local success, errormessage = pcall(function()
			BestTime = Typing:GetAsync(UserId, FinalTime) -- save player data
		end)

		if not BestTime or BestTime > FinalTime then
			pcall(function()
				Typing:SetAsync(UserId, FinalTime) -- save player data
			end)
		end
			
		TypingLeaderboard()
	end
end)


-----------------------------------------------------------------------------------------------------


---- DISPLAY THE FACTORY LEADERBOARD

--local function FactoryLeaderboard()
--	local FactoryPages = Factory:GetSortedAsync(true, 99) -- 99 players from best to worse
--	local FactoryTop100 = FactoryPages:GetCurrentPage() -- get first page

--	for rank, data in ipairs(FactoryTop100) do -- loop through all players
--		local Frame = workspace.Factory.Leaderboard.SurfaceGui.Frame.ScrollingFrame:FindFirstChild(rank)
--		Frame.Rank.Text = rank
--		local username = "Loading..."
--		pcall(function()
--			username = game.Players:GetNameFromUserIdAsync(data.key)
--		end)
--		Frame.PlayerName.Text = username
--		Frame.Points.Text = data.value

--		if rank == 99 then
--			workspace.Factory.Leaderboard.LowestTime.Value = (data.value)
--		end
--	end

--	if not FactoryPages.IsFinished then
--		FactoryPages:AdvanceToNextPageAsync()
--		FactoryTop100 = FactoryPages:GetCurrentPage()
--		for rank, data in ipairs(FactoryTop100) do -- loop through all players
--			Factory:RemoveAsync(data.key)
--		end
--	end
--end

--FactoryLeaderboard()


---- LAST WEEK DATA LEADERBOARD

--local function LastWeekFactoryLeaderboard()
--	local LastWeekFactoryPages = LastWeekFactory:GetSortedAsync(true, 3) -- 3 bets players last week
--	local FactoryTop3 = LastWeekFactoryPages:GetCurrentPage() -- get first page
	
--	for rank, data in ipairs(FactoryTop3) do
--		local LastWeekFactoryGui = workspace.Factory.LastWeek.SurfaceGui.Frame
--		local username = "Loading..."

--		if rank == 1 then
--			LastWeekFactoryGui["1st"].Rank.Text = rank

--			pcall(function()
--				username = game.Players:GetNameFromUserIdAsync(data.key)
--			end)
--			LastWeekFactoryGui["1st"].PlayerName.Text = username
--			LastWeekFactoryGui["1st"].Points.Text = (data.value)

--		elseif rank == 2 then
--			LastWeekFactoryGui["2nd"].Rank.Text = rank
--			pcall(function()
--				username = game.Players:GetNameFromUserIdAsync(data.key)
--			end)
--			LastWeekFactoryGui["2nd"].PlayerName.Text = username
--			LastWeekFactoryGui["2nd"].Points.Text = (data.value)

--		elseif rank == 3 then
--			LastWeekFactoryGui["3rd"].Rank.Text = rank
--			pcall(function()
--				username = game.Players:GetNameFromUserIdAsync(data.key)
--			end)
--			LastWeekFactoryGui["3rd"].PlayerName.Text = username
--			LastWeekFactoryGui["3rd"].Points.Text = (data.value)
--		end
--	end
--end

--LastWeekFactoryLeaderboard() -- call the function to display the top 3 best times from last week


---- PLAYER POINTS ON LEADERBOARD

--FactoryBindableEvent.Event:Connect(function(plr, Points)
--	local UserId = plr.UserId
--	if Points < workspace.Factory.Leaderboard.LowestTime.Value or workspace.Factory.Leaderboard.LowestTime.Value == 0 then -- if player has a better time than the 99th in the leaderboard
--		pcall(function()
--			Factory:SetAsync(UserId, Points) -- save player data
--		end)
--		FactoryLeaderboard()
--	end
--end)



-----------------------------------------------------------------------------------------------------


-- DISPLAY THE RACING LEADERBOARD

local function RacingLeaderboard()
	local RacingPages = Racing:GetSortedAsync(true, 99) -- 99 players from best to worse
	local RacingTop100 = RacingPages:GetCurrentPage() -- get first page

	for rank, data in ipairs(RacingTop100) do -- loop through all players
		local Frame = workspace.RaceTrack.Leaderboard.SurfaceGui.Frame.ScrollingFrame:FindFirstChild(rank)
		Frame.Rank.Text = rank
		local username = "Loading..."
		pcall(function()
			username = game.Players:GetNameFromUserIdAsync(data.key)
		end)
		Frame.PlayerName.Text = username
		Frame.Points.Text = data.value/1000

		if rank == 99 then
			workspace.RaceTrack.Leaderboard.LowestTime.Value = (data.value/1000)
		end
	end

	if not RacingPages.IsFinished then
		RacingPages:AdvanceToNextPageAsync()
		RacingTop100 = RacingPages:GetCurrentPage()
		for rank, data in ipairs(RacingTop100) do -- loop through all players
			Racing:RemoveAsync(data.key)
		end
	end
end

RacingLeaderboard()


-- LAST WEEK DATA LEADERBOARD

local function LastWeekRacingLeaderboard()
	local LastWeekRacingPages = LastWeekRacing:GetSortedAsync(true, 3) -- 3 bets players last week
	local RacingTop3 = LastWeekRacingPages:GetCurrentPage() -- get first page
	
	for rank, data in ipairs(RacingTop3) do
		local LastWeekRacingGui = workspace.RaceTrack.LastWeek.SurfaceGui.Frame
		local username = "Loading..."

		if rank == 1 then
			LastWeekRacingGui["1st"].Rank.Text = rank

			pcall(function()
				username = game.Players:GetNameFromUserIdAsync(data.key)
			end)
			LastWeekRacingGui["1st"].PlayerName.Text = username
			LastWeekRacingGui["1st"].Points.Text = (data.value/1000)

		elseif rank == 2 then
			LastWeekRacingGui["2nd"].Rank.Text = rank
			pcall(function()
				username = game.Players:GetNameFromUserIdAsync(data.key)
			end)
			LastWeekRacingGui["2nd"].PlayerName.Text = username
			LastWeekRacingGui["2nd"].Points.Text = (data.value/1000)

		elseif rank == 3 then
			LastWeekRacingGui["3rd"].Rank.Text = rank
			pcall(function()
				username = game.Players:GetNameFromUserIdAsync(data.key)
			end)
			LastWeekRacingGui["3rd"].PlayerName.Text = username
			LastWeekRacingGui["3rd"].Points.Text = (data.value/1000)
		end
	end
end

LastWeekRacingLeaderboard() -- call the function to display the top 3 best times from last week


-- PLAYER TIME ON LEADERBOARD

RacingBindableEvent.Event:Connect(function(plr, Time)
	local UserId = plr.UserId
	
	local UserId = plr.UserId
	local FinalTime = Time*1000 -- x1000 to get an integer
	if Time < workspace.RaceTrack.Leaderboard.LowestTime.Value or workspace.RaceTrack.Leaderboard.LowestTime.Value == 0 then -- if player has a better time than the 99th in the leaderboard
		
		local BestTime = nil
		local success, errormessage = pcall(function()
			BestTime = Racing:GetAsync(UserId, FinalTime) -- save player data
		end)
		
		if not BestTime or BestTime > FinalTime then
			pcall(function()
				Racing:SetAsync(UserId, FinalTime) -- save player data
			end)
		end

		RacingLeaderboard()
	end
end)


-----------------------------------------------------------------------------------------------------


-- LEADERBOARD REWARD

local Claimed = false
local MoneyToClaim = 75000
local ExperienceToClaim = 1500
local RewardJob = ""
local RewardTable = nil


local function RewardPlayer(plr)
	
	if not RewardTable then
		local success, errormessage = pcall(function()
			RewardTable = RewardLeaderboard:GetAsync(plr.UserId) -- get player reward
		end)
	end
	
	if RewardTable and RewardTable[1] then -- if player has a reward to claim
		local SplitString = string.split(RewardTable[1], "|") -- split the string to get both the rank and the job
		local RewardRank = tonumber(SplitString[1])
		RewardJob = SplitString[2]

		if RewardRank == 1 then -- get the money and experience based on the rank
			MoneyToClaim = 500000
			ExperienceToClaim = 20000
		elseif RewardRank == 2 then
			MoneyToClaim = 350000
			ExperienceToClaim = 15000
		elseif RewardRank == 3 then
			MoneyToClaim = 250000
			ExperienceToClaim = 10000
		elseif RewardRank >= 4 and RewardRank < 11 then
			MoneyToClaim = 175000
			ExperienceToClaim = 7500
		elseif RewardRank >= 11 and RewardRank < 26 then
			MoneyToClaim = 125000
			ExperienceToClaim = 5000
		elseif RewardRank >= 26 and RewardRank < 51 then
			MoneyToClaim = 100000
			ExperienceToClaim = 3000
		else
			MoneyToClaim = 75000
			ExperienceToClaim = 1500
		end

		coroutine.wrap(function()
			if not plr.Character then -- if character is not loaded, wait for it to load
				plr.CharacterAdded:Wait()
			end

			wait(3)
			LeaderboardRemoteEvent:FireClient(plr, MoneyToClaim, ExperienceToClaim, RewardRank, RewardJob) -- fire client to show gui to claim money and experience
		end)()
	end
end


game.Players.PlayerAdded:Connect(function(plr)
	RewardPlayer(plr)
end)


LeaderboardRemoteEvent.OnServerEvent:Connect(function(plr) -- when player claims his rewards
	
	local RewardJob
	if PlayerList[plr.Name] then
		if PlayerList[plr.Name] == "typing" then -- change the name of the job for the experience
			RewardJob = "Typist"
		elseif PlayerList[plr.Name] == "factory worker" then
			RewardJob = "FactoryWorker"
		elseif PlayerList[plr.Name] == "racing" then
			RewardJob = "Racer"
		end
	end
	
	table.remove(RewardTable, 1) -- remove the rank and job from the table because it is claimed
	
	pcall(function()
		RewardLeaderboard:SetAsync(plr.UserId, RewardTable) -- save table so that if player disconnects, he doesn't get the rewards twice
	end)
	
	MoneyBindableEvent:Invoke(plr, MoneyToClaim, "+") -- fire money and experience
	ExperienceBindableEvent:Fire(plr, RewardJob, ExperienceToClaim)
	
	RewardPlayer(plr)
end)

-----------------------------------------------------------------------------------------------------


-- REFRESH DATA EVERY 5 MINUTES

coroutine.wrap(function()
	while true do

		local Now = os.date("!*t", os.time()) -- get the time (UTC time)

		local Day = 31 - Now.day -- determine the number of day left in the month
		local Hours = 23 - Now.hour -- hours left
		local Minutes = 60 - Now.min -- minutes left

		if Day == 0 and Hours == 0 and Minutes < 10 then
			repeat
				TypingKey = os.date("%m/%y", os.time())
				TypingLastWeekKey = string.sub(TypingKey, 1,4) -- get the last week from TypingKey
				TypingLastWeekKey = TypingLastWeekKey.."/%y" -- add the year
				TypingLastWeekKey = os.date(TypingLastWeekKey, os.time()) -- get lastweek date : MM/YY

				Typing = DataStoreService:GetOrderedDataStore(TypingKey) 
				LastWeekTyping = DataStoreService:GetOrderedDataStore(TypingLastWeekKey)
				TypingLeaderboard()
				wait(30)
				--FactoryLeaderboard()
				--wait(30)
				Racing = DataStoreService:GetOrderedDataStore(RacingKey) 
				LastWeekRacing = DataStoreService:GetOrderedDataStore(RacingLastWeekKey)
				RacingLeaderboard()
				wait(30)
				Now = os.date("!*t", os.time())
			until Now.hour ~= 0		
		end

		Typing = DataStoreService:GetOrderedDataStore(TypingKey) 
		TypingLeaderboard()
		wait(150)
		Racing = DataStoreService:GetOrderedDataStore(RacingKey)
		RacingLeaderboard()
		wait(150)	
	end
end)()