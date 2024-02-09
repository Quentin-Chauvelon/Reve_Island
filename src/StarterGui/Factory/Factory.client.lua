local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FactoryRemoteEvent = ReplicatedStorage:WaitForChild("Factory")
local Split1 = workspace.Factory.Split1
local Split2 = workspace.Factory.Split2
local Split3 = workspace.Factory.Split3
local CurrentSplit = nil

local lplr = game:GetService("Players").LocalPlayer
local FactoryGui = lplr.PlayerGui.Factory

local Camera = workspace.CurrentCamera
local Timer = 0
local Mode3Playing = false
local WrongColor = false
local WalkSpeed = 20
local debounce = false

local Mode1SpawnInterval = 1
local Mode2SpawnInterval = 1
local Mode3SpawnInterval = 1

local RedInRed = 0 -- variables to know the number of cubes in each box
local BlueInRed = 0
local GreenInRed = 0
local RedInBlue = 0
local BlueInBlue = 0
local GreenInBlue = 0
local RedInGreen = 0
local BlueInGreen = 0
local GreenInGreen = 0

workspace.Factory.Conveyors:FindFirstChild("Z-8").AssemblyLinearVelocity = Vector3.new(0,0,8) -- set the velocity for the conveyors
workspace.Factory.Conveyors.Z8.AssemblyLinearVelocity = Vector3.new(0,0,-8)
for i,v in ipairs(workspace.Factory.Conveyors:FindFirstChild("X-8"):GetChildren()) do
	v.AssemblyLinearVelocity = Vector3.new(8,0,0)
end
Split1.RotatingPart.AssemblyLinearVelocity = Vector3.new(8,0,0)
Split2.MovingPart.AssemblyLinearVelocity = Vector3.new(8,0,0)


-- PLAYER STARTS THE GAME

