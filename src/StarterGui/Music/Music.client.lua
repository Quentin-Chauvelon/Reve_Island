local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MusicRemoteFunction = ReplicatedStorage:WaitForChild("Music")

local MusicGui = script.Parent:WaitForChild("Board")
local Music = workspace.School.Music
local CurrentCamera = workspace.CurrentCamera
local lplr = game.Players.LocalPlayer

local TimerOut = false
local Sit = false
local Level = 1
local WaitTime = 0
local WaitForNextNote = false
local IsPlaying = false

local TweenMusicCamera = TweenService:Create(CurrentCamera, TweenInfo.new(2), {CFrame = Music.MusicCamera.CFrame})

local Unsit, Level1, Level2, Level3, Level4, Level5, GreenClicked, PurpleClicked, RedClicked, YellowClicked, BlueClicked

local BackgroundColors = {Color3.fromRGB(8, 170, 0), Color3.fromRGB(222, 5, 193), Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 213, 0), Color3.fromRGB(6, 181, 255)}
local BorderColors = {Color3.fromRGB(6, 136, 0), Color3.fromRGB(186, 3, 162), Color3.fromRGB(180, 0, 0), Color3.fromRGB(200, 167, 0), Color3.fromRGB(3, 141, 195)}


-- LOAD MUSIC DATA (LOCKED LEVELS)

lplr:WaitForChild("Music")
MusicGui:WaitForChild("Levels"):WaitForChild("Level1")
MusicGui.Levels:WaitForChild("Level2")
MusicGui.Levels:WaitForChild("Level3")
MusicGui.Levels:WaitForChild("Level4")
MusicGui.Levels:WaitForChild("Level5")

-- Unlock the levels
for i,v in ipairs(lplr.Music:GetChildren()) do
	if not v.Value and v:FindFirstChild("Level") and MusicGui.Levels:FindFirstChild("Level"..tostring(v.Level.Value)) then
		MusicGui.Levels:FindFirstChild("Level"..tostring(v.Level.Value)).Lock.Visible = false
		
		-- Show as completed or let it blank if the player ahs not completed the level yet
		if not lplr.Music:FindFirstChild("Lock"..(v.Level.Value + 1)).Value then
			MusicGui.Levels:FindFirstChild("Level"..tostring(v.Level.Value)).Completed.Visible = true
		end
	end
end

if not lplr.Music.Lock6.Value then
	MusicGui.Levels.CompleteAllLevels.Visible = false
	MusicGui.Levels.CompletedAllLevels.Visible = true
end


-- RESET THE GAME

local function Reset()
	MusicGui.Songs.Visible = false
	MusicGui.Songs.Song:ClearAllChildren()
	WaitTime = 0 -- set it to 0 so that the song finishes instantly and the player can restart (this avoid having to check if the player is still sitting at each loop)
end


-- GAME ENDS (EITHER WHEN PLAYER CLICKS ALL THE NOTES OR WHEN TIMER RUNS OUT)

local function EndOfGame(Correct)
	
	IsPlaying = false
	Reset()

	local MaxScore = (5 + 5 * Level)

	-- If player got all the notes right, he unlocks the next level
	if Correct and Correct == MaxScore then

		if Level == 1 then
			MusicGui.FinalScore.Text = "You unlocked level 2 and earnt $2000"
		elseif Level == 2 then
			MusicGui.FinalScore.Text = "You unlocked level 3 and earnt $5000"
		elseif Level == 3 then
			MusicGui.FinalScore.Text = "You unlocked level 4 and earnt $10 000"
		elseif Level == 4 then
			MusicGui.FinalScore.Text = "You unlocked level 5 and earnt $25 000"
		elseif Level == 5 then
			MusicGui.FinalScore.Text = "Congratulations! You completed all the levels and earnt $50 000"
			MusicGui.Levels.CompleteAllLevels.Visible = false
			MusicGui.Levels.CompletedAllLevels.Visible = true
		end
		
		if MusicGui.Levels:FindFirstChild("Level"..tostring(Level)) then
			MusicGui.Levels:FindFirstChild("Level"..tostring(Level)).Completed.Visible = true
		end

		if MusicGui.Levels:FindFirstChild("Level"..tostring(Level+1)) then
			MusicGui.Levels:FindFirstChild("Level"..tostring(Level+1)).Lock.Visible = false
		end
	else

		MusicGui.FinalScore.Text = "You scored "..tostring(Correct).."/"..tostring(MaxScore)..". You need "..tostring(MaxScore).."/"..tostring(MaxScore).." to unlock level "..tostring(Level+1)
	end

	MusicGui.FinalScore.Visible = true
	wait(6)
	MusicGui.FinalScore.Visible = false
	MusicGui.Levels.Visible = true
end


-- TIMER TO STOP THE LEVEL IF THE PLAYER DOESN'T CLICK ALL THE NOTES OR STOPS PLAYING

local function Timer(TimeToWait)
	wait(TimeToWait + 2)
	
	if IsPlaying then
		local Finished, Correct = MusicRemoteFunction:InvokeServer("Stop")
		EndOfGame(Correct)
	end
end


-- PLAYER CLICKS A COLOR

