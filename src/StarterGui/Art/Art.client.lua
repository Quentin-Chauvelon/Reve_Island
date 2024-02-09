local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ArtRemoteFunction = ReplicatedStorage:WaitForChild("Art")

local lplr = game.Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera
local ArtGui = script.Parent
local Art = workspace.School.Art
local Mouse = lplr:GetMouse()

local SelectedColor = 1
local Level = 1
local TimerOut = false
local Sit = false
local Colors = {Color3.fromRGB(230,0,255), Color3.fromRGB(0,255,255), Color3.fromRGB(0,255,0), Color3.fromRGB(255,255,0), Color3.fromRGB(255,128,0)}

local TweenArtCamera = TweenService:Create(CurrentCamera, TweenInfo.new(2), {CFrame = Art.ArtCamera.CFrame})
local TweenTableCamera = TweenService:Create(CurrentCamera, TweenInfo.new(2), {CFrame = Art.TableCamera.CFrame})

local Unsit, Level1, Level2, Level3, Level4, Level5
local PurpleClicked, BlueClicked, GreenClicked, YellowClicked, OrangeClicked, EraseClicked, MouseClicked, ScreenTouched


-- LOAD ART DATA (LOCKED LEVELS)

lplr:WaitForChild("Art")
ArtGui:WaitForChild("Board"):WaitForChild("Levels"):WaitForChild("Level1")
ArtGui.Board.Levels:WaitForChild("Level2")
ArtGui.Board.Levels:WaitForChild("Level3")
ArtGui.Board.Levels:WaitForChild("Level4")
ArtGui.Board.Levels:WaitForChild("Level5")

-- Unlock the levels
for i,v in ipairs(lplr.Art:GetChildren()) do
	if not v.Value and v:FindFirstChild("Level") and ArtGui.Board.Levels:FindFirstChild("Level"..tostring(v.Level.Value)) then
		ArtGui.Board.Levels:FindFirstChild("Level"..tostring(v.Level.Value)).Lock.Visible = false

		-- Show as completed or let it blank if the player ahs not completed the level yet
		if not lplr.Art:FindFirstChild("Lock"..(v.Level.Value + 1)).Value then
			ArtGui.Board.Levels:FindFirstChild("Level"..tostring(v.Level.Value)).Completed.Visible = true
		end
	end
end

if not lplr.Art.Lock6.Value then
	ArtGui.Board.Levels.CompleteAllLevels.Visible = false
	ArtGui.Board.Levels.CompletedAllLevels.Visible = true
end


-- RESET

local function Reset()
	ArtGui.Drawing.Visible = false
	ArtGui.Timer.Visible = false

	-- Hide the drawing board and the template
	if ArtGui.Drawing.DrawingBoard:FindFirstChild("Level"..tostring(Level)) then
		ArtGui.Drawing.DrawingBoard["Level"..tostring(Level)].Visible = false
	end

	if ArtGui.Drawing.Template:FindFirstChild("Level"..tostring(Level)) then
		ArtGui.Drawing.Template["Level"..tostring(Level)].Visible = false
	end
	
	-- Reset all the tiles from the drawing board and the template
	for i,v in ipairs(ArtGui.Drawing.DrawingBoard["Level"..tostring(Level)]:GetChildren()) do
		if v:IsA("Frame") then
			v.BackgroundColor3 = Color3.new(1,1,1)
		end
	end
	
	for i,v in ipairs(ArtGui.Drawing.Template["Level"..tostring(Level)]:GetChildren()) do
		if v:IsA("Frame") then
			v.BackgroundColor3 = Color3.new(1,1,1)
		end
	end
end


-- GET THE FRAME THE PLAYER CLICKED USING THE COORDINATES OF THE MOUSE OR SCREEN TOUCHED EVENTS

