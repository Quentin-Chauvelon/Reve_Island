local Players = game:GetService("Players")

local ServerStorage = game:GetService("ServerStorage")
local FactoryBindableEvent = ServerStorage:WaitForChild("Factory")
local MoneyBindableEvent = ServerStorage:WaitForChild("Money")
local ExperienceBindableEvent = ServerStorage:WaitForChild("Experience")
local WarnBindableEvent = ServerStorage:WaitForChild("Warn")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FactoryRemoteEvent = ReplicatedStorage:WaitForChild("Factory")

local Mode3Started = false
local CountCubes = false
local NumberOfCubes = 0
local StartTime = 0
local EndTime = 0

local PlayerList = {} -- index : [1] = Debounce, [2] = Mode1Debounce, [3] = Mode2Debounce, [4] = Mode3Debounce, [5] = Mode, [6] = Map, [7] = IsPlaying 


-- CREATE THE TABLE FOR EACH PLAYER

Players.PlayerAdded:Connect(function(plr)
	PlayerList[plr.Name] = {}
	table.insert(PlayerList[plr.Name], 1, 0)
	table.insert(PlayerList[plr.Name], 2, 0)
	table.insert(PlayerList[plr.Name], 3, 0)
	table.insert(PlayerList[plr.Name], 4, 0)
	table.insert(PlayerList[plr.Name], 5, 1)
	table.insert(PlayerList[plr.Name], 6, 1)
	table.insert(PlayerList[plr.Name], 7, false)
end)

Players.PlayerRemoving:Connect(function(plr)
	PlayerList[plr.Name] = nil
end)


-- START

workspace.Factory.Start.StartTrigger.Touched:Connect(function(hit)
	local Player = Players:FindFirstChild(hit.Parent.Name)
	if Player then
		
		if PlayerList[Player.Name][1] == 0 then
			PlayerList[Player.Name][1] = 1
			
			PlayerList[Player.Name][7] = true
			
			Player.CanDie.Value = false
			FactoryRemoteEvent:FireClient(Player, PlayerList[Player.Name][5], PlayerList[Player.Name][6])
		end	
	end
end)


-- SELECT MODE 

local function ModeSelection(hit, Mode)
	local Player = Players:FindFirstChild(hit.Parent.Name) -- find player

	if Player then
		PlayerList[Player.Name][5] = Mode -- change the selected mode
	end
end

workspace.Factory.Modes.Mode1.Mode1Trigger.Touched:Connect(function(hit)
	ModeSelection(hit, 1) -- mode 1
end)

workspace.Factory.Modes.Mode2.Mode2Trigger.Touched:Connect(function(hit)
	ModeSelection(hit, 2) -- mode 2
end)

workspace.Factory.Modes.Mode3.Mode3Trigger.Touched:Connect(function(hit)
	ModeSelection(hit, 3) -- mode 3
end)


-- SELECT MAP

local function MapSelection(hit, Map)
	local Player = Players:FindFirstChild(hit.Parent.Name) -- find player

	if Player then
		PlayerList[Player.Name][6] = Map -- change the selected mode
	end
end

workspace.Factory.Maps.Map1.Map1Trigger.Touched:Connect(function(hit)
	MapSelection(hit, 1) -- map 1
end)

workspace.Factory.Maps.Map2.Map2Trigger.Touched:Connect(function(hit)
	MapSelection(hit, 2) -- map 2
end)

workspace.Factory.Maps.Map3.Map3Trigger.Touched:Connect(function(hit)
	MapSelection(hit, 3) -- map 3
end)