FactoryRemoteEvent.OnClientEvent:Connect(function(SelectedMode, SelectedMap)
	if not debounce then
		debounce = true

		WalkSpeed = workspace[lplr.Name].Humanoid.WalkSpeed
		workspace[lplr.Name].Humanoid.WalkSpeed = 0
		workspace[lplr.Name].HumanoidRootPart.Anchored = true

		Camera.CameraType = Enum.CameraType.Scriptable

		if SelectedMode == 3 then
			Mode3Playing = true
		end		

		if SelectedMap == 1 then -- determine which map is being played and change the currentsplit variable (instead of using multiple if statements)
			CurrentSplit = Split1

			if SelectedMode == 3 then -- change the spawn interval depending on the map
				Mode3SpawnInterval = 0.6
			else
				Mode1SpawnInterval = 0.8
				Mode2SpawnInterval = 0.8
			end

		elseif SelectedMap == 2 then
			CurrentSplit = Split2

			if SelectedMode == 1 then
				Mode3SpawnInterval = 0.9
			else
				Mode1SpawnInterval = 1.2
				Mode2SpawnInterval = 1.2
			end

		else
			CurrentSplit = Split3

			if SelectedMode == 1 then
				Mode3SpawnInterval = 0.9
			else
				Mode1SpawnInterval = 1.2
				Mode2SpawnInterval = 1.2		
			end
		end

		local TweenCamera = TweenService:Create(Camera, TweenInfo.new(1), {CFrame = CurrentSplit.Camera.CFrame})
		TweenCamera:Play()

		wait(1)

		if SelectedMode == 1 then -- mode : most points in 1 min

			local PlayCoroutine = coroutine.wrap(function()
				FactoryGui[CurrentSplit.Name].Visible = true -- show arrows

				repeat
					local Cube = CurrentSplit.TemplateCube:Clone() -- spawn a cube
					Cube.Parent = workspace.Factory.Cubes
					Cube.CanCollide = true
					Cube.Anchored = false

					local RandomColor = math.random(1,3) -- get random color
					if RandomColor == 1 then
						Cube.BrickColor = BrickColor.new("Really red")
					elseif RandomColor == 2 then
						Cube.BrickColor = BrickColor.new("Bright blue")
					else
						Cube.BrickColor = BrickColor.new("Sea green")
					end

					wait(Mode1SpawnInterval)

				until Timer == 0
			end)

			PlayCoroutine()

			Timer = 45
			repeat
				CurrentSplit.Timer.Timer.SurfaceGui.TextLabel.Text = Timer -- display time
				wait(1)
				Timer = Timer - 1

			until Timer == 0

			wait(6)

		elseif SelectedMode == 2 then -- mode : most points in 50 cubes

			FactoryGui[CurrentSplit.Name].Visible = true -- show arrows

			for i=1,5 do -- increase speed 5 times
				for i=1,10 do -- spawn 10 cubes
					local Cube = CurrentSplit.TemplateCube:Clone() -- spawn cube
					Cube.Parent = workspace.Factory.Cubes
					Cube.CanCollide = true
					Cube.Anchored = false

					local RandomColor = math.random(1,3) -- get random color
					if RandomColor == 1 then
						Cube.BrickColor = BrickColor.new("Really red")
					elseif RandomColor == 2 then
						Cube.BrickColor = BrickColor.new("Bright blue")
					else
						Cube.BrickColor = BrickColor.new("Sea green")
					end
					wait(Mode2SpawnInterval) -- wait for the time interval between each cube (which is decreasing)
				end
				Mode2SpawnInterval = Mode2SpawnInterval - 0.1 -- increase speed
			end

			wait(6)

		else -- mode : sudden death

			FactoryGui[CurrentSplit.Name].Visible = true -- show arrows
			WrongColor = false

			repeat

				local Cube = CurrentSplit.TemplateCube:Clone() -- spawn cube
				Cube.Parent = workspace.Factory.Cubes
				Cube.CanCollide = true
				Cube.Anchored = false

				local RandomColor = math.random(1,3) -- get random color
				if RandomColor == 1 then
					Cube.BrickColor = BrickColor.new("Really red")
				elseif RandomColor == 2 then
					Cube.BrickColor = BrickColor.new("Bright blue")
				else
					Cube.BrickColor = BrickColor.new("Sea green")
				end

				wait(Mode3SpawnInterval)
			until WrongColor == true	

			Mode3Playing = false
			workspace.Factory.Cubes:ClearAllChildren()
			wait(2)

		end

		FactoryGui[CurrentSplit.Name].Visible = false -- hide arrows
		Split2.MovingPart.Position = Split2.UpPosition.Position

		FactoryGui.Score.RedBox.Red.Text = "Red cubes : "..RedInRed -- display scores
		FactoryGui.Score.RedBox.Blue.Text = "Blue cubes : "..BlueInRed
		FactoryGui.Score.RedBox.Green.Text = "Green cubes : "..GreenInRed

		FactoryGui.Score.BlueBox.Blue.Text = "Blue cubes : "..BlueInBlue
		FactoryGui.Score.BlueBox.Green.Text = "Green cubes : "..GreenInBlue
		FactoryGui.Score.BlueBox.Red.Text = "Red cubes : "..RedInBlue

		FactoryGui.Score.GreenBox.Green.Text = "Green cubes : "..GreenInGreen
		FactoryGui.Score.GreenBox.Red.Text = "Red cubes : "..RedInGreen
		FactoryGui.Score.GreenBox.Blue.Text = "Blue cubes : "..BlueInGreen

		FactoryGui.Score.FinalScore.Score.Text = RedInRed + BlueInBlue + GreenInGreen

		local CurrentMap = 1
		if CurrentSplit.Name == "Split1" then
			CurrentMap = 1
		elseif CurrentSplit.Name == "Split2" then
			CurrentMap = 2
		else
			CurrentMap = 3
		end
		FactoryRemoteEvent:FireServer("Points", SelectedMode, CurrentMap, RedInRed+BlueInBlue+GreenInGreen)

		FactoryGui.Score.Visible = true
		FactoryGui.Score.RedBox:TweenSize(UDim2.new(0.24,0,0.3,0), nil, nil, 0.5) -- tween scores
		FactoryGui.Score.BlueBox:TweenSize(UDim2.new(0.24,0,0.3,0), nil, nil, 0.5)
		FactoryGui.Score.GreenBox:TweenSize(UDim2.new(0.24,0,0.3,0), nil, nil, 0.5)
		wait(2)
		FactoryGui.Score.FinalScore:TweenSize(UDim2.new(0.2,0,0.26,0), nil, nil, 0.5)
		FactoryGui.Score.TextButton:TweenSize(UDim2.new(0.08,0,0.08,0), nil, nil, 0.5)
	end
end)


