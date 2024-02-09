local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local FishingBindableEvent = ServerStorage:WaitForChild("Fishing")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local ExperienceBindableEvent = ServerStorage:WaitForChild("Experience")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishingRemoteEvent = ReplicatedStorage:WaitForChild("Fishing")

local FishingHut = workspace.Lake.FishingHut

local debounce = false

local WaitTimeTable = {
	None = {10,30},
	PinkBait = {8,25},
	GreenBait = {6,20},
	RedOrangeBait = {4,15},
	RainbowBait = {2,10}
}

local RarityTable = {
	WoodenRod = {79,94,99,100},
	GraphiteRod = {52,87,97,100},
	AluminiumRod = {25,75,95,100},
	Carrod = {10,55,90,100}
}

local FishRarities = {
	Common = {"Salmon", "Cod"},
	Rare = {"Trout", "Catfish"},
	Epic = {"Eel", "Pufferfish"},
	Legendary = {"Swordfish", "Shark"}
}

local PricesTable = { -- prices to buy the rods, baits and sell the fishes
	GraphiteRod = 27000,
	AluminiumRod = 105000,
	Carrod = 430000,
	
	PinkBait = 8000,
	GreenBait = 27000,
	RedOrangeBait = 80000,
	RainbowBait = 300000,
	
	Salmon = 70,
	Cod = 75,
	Trout = 130,
	Catfish = 135,
	Eel = 160,
	Pufferfish = 165,
	Swordfish = 225,
	Shark = 230
}

local RodsList = {"WoodenRod", "GraphiteRod", "AluminiumRod", "Carrod"}

-- PLAYER ENTERS THE CIRCLE TO SELECT OR BUY A TOOL

FishingHut.Circle.InTrigger.Touched:Connect(function(hit)

	if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) then -- get the player that touched the trigger

		local FishingGui = Players:FindFirstChild(hit.Parent.Name).PlayerGui.Fishing.Select

		if FishingGui.Visible == false then -- if the gui is not shown yet
			FishingGui.Visible = true
			FishingGui.Baits.Visible = false
			FishingGui.Fishes.Visible = false
			FishingGui.Rods.Visible = true
			FishingGui:TweenPosition(UDim2.new(0.5,0,0.55,0))
		end
	end
end)


-- PLAYER GETS OUT OF THE CIRCLE

FishingHut.Circle.OutTrigger.Touched:Connect(function(hit)

	local plr = Players:FindFirstChild(hit.Parent.Name)

	if plr and plr.PlayerGui.Fishing.Select.Visible == true then -- get the player that touched the trigger

		local FishingGui = plr.PlayerGui.Fishing.Select

		if FishingGui.Visible == true then

			coroutine.wrap(function()
				FishingGui:TweenPosition(UDim2.new(0.5,0,1.5,0)) -- tween the position down
				wait(1)
				FishingGui.Visible = false -- hide the tools selection gui
			end)()
		end
	end
end)


-- PLAYER ACTIVATED THE TOOL

local function ToolActivated(plr, Tool, ThrowAnimation, PullBackAnimation)
	if plr then -- if the player and the character are not nil then
		
		Tool = workspace:FindFirstChild(plr.Name):FindFirstChild(Tool)
		
		if Tool and Tool.LastUse.Value + 0.5 < tick() then -- if the tool has not been used in the last 0.5s
			Tool.LastUse.Value = tick()
			
			if Tool.Thrown.Value == false then -- if the player is throwing the fishing rod
				Tool.Thrown.Value = true
				Tool.Float.CanCollide = true
				ThrowAnimation:Play()
				Tool.Float.RopeConstraint.Length = 10
				
				ThrowAnimation:GetMarkerReachedSignal("FishingRodThrown"):Connect(function()
					ThrowAnimation:AdjustSpeed(0)
				end)
				
			else -- if the player is pulling back the fishing rod
				Tool.Thrown.Value = false
				Tool.Waiting.Value = false
				Tool.Float.CanCollide = false
				ThrowAnimation:Stop()
				PullBackAnimation:Play()
				Tool.Float.RopeConstraint.Length = 0.9
			end
		end
	end
