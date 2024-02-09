local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local SportBindableEvent = ServerStorage:WaitForChild("Sport")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BowlingRemoteEvent = ReplicatedStorage:WaitForChild("Bowling")

local Bowling = workspace.School.Bowling
local StartTime = 0
local SpinDetection


-- PLAYER TOUCHES THE TRIGGER TO START A BOWLING GAME 

Bowling.Trigger.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) then
		BowlingRemoteEvent:FireClient(Players[hit.Parent.Name], "Start")
	end
end)



BowlingRemoteEvent.OnServerEvent:Connect(function(plr, Type, BallPosition, Power, Spin)

	if Type == "Ball" then
		
		if plr:FindFirstChild("CanDie") then
			plr.CanDie.Value = false
		end
		
		-- If someone is already playing
		if Bowling.IsSomeonePlaying.Value then
			
			-- If the player has been playing for more than 2 minutes (AFK or quit)
			if StartTime + 120 < os.time() then
				Bowling.IsSomeonePlaying.Value = false
				
				if Bowling.Balls:FindFirstChildOfClass("Part") and Players:FindFirstChild(Bowling.Balls:FindFirstChildOfClass("Part").Name) then
					
					if Players[Bowling.Balls:FindFirstChildOfClass("Part").Name]:FindFirstChild("CanDie") then
						Players[Bowling.Balls:FindFirstChildOfClass("Part").Name].CanDie.Value = true
					end
					
					BowlingRemoteEvent:FireClient(Players[Bowling.Balls:FindFirstChildOfClass("Part").Name], "FallenPins", 0) -- fire client to tp player, reset the camera...					
					Bowling.Balls:ClearAllChildren()
				end
			end
			
		else
			Bowling.IsSomeonePlaying.Value = true
			
			local Ball = Instance.new("Part") -- create a ball
			Ball.Shape = "Ball"
			Ball.Name = plr.Name
			Ball.Color = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
			Ball.Size = Vector3.new(2,2,2)
			Ball.CFrame = Bowling.BallPlacement.CFrame + Vector3.new(0,0.5,0)
			Ball.Anchored = false
			Ball.TopSurface = "Smooth"
			Ball.BottomSurface = "Smooth"
			Ball.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 100, 100)
			Ball.Parent = Bowling.Balls
			
			StartTime = os.time()

			-- Spin value stores the value once it is fired from the client for later use
			local Spin = Instance.new("IntValue")
			Spin.Name = "Spin"
			Spin.Parent = Ball
		end
		
	elseif Type == "Throw" then
		
		if BallPosition and typeof(BallPosition) == "Vector3" then
			
			-- If the ball was found and is not moving (to prevent exploiters from firing the event)
			if Bowling.Balls:FindFirstChild(plr.Name) and Bowling.Balls[plr.Name]:FindFirstChild("Spin") then
				
				Bowling.Balls[plr.Name].Position = BallPosition
				
				-- Set the power and spin of the ball
				if Power and Spin and typeof(Power) == "number" and typeof(Spin) == "number" then
					
					Power = ((Power - 0.2) / 0.04) - 24
					Spin = 10 - (((Spin - 0.25) / 0.02) * 0.8)
					
					Bowling.Balls[plr.Name].AssemblyLinearVelocity = Vector3.new(Power, 0, 0)
					Bowling.Balls[plr.Name].Spin.Value = Spin
				end
				
				-- When the ball touches the spin detection part, apply the spin value
				SpinDetection = Bowling.SpinDetection.Touched:Connect(function(hit)
					if hit.Parent.Name == "Balls" and hit.Parent.Parent.Name == "Bowling" then
						SpinDetection:Disconnect()

						-- Different values to make it smoother
						Bowling.Balls[plr.Name].AssemblyLinearVelocity = Vector3.new(Bowling.Balls[plr.Name].AssemblyLinearVelocity.X, 0, Bowling.Balls[plr.Name].Spin.Value / 8)
						wait(0.1)
						Bowling.Balls[plr.Name].AssemblyLinearVelocity = Vector3.new(Bowling.Balls[plr.Name].AssemblyLinearVelocity.X, 0, Bowling.Balls[plr.Name].Spin.Value / 4)
						wait(0.1)
						Bowling.Balls[plr.Name].AssemblyLinearVelocity = Vector3.new(Bowling.Balls[plr.Name].AssemblyLinearVelocity.X, 0, Bowling.Balls[plr.Name].Spin.Value / 2)
						wait(0.1)
						Bowling.Balls[plr.Name].AssemblyLinearVelocity = Vector3.new(Bowling.Balls[plr.Name].AssemblyLinearVelocity.X, 0, Bowling.Balls[plr.Name].Spin.Value)
						wait(0.5)
						Bowling.Balls[plr.Name].AssemblyLinearVelocity = Vector3.new(Bowling.Balls[plr.Name].AssemblyLinearVelocity.X / 2, 0, 0)
					end
					
					wait(4)
					local FallenPins = 0
					
					-- Get the number of pins that have fallen 					
					for i,v in ipairs(Bowling.Pins:GetChildren()) do
						
						-- If the pin has an orientation of more than 10 in any of the following axis (-X, X, -Z, Z), then it fell
						if math.max(math.abs(v.Orientation.X), math.abs(v.Orientation.Z)) > 10 then
							FallenPins += 1
							
						-- If the pin stayed straight while moving, check if its position is different from the placement pin by more than 0.5
						elseif Bowling.PinsPlacement:FindFirstChild(v.Name) and math.max(math.abs(Bowling.PinsPlacement[v.Name].Position.X - v.Position.X), math.abs(Bowling.PinsPlacement[v.Name].Position.Z - v.Position.Z)) > 0.5 then
							FallenPins += 1
						end
						
						-- Reset the pins position
						if Bowling.PinsPlacement:FindFirstChild(v.Name) then
							v.CFrame = Bowling.PinsPlacement[v.Name].CFrame 
						end
					end
					
					-- If all the pins fell, the player completed the level
					if FallenPins == 10 and plr.Sport.Lock2.Value then
						plr.Sport.Lock2.Value = false
						
						SportBindableEvent:Fire(plr, 2)
						MoneyBindableFunction:Invoke(plr, 2000, "+")
					end
					
					BowlingRemoteEvent:FireClient(plr, "FallenPins", FallenPins)
					
					if plr:FindFirstChild("CanDie") then
						plr.CanDie.Value = true
					end 
					
					Bowling.Balls:ClearAllChildren()
					Bowling.IsSomeonePlaying.Value = false
				end)
			end
		end
	end
end)