-----------------------------------------------------------------------------------------------------


-- SELECT MODE

workspace.Factory.Modes.Mode1.Mode1Trigger.Touched:Connect(function(hit) -- mode 1 : most points in 45 seconds
	if hit.Parent.Name == lplr.Name then
		workspace.Factory.Modes.Mode1.Selected.BrickColor = BrickColor.new("Lime green")
		workspace.Factory.Modes.Mode2.Selected.BrickColor = BrickColor.new("Really red")
		workspace.Factory.Modes.Mode3.Selected.BrickColor = BrickColor.new("Really red")
		workspace.Factory.Start.Display.SurfaceGui.Mode.Text = "Mode : Most points in 45 seconds"
	end
end)

workspace.Factory.Modes.Mode2.Mode2Trigger.Touched:Connect(function(hit) -- mode 2 : most points in 50 cubes (with incerasing speed)
	if hit.Parent.Name == lplr.Name then
		workspace.Factory.Modes.Mode2.Selected.BrickColor = BrickColor.new("Lime green")
		workspace.Factory.Modes.Mode1.Selected.BrickColor = BrickColor.new("Really red")
		workspace.Factory.Modes.Mode3.Selected.BrickColor = BrickColor.new("Really red")
		workspace.Factory.Start.Display.SurfaceGui.Mode.Text = "Mode : Most points in 50 cubes (increasing speed)"
	end
end)

workspace.Factory.Modes.Mode3.Mode3Trigger.Touched:Connect(function(hit) -- mode 3 : sudden death (at max speed) and with leaderboard
	if hit.Parent.Name == lplr.Name then
		workspace.Factory.Modes.Mode3.Selected.BrickColor = BrickColor.new("Lime green")
		workspace.Factory.Modes.Mode1.Selected.BrickColor = BrickColor.new("Really red")
		workspace.Factory.Modes.Mode2.Selected.BrickColor = BrickColor.new("Really red")
		workspace.Factory.Start.Display.SurfaceGui.Mode.Text = "Mode : Sudden death (at max speed)"
	end
end)


-- SELECT MAP

workspace.Factory.Maps.Map1.Map1Trigger.Touched:Connect(function(hit) -- map 1
	if hit.Parent.Name == lplr.Name then
		workspace.Factory.Maps.Map1.Selected.BrickColor = BrickColor.new("Lime green")
		workspace.Factory.Maps.Map2.Selected.BrickColor = BrickColor.new("Really red")
		workspace.Factory.Maps.Map3.Selected.BrickColor = BrickColor.new("Really red")
		workspace.Factory.Start.Display.SurfaceGui.Map.Text = "Map : 1"
	end
end)

workspace.Factory.Maps.Map2.Map2Trigger.Touched:Connect(function(hit) -- map 2
	if hit.Parent.Name == lplr.Name then
		workspace.Factory.Maps.Map2.Selected.BrickColor = BrickColor.new("Lime green")
		workspace.Factory.Maps.Map1.Selected.BrickColor = BrickColor.new("Really red")
		workspace.Factory.Maps.Map3.Selected.BrickColor = BrickColor.new("Really red")
		workspace.Factory.Start.Display.SurfaceGui.Map.Text = "Map : 2"
	end
end)

workspace.Factory.Maps.Map3.Map3Trigger.Touched:Connect(function(hit) -- map 3
	if hit.Parent.Name == lplr.Name then
		workspace.Factory.Maps.Map3.Selected.BrickColor = BrickColor.new("Lime green")
		workspace.Factory.Maps.Map1.Selected.BrickColor = BrickColor.new("Really red")
		workspace.Factory.Maps.Map2.Selected.BrickColor = BrickColor.new("Really red")
		workspace.Factory.Start.Display.SurfaceGui.Map.Text = "Map : 3"
	end
end)


-- SPLIT 1 ARROWS CLICK