end


-- WHEN THE FLOAT TOUCHES THE WATER

local function WaterTouched(plr, Tool, PullBackAnimation)
	
	coroutine.wrap(function()
		local Bait = plr.Fishing.Baits.EquippedBait.Value -- find the equipped bait
		local TimeToWait = 20 -- default time to wait (20 because without a bait, min is 10 and max is 30, so average is 20)
		
		if WaitTimeTable[Bait] then -- if the bait was find in the wait time table
			TimeToWait = math.random(WaitTimeTable[Bait][1], WaitTimeTable[Bait][2]) -- get a random number between the min and max for the bait
		else
			TimeToWait = math.random(WaitTimeTable["None"][1], WaitTimeTable["None"][2]) -- otherwise get a random number between the min and max for the "none" bait (if has no baits equipped)
		end
		
		for i=1,TimeToWait do
			if Tool.Waiting.Value == false then -- if player pulls back the rod, stop the function so that he doesn't get the fish
				return
			end
			wait(1)
		end
				
		local FishCaught = "Salmon" -- default fish
		local FishRarity = "Common" -- default rarity
		
		ExperienceBindableEvent:Fire(plr, "Fisherman", 5)
		
		local RandomPearl = math.random(1,2406) -- 1 in 2400 chance to get a pearl
		if RandomPearl == 2002 then
			FishCaught = "Pearl"

		else		
			local RandomRarity = math.random(1,100)		

			if RarityTable[Tool.Name] then
				
				for i=1,4 do -- for the 4 rarity percentages in the table
					if RandomRarity <= RarityTable[Tool.Name][i] then -- check if the random rarity is less than or equal to the percentage 
						if i == 1 then -- get the rarity corresponding to i
							FishRarity = "Common"
						elseif i == 2 then
							FishRarity = "Rare"
						elseif i == 3 then
							FishRarity = "Epic"
						else
							FishRarity = "Legendary"
						end

						break
					end
				end

			else -- default rarities (for the wooden rod)
				if RandomRarity <= 79 then
					FishRarity = "Common"
				elseif RandomRarity <= 94 then
					FishRarity = "Rare"
				elseif RandomRarity <= 99 then
					FishRarity = "Epic"
				else
					FishRarity = "Legendary"
				end
			end

			if FishRarities[FishRarity] then -- choose a random fish based on the rarity
				local RandomFish = math.random(1,2)
				FishCaught = FishRarities[FishRarity][RandomFish]
			end
		end
		
		if plr.Fishing.Fishes:FindFirstChild(FishCaught) then
			plr.Fishing.Fishes:FindFirstChild(FishCaught).Value += 1
			FishingBindableEvent:Fire(plr, "FishCaught", FishCaught)
		end
		
		Tool.Thrown.Value = false -- rod pulled back
		Tool.Waiting.Value = false -- player not waiting for a fish
		Tool.Float.CanCollide = false
		PullBackAnimation:Play() -- play the pull back animation
		Tool.Float.RopeConstraint.Length = 0.9
		
		if workspace:FindFirstChild(plr.Name) and workspace:FindFirstChild(plr.Name).Humanoid:FindFirstChildOfClass("Animator") then -- the thrown animation is paused so that the player keep the position but when catching a fish, player still keeps the same position while he should stop
			for i,v in ipairs(workspace:FindFirstChild(plr.Name).Humanoid:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()) do -- get all the animation loaded on the player
				if v.Name == "ThrowAnimation" then -- if the thrown animation is playing
					v:Stop() -- stop it
				end
			end
		end
		
		local RarityColor = "#378abd" -- default rarity color
		
		if FishCaught == "Pearl" then -- if player caught a pearl
			RarityColor = "#ff0080" -- pink (special color)
		else
			if FishRarity == "Rare" then -- get the color corresponding to the rarity of the fish for the caught fish text label
				RarityColor = "#20bd2d"
			elseif FishRarity == "Epic" then
				RarityColor = "#9f44bd"
			elseif FishRarity == "Legendary" then
				RarityColor = "#dc9315"
			end
		end

		plr.PlayerGui.Fishing.FishCaught.Visible = true
		plr.PlayerGui.Fishing.FishCaught.Text = 'You caught a <font color="'..RarityColor..'">'..FishCaught..'</font>!' -- show the caught fish text label with the fish and the rarity color
		wait(5)
		plr.PlayerGui.Fishing.FishCaught.Visible = false
	end)()
end


-- PLAYER FIRES THE REMOTE EVENT (EQUIPPED A TOOL, BOUGHT A TOOL, SELL ITEMS)

FishingRemoteEvent.OnServerEvent:Connect(function(plr, Type, Param1, Param2)
	
	if Type == "Buy" then
		
		local ToolType = Param1 -- used because it can be either a rod or a bait
		local Tool = Param2
		
		if ToolType and typeof(ToolType) == "string" and Tool and typeof(Tool) == "string" then
			if plr.Fishing:FindFirstChild(ToolType) and plr.Fishing:FindFirstChild(ToolType):FindFirstChild(Tool) and plr.Fishing:FindFirstChild(ToolType):FindFirstChild(Tool).Value == false then -- if the tool has been found
				
				local Amount = PricesTable[Tool]
				
				if Amount then
					local EnoughMoney = MoneyBindableFunction:Invoke(plr, Amount, "-") -- check if player has enough money to buy the tool
					if EnoughMoney == true then
						
						plr.Fishing:FindFirstChild(ToolType):FindFirstChild(Tool).Value = true -- player now owns the tool
						
						if plr.PlayerGui.Fishing.Select.Rods:FindFirstChild(Tool) then -- if the tool is a rod
							plr.PlayerGui.Fishing.Select.Rods:FindFirstChild(Tool).Locked.Visible = false -- hide the locked button and show the select button
							plr.PlayerGui.Fishing.Select.Rods:FindFirstChild(Tool).Select.Visible = true
							
						elseif plr.PlayerGui.Fishing.Select.Baits:FindFirstChild(Tool) then -- if the tool is a bait
							plr.PlayerGui.Fishing.Select.Baits:FindFirstChild(Tool).Locked.Visible = false -- hide the locked button and show the select button
							plr.PlayerGui.Fishing.Select.Baits:FindFirstChild(Tool).Select.Visible = true
						end
						
						FishingBindableEvent:Fire(plr, "Buy", ToolType, Tool)
					end
				end
				
			end
		end
		
	elseif Type == "Sell" then
		
		local Fish = Param1
		local AmountSold = Param2
		
		if Fish and typeof(Fish) == "string" and AmountSold and typeof(AmountSold) == "number" then
			if plr.Fishing.Fishes:FindFirstChild(Fish) and AmountSold <= plr.Fishing.Fishes:FindFirstChild(Fish).Value then -- if the player is not trying to sell more fishes than he has
				if PricesTable[Fish] then -- if the fish was found in the prices table
					
					plr.Fishing.Fishes:FindFirstChild(Fish).Value -= AmountSold -- change the amount of fish the player has

					if plr.PlayerGui.Fishing.Select.Fishes:FindFirstChild(Fish) then
						plr.PlayerGui.Fishing.Select.Fishes:FindFirstChild(Fish).Total.Text = "Total : "..plr.Fishing.Fishes:FindFirstChild(Fish).Value
					end
					
					MoneyBindableFunction:Invoke(plr, AmountSold * PricesTable[Fish], "+") -- fire the money function to give the player the money
					FishingBindableEvent:Fire(plr, "Sell", Fish) -- fire the server to save the fishes for the player
				end
			end
		end
		
	elseif Type == "Equip" then
		
		local Tool = Param1
		if Tool and typeof(Tool) == "string" then

			if ServerStorage.FishingRods:FindFirstChild(Tool) and plr.Fishing.Rods:FindFirstChild(Tool) and plr.Fishing.Rods:FindFirstChild(Tool).Value == true then -- if it's a rod and the player owns it
				if not plr.Backpack:FindFirstChild(Tool) then
					
					local ToolClone = ServerStorage.FishingRods:FindFirstChild(Tool):Clone() -- clone the tool and put in the player's backpack
					ToolClone.Parent = plr.Backpack

					local ThrowAnimation = nil
					local PullBackAnimation = nil
					if plr.Character and plr.Character:FindFirstChild("Humanoid") and ToolClone:FindFirstChild("ThrowAnimation") and ToolClone:FindFirstChild("StopAnimation") then
						ThrowAnimation = plr.Character:FindFirstChild("Humanoid"):LoadAnimation(ToolClone:FindFirstChild("ThrowAnimation"))
						PullBackAnimation = plr.Character:FindFirstChild("Humanoid"):LoadAnimation(ToolClone:FindFirstChild("StopAnimation"))
					end
					if ThrowAnimation and PullBackAnimation then
						ToolClone.Activated:Connect(function() -- player activates the tool
							ToolActivated(plr, Tool, ThrowAnimation, PullBackAnimation)
						end)
						
						ToolClone.Float.Touched:Connect(function(hit)
							if not debounce then
								debounce = true
								
								if hit.Name == "WaterTouch" and hit.Parent.Name == "Lake" then
									
									if ToolClone.Waiting.Value == false and ToolClone.Thrown.Value == true then -- if the player is not already waiting to catch a fish and he has thrown the fishing rod
										ToolClone.Waiting.Value = true -- player waiting to catch a fish
										WaterTouched(plr, ToolClone, PullBackAnimation)
									end
								end
								wait(0.1)
								debounce = false
							end							
						end)
						
					else
						ToolClone:Destroy() -- if the animations didn't load, the tool activated function won't fire and the player won't be able to use the rod, so destroy it so that he can get another one
					end
				end
				
			elseif plr.Fishing.Baits:FindFirstChild(Tool) and plr.Fishing.Baits:FindFirstChild(Tool).Value == true then -- it it's a bait and the player owns it
				plr.Fishing.Baits.EquippedBait.Value = Tool
				
				if plr.PlayerGui.Fishing.Select.Baits:FindFirstChild(Tool) then -- if the tool gui is found
					
					for i,v in ipairs(plr.PlayerGui.Fishing.Select.Baits:GetChildren()) do -- for all baits, hide the selected image and show the select button
						if v:IsA("ImageLabel") then
							v.Selected.Visible = false
							v.Select.Visible = true
						end
					end

					plr.PlayerGui.Fishing.Select.Baits:FindFirstChild(Tool).Select.Visible = false -- for the bait the player selected, hide the select button and show the selected image
					plr.PlayerGui.Fishing.Select.Baits:FindFirstChild(Tool).Selected.Visible = true
				end
			end
		end
	end
end)


-- PLAYER LEAVES THE LAKE

for i,v in ipairs(workspace.Lake.LakeBorders:GetChildren()) do -- get all the touched events for the lake borders

	v.Touched:Connect(function(hit) -- if the player touches the lake borders

		local plr = Players:FindFirstChild(hit.Parent.Name) -- if hit was a player

		if plr then

			--for i,v in pairs(RodsList) do -- loop through the rods list

			--	if plr.Backpack:FindFirstChild(v) then -- if the player has got the tool in his backpack
			--		plr.Backpack:FindFirstChild(v):Destroy() -- destroy the tool

			--		local FishingGui = plr.PlayerGui.Fishing -- hide all guis
			--		FishingGui.Select.Visible = false
			--		FishingGui.Select.Position = UDim2.new(0.5,0,1.5,0)
			--	end
			--end
			
			for i,v in ipairs(plr.Backpack:GetChildren()) do
				v:Destroy()
			end

			if hit.Parent:FindFirstChildOfClass("Tool") then
				hit.Parent:FindFirstChildOfClass("Tool"):Destroy()
			end
		end
	end)
end