local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local SportBindableEvent = ServerStorage:WaitForChild("Sport")
local AbilitiesBindableEvent = ServerStorage:WaitForChild("Abilities")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ParkourRemoteEvent = ReplicatedStorage:WaitForChild("Parkour")

local Checkpoint0, Checkpoint3, Checkpoint5, Checkpoint6, Checkpoint7, Checkpoint8, Checkpoint9, Checkpoint10
local Obstacle3Running, Obstacle5Running, Obstacle6Running, Obstacle7Running, Obstacle8Running, Obstacle9Running = false,  false, false,  false, false,  false

local Parkour = workspace.School.Parkour

local Obstacle6Kill1, Obstacle6Kill2
local Obstacle7StartToMiddle = TweenService:Create(Parkour.Obstacle7.MovingPart, TweenInfo.new(5, Enum.EasingStyle.Linear), {CFrame = Parkour.Obstacle7.Middle.CFrame})
local Obstacle7MiddleToEnd = TweenService:Create(Parkour.Obstacle7.MovingPart, TweenInfo.new(14.375, Enum.EasingStyle.Linear), {CFrame = Parkour.Obstacle7.End.CFrame})
local Obstacle7EndToMiddle = TweenService:Create(Parkour.Obstacle7.MovingPart, TweenInfo.new(14.375, Enum.EasingStyle.Linear), {CFrame = Parkour.Obstacle7.Middle.CFrame})
local Obstacle7MiddleToStart = TweenService:Create(Parkour.Obstacle7.MovingPart, TweenInfo.new(5, Enum.EasingStyle.Linear), {CFrame = Parkour.Obstacle7.Start.CFrame})
local Obstacle8Kill1, Obstacle8Kill2, Obstacle8Kill3, Obstacle8Kill4

local PlayerList = {}


-- TELEPORT THE PLAYER DOWN WHEN HE TOUCHES A KILL PART (OBSTACLE 6, OBSTACLE 7, OBSTACLE 8)

local function TeleportPlayerDown(hit, CheckForHumanoidRootPart)
	
	-- If CheckForHumanoidRootPart is true, then check if the hit is the humanoid root part, otherwise just tp the player
	if hit.Name == "HumanoidRootPart" or not CheckForHumanoidRootPart then
		
		if hit.Parent:FindFirstChild("HumanoidRootPart") then
			hit.Parent:FindFirstChild("HumanoidRootPart").CFrame = Parkour.PlayerPlacement.CFrame
		end
	end
end


-- CHECK IF MULTIPLE PLAYERS ARE ON THE SAME OBSTACLE

local function CanDeactivateObstacle(Obstacle)
	for i,v in pairs(PlayerList) do
		if v == Obstacle then
			return true
		end
	end
	
	return false
end


-- DEACTIVATE ALL OBSTACLES

local function DeactivateObstacles()
	Obstacle3Running = CanDeactivateObstacle(3)
	Obstacle5Running = CanDeactivateObstacle(5)
	Obstacle6Running = CanDeactivateObstacle(6)
	Obstacle7Running = CanDeactivateObstacle(7)
	Obstacle9Running = CanDeactivateObstacle(9)
end



Parkour.Trigger.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) then
		
		-- If the player is already playing, he can't leave this way, he has to use the other door
		if table.find(PlayerList, hit.Parent.Name) then
			hit.CFrame = Parkour.PlayerPlacement.CFrame
		else
			ParkourRemoteEvent:FireClient(Players[hit.Parent.Name], "Start")
		end
	end
end)