FactoryGui.Split1.LeftButton.MouseButton1Down:Connect(function()
	Split1.RotatingPart.AssemblyLinearVelocity = Vector3.new(0,0,8)
end)

FactoryGui.Split1.DownButton.MouseButton1Down:Connect(function()
	Split1.RotatingPart.AssemblyLinearVelocity = Vector3.new(8,0,0)
end)

FactoryGui.Split1.RightButton.MouseButton1Down:Connect(function()
	Split1.RotatingPart.AssemblyLinearVelocity = Vector3.new(0,0,-8)
end)


-- SPLIT 1 BOXES TRIGGER

Split1.RedTrigger.Touched:Connect(function(Part)
	if Part.Parent == workspace.Factory.Cubes then		
		Part:Destroy()

		if Part.BrickColor == BrickColor.new("Really red") then
			RedInRed = RedInRed + 1
			if Mode3Playing == true then
				FactoryRemoteEvent:FireServer("Cubes", 0, 0, 0)
			end
		elseif Part.BrickColor == BrickColor.new("Bright blue") then
			BlueInRed = BlueInRed + 1
			WrongColor = true
		else
			GreenInRed = GreenInRed + 1
			WrongColor = true
		end
	end
end)

Split1.BlueTrigger.Touched:Connect(function(Part)
	if Part.Parent == workspace.Factory.Cubes then
		Part:Destroy()

		if Part.BrickColor == BrickColor.new("Bright blue") then
			BlueInBlue = BlueInBlue + 1
			if Mode3Playing == true then
				FactoryRemoteEvent:FireServer("Cubes", 0, 0, 0)
			end
		elseif Part.BrickColor == BrickColor.new("Sea green") then
			GreenInBlue = GreenInBlue + 1
			WrongColor = true
		else
			RedInBlue = RedInBlue + 1
			WrongColor = true
		end
	end
end)

Split1.GreenTrigger.Touched:Connect(function(Part)
	if Part.Parent == workspace.Factory.Cubes then
		Part:Destroy()

		if Part.BrickColor == BrickColor.new("Sea green")then
			GreenInGreen = GreenInGreen + 1
			if Mode3Playing == true then
				FactoryRemoteEvent:FireServer("Cubes", 0, 0, 0)
			end
		elseif Part.BrickColor == BrickColor.new("Really red") then
			RedInGreen = RedInGreen + 1 
			WrongColor = true
		else
			BlueInGreen = BlueInGreen + 1
			WrongColor = true
		end
	end
end)


-- SPLIT 2 ARROWS CLICK

FactoryGui.Split2.UpButton.MouseButton1Down:Connect(function()
	TweenService:Create(Split2.MovingPart, TweenInfo.new(0.1), {Position = Split2.UpPosition.Position}):Play()
end)

FactoryGui.Split2.MiddleButton.MouseButton1Down:Connect(function()
	TweenService:Create(Split2.MovingPart, TweenInfo.new(0.1), {Position = Split2.MiddlePosition.Position}):Play()
end)

FactoryGui.Split2.DownButton.MouseButton1Down:Connect(function()
	TweenService:Create(Split2.MovingPart, TweenInfo.new(0.1), {Position = Split2.DownPosition.Position}):Play()
end)


-- SPLIT 2 BOXES TRIGGER

Split2.RedTrigger.Touched:Connect(function(Part)
	if Part.Parent == workspace.Factory.Cubes then		
		Part:Destroy()

		if Part.BrickColor == BrickColor.new("Really red") then
			RedInRed = RedInRed + 1
			if Mode3Playing == true then
				FactoryRemoteEvent:FireServer("Cubes", 0, 0, 0)
			end
		elseif Part.BrickColor == BrickColor.new("Bright blue") then
			BlueInRed = BlueInRed + 1
			WrongColor = true
		else
			GreenInRed = GreenInRed + 1
			WrongColor = true
		end
	end
end)

Split2.BlueTrigger.Touched:Connect(function(Part)
	if Part.Parent == workspace.Factory.Cubes then
		Part:Destroy()

		if Part.BrickColor == BrickColor.new("Bright blue") then
			BlueInBlue = BlueInBlue + 1
			if Mode3Playing == true then
				FactoryRemoteEvent:FireServer("Cubes", 0, 0, 0)
			end
		elseif Part.BrickColor == BrickColor.new("Sea green") then
			GreenInBlue = GreenInBlue + 1
			WrongColor = true
		else
			RedInBlue = RedInBlue + 1
			WrongColor = true
		end
	end
end)

