local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local ExperienceBindableEvent = ServerStorage:WaitForChild("Experience")
local RaceTrackBindableEvent = ServerStorage:WaitForChild("RaceTrack")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaceTrackRemoteEvent = ReplicatedStorage:WaitForChild("RaceTrack")
local ServerStorage = game:GetService("ServerStorage")

local RaceTrack = workspace.RaceTrack

local QueueTable = {}


-- DESTROY CAR

local function DestroyCar(plr)
	if plr.Character and plr.Character.Humanoid.Sit then -- if the player is found in the workspace and he is sit
		plr.Character.Humanoid.Sit = false -- unsit the player
		
		-- wait for the player to be unsitted to teleport him
		repeat wait(0.2) until plr.Character.Humanoid.Sit == false
		
		plr.Character.HumanoidRootPart.CFrame = RaceTrack.PlayerOutPlacement.CFrame -- tp the player out of the track
	end
	
	if workspace.Cars:FindFirstChild("F1"..plr.Name) then -- if the player's car is found
		if workspace.Cars:FindFirstChild("F1"..plr.Name):FindFirstChild("Checkpoint").Value < 3 then -- if the player hasn't reached checkpoint 3 yet
			RaceTrack.WaitToStart.Value = false -- set wait to start to false so that the next player can start
		end
		workspace.Cars:FindFirstChild("F1"..plr.Name):Destroy() -- destroy the car
	end
	
	plr.PlayerGui.RaceTrack.Racing.CheckpointMiss.Visible = false
end


-- START THE RACE

local function Race(plr)
	local Car = ServerStorage:FindFirstChild("Formula1"):Clone() ---= clone the car from the server storage
	Car.Chassis.FloorPanel.Anchored = true -- anchor the car (otherwise when change the cframe, the car sometimes explodes)
	Car:SetPrimaryPartCFrame(RaceTrack.CarPlacement.CFrame) -- move the car to the start line
	Car.Name = "F1"..plr.Name -- change the name of the car
	Car.Parent = workspace.Cars -- parent it to the cars folder in the workspace
	wait(0.1)
	Car.Chassis.VehicleSeat:Sit(plr.Character.Humanoid) -- sit the player to the driver seat 
	
	RaceTrack.Lights.Green.BrickColor = BrickColor.new("Dark stone grey") -- reset the green lights
	RaceTrack.Lights.Green.Material = Enum.Material.Plastic
	
	RaceTrackRemoteEvent:FireClient(plr) -- fire the client to tween the camera and show the racing gui
	
	coroutine.wrap(function() -- coroutine to start the car and set the player ownership (so that the player can drive)

		if Car and Car.Parent and plr then
			wait(1)
			plr.PlayerGui.RaceTrack.Racing.Visible = true -- show the racing gui
			wait(1)
			
			if Car and Car.Parent then
				Car.Scripts.VehicleSeating.StartCar.Value = true -- start the car (engine)

				RaceTrack.Lights.Red.BrickColor = BrickColor.new("Really red") -- red Lightss
				RaceTrack.Lights.Red.Material = Enum.Material.Neon
				wait(1.5)
				RaceTrack.Lights.Red.BrickColor = BrickColor.new("Dark stone grey") -- yellow Lights
				RaceTrack.Lights.Red.Material = Enum.Material.Plastic
				RaceTrack.Lights.Yellow.BrickColor = BrickColor.new("Deep orange")
				RaceTrack.Lights.Yellow.Material = Enum.Material.Neon
				wait(1.5)
				RaceTrack.Lights.Yellow.BrickColor = BrickColor.new("Dark stone grey") -- green Lights
				RaceTrack.Lights.Yellow.Material = Enum.Material.Plastic
				RaceTrack.Lights.Green.BrickColor = BrickColor.new("Lime green")
				RaceTrack.Lights.Green.Material = Enum.Material.Neon

				if Car and Car.Parent then
					Car.Scripts.Vehicle.SetOwnerShip.Value = true -- set owner shop (player can now drive)

					Car.StartTime.Value = tick() -- set the start value for the timer

					local RacingGui = plr.PlayerGui.RaceTrack.Racing

					while Car and Car.Parent and Car:FindFirstChild("StartTime") and Car:FindFirstChild("Checkpoint") and (tick() - Car.StartTime.Value) < 180 and Car.Checkpoint.Value ~= 14 do -- if the values can be found in the car and player has not been racing for more than 3 minutes and the player has not reached the finish line

						if plr then
							RacingGui.Timer.Text = math.floor(tick() - Car.StartTime.Value) -- get the seconds ellapsed since the start of the race (for the timer)
						end

						local FloorMaterial = workspace:Raycast(Car.Body.Caster.Position, Vector3.new(0,-1,0))

						if FloorMaterial then
							if FloorMaterial.Material == Enum.Material.Concrete then -- if the player drives over concrete
								Car.Chassis.FloorPanel.VectorForce.Force = Vector3.new(0,0,0)

							elseif FloorMaterial.Material == Enum.Material.Grass then -- if the player drives over grass, then slow him down a bit
								Car.Chassis.FloorPanel.VectorForce.Force = Vector3.new(0,0,60000)

							elseif FloorMaterial.Material == Enum.Material.Sand then -- if the player drives over sand, them slow him down
								Car.Chassis.FloorPanel.VectorForce.Force = Vector3.new(0,0,125000)

							elseif FloorMaterial.Material == Enum.Material.Marble then -- if the player drives over marble, then slow him down a lot (when the players fails the cut)
								Car.Chassis.FloorPanel.VectorForce.Force = Vector3.new(0,0,250000)	
							end
						end

						wait(0.3)
					end
					
					if Car and Car.Parent then
						Car.Chassis.FloorPanel.VectorForce.Force = Vector3.new(0,0,0)
					end

					if Car and Car.Parent and (tick() - Car.StartTime.Value) > 180 and Car:FindFirstChild("Checkpoint").Value ~= 14 then -- if the player has been racing for more than 3 minutes
						DestroyCar(plr) -- unsit player and destroy the car
						
						RacingGui.Visible = false -- reset all the racing gui
						RacingGui.Speedometer.Frame.Speed.Text = 0
						RacingGui.Speedometer.Needle.Rotation = 0
						RacingGui.Tachometer.Frame.RPM.Text = 0
						RacingGui.Tachometer.Needle.Rotation = 0
						RacingGui.Timer.Text = "0"
					end
				end
			end
		end
	end)()