local function GetClickedFrame(PositionX, PositionY)
	if ArtGui.Drawing.Visible then
		
		local DrawingBoard = ArtGui.Drawing.DrawingBoard:FindFirstChild("Level"..tostring(Level))

		if DrawingBoard then
			-- Find the column and the row the player clicked
			local Column = math.ceil((PositionY - DrawingBoard.AbsolutePosition.Y) / (DrawingBoard.AbsoluteSize.Y / (2 + Level)))
			local Row = math.ceil((PositionX - DrawingBoard.AbsolutePosition.X) / (DrawingBoard.AbsoluteSize.X / (2 + Level)))

			-- Change the color of the tile the player clicked
			if DrawingBoard:FindFirstChild("C"..tostring(Column).."R"..tostring(Row)) then
				DrawingBoard["C"..tostring(Column).."R"..tostring(Row)].BackgroundColor3 = Colors[SelectedColor] or Color3.fromRGB(230,0,255)
			end

			-- Fire the server to check if the player clicked the right color
			local Finished = ArtRemoteFunction:InvokeServer(Level, false, Column, Row, SelectedColor)
			
			if Finished then
				TimerOut = true

				Reset()

				if ArtGui.Board.Levels:FindFirstChild("Level"..tostring(Level)) then
					ArtGui.Board.Levels["Level"..tostring(Level)].Completed.Visible = true
				end

				if ArtGui.Board.Levels:FindFirstChild("Level"..tostring(Level + 1)) then
					ArtGui.Board.Levels["Level"..tostring(Level + 1)].Lock.Visible = false
				end

				if Level == 1 then
					ArtGui.Completed.Text = "You unlocked the level 2 and earnt $2000"
				elseif Level == 2 then
					ArtGui.Completed.Text = "You unlocked the level 3 and earnt $5000"
				elseif Level == 3 then
					ArtGui.Completed.Text = "You unlocked the level 4 and earnt $10 000"
				elseif Level == 4 then
					ArtGui.Completed.Text = "You unlocked the level 5 and earnt $25 000"
				elseif Level == 5 then
					ArtGui.Completed.Text = "Congratulations! You completed all the levels and earnt $50 000"
				end

				ArtGui.Completed.Visible = true
				wait(6)
				ArtGui.Completed.Visible = false

				if Sit then
					TweenArtCamera:Play()
					wait(2)
					ArtGui.Board.Levels.Visible = true
				end
			end
		end
	end
end


-- PLAYER PICKED A LEVEL TO START THE GAME

local function StartLevel(PickedLevel)

	Level = PickedLevel
	
	if Level == 1 or (lplr.Art:FindFirstChild("Lock"..tostring(Level)) and not lplr.Art:FindFirstChild("Lock"..tostring(Level)).Value) then
		
		local ArtMatrix = ArtRemoteFunction:InvokeServer(Level)
		local TemplateBoard = ArtGui.Drawing.Template:FindFirstChild("Level"..tostring(Level))
		
		if ArtMatrix and typeof(ArtMatrix) == "table" and TemplateBoard then
			
			-- Color the template drawing board with the colors of the matrix			
			for column,v in pairs(ArtMatrix) do
				for row, b in pairs(v) do
					
					if TemplateBoard:FindFirstChild("C"..tostring(column).."R"..tostring(row)) then
						TemplateBoard["C"..tostring(column).."R"..tostring(row)].BackgroundColor3 = Colors[b] or Color3.fromRGB(230,0,255)
					end
				end
			end
			
			TweenTableCamera:Play()
			wait(2)
			
			TemplateBoard.Visible = true
			
			if ArtGui.Drawing.DrawingBoard:FindFirstChild("Level"..tostring(Level)) then
				ArtGui.Drawing.DrawingBoard["Level"..tostring(Level)].Visible = true
			end
			
			-- Countdown
			ArtGui.Countdown.Visible = true
			for i=3,1,-1 do
				ArtGui.Countdown.Text = tostring(i)
				wait(0.5)
			end

			ArtGui.Countdown.Text = "Go!"
			wait(1)

			if Sit then
				ArtGui.Countdown.Visible = false
				ArtGui.Timer.Visible = true
				ArtGui.Drawing.Visible = true
				TimerOut = false
				SelectedColor = 1
				
				-- Set the timer based on the level
				local Time = 0
				if Level == 1 then
					Time = 15
				elseif Level == 5 then
					Time = 24
				else
					Time = 20
				end
				
				-- Timer
				coroutine.wrap(function()
					for i=Time,0,-1 do

						if TimerOut or not Sit then
							break
						else
							ArtGui.Timer.Text = tostring(i)
							wait(1)
						end
					end

					if not TimerOut and Sit then
						TimerOut = true
						Reset()
						
						ArtGui.Fail.Visible = true
						wait(3)

						if ArtGui.IsPlaying.Value then
							ArtRemoteFunction:InvokeServer() -- invoke the server to end the game if the player didn't already do it (so that he can restart)
						end

						wait(1)
						ArtGui.Fail.Visible = false

						if Sit then
							TweenArtCamera:Play()
							wait(2)
							ArtGui.Board.Levels.Visible = true
						end
					end
					
					TimerOut = true
				end)()
				
			-- if the player is not sitting anymore
			else
				TimerOut = true
				Reset()

				if ArtGui.IsPlaying.Value then
					ArtRemoteFunction:InvokeServer() -- invoke the server to end the game if the player didn't already do it (so that he can restart)
				end
			end
		end
	end