Split2.GreenTrigger.Touched:Connect(function(Part)
	if Part.Parent == workspace.Factory.Cubes then
		Part:Destroy()
		if Part.BrickColor == BrickColor.new("Sea green")then
			GreenInGreen = GreenInGreen + 1	
			if Mode3Playing == true then
				FactoryRemoteEvent:FireServer("Cubes", 0, 0, 0)
			end
		elseif Part.BrickColor == BrickColor.new("Really red") then
			RedInGreen = RedInGreen + 1 
			WrongColor = true
		else
			BlueInGreen = BlueInGreen + 1
			WrongColor = true
		end
	end
end)


-- SPLIT 3 ARROWS CLICK

FactoryGui.Split3.Push1Button.MouseButton1Down:Connect(function()
	TweenService:Create(Split3.Push1, TweenInfo.new(0.1), {Position = Split3.Push1Extend.Position}):Play()
	wait(0.1)
	TweenService:Create(Split3.Push1, TweenInfo.new(0.1), {Position = Split3.Push1Retract.Position}):Play()
end)

FactoryGui.Split3.Push2Button.MouseButton1Down:Connect(function()
	TweenService:Create(Split3.Push2, TweenInfo.new(0.1), {Position = Split3.Push2Extend.Position}):Play()
	wait(0.1)
	TweenService:Create(Split3.Push2, TweenInfo.new(0.1), {Position = Split3.Push2Retract.Position}):Play()
end)

FactoryGui.Split3.Push3Button.MouseButton1Down:Connect(function()
	TweenService:Create(Split3.Push3, TweenInfo.new(0.1), {Position = Split3.Push3Extend.Position}):Play()
	wait(0.1)
	TweenService:Create(Split3.Push3, TweenInfo.new(0.1), {Position = Split3.Push3Retract.Position}):Play()
end)


-- SPLIT 3 BOXES TRIGGER

Split3.RedTrigger.Touched:Connect(function(Part)
	if Part.Parent == workspace.Factory.Cubes then		
		Part:Destroy()

		if Part.BrickColor == BrickColor.new("Really red") then
			RedInRed = RedInRed + 1
			if Mode3Playing == true then
				FactoryRemoteEvent:FireServer("Cubes", 0, 0, 0)
			end
		elseif Part.BrickColor == BrickColor.new("Bright blue") then
			BlueInRed = BlueInRed + 1
			WrongColor = true
		else
			GreenInRed = GreenInRed + 1
			WrongColor = true
		end
	end
end)

Split3.BlueTrigger.Touched:Connect(function(Part)
	if Part.Parent == workspace.Factory.Cubes then
		Part:Destroy()

		if Part.BrickColor == BrickColor.new("Bright blue") then
			BlueInBlue = BlueInBlue + 1
			if Mode3Playing == true then
				FactoryRemoteEvent:FireServer("Cubes", 0, 0, 0)
			end
		elseif Part.BrickColor == BrickColor.new("Sea green") then
			GreenInBlue = GreenInBlue + 1
			WrongColor = true
		else
			RedInBlue = RedInBlue + 1
			WrongColor = true
		end
	end
end)

Split3.GreenTrigger.Touched:Connect(function(Part)
	if Part.Parent == workspace.Factory.Cubes then
		Part:Destroy()

		if Part.BrickColor == BrickColor.new("Sea green")then
			GreenInGreen = GreenInGreen + 1
			if Mode3Playing == true then
				FactoryRemoteEvent:FireServer("Cubes", 0, 0, 0)
			end
		elseif Part.BrickColor == BrickColor.new("Really red") then
			RedInGreen = RedInGreen + 1 
			WrongColor = true
		else
			BlueInGreen = BlueInGreen + 1
			WrongColor = true
		end
	end
end)

Split3.WhiteTrigger.Touched:Connect(function(Part)
	if Part.Parent == workspace.Factory.Cubes then
		Part:Destroy()
		WrongColor = true
	end
end)


