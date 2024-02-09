local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DanceRemoteFunction = ReplicatedStorage:WaitForChild("Dance")

local lplr = game.Players.LocalPlayer
local DanceGui = script.Parent
local CurrentCamera = workspace.CurrentCamera
local Dance = workspace.School.Dance
local NextArrow = nil
local Score = 0
local Timer = false

local TweenDanceCamera = TweenService:Create(CurrentCamera, TweenInfo.new(2), {CFrame = Dance.Camera.CFrame})

local YesButtonClicked, NoButtonClicked, ArrowPressed, LeftArrowClicked, TopArrowClicked, RightArrowClicked, BottomArrowClicked


-- DISCONNECT THE YES AND NO CLICKED EVENTS (IF PLAYER WANTS TO PLAY OR NOT) + HIDE GUI

local function Reset()
	DanceGui.Frame.Visible = false
	DanceGui.Keyboard.Visible = false
	DanceGui.Mobile.Visible = false

	for i,v in ipairs(DanceGui.Board.Jukebox:GetChildren()) do
		if v:IsA("Frame") then
			v.Size = UDim2.new(0.5,0,1,0)
		end
	end

	-- Disconnect all the events
	if YesButtonClicked and NoButtonClicked then
		YesButtonClicked:Disconnect()
		NoButtonClicked:Disconnect()
		YesButtonClicked = nil
		NoButtonClicked = nil
	end

	if ArrowPressed then
		ArrowPressed:Disconnect()
	end

	if LeftArrowClicked and TopArrowClicked and RightArrowClicked and BottomArrowClicked then
		LeftArrowClicked:Disconnect()
		TopArrowClicked:Disconnect()
		RightArrowClicked:Disconnect()
		BottomArrowClicked:Disconnect()
	end

	CurrentCamera.CameraType = Enum.CameraType.Custom

	if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
		lplr.Character:FindFirstChild("HumanoidRootPart").CFrame = Dance.PlayerPlacementOut.CFrame
	end
end


-- PLAYER PRESSED AN ARROW ON HIS KEYBOARD (IF DESKTOP PLAYER) OR CLICKED THE ARROWS ON THE GUI (IF MOBILE PLAYER)

local function Arrow(Arrow)

	if DanceGui.IsPlaying.Value or Arrow == 0 then -- check if the player is playing (value changed by the server to avoid having games that stops and restart halfway through because of a bad timing) or if the player is firing the event for the first time of the game
		NextArrow, Score = DanceRemoteFunction:InvokeServer(Arrow)

		if NextArrow then
			-- Hide the buttons with the frames
			for i,v in ipairs(DanceGui.Board.HideButtons:GetChildren()) do
				if v:IsA("Frame") then
					if v.LayoutOrder == NextArrow then
						v.BackgroundTransparency = 1
					else
						v.BackgroundTransparency = 0
					end
				end
			end
		end
	end
end


-- SCORE GUI

local function ScoreGui()
	wait(3)

	-- If the player is still playing, then fire the event one last time to end the game
	if DanceGui.IsPlaying.Value then
		Arrow(5)
	end

	wait(3)
	DanceGui.Completed.Visible = false
	DanceGui.Fail.Visible = false
	DanceGui.Score.Visible = false
end


-- DANCE REMOTE EVENT FIRED FROM THE SERVER

local function Start()

	-- Get confirmation that the player wants to play the level
	DanceGui.Frame.Visible = true

	if not YesButtonClicked and not NoButtonClicked then
		YesButtonClicked = DanceGui.Frame.YesButton.MouseButton1Down:Connect(function()
			Reset()

			if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
				lplr.Character:FindFirstChild("HumanoidRootPart").CFrame = Dance.PlayerPlacement.CFrame

				CurrentCamera.CameraType = Enum.CameraType.Scriptable
				TweenDanceCamera:Play()
				wait(2)

				-- Hide all the hide buttons frame
				for i,v in ipairs(DanceGui.Board.HideButtons:GetChildren()) do
					if v:IsA("Frame") then
						v.BackgroundTransparency = 1
					end
				end

				DanceGui.Countdown.Visible = true
				Arrow(0) -- fire the remote function once to get an arrow to click (to start the game)

				-- Countdown
				for i=3,1,-1 do
					DanceGui.Countdown.Text = tostring(i)
					wait(0.5)
				end

				DanceGui.Countdown.Text = "Go!"
				wait(1)
				DanceGui.Countdown.Visible = false

				Score = 0
				Timer = true

				-- Timer
				coroutine.wrap(function()
					wait(20)
					Timer = false
					Reset()

					if lplr.Sport.Lock3.Value then
						if Score > 20 then
							DanceGui.Completed.Visible = true
						else
							DanceGui.Fail.Text = "You scored "..tostring(Score)..". You need to score at least 20 to unlock sport level 3"
							DanceGui.Fail.Visible = true
						end
					else
						DanceGui.Score.Text = "You scored "..tostring(Score)
						DanceGui.Score.Visible = true
					end

					ScoreGui()
				end)()

				-- Enable either the arrows pressed events if the player has a keyboard or the arrows clicked events if he is on mobile
				if UserInputService.KeyboardEnabled then

					if not UserInputService.TouchEnabled then
						DanceGui.Keyboard.Visible = true
					end

					-- Detect when the keyboard arrows are pressed
					ArrowPressed = UserInputService.InputBegan:Connect(function(Input)
						if Input.KeyCode == Enum.KeyCode.Left then
							Arrow(1)
						elseif Input.KeyCode == Enum.KeyCode.Up then
							Arrow(2)
						elseif Input.KeyCode == Enum.KeyCode.Right then
							Arrow(3)
						elseif Input.KeyCode == Enum.KeyCode.Down then
							Arrow(4)
						end
					end)
				end

				if UserInputService.TouchEnabled then
					DanceGui.Mobile.Visible = true

					-- Detect when the arrows on the gui are clicked
					LeftArrowClicked = DanceGui.Board.Buttons.Left.Activated:Connect(function()
						Arrow(1)
					end)
					TopArrowClicked = DanceGui.Board.Buttons.Top.Activated:Connect(function()
						Arrow(2)
					end)
					RightArrowClicked = DanceGui.Board.Buttons.Right.Activated:Connect(function()
						Arrow(3)
					end)
					BottomArrowClicked = DanceGui.Board.Buttons.Bottom.Activated:Connect(function()
						Arrow(4)
					end)
				end

				-- Beat at the top (visual effect to fill the space)			
				coroutine.wrap(function()
					while Timer do
						for i,v in ipairs(DanceGui.Board.Jukebox:GetChildren()) do
							if v:IsA("Frame") then
								v.Size = UDim2.new(0.05, 0, math.random(), 0)
							end
						end

						wait(0.35)
					end
				end)()
			end
		end)

		-- Player clicks no (doesn't want to play the swimming game)
		NoButtonClicked = DanceGui.Frame.NoButton.MouseButton1Down:Connect(function()
			Reset()
		end)
	end
end


-- PLAYER TOUCHED THE TRIGGER TO START THE GAME

Dance.Trigger.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" and hit.Parent.Name == lplr.Name and Players:FindFirstChild(hit.Parent.Name) then

		if not Players:FindFirstChild(hit.Parent.Name).Sport.Lock2.Value then
			if not DanceGui.IsPlaying.Value then
				Start()
			end
		else
			DanceGui.DanceLock.Visible = true
			wait(6)
			DanceGui.DanceLock.Visible = false
		end
	end
end)