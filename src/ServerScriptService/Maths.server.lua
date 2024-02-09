local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local MathsBindableEvent = ServerStorage:WaitForChild("Maths")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MathsRemoteEvent = ReplicatedStorage:WaitForChild("Maths")

local Maths = workspace.School.Maths
local PlayerList = {}
local ScoreNeeded = {0, 8, 8, 10, 10, 10}
local LevelReward = {2000, 5000, 10000, 25000, 50000}


-- FUNCTION TO CREATE ALL THE CALCULATIONS

local function CreateCalculation(plr, Level)
	if Level == 1 then
		local Number1 = math.random(1,15)
		local Number2 = math.random(1,15)
		PlayerList[plr.Name][2] = Number1 + Number2
		return tostring(Number1).." + "..tostring(Number2), PlayerList[plr.Name][3]

	elseif Level == 2 then
		local Number1 = math.random(1,10)
		local Number2 = math.random(1,10)
		PlayerList[plr.Name][2] = Number1 * Number2
		return tostring(Number1).." x "..tostring(Number2), PlayerList[plr.Name][3]

	elseif Level == 3 then
		local Number1 = math.random(1,15)
		local Number2 = math.random(1,15)
		PlayerList[plr.Name][2] = Number1 * Number2
		return tostring(Number1).." x "..tostring(Number2), PlayerList[plr.Name][3]

	elseif Level == 4 then
		local Number1 = math.random(1,10)
		local Number2 = math.random(1,10)
		local Number3 = math.random(1,10)
		PlayerList[plr.Name][2] = Number1 * Number2 * Number3
		return tostring(Number1).." x "..tostring(Number2).." x "..tostring(Number3), PlayerList[plr.Name][3]

	elseif Level == 5 then
		local Number1 = math.random(1,15)
		local Number2 = math.random(1,15)
		local Number3 = math.random(1,15)
		PlayerList[plr.Name][2] = Number1 * Number2 * Number3
		return tostring(Number1).." x "..tostring(Number2).." x "..tostring(Number3), PlayerList[plr.Name][3]

	end
end


-- MATHS REMOTE EVENT FIRED FROM THE CLIENT

MathsRemoteEvent.OnServerInvoke = function(plr, Answer, Level)
	
	-- Start the game
	if not PlayerList[plr.Name] then
		-- [1] = StartTime (to check if the player is firing the remote event after the timer ran out)
		-- [2] = Answer (answer to the calculation that was last fired to the client and so, when the client calls the server, it checks if the answer is correct)
		-- [3] = Score (increases each time the player fires the server with a correct answer)
		-- [4] = Level (level the player started the timer at)
		PlayerList[plr.Name] = {os.time(), 0, 0, Level}
		
		plr.PlayerGui.Maths.Board.IsPlaying.Value = true -- value can be read by the client to know if the player is done playing (makes the client wait to restart if he is not playing)
		
		if plr:FindFirstChild("CanDie") then
			plr.CanDie.Value = false
		end
		
		if Level and typeof(Level) == "number" and plr.Maths.Lock:FindFirstChild("Lock"..Level) and not plr.Maths.Lock:FindFirstChild("Lock"..Level).Value then
			-- Choose a random calculation and return the calculation and the score
			return CreateCalculation(plr, Level)
		end
	else
		-- Change the level value in case the player would start at level 1 and at the very end would fire a level 5 to complete the last level
		Level = PlayerList[plr.Name][4]
		
		-- End the game
		if PlayerList[plr.Name][1] + 32 < os.time()  then
			
			local Score = PlayerList[plr.Name][3]
			Level = PlayerList[plr.Name][4]
			PlayerList[plr.Name] = nil
			plr.PlayerGui.Maths.Board.IsPlaying.Value = false -- player can now restart
			
			if plr:FindFirstChild("CanDie") then
				plr.CanDie.Value = true
			end

			-- If player has beaten his best score
			if Level and typeof(Level) == "number" then
				if plr.Maths.Best:FindFirstChild("Best"..tostring(Level)) and Score > plr.Maths.Best:FindFirstChild("Best"..tostring(Level)).Value then
					plr.Maths.Best:FindFirstChild("Best"..tostring(Level)).Value = Score
					
					MathsBindableEvent:Fire(plr, "Best", Level, Score) -- fire the datastore to save the best score
				end
				
				-- If the player has got a score that is enough to unlock the next level
				if ScoreNeeded[Level+1] and Score >= ScoreNeeded[Level+1] then

					-- Unlock level
					if plr.Maths.Lock:FindFirstChild("Lock"..(tostring(Level+1))) then
						plr.Maths.Lock:FindFirstChild("Lock"..(tostring(Level+1))).Value = false
					end

					if LevelReward[Level] then
						MoneyBindableFunction:Invoke(plr, LevelReward[Level], "+")
					end

					MathsBindableEvent:Fire(plr, "Unlock", Level+1) -- fire the datastore to save the unlocked level
				end
			end
			
			return "", Score
			
		else
			-- If the player gave the correct answer
			if Answer and typeof(Answer) == "number" and PlayerList[plr.Name][2] == Answer then
				PlayerList[plr.Name][3] += 1
			end
			
			if Level and typeof(Level) == "number" then
				-- Choose a random calculation and return the calculation and the score
				return CreateCalculation(plr, Level)
			end
		end
	end
	
	return "", PlayerList[plr.Name][3]
end