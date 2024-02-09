local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local LumberjackBindableEvent = ServerStorage:WaitForChild("Lumberjack")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local ExperienceBindableEvent = ServerStorage:WaitForChild("Experience")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LumberjackRemoteEvent = ReplicatedStorage:WaitForChild("Lumberjack")

local LumberjackHut = workspace.LumberjackHut

local ToolsFolder = ServerStorage:FindFirstChild("LumberjackTools")

local AxePrices = {
	StoneAxe = 2000,
	IronAxe = 4500,
	SteelAxe = 18000,
	DiamondAxe = 90000
}

local CanBuyTool = false

local ToolsList = {"WoodenAxe", "StoneAxe", "IronAxe", "SteelAxe", "DiamondAxe", "Shears", "Basket", "Mystree"}


-- PLAYER ENTERS THE CIRCLE TO SELECT OR BUY A TOOL

LumberjackHut.Circle.InTrigger.Touched:Connect(function(hit)

	if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) then -- get the player that touched the trigger

		local LumberjackGui = Players:FindFirstChild(hit.Parent.Name).PlayerGui.Lumberjack

		if LumberjackGui.Select.Visible == false then
			coroutine.wrap(function()

				if LumberjackGui.UnlockTrees.Visible == true then -- if the unlock trees or trees chopped down gui are visible then hide them before showing the selection gui
					LumberjackGui.UnlockTrees:TweenPosition(UDim2.new(0,0,-1,0)) -- tween the position down
					wait(1)
					LumberjackGui.UnlockTrees.Visible = false
				end

				LumberjackGui.Select.Visible = true -- show the tools selection gui
				LumberjackGui.Select:TweenPosition(UDim2.new(0.5,0,0.53,0)) -- tween the position up
			end)()
		end
	end
end)


--PLAYER GETS OUT OF THE CIRCLE

