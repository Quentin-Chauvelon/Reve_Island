local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MathsRemoteEvent = ReplicatedStorage:WaitForChild("Maths")

local MathsGui = script.Parent:WaitForChild("Board")
local Maths = workspace.School.Maths
local CurrentCamera = workspace.CurrentCamera
local lplr = game.Players.LocalPlayer

local TimerOut = false
local Sit = false
local Level = 1
local Score = 0
local ScoreNeeded = {0, 8, 8, 10, 10, 10}

local TweenMathsCamera = TweenService:Create(CurrentCamera, TweenInfo.new(2), {CFrame = game.Workspace.School.Maths.MathsCamera.CFrame})

local Unsit, Level1, Level2, Level3, Level4, Level5, ValidateButton, ValidateEnter


-- LOAD MATHS DATA (BEST AND LOCKED LEVELS)

lplr:WaitForChild("Maths")
lplr.Maths:WaitForChild("Lock")
lplr.Maths:WaitForChild("Best")
MathsGui:WaitForChild("Levels"):WaitForChild("Level1")
MathsGui.Levels:WaitForChild("Level2")
MathsGui.Levels:WaitForChild("Level3")
MathsGui.Levels:WaitForChild("Level4")
MathsGui.Levels:WaitForChild("Level5")

--Best value for the level 1 (separated from the other levels because it is always unlocked)
MathsGui.Levels.Level1.Best.Text ="Best : "..tostring(lplr.Maths.Best.Best1.Value)

-- Unlock + best values for the other levels
for i,v in ipairs(lplr.Maths.Lock:GetChildren()) do
	if not v.Value and v:FindFirstChild("Level") and MathsGui.Levels:FindFirstChild("Level"..tostring(v.Level.Value)) then
		MathsGui.Levels:FindFirstChild("Level"..tostring(v.Level.Value)).Lock.Visible = false
		MathsGui.Levels:FindFirstChild("Level"..tostring(v.Level.Value)).Require.Visible = false

		if lplr.Maths.Best:FindFirstChild("Best"..tostring(v.Level.Value)) then
			MathsGui.Levels:FindFirstChild("Level"..tostring(v.Level.Value)).Best.Text = "Best : "..tostring(lplr.Maths.Best:FindFirstChild("Best"..tostring(v.Level.Value)).Value)
		end
		
		MathsGui.Levels:FindFirstChild("Level"..tostring(v.Level.Value)).Best.Visible = true
	end
end

if not lplr.Maths.Lock.Lock6.Value then
	MathsGui.Levels.CompleteAllLevels.Visible = false
	MathsGui.Levels.CompletedAllLevels.Visible = true
end


-- HIDE THE GUIS

local function Reset()
	-- Hide the guis
	TimerOut = true
	MathsGui.Calculation.Visible = false
	MathsGui.Countdown.Visible = false
	MathsGui.Points.Visible = false
end


-- VALIDATE ANSWER (BY CLICKING THE VALIDATE BUTTON OR PRESSING ENTER WHILE FOCUSING THE TEXTBOX)

local function ValidateAnswer()
	MathsGui.Calculation.Calcul.Text, Score = MathsRemoteEvent:InvokeServer((tonumber(MathsGui.Calculation.TextBox.Text) or 0), Level)
	MathsGui.Calculation.TextBox:CaptureFocus()
end


-- PLAYER PICKED A LEVEL