-- CLOSE SCORE GUI

FactoryGui.Score.TextButton.MouseButton1Down:Connect(function()
	FactoryGui.Score.RedBox:TweenSize(UDim2.new(0,0,0,0), nil, nil, 0.5)
	FactoryGui.Score.BlueBox:TweenSize(UDim2.new(0,0,0,0), nil, nil, 0.5)
	FactoryGui.Score.GreenBox:TweenSize(UDim2.new(0,0,0,0), nil, nil, 0.5)
	FactoryGui.Score.FinalScore:TweenSize(UDim2.new(0,0,0,0), nil, nil, 0.5)
	FactoryGui.Score.TextButton:TweenSize(UDim2.new(0,0,0,0), nil, nil, 0.5)
	wait(1)
	FactoryGui.Score.Visible = false

	workspace.Factory.Cubes:ClearAllChildren()
	CurrentSplit.Timer.Timer.SurfaceGui.TextLabel.Text = "0"
	workspace[lplr.Name].Humanoid.WalkSpeed = WalkSpeed
	workspace[lplr.Name].HumanoidRootPart.Anchored = false
	workspace[lplr.Name].HumanoidRootPart.CFrame = workspace.Factory.PlayerPlacement.CFrame
	Camera.CameraType = Enum.CameraType.Custom

	RedInRed = 0
	BlueInRed = 0
	GreenInRed = 0
	RedInBlue = 0
	BlueInBlue = 0
	GreenInBlue = 0
	RedInGreen = 0
	BlueInGreen = 0
	GreenInGreen = 0

	debounce = false
end)


-----------------------------------------------------------------------------------------------------


local Leaderboard = workspace.Factory.Leaderboard.SurfaceGui.Frame


-- RANKING BUTTON CLICK

Leaderboard.Ranking.MouseButton1Down:Connect(function() -- show the rankings
	Leaderboard.Header.Visible = true
	Leaderboard.ScrollingFrame.Visible = true
	Leaderboard.RewardFrame.Visible = false
	Leaderboard.Ranking.BackgroundColor3 = Color3.fromRGB(206, 206, 206) -- change the buttons colors
	Leaderboard.Ranking.TextColor3 = Color3.fromRGB(121, 121, 121)
	Leaderboard.Ranking.TopLeft.BackgroundColor3 = Color3.fromRGB(206, 206, 206)
	Leaderboard.Ranking.TopRight.BackgroundColor3 = Color3.fromRGB(206, 206, 206)

	Leaderboard.Reward.BackgroundColor3 = Color3.fromRGB(121, 121, 121)
	Leaderboard.Reward.TextColor3 = Color3.fromRGB(206, 206, 206)
	Leaderboard.Reward.TopLeft.BackgroundColor3 = Color3.fromRGB(121, 121, 121)
	Leaderboard.Reward.TopRight.BackgroundColor3 = Color3.fromRGB(121, 121, 121)
end)


-- REWARD BUTTON CLICK

Leaderboard.Reward.MouseButton1Down:Connect(function() -- show the rewards
	Leaderboard.RewardFrame.Visible = true
	Leaderboard.Header.Visible = false
	Leaderboard.ScrollingFrame.Visible = false
	Leaderboard.Reward.BackgroundColor3 = Color3.fromRGB(206, 206, 206)
	Leaderboard.Reward.TextColor3 = Color3.fromRGB(121, 121, 121) -- change the buttons colors
	Leaderboard.Reward.TopLeft.BackgroundColor3 = Color3.fromRGB(206, 206, 206)
	Leaderboard.Reward.TopRight.BackgroundColor3 = Color3.fromRGB(206, 206, 206)

	Leaderboard.Ranking.BackgroundColor3 = Color3.fromRGB(121, 121, 121)
	Leaderboard.Ranking.TextColor3 = Color3.fromRGB(206, 206, 206)
	Leaderboard.Ranking.TopLeft.BackgroundColor3 = Color3.fromRGB(121, 121, 121)
	Leaderboard.Ranking.TopRight.BackgroundColor3 = Color3.fromRGB(121, 121, 121)
end)