local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DailyRewardRemoteEvent = ReplicatedStorage:WaitForChild("DailyReward")

local Shuffle = {} -- variable to save the shuffle pattern once it is fired from the server

local DailyRewardGui = script.Parent:WaitForChild("Frame")

local Comeback = DailyRewardGui:WaitForChild("Comeback"):WaitForChild("Comeback")

local RewardsImages = DailyRewardGui:WaitForChild("Rewards"):WaitForChild("RewardsImages")
RewardsImages:WaitForChild("Reward1")

local RewardsNames = DailyRewardGui.Rewards:WaitForChild("RewardsNames")
RewardsNames:WaitForChild("Name1")
RewardsNames:WaitForChild("Name2")
RewardsNames:WaitForChild("Name3")

local ButtonsRewardsImages = DailyRewardGui:WaitForChild("ButtonsRewards"):WaitForChild("RewardsImages")
local ButtonsRewardsNames = DailyRewardGui.ButtonsRewards:WaitForChild("RewardsNames")

local ShuffledRewardsImages = DailyRewardGui:WaitForChild("ShuffledRewards"):WaitForChild("RewardsImages")
local ShuffledRewardsNames = DailyRewardGui.ShuffledRewards:WaitForChild("RewardsNames")


RewardsNames.Name1.Size =  UDim2.new(0, RewardsImages.Reward1.AbsoluteSize.X, 0.6, 0) -- change the offset size of the name to the absolute size of the images (so that it is aligned with the images)
RewardsNames.Name2.Size =  UDim2.new(0, RewardsImages.Reward1.AbsoluteSize.X, 0.6, 0)
RewardsNames.Name3.Size =  UDim2.new(0, RewardsImages.Reward1.AbsoluteSize.X, 0.6, 0)

local AnimationGui = script.Parent:WaitForChild("Animation")
AnimationGui:WaitForChild("Reward1")
AnimationGui:WaitForChild("Reward2")
AnimationGui:WaitForChild("Reward3")

local PreviousRewardClicked = 0
local RewardChosen = 0
local RewardClaimed = false


-- ON DAILY REWARD REMOTE EVENT FIRE FROM SERVER

DailyRewardRemoteEvent.OnClientEvent:Connect(function(ShuffleTable)
	Shuffle = ShuffleTable -- store the shuffle pattern which was randomly chosen by the server
end)


-- WHEN PLAYER CLICKS THE CHOOSE BUTTON

