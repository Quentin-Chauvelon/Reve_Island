local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local TypingBindableEvent = ServerStorage:WaitForChild("Typing")
local MoneyBindableEvent = ServerStorage:WaitForChild("Money")
local ExperienceBindableEvent = ServerStorage:WaitForChild("Experience")
local WarnBindableEvent = ServerStorage:WaitForChild("Warn")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TypingRemoteEvent = ReplicatedStorage:WaitForChild("Typing")

local StartTime = 0
local EndTime = 0
local TextToType = ""
local StartComputer

local PlayerList = {} -- index : [1] = ChairDebounce, [2] = IdiomDebounce, [3] = CompetitiveDebounce, [4] = IsPlaying 


-- CREATE THE TABLE FOR EACH PLAYER

Players.PlayerAdded:Connect(function(plr)
	PlayerList[plr.Name] = {}
	table.insert(PlayerList[plr.Name], 1, 0)
	table.insert(PlayerList[plr.Name], 2, 0)
	table.insert(PlayerList[plr.Name], 2, 0)
	table.insert(PlayerList[plr.Name], 4, false)
end)

Players.PlayerRemoving:Connect(function(plr)
	PlayerList[plr.Name] = nil
end)


-- GET ALL THE TOUCHED EVENT FOR THE SEATS

StartComputer = workspace.ComputerRoom.Start.Touched:Connect(function()
	StartComputer:Disconnect()
	
	for i,v in ipairs(workspace.ComputerRoom.Seats:GetChildren()) do -- for every seats
		
		v:GetPropertyChangedSignal("Occupant"):Connect(function()
			if v.Occupant and v.Occupant.Parent then
				local Player = Players:GetPlayerFromCharacter(v.Occupant.Parent)
				
				if Player then
					if PlayerList[Player.Name][1] == 0 then
						PlayerList[Player.Name][1] = 1

						PlayerList[Player.Name][4] = true -- to know if player is playing

						Player.CanDie.Value = false

						TypingRemoteEvent:FireClient(Player) -- fire client to start	
					end	
				end
			end
		end)



		v.Touched:Connect(function(hit) -- get click on all the buttons
			local Player = Players:FindFirstChild(hit.Parent.Name)
			if Player then
				if PlayerList[Player.Name][1] == 0 then
					PlayerList[Player.Name][1] = 1

					PlayerList[Player.Name][4] = true -- to know if player is playing

					Player.CanDie.Value = false

					TypingRemoteEvent:FireClient(Player) -- fire client to start	
				end	
			end
		end)
	end


	TypingRemoteEvent.OnServerEvent:Connect(function(plr, Mode, Start, Time, Text)

		if Mode and Start ~= nil and Time and Text then -- start ~= nil used because it's a boolean so it can be false, and if it is then, it is like if it was nil
			if typeof(Mode) == "string" and typeof(Start) == "boolean" and typeof(Time) == "number" and typeof(Text) == "string" then
				if Mode == "Idioms" then -- if player is playing the idioms mode
					if PlayerList[plr.Name][4] == true then -- if player is playing
						if Time >= 0 then

							if PlayerList[plr.Name][2] == 0 then
								PlayerList[plr.Name][2] = 2

								MoneyBindableEvent:Invoke(plr, (100 - Time), "+")
								ExperienceBindableEvent:Fire(plr, "Typist", 3)
								plr.CanDie.Value = true


							else WarnBindableEvent:Fire(plr, "Normal", "is firing the typing remote event too quickly for the idioms mode", "Computer", os.time()) end
						else WarnBindableEvent:Fire(plr, "Important", "typed the idiom in "..Time.."s which is negative", "Computer", os.time()) end
					else WarnBindableEvent:Fire(plr, "Normal", "fired the typing remote event while he wasn't playing", "Computer", os.time()) end


				elseif Mode == "Competitive" then -- if player is playing the competitive mode
					if PlayerList[plr.Name][4] == true then -- if player is playing
						if Start == true then
							StartTime = tick()
							TextToType = Text

						else
							if TextToType == Text then
								EndTime = tick()
								local TimeDifference = EndTime - StartTime

								if (Time - 1)  <= TimeDifference and (Time + 1) >= TimeDifference then

									if PlayerList[plr.Name][1] == 0 then
										PlayerList[plr.Name][3] = 3

										if Time < plr.Stats.TypingPb.Value or plr.Stats.TypingPb.Value == 0 then -- if player get a pb or if he hasn't got one
											TypingBindableEvent:Fire(plr, Time) -- fire the server to save and change the leaderboard
										elseif Time < workspace.ComputerRoom.Leaderboard.LowestTime.Value or workspace.ComputerRoom.Leaderboard.LowestTime.Value == 0 then -- if player makes it into the leaderboard
											TypingBindableEvent:Fire(plr, Time) -- fire the server to save and change the the leaderboard
										end

										MoneyBindableEvent:Invoke(plr, 100, "+")
										ExperienceBindableEvent:Fire(plr, "Typist", 6)
										plr.CanDie.Value = true

									else WarnBindableEvent:Fire(plr, "Normal", "is firing the typing remote event too quickly for the competitive mode", "Computer", os.time()) end
								else WarnBindableEvent:Fire(plr, "Important", "fired the typing remote on competitive mode with the wrong time, "..Time.." instead of "..TimeDifference, "Computer", os.time()) end
							else WarnBindableEvent:Fire(plr, "Important", "fired the typing remote on competitive mode with a mistake, text to type : "..TextToType.." and typed text : "..Text, "Computer", os.time()) end
						end
					else WarnBindableEvent:Fire(plr, "Normal", "fired the typing remote event while he wasn't playing", "Computer", os.time()) end

				elseif Mode == "Close" then
					PlayerList[plr.Name][4] = false

				else WarnBindableEvent:Fire(plr, "Normal", "fired the typing remote event with the first parameter : "..Mode, "Computer", os.time()) end		
			else WarnBindableEvent:Fire(plr, "Normal", "fired the typing remote event with unexpected types of value (Mode : "..Mode..", Start : "..Start..", Time : "..Time..", Text : "..Text, "Computer", os.time()) end
		else WarnBindableEvent:Fire(plr, "Normal", "fired the typing remote event with nil values", "Computer", os.time()) end
	end)


	-- DEBOUNCE FOR EACH PLAYER

	while wait(1) do
		for i, v in next, PlayerList do
			if v[1] > 0 then
				v[1] = v[1] - 1
			end

			if v[2] > 0 then
				v[2] = v[2] - 1
			end

			if v[3] > 0 then
				v[3] = v[3] - 1
			end
		end
	end
end)