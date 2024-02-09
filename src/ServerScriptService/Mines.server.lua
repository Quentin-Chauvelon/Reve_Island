-- give pickaxe --> give tool == TEST
-- compute async / find path way too slow in the mine (try digging a hole in LFS Building and see if there is a the same issue)
-- modify the sword animation (make it move straight)
-- make the mountain + the tunnel that goes to the mine
-- amethyst miner event == TEST
-- datastore (tools, ores) == TEST
-- sell ores gui (miner at the entrance of the mine)
-- money and experience (mining + hunter)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local ExperienceBindableEvent = ServerStorage:WaitForChild("Experience")
local MiningBindableEvent = ServerStorage:WaitForChild("Mining")
local AmethystMinecarts = ServerStorage.MiningTools:WaitForChild("AmethystMinecarts")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MinesRemoteEvent = ReplicatedStorage:WaitForChild("Mines")

local Mines = workspace.Mines
local AmethystMinecartEnded = false
local Wave1, Wave2, Wave3 = false, false, false
local PlayerInTheMine = false

local OresTable = {Stone = 0, Coal = 50, Iron = 200, Olivine = 750, Amethyst = 1600, Cobalt = 4250}
local MinerKillReward = {Iron = 70, Olivine = 83, Amethyst = 98, Cobalt = 115}


-- Table used to know at which layer players are (should prevent lag)
-- This will avoid having the miners look for players to attack when there are none in the mines
-- It will also help knowing which if the miners should be running and attacking or not (also prevents lag)
local MinesPlayers = {Surface = {}, Coal = {}, Iron = {}, Olivine = {}, Amethyst = {}, Cobalt = {}}


-- PLAYER GETS OUT OF A MINE, LEAVES THE GAME OR IS KILLED

local function OutOfMine(plr)
	for a,b in pairs(MinesPlayers) do
		if table.find(b, plr) then
			table.remove(b, table.find(b, plr)) -- remove player from the table
		end
	end
end


-- PLAYER SHOULD BE KILLED

local function KillPlayer(plr, char)
	
	-- Teleport the player to the first layer and regen him to full health
	if plr and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
		char:FindFirstChild("HumanoidRootPart").CFrame = Mines.KillTeleport.CFrame
		char:FindFirstChild("Humanoid").Health = char:FindFirstChild("Humanoid").MaxHealth
	end
	
	-- Remove the player from any other layer
	OutOfMine(plr.Name)
end


-- RESPAWN THE MINERS

RespawnMiners = coroutine.wrap(function()

	-- While there is a player in the mine, respawn the miners 
	-- Used a repeat until because it runs at least once even if the condition is false (and in our case, we run it once at the start to spawn all the miners)
	repeat
		for i,v in ipairs(workspace.Mines.SpawnPositions:GetChildren()) do

			if v.Respawn.Value == true then
				if ServerStorage.MiningTools.Miners:FindFirstChild(v.Name.."Miner") and workspace.Mines.Miners:FindFirstChild(v.Name) then
					local Miner = ServerStorage.MiningTools.Miners:FindFirstChild(v.Name.."Miner"):Clone()
					Miner:SetPrimaryPartCFrame(v.CFrame)
					Miner.Index.Value = v.Index.Value
					Miner.Parent = workspace.Mines.Miners:FindFirstChild(v.Name)
										
					-- Miner damages the player when he touches him
					Miner.HumanoidRootPart.Touched:Connect(function(hit)
						if hit.Parent and Players:FindFirstChild(hit.Parent.Name) and hit.Parent:FindFirstChild("Humanoid") and Miner.HitCooldown.Value + 0.5 < tick() then
							Miner.HitCooldown.Value = tick()
							
							-- Kill or damage the player based on his health
							if hit.Parent:FindFirstChild("Humanoid").Health > Miner.Damage.Value then
								hit.Parent:FindFirstChild("Humanoid"):TakeDamage(Miner.Damage.Value)
							else
								KillPlayer(Players:FindFirstChild(hit.Parent.Name), Players:FindFirstChild(hit.Parent.Name).Character)
							end
							
						-- If a sword is touching the miner, damage or kill him 
						elseif hit.Name == "Blade" and hit.Parent:FindFirstChild("Damage") then
							
							-- If the sword deals more damage than the miner's health, destroy and respawn him
							if hit.Parent:FindFirstChild("Damage").Value >= Miner.Humanoid.Health then
								
								-- Find the spawn position that has the miner index to respawn him
								for i,v in ipairs(Mines.SpawnPositions:GetChildren()) do
									if v.Index.Value == Miner.Index.Value then -- if the part index is the same as the miner's one
										v.Respawn.Value = true -- respawn him
										break
									end
								end

								Miner:Destroy() -- destroy the miner
								
								if MinerKillReward[v.Name] then	
									MoneyBindableFunction:Invoke(Players:FindFirstChild(hit.Parent.Parent.Name), MinerKillReward[v.Name], "+")
								end
								
								ExperienceBindableEvent:Fire(Players:FindFirstChild(hit.Parent.Parent.Name), "Hunter", 5)
								
								
							-- Otherwise, damage him
							else
								Miner.Humanoid:TakeDamage(hit.Parent:FindFirstChild("Damage").Value)
							end
						end
					end)
					v.Respawn.Value = false
				end
			end

			wait(1)
		end	
	until PlayerInTheMine == false
end)

