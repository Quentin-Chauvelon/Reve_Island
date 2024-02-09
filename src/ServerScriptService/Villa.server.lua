local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local VillaCard = ServerStorage:WaitForChild("Villa"):WaitForChild("Card")
local LasersTemplate = ServerStorage.Villa:WaitForChild("Lasers")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local ExperienceBindableEvent = ServerStorage:WaitForChild("Experience")
local AbilitiesBindableEvent = ServerStorage:WaitForChild("Abilities")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VillaRemoteEvent = ReplicatedStorage:WaitForChild("Villa")

local Villa = workspace.Villa
local Tiles = Villa.Basement.FallingTiles.Tiles
local TilesToKeep = Villa.Basement.FallingTiles.TilesToKeep
local Activators = Villa.Basement.FallingTiles.Activators

local PlayerList = {}
local CardTable = {}
local BasementTable = {}
local ActivatorsTable = {}
local VaultTable = {}

local Spike1Crush = TweenService:Create(Villa.Basement.Spikes.Spike1, TweenInfo.new(0.5), {CFrame = Villa.Basement.Spikes.Spike1Crushed.CFrame})
local Spike2Crush = TweenService:Create(Villa.Basement.Spikes.Spike2, TweenInfo.new(0.5), {CFrame = Villa.Basement.Spikes.Spike2Crushed.CFrame})
local Spike3Crush = TweenService:Create(Villa.Basement.Spikes.Spike3, TweenInfo.new(0.5), {CFrame = Villa.Basement.Spikes.Spike3Crushed.CFrame})
local Spike1Return = TweenService:Create(Villa.Basement.Spikes.Spike1, TweenInfo.new(0.5), {CFrame = Villa.Basement.Spikes.Spike1Placement.CFrame})
local Spike2Return = TweenService:Create(Villa.Basement.Spikes.Spike2, TweenInfo.new(0.5), {CFrame = Villa.Basement.Spikes.Spike2Placement.CFrame})
local Spike3Return = TweenService:Create(Villa.Basement.Spikes.Spike3, TweenInfo.new(0.5), {CFrame = Villa.Basement.Spikes.Spike3Placement.CFrame})

local SpikesRunning = false
local FallingTilesRunning = false
local TrapdoorTrigger, JumpKillPart, SpikesTrigger, Spike1Kill, Spike2Kill, Spike3Kill, WrapAroundTrigger, WrapAroundKillPart,
MazeTrigger, TilesKillPart, Activator1Touched, Activator2Touched, Activator3Touched, Activator4Touched