end


-- GET ALL THE SEATS EVENTS

for i,v in ipairs(Art.Seats:GetChildren()) do
	v:GetPropertyChangedSignal("Occupant"):Connect(function()
		if v.Occupant and v.Occupant.Parent and v.Occupant.Parent.Name == lplr.Name then
			if Players:GetPlayerFromCharacter(v.Occupant.Parent) then
				
				Sit = true
				
				Level1 = ArtGui.Board.Levels.Level1.Activated:Connect(function()
					StartLevel(1)
				end)

				Level2 = ArtGui.Board.Levels.Level2.Activated:Connect(function()
					StartLevel(2)
				end)

				Level3 = ArtGui.Board.Levels.Level3.Activated:Connect(function()
					StartLevel(3)
				end)

				Level4 = ArtGui.Board.Levels.Level4.Activated:Connect(function()
					StartLevel(4)
				end)

				Level5 = ArtGui.Board.Levels.Level5.Activated:Connect(function()
					StartLevel(5)
				end)

				Unsit = v:GetPropertyChangedSignal("Occupant"):Connect(function()
					Sit = false
					CurrentCamera.CameraType = Enum.CameraType.Custom

					ArtGui.Board.Levels.Visible = false
					ArtGui.Board.TextLabel.Visible = true
					ArtGui.Board.SitDown.Visible = true

					-- Disconnec the unsit event 
					Unsit:Disconnect()

					-- Disconnect all the click events for the levels
					Level1:Disconnect()
					Level2:Disconnect()
					Level3:Disconnect()
					Level4:Disconnect()
					Level5:Disconnect()

					-- Disconnect all the colors click events
					PurpleClicked:Disconnect()
					BlueClicked:Disconnect()
					GreenClicked:Disconnect()
					YellowClicked:Disconnect()					
					OrangeClicked:Disconnect()
					EraseClicked:Disconnect()
					MouseClicked:Disconnect()
					ScreenTouched:Disconnect()
					
					Reset()
				end)

				PurpleClicked = ArtGui.Drawing.Colors.Purple.MouseButton1Down:Connect(function()
					SelectedColor = 1
				end)

				BlueClicked = ArtGui.Drawing.Colors.Blue.MouseButton1Down:Connect(function()
					SelectedColor = 2
				end)

				GreenClicked = ArtGui.Drawing.Colors.Green.MouseButton1Down:Connect(function()
					SelectedColor = 3
				end)

				YellowClicked = ArtGui.Drawing.Colors.Yellow.MouseButton1Down:Connect(function()
					SelectedColor = 4
				end)

				OrangeClicked = ArtGui.Drawing.Colors.Orange.MouseButton1Down:Connect(function()
					SelectedColor = 5
				end)

				EraseClicked = ArtGui.Drawing.Colors.Erase.MouseButton1Down:Connect(function()
					-- Make all the drawing frames white
					if ArtGui.Drawing.DrawingBoard:FindFirstChild("Level"..tostring(Level)) then
						for i,v in ipairs(ArtGui.Drawing.DrawingBoard["Level"..tostring(Level)]:GetChildren()) do
							if v:IsA("Frame") then
								v.BackgroundColor3 = Color3.new(1,1,1)
							end
						end
					end
					
					ArtRemoteFunction:InvokeServer(Level, true)
				end)
				
				if Mouse then
					MouseClicked = Mouse.Button1Down:Connect(function()
						GetClickedFrame(Mouse.X, Mouse.Y)
					end)
				end
				
				ScreenTouched = UserInputService.TouchStarted:Connect(function(Input)
					GetClickedFrame(Input.Position.X, Input.Position.Y)
				end)
				
				CurrentCamera.CameraType = Enum.CameraType.Scriptable
				TweenArtCamera:Play()
				wait(2)

				if Sit then
					ArtGui.Board.SitDown.Visible = false
					ArtGui.Board.Levels.Visible = true
				end
			end
		end
	end)
end