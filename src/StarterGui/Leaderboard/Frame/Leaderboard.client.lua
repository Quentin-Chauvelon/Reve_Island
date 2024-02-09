local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LeaderboardRemoteEvent = ReplicatedStorage:WaitForChild("Leaderboard")
local MoneyRemoteFunction = ReplicatedStorage:WaitForChild("Money")
local ExperienceRemoteEvent = ReplicatedStorage:WaitForChild("Experience")


LeaderboardRemoteEvent.OnClientEvent:Connect(function(Money, Experience, Rank, Job)
	
	script.Parent.Money.Text = "$"..Money
	script.Parent.Experience.Text = "¤"..Experience
	script.Parent.Information.Text = "You got "..Rank.." in "..Job
	script.Parent.Visible = true
	script.Parent:TweenSize(UDim2.new(0.3,0,0.5,0), nil, nil, 0.5)
	
end)


script.Parent.Claim.MouseButton1Down:Connect(function()
	LeaderboardRemoteEvent:FireServer()
	script.Parent:TweenSize(UDim2.new(0,0,0,0), nil, nil, 0.5)
	wait(0.5)
	script.Parent.Visible = false
end)