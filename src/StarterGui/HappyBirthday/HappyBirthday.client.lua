local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BirthdayRemoteEvent = ReplicatedStorage:WaitForChild("Birthday")

local lplr = game.Players.LocalPlayer


-- ON BIRTHDAY SERVER REMOTE EVENT

BirthdayRemoteEvent.OnClientEvent:Connect(function(Age, MoneyAmount, CasinoChipAmount, ExperienceJob, ExperienceAmount)
	local HappyBirthdayGui = lplr.PlayerGui:WaitForChild("HappyBirthday")
	HappyBirthdayGui.Enabled = true -- enable the happy birthday screen gui

	if Age == 3  or Age == 18 or Age == 60 then -- if the player changes team
		HappyBirthdayGui = HappyBirthdayGui:WaitForChild("WithHungSign") -- change the HappyBirthdayGui variable with the sign to change the team

		if Age == 3 then -- if the player is now a children
			HappyBirthdayGui.Team.Text = "You are now a children."
		elseif Age == 18 then -- if the player is now an adult
			HappyBirthdayGui.Team.Text = "You are now an adult."
		elseif Age == 60 then -- if the player is now retired
			HappyBirthdayGui.Team.Text = "You are now retired."
		end							
	else
		HappyBirthdayGui = HappyBirthdayGui:WaitForChild("WithoutHungSign") -- change the HappyBirthdayGui variable without the sign to change the team
	end

	HappyBirthdayGui.Age.Text = "You are "..tostring(Age).." years old!" -- change the age text label with the new age

	HappyBirthdayGui.Rewards.RewardsNames.Money.Text = "$"..tostring(MoneyAmount) -- change the money text label with the money amount
	HappyBirthdayGui.Rewards.RewardsNames.CasinoChip.Text = "+"..tostring(CasinoChipAmount) -- change the casino chip text label with the casino chip amount
	HappyBirthdayGui.Rewards.RewardsImages.Experience.Experience.TextLabel.Text = ExperienceJob -- change the job name
	HappyBirthdayGui.Rewards.RewardsNames.Experience.Text = "¤"..tostring(ExperienceAmount) -- change the experience text label with the experience amount

	HappyBirthdayGui.Visible = true -- show the happy birthday gui

	HappyBirthdayGui.Rewards.RewardsImages.Money:TweenSize(UDim2.new(1,0,1,0), nil, nil, 1) -- show the first reward and name
	HappyBirthdayGui.Rewards.RewardsNames.Money:TweenSize(UDim2.new(0.5,0,1,0), nil, nil, 1)
	wait(1)
	HappyBirthdayGui.Rewards.RewardsImages.CasinoChip:TweenSize(UDim2.new(1,0,1,0), nil, nil, 1) -- show the second reward and name
	HappyBirthdayGui.Rewards.RewardsNames.CasinoChip:TweenSize(UDim2.new(0.5,0,1,0), nil, nil, 1)
	wait(1)
	HappyBirthdayGui.Rewards.RewardsImages.Experience:TweenSize(UDim2.new(1,0,1,0), nil, nil, 1) -- show the third reward and name
	HappyBirthdayGui.Rewards.RewardsNames.Experience:TweenSize(UDim2.new(0.5,0,1,0), nil, nil, 1)
	wait(1)

	HappyBirthdayGui.Close.Visible = true

end)


-- HIDE GUI

local function CloseGui(BirthdayGui)
	local RewardsImages = BirthdayGui.Rewards.RewardsImages
	local RewardsNames = BirthdayGui.Rewards.RewardsNames

	--BirthdayGui.Rewards.Visible = false -- hide the rewards and scale them to 0 to be able to tween the size on next birthday
	RewardsImages.Money.Size = UDim2.new(0,0,0,0)
	RewardsImages.CasinoChip.Size = UDim2.new(0,0,0,0)
	RewardsImages.Experience.Size = UDim2.new(0,0,0,0)
	RewardsNames.Money.Size = UDim2.new(0,0,0,0)
	RewardsNames.CasinoChip.Size = UDim2.new(0,0,0,0)
	RewardsNames.Experience.Size = UDim2.new(0,0,0,0)

	BirthdayGui.Visible = false -- hide the happy birhtday gui
	script.Parent.Enabled = false -- disable the screen gui
end


-- ON CLOSE BUTTON CLICK

script.Parent.WithHungSign.Close.MouseButton1Down:Connect(function()
	CloseGui(script.Parent.WithHungSign)
end)

script.Parent.WithoutHungSign.Close.MouseButton1Down:Connect(function()
	CloseGui(script.Parent.WithoutHungSign)
end)