local function StartLevel(LevelPicked)

	-- If the player has unlocked the level or is playing the level 1
	if LevelPicked == 1 or (lplr.Maths.Lock:FindFirstChild("Lock"..tostring(LevelPicked)) and not lplr.Maths.Lock:FindFirstChild("Lock"..tostring(LevelPicked)).Value) then
		Level = LevelPicked

		MathsGui.Levels.Visible = false
		MathsGui.Countdown.Visible = true

		-- Countdown
		for i=3,1,-1 do
			MathsGui.Countdown.Text = tostring(i)
			wait(0.5)
		end

		MathsGui.Countdown.Text = "Go!"
		wait(1)

		if Sit then
			MathsGui.Countdown.Visible = false
			MathsGui.Calculation.Visible = true

			Score = 0
			TimerOut = false
			MathsGui.Calculation.TimerCount.Text = 30
			ValidateAnswer() -- call it once to get a calculation

			-- Timer
			coroutine.wrap(function()
				-- 30 seconds timer
				for i=30,0,-1 do
					if TimerOut or not Sit then
						break
					else
						MathsGui.Calculation.TimerCount.Text = tostring(i)
						wait(1)
					end
				end

				TimerOut = true

				if Sit then
					MathsGui.Calculation.Visible = false
					MathsGui.Points.Points.Text = tostring(Score).." right answers"
					MathsGui.Points.Visible = true

					-- If the player beat his best score, update it
					if lplr.Maths.Best:FindFirstChild("Best"..tostring(Level)) and Score > lplr.Maths.Best:FindFirstChild("Best"..tostring(Level)).Value then
						MathsGui.Points.NewBest.Visible = true

						-- Update the text on the level gui
						local BestGui = MathsGui.Levels:FindFirstChild("Level"..tostring(Level))
						if BestGui then
							BestGui.Best.Text = "Best : "..tostring(Score)
						end

						-- If the player has a score which is enough to unlock the next level
						if ScoreNeeded[Level+1] and Score >= ScoreNeeded[Level+1] then

							-- If the player has not unlocked the next level yet
							if lplr.Maths.Lock:FindFirstChild("Lock"..tostring(Level+1)) and lplr.Maths.Lock:FindFirstChild("Lock"..tostring(Level+1)).Value then

								-- Show the unlock level text label on the points gui
								local PointsGui = MathsGui.Points:FindFirstChild("Unlock"..tostring(Level+1))
								if PointsGui then
									PointsGui.Visible = true
								end

								-- Unlock the level on the levels gui
								local LevelGui = MathsGui.Levels:FindFirstChild("Level"..tostring(Level+1))
								if LevelGui then
									LevelGui.Lock.Visible = false
									LevelGui.Require.Visible = false
									LevelGui.Best.Visible = true
								end

								if Level == 5 then
									MathsGui.Points.Win5.Visible = true
								end
							end

							-- If the player didn't get a score good enough to unlock the next level
						else
							-- If the player has not unlocked the next level yet
							if lplr.Maths.Lock:FindFirstChild("Lock"..tostring(Level+1)) and lplr.Maths.Lock:FindFirstChild("Lock"..tostring(Level+1)).Value then
								local LockGui = MathsGui.Points:FindFirstChild("Lock"..tostring(Level+1))
								
								if LockGui then
									LockGui.Visible = true
								end
							end
						end
					end

					wait(4)
					-- If the player is still playing (he didn't fire the event after the end of the timer)
					-- then force the client to finish playing so that he can restart another game
					if MathsGui.IsPlaying.Value then
						MathsGui.Calculation.TextBox:ReleaseFocus()
						ValidateAnswer()
					end
					wait(4)

					MathsGui.Points.Visible = false
					MathsGui.Levels.Visible = true

					-- Hide all the points children (best, lock, newbest..)
					for i,v in ipairs(MathsGui.Points:GetChildren()) do
						if v:IsA("TextLabel") and v.Name ~= "Points" then
							v.Visible = false
						end
					end
				end
			end)()
		end
	end
end


-- GET ALL THE SEATS EVENTS

for i,v in ipairs(Maths.Seats:GetChildren()) do
	v:GetPropertyChangedSignal("Occupant"):Connect(function()
		if v.Occupant and v.Occupant.Parent and v.Occupant.Parent.Name == lplr.Name then
			if Players:GetPlayerFromCharacter(v.Occupant.Parent) then
				
				Level1 = MathsGui.Levels.Level1.Activated:Connect(function()
					StartLevel(1)
				end)

				Level2 = MathsGui.Levels.Level2.Activated:Connect(function()
					StartLevel(2)
				end)

				Level3 = MathsGui.Levels.Level3.Activated:Connect(function()
					StartLevel(3)
				end)

				Level4 = MathsGui.Levels.Level4.Activated:Connect(function()
					StartLevel(4)
				end)

				Level5 = MathsGui.Levels.Level5.Activated:Connect(function()
					StartLevel(5)
				end)

				Sit = true

				Unsit = v:GetPropertyChangedSignal("Occupant"):Connect(function()
					Sit = false
					CurrentCamera.CameraType = Enum.CameraType.Custom

					MathsGui.Levels.Visible = false
					MathsGui.SitDown.Visible = true

					-- Disconnec the unsit event 
					Unsit:Disconnect()

					-- Disconnect all the click events for the levels
					Level1:Disconnect()
					Level2:Disconnect()
					Level3:Disconnect()
					Level4:Disconnect()
					Level5:Disconnect()

					-- Disconnect the events to validate the answer
					ValidateButton:Disconnect()
					ValidateEnter:Disconnect()

					Reset()
				end)
				
				CurrentCamera.CameraType = Enum.CameraType.Scriptable
				TweenMathsCamera:Play()
				wait(2)

				if Sit then
					MathsGui.SitDown.Visible = false
					MathsGui.Levels.Visible = true

					-- Player validates his answer by clicking the validate button
					ValidateButton = MathsGui.Calculation.TextBox.Validate.Activated:Connect(function()
						-- Check if the player is playing before validating the answer
						-- Do that to avoid restarting a game when the player is in the middle of his game
						if MathsGui.IsPlaying.Value then
							ValidateAnswer()
						end
					end)

					-- Player validates his answer by pressing enter
					ValidateEnter = MathsGui.Calculation.TextBox.FocusLost:Connect(function(EnterPressed)
						if EnterPressed and MathsGui.IsPlaying.Value then
							ValidateAnswer()
						end
					end)
				end
			end
		end
	end)
end