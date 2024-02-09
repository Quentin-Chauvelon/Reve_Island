local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local MusicBindableEvent = ServerStorage:WaitForChild("Music")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MusicRemoteFunction = ReplicatedStorage:WaitForChild("Music")

local PlayerList = {}
local LevelReward = {2000, 5000, 10000, 25000, 50000}


-- PLAYER HAS FINISHED THE GAME (EITHER CLICKED ALL THE NOTES OR GOT FORCED TO END THE GAME (IF HE WAS NOT PLAYING FOR EXAMPLE))

local function EndOfGame(plr)
	
	local Score = PlayerList[plr.Name][3]
	local Level = PlayerList[plr.Name][4]
	PlayerList[plr.Name] = nil
	
	if plr:FindFirstChild("CanDie") then
		plr.CanDie.Value = true
	end
	
	-- If the player got all the notes right (max score)
	if Score == (5 + 5 * Level) then

		local Level = Level
		if Level and typeof(Level) == "number" then

			-- Unlock level
			if plr.Music:FindFirstChild("Lock"..(tostring(Level + 1))) and plr.Music:FindFirstChild("Lock"..(tostring(Level + 1))).Value then
				plr.Music:FindFirstChild("Lock"..(tostring(Level + 1))).Value = false
				
				-- Reward the player
				if LevelReward[Level] then
					MoneyBindableFunction:Invoke(plr, LevelReward[Level], "+")
				end

				MusicBindableEvent:Fire(plr, Level+1)
			end
		end
	end
	
	return true, Score
end


-- REMOTE FUNCTION FIRED FROM THE CLIENT

MusicRemoteFunction.OnServerInvoke = function(plr, Note, Level)
	
	if not PlayerList[plr.Name] then
		-- [1] = StartTime (to check if the player is firing the remote event after the timer ran out)
		-- [2] = Song table (randomly generated song)
		-- [3] = Score (increases each time the player clicks on the correct next color)
		-- [4] = Level (level the player started the timer at)
		PlayerList[plr.Name] = {os.time(), {}, 0, Level}
		
		if plr:FindFirstChild("CanDie") then
			plr.CanDie.Value = false
		end
		
		if Level and typeof(Level) == "number" and (Level == 1 or (plr.Music:FindFirstChild("Lock"..Level) and not plr.Music:FindFirstChild("Lock"..Level).Value)) then
			
			for i=1,(5 + 5 * Level) do -- from 1 do to the length of the song which 5 + 5 * Level (1 : 10, 2 : 15..., 5 : 30) do do
				table.insert(PlayerList[plr.Name][2], math.random(1,5)) -- append a random number from 1 to 5 to the table
			end
			
			-- Make a copy of the table before reversing it
			local Song = {}
			for i,v in pairs(PlayerList[plr.Name][2]) do
				table.insert(Song, v)
			end
			
			-- Reverse the table (because when player fires the note he clicked, it is way faster to remove the last element than the first one)
			-- To reverse a table with 1000 element, it takes 8 seconds when removing the first element, 3.6 seconds when removing the middle one and 0.01 seconds when removing the last one
			for i=1,math.floor(#PlayerList[plr.Name][2]/2) do
				local j = #PlayerList[plr.Name][2] - i + 1
				PlayerList[plr.Name][2][i], PlayerList[plr.Name][2][j] = PlayerList[plr.Name][2][j], PlayerList[plr.Name][2][i]
			end
			
			return Song
		end
		
	else
		
		if Note and typeof(Note) == "string" and Note == "Stop" and PlayerList[plr.Name] then
			return EndOfGame(plr)
		end		
		
		if Note and typeof(Note) == "number" then
			
			-- If the player has not finished the song yet
			if #PlayerList[plr.Name][2] > 0 then
				
				-- If the player clicked the very next note, add 1 to his score
				if PlayerList[plr.Name][2][#PlayerList[plr.Name][2]] == Note then
					PlayerList[plr.Name][3] = PlayerList[plr.Name][3] + 1
				end
				
				-- Remove the element from the table
				table.remove(PlayerList[plr.Name][2], #PlayerList[plr.Name][2])
				
				-- If the table is empty, the player is done playing
				if #PlayerList[plr.Name][2] == 0 then
					return EndOfGame(plr)
				end
			end
		end
		
		return false, PlayerList[plr.Name][3]
	end
end