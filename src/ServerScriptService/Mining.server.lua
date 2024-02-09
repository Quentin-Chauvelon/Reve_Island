--[[
COLORS :
Coal : 99, 95, 98
Iron : 202, 203, 209	231 231 236
Olivine : 154, 185, 115
Amethyst : 191, 127, 255
Cobalt : 0, 106, 255	0 70 240
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local MiningBindableEvent = ServerStorage:WaitForChild("Mining")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local ExperienceBindableEvent = ServerStorage:WaitForChild("Experience")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MiningRemoteEvent = ReplicatedStorage:WaitForChild("Mining")

local Mines = workspace.Mines

local AllOresSpawned = false

local OresTable = {Stone = 0, Coal = 50, Iron = 200, Olivine = 750, Amethyst = 1600, Cobalt = 4250}
local PricesTable = {
	Swords = {Stone = 0, Coal = 4500, Iron = 10000, Olivine = 35000, Amethyst = 60000, Cobalt = 130000},
	Bow = 300000
}
local SellPrices = {Stone = 0, Coal = 25, Iron = 33, Olivine = 42, Amethyst = 55, Cobalt = 70}


-- GIVE A PICKAXE TO THE PLAYER

local function GivePickaxe(plr, char, Ore)
	if ServerStorage.MiningTools.Pickaxes:FindFirstChild(Ore.."Pickaxe") then

		if plr and char then

			for i,v in pairs(OresTable) do

				-- Destroy the other pickaxes that may be in the backpack or equipped
				if plr.Backpack:FindFirstChild(v.."Pickaxe") and v.."Pickaxe" ~= Ore.."Pickaxe" then
					plr.Backpack:FindFirstChild(v.."Pickaxe"):Destroy()
				end

				if char:FindFirstChild(v.."Pickaxe") and v.."Pickaxe" ~= Ore.."Pickaxe" then
					char:FindFirstChild(v.."Pickaxe"):Destroy()
				end

				if not plr.Backpack:FindFirstChild(Ore.."Pickaxe") and not char:FindFirstChild(Ore.."Pickaxe") then

					local PickaxeClone = ServerStorage.MiningTools.Pickaxes:FindFirstChild(Ore.."Pickaxe"):Clone()

					local Animation = char.Humanoid:LoadAnimation(PickaxeClone.Animation) -- load animation to the player

					-- Player uses the pickaxe
					PickaxeClone.Activated:Connect(function()
						if PickaxeClone.LastActivated.Value + 1 < tick() then
							PickaxeClone.LastActivated.Value = tick()
							PickaxeClone.ToolActivated.Value = true		
							Animation:Play()
						end
					end)

					PickaxeClone.Parent = plr.Backpack
				end
			end
		end
	end
end


-- GIVE A TOOL TO THE PLAYER

local function GiveTool(plr, char, Ore, ToolType)
	if ServerStorage.MiningTools:FindFirstChild(ToolType.."s"):FindFirstChild(Ore..ToolType) then
		
		if plr and char then

			for i,v in pairs(OresTable) do

				-- Destroy the other pickaxes that may be in the backpack or equipped
				if plr.Backpack:FindFirstChild(v..ToolType) and v..ToolType ~= Ore..ToolType then
					plr.Backpack:FindFirstChild(v..ToolType):Destroy()
				end

				if char:FindFirstChild(v..ToolType) and v..ToolType ~= Ore..ToolType then
					char:FindFirstChild(v..ToolType):Destroy()
				end
			end
			
			--if not plr.Backpack:FindFirstChild(Ore..ToolType) and not char:FindFirstChild(Ore..ToolType) then

			local ToolClone = ServerStorage.MiningTools:FindFirstChild(ToolType.."s"):FindFirstChild(Ore..ToolType):Clone()

			local Animation = nil
			if ToolClone:FindFirstChild("Animation") then
				Animation = char.Humanoid:LoadAnimation(ToolClone.Animation) -- load animation to the player
			end

			if Animation then
				if ToolType == "Pickaxe" then

					-- Player uses the pickaxe
					ToolClone.Activated:Connect(function()
						if ToolClone.LastActivated.Value + 1 < tick() then
							ToolClone.LastActivated.Value = tick()
							ToolClone.ToolActivated.Value = true	
							Animation:Play()
						end
					end)


				elseif ToolType == "Sword" then

					-- Player uses the sword
					ToolClone.Activated:Connect(function()
						Animation:Play()
					end)
				end
			end

			ToolClone.Parent = plr.Backpack -- put the tool in the player's backpack
			--end
		end
	end
end



-- GET ALL THE ORES MINERS CIRCLES TOUCHED EVENTS

for i,v in ipairs(Mines.OresMiners:GetChildren()) do
	if v:FindFirstChild("CircleIn") then
		v:FindFirstChild("CircleIn").Touched:Connect(function(hit)

			if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) then

				if Players:FindFirstChild(hit.Parent.Name).Mining.Pickaxes:FindFirstChild(v.Name).Value == true then

					local plr = Players:FindFirstChild(hit.Parent.Name)
					local char = workspace:FindFirstChild(plr.Name)

					GiveTool(plr, char, v.Name, "Pickaxe")

					-- If the player doesn't own the tool
				else
					MiningRemoteEvent:FireClient(Players:FindFirstChild(hit.Parent.Name), "GiveOres", v.Name) -- fire the client to show the give ores gui
				end
			end
		end)
	end
end


-- PLAYER FIRED THE MINING REMOTE EVENT

MiningRemoteEvent.OnServerEvent:Connect(function(plr, Type, Param1, Param2)

	-- Player is giving ores to the miners
	if Type == "GiveOres" then

		local Ore = Param1
		local Amount = Param2

		if Ore and Amount and typeof(Ore) == "string" and typeof(Amount) == "number" and OresTable[Ore] then -- if ore can be found in the ores table and amount is a number

			-- If player doesn't alreayd own the pickaxe
			if plr.Mining.Pickaxes:FindFirstChild(Ore) and plr.Mining.Pickaxes:FindFirstChild(Ore).Value == false then

				-- Player is not trying to give more ores that he has
				if plr.Mining.Ores:FindFirstChild(Ore) and Amount <= plr.Mining.Ores:FindFirstChild(Ore).Value then

					-- Give ores to the miner and remove them from the player
					if plr.Mining.OresGiven:FindFirstChild(Ore) then
						local OresLeftToGive = OresTable[Ore] - plr.Mining.OresGiven:FindFirstChild(Ore).Value

						if Amount > OresLeftToGive then -- if player is giving more ores than what he needs
							Amount = OresLeftToGive -- reduce the amount of ores the player is giving
						end

						plr.Mining.OresGiven:FindFirstChild(Ore).Value += Amount -- add the ores to the ore given value
						plr.Mining.Ores:FindFirstChild(Ore).Value -= Amount -- remove the ores from the ore value
						
						MiningBindableEvent:Fire(plr, "OresGiven", Ore) -- save the amount of ores given to the miner
						MiningBindableEvent:Fire(plr, "Ores", Ore) -- save the amount of ores the player has
						
						if plr.PlayerGui.Mining.OresGiven:FindFirstChild(Ore) then -- if the miner's surface gui as been found

							plr.PlayerGui.Mining.OresGiven:FindFirstChild(Ore).Amount.Text = plr.Mining.OresGiven:FindFirstChild(Ore).Value.." / ".. OresTable[Ore] -- change the amount of ores the player gave in the gui

							-- If player has given all the required ores to the miner
							if plr.Mining.OresGiven:FindFirstChild(Ore).Value == OresTable[Ore] then
								plr.PlayerGui.Mining.OresGiven:FindFirstChild(Ore).Amount.TextColor3 = Color3.fromRGB(0, 190, 6) -- change the text color to green

								if plr.Mining.Pickaxes:FindFirstChild(Ore) then -- unlock pickaxe
									plr.Mining.Pickaxes:FindFirstChild(Ore).Value = true
								end
								
								MiningBindableEvent:Fire(plr, "Pickaxes", Ore) -- save the pickaxe unlocking
								GiveTool(plr, workspace:FindFirstChild(plr.Name), Ore, "Pickaxe") -- Give the pickaxe to the player
							end
						end
					end
				end
			end
		end

		-- Player is buying a sword
	elseif Type == "Sword" then

		local Sword = Param1

		if Sword and typeof(Sword) == "string" then

			if plr.Mining.Swords:FindFirstChild(Sword) and PricesTable["Swords"][Sword] then

				-- If player doesn't own the sword yet
				if plr.Mining.Swords:FindFirstChild(Sword).Value == true  then

					-- Give the sword to the player
					GiveTool(plr, workspace:FindFirstChild(plr.Name), Sword, "Sword")
					--if ServerStorage.MiningTools.Swords:FindFirstChild(Sword.."Sword") then						
					--	ServerStorage.MiningTools.Swords:FindFirstChild(Sword.."Sword"):Clone().Parent = plr.Backpack
					--end

				else

					-- If player has enough money to buy the sword
					local EnoughMoney = MoneyBindableFunction:Invoke(plr, PricesTable["Swords"][Sword], "-") -- check if player has enough money
					if EnoughMoney == true then


						plr.Mining.Swords:FindFirstChild(Sword).Value = true -- set the sword value to true
						MiningBindableEvent:Fire(plr, "Swords", Sword) -- save the sword

						-- Give the sword to the player
						GiveTool(plr, workspace:FindFirstChild(plr.Name), Sword, "Sword")
					end
				end
			end
		end

		-- Player is buying a bow
	elseif Type == "Bow" then

		if plr.Mining.Bows:FindFirstChild("Iron") and PricesTable["Bow"] then

			-- If player doesn't own the bow yet
			if plr.Mining.Bows:FindFirstChild("Iron").Value == true  then

				-- Give the bow to the player
				GiveTool(plr, workspace:FindFirstChild(plr.Name), "", "Bow")

			else

				-- If player has enough money to buy the bow
				local EnoughMoney = MoneyBindableFunction:Invoke(plr, PricesTable["Bow"], "-") -- check if player has enough money
				if EnoughMoney == true then


					plr.Mining.Bows:FindFirstChild("Iron").Value = true -- set the sword value to true
					MiningBindableEvent:Fire(plr, "Bows", "Iron")

					-- Give the sword to the player
					GiveTool(plr, workspace:FindFirstChild(plr.Name), "", "Bow")
				end
			end
		end
		
	-- Player is selling ores
	elseif Type == "Sell" then
		
		local Ore = Param1
		local Amount = Param2
		
		if Ore and Amount and typeof(Ore) == "string" and typeof(Amount) == "number" then
			
			-- If the player is not trying to sell more ores than he has
			if plr.Mining.Ores:FindFirstChild(Ore) and plr.Mining.Ores[Ore].Value >= Amount and SellPrices[Ore] then
				plr.Mining.Ores[Ore].Value -= Amount
				
				MoneyBindableFunction:Invoke(plr, Amount * SellPrices[Ore], "+")
				MiningBindableEvent:Fire(plr, "Ores", Ore)
			end
		end
	end
end)


-- PLAYER MINES THE ORES + RESPAWN THEM ONCE THEY ARE MINED

coroutine.wrap(function()
	while true do
		for i,v in ipairs(Mines.OresPlacement:GetChildren()) do
			for a,b in ipairs(v:GetChildren()) do

				if b:FindFirstChild("Mined") and b:FindFirstChild("Mined").Value == true then -- if the ore has been mined	
					b:FindFirstChild("Mined").Value = false -- set the mined value to false

					-- Respawn the ore
					local Ore = ServerStorage.MiningTools.Ores:FindFirstChild(v.Name)

					if Ore then
						Ore = Ore:Clone()
						Ore:SetPrimaryPartCFrame(b.CFrame)

						-- Randomize the shape a little bit to make it look more natural
						for y,z in ipairs(Ore:GetChildren()) do
							if z.Name == "Part" then
								z.Size = Vector3.new(z.Size.X, math.random(2,5)/10, math.random(8,12)/10) -- random size : X = X, Y = 0.2-0.5, Z = 0.8-1.2
								z.Orientation += Vector3.new(math.random(0,30),0,0) -- random X orientation
							end
						end

						local debounce = false

						-- Ore is being mined
						Ore.HitBox.Touched:Connect(function(hit)
							if not debounce then
								debounce = true

								if hit.Parent:FindFirstChild("Efficiency") and hit.Parent:FindFirstChild("ToolActivated") and hit.Parent:FindFirstChild("ToolActivated").Value == true then -- if it's a pickaxe

									hit.Parent.ToolActivated.Value = false -- tool is not activated anymore (to avoid hitting multiple times at once)

									-- Decrease ore toughness
									Ore.Toughness.Value -= hit.Parent:FindFirstChild("Efficiency").Value

									-- Break ore 
									if Ore.Toughness.Value <= 0 then

										-- Breaking animation (3 small spheres falling on the ground)

										for i=0,2 do
											local Sphere = Instance.new("Part")
											Sphere.Color = Ore:FindFirstChild("Part").Color
											Sphere.Material = Enum.Material.Foil
											Sphere.Size = Vector3.new(0.8,0.8,0.8)
											Sphere.Position = Ore.HitBox.Position - Vector3.new(2,0.8*i,0) 
											Sphere.Shape = Enum.PartType.Ball
											Sphere.Parent = Mines.BreakingAnimation
											Sphere.Anchored = false
											Debris:AddItem(Sphere, 2)
										end

										Ore:Destroy() -- destroy the ore			
										b:FindFirstChild("Mined").Value = true -- set the mined value to true so that the ore can respawn

										-- Give the ores to the player
										if Players:FindFirstChild(hit.Parent.Parent.Name) and Players:FindFirstChild(hit.Parent.Parent.Name).Mining.Ores:FindFirstChild(v.Name) then
											
											ExperienceBindableEvent:Fire(Players:FindFirstChild(hit.Parent.Parent.Name), "Miner", 1)
											
											Players:FindFirstChild(hit.Parent.Parent.Name).Mining.Ores:FindFirstChild(v.Name).Value += math.random(3,5)
											MiningBindableEvent:Fire(Players:FindFirstChild(hit.Parent.Parent.Name), "Ores", v.Name) -- fire the datastore to save the number of ores the player has
										end
									end
								end

								wait(0.5)
								debounce = false
							end
						end)

						Ore.Parent = Mines.Ores:FindFirstChild(v.Name)
					end
				end

				if AllOresSpawned then
					wait(1)
				else
					RunService.Heartbeat:Wait() -- heartbeat if not all the ores are loaded otherwise it would take 8 minutes to load everything
				end
			end
			wait(1)
		end
	end
end)()


-- PLAYER GETS OUT OF THE MINE

for i,v in ipairs(Mines.Borders:GetChildren()) do
	v.Touched:Connect(function(hit)
		
		if hit.Parent:FindFirstChildOfClass("Tool") then
			hit.Parent:FindFirstChildOfClass("Tool"):Destroy()
		end
		
		if Players:FindFirstChild(hit.Parent.Name) then
			Players[hit.Parent.Name].Backpack:ClearAllChildren()
		end
	end)
end


--for i,v in ipairs(workspace.Mines.Ores.Iron:GetChildren()) do
--	local Part = Instance.new("Part")
--	Part.Size = v.HitBox.Size
--	Part.CFrame = v.HitBox.CFrame
--	Part.Anchored = true
--	Part.CanCollide = false
--	Part.Transparency = 1
--	Part.Parent = workspace.Mines.OresPlacement.Iron
--	local Mined = Instance.new("BoolValue", Part)
--	Mined.Name = "Mined"
--	Mined.Value = true
--end