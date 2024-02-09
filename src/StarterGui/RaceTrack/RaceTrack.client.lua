local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaceTrackRemoteEvent = ReplicatedStorage:WaitForChild("RaceTrack")
local TweenService = game:GetService("TweenService")

local lplr = game.Players.LocalPlayer
local RacingGui = lplr.PlayerGui:WaitForChild("RaceTrack"):WaitForChild("Racing")
local FinishGui = RacingGui.Parent:WaitForChild("Finish")

local RaceTrack = workspace.RaceTrack


-- WHEN THE PLAYER STARTS THE RACE

RaceTrackRemoteEvent.OnClientEvent:Connect(function()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Attach
	workspace.CurrentCamera.CameraSubject =  workspace.Cars:FindFirstChild("F1"..lplr.Name).Body.FirstPersonView
	
	wait(2)
	
	TweenService:Create(RacingGui.Speedometer.Needle, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true), {Rotation = -90}):Play()
	TweenService:Create(RacingGui.Tachometer.Needle, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true), {Rotation = 90}):Play()
	
	wait(3)
end)


-- PLAYER CLICKS ON THE RESTART BUTTON ON THE RACING GUI

RacingGui.Restart.MouseButton1Down:Connect(function()
	RaceTrackRemoteEvent:FireServer("Restart")
end)


-- PLAYER CLICKS ON THE QUIT BUTTON ON THE RACING GUI

RacingGui.Quit.MouseButton1Down:Connect(function()
	RaceTrackRemoteEvent:FireServer("Quit")
end)


-- PLAYER CLICKS ON THE RESTART BUTTON ON THE FINISH GUI

FinishGui.Restart.MouseButton1Down:Connect(function()
	RaceTrackRemoteEvent:FireServer("Restart")
end)


-- PLAYER CLICKS ON THE QUIT BUTTON ON THE FINISH GUI

FinishGui.Quit.MouseButton1Down:Connect(function()
	RaceTrackRemoteEvent:FireServer("Quit")
end)


-----------------------------------------------------------------------------------------------------


local Leaderboard = workspace.RaceTrack.Leaderboard.SurfaceGui.Frame


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