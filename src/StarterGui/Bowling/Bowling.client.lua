local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BowlingRemoteEvent = ReplicatedStorage:WaitForChild("Bowling")

local lplr = game.Players.LocalPlayer
local BowlingGui = script.Parent
local CurrentCamera = workspace.CurrentCamera
local Bowling = workspace.School.Bowling
local SpaceBarPressed = false

local TweenBowlingCamera = TweenService:Create(CurrentCamera, TweenInfo.new(2), {CFrame = Bowling.Camera.CFrame})
local MoveArrowUp = TweenService:Create(BowlingGui.Power.Arrow, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Position = UDim2.new(0.93,0,0.2,0)})
local MoveArrowDown = TweenService:Create(BowlingGui.Power.Arrow, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Position = UDim2.new(0.93,0,0.8,0)})
local MoveArrowLeft = TweenService:Create(BowlingGui.Spin.Arrow, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Position = UDim2.new(0.25,0,0.35,0)})
local MoveArrowRight = TweenService:Create(BowlingGui.Spin.Arrow, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Position = UDim2.new(0.75,0,0.35,0)})

local YesButtonClicked, NoButtonClicked, SpaceBar, ScreenTouched


-- DISCONNECT THE YES AND NO CLICKED EVENTS (IF PLAYER WANTS TO PLAY OR NOT) + HIDE GUI

local function DisconnectClickEvents()
	BowlingGui.Frame.Visible = false

	if YesButtonClicked and NoButtonClicked then
		YesButtonClicked:Disconnect()
		NoButtonClicked:Disconnect()
		YesButtonClicked = nil
		NoButtonClicked = nil
	end
end


-- BOWLING REMOTE EVENT FIRED FROM THE SERVER

BowlingRemoteEvent.OnClientEvent:Connect(function(Type, FallenPins)

	-- Player starts the game
	if Type == "Start" then

		-- If someone is already playing, tell the player to wait
		if Bowling.IsSomeonePlaying.Value then
			BowlingGui.SomeoneAlreadyPlaying.Visible = true
			wait(6)
			BowlingGui.SomeoneAlreadyPlaying.Visible = false

		else
			-- Get confirmation that the player wants to play the level
			BowlingGui.Frame.Visible = true

			if not YesButtonClicked and not NoButtonClicked then
				YesButtonClicked = BowlingGui.Frame.YesButton.MouseButton1Down:Connect(function()
					DisconnectClickEvents()

					-- Create the ball
					BowlingRemoteEvent:FireServer("Ball")

					if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
						lplr.Character:FindFirstChild("HumanoidRootPart").CFrame = Bowling.PlayerPlacement.CFrame
					end

					CurrentCamera.CameraType = Enum.CameraType.Scriptable
					TweenBowlingCamera:Play()
					wait(2)

					BowlingGui.SpaceBar.Visible = true
					BowlingGui.TextLabel.Visible = true
					BowlingGui.TextLabel.Text = "Position"

					-- Wait for the ball to be created
					Bowling.Balls:WaitForChild(lplr.Name)


					-- Create the tweens to move the ball back and forth along the alley
					local TweenMoveBall = TweenService:Create(Bowling.Balls:FindFirstChild(lplr.Name), TweenInfo.new(0.8, Enum.EasingStyle.Linear), {Position = Bowling.BallMoving.Position})
					local TweenMoveBallBack = TweenService:Create(Bowling.Balls:FindFirstChild(lplr.Name), TweenInfo.new(0.8, Enum.EasingStyle.Linear), {Position = Bowling.BallPlacement.Position})


					-- PLAYER PRESSED THE SPACEBAR OR TOUCHED THE SCREEN

					local function NextStep()
						SpaceBarPressed = true

						-- Cancel the tweens so that the ball and arrow stop moving
						TweenMoveBall:Cancel()
						TweenMoveBallBack:Cancel()
						MoveArrowUp:Cancel() 
						MoveArrowDown:Cancel()
						MoveArrowLeft:Cancel()
						MoveArrowRight:Cancel()
					end


					--  Player presses the spacebar				
					SpaceBar = UserInputService.InputBegan:Connect(function(Input)
						if Input.KeyCode == Enum.KeyCode.Space then
							NextStep()
						end
					end)

					-- Player touches the screen
					ScreenTouched = UserInputService.TouchTap:Connect(function()
						NextStep()
					end)


					-- Move the ball back and forth along the alley until the player presses the spacebar
					repeat
						TweenMoveBall:Play()
						wait(0.8)

						if not SpaceBarPressed then
							TweenMoveBallBack:Play()
							wait(0.8)
						end
					until SpaceBarPressed

					SpaceBarPressed = false
					BowlingGui.Power.Arrow.Position = UDim2.new(0.93,0,0.8,0)
					BowlingGui.Power.Visible = true
					BowlingGui.TextLabel.Text = "Power"


					-- Move the arrow up and down until the player presses the spacebar
					repeat
						MoveArrowUp:Play()
						wait(0.5)

						if not SpaceBarPressed then
							MoveArrowDown:Play()
							wait(0.5)
						end
					until SpaceBarPressed

					SpaceBarPressed = false
					wait(0.5)
					BowlingGui.Spin.Arrow.Position = UDim2.new(0.75,0,0.35,0)
					BowlingGui.Power.Visible = false
					BowlingGui.Spin.Visible = true
					BowlingGui.TextLabel.Text = "Spin"


					-- Move the arrow back and forst until the player presses the spacebar
					repeat
						MoveArrowLeft:Play()
						wait(0.5)

						if not SpaceBarPressed then
							MoveArrowRight:Play()
							wait(0.5)
						end
					until SpaceBarPressed

					SpaceBarPressed = false

					-- Disconnect the space bar and touched events
					SpaceBar:Disconnect()
					ScreenTouched:Disconnect()

					wait(0.5)
					BowlingGui.Spin.Visible = false
					BowlingGui.SpaceBar.Visible = false
					BowlingGui.TextLabel.Visible = false
					wait(1)

					-- Tween the camera towards the pins faster or slower depending of the velocity of the ball (0.2 = 3, 0.8 = 7)
					TweenService:Create(CurrentCamera, TweenInfo.new((((BowlingGui.Power.Arrow.Position.Y.Scale - 0.2) * 100 / 0.6) * 0.04 + 3), Enum.EasingStyle.Linear), {CFrame = Bowling.StrikeCamera.CFrame}):Play()

					BowlingRemoteEvent:FireServer("Throw", Bowling.Balls:FindFirstChild(lplr.Name).Position, BowlingGui.Power.Arrow.Position.Y.Scale, BowlingGui.Spin.Arrow.Position.X.Scale)
				end)


				-- Player clicks no (doesn't want to play the bowling game)
				NoButtonClicked = BowlingGui.Frame.NoButton.MouseButton1Down:Connect(function()
					DisconnectClickEvents()

					if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
						lplr.Character:FindFirstChild("HumanoidRootPart").CFrame = Bowling.PlayerPlacementOut.CFrame
					end
				end)
			end
		end

	elseif Type == "FallenPins" then

		-- Tp the player out of the alley
		if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
			lplr.Character:FindFirstChild("HumanoidRootPart").CFrame = Bowling.PlayerPlacementOut.CFrame
		end

		CurrentCamera.CameraType = Enum.CameraType.Custom -- reset the camera

		--if lplr.Sport.Lock2.Value then
		if FallenPins == 10 then
			BowlingGui.Completed.Visible = true
			wait(6)
			BowlingGui.Completed.Visible = false

		else
			BowlingGui.Fail.Visible = true
			wait(6)
			BowlingGui.Fail.Visible = false
		end
		--end
	end
end)