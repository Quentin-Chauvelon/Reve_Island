local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local SportBindableEvent = ServerStorage:WaitForChild("Sport")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DanceRemoteFunction = ReplicatedStorage:WaitForChild("Dance")

local Dance = workspace.School.Dance

local PlayerList = {}


-- DANCE REMOTE FUNCTION FIRED FROM THE CLIENT (WHEN PLAYER CLICKS AN ARROW)

DanceRemoteFunction.OnServerInvoke = function(plr, Arrow)
	
	-- Start the game
	if not PlayerList[plr.Name] then
		-- [1] = StartTime (to check if the player is firing the remote event after the timer ran out)
		-- [2] = NextArrow (the next arrow the player should fire the event with)
		-- [3] = Score (increases each time the player fires the server with a correct arrow)
		PlayerList[plr.Name] = {os.time(), math.random(1,4), 0, 0}

		plr.PlayerGui.Dance.IsPlaying.Value = true -- value can be read by the client to know if the player is done playing (makes the client wait to restart if he is not playing)
		
		if plr:FindFirstChild("CanDie") then
			plr.CanDie.Value = false
		end

		return PlayerList[plr.Name][2], PlayerList[plr.Name][3] -- return the next arrow the player should press
		
	-- If the player already started a game
	else

		-- End the game
		if PlayerList[plr.Name][1] + 22 < os.time()  then
			
			local Score = PlayerList[plr.Name][3]
			PlayerList[plr.Name] = nil
			plr.PlayerGui.Dance.IsPlaying.Value = false -- player can now restart

			if plr:FindFirstChild("CanDie") then
				plr.CanDie.Value = true
			end
			
			if Score > 20 and not plr.Sport.Lock2.Value and plr.Sport.Lock3.Value then -- check if level 2 is unlocked in case an exploiter would fire the event without unlocking the level
				plr.Sport.Lock3.Value = false

				SportBindableEvent:Fire(plr, 3)
				MoneyBindableFunction:Invoke(plr, 5000, "+")
			end

			return math.random(1,4), Score

		else
			-- If the player gave the correct answer
			if Arrow and typeof(Arrow) == "number" then
				if PlayerList[plr.Name][2] == Arrow then
					PlayerList[plr.Name][3] += 1
				else
					PlayerList[plr.Name][3] -= 1
				end
			end
			
			PlayerList[plr.Name][2] = math.random(1,4)
		end
	end

	return PlayerList[plr.Name][2], PlayerList[plr.Name][3]
end