local function ColorClicked(Color)
	
	-- You can only click once per note (to avoid spam clicking all the colors)
	if not WaitForNextNote then

		WaitForNextNote = true
		
		local Finished, Correct = MusicRemoteFunction:InvokeServer(Color)
		
		-- If the player has finished the song
		if Finished then
			EndOfGame(Correct)		
		end
	end
end


-- PLAYER PICKED A LEVEL TO START THE GAME

local function StartLevel(PickedLevel)
	
	Level = PickedLevel
	IsPlaying = true
	
	if Level == 1 or (lplr.Music:FindFirstChild("Lock"..tostring(Level)) and not lplr.Music:FindFirstChild("Lock"..tostring(Level)).Value) then
		local SongTable = MusicRemoteFunction:InvokeServer(0, Level)
		
		if typeof(SongTable) == "table" then
			
			MusicGui.Levels.Visible = false
			MusicGui.TextLabel.Visible = false
			MusicGui.Songs.Visible = true
			MusicGui.Songs.Song.Position = UDim2.new(0,0,0.095,0)
			
			for i,v in pairs(SongTable) do
				local Note = MusicGui.Songs.Template:Clone()
				Note.Position = UDim2.new((-0.04 + 0.18 * v), 0 ,(1.5 - 1.5 * i), 0)
				Note.BackgroundColor3 = BackgroundColors[v]
				Note.BorderColor3 = BorderColors[v]
				Note.Visible = true
				Note.Parent = MusicGui.Songs.Song
			end

			-- Set the rate at which the frame goes down based on the level
			if Level == 1 then
				WaitTime = 1.5
				coroutine.resume(coroutine.create(Timer), 21)
			elseif Level == 2 then
				WaitTime = 1
				coroutine.resume(coroutine.create(Timer), 19)
			elseif Level == 3 then
				WaitTime = 0.8
				coroutine.resume(coroutine.create(Timer), 19)
			elseif Level == 4 then
				WaitTime = 0.6
				coroutine.resume(coroutine.create(Timer), 17)
			elseif Level == 5 then
				WaitTime = 0.4
				coroutine.resume(coroutine.create(Timer), 14)
			end

			for i=1,(4 + #MusicGui.Songs.Song:GetChildren()) do
				MusicGui.Songs.Song.Position += UDim2.new(0,0,0.15,0)
				WaitForNextNote = false
				wait(WaitTime)
			end
			
			WaitForNextNote = true
		end
	end
end


-- GET ALL THE SEATS EVENTS

for i,v in ipairs(Music.Seats:GetChildren()) do
	v:GetPropertyChangedSignal("Occupant"):Connect(function()
		if v.Occupant and v.Occupant.Parent and v.Occupant.Parent.Name == lplr.Name then
			if Players:GetPlayerFromCharacter(v.Occupant.Parent) then

				Level1 = MusicGui.Levels.Level1.Activated:Connect(function()
					StartLevel(1)
				end)

				Level2 = MusicGui.Levels.Level2.Activated:Connect(function()
					StartLevel(2)
				end)
				
				Level3 = MusicGui.Levels.Level3.Activated:Connect(function()
					StartLevel(3)
				end)

				Level4 = MusicGui.Levels.Level4.Activated:Connect(function()
					StartLevel(4)
				end)

				Level5 = MusicGui.Levels.Level5.Activated:Connect(function()
					StartLevel(5)
				end)

				Sit = true

				Unsit = v:GetPropertyChangedSignal("Occupant"):Connect(function()
					Sit = false
					CurrentCamera.CameraType = Enum.CameraType.Custom

					MusicGui.Levels.Visible = false
					MusicGui.TextLabel.Visible = true
					MusicGui.SitDown.Visible = true

					-- Disconnec the unsit event 
					Unsit:Disconnect()

					-- Disconnect all the click events for the levels
					Level1:Disconnect()
					Level2:Disconnect()
					Level3:Disconnect()
					Level4:Disconnect()
					Level5:Disconnect()
					
					-- Disconnect all the colors click events
					GreenClicked:Disconnect()
					PurpleClicked:Disconnect()
					RedClicked:Disconnect()
					YellowClicked:Disconnect()
					BlueClicked:Disconnect()

					Reset()
				end)
				
				GreenClicked = MusicGui.Songs.Buttons.Green.Activated:Connect(function()
					ColorClicked(1)
				end)

				PurpleClicked = MusicGui.Songs.Buttons.Purple.Activated:Connect(function()
					ColorClicked(2)
				end)

				RedClicked = MusicGui.Songs.Buttons.Red.Activated:Connect(function()
					ColorClicked(3)
				end)

				YellowClicked = MusicGui.Songs.Buttons.Yellow.Activated:Connect(function()
					ColorClicked(4)
				end)

				BlueClicked = MusicGui.Songs.Buttons.Blue.Activated:Connect(function()
					ColorClicked(5)
				end)

				CurrentCamera.CameraType = Enum.CameraType.Scriptable
				TweenMusicCamera:Play()
				wait(2)

				if Sit then
					MusicGui.SitDown.Visible = false
					MusicGui.Levels.Visible = true
				end
			end
		end
	end)
end