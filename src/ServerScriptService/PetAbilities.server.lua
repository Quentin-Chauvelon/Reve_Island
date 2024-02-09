local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")
local WarnBindableEvent = ServerStorage:WaitForChild("Warn")
local EquipPetBindableEvent = ServerStorage:WaitForChild("EquipPet")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AbilitiesRemoteFunction = ReplicatedStorage:WaitForChild("Abilities")

local PlayerList = {}
local SizeProperties = {"BodyDepthScale", "BodyHeightScale", "BodyProportionScale", "BodyTypeScale", "BodyWidthScale", "HeadScale"}
local CooldownTime = 0


-- CREATE THE TABLE FOR EACH PLAYER

Players.PlayerAdded:Connect(function(plr)
	PlayerList[plr.Name] = {}
	table.insert(PlayerList[plr.Name], 1, 0)
	table.insert(PlayerList[plr.Name], 2, 0)
end)

Players.PlayerRemoving:Connect(function(plr)
	PlayerList[plr.Name] = nil
end)


-- SET COOLDOWN ABILITY

local function CoolDown(plr, Ability, Time)
	if PlayerList[plr.Name] and PlayerList[plr.Name][Ability] then
		PlayerList[plr.Name][Ability] = Time
	end
end


-- TELEPORT PLAYER

local function Teleport(Character, TeleportPart)
	if TeleportPart and Character:FindFirstChild("HumanoidRootPart") then
		Character:FindFirstChild("HumanoidRootPart").CFrame = TeleportPart.CFrame
	end
end


-- SPAWN TRAMPOLINE
local function SpawnTrampoline(HumanoidRootPart)
	if HumanoidRootPart then
		local Trampoline = ServerStorage.Trampoline:Clone()
		Trampoline.Parent = workspace
		Trampoline:MoveTo(HumanoidRootPart.Position + Vector3.new(15,5,0))
	end
end


-- STICK PLAYER TO CEILING

local function StickToCeiling(Character, Humanoid)
	if Character:FindFirstChild("Head") and Humanoid then
		if Character:FindFirstChild("Head"):FindFirstChild("BodyVelocity") then
			Character:FindFirstChild("Head"):FindFirstChild("BodyVelocity"):Destroy()

		else
			local RayCastResult = workspace:Raycast(Character:FindFirstChild("Head").Position + Vector3.new(0, 2, 0), Vector3.new(0, 30, 0))
			if RayCastResult then

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(0,4000,0)
				BodyVelocity.Velocity = Vector3.new(0,15,0)
				BodyVelocity.Parent = Character:FindFirstChild("Head")

				local HeadHit
				HeadHit = Character:FindFirstChild("Head").Touched:Connect(function()
					HeadHit:Disconnect()
					BodyVelocity.Velocity = Vector3.new(0,0,0)
				end)
			end
		end
	end
end


-- FLY

local function Fly(HumanoidRootPart, Duration)
	if HumanoidRootPart then
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Name = "FlyBV"
		BodyVelocity.MaxForce = Vector3.new(0,4000,0)
		BodyVelocity.Velocity = Vector3.new(0,0,0)
		BodyVelocity.Parent = HumanoidRootPart
		Debris:AddItem(BodyVelocity, Duration)
	end
end


-- PET ABILITIES