-- KILL PLAYER (BUT DON'T REALLY KILL, JUST TELEPORT HIM, REMOVE HIM FROM TABLE...)

local function KillPlayer(plr)
	if plr then
		if BasementTable[plr.Name] then
			BasementTable[plr.Name] = nil
		end
		
		-- Reenable the player's pet abilities
		plr.PetAbilitiesDisabled.Value = false
		AbilitiesBindableEvent:Fire(plr, false)
		
		if workspace:FindFirstChild(plr.Name) then
			workspace[plr.Name].HumanoidRootPart.CFrame = workspace.Spawn.Spawns.SpawnLocation.CFrame
		end
	end
end


-- DESTROY THE LASERS WHEN THE PLAYER TOUCHES ONE OF THE LASERS, FALLS OFF OF THE JUMP OR REACHES THE SPIKES TRIGGER

local function DestroyLasers()

	-- If there are no other players in the basement, destroy the lasers
	if #BasementTable ~= 0 then
		local PlayerInBasement1 = false
		for i,v in pairs(BasementTable) do
			if v == 1 then
				PlayerInBasement1 = true
			end
		end

		-- Destroy the lasers
		if not PlayerInBasement1 then
			if Villa.Basement:FindFirstChild("Lasers") then
				Villa.Basement.Lasers:Destroy()
			end

			-- Disconnect the jump kill part
			if JumpKillPart then
				JumpKillPart:Disconnect()
			end

			-- Disconnect the spikes trigger
			if SpikesTrigger then
				SpikesTrigger:Disconnect()
			end
		end
	end
end


-- STOP THE SPIKES IF PLAYER TOUCHES ONE OF THEM OR IF HE REACHES THE WRAP AROUND CHECKPOINT

local function StopSpikes()
	SpikesRunning = false

	-- If there are no other players in the basement, stop the spikes
	if #BasementTable ~= 0 then
		local PlayerInBasement2 = false
		for i,v in pairs(BasementTable) do
			if v == 2 then
				PlayerInBasement2 = true
			end
		end

		-- disconnect all the events
		if not PlayerInBasement2 then
			if Spike1Kill then
				Spike1Kill:Disconnect()
			end

			if Spike2Kill then
				Spike2Kill:Disconnect()
			end

			if Spike3Kill then
				Spike3Kill:Disconnect()
			end

			if WrapAroundTrigger then
				WrapAroundTrigger:Disconnect()
				WrapAroundTrigger = nil
			end
		end
	end
end


-- PLAYER TOUCHES THE WRAP AROUND KILL PART OR TOUCHES THE MAZE TRIGGER

local function StopWrapAroundKill()

	-- If there are no other players in the basement, stop the wrap around kill
	if #BasementTable ~= 0 then
		local PlayerInBasement3 = false
		for i,v in pairs(BasementTable) do
			if v == 3 then
				PlayerInBasement3 = true
			end
		end

		-- Disconnect all the events
		if not PlayerInBasement3 then
			if WrapAroundKillPart then
				WrapAroundKillPart:Disconnect()
				WrapAroundKillPart = nil
			end

			if MazeTrigger then
				MazeTrigger:Disconnect()
			end
		end
	end
end


-- STOP FALLING TILES IF THE PLAYER TOUCHES THE KILL PART OR IF ACTIVATES ALL THE ACTIVATORS

local function StopFallingTiles()

	-- If the activator table is empty, disconnect all the events
	if not next(ActivatorsTable) then
		if TilesKillPart then
			TilesKillPart:Disconnect()
		end

		if Activator1Touched and Activator2Touched and Activator3Touched and Activator4Touched then
			Activator1Touched:Disconnect()
			Activator2Touched:Disconnect()
			Activator3Touched:Disconnect()
			Activator4Touched:Disconnect()
		end

		-- Deactivate the falling tiles
		FallingTilesRunning = false
	end
end


-- CHECK IF PLAYER ACTVATED ALL ACTIVATORS

local function ActivatedAllActivators(plr)
	for i,v in pairs(ActivatorsTable[plr.Name]) do

		-- If one of them is not activated, return
		if v == false then
			return
		end
	end

	-- Remove the player from the activator table
	ActivatorsTable[plr.Name] = nil

	StopFallingTiles()

	-- Add the player to the vault table so that when the player fires the remote event, he can get the money
	table.insert(VaultTable, plr.Name)

	-- Fire client to open the vault
	VillaRemoteEvent:FireClient(plr, "Vault")
end


-- PLAYER TOUCHES THE TRIGGER TO START THE ROBBERY

for i,v in ipairs(Villa.Triggers:GetChildren()) do
	v.Touched:Connect(function(hit)

		if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) then

			-- If there players that are supposed to be looking for a card, but they have disconnected, disconnect the trapdoor trggier touched event
			if #CardTable ~= 0 then
				local AllPlayersDisconnected = true

				for i,v in pairs(CardTable) do
					if Players:FindFirstChild(v) then
						AllPlayersDisconnected = false
					end
				end

				if AllPlayersDisconnected and TrapdoorTrigger then
					TrapdoorTrigger:Disconnect()
					TrapdoorTrigger = nil
				end
			end
			
			-- Check if players disconnect before finishing or dying (because things are then running while they shouldn't be) and remove him from the table and disconnect all events...
			for i,v in pairs(BasementTable) do
				if not Players:FindFirstChild(i) then
					BasementTable[i] = nil
					DestroyLasers()
					StopSpikes()
					StopWrapAroundKill()
				end
			end
			
			for i,v in pairs(ActivatorsTable) do
				if not Players:FindFirstChild(i) then
					ActivatorsTable[i] = nil
					StopFallingTiles()
				end
			end
			
			for i,v in pairs(VaultTable) do
				if not Players:FindFirstChild(v) then
					local Position = table.find(VaultTable, v)
					if Position then
						table.remove(VaultTable, Position)
					end
				end 
			end

			PlayerList[Players[hit.Parent.Name].Name] = os.time() 
			VillaRemoteEvent:FireClient(Players[hit.Parent.Name], "Start")
		end
	end)
end


-- REMOTE EVENT FIRED FROM THE CLIENT

VillaRemoteEvent.OnServerEvent:Connect(function(plr, Type)

	if Type and typeof(Type) == "string" then

		if Type == "Card" then
			-- If player hasn't taken less than 15 seconds to reach the card stage
			if PlayerList[plr.Name] and PlayerList[plr.Name] + 15 < os.time() then

				-- Remove the player from the player list and add him to the CardTable (to keep track of where the player is)
				PlayerList[plr.Name] = nil
				table.insert(CardTable, plr.Name)

				-- Clone the card and place it randomly in the house
				local CardClone = VillaCard:Clone()
				
				-- When a player touches the tool (picks it up)
				CardClone.Handle.Touched:Connect(function(hit)
					
					-- If the player is already holding a card
					--if hit.Parent:FindFirstChildOfClass("Tool") and hit.Parent:FindFirstChildOfClass("Tool").Name == "Card" then
					--	-- Put it back in the villa
					--	hit.Parent:FindFirstChildOfClass("Tool").Handle.AssemblyLinearVelocity = Vector3.new(0,0,0)
					--	CardClone.Parent = Villa.Cards
					--end
					
					-- If the player already has a card in his backpack
					--if Players:FindFirstChild(hit.Parent.Name) then
					--	local NumberOfCards = 0
						
					--	for i,v in ipairs(Players[hit.Parent.Name].Backpack:GetChildren()) do
							
					--		-- Count the number of cards the player has
					--		if v.Name == "Card" then
					--			NumberOfCards += 1
					--		end
					--	end
						
					--	-- If the player has more than 1 card, put one back in the villa
					--	if NumberOfCards > 1 then
					--		Players[hit.Parent.Name].Backpack.Card.Parent = Villa.Cards
					--	end
					--end
					
					-- If the player already has a card in his backpack, throw it
					if Players:FindFirstChild(hit.Parent.Name) and Players[hit.Parent.Name].Backpack:FindFirstChild("Card") then
						Players[hit.Parent.Name].Backpack.Card.Handle.AssemblyLinearVelocity = Vector3.new(0,0,0)
						Players[hit.Parent.Name].Backpack.Card.Parent = Villa.Cards
					end
				end)
				
				local CardsPlacement = Villa.CardsPlacement:GetChildren()
				CardClone.Handle.CFrame = CardsPlacement[math.random(1, #CardsPlacement)].CFrame
				CardClone.Parent = Villa.Cards

				-- When the player touches the trapdoor trigger, if he is holding the card, he can go to the next stage
				if not TrapdoorTrigger then
					TrapdoorTrigger = Villa.TrapdoorTrigger.Touched:Connect(function(hit)
						if hit.Name == "HumanoidRootPart" and hit.Parent:FindFirstChild("Card") and hit.Parent.Card:IsA("Tool") and Players:FindFirstChild(hit.Parent.Name) then
							-- Fire the remote event for the basement animation
							VillaRemoteEvent:FireClient(Players[hit.Parent.Name], "Card")
							
							-- Disable the player's pet abilities
							plr.PetAbilitiesDisabled.Value = true
							AbilitiesBindableEvent:Fire(plr, true)

							hit.Parent.Card:Destroy()

							-- Remove the player from the card table and if there are no other players, disconnect the trapdoor trigger touched event
							if table.find(CardTable, Players[hit.Parent.Name].Name) then
								table.remove(CardTable, table.find(CardTable, Players[hit.Parent.Name].Name))
								BasementTable[Players[hit.Parent.Name].Name] = 1

								if #CardTable == 0 then
									TrapdoorTrigger:Disconnect()
									TrapdoorTrigger = nil
								end

								-- If there is no one in the basement, create all the lasers to kill player + detect if the player falls off of the jump, or if he reaches the spikes trigger
								if not Villa.Basement:FindFirstChild("Lasers") then
									local Lasers = LasersTemplate:Clone()

									for i,v in ipairs(Lasers:GetChildren()) do
										v.Touched:Connect(function(hit)

											if Players:FindFirstChild(hit.Parent.Name) then
												KillPlayer(Players[hit.Parent.Name])
												DestroyLasers()
											end
										end)
									end

									Lasers.Parent = Villa.Basement

									-- Player falls off of the jump
									JumpKillPart = Villa.Basement.Jump.KillPart.Touched:Connect(function(hit)
										if Players:FindFirstChild(hit.Parent.Name) then
											KillPlayer(Players[hit.Parent.Name])
											DestroyLasers()
										end
									end)

									if not SpikesRunning then
										-- Player reaches the spikes trigger
										SpikesTrigger = Villa.Basement.Spikes.SpikesTrigger.Touched:Connect(function(hit)
											if Players:FindFirstChild(hit.Parent.Name) then

												-- Change the stage the player is at
												if BasementTable[hit.Parent.Name] then
													BasementTable[hit.Parent.Name] = 2
												end

												DestroyLasers()


												-- SPIKES

												if not SpikesRunning then
													-- Start the spikes
													SpikesRunning = true

													coroutine.wrap(function()
														repeat
															Spike1Crush:Play()
															Spike2Crush:Play()
															Spike3Crush:Play()
															wait(0.5)
															Spike1Return:Play()
															Spike2Return:Play()
															Spike3Return:Play()
															wait(1)
														until not SpikesRunning
													end)()

													Spike1Kill = Villa.Basement.Spikes.Spike1.Touched:Connect(function(hit)
														if Players:FindFirstChild(hit.Parent.Name) then
															KillPlayer(Players[hit.Parent.Name])
															StopSpikes()
														end
													end)

													Spike2Kill = Villa.Basement.Spikes.Spike2.Touched:Connect(function(hit)
														if Players:FindFirstChild(hit.Parent.Name) then
															KillPlayer(Players[hit.Parent.Name])
															StopSpikes()
														end
													end)

													Spike3Kill = Villa.Basement.Spikes.Spike3.Touched:Connect(function(hit)
														if Players:FindFirstChild(hit.Parent.Name) then
															KillPlayer(Players[hit.Parent.Name])
															StopSpikes()
														end
													end)

													if not WrapAroundTrigger then
													WrapAroundTrigger = Villa.Basement.WrapAround.WrapAroundTrigger.Touched:Connect(function(hit)


															-- Change the stage the player is at
															if BasementTable[hit.Parent.Name] then
																BasementTable[hit.Parent.Name] = 3
															end

															StopSpikes()


															-- WRAP AROUND

															if not WrapAroundKillPart then
																WrapAroundKillPart = Villa.Basement.WrapAround.WrapAroundKillPart.Touched:Connect(function(hit)
																	if Players:FindFirstChild(hit.Parent.Name) then
																		KillPlayer(Players[hit.Parent.Name])
																		StopWrapAroundKill()
																	end
																end)

																MazeTrigger = Villa.Basement.Maze.MazeTrigger.Touched:Connect(function(hit)
																	if Players:FindFirstChild(hit.Parent.Name) then
																		StopWrapAroundKill()



																		-- FALLING TILES

																		if not FallingTilesRunning then

																			FallingTilesRunning = true

																			TilesKillPart = Villa.Basement.FallingTiles.KillPart.Touched:Connect(function(hit)
																				if Players:FindFirstChild(hit.Parent.Name) then
																					KillPlayer(Players[hit.Parent.Name])

																					if ActivatorsTable[hit.Parent.Name] then
																						ActivatorsTable[hit.Parent.Name] = nil
																					end

																					StopFallingTiles()
																				end
																			end)

																			-- Player touches the activators
																			Activator1Touched = Activators.Activator1.Activator.Touched:Connect(function(hit)
																				if Players:FindFirstChild(hit.Parent.Name) then
																					-- Player has activated the activator
																					if ActivatorsTable[hit.Parent.Name] and not ActivatorsTable[hit.Parent.Name][1] then
																						ActivatorsTable[hit.Parent.Name][1] = true
																						VillaRemoteEvent:FireClient(plr, "Activator", 1)

																						-- Check if he has activated all of them
																						ActivatedAllActivators(Players:FindFirstChild(hit.Parent.Name))
																					end
																				end
																			end)

																			Activator2Touched = Activators.Activator2.Activator.Touched:Connect(function(hit)
																				if Players:FindFirstChild(hit.Parent.Name) then

																					-- Player has activated the activator
																					if ActivatorsTable[hit.Parent.Name] and not ActivatorsTable[hit.Parent.Name][2] then
																						ActivatorsTable[hit.Parent.Name][2] = true

																						VillaRemoteEvent:FireClient(plr, "Activator", 2)

																						-- Check if he has activated all of them
																						ActivatedAllActivators(Players:FindFirstChild(hit.Parent.Name))
																					end
																				end
																			end)

																			Activator3Touched = Activators.Activator3.Activator.Touched:Connect(function(hit)
																				if Players:FindFirstChild(hit.Parent.Name) then

																					-- Player has activated the activator
																					if ActivatorsTable[hit.Parent.Name] and not ActivatorsTable[hit.Parent.Name][3] then
																						ActivatorsTable[hit.Parent.Name][3] = true

																						VillaRemoteEvent:FireClient(plr, "Activator", 3)

																						-- Check if he has activated all of them
																						ActivatedAllActivators(Players:FindFirstChild(hit.Parent.Name))
																					end
																				end
																			end)

																			Activator4Touched = Activators.Activator4.Activator.Touched:Connect(function(hit)
																				if Players:FindFirstChild(hit.Parent.Name) then

																					-- Player has activated the activator
																					if ActivatorsTable[hit.Parent.Name] and not ActivatorsTable[hit.Parent.Name][4] then
																						ActivatorsTable[hit.Parent.Name][4] = true

																						VillaRemoteEvent:FireClient(plr, "Activator", 4)

																						-- Check if he has activated all of them
																						ActivatedAllActivators(Players:FindFirstChild(hit.Parent.Name))
																					end
																				end
																			end)

																			coroutine.wrap(function()
																				repeat

																					-- Take 15 tiles to keep, move them to another folder and make them red
																					for i=1,15 do
																						local TilesChildren = Tiles:GetChildren()
																						local Tile = TilesChildren[math.random(1,#TilesChildren)]
																						Tile.BrickColor = BrickColor.new("Bright green")
																						Tile.Parent = TilesToKeep
																					end

																					wait(1.5)

																					-- Hide and uncancollide all the tiles left to remove
																					for i,v in ipairs(Tiles:GetChildren()) do
																						v.Transparency = 1
																						v.CanCollide = false
																					end

																					-- Make all the parts to keep beige
																					for i,v in ipairs(TilesToKeep:GetChildren()) do
																						v.BrickColor = BrickColor.new("Cashmere")
																					end

																					wait(2)

																					-- Show and cancollide all the tiles that were removed previously
																					for i,v in ipairs(Tiles:GetChildren()) do
																						v.Transparency = 0
																						v.CanCollide = true
																					end

																					-- Parent all the parts to keep back to the tiles folder
																					for i,v in ipairs(TilesToKeep:GetChildren()) do
																						v.Parent = Tiles
																					end

																				until not FallingTilesRunning
																			end)()
																		end

																		ActivatorsTable[hit.Parent.Name] = {false, false, false, false}
																	end
																end)
															end
														end)
													end
												end
											end
										end)
									end
								end
							end

						else
							-- Make the part next to the trapdoor red
							if Villa.TrapdoorLock.ClickPart.BrickColor ~= BrickColor.new("Really red") then
								coroutine.wrap(function()
									Villa.TrapdoorLock.ClickPart.BrickColor = BrickColor.new("Really red")
									wait(3)
									Villa.TrapdoorLock.ClickPart.BrickColor = BrickColor.new("Dark stone grey")
								end)()
							end
						end
					end)
				end
			end

		elseif Type == "Vault" then

			local Position = table.find(VaultTable, plr.Name)
			if Position then
				table.remove(VaultTable, Position)
				
				if workspace:FindFirstChild(plr.Name) and workspace[plr.Name]:FindFirstChild("HumanoidRootPart") then
					workspace[plr.Name].HumanoidRootPart.CFrame = workspace.Spawn.Spawns.SpawnLocation.CFrame
				end

				MoneyBindableFunction:Invoke(plr, 10000, "+")
				ExperienceBindableEvent:Fire(plr, "Thief", 40)

				plr.PetAbilitiesDisabled.Value = false
				AbilitiesBindableEvent:Fire(plr, false)
			end
		end
	end
end)


--ReplicatedStorage:WaitForChild("Test").OnServerEvent:Connect(function(plr, Type, Player, Value)
--	if Type == "Add" then
--		if Player == "Freez491" then
--			if not table.find(CardTable, "Freez491") then
--				table.insert(CardTable, "Freez491")
--			end
--		end

--		BasementTable[Player] = Value
--	else
--		BasementTable[Players] = nil
--	end
--end)