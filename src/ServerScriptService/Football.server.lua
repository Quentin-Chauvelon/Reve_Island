local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local SportBindableEvent = ServerStorage:WaitForChild("Sport")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FootballRemoteEvent = ReplicatedStorage:WaitForChild("Football")

local Football = workspace.School.Football
local StartTime = 0
local Score = 1 -- can use the same variable for every player since only one player can play at a time
local HumanoidRootPart = nil
local debounce = false

local Goal


-- RESET THE BALL POSITION AND VELOCITY

local function ResetBall()
	Football.Ball.AssemblyAngularVelocity = Vector3.zero
	Football.Ball.AssemblyLinearVelocity = Vector3.zero
	Football.Ball.CFrame = Football.BallPlacement.CFrame
end


-- PLAYER TOUCHES THE TRIGGER TO START A Football GAME 

Football.Trigger.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) then
		FootballRemoteEvent:FireClient(Players[hit.Parent.Name], "Start")
	end
end)


-- CREATE THE OBSTACLES

local function CreateObstacle(Obstacle)

	Football.Obstacles:ClearAllChildren()

	if Obstacle == 1 then
		ServerStorage.FootballOstacles.Obstacle1:Clone().Parent = Football.Obstacles

	elseif Obstacle == 2 then
		ServerStorage.FootballOstacles.Obstacle2:Clone().Parent = Football.Obstacles

		if Football.Obstacles:FindFirstChild("Obstacle2") and Football.Obstacles.Obstacle2:FindFirstChild("Obstacle1") and Football.Obstacles.Obstacle2:FindFirstChild("Obstacle2") then

			-- Create the twens to move the obstacles
			local TweenObstacle1Left = TweenService:Create(Football.Obstacles.Obstacle2.Obstacle1, TweenInfo.new(4, Enum.EasingStyle.Linear), {Position = Football.S2Obstacle1Start.Position})
			local TweenObstacle1Right = TweenService:Create(Football.Obstacles.Obstacle2.Obstacle1, TweenInfo.new(4, Enum.EasingStyle.Linear), {Position = Football.S2Obstacle1End.Position})
			local TweenObstacle2Left = TweenService:Create(Football.Obstacles.Obstacle2.Obstacle2, TweenInfo.new(4, Enum.EasingStyle.Linear), {Position = Football.S2Obstacle2End.Position})
			local TweenObstacle2Right = TweenService:Create(Football.Obstacles.Obstacle2.Obstacle2, TweenInfo.new(4, Enum.EasingStyle.Linear), {Position = Football.S2Obstacle2Start.Position})

			coroutine.wrap(function()
				
				-- Move the obstacles while the player doesn't score
				while Score == 2 do
					TweenObstacle1Right:Play()
					TweenObstacle2Left:Play()
					wait(4)
					TweenObstacle1Left:Play()
					TweenObstacle2Right:Play()
					wait(4)
				end	
			end)()
		end

	elseif Obstacle == 3 then
		ServerStorage.FootballOstacles.Obstacle3:Clone().Parent = Football.Obstacles

		if Football.Obstacles:FindFirstChild("Obstacle3") and Football.Obstacles.Obstacle3:FindFirstChild("Model") and Football.Obstacles.Obstacle3.Model.PrimaryPart then

			-- Create the twens to move the obstacles
			local RotateObstacle = TweenService:Create(Football.Obstacles.Obstacle3.Model.PrimaryPart, TweenInfo.new(4, Enum.EasingStyle.Linear), {CFrame = Football.Obstacles.Obstacle3.Model.PrimaryPart.CFrame * CFrame.Angles(math.rad(180),0,0)})
			local RotateObstacleBack = TweenService:Create(Football.Obstacles.Obstacle3.Model.PrimaryPart, TweenInfo.new(4, Enum.EasingStyle.Linear), {CFrame = Football.Obstacles.Obstacle3.Model.PrimaryPart.CFrame * CFrame.Angles(math.rad(0),0,0)})
			coroutine.wrap(function()

				-- Move the obstacles while the player doesn't score
				while Score == 3 do
					RotateObstacle:Play()
					wait(4)
					RotateObstacleBack:Play()
					wait(4)
				end	
			end)()
		end

	else
		ServerStorage.FootballOstacles.Obstacle4:Clone().Parent = Football.Obstacles

		if Football.Obstacles:FindFirstChild("Obstacle4") and Football.Obstacles.Obstacle4:FindFirstChild("Obstacle1") and Football.Obstacles.Obstacle4:FindFirstChild("Obstacle2") and Football.Obstacles.Obstacle4:FindFirstChild("Obstacle3") then

			-- Create the twens to move the obstacles
			local TweenObstacle1Up = TweenService:Create(Football.Obstacles.Obstacle4.Obstacle1, TweenInfo.new(2, Enum.EasingStyle.Linear), {Position = Football.S4Obstacle1Up.Position})
			local TweenObstacle1Down = TweenService:Create(Football.Obstacles.Obstacle4.Obstacle1, TweenInfo.new(2, Enum.EasingStyle.Linear), {Position = Football.S4Obstacle1Down.Position})
			local TweenObstacle2Up = TweenService:Create(Football.Obstacles.Obstacle4.Obstacle2, TweenInfo.new(2, Enum.EasingStyle.Linear), {Position = Football.S4Obstacle2Up.Position})
			local TweenObstacle2Down = TweenService:Create(Football.Obstacles.Obstacle4.Obstacle2, TweenInfo.new(2, Enum.EasingStyle.Linear), {Position = Football.S4Obstacle2Down.Position})
			local TweenObstacle3Up = TweenService:Create(Football.Obstacles.Obstacle4.Obstacle3, TweenInfo.new(2, Enum.EasingStyle.Linear), {Position = Football.S4Obstacle3Up.Position})
			local TweenObstacle3Down = TweenService:Create(Football.Obstacles.Obstacle4.Obstacle3, TweenInfo.new(2, Enum.EasingStyle.Linear), {Position = Football.S4Obstacle3Down.Position})

			coroutine.wrap(function()

				-- Move the obstacles while the player doesn't score
				while Score == 4 do
					TweenObstacle1Down:Play()
					TweenObstacle2Up:Play()
					TweenObstacle3Down:Play()
					wait(2)
					TweenObstacle1Up:Play()
					TweenObstacle2Down:Play()
					TweenObstacle3Up:Play()
					wait(2)
				end	
			end)()
		end

	end