DailyRewardGui.Choose.MouseButton1Down:Connect(function()
	
	Comeback.Text = "Comeback in "..tostring(24 - os.date("*t", os.time())["hour"])..":"..tostring(59 - os.date("*t", os.time())["min"])
	
	DailyRewardGui.Choose.Visible = false -- hide the choose button
	DailyRewardGui.WaitForReward.Visible = true  -- empty frame to wait for the animation to be complete and the player to choose the reward
	
	ShuffledRewardsNames.Name1.Size =  UDim2.new(0, RewardsImages.Reward1.AbsoluteSize.X, 0.6, 0) -- change the offset size of the name to the absolute size of the images (so that it is aligned with the images)
	ShuffledRewardsNames.Name2.Size =  UDim2.new(0, RewardsImages.Reward1.AbsoluteSize.X, 0.6, 0)
	ShuffledRewardsNames.Name3.Size =  UDim2.new(0, RewardsImages.Reward1.AbsoluteSize.X, 0.6, 0)
	
	RewardsImages.Visible = false -- hide the rewards images and names so that you can't see it when the animation starts
	RewardsNames.Visible = false
	
	for i,v in ipairs(AnimationGui:GetChildren()) do -- loop through the animation gui children to change the size and the position based on the player's screen size
		
		v.UIAspectRatioConstraint.AspectRatio = RewardsImages.Reward1.AbsoluteSize.X / ((RewardsImages.AbsoluteSize.Y + RewardsNames.AbsoluteSize.Y) - ((RewardsNames.AbsoluteSize.Y - RewardsNames.Name1.AbsoluteSize.Y) / 2)) -- change the ui aspect ratio by dividing the X size of the reward image size by the sum of the Y size of the rewards images and names frames (-5 so that it doesn't touch the outline)
		v.Size = UDim2.new(0, RewardsImages.Reward1.AbsoluteSize.X, 0, ((RewardsImages.AbsoluteSize.Y + RewardsNames.AbsoluteSize.Y) - ((RewardsNames.AbsoluteSize.Y - RewardsNames.Name1.AbsoluteSize.Y) / 2))) -- change the size to the X size of the reward image
		
		if v:IsA("ImageLabel") then -- image label are used for the animation so that the player can't click the squares before the animation is finished
			v.Position = UDim2.new(0, RewardsImages:FindFirstChild(v.Name).AbsolutePosition.X, 0, RewardsImages:FindFirstChild(v.Name).AbsolutePosition.Y) -- change the position to the image position
			
		elseif v:IsA("ImageButton") then -- image button are used to let the player choose one reward once the animation is finished
			v.Position = UDim2.new(0, RewardsImages:FindFirstChild("Reward"..v.Value.Value).AbsolutePosition.X, 0, RewardsImages:FindFirstChild("Reward"..v.Value.Value).AbsolutePosition.Y) -- change the position to the image position
		end
	end
	
	-- ANIMATION STARTS
	
	AnimationGui.Visible = true -- show the animation red covers
	
	wait(1.5)
	
	AnimationGui.Reward1:TweenPosition(AnimationGui.Reward2.Position) -- move them all to the center
	AnimationGui.Reward3:TweenPosition(AnimationGui.Reward2.Position)
	
	wait(2)	
	
	AnimationGui.Reward1:TweenPosition(UDim2.new(0, RewardsImages.Reward1.AbsolutePosition.X, 0, RewardsImages.Reward1.AbsolutePosition.Y)) -- move them to the side
	AnimationGui.Reward3:TweenPosition(UDim2.new(0, RewardsImages.Reward3.AbsolutePosition.X, 0, RewardsImages.Reward3.AbsolutePosition.Y))
	
	wait(1)
	
	-- ANIMATION ENDS
	
	DailyRewardGui.TextLabel.Text = "Choose one of the following reward."
	
	for i,v in ipairs(AnimationGui:GetChildren()) do -- animation is finished and thus switch between the image labels and buttons so that the player can choose a reward
		if v:IsA("ImageButton") then -- show the buttons
			v.Visible = true
		end
		
		if v:IsA("ImageLabel") then -- hide the image labels
			v.Visible = false
		end
	end
	
	--DailyRewardGui.Rewards.Visible = false -- hide the rewards (unshuffled)
end)


-- ON REWARD BUTTON CLICK

local function RewardClicked(RewardClicked, RewardValue)
	
	RewardClaimed = true -- variable used to prevent player from clicking the other rewards once he clicked one
	
	DailyRewardGui.Rewards.Visible = false -- hide the rewards (unshuffled)
	DailyRewardGui.ShuffledRewards.Visible = true -- show the shuffled rewards (not shown before because if the player resized his window, the covers (which are set with the offset) wouldn't hide the rewards anymore)
	
	DailyRewardGui.WaitForReward.Visible = false
	DailyRewardGui.Claim.Visible = true -- show the claim button
	
	RewardChosen = RewardValue -- variable used when player wants to claim his reward
	
	RewardClicked.Visible = false -- hide the cover the player clicked
	
	wait(1.5)
	
	for i,v in ipairs(AnimationGui:GetChildren()) do -- hide the two remaining covers to reveal where the rewards were
		if v:IsA("ImageLabel") and v.Name ~= "Reward"..tostring(RewardValue) then -- check if it's a image label and if the name is different to the name of the cover the player clicked
			v.Visible = false -- hide the cover
		end
	end
	
	AnimationGui.Visible = false -- hide the animation frame	
end


-- ON BUTTONS REWARDS CLICK (IF PLAYER HAS BEEN PLAYING FOR MORE THAN 7 DAYS IN A ROW)

local function ButtonsRewardsClick(RewardClicked, RewardValue)
	RewardChosen = RewardValue -- variable used when player wants to claim his reward
	
	DailyRewardGui.WaitForReward.Visible = false
	DailyRewardGui.Claim.Visible = true
	
	if PreviousRewardClicked then -- if the player has already clicked a reward
		local PreviousReward = ButtonsRewardsImages:FindFirstChild("Reward"..PreviousRewardClicked) -- find the previous reward button
		
		if PreviousReward then
			PreviousReward.ImageColor3 = ButtonsRewardsNames:FindFirstChild("Name"..PreviousRewardClicked).TextColor3 -- change the color of the outline of the previous image back to the color of the name
		end
	end
	
	PreviousRewardClicked = RewardValue
	
	RewardClicked.ImageColor3 = Color3.new(1,0,0) -- change the clicked reward outline color to red
	
end

-- WHEN PLAYER CLICKS THE BUTTONS REWARDS (IF HE HAS BEEN PLAYING FOR MORE THAN 7 DAYS IN A ROW)

for i,v in ipairs(ButtonsRewardsImages:GetChildren()) do -- loop through the buttons rewards images to get all the buttons
	if v:IsA("ImageButton") then
		v.MouseButton1Down:Connect(function() -- get all the clicks event
			ButtonsRewardsClick(v, v.Value.Value)
		end)
	end
end

-- WHEN PLAYER CLICKS THE CLAIM BUTTON

for i,v in ipairs(AnimationGui:GetChildren()) do -- loop through the animation frame to get all the buttons
	if v:IsA("ImageButton") then
		v.MouseButton1Down:Connect(function() -- get all the clicks event
			if not RewardClaimed then -- if player hasn't claimed his reward yet
				RewardClicked(v, v.Value.Value)
			end
		end)
	end
end


-- ON CLAIM BUTTON CLICK

DailyRewardGui.Claim.MouseButton1Down:Connect(function()
	if RewardChosen and RewardChosen >= 1 and RewardChosen <= 3 then -- check if the reward chosen is not nil and if it's between 1 and 3
		DailyRewardRemoteEvent:FireServer(RewardChosen) -- fire the server with the number corresponding to the reward the player clicked
	end
end)

-- car : 7341103798
-- aspect ratio : 2.103 or 0.475