AbilitiesRemoteFunction.OnServerInvoke = function(plr, Ability)
		
	if Ability and typeof(Ability) == "number" then
		
		local Pet = plr.PetCustomisations.EquippedPet.Value -- get the equipped pet
		local Character = plr.Character

		if Pet and Character then -- check if character
			if Character:FindFirstChild(Pet) and not plr.PetAbilitiesDisabled.Value then

				local Humanoid = Character:FindFirstChild("Humanoid")

				if Humanoid then -- check if humanoid
										
					if Ability == 1 and PlayerList[plr.Name][1] <= 0 then -- if player clicked the ability 1

						if Pet == "Alien" then
							Teleport(Character, workspace.PetTeleport.Spawn)

						elseif Pet == "Angel" then
							CoolDown(plr, 1, 70)
							CooldownTime = 70
							Fly(Character:FindFirstChild("HumanoidRootPart"), 16)


						elseif Pet == "AquaDragon" then
							CoolDown(plr, 1, 70)
							CooldownTime = 70
							Fly(Character:FindFirstChild("HumanoidRootPart"), 16)

						elseif Pet == "Bat" then
							StickToCeiling(Character, Humanoid)
							
						elseif Pet == "Bee" then
							CoolDown(plr, 1, 63)
							CooldownTime = 63
							Fly(Character:FindFirstChild("HumanoidRootPart"), 4)
							

						elseif Pet == "Bull" then
							Teleport(Character, workspace.PetTeleport.Mines)									

						elseif Pet == "Crab" then
							Teleport(Character, workspace.PetTeleport.Port)

						elseif Pet == "Duck" then
							Teleport(Character, workspace.PetTeleport.Lake)

						elseif Pet == "Lightning" then
							CoolDown(plr, 1, 20)
							CooldownTime = 20
							
							if Character:FindFirstChild("HumanoidRootPart") then

								local boltParts = {}

								for i=1, math.random(4,8) do
									local maxRange = 5
									local heightOffset = 10
									local Head = Vector3.new(Character:FindFirstChild("HumanoidRootPart").Position.X + math.random(-30,30), math.random(100,200), Character:FindFirstChild("HumanoidRootPart").Position.Z + math.random(-30,30))

									while Head.Y > 0 do
										local angle = math.pi * 4 * math.random() -- 4 because I don't trust the random distribution
										local radius = math.random() * maxRange -- radius

										local dir = Vector3.new(math.cos(angle)*radius, -heightOffset, -math.sin(angle)*radius) -- converting the XY plane of a graph into the XZ plane of a part requires Z to be negative

										local Part = Instance.new("Part")
										Part.Color = Color3.fromRGB(255, 245, 206)
										Part.Material = Enum.Material.Neon
										Part.CanCollide = false
										Part.Anchored = true
										Part.Size = Vector3.new(1, 1, math.random(8,40)) -- component change to take advantage of CFrame's 2-vector construction method
										Part.CFrame = CFrame.new(Head,Head+dir)*CFrame.new(0,0,-Part.Size.Z/2) -- starting point, target point, and offset by half the length
										table.insert(boltParts,Part)
										Head = Part.CFrame*Vector3.new(0,0,-Part.Size.Z/2) -- move the head to the end of the part so we can continuously cast bolts
									end

									for _,part in ipairs (boltParts) do
										part.Parent = workspace
									end
								end
								
								coroutine.wrap(function()
									wait(0.2)
									for _,part in ipairs (boltParts) do
										part.Transparency = 1
									end
									wait(0.1)
									for _,part in ipairs (boltParts) do
										part.Transparency = 0
									end
									wait(0.15)
									for _,part in ipairs (boltParts) do
										part.Transparency = 1
									end
									wait(0.1)
									for _,part in ipairs (boltParts) do
										part.Transparency = 0
									end
									wait(0.15)
									for _,part in ipairs (boltParts) do
										part:Destroy()
									end
								end)()
							end
							
						elseif Pet == "LittleCreature" then
							Teleport(Character, workspace.Houses:FindFirstChild(plr.Name))
							
						elseif Pet == "LittleDragon" then
							CoolDown(plr, 1, 30)
							CooldownTime = 30

							if Character:FindFirstChild("Head") then
								local FirePart = Instance.new("Part")
								FirePart.Size = Character:FindFirstChild("Head").Size
								FirePart.Position = Character:FindFirstChild("Head").Position
								FirePart.Orientation = Character:FindFirstChild("Head").Orientation + Vector3.new(-90,0,0)
								FirePart.CanCollide = false
								FirePart.Transparency = 1

								local WeldConstraint = Instance.new("WeldConstraint")
								WeldConstraint.Part0 = Character:FindFirstChild("Head")
								WeldConstraint.Part1 = FirePart
								
								local Fire = Instance.new("Fire")
								Fire.Heat = 20
								Fire.Size = 3
								Fire.TimeScale = 1
								
								FirePart.Parent = Character:FindFirstChild("Head")
								WeldConstraint.Parent = FirePart
								Fire.Parent = FirePart
								
								Debris:AddItem(FirePart, 5)
							end

						elseif Pet == "Ninja" then
							CoolDown(plr, 1, 70)
							CooldownTime = 70

							for _,v in ipairs(Character:GetChildren()) do
								if v:IsA("MeshPart") or v:IsA("Part") then
									v.Transparency = 1
								end
							end

							if Character:FindFirstChildWhichIsA("Accessory") and Character:FindFirstChildWhichIsA("Accessory"):FindFirstChild("Handle") then
								Character:FindFirstChildWhichIsA("Accessory"):FindFirstChild("Handle").Transparency = 1
							end

							coroutine.wrap(function()
								wait(10)
								for _,v in ipairs(Character:GetChildren()) do
									if v:IsA("MeshPart") or v:IsA("Part") and v.Name ~= "HumanoidRootPart" then
										v.Transparency = 0
									end
								end

								if Character:FindFirstChildWhichIsA("Accessory") and Character:FindFirstChildWhichIsA("Accessory"):FindFirstChild("Handle") then
									Character:FindFirstChildWhichIsA("Accessory"):FindFirstChild("Handle").Transparency = 0
								end									
							end)()

						elseif Pet == "Panda" then
							Teleport(Character, workspace.PetTeleport.Forest)

						elseif Pet == "Pig" then
							Teleport(Character, workspace.PetTeleport.Farms)
							
						elseif Pet == "PsychicScorpion" then
							if Character:FindFirstChild("HumanoidRootPart") then
								Character:MoveTo(Vector3.new(math.random(-1250,1250), 150, math.random(-1250,1250)))
							end
							
						elseif Pet == "Reindeer" then
							
							if Character:FindFirstChild("HumanoidRootPart")
							and Character:FindFirstChild("HumanoidRootPart").Position.Z > 730 and Character:FindFirstChild("HumanoidRootPart").Position.Z < 1730
							and Character:FindFirstChild("HumanoidRootPart").Position.X > -1730 and Character:FindFirstChild("HumanoidRootPart").Position.X < 970 then
								CoolDown(plr, 1, 20)
								CooldownTime = 20
								
								Fly(Character:FindFirstChild("HumanoidRootPart"), 21)
							end
							
						elseif Pet == "Snowman" then
							if Character:FindFirstChild("HumanoidRootPart") then
								local SnowBall = ServerStorage.SnowBall:Clone()
								SnowBall.Position = Character:FindFirstChild("HumanoidRootPart").Position + (Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * Vector3.new(5,5,5))
								-- Throw a snowball where the player is looking and add a gravity of -1 so that it touches the ground at some point and doesn't fly forever
								SnowBall.BodyVelocity.Velocity = Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * Vector3.new(50,0,50) - Vector3.new(0,0.2,0)
								SnowBall.Parent = workspace
								
								Debris:AddItem(SnowBall, 6)
								
								-- Hide the snowball and add particles to make it look like a splash when it hit something
								SnowBall.Touched:Connect(function()
									if SnowBall:FindFirstChild("ParticleEmitter") then
										SnowBall.Transparency = 1
										SnowBall:FindFirstChild("ParticleEmitter"):Emit(20)
									end
								end)
							end

						elseif Pet == "Wizard" then
							CoolDown(plr, 1, 60)
							CooldownTime = 60

							local RandomEffect = math.random(1,2)

							-- Either change the speed or the size of the character
							if RandomEffect == 1 then
								-- Faster or slower
								Humanoid.WalkSpeed = math.random(10, 30)
							else
								-- Bigger or smaller
								local Scale = (math.random(5, 15) / 10)
								for _, property in pairs(SizeProperties) do
									if Humanoid:FindFirstChild(property) then
										Humanoid:FindFirstChild(property).Value = Scale
									end
								end
							end
						end


					elseif Ability == 2 and PlayerList[plr.Name][2] <= 0 then
						
						if Pet == "Alien" then
							CoolDown(plr, 2, 30)
							CooldownTime = 30
							
						elseif Pet == "Fox" then
							CoolDown(plr, 2, 100)
							CooldownTime = 100
							SpawnTrampoline(Character:FindFirstChild("HumanoidRootPart"))

						elseif Pet == "Gumdrop" then
							Teleport(Character, workspace.PetTeleport.Casino)

						elseif Pet == "IceGolem" then
							CoolDown(plr, 2, 150)
							CooldownTime = 150
							
							if Character:FindFirstChild("HumanoidRootPart") then
								local IcePart = ServerStorage.IcePart:Clone()
								IcePart.Parent = workspace
								IcePart:MoveTo(Character:FindFirstChild("HumanoidRootPart").Position + Vector3.new(20,0,0))
								
								-- Destroy the ice part after 30 seconds
								Debris:AddItem(IcePart, 30)
							end

						elseif Pet == "LigthBat" then
							StickToCeiling(Character, Humanoid)
							
						elseif Pet == "MythicalDemon" then
							CoolDown(plr, 2, 80)
							CooldownTime = 80
							
							if Character:FindFirstChild("LeftFoot") then
								local Fireworks = ServerStorage.Fireworks:Clone()
								Fireworks:SetPrimaryPartCFrame(Character:FindFirstChild("LeftFoot").CFrame)
								
								for i,v in ipairs(Fireworks:GetChildren()) do
									v.Position += Vector3.new(math.random(-30,30), 0, math.random(-30,30))
									v.Orientation = Vector3.new(0,0,90)
									v.Anchored= false
								end
								
								Fireworks.Parent = workspace
								Debris:AddItem(Fireworks, 11)
								
								coroutine.wrap(function()
									wait(5)
									for i,v in ipairs(Fireworks:GetChildren()) do
										if v:FindFirstChild("ParticleEmitter") then
											v.Transparency = 1
											v:FindFirstChild("ParticleEmitter"):Emit(500)
										end
									end
								end)()
							end

						elseif Pet == "Ninja" then
							CoolDown(plr, 2, 45)
							CooldownTime = 45
							
							Humanoid.WalkSpeed = 100
							
							coroutine.wrap(function()
								wait(5)
								Humanoid.WalkSpeed = 20
							end)()

						elseif Pet == "PsychicScorpion" then
							CoolDown(plr, 2, 100)
							CooldownTime = 100
							SpawnTrampoline(Character:FindFirstChild("HumanoidRootPart"))
							
						elseif Pet == "Reindeer" then
							Teleport(Character, workspace.PetTeleport.Mountain)
							
						elseif Pet == "Star" then
							CoolDown(plr, 2, 120)
							CooldownTime = 120
						end
					end
				end
			end
		end
	end		

	return CooldownTime -- return the time the client should wait