FactoryRemoteEvent.OnServerEvent:Connect(function(plr, Type, PlayedMode, PlayedMap, Points)
	if Type and PlayedMode and PlayedMap and Points then
		if typeof(Type) == "string" and typeof(PlayedMode) == "number" and typeof(PlayedMap) == "number" and typeof(Points) == "number" then
			if Type == "Points" then
				if PlayerList[plr.Name][7] == true then -- if player is playing
					PlayerList[plr.Name][7] = false

					if PlayedMode == PlayerList[plr.Name][5] then -- if the mode the player was playing is the same fired by the server
						if PlayedMap == PlayerList[plr.Name][6] then -- the map the player was playing is the same fired by the server
							if PlayedMode == 1 then -- if the player played the mode 1
								if Points <= 60 then -- points should be around 57 on map 1 (take 60 to prevent false positive)
									
									if PlayerList[plr.Name][2] == 0 then
										PlayerList[plr.Name][2] = 45

										MoneyBindableEvent:Invoke(plr, (20 * Points), "+") -- give money
										ExperienceBindableEvent:Fire(plr, "FactoryWorker", 8) -- give experience
										plr.CanDie.Value = true

									else WarnBindableEvent:Fire(plr, "Normal", "is firing the factory remote event too quickly for mode 1", "Factory", os.time()) end
								else WarnBindableEvent:Fire(plr, "Important", "got "..Points.." points which is more than the maximum expected (60) (mode "..PlayedMode.." and map "..PlayedMap..")", "Factory", os.time()) end

							elseif PlayedMode == 2 then -- if the player played the mode 2
								if Points <= 51 then -- points  can't be higher than 50 (take 51 just in case) then
									
									if PlayerList[plr.Name][3] == 0 then
										PlayerList[plr.Name][3] = 30

										if PlayedMap == 1 then -- money earnt based on the map
											MoneyBindableEvent:Invoke(plr, (14 * Points), "+")
										--elseif PlayedMap == 2 then
											--MoneyBindableEvent:Invoke(plr, (3 * Points), "+")
										else
											MoneyBindableEvent:Invoke(plr, (22 * Points), "+")
										end

										if PlayedMap == 1 then -- experience earnt based on the map and the points
											if Points <= 10 then
												ExperienceBindableEvent:Fire(plr, "FactoryWorker", 2)
											elseif Points > 10 and Points <= 20 then
												ExperienceBindableEvent:Fire(plr, "FactoryWorker", 3)
											elseif Points > 20 and Points <= 30 then
												ExperienceBindableEvent:Fire(plr, "FactoryWorker", 4)
											elseif Points > 30 and Points <= 40 then
												ExperienceBindableEvent:Fire(plr, "FactoryWorker", 5)
											else
												ExperienceBindableEvent:Fire(plr, "FactoryWorker", 6)
											end
										else -- map 2 or 3
											if Points <= 10 then
												ExperienceBindableEvent:Fire(plr, "FactoryWorker", 3)
											elseif Points > 10 and Points <= 20 then
												ExperienceBindableEvent:Fire(plr, "FactoryWorker", 6)
											elseif Points > 20 and Points <= 30 then
												ExperienceBindableEvent:Fire(plr, "FactoryWorker", 9)
											elseif Points > 30 and Points <= 40 then
												ExperienceBindableEvent:Fire(plr, "FactoryWorker", 12)
											else
												ExperienceBindableEvent:Fire(plr, "FactoryWorker", 15)
											end
										end
										
										plr.CanDie.Value = true

									else WarnBindableEvent:Fire(plr, "Normal",  "is firing the factory remote event too quickly for mode 2", "Factory", os.time()) end
								end

							else -- if the player played the mode 3
								
								if PlayerList[plr.Name][4] == 0 then
									PlayerList[plr.Name][4] = 5
									
									CountCubes = false

									if Points == 0 then
										StartTime = os.time()
									end
									EndTime = os.time()

									local Difference = EndTime - StartTime -- get the time between the first and last cubes

									if PlayedMap == 1 then
										if (Points - 1) <= NumberOfCubes and (Points + 1) >= NumberOfCubes then -- if points seems legit
											if (Difference - 3) <= (NumberOfCubes*0.6+2) and (Difference + 3) >= (NumberOfCubes*0.6+2) then -- if time seems legit

												MoneyBindableEvent:Invoke(plr, (24 * Points), "+")

												if Points <= 10 then
													ExperienceBindableEvent:Fire(plr, "FactoryWorker", 1)
												elseif Points > 10 and Points <= 20 then
													ExperienceBindableEvent:Fire(plr, "FactoryWorker", 3)
												elseif Points > 20 and Points <= 30 then
													ExperienceBindableEvent:Fire(plr, "FactoryWorker", 5)
												elseif Points > 30 and Points <= 40 then
													ExperienceBindableEvent:Fire(plr, "FactoryWorker", 7)
												elseif Points > 40 and Points <= 50 then
													ExperienceBindableEvent:Fire(plr, "FactoryWorker", 10)
												else
													ExperienceBindableEvent:Fire(plr, "FactoryWorker", 15)
												end
												
												plr.CanDie.Value = true

												if Points > workspace.Factory.Leaderboard.LowestTime.Value or workspace.Factory.Leaderboard.LowestTime.Value == 0 then
													FactoryBindableEvent:Fire(plr, Points) -- set player on leaderboard
												end

											else WarnBindableEvent:Fire(plr, "Normal", "fired the factory remote event with a wrong time", "Factory", os.time()) end
										else WarnBindableEvent:Fire(plr, "Important", "fired the factory remote event with a wrong number of points", "Factory", os.time()) end

									else
										if (Points - 1) <= NumberOfCubes and (Points + 1) >= NumberOfCubes then
											--if (Difference - 3) <= (NumberOfCubes*0.8+2) and (Difference + 3) >= (NumberOfCubes*0.8+2) then

												MoneyBindableEvent:Invoke(plr, (24 * Points), "+")

												if Points <= 10 then
													ExperienceBindableEvent:Fire(plr, "FactoryWorker", 1)
												elseif Points > 10 and Points <= 20 then
													ExperienceBindableEvent:Fire(plr, "FactoryWorker", 3)
												elseif Points > 20 and Points <= 30 then
													ExperienceBindableEvent:Fire(plr, "FactoryWorker", 5)
												elseif Points > 30 and Points <= 40 then
													ExperienceBindableEvent:Fire(plr, "FactoryWorker", 7)
												elseif Points > 40 and Points <= 50 then
													ExperienceBindableEvent:Fire(plr, "FactoryWorker", 10)
												else
													ExperienceBindableEvent:Fire(plr, "FactoryWorker", 15)
												end

												if Points > workspace.Factory.Leaderboard.LowestTime.Value or workspace.Factory.Leaderboard.LowestTime.Value == 0 then
													FactoryBindableEvent:Fire(plr, Points) -- set player on leaderboard
												end	

											--else WarnBindableEvent:Fire(plr, "Normal", "fired the factory remote event with a wrong time", "Factory", os.time()) end
										else WarnBindableEvent:Fire(plr, "Important", "fired the factory remote event with a wrong number of points", "Factory", os.time()) end
									end

									NumberOfCubes = 0

								else WarnBindableEvent:Fire(plr, "Normal",  "is firing the factory remote event too quickly for mode 3", "Factory", os.time()) end
							end
						else WarnBindableEvent:Fire(plr, "Normal",  "isn't playing the correct map in factory (map "..PlayedMap.." instead of map "..PlayerList[plr.Name][2]..")", "Factory", os.time()) end
					else WarnBindableEvent:Fire(plr, "Normal",  "isn't playing the correct mode in factory (mode "..PlayedMode.." instead of mode "..PlayerList[plr.Name][1]..")", "Factory", os.time()) end
				else WarnBindableEvent:Fire(plr, "Normal",  "fired the factory remote event while he wasn't playing", "Factory", os.time()) end
				
			elseif Type == "Cubes" then
				if CountCubes then -- counting the number of cubes that have been spawned
					NumberOfCubes += 1
				else
					CountCubes = true
					StartTime = os.time()
					NumberOfCubes += 1
				end

			else WarnBindableEvent:Fire(plr, "Normal",  "fired the factory remote event with the first parameter : "..Type, "Factory", os.time()) end
		else WarnBindableEvent:Fire(plr, "Normal",  "fired the factory remote event with unexpected types of value (Type : "..Type..", PlayedMode : "..PlayedMode..", PlayedMap : "..PlayedMap..", Points : "..Points..")", "Factory", os.time()) end
	else WarnBindableEvent:Fire(plr, "Normal",  "fired the factory remote event with nil values", "Factory", os.time()) end
end)


 --DEBOUNCE FOR EACH PLAYER

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
		
		if v[4] > 0 then
			v[4] = v[4] - 1
		end
	end
end