ParkourRemoteEvent.OnServerEvent:Connect(function(plr)
	
	-- Add the player to the table
	if not PlayerList[plr.Name] then
		PlayerList[plr.Name] = 0
		
		-- Disable the player's pet abilities
		plr.PetAbilitiesDisabled.Value = true
		AbilitiesBindableEvent:Fire(plr, true)
		
		-- Get all the checkpoints touched events (to activate and deactivate the obstacles when not used)
		if not Checkpoint3 and not Checkpoint5 then
			
			-- Activate obstacle 3 when someone touches the checkpoint, and deactivate it once he gets to the next obstacle or fall
			Checkpoint3 = Parkour.Checkpoint3.Touched:Connect(function(hit)
				if hit.Name == "HumanoidRootPart" and PlayerList[hit.Parent.Name] then
					
					DeactivateObstacles()
					PlayerList[hit.Parent.Name] = 3

					if not Obstacle3Running then
						Obstacle3Running = true
						
						coroutine.wrap(function()
							while Obstacle3Running do
								
								-- Choose four random parts to move
								for i=1,4 do
									local MovableParts = Parkour.Obstacle3.MovableParts:GetChildren()
									MovableParts[math.random(#MovableParts)].Parent = Parkour.Obstacle3.PartsToMove
								end
								
								-- Set their color to red
								for i,v in ipairs(Parkour.Obstacle3.PartsToMove:GetChildren()) do
									v.BrickColor = BrickColor.new("Really red")
								end
								
								wait(0.75)
								
								-- Move them to push players
								for i,v in ipairs(Parkour.Obstacle3.PartsToMove:GetChildren()) do
									v.BrickColor = BrickColor.new("Pastel blue-green")
									v.Anchored = false
									v.BodyPosition.Position = v.OriginalPosition.Value - Vector3.new(0,0,4.5)
								end
								
								wait(1)		
								
								-- Move the part back to its original position
								for i,v in ipairs(Parkour.Obstacle3.PartsToMove:GetChildren()) do
									v.BodyPosition.Position = v.OriginalPosition.Value
								end
								
								wait(1)
								
								-- Parent them to the movable parts folder so that they can be picked again
								for i,v in ipairs(Parkour.Obstacle3.PartsToMove:GetChildren()) do
									v.Parent = Parkour.Obstacle3.MovableParts
								end
							end
						end)()
					end
				end
			end)
		
			-- Activate obstacle 5 when someone touches the checkpoint, and deactivate it once he gets to the next obstacle or fall
			Checkpoint5 = Parkour.Checkpoint5.Touched:Connect(function(hit)
				if hit.Name == "HumanoidRootPart" and PlayerList[hit.Parent.Name] then
					
					DeactivateObstacles()
					PlayerList[hit.Parent.Name] = 5

					if not Obstacle5Running then
						Obstacle5Running = true
						
						coroutine.wrap(function()
							while Obstacle5Running do
								
								for i=1,5 do
									-- Hide the part and make it uncollidable
									if Parkour.Obstacle5:FindFirstChild("Part"..tostring(i)) then
										Parkour.Obstacle5["Part"..tostring(i)].CanCollide = false
										Parkour.Obstacle5["Part"..tostring(i)].Transparency = 1
									end
									
									wait(0.5)
									
									-- Show the part and make it collidable
									if Parkour.Obstacle5:FindFirstChild("Part"..tostring(i)) then
										Parkour.Obstacle5["Part"..tostring(i)].CanCollide = true
										Parkour.Obstacle5["Part"..tostring(i)].Transparency = 0
									end
								end
								
								wait(0.8)
							end
						end)()
					end
				end
			end)
		
			-- Activate obstacle 6 when someone touches the checkpoint, and deactivate it once he gets to the next obstacle or fall
			Checkpoint6 = Parkour.Checkpoint6.Touched:Connect(function(hit)
				if hit.Name == "HumanoidRootPart" and PlayerList[hit.Parent.Name] then
					
					DeactivateObstacles()
					PlayerList[hit.Parent.Name] = 6

					if not Obstacle6Running then
						Obstacle6Running = true

						Obstacle6Kill1 = Parkour.Obstacle6.Kill1.Touched:Connect(function(hit)
							TeleportPlayerDown(hit)
						end)

						Obstacle6Kill2 = Parkour.Obstacle6.Kill2.Touched:Connect(function(hit)
							TeleportPlayerDown(hit)
						end)
						coroutine.wrap(function()
							
							repeat wait(1) until not Obstacle6Running
							
							Obstacle6Kill1:Disconnect()
							Obstacle6Kill2:Disconnect()
						end)()
					end
				end
			end)
		
			-- Activate obstacle 7 when someone touches the checkpoint, and deactivate it once he gets to the next obstacle or fall
			Checkpoint7 = Parkour.Checkpoint7.Touched:Connect(function(hit)
				if hit.Name == "HumanoidRootPart" and PlayerList[hit.Parent.Name] then
					
					DeactivateObstacles()
					PlayerList[hit.Parent.Name] = 7

					if not Obstacle7Running then
						Obstacle7Running = true

						if not Parkour.Obstacle7:FindFirstChild("ParkourLasers") then
							
							ServerStorage.ParkourLasers:Clone().Parent = Parkour.Obstacle7

							if Parkour.Obstacle7:FindFirstChild("ParkourLasers") then
								for i,v in ipairs(Parkour.Obstacle7.ParkourLasers:GetChildren()) do
									v.Touched:Connect(function(hit)
										TeleportPlayerDown(hit, true)
									end)
								end
							end
						end

						coroutine.wrap(function()
							
							while Obstacle7Running do
								
								Obstacle7StartToMiddle:Play()
								wait(5)
								
								if Obstacle7Running then
									Obstacle7MiddleToEnd:Play()
									wait(14.375)
									
									if Obstacle7Running then
										Obstacle7EndToMiddle:Play()
										wait(14.375)
										
										if Obstacle7Running then
											Obstacle7MiddleToStart:Play()
											wait(5)
										end
									end
								end
							end
							
							Parkour.Obstacle7.MovingPart.CFrame = Parkour.Obstacle7.Start.CFrame
								
							if Parkour.Obstacle7:FindFirstChild("ParkourLasers") then
								Parkour.Obstacle7:FindFirstChild("ParkourLasers"):Destroy()
							end
						end)()
					end
				end
			end)
		
			-- Activate obstacle 8 when someone touches the checkpoint, and deactivate it once he gets to the next obstacle or fall
			Checkpoint8 = Parkour.Checkpoint8.Touched:Connect(function(hit)
				if hit.Name == "HumanoidRootPart" and PlayerList[hit.Parent.Name] then
					
					DeactivateObstacles()
					PlayerList[hit.Parent.Name] = 8

					if not Obstacle8Running then
						Obstacle8Running = true
						
						Obstacle8Kill1 = Parkour.Obstacle8.Lasers.Kill1.Touched:Connect(function(hit)
								TeleportPlayerDown(hit, true)
						end)
						
						Obstacle8Kill2 = Parkour.Obstacle8.Lasers.Kill2.Touched:Connect(function(hit)
								TeleportPlayerDown(hit, true)
						end)
						
						Obstacle8Kill3 = Parkour.Obstacle8.Lasers.Kill3.Touched:Connect(function(hit)
								TeleportPlayerDown(hit, true)
						end)
						
						Obstacle8Kill4 = Parkour.Obstacle8.Lasers.Kill4.Touched:Connect(function(hit)
								TeleportPlayerDown(hit, true)
						end)
						
						coroutine.wrap(function()
							
							repeat wait(1) until not Obstacle8Running
							
							Obstacle8Kill1:Disconnect()
							Obstacle8Kill2:Disconnect()
							Obstacle8Kill3:Disconnect()
							Obstacle8Kill4:Disconnect()
						end)()
					end
				end
			end)
		
			-- Activate obstacle 9 when someone touches the checkpoint, and deactivate it once he gets to the next obstacle or fall
			Checkpoint9 = Parkour.Checkpoint9.Touched:Connect(function(hit)
				if hit.Name == "HumanoidRootPart" and PlayerList[hit.Parent.Name] then
					
					DeactivateObstacles()
					PlayerList[hit.Parent.Name] = 9

					if not Obstacle9Running then
						Obstacle9Running = true
						
						coroutine.wrap(function()

							while Obstacle9Running do
								-- Choose a random color to keep, the 2 other colors will be hidden
								local RandomColor = math.random(1,3)

								for i,v in ipairs(Parkour.Obstacle9.ColorParts:GetChildren()) do
									if v.Name ~= "Color"..tostring(RandomColor) then
										v.Transparency = 1
									end
								end
								
								wait(1)
								
								for i,v in ipairs(Parkour.Obstacle9.Colors:GetChildren()) do
									if v.Name ~= "Color"..tostring(RandomColor) then

										-- Hide all the parts of that color
										for a,b in ipairs(v:GetChildren()) do
											b.Transparency = 1
											b.CanCollide = false
										end
									end
								end

								wait(2)

								for i,v in ipairs(Parkour.Obstacle9.Colors:GetChildren()) do
									if v.Name ~= "Color"..tostring(RandomColor) then

										-- Show all the parts of that color
										for a,b in ipairs(v:GetChildren()) do
											b.Transparency = 0
											b.CanCollide = true
										end
									end
								end

								for i,v in ipairs(Parkour.Obstacle9.ColorParts:GetChildren()) do
									if v.Name ~= "Color"..tostring(RandomColor) then
										v.Transparency = 0
									end
								end

								wait(0.5)
							end
						end)()
					end
				end
			end)
		end
	end
end)


-- PLAYER FALLS ON THE GROUND

Parkour.Checkpoint0.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" and PlayerList[hit.Parent.Name] and PlayerList[hit.Parent.Name] ~= 0 then
		PlayerList[hit.Parent.Name] = 0
		DeactivateObstacles()
	end
end)


-- PLAYER TOUCHES THE LAST CECKPOINT

Parkour.Checkpoint10.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" and PlayerList[hit.Parent.Name] then
		PlayerList[hit.Parent.Name] = 10
		DeactivateObstacles()
	end
end)