end


-- COOLDOWN AFTER ACTIVATING AN ABILITY

coroutine.wrap(function()
	while wait(1) do
		for i, v in next, PlayerList do
			if v[1] > 0 then
				v[1] -= 1
			end

			if v[2] > 0 then
				v[2] -= 1
			end
		end
	end	
end)()





--local function EquipPet(plr, Pet, OldPet)


--	local Character = workspace:FindFirstChild(plr.Name)

--	local Humanoid = nil
--	if Character then
--		Humanoid = Character:FindFirstChild("Humanoid")
--	end

--	if Humanoid then

--	if Pet then

--	end
--end


--Players.PlayerAdded:Connect(function(plr)

--	repeat wait(1) until plr:FindFirstChild("PetCustomisations"):FindFirstChild("EquippedPet")	
--	repeat wait(1) until workspace:FindFirstChild(plr.Name):FindFirstChild("Humanoid")
--	repeat wait(1) until plr:FindFirstChild("Stats"):FindFirstChild("MoneyMultiplier")

--	workspace[plr.Name].Humanoid.WalkSpeed = 20 -- set the default walkspeed to 20

--	EquipPet(plr, plr.PetCustomisations.EquippedPet.Value, nil)

--	--wait(10)
--	--game.ReplicatedStorage.Abilities:FireClient(game.Players.Freez491, "1", 1)
--	--wait(3)
--	--game.ReplicatedStorage.Abilities:FireClient(game.Players.Freez491, "1", 5)
--	--wait(7)
--	--game.ReplicatedStorage.Abilities:FireClient(game.Players.Freez491, "1", 10)
--end)


---- PLAYER EQUIPS A PET

--EquipPetBindableEvent.Event:Connect(EquipPet)