--RespawnMiners()


-- MINERS THAT ATTACK THE PLAYERS

local AttackmingMiners = coroutine.wrap(function()
	while PlayerInTheMine do
		for a,b in ipairs(Mines.Miners:GetChildren()) do

			if MinesPlayers[b.Name] and #MinesPlayers[b.Name] > 0 then
				for i,v in ipairs(b:GetChildren()) do
					
					if #MinesPlayers[b.Name] > 0 and v:FindFirstChild("Humanoid") then
						
						local ClosestPlayer = MinesPlayers[b.Name][1]
						
						local ClosestDistance = 1000
						if Players:FindFirstChild(MinesPlayers[b.Name][1]).Character and Players[MinesPlayers[b.Name][1]].Character:FindFirstChild("HumanoidRootPart") then
							ClosestDistance = math.abs((Players[MinesPlayers[b.Name][1]].Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude)
						end

						for y,w in pairs(MinesPlayers[b.Name]) do
							if Players:FindFirstChild(w) then
								if math.abs((Players:FindFirstChild(w).Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude) < ClosestDistance then
									ClosestDistance = math.abs((Players:FindFirstChild(w).Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude)
								end
							end
						end
						
						if ClosestDistance < 35 and workspace:FindFirstChild(ClosestPlayer) then

							local goalPosition = Vector3.new(workspace:FindFirstChild(ClosestPlayer).HumanoidRootPart.Position.X, workspace:FindFirstChild(ClosestPlayer).HumanoidRootPart.Position.Y, workspace:FindFirstChild(ClosestPlayer).HumanoidRootPart.Position.Z)
							
							local path = PathfindingService:CreatePath()
							path:ComputeAsync(v.HumanoidRootPart.Position, goalPosition)
							--local path = PathfindingService:FindPathAsync(v.HumanoidRootPart.Position, goalPosition)
							local waypoints = path:GetWaypoints()
							
							
							--workspace.Cars:ClearAllChildren()

							--for i,v in pairs(waypoints) do
							--	local Part = Instance.new("Part")
							--	Part.Size = Vector3.new(1,1,1)
							--	Part.CanCollide = false
							--	Part.Anchored = true
							--	Part.BrickColor = BrickColor.new("Really red")
							--	Part.Position = v.Position
							--	Part.Parent = workspace.Cars
							--end
							
							if path.Status == Enum.PathStatus.Success then
								for _, waypoint in pairs(waypoints) do
									if v:FindFirstChild("Humanoid") then
										v.Humanoid:MoveTo(waypoint.Position)
									end
								end
							end
						end
					end
					
					RunService.Heartbeat:Wait()
				end
			end
			RunService.Heartbeat:Wait()
		end
	end
end)


-- PLAYER GETS IN A MINE

for i,v in ipairs(Mines.LayersTriggers:GetChildren()) do
	v.Touched:Connect(function(hit) -- if the player touches one of the layers triggers

		if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) and MinesPlayers[v.Name] and not table.find(MinesPlayers[v.Name], hit.Parent.Name) then -- if hit is a player, the layer has been found in the table and the player is not already in the mine
			
			-- Load and change all the ores given miners texts
			if v.Name == "Surface" then
				MinesRemoteEvent:FireClient(Players:FindFirstChild(hit.Parent.Name), "LoadOres")
			end
			
			-- Remove the player from any other layer
			OutOfMine(hit.Parent.Name)

			table.insert(MinesPlayers[v.Name], 1, hit.Parent.Name)
			
			-- If there was no players in the mines, there is now one (used for the mobs)
			if not PlayerInTheMine then
				PlayerInTheMine = true
				AttackmingMiners()
				coroutine.resume(coroutine.create(RespawnMiners))
			end
		end
	end)
end


-- PLAYER LEAVES THE GAME AND THUS LEAVES A MINE

Players.PlayerRemoving:Connect(function(plr)
	OutOfMine(plr.Name)
end)


-- PLAYER GOES IN THE ELEVATOR

for i,v in ipairs(Mines.Elevators.Triggers:GetChildren()) do
	v.Touched:Connect(function(hit)
		if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) then
			MinesRemoteEvent:FireClient(Players:FindFirstChild(hit.Parent.Name), "Elevator")
		end
	end)
end



-- PLAYER TOUCHES THE LAVA AT THE COBALT LAYER

for i,v in ipairs(Mines.CobaltLayer.Lava.KillParts:GetChildren()) do
	v.Touched:Connect(function(hit)
		if hit.Parent then
			if table.find(MinesPlayers["Cobalt"], hit.Parent.Name) then -- if the player is in the cobalt mine
				
				-- Kill or damage the player based on his health
				if hit.Parent:FindFirstChild("Humanoid").Health > 1 and Players:FindFirstChild(hit.Parent.Name) then -- make the sure it's a player to not kill a miner
					
					-- If the player doesn't have the lavalord pet equipped
					if Players:FindFirstChild(hit.Parent.Name):FindFirstChild("PetCustomisations")
					and Players:FindFirstChild(hit.Parent.Name):FindFirstChild("PetCustomisations"):FindFirstChild("EquippedPet")
					and Players:FindFirstChild(hit.Parent.Name):FindFirstChild("PetCustomisations"):FindFirstChild("EquippedPet").Value ~= "Lavalord" then
						hit.Parent:FindFirstChild("Humanoid"):TakeDamage(1)
					end
				else
					KillPlayer(Players:FindFirstChild(hit.Parent.Name), Players:FindFirstChild(hit.Parent.Name).Character)
				end
			end
		end
	end)
end


-- MINING EVENT FIRED FROM THE CLIENT

MinesRemoteEvent.OnServerEvent:Connect(function(plr, Type, Param1)

	-- Player takes the elevator
	if Type == "Elevator" then

		local Layer = Param1

		if Mines.Elevators.Teleports:FindFirstChild(Layer) then
			plr.Character.HumanoidRootPart.CFrame = Mines.Elevators.Teleports:FindFirstChild(Layer).CFrame

			-- If there was no players in the mines, there is now one (used for the mobs)
			if not PlayerInTheMine then
				PlayerInTheMine = true
				AttackmingMiners()
			end

			-- Remove the player from any other layer
			OutOfMine(plr.Name)

			if MinesPlayers[Layer] then
				table.insert(MinesPlayers[Layer], 1, plr.Name)
			end
		end
	end
end)



-- SPAWN AND PATHFIND ALL AMETHYST MINERS

local function SpawnAmethystMiners(Wave)

	for i,v in ipairs(Wave:GetChildren()) do

		local Miner = ServerStorage.MiningTools.Miners.AmethystMiner:Clone()
		Miner:SetPrimaryPartCFrame(v.CFrame)
		Miner.Parent = workspace.Mines.AmethystLayer.Miners

		-- Miner damages the player when he touches him
		Miner.HumanoidRootPart.Touched:Connect(function(hit)
			if hit.Parent and Players:FindFirstChild(hit.Parent.Name) and hit.Parent:FindFirstChild("Humanoid") and Miner.HitCooldown.Value + 0.5 < tick() then
				Miner.HitCooldown.Value = tick()

				-- Kill or damage the player based on his health
				if hit.Parent:FindFirstChild("Humanoid").Health > Miner.Damage.Value then
					hit.Parent:FindFirstChild("Humanoid"):TakeDamage(Miner.Damage.Value)
				else
					KillPlayer(Players:FindFirstChild(hit.Parent.Name), Players:FindFirstChild(hit.Parent.Name).Character)
				end

				-- If a sword is touching the miner, damage or kill him 
			elseif hit.Name == "Blade" and hit.Parent:FindFirstChild("Damage") then

				-- If the sword deals more damage than the miner's health, destroy and respawn him
				if hit.Parent:FindFirstChild("Damage").Value >= Miner.Humanoid.Health then
					Miner:Destroy() -- destroy the miner

					if Players:FindFirstChild(hit.Parent.Name) then
						
						MoneyBindableFunction:Invoke(Players:FindFirstChild(hit.Parent.Name), 98, "+")
						ExperienceBindableEvent:Fire(Players:FindFirstChild(hit.Parent.Name), "Hunter", 5)
					end

					-- Otherwise, damage him
				else
					Miner.Humanoid:TakeDamage(hit.Parent:FindFirstChild("Damage").Value)
				end
			end
		end)
	end
	
	-- Pathfind the miners
	while #workspace.Mines.AmethystLayer.Miners:GetChildren() ~= 0 do

		if #MinesPlayers["Amethyst"] > 0 then
			
			for i,v in ipairs(Mines.AmethystLayer.Miners:GetChildren()) do

				if #MinesPlayers["Amethyst"] > 0 and v:FindFirstChild("Humanoid") then

					local ClosestPlayer = MinesPlayers["Amethyst"][1]
					local ClosestDistance = math.abs((Players:FindFirstChild(MinesPlayers["Amethyst"][1]).Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude)

					for y,w in pairs(MinesPlayers["Amethyst"]) do
						if Players:FindFirstChild(w) then
							if math.abs((Players:FindFirstChild(w).Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude) < ClosestDistance then
								ClosestDistance = math.abs((Players:FindFirstChild(w).Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude)
							end
						end
					end

					if ClosestDistance < 35 and workspace:FindFirstChild(ClosestPlayer) then

						local goalPosition = Vector3.new(workspace:FindFirstChild(ClosestPlayer).HumanoidRootPart.Position.X, workspace:FindFirstChild(ClosestPlayer).HumanoidRootPart.Position.Y, workspace:FindFirstChild(ClosestPlayer).HumanoidRootPart.Position.Z)

						local path = PathfindingService:CreatePath({WaypointSpacing = 5})
						path:ComputeAsync(v.HumanoidRootPart.Position, goalPosition)
						local waypoints = path:GetWaypoints()
						
						if path.Status == Enum.PathStatus.Success then
							for _, waypoint in pairs(waypoints) do
								if v:FindFirstChild("Humanoid") then
									v.Humanoid:MoveTo(waypoint.Position)
								end
							end
						end
					end
				end

				RunService.Heartbeat:Wait()
			end
		end
		RunService.Heartbeat:Wait()
	end
end


-- MINECARTS ARRIVED AT THE MIDDLE

local function AmethystMinecartEventStart(Minecart)

	-- Stop wheels rotation + anchor minecart
	for i,v in ipairs(Minecart.Wheels:GetChildren()) do
		v.BodyAngularVelocity.AngularVelocity = Vector3.new(0,0,0)
	end

	--Minecart.Cart.Floor.Anchored = true

	Minecart.Cart.AmethystLoad.Touched:Connect(function(hit)
		if hit.Parent:FindFirstChild("Efficiency") and hit.Parent:FindFirstChild("ToolActivated") and hit.Parent:FindFirstChild("ToolActivated").Value == true then -- if it's a pickaxe

			hit.Parent.ToolActivated.Value = false -- tool is not activated anymore (to avoid hitting multiple times at once)

			-- Decrease ore toughness
			Minecart.Cart.AmethystLoad.Toughness.Value -= hit.Parent:FindFirstChild("Efficiency").Value

			-- Break ore 
			if Minecart.Cart.AmethystLoad.Toughness.Value <= 0 then

				Minecart:Destroy() -- destroy the minecart

				if not Mines.AmethystLayer.Track1:FindFirstChild("Minecart1") and not Mines.AmethystLayer.Track2:FindFirstChild("Minecart2") then
					AmethystMinecartEnded = true
				end

				-- Give the ores to the player
				if Players:FindFirstChild(hit.Parent.Parent.Name) and Players:FindFirstChild(hit.Parent.Parent.Name).Mining.Ores.Amethyst then
					Players:FindFirstChild(hit.Parent.Parent.Name).Mining.Ores.Amethyst.Value += 150
					MiningBindableEvent:Fire(Players:FindFirstChild(hit.Parent.Parent.Name), "Ores", "Amethyst") -- fire the datastore to save the number of ores the player has
				end		
				
			-- First wave of miners (2)
			elseif not Wave1 and Minecart.Cart.AmethystLoad.Toughness.Value >= 140 then
				Wave1 = true
				coroutine.resume(coroutine.create(SpawnAmethystMiners), Mines.AmethystLayer.Wave1)
				
			-- Second wave of miners (4)
			elseif not Wave2 and Minecart.Cart.AmethystLoad.Toughness.Value <= 90 then
				Wave2 = true
				coroutine.resume(coroutine.create(SpawnAmethystMiners), Mines.AmethystLayer.Wave2)
				
			-- Third wave of miners (8)
			elseif not Wave3 and Minecart.Cart.AmethystLoad.Toughness.Value <= 40 then
				Wave3 = true
				coroutine.resume(coroutine.create(SpawnAmethystMiners), Mines.AmethystLayer.Wave3)				
			end
		end
	end)
end



-- AMETHYST MINECART EVENT

local function AmethystMinecart()

	for i=1,2 do

		if AmethystMinecarts:FindFirstChild("Minecart"..i) and Mines.AmethystLayer:FindFirstChild("Track"..i) then

			local AmethystMinecartClone = AmethystMinecarts:FindFirstChild("Minecart"..i):Clone()

			-- Make the minecart move towards the middle
			for a,b in ipairs(AmethystMinecartClone.Wheels:GetChildren()) do
				-- Different AngularVelocity based on where it's coming from
				if i == 1 then
					b.BodyAngularVelocity.AngularVelocity = Vector3.new(0,0,10)
				else
					b.BodyAngularVelocity.AngularVelocity = Vector3.new(-10.2,0,0)
				end
			end

			AmethystMinecartClone.Parent = Mines.AmethystLayer:FindFirstChild("Track"..i)

			-- Minecart touch the middle
			local connection

			connection = Mines.AmethystLayer:FindFirstChild("Track"..i).MiddleTrigger.Touched:Connect(function(hit)
				if hit.Name == "Floor" and hit.Parent.Parent.Name == "Minecart"..i then
					connection:Disconnect()
					AmethystMinecartEventStart(hit.Parent.Parent)
				end
			end)
		end
	end
end


-- AMETHYST MINECART TIMER

coroutine.wrap(function()
	while true do
		for i=1800,0,-1 do -- wait 30 minutes (1800 seconds)
			local Time = ""
			local Minutes = math.floor(i/60)
			local Seconds = i%60

			if Minutes < 10 then
				Time = Time.."0"..tostring(Minutes).." : "
			else
				Time = Time..tostring(Minutes).." : "
			end

			if Seconds < 10 then
				Time = Time.."0"..tostring(Seconds)
			else
				Time = Time..tostring(Seconds)
			end

			Mines.AmethystLayer.Track1.Next.SurfaceGui.Timer.Text = Time -- set the timers text
			Mines.AmethystLayer.Track2.Next.SurfaceGui.Timer.Text = Time
			wait(1)
		end

		-- Start the event if there is someone in the amethyst mine, otherwise skip it
		if #MinesPlayers["Amethyst"] == 0 then
			AmethystMinecartEnded = true
		else
			AmethystMinecart()
		end

		repeat wait(10) until AmethystMinecartEnded == true -- wait for the event to end (players taking the ores)
		AmethystMinecartEnded = false -- restart the event
	end
end)()