-- PLAYER GIVES UP

Parkour.GiveUp.Trigger.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) then
		hit.CFrame = Parkour.PlayerPlacementOut.CFrame
		
		if PlayerList[hit.Parent.Name] then
			PlayerList[hit.Parent.Name] = nil
		end
		
		-- Reenable the player's pet abilities
		Players[hit.Parent.Name].PetAbilitiesDisabled.Value = false
		AbilitiesBindableEvent:Fire(Players[hit.Parent.Name], false)
	end
end)


-- PLAYER FINISHES THE PARKOUR

Parkour.Finish.Trigger.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) then

		if PlayerList[hit.Parent.Name] and PlayerList[hit.Parent.Name] == 10 and Players[hit.Parent.Name].Sport.Lock6.Value then
			Players[hit.Parent.Name].Sport.Lock6.Value = false
			
			-- Reenable the player's pet abilities
			Players[hit.Parent.Name].PetAbilitiesDisabled.Value = false
			AbilitiesBindableEvent:Fire(Players[hit.Parent.Name], false)
			
			SportBindableEvent:Fire(Players[hit.Parent.Name], 6)
			MoneyBindableFunction:Invoke(Players[hit.Parent.Name], 50000, "+")
			ParkourRemoteEvent:FireClient(Players[hit.Parent.Name], "End")
		end
	end
end)