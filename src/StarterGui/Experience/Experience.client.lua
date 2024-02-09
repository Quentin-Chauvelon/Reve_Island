local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ExperienceRemoteEvent = ReplicatedStorage:WaitForChild("Experience")

local lplr = game.Players.LocalPlayer
local GainExperienceGui = script.Parent:WaitForChild("Gain")
local SummaryExperienceGui = script.Parent:WaitForChild("Summary")
local SummaryOpen = script.Parent.SummaryOpen


-- REMOTE EVENT FIRED FROM THE SERVER EITHER TO LOAD THE EXPERIENCE OR TO UPDATE IT

ExperienceRemoteEvent.OnClientEvent:Connect(function(Amount, Job, JobExperience)
	
	local MaxExperience = 0
	local ExperienceLevel = 0

	if JobExperience < 100 then
		MaxExperience = 100
		ExperienceLevel = 1

	elseif JobExperience >= 100 and JobExperience < 400 then
		JobExperience = JobExperience - 100
		MaxExperience = 300
		ExperienceLevel = 2


	elseif JobExperience >= 400 and JobExperience < 1000 then
		JobExperience = JobExperience - 400
		MaxExperience = 600
		ExperienceLevel = 3

	elseif JobExperience >= 1000 and JobExperience < 2200 then
		JobExperience = JobExperience - 1000
		MaxExperience = 1200
		ExperienceLevel = 4

	elseif JobExperience >= 2200 and JobExperience < 5200 then
		JobExperience = JobExperience - 2200
		MaxExperience = 3000
		ExperienceLevel = 5

	elseif JobExperience >= 5200 and JobExperience < 11200 then
		JobExperience = JobExperience - 5200
		MaxExperience = 6000
		ExperienceLevel = 6

	elseif JobExperience >= 11200 and JobExperience < 26200 then
		JobExperience = JobExperience - 11200
		MaxExperience = 15000
		ExperienceLevel = 7

	elseif JobExperience >= 26200 and JobExperience < 56200 then
		JobExperience = JobExperience - 26200
		MaxExperience = 30000
		ExperienceLevel = 8

	elseif JobExperience >= 56200 and JobExperience < 101200 then
		JobExperience = JobExperience - 56200
		MaxExperience = 45000
		ExperienceLevel = 9

	elseif JobExperience >= 101200 and JobExperience < 161200 then
		JobExperience = JobExperience - 101200
		MaxExperience = 60000
		ExperienceLevel = 10

	elseif JobExperience >= 161200 then
		JobExperience = 60000
		MaxExperience = 60000
		ExperienceLevel = "MAX"
	end
	
	GainExperienceGui.ExperienceGained.Text = "+ "..Amount -- experience gained "+ X"

	GainExperienceGui.Experience.Text = JobExperience.." / "..MaxExperience -- total level experience "X / X"
	SummaryExperienceGui[Job].Experience.Text = tostring(JobExperience).." / "..tostring(MaxExperience)

	local XScale = JobExperience / MaxExperience -- percentage of level completion
	GainExperienceGui.Frame.ProgressBar.Size = UDim2.new(XScale,0,1,0) -- the size of the bar is the percentage of level completion
	SummaryExperienceGui[Job].Frame.ProgressBar.Size = UDim2.new(XScale,0,1,0)

	GainExperienceGui.Level.Text = "Level "..ExperienceLevel -- job level
	SummaryExperienceGui[Job].Level.Text = "Level "..ExperienceLevel


	GainExperienceGui.Visible = true
	wait(6)
	
	if not script.Parent.SummaryOpen.Value then
		GainExperienceGui.Visible = false
	end
end)


-- OPEN AND CLOSE THE SUMMARY

script.Parent.Gain.SummaryButton.MouseButton1Down:Connect(function()
	if SummaryOpen.Value == true then
		script.Parent.Summary:TweenSizeAndPosition(UDim2.new(0.2,0,0.2,0), UDim2.new(0.5,0,0.79,0), nil, nil, 0.3)
		wait(0.3)
		script.Parent.Summary.Visible = false
		SummaryOpen.Value = false
		script.Parent.Gain.Visible = false
	else
		script.Parent.Summary.Visible = true
		script.Parent.Summary:TweenSizeAndPosition(UDim2.new(0.8,0,0.7,0), UDim2.new(0.5,0,0.12,0), nil, nil, 0.2)
		wait(0.2)
		SummaryOpen.Value = true	
	end
end)


-- PLAYER CLICKS THE X2 BUTTON TO BUY THE GAME PASS

GainExperienceGui.DoubleXP.MouseButton1Down:Connect(function()

	if lplr.GamePasses.DoubleXP.Value then

		-- If the player already owns the pass, he can't buy it again
		script.Parent.DoubleXPOwned.Visible = true
		wait(6)
		script.Parent.DoubleXPOwned.Visible = false
	else
		MarketPlaceService:PromptGamePassPurchase(lplr, 42480055)
	end
end)



--script.Parent.Gain:GetPropertyChangedSignal("Visible"):Connect(function()
--	if SummaryOpen.Value then
--		script.Parent.Gain.Visible = true
--	end
--end)
