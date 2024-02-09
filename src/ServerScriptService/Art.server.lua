local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local ArtBindableEvent = ServerStorage:WaitForChild("Art")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ArtRemoteFunction = ReplicatedStorage:WaitForChild("Art")

local PlayerList = {}
local LevelReward = {2000, 5000, 10000, 25000, 50000}


-- END OF THE GAME

local function EndOfGame(plr)
	if PlayerList[plr.Name] then
		PlayerList[plr.Name] = nil
	end
	
	plr.PlayerGui.Art.IsPlaying.Value = false
	
	if plr:FindFirstChild("CanDie") then
		plr.CanDie.Value = true
	end
end



-- REMOTE FUNCTION FIRED FROM THE CLIENT

ArtRemoteFunction.OnServerInvoke = function(plr, Level, Erase, Column, Row, Color)
	
	
	if not PlayerList[plr.Name] then

		if Level and typeof(Level) == "number" and (Level == 1 or (plr.Art:FindFirstChild("Lock"..Level) and not plr.Art:FindFirstChild("Lock"..Level).Value)) then
			-- [1] = StartTime (to check if the player is firing the remote event after the timer ran out)
			-- [2] = Art matrix (to know which tile of the drawing is colored in what color)
			-- [3] = Score matrix (to know which tiles the player has colored the right color)
			-- [4] = Score (increases each time the player clicks on the correct next color)
			-- [5] = Level (level the player started the timer at)
			PlayerList[plr.Name] = {os.time(), {}, {}, 0, Level}

			plr.PlayerGui.Art.IsPlaying.Value = true

			if plr:FindFirstChild("CanDie") then
				plr.CanDie.Value = false
			end

			-- Create a matrix of size 2 + level (between 3x3 and 7x7) and choose a random color each time
			for column = 1, (2 + Level) do
				PlayerList[plr.Name][2][column] = {}
				PlayerList[plr.Name][3][column] = {}

				for row = 1, (2 + Level) do
					PlayerList[plr.Name][2][column][row] = math.random(1,5)
					PlayerList[plr.Name][3][column][row] = false
				end
			end

			return PlayerList[plr.Name][2]
		end

	else
		
		if Level and not Erase and not Column then
			EndOfGame(plr)
			return
		end

		-- Player fires the remote event while the timer is over
		if PlayerList[plr.Name][1] + 32 < os.time()  then
			EndOfGame(plr)
			return
		end

		if Erase then
			for i,v in pairs(PlayerList[plr.Name][3]) do
				for a,b in pairs(v) do
					b = false
				end
			end

			PlayerList[plr.Name][4] = 0
			
			return
		end

		if Column and Row and Color and typeof(Column) == "number" and typeof(Row) == "number" and typeof(Color) == "number" then
			if PlayerList[plr.Name][2][Column] and PlayerList[plr.Name][2][Column][Row] then
				local RightColor = (PlayerList[plr.Name][2][Column][Row] == Color)
				
				if PlayerList[plr.Name][3][Column][Row] ~= RightColor then
					if RightColor then
						PlayerList[plr.Name][4] += 1
						PlayerList[plr.Name][3][Column][Row] = true
					else
						PlayerList[plr.Name][4] -= 1
						PlayerList[plr.Name][3][Column][Row] = false
					end

					PlayerList[plr.Name][4] = math.max(PlayerList[plr.Name][4], 0)

					-- If the player colored all the tiles right
					if PlayerList[plr.Name][4] == (2 + PlayerList[plr.Name][5])^2 and PlayerList[plr.Name][4] > 0 then
						EndOfGame(plr)

						if plr.Art:FindFirstChild("Lock"..(tostring(Level+1))) and plr.Art["Lock"..(tostring(Level+1))].Value and LevelReward[Level] then
							MoneyBindableFunction:Invoke(plr, LevelReward[Level], "+")
						end
						
						if plr.Art:FindFirstChild("Lock"..(tostring(Level+1))) then
							plr.Art:FindFirstChild("Lock"..(tostring(Level+1))).Value = false
						end

						ArtBindableEvent:Fire(plr, Level+1) -- fire the datastore to save the unlocked level

						return true
					end
				end
			end
		end
	end
	
	return false
end