LumberjackHut.Circle.OutTrigger.Touched:Connect(function(hit)
	local plr = Players:FindFirstChild(hit.Parent.Name)

	if plr and plr.PlayerGui.Lumberjack.Select.Visible == true then -- get the player that touched the trigger

		coroutine.wrap(function()
			local LumberjackGui = plr.PlayerGui.Lumberjack

			if LumberjackGui.Select.Visible == true then

				LumberjackGui.Select:TweenPosition(UDim2.new(0.5,0,2,0)) -- tween the position down
				wait(1)
				LumberjackGui.Select.Visible = false -- hide the tools selection gui

				if plr.Backpack:FindFirstChildWhichIsA("Tool") then -- if player has a tool in his backpack (assume that it's a an axe or something)

					LumberjackGui.UnlockTrees.Visible = true -- show the progress bar with the number of trees left to chop down to unlock the next type of trees
					LumberjackGui.UnlockTrees:TweenPosition(UDim2.new(0,0,0,0)) -- tween the position up
				end
			end
		end)()
	end
end)


-- DERTOY TREE

local function DestroyTree(plr, Tree)
	local TreeIndex = workspace.Forest.TreesPlacement:FindFirstChild(Tree.Name):FindFirstChild(Tree.Index.Value) -- get the tree index (value that tells where the tree is (and where to respawn it))

	if TreeIndex then -- if the tree index was found
		TreeIndex.ChoppedDown.Value = true -- change the chopped down value to true so that it can respawn
		Tree:Destroy() -- destroy the tree
	end
	
	LumberjackBindableEvent:Fire(plr, "TreeChoppedDown") -- fire the server to save the tree chopped down value	
	
	local TreesChoppedDown = plr.Lumberjack.TreesChoppedDown
	
	if TreesChoppedDown.Value <= 890 then
		local TreesToUnlockGui = plr.PlayerGui.Lumberjack.UnlockTrees.TreesToUnlock
		
		TreesChoppedDown.Value += 1 -- add one to the trees chopped down tree value
		
		if TreesChoppedDown.Value < 10 then
			TreesToUnlockGui.ImageLabel.TextLabel.Text = tostring(TreesChoppedDown.Value).." / 10" -- add one to the tree counter (x / x)
			TreesToUnlockGui.ImageLabel.Frame.Size = UDim2.new((TreesChoppedDown.Value / 10),0,1,0) -- make the progress bar bigger
			
		elseif TreesChoppedDown.Value == 10 then -- player unlocks new tree
			TreesToUnlockGui.ImageLabel.TextLabel.Text = "0 / 30" -- reset the tree counter
			TreesToUnlockGui.ImageLabel.Frame.Size = UDim2.new(0,0,1,0) -- reset the progress bar size
			TreesToUnlockGui.ToUnlock.Text = "Chop down 30 trees to unlock the maple trees" -- change the text that tells you how many trees you have to break to unlock the next tree
			
			plr.Lumberjack.Trees.Birch.Value = true -- unlock the tree in the player lumberjack folder
			LumberjackBindableEvent:Fire(plr, "UnlockTree", "Birch") -- fire the server to save the unlocked tree
			
			coroutine.wrap(function() -- coroutine to animate the tree
				local NewTreeUnlockedGui = plr.PlayerGui.Lumberjack.UnlockTrees.NewTreeUnlocked
				NewTreeUnlockedGui.Birch.Visible = true
				NewTreeUnlockedGui.TreeUnlocked.Text = "You unlocked the birch trees!"
				NewTreeUnlockedGui.Visible = true
				NewTreeUnlockedGui:TweenSize(UDim2.new(0.6,0,0.6,0), nil, nil, 1.5) -- bigger
				wait(8)
				NewTreeUnlockedGui:TweenSize(UDim2.new(0,0,0,0), nil, nil, 1.5) -- smaller
				wait(1.5)
				NewTreeUnlockedGui.Birch.Visible = false
				NewTreeUnlockedGui.Visible = false
			end)()
			
		elseif TreesChoppedDown.Value < 40 then
			TreesToUnlockGui.ImageLabel.TextLabel.Text = tostring(TreesChoppedDown.Value - 10).." / 30"
			TreesToUnlockGui.ImageLabel.Frame.Size = UDim2.new(((TreesChoppedDown.Value - 10) / 30),0,1,0)
			
		elseif TreesChoppedDown.Value == 40 then
			TreesToUnlockGui.ImageLabel.TextLabel.Text = "0 / 100"
			TreesToUnlockGui.ImageLabel.Frame.Size = UDim2.new(0,0,1,0)
			TreesToUnlockGui.ToUnlock.Text = "Chop down 100 trees to unlock the pine trees"

			plr.Lumberjack.Trees.Maple.Value = true
			LumberjackBindableEvent:Fire(plr, "UnlockTree", "Maple")	

			coroutine.wrap(function()
				local NewTreeUnlockedGui = plr.PlayerGui.Lumberjack.UnlockTrees.NewTreeUnlocked
				NewTreeUnlockedGui.Maple.Visible = true
				NewTreeUnlockedGui.TreeUnlocked.Text = "You unlocked the maple trees!"
				NewTreeUnlockedGui.Visible = true
				NewTreeUnlockedGui:TweenSize(UDim2.new(0.6,0,0.6,0), nil, nil, 1.5)
				wait(8)
				NewTreeUnlockedGui:TweenSize(UDim2.new(0,0,0,0), nil, nil, 1.5)
				wait(1.5)
				NewTreeUnlockedGui.Maple.Visible = false
				NewTreeUnlockedGui.Visible = false
			end)()
			
		elseif TreesChoppedDown.Value < 140 then
			TreesToUnlockGui.ImageLabel.TextLabel.Text = tostring(TreesChoppedDown.Value - 40).." / 100"
			TreesToUnlockGui.ImageLabel.Frame.Size = UDim2.new(((TreesChoppedDown.Value - 40) / 100),0,1,0)
			
		elseif TreesChoppedDown.Value == 140 then
			TreesToUnlockGui.ImageLabel.TextLabel.Text = "0 / 750"
			TreesToUnlockGui.ImageLabel.Frame.Size = UDim2.new(0,0,1,0)
			TreesToUnlockGui.ToUnlock.Text = "Chop down 750 trees to unlock the apple trees"
			
			plr.Lumberjack.Trees.PineTree.Value = true
			LumberjackBindableEvent:Fire(plr, "UnlockTree", "PineTree")	
			
			coroutine.wrap(function()
				local NewTreeUnlockedGui = plr.PlayerGui.Lumberjack.UnlockTrees.NewTreeUnlocked
				NewTreeUnlockedGui.PineTree.Visible = true
				NewTreeUnlockedGui.TreeUnlocked.Text = "You unlocked the pine trees!"
				NewTreeUnlockedGui.Visible = true
				NewTreeUnlockedGui:TweenSize(UDim2.new(0.6,0,0.6,0), nil, nil, 1.5)
				wait(8)
				NewTreeUnlockedGui:TweenSize(UDim2.new(0,0,0,0), nil, nil, 1.5)
				wait(1.5)
				NewTreeUnlockedGui.PineTree.Visible = false
				NewTreeUnlockedGui.Visible = false
			end)()
			
		elseif TreesChoppedDown.Value < 890 then
			TreesToUnlockGui.ImageLabel.TextLabel.Text = tostring(TreesChoppedDown.Value - 140).." / 750"
			TreesToUnlockGui.ImageLabel.Frame.Size = UDim2.new(((TreesChoppedDown.Value - 140) / 750),0,1,0)

		else -- trees chopped down value == 890
			TreesToUnlockGui.Visible = false -- hide the trees to unlock with the prograss bar
			plr.PlayerGui.Lumberjack.UnlockTrees.AllTreesUnlocked.TextLabel.Text = TreesChoppedDown.Value
			plr.PlayerGui.Lumberjack.UnlockTrees.AllTreesUnlocked.Visible = true -- show the trees chopped down counter

			plr.Lumberjack.Trees.AppleTree.Value = true
			LumberjackBindableEvent:Fire(plr, "UnlockTree", "AppleTree")	

			coroutine.wrap(function()
				local NewTreeUnlockedGui = plr.PlayerGui.Lumberjack.UnlockTrees.NewTreeUnlocked
				NewTreeUnlockedGui.AppleTree.Visible = true
				NewTreeUnlockedGui.TreeUnlocked.Text = "You unlocked the apple trees!"
				NewTreeUnlockedGui.Visible = true
				NewTreeUnlockedGui:TweenSize(UDim2.new(0.6,0,0.6,0), nil, nil, 1.5)
				wait(8)
				NewTreeUnlockedGui:TweenSize(UDim2.new(0,0,0,0), nil, nil, 1.5)
				wait(1.5)
				NewTreeUnlockedGui.AppleTree.Visible = false
				NewTreeUnlockedGui.Visible = false
			end)()
		end

	else
		TreesChoppedDown.Value += 1 -- add 1 to the trees chopped down counter
		plr.PlayerGui.Lumberjack.UnlockTrees.AllTreesUnlocked.TextLabel.Text = TreesChoppedDown.Value -- change the text for number of trees chopped down
	end
end

-- ITEMS EARNED POP-UP + FIRE DATASTORE TO SAVE THE ITEM

local function ItemEarned(plr, Tool, Item, Amount) -- function to show the poop up on the left that says : "+13 woods" (The item has to be plural : woods, leaves, apples)
	
	if Tool == "Mystree" then
		LumberjackBindableEvent:Fire(plr, "Item", "All", Amount)
	else
		LumberjackBindableEvent:Fire(plr, "Item", Item, Amount)
	end
	
	ExperienceBindableEvent:Fire(plr, "Lumberjack", 1)
	
	local TemplateClone = plr.PlayerGui.Lumberjack.ItemsGained.Templates:FindFirstChild(Item.."Template") -- find the template clone corresponding to the item

	if TemplateClone then -- if found
		local ItemsGainedGui = plr.PlayerGui.Lumberjack.ItemsGained

		TemplateClone = TemplateClone:Clone()
		TemplateClone.Parent = ItemsGainedGui
		TemplateClone.TextLabel.Text = "+"..tostring(Amount).." "..Item -- change the text with the amount of items the player got

		coroutine.wrap(function()
			TemplateClone.Visible = true
			local PositionMultiplicator = ItemsGainedGui.PositionMultiplicator
			TemplateClone.Position = UDim2.new(-1.2, 0, (0.18 * PositionMultiplicator.Value), 0) -- move it up or down depending of how many other frames are already shown
			TemplateClone:TweenPosition(UDim2.new(0, 0, (TemplateClone.Position.Y.Scale), 0)) -- tween it to the right to animate it (entrance)
			PositionMultiplicator.Value += 1 -- value to know how many frames are already shown
			wait(1.5)
			TemplateClone:TweenPosition(UDim2.new(-1.2, 0, TemplateClone.Position.Y.Scale, 0)) -- tween it to the left to animate it (exit)
			wait(1)
			TemplateClone:Destroy() -- destroy it
			PositionMultiplicator.Value = PositionMultiplicator.Value - 1 -- 1 less frame is shown
		end)()
	end
end


--PLAYER ACTIVATED THE TOOL

local function ToolActivated(plr, Character, Tool, ToolAnimation)
	if plr and Character then -- if the player and the character are not nil
		
		local TreeRayCast = workspace:Raycast(Character.Head.Position, Character.Head.CFrame.LookVector * 6) -- create a ray cast that goes forward 6 studs from the head of the player
		if TreeRayCast then -- if the raycast hit something
			
			if (TreeRayCast.Instance.Name == "Tree" or TreeRayCast.Instance.Name == "Leaves") and TreeRayCast.Instance.Parent.Parent.Name == "Trees" then -- if the ray cast hit is a tree
				
				local Tree = TreeRayCast.Instance.Parent -- get the tree that was hit by the ray cast
				if plr.Lumberjack.Trees:FindFirstChild(Tree.Name) and plr.Lumberjack.Trees:FindFirstChild(Tree.Name).Value == true then -- if the tree value is in the lumberjack folder and the player can cut the tree (tree value set to true (if he has unlocked it)) 
					
					local Tool = workspace:FindFirstChild(plr.Name):FindFirstChild(Tool) -- find the tool in the player's character
					
					if Tool and Tool.LastUse and (Tool.LastUse.Value + 1) < tick() then -- tool cooldown, if the player used the tool over 1 second ago
						Tool.LastUse.Value = tick() -- new time
						
						ToolAnimation:Play() -- play the tool's animation
						
						Tool = Tool.Name -- change the tool variable to the name (instead of using Tool.Name)
						
						if Tool == "Mystree" then -- special tool that breaks everything (wood, leaves, apples)

							plr.Lumberjack.Wood.Value += 13 -- add the items to the items value
							plr.Lumberjack.Leaf.Value += 6
							plr.Lumberjack.Apple.Value += 6

							LumberjackBindableEvent:Fire(plr, "All", nil) -- fire the server to save the items

							ItemEarned(plr, "Mystree", "Woods", 13) -- call the function to 'animate' the items pop-ups
							ItemEarned(plr, "Mystree", "Leaves", 6)
							ItemEarned(plr, "Mystree", "Apples", 6)

							DestroyTree(plr, Tree) -- destroy the tree

						elseif Tool == "Shears" then
							if Tree.Leaves.Value > 0 then -- if the tree has leaves left

								if Tree.Leaves.Value == 1 then -- if there is 1 leaf left (0 left after the hit)
									if Tree:FindFirstChild("LeavesPart") then
										Tree.LeavesPart:Destroy() -- destroy the leaves
									end

									plr.Lumberjack.Leaf.Value += 6
									LumberjackBindableEvent:Fire(plr, "Leaf", nil)
									ItemEarned(plr, nil, "Leaves", 6)
								end
								Tree.Leaves.Value = Tree.Leaves.Value - 1 -- remove 1 leaf from the tree
							end

						elseif Tool == "Basket" then
							if Tree.Name == "AppleTree" then
								if Tree.Apples.Value > 0 then -- if the tree has apples left

									if Tree.Apples.Value == 1 then -- if there is 1 apple left (0 left after the hit)
										if Tree:FindFirstChild("ApplesPart") then
											Tree.ApplesPart:Destroy() -- destroy the leaves
										end

										plr.Lumberjack.Apple.Value += 6
										LumberjackBindableEvent:Fire(plr, "Apple", nil)
										ItemEarned(plr, nil, "Apples", 6)
									end
									Tree.Apples.Value = Tree.Apples.Value - 1 --- remove 1 apple from the tree
								end
							end

						else
							if Tree.Branches.Value > 0 then -- if the tree has branches left
								if Tool == "WoodenAxe" or Tool == "StoneAxe" or Tool == "IronAxe" then
									plr.Lumberjack.Wood.Value += 1
									LumberjackBindableEvent:Fire(plr, "Wood", nil)
									ItemEarned(plr, nil, "Woods", 1)
									Tree.Branches.Value = Tree.Branches.Value - 1 -- remove 1 branch from the tree

								elseif Tool == "SteelAxe" then
									plr.Lumberjack.Wood.Value += Tree.Branches.Value
									LumberjackBindableEvent:Fire(plr, "Wood", nil)
									ItemEarned(plr, nil, "Woods", Tree.Branches.Value)
									Tree.Branches.Value = 0 -- remove all the branches at once

								elseif Tool == "DiamondAxe" then
									Tree.Trunk.Value = 0
								end

							elseif Tree.Trunk.Value > 0 then -- if the tree has no branches left but still has the trunk

								if Tool == "WoodenAxe" then
									Tree.Trunk.Value = Tree.Trunk.Value - 1 -- remove 1 from the trunk (5 hits)
								elseif Tool == "StoneAxe" then
									Tree.Trunk.Value = Tree.Trunk.Value - 2 -- remove 2 from the trunk (3 hits)

								elseif Tool == "IronAxe" then
									Tree.Trunk.Value = 0 -- remove all of the trunk (1 hit)

								elseif Tool == "SteelAxe" then
									Tree.Trunk.Value = Tree.Trunk.Value - 3 -- remove 3 from the trunk (2 hits)
									
								elseif Tool == "DiamondAxe" then
									Tree.Trunk.Value = 0
								end

							else
								DestroyTree(plr, Tree) -- if it doesn't have either branches or trunk, then detroy the tree
							end
							
							if Tree.Trunk.Value <= 0 then -- if there is no trunk left
								plr.Lumberjack.Wood.Value += 8
								LumberjackBindableEvent:Fire(plr, "Wood", nil)
								ItemEarned(plr, nil, "Woods", 8)
								DestroyTree(plr, Tree) -- destroy the tree
							end
						end
					end
				else
					coroutine.wrap(function() -- player hasn't unlocked the tree yet
						plr.PlayerGui.Lumberjack.TextLabel.Visible = true
						wait(8)
						plr.PlayerGui.Lumberjack.TextLabel.Visible = false
					end)()
				end
			end
		end
	end
end


-- PLAYER HAS ENOUGH MONEY OR ITEMS TO BUY THE TOOL

local function CanBuyTool(plr, Tool)
	LumberjackBindableEvent:Fire(plr, "Buy", Tool) -- fire the bindable event to save the tool for the player

	plr.Lumberjack.Tools:FindFirstChild(Tool).Value = true -- change the value in the lumberjack tools folder

	coroutine.wrap(function() -- coroutine to animate the unlocking of the tool

		local BuyToolTween = TweenService:Create(plr.PlayerGui.Lumberjack.Select.Tools:FindFirstChild(Tool).Bubble, TweenInfo.new(1.5), {BackgroundColor3 = Color3.fromRGB(255,235,0)})
		BuyToolTween:Play() -- tween background circle from grey to yellow
		wait(2.5)

		plr.PlayerGui.Lumberjack.Select.Tools:FindFirstChild(Tool).Locked.Visible = false -- hide the locked text
		plr.PlayerGui.Lumberjack.Select.Tools:FindFirstChild(Tool).Select.Visible = true -- show the select text
	end)()
end

-- PLAYER FIRES THE REMOTE EVENT (EQUIPPED A TOOL, BOUGHT A TOOL, SELL ITEMS)

LumberjackRemoteEvent.OnServerEvent:Connect(function(plr, Type, Param1, Param2)

	if Type == "Buy" then -- player wants to buy a tool 
		
		local Tool = Param1	
		if Tool and typeof(Tool) == "string" then
			if plr.Lumberjack.Tools:FindFirstChild(Tool) and plr.Lumberjack.Tools:FindFirstChild(Tool).Value == false then -- if the tool is found in the lumberjack tools folder

				if Tool == "Shears" then
					if plr.Lumberjack.Wood.Value >= 50000 then -- if the player has more than 50 000 woods
						plr.Lumberjack.Wood.Value -= 50000
						CanBuyTool(plr, Tool)
					end

				elseif Tool == "Basket" then
					if plr.Lumberjack.Wood.Value >= 30000 and plr.Lumberjack.Leaf.Value >= 100000 then -- if the player has more than 30 000 wood and 100 000 leaves
						plr.Lumberjack.Wood.Value -= 30000
						plr.Lumberjack.Leaf.Value -= 100000
						CanBuyTool(plr, Tool)
					end

				elseif Tool == "Mystree" then
					if plr.Lumberjack.Wood.Value >= 75000 and plr.Lumberjack.Leaf.Value >= 150000 and plr.Lumberjack.Apple.Value >= 250000 then -- if the player has more than 75 000 wood, 150 000 leaves and 250 000 apples
						plr.Lumberjack.Wood.Value -= 75000
						plr.Lumberjack.Leaf.Value -= 150000
						plr.Lumberjack.Apple.Value -= 250000
						CanBuyTool(plr, Tool)
					end

				else -- otherwise player has to pay with money (for the axes)
					local Amount = AxePrices[Tool] -- find the price of the axe in the table

					if Amount then -- if the price was found
						local EnoughMoney = MoneyBindableFunction:Invoke(plr, Amount, "-") -- check if player has enough money to buy the tool
						if EnoughMoney == true then
							CanBuyTool(plr, Tool)
						end
					end

				end
			end
		end

	elseif Type == "Sell" then -- player wants to sell a tool
		
		local Item = Param1
		local AmountSold = Param2

		if Item and Item == "Wood" or Item == "Leaf" or Item == "Apple" and AmountSold and typeof(AmountSold) == "number" and AmountSold <= plr.Lumberjack:FindFirstChild(Item).Value then -- if the item exists and the player doesn't have less items than what he is trying to sell
			plr.Lumberjack:FindFirstChild(Item).Value = plr.Lumberjack:FindFirstChild(Item).Value - AmountSold -- change the amount of items the player has (remove what he is selling)

			local MoneyEarnt = 0

			if Item == "Wood" then -- give the money based on the item the player is selling (different multiplicators)
				MoneyEarnt = AmountSold * 2
			elseif Item == "Leaf" then
				MoneyEarnt = AmountSold * 4
			elseif Item == "Apple" then
				MoneyEarnt = AmountSold * 5
			end
			
			plr.PlayerGui.Lumberjack.Sell.Items:FindFirstChild(Item).Total.Text = "Total : "..plr.Lumberjack:FindFirstChild(Item).Value
			
			MoneyBindableFunction:Invoke(plr, MoneyEarnt, "+") -- fire the money function to give the player the money
			LumberjackBindableEvent:Fire(plr, "Sell", Item) -- fire the server to save the items for the player
		end

	elseif Type == "Equip" then

		local Tool = Param1

		if Tool and typeof(Tool) == "string" then
			plr.PlayerGui.Lumberjack.UnlockTrees.Visible = true -- show the progress bar with the number of trees left to chop down to unlock the next type of trees
			plr.PlayerGui.Lumberjack.UnlockTrees:TweenPosition(UDim2.new(0,0,0,0))-- tweeen the position up

			if ToolsFolder:FindFirstChild(Tool) and not plr.Backpack:FindFirstChild(Tool) and plr.Lumberjack.Tools:FindFirstChild(Tool) and plr.Lumberjack.Tools:FindFirstChild(Tool).Value then -- if the tool is found in the folder and the player doesn't already have the tool

				local ToolClone = ToolsFolder:FindFirstChild(Tool):Clone() -- clone the tool and put in the player's backpack
				ToolClone.Parent = plr.Backpack

				local ToolAnimation = nil
				if plr.Character and plr.Character:FindFirstChild("Humanoid") and ToolClone:FindFirstChild("Animation") then
					ToolAnimation = plr.Character:FindFirstChild("Humanoid"):LoadAnimation(ToolClone:FindFirstChild("Animation"))
				end

				if ToolAnimation then
					ToolClone.Activated:Connect(function() -- player activates the tool
						ToolActivated(plr, workspace:FindFirstChild(plr.Name), Tool, ToolAnimation)
					end)

				else
					ToolClone:Destroy() -- if the animations didn't load, the tool activated function won't fire and the player won't be able to use the tool, so destroy it so that he can get another one
				end
			end
		end
	end
end)


-- PLAYER LEAVES THE FOREST

for i,v in ipairs(LumberjackHut.ForestBorders:GetChildren()) do -- get all the touched events for the forest borders

	v.Touched:Connect(function(hit) -- if the player touches the forest borders

		local plr = Players:FindFirstChild(hit.Parent.Name) -- if hit was a player

		if plr then

			for i,v in pairs(ToolsList) do -- loop through the tool list

				if plr.Backpack:FindFirstChild(v) then -- if the player has got the tool in his backpack
					plr.Backpack:FindFirstChild(v):Destroy() -- destroy the tool

					local LumberjackGui = plr.PlayerGui.Lumberjack -- hide all guis
					LumberjackGui.Select.Visible = false
					LumberjackGui.Sell.Visible = false
					LumberjackGui.UnlockTrees.Visible = false
					LumberjackGui.UnlockTrees.Position = UDim2.new(0,0,-1,0)
				end
			end
		end
	end)
end


-- RESPAWN TREES

coroutine.wrap(function() -- coroutine to respawn the trees

	while true do
		for i,v in ipairs(workspace.Forest.TreesPlacement:GetChildren()) do -- loop through the different types of trees folder

			for a,b in ipairs(v:GetChildren()) do -- get every single trees from every type of tree

				if b.ChoppedDown.Value == true then -- if the tree has been chopped down

					b.ChoppedDown.Value = false -- change the value to false

					local RandomTree = math.random(1,3) -- choose a rnandom
					local RespawnTree = ServerStorage.TreesToClone:FindFirstChild(v.Name):FindFirstChild(v.Name..RandomTree) -- find the tree

					if RespawnTree then -- if the tree was found
						RespawnTree = RespawnTree:Clone()
						RespawnTree.Name = v.Name -- change the name to the type of tree tree (ex : "OakTree")
						RespawnTree.Index.Value = b.Name -- change the index (to indicate which tree is which)
						RespawnTree.Parent = workspace.Forest.Trees
						local RandomOrientation = math.random(0,360)
						RespawnTree:SetPrimaryPartCFrame(b.CFrame * CFrame.Angles(0,math.rad(RandomOrientation),0))
					end
				end
				wait(0.1)
			end
		end
	end
end)()

-- when using the pet teleport ability : hide all lumberjack guis and destroy all the tools

--[[

Player's Folder :
Lumberjack
	Tools
		WoodenAxe
		StoneAxe
		IronAxe
		SteelAxe
		DiamondAxe
		Shears
		Basket
	Trees
		Oak
		Birch
		Maple
		PineTree
		AppleTree
	NextTreeType (int)

wooden axe (birch) : 10 hits to chop down a tree --> 10 trees = 100 hits = 1'40
stone axe (maple) : 8 hits --> 30 trees = 240 hits = 4'00
iron axe (pine tree) : 6 hits --> 100 trees = 600 = 10'00
steel axe (apple tree) : 3 hits --> 750 trees = 2250 = 37'30

to unlock :
birch tree : 10 trees
maple : 30 trees
pine tree : 100 trees
steel axe : 750 trees

each tree will have 2 int values (one for the branches and one for the trunk) that takes a value between 0 and 5 
each axe fires a function with a value that represents the number of hits at once (make something different for the diamond axe, as it one hit both the branches and the trunk)

booster ? (make trees grow faster, or double log ? (buy with money, robux ?))

big walls around the forest (triggers), and if the player touches one of them, empty his backpack (so that he doesn't go everywhere with his axe)

on player added :
change the values in the player's folder
change the text from locked to select
change the color from grey to green
remove the grey circle to make the tool visible (or change the tool if using a black and white one)
in the shop change the text to already owned

on circle in trigger touch :
show gui

on select button click :
give the tool to the player

on tool buy :
check if the player doesn't already own the tool (values in the player's folder)
check if he has enough money
change the guis (shop and selection (see player added))
give the tool to the player

on tool use :
check if player is not in cooldown
check if player can that type of tree


-- add trees pile for each type of tree
-- money + experience




to do :
make the unlock next tree feature work
tool cooldown

change the prices of the shears, basket and the mystree
change the get woods, leaves and apples values
change the price size (too big)


apple : 7558176593 (1)
wood : 7558413433 (1.596)
leaf : 7558529189 (0.687)
oak sign : 7558395367 (lumberjack tools)
birch sign : 7558585465
maple sign : 7558369787
pine tree sign : 7558405066
apple tree sign : 7558180929
sell : 7558408765 (buy)
trees chopped down : 7559071836 (4.065)
unlock tree : 7559424825 (20.433) (#816342)
all : 7569791886 (2.97)
back : 7569797638 (owned)


prices :
free
2000
4500
18000
90000
100000 (not money) 50 000 wood 
125000 (not money) 30 000 wood and 100 000 leaves
300000 (not money) 75 000 wood, 150 000 leaves and 250 000 apples
add the price check before buying a tool (use a table ? (for the items))
]]--

--for i,v in ipairs(workspace.Shears:GetChildren()) do
--	if v.Name ~= "Handle" then
--		local WeldConstraint = Instance.new("WeldConstraint", workspace.Shears.Handle)
--		WeldConstraint.Part0 = workspace.Shears.Handle
--		WeldConstraint.Part1 = v
--	end
--end