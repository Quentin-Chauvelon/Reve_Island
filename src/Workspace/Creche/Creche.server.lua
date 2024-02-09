local TweenService = game:GetService("TweenService")

local SlidingDoor = workspace.Creche.SlidingDoor
local door1 = SlidingDoor:WaitForChild("Door1")
local outline = SlidingDoor:WaitForChild("Outline")

local tweeningInformation = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local tween1open = TweenService:Create(door1,tweeningInformation,{CFrame = SlidingDoor.DoorOpen.CFrame})
local tween1close = TweenService:Create(door1,tweeningInformation,{CFrame = SlidingDoor.DoorClose.CFrame})
local tween2open = TweenService:Create(outline,tweeningInformation,{CFrame = SlidingDoor.OutlineOpen.CFrame})
local tween2close = TweenService:Create(outline,tweeningInformation,{CFrame = SlidingDoor.OutlineClose.CFrame})

local StartCreche

StartCreche = workspace.Creche.Start.Touched:Connect(function()
	StartCreche:Disconnect()

	for i,v in ipairs(workspace.Creche.Balls.Balls:GetChildren()) do
		v.Anchored = false
	end

	workspace.Creche.SlidingDoor.Detector1.Touched:Connect(function(hit)
		if hit.Parent:IsA("Model") and hit.Parent:FindFirstChild("Humanoid") then
			tween1open:Play()
			tween2open:Play()
			wait(2)
			tween1close:Play()
			tween2close:Play()
		end
	end)

	workspace.Creche.SlidingDoor.Detector2.Touched:Connect(function(hit)
		if hit.Parent:IsA("Model") and hit.Parent:FindFirstChild("Humanoid") then
			tween1open:Play()
			tween2open:Play()
			wait(2)
			tween1close:Play()
			tween2close:Play()
		end
	end)


	coroutine.wrap(function()
		local Color = workspace.Creche.Color.Colors.Color

		while wait(1) do
			local RandomNumber = math.random(1,4)

			if RandomNumber == 1 then
				Color.BrickColor = BrickColor.new("Lapis")
			elseif RandomNumber == 2 then
				Color.BrickColor = BrickColor.new("Forest green")
			elseif RandomNumber == 3 then
				Color.BrickColor = BrickColor.new("Really red")
			elseif RandomNumber == 4 then
				Color.BrickColor = BrickColor.new("New Yeller")
			end
		end
	end)()
end)