end


-- START THE RACE

local function StartRace(hit)
	if RaceTrack.WaitToStart.Value and Players:FindFirstChild(hit.Parent.Name) then -- if a player is already racing and has not reached the checkpoint 3 yet
		if workspace:FindFirstChild(hit.Parent.Name) and workspace:FindFirstChild(hit.Parent.Name):FindFirstChild("HumanoidRootPart") then -- if the player's humanoid has been found
			workspace:FindFirstChild(hit.Parent.Name):FindFirstChild("HumanoidRootPart").CFrame = RaceTrack.TeleportPart.CFrame -- tp the player to the the stands 
		end
		
		Players:FindFirstChild(hit.Parent.Name).CanDie.Value = false
		
		for i,v in pairs(QueueTable) do -- if the player is already in the table then return
			if v == hit.Parent.Name then
				return
			end
		end

		table.insert(QueueTable, (#QueueTable + 1), hit.Parent.Name) -- insert the player to the table
		Players:FindFirstChild(hit.Parent.Name).PlayerGui.RaceTrack.Queue.Visible = true -- show the queue gui
		Players:FindFirstChild(hit.Parent.Name).PlayerGui.RaceTrack.Queue.QueuePosition.Text = "Position in queue : "..tostring(#QueueTable) -- show the player's position in the queue

		coroutine.wrap(function()
			repeat wait(1) until RaceTrack.WaitToStart.Value == false -- wait for the wait to start value to be false (so that another player can start driving)

			while #QueueTable ~= 0 do -- if there is a player waiting to race
				if Players:FindFirstChild(QueueTable[1]) then -- if the player can be found from the table

					local plr = Players:FindFirstChild(QueueTable[1]) -- get the player
					table.remove(QueueTable, 1) -- remove the player from the table
					RaceTrack.WaitToStart.Value = true -- set wait for player to true so that if there is another player waiting, he has to wait 
					plr.PlayerGui.RaceTrack.Queue.Visible = false -- hide the queue gui

					for i,v in pairs(QueueTable) do -- for every player in the queue table
						if Players:FindFirstChild(v) then
							Players:FindFirstChild(v).PlayerGui.RaceTrack.Queue.QueuePosition.Text = "Position in queue : "..tostring(i) -- lower the position in the queue
						end
					end

					Race(plr) -- create the car for the player

				else -- if the player hasn't been found
					table.remove(QueueTable, 1) -- remove the player from the table
				end
			end
		end)()

	else -- if no one is racing or the player racing has reached checkpoint 3 
		RaceTrack.WaitToStart.Value = true  -- set wait for player to true so that if there is another player waiting, he has to wait 

		Race(Players:FindFirstChild(hit.Parent.Name)) -- create the car for the player			
	end
end


-- WHEN THE PLAYER TOUCHES THE TRIGGER TO START THE RACE

RaceTrack.RaceTrigger.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) then -- if the hit is the humanoid root part of the player
		StartRace(hit) -- start the race
	end
end)


-- CHECKPOINTS

for i,v in ipairs(workspace.RaceTrack.Checkpoints:GetChildren()) do
	v.Touched:Connect(function(hit)
		if hit.Name == "CheckpointTrigger" and hit.Parent.Parent:FindFirstChild("Checkpoint") and Players:FindFirstChild(hit.Parent.Parent.Chassis.VehicleSeat.Occupant.Parent.Name) then -- if hit is the checkpoint trigger from the car and the checkpoint value is found
			
			if v.Checkpoint.Value == hit.Parent.Parent:FindFirstChild("Checkpoint").Value + 1 then -- if the checkpoint the player hit is the same as the one he hits last + 1
				hit.Parent.Parent:FindFirstChild("Checkpoint").Value += 1 -- add 1 to the checkpoint value
				Players:FindFirstChild(hit.Parent.Parent.Chassis.VehicleSeat.Occupant.Parent.Name).PlayerGui.RaceTrack.Racing.CheckpointMiss.Visible = false -- hide the missed checkpoint text
				
			elseif (hit.Parent.Parent:FindFirstChild("Checkpoint").Value ~= 0 or (hit.Parent.Parent:FindFirstChild("Checkpoint").Value == 0 and v.Checkpoint.Value ~= 14)) and v.Checkpoint.Value ~= hit.Parent.Parent:FindFirstChild("Checkpoint").Value then -- if the player missed a checkpoint but has already taken at least one (otherwise it shows the text right when the player crosses the start line (because of checkpoint 14)) and when player is not taking the same checkpoint multiple times
				Players:FindFirstChild(hit.Parent.Parent.Chassis.VehicleSeat.Occupant.Parent.Name).PlayerGui.RaceTrack.Racing.CheckpointMiss.Visible = true -- show the missed checkpoint text
			end
			
			if hit.Parent.Parent:FindFirstChild("Checkpoint").Value == 3 then -- if the player has reached checkpoint 3
				RaceTrack.WaitToStart.Value = false -- set wait to start to false so that the next player can start

			elseif hit.Parent.Parent:FindFirstChild("Checkpoint").Value == 14 then -- if the player has reached the finish line (checkpoint 14)
				hit.Parent.Parent.StartTime.Value = tick() - hit.Parent.Parent.StartTime.Value -- get the exact time ellasped since the start (timer) 
				hit.Parent.Parent.StartTime.Value = math.floor(hit.Parent.Parent.StartTime.Value * 1000) / 1000 -- round the start time to only have 3 digits after the coma (ex : start time : 123.4567890123, x1000 : 123456.7890123, floor : 123456, /1000 : 123.456)
				
				Players:FindFirstChild(hit.Parent.Parent.Chassis.VehicleSeat.Occupant.Parent.Name).CanDie.Value = true
				
				coroutine.wrap(function()
					if hit.Parent.Parent.Chassis.VehicleSeat.Occupant and Players:FindFirstChild(hit.Parent.Parent.Chassis.VehicleSeat.Occupant.Parent.Name) then -- if there is a player in the driver seat
						local plr = Players:FindFirstChild(hit.Parent.Parent.Chassis.VehicleSeat.Occupant.Parent.Name) -- get the player
						
						MoneyBindableFunction:Invoke(plr, 1000, "+")
						ExperienceBindableEvent:Fire(plr, "Racer", 12)
						
						for i,v in ipairs(hit.Parent.Parent.Chassis:GetChildren()) do -- for all wheels
							if v:IsA("Model") and v:FindFirstChild("Wheel") then
								v:FindFirstChild("Wheel").CustomPhysicalProperties = PhysicalProperties.new(2, 0.1, 2, 100, 1) -- set the friction very low so that the car slids into the barrier (to avoid having the car stuck in the middle of the track)
							end
						end
						
						for i,v in ipairs(hit.Parent.Parent.Constraints:GetChildren()) do -- for all motors
							if v:IsA("CylindricalConstraint") then
								v.AngularLimitsEnabled = true -- block the wheels (can only turn 90 degrees)
							end
						end
						
						plr.PlayerGui.RaceTrack.Racing.Visible = false -- hide the racing gui
						plr.PlayerGui.RaceTrack.Finish.Visible = true -- show the finish gui
						plr.PlayerGui.RaceTrack.Finish.Restart:TweenPosition(UDim2.new(0.25,0,0.51,0)) -- tween the restart button lower
						plr.PlayerGui.RaceTrack.Finish.Quit:TweenPosition(UDim2.new(0.75,0,0.51,0)) -- tween the quit button lower
						
						wait(1)
						
						plr.PlayerGui.RaceTrack.Finish.Time.Visible = true -- show the time text

						local Seconds = math.floor(hit.Parent.Parent.StartTime.Value) -- get the seconds

						plr.PlayerGui.RaceTrack.Finish.Timer.Text = tostring(Seconds)..","..tostring(math.floor((hit.Parent.Parent.StartTime.Value - Seconds) * 1000)) -- show the time the player got seconds and milliseconds
						plr.PlayerGui.RaceTrack.Finish.Timer.Visible = true -- show the time the player got

						if hit.Parent.Parent.StartTime.Value < 180 then
							if hit.Parent.Parent.StartTime.Value < plr.Stats.BestRaceTime.Value or plr.Stats.BestRaceTime.Value == 0 then -- if player has beaten his best time or has never fisnihed the race yet

								plr.PlayerGui.RaceTrack.Finish.NewRecord.PreviousTime.Text = "Previous best time : "..tostring(plr.Stats.BestRaceTime.Value) -- show the previous best time
								plr.PlayerGui.RaceTrack.Finish.NewRecord.Improvement.Text = "("..tostring(plr.Stats.BestRaceTime.Value - hit.Parent.Parent.StartTime.Value)..")" -- show the improvement : (-x.xxx)
								plr.PlayerGui.RaceTrack.Finish.NewRecord.Visible = true -- show the new record text

								RaceTrackBindableEvent:Fire(plr, hit.Parent.Parent.StartTime.Value) -- fire the datastore to save the new time

							elseif hit.Parent.Parent.StartTime.Value < workspace.RaceTrack.Leaderboard.LowestTime.Value or workspace.RaceTrack.Leaderboard.LowestTime.Value == 0 then -- if player makes it into the leaderboard
								RaceTrackBindableEvent:Fire(plr, hit.Parent.Parent.StartTime.Value) -- fire the server to save and change the the leaderboard
							end
						end
					end
				end)()
			end
		end
	end)
end


-- PLAYER CLICKS ON OF THE BUTTON (RESTART AND QUIT IN BOTH THE RACING AND FINISH GUI)

RaceTrackRemoteEvent.OnServerEvent:Connect(function(plr, Type)

	DestroyCar(plr) -- unsit player and destroy the car
	plr.CanDie.Value = true

	local RacingGui = plr.PlayerGui.RaceTrack.Racing -- get the racing and finish gui
	local FinishGui = RacingGui.Parent.Finish
	if RacingGui and FinishGui then

		if FinishGui.Visible == true then -- if the finish gui is shown, reset all the finish gui
			FinishGui.Visible = false
			FinishGui.NewRecord.Visible = false
			FinishGui.NewRecord.PreviousTime.Text = "Previous best time :"
			FinishGui.NewRecord.Improvement.Text = ""
			FinishGui.Timer.Text = ""
			FinishGui.Timer.Visible = false
			FinishGui.Time.Visible = false
			FinishGui.Quit.Position = UDim2.new(0.7,0,0.13,0)
			FinishGui.Restart.Position = UDim2.new(0.3,0,0.13,0)
		end

		RacingGui.Visible = false -- reset all the racing gui
		RacingGui.Speedometer.Frame.Speed.Text = 0
		RacingGui.Speedometer.Needle.Rotation = 0
		RacingGui.Tachometer.Frame.RPM.Text = 0
		RacingGui.Tachometer.Needle.Rotation = 0
		RacingGui.Timer.Text = "0"
	end
	
	if Type == "Restart" then -- if player clicked on one of the restart buttons
		if plr.Character and plr.Character.HumanoidRootPart then -- if the player humanoid root part was found
			StartRace(plr.Character.HumanoidRootPart) -- restart the race (add to queue if needed) (fired with the humanoid root part as arugument because it corresponds to the hit if it was a touched event)
		end
	end
end)