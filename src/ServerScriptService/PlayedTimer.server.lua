local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local TimerBindableEvent = ServerStorage:WaitForChild("Timer")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local AgeBindableEvent = ServerStorage:WaitForChild("Age")
local CasinoChipBindableEvent = ServerStorage:WaitForChild("CasinoChip")
local ExperienceBindableEvent = ServerStorage:WaitForChild("Experience")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BirthdayRemoteEvent = ReplicatedStorage:WaitForChild("Birthday")
local DeathRemoteEvent = ReplicatedStorage:WaitForChild("Death")

local ExperienceJobsTable = { -- table used to be able to select a random job
	"BusDriver",
	"DeliveryDriver",
	"FactoryWorker",
	"Farmer",
	"Fisherman",
	"Lumberjack",
	"Miner",
	"Thief",
	"Typist",
	"Hunter"
}

local PlayerList = {}


-- PET SAVE FUNCTION + RETURN + CHANGE FUNCTION CALL IN THE REST OF THE SCRIPT + CLIENT ANIMATION + WILL YOUR PET SAVE YOU ?

-- 50% TO GET SAVED FROM DEATH BY THE SKELETONS PETS

local function PetSave(plr)
	
	if plr:FindFirstChild("PetCustomisations") and plr:FindFirstChild("PetCustomisations"):FindFirstChild("EquippedPet") then
		if plr.PetCustomisations.EquippedPet.Value == "SkeletonDeer" or plr.PetCustomisations.EquippedPet.Value == "SkeletonPup" then -- if player has the ninja or the skeleton pup pet equipped, then 1/2 chance of surviving 
			local RandomNumber = math.random(1,2)

			if RandomNumber == 1 then -- 50% chance to survive with the pets
				return true
			else
				return false
			end
		end
	end
end


-- EVENT FIRES WHEN A PLAYER JOINS THE GAME (FIRED FROM THE DATASTORE)

TimerBindableEvent.Event:Connect(function(plr, LastPlayed, TimePlayed)
	if not PlayerList[plr.Name] then
		PlayerList[plr.Name] = {} -- create a table for the player
		PlayerList[plr.Name]["Username"] = plr.Name -- get player's username (used to get the player)
		PlayerList[plr.Name]["LastPlayed"] = os.time() -- get the time the player last played
		PlayerList[plr.Name]["TimePlayed"] = TimePlayed -- get the number of minutes the player has played (less than 20)
	end
end)

-- WHILE LOOP TO CHECK IF THE PLAYER HAS PLAYED FOR 1 WHOLE MINUTE

while wait(5) do -- check every 5 seconds
	local Now = os.time() -- get the current time

	for i,v in pairs(PlayerList) do -- loop through every player in the player list
		
		if Now >= (v["LastPlayed"] + 60) then -- if player has played for a minute
			v["LastPlayed"] = Now -- change the time the player last played to the current time
			v["TimePlayed"] = v["TimePlayed"] + 1 -- add 1 minute to the player minute counter

			local plr = Players:FindFirstChild(v["Username"]) -- get the player
			if plr then
				
				TimerBindableEvent:Fire(plr, v["LastPlayed"], v["TimePlayed"]) -- fire the timer bindable event to save the time played and last played of the player every minute

				if v["TimePlayed"] >= 20 then -- if the player has played for 20 minutes
					v["TimePlayed"] = 0 -- reset the minute counter to 0
					
					local NewAge = plr.leaderstats.Age.Value
					
					-- DEATH

					if NewAge < 60 then -- if player is 60 or younger

						if math.random(1,20000) == 1 then -- 1 / 20000 chance of dying

							if PetSave(plr) then -- if the player got saved by his pet
								DeathRemoteEvent:FireClient(plr, 0, true)
							else
								DeathRemoteEvent:FireClient(plr, NewAge, nil) -- fire the client for the gui
								MoneyBindableFunction:Invoke(plr, ((100 - NewAge) * 1000), "+")
								AgeBindableEvent:Fire(plr, 0, "Set")
								continue
							end
						end

					elseif  NewAge >= 60 and NewAge <= 99 then-- if player is 61 or older

						local Odds = NewAge - 59
						if math.random(1,100) <= Odds then

							if PetSave(plr) then -- if the player got saved by his pet
								DeathRemoteEvent:FireClient(plr, 0, true)
							else
								DeathRemoteEvent:FireClient(plr, NewAge) -- fire the client for the gui
								MoneyBindableFunction:Invoke(plr, (2000 * Odds), "+")
								AgeBindableEvent:Fire(plr, 0, "Set")
								continue
							end
						end	

					elseif NewAge == 100 then
						DeathRemoteEvent:FireClient(plr, NewAge) -- fire the client for the gui
						MoneyBindableFunction:Invoke(plr, 150000, "+")
						AgeBindableEvent:Fire(plr, 0, "Set")
					end
					
					
					-- BIRTHDAY
					
					if Players[v["Username"]].Settings.DisplayHappyBirthday.Value then -- if the player has the display gui set to true 

						local MoneyAmount = math.random(1,5000) -- get a random amount of money between 1 and 10000
						local CasinoChipAmount = math.random(1,8) -- get a random amount of casino chips between 1 and 8
						local ExperienceJob = ExperienceJobsTable[math.random(1, #ExperienceJobsTable)] -- get a random job from the table
						local ExperienceAmount = math.random(1,1000) -- get a random amount of experience between 1 and 5000	

						BirthdayRemoteEvent:FireClient(plr, NewAge, MoneyAmount, CasinoChipAmount, ExperienceJob, ExperienceAmount)

						MoneyBindableFunction:Invoke(plr, MoneyAmount, "+") -- give the money to the player
						CasinoChipBindableEvent:Fire(plr, CasinoChipAmount, "+") -- give the casino chips to the player
						ExperienceBindableEvent:Fire(plr, ExperienceJob, ExperienceAmount) -- give the experience to the player
					end
				end
			end
		end
	end
end


-- WHEN PLAYER LEAVES

Players.PlayerRemoving:Connect(function(plr)
	PlayerList[plr.Name] = nil -- remove the player from the player list (to reduce lag (otherwise unnecessary loop through player))
end)