end


-- DID THE PLAYER RUN OUT OF TIME

local function TimerOut()
	
	-- If the player has been playing for more than 40 seconds (AFK or quit or exploiter)
	if StartTime + 40 < os.time() and Football.IsSomeonePlaying.Value then
		Football.IsSomeonePlaying.Value = false
		Football.Obstacles:ClearAllChildren()
		ResetBall()

		if HumanoidRootPart then
			HumanoidRootPart.CFrame = Football.PlayerPlacementOut.CFrame
		end
	end
end


-- REMOTE EVENT FIRED FROM THE CLIENT (TO START THE GAME)

FootballRemoteEvent.OnServerEvent:Connect(function(plr, Type)

	if Type and typeof(Type) == "string" then
		if Type == "Start" then

			if Football.IsSomeonePlaying.Value then

				TimerOut()

			else
				if not plr.Sport.Lock4.Value then
					Football.IsSomeonePlaying.Value = true

					if plr:FindFirstChild("CanDie") then
						plr.CanDie.Value = false
					end 

					if workspace:FindFirstChild(plr.Name) and workspace[plr.Name]:FindFirstChild("HumanoidRootPart") then
						HumanoidRootPart = workspace[plr.Name].HumanoidRootPart
					end

					Score = 1
					StartTime = os.time()

					ResetBall()
					CreateObstacle(1)

					-- Get the goal touched event (when the player scores)
					Goal = Football.Goal.Touched:Connect(function(hit)
						
						if hit.Name == "Ball" and hit.Parent.Name == "Football" then
							
							if not debounce then
								debounce = true

								if HumanoidRootPart then
									HumanoidRootPart.CFrame = Football.PlayerPlacement.CFrame
								end

								Score += 1

								-- If the player scored all 4 goals
								if Score == 5 then

									if plr:FindFirstChild("CanDie") then
										plr.CanDie.Value = true
									end 

									Score = 1
									Football.Obstacles:ClearAllChildren()						
									Football.IsSomeonePlaying.Value = false

									if plr.Sport.Lock5.Value then
										plr.Sport.Lock5.Value = false

										SportBindableEvent:Fire(plr, 5)
										MoneyBindableFunction:Invoke(plr, 25000, "+")
									end

									FootballRemoteEvent:FireClient(plr, "End", 4)
								else
									ResetBall()
									CreateObstacle(Score)
								end

								TimerOut()

								wait(1)
								debounce = false
							end
						end
					end)
				end
			end
			
		elseif Type == "Stop" then
			Score = 1
			Football.Obstacles:ClearAllChildren()
			ResetBall()
			Football.IsSomeonePlaying.Value = false
		end
	end
end)