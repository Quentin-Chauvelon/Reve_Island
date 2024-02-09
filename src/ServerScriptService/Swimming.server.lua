local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local SportBindableEvent = ServerStorage:WaitForChild("Sport")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SwimmingRemoteEvent = ReplicatedStorage:WaitForChild("Swimming")

local Swimming = workspace.School.SwimmingPool

local PlayerList = {}


-- END OF GAME

local function EndOfGame(plr)
	
	if plr:FindFirstChild("CanDie") then
		plr.CanDie.Value = false
	end
	
	if plr.PlayerGui.Swimming:FindFirstChild("IsPlaying") then
		plr.PlayerGui.Swimming.IsPlaying.Value = false
	end
	
	PlayerList[plr.Name] = nil
end


-- SWIMMING REMOTE EVENT FIRED FROM THE CLIENT

SwimmingRemoteEvent.OnServerEvent:Connect(function(plr)

	-- Start the game
	if not PlayerList[plr.Name] then
		-- [1] = StartTime (to check if the player is firing the remote event after the timer ran out)
		-- [2] = NextRing (next ring the player is supposed to touch)
		PlayerList[plr.Name] = {os.time(), 1}
		
		if plr:FindFirstChild("CanDie") then
			plr.CanDie.Value = false
		end
		
		if plr.PlayerGui.Swimming:FindFirstChild("IsPlaying") then
			plr.PlayerGui.Swimming.IsPlaying.Value = true
		end
		
	else
		EndOfGame(plr)
	end
end)


-- GET ALL THE TOUCHED EVENTS FOR THE RINGS

for i,v in ipairs(Swimming.TouchRings:GetChildren()) do
	v.Touched:Connect(function(hit)
		
		-- If the player is in the player list (meaning he is playing the game)
		if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) and PlayerList[hit.Parent.Name] then
			
			local plr = Players[hit.Parent.Name]
			-- If the player ran out of time
			if PlayerList[hit.Parent.Name][1] + 31 < os.time() then
				EndOfGame(plr)
				
			else
				-- If the player is touching the ring he is supposed to touch
				if PlayerList[hit.Parent.Name][2] == v.Ring.Value then
					
					SwimmingRemoteEvent:FireClient(plr, PlayerList[hit.Parent.Name][2]) -- fire the client to change the color of the rings
					PlayerList[hit.Parent.Name][2] += 1
					
					-- If the player went through all the rings, then he unlocks the next level
					if PlayerList[hit.Parent.Name][2] == 17 then
						
						EndOfGame(plr)
						
						-- If the player has unlocked the swimming level but not the football level
						if not plr.Sport.Lock3.Value and plr.Sport.Lock4.Value then
							plr.Sport.Lock4.Value = false

							SportBindableEvent:Fire(plr, 4)
							MoneyBindableFunction:Invoke(plr, 10000, "+")
						end
					end
				end
			end
		end
	end)
end