local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SwimmingRemoteEvent = ReplicatedStorage:WaitForChild("Swimming")

local lplr = game.Players.LocalPlayer
local SwimmingGui = script.Parent
local Swimming = workspace.School.SwimmingPool
local Score = 0

local YesButtonClicked, NoButtonClicked


-- RESET GUIS, EVENTS...

local function Reset()
	SwimmingGui.Timer.Visible = false
	SwimmingGui.Frame.Visible = false

	if YesButtonClicked and NoButtonClicked then
		YesButtonClicked:Disconnect()
		NoButtonClicked:Disconnect()
		YesButtonClicked = nil
		NoButtonClicked = nil
	end

	if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
		lplr.Character:FindFirstChild("HumanoidRootPart").CFrame = Swimming.PlayerPlacementOut.CFrame
	end
end


-- END THE GAME

local function EndOfGame()
	SwimmingGui.Instructions.Visible = false

	for i,v in ipairs(Swimming.Rings:GetChildren()) do
		v.BrickColor = BrickColor.new("Really red")
	end

	Swimming.Rings.Ring1.BrickColor = BrickColor.new("Neon orange")

	wait(3)
	if SwimmingGui.IsPlaying.Value then
		SwimmingRemoteEvent:FireServer()
	end
	wait(3)

	SwimmingGui.Completed.Visible = false
	SwimmingGui.Fail.Visible = false	
end


-- REMOTE EVENT FIRED FROM THE SERVER (WHEN THE PLAYER TOUCHES A RING)

SwimmingRemoteEvent.OnClientEvent:Connect(function(Ring)

	Score = Ring

	if Ring then
		-- Turn the ring the player just went through green
		if Swimming.Rings:FindFirstChild("Ring"..tostring(Ring)) then
			Swimming.Rings["Ring"..Ring].BrickColor = BrickColor.new("Bright green") 
		end

		-- Turn the next ring orange
		if Swimming.Rings:FindFirstChild("Ring"..tostring(Ring + 1)) then
			Swimming.Rings["Ring"..(Ring + 1)].BrickColor = BrickColor.new("Neon orange") 
		end
	end
end)


-- PLAYER STARTS THE GAME (BY TOUCHING THE TRIGGER)

local function Start()

	-- Get confirmation that the player wants to play the level
	SwimmingGui.Frame.Visible = true

	if not YesButtonClicked and not NoButtonClicked then
		YesButtonClicked = SwimmingGui.Frame.YesButton.MouseButton1Down:Connect(function()

			SwimmingGui.Frame.Visible = false
			SwimmingGui.Instructions.Visible = true

			if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
				lplr.Character.HumanoidRootPart.CFrame = Swimming.PlayerPlacement.CFrame

				SwimmingGui.Countdown.Visible = true

				-- Countdown
				for i=3,1,-1 do
					SwimmingGui.Countdown.Text = tostring(i)
					wait(0.5)
				end

				SwimmingGui.Countdown.Text = "Go!"
				wait(1)
				SwimmingGui.Countdown.Visible = false
				SwimmingGui.Timer.Visible = true

				SwimmingRemoteEvent:FireServer()

				coroutine.wrap(function()
					for i=30,0,-1 do
						SwimmingGui.Timer.Text = tostring(i)
						wait(1)
					end

					if Score == 16 then
						SwimmingGui.Completed.Visible = true
					else
						SwimmingGui.Fail.Visible =  true			
					end

					Reset()
					EndOfGame()
				end)()
			end
		end)

		-- Player clicks no (doesn't want to play the swimming game)
		NoButtonClicked = SwimmingGui.Frame.NoButton.MouseButton1Down:Connect(function()
			Reset()
		end)
	end
end


-- PLAYER TOUCHES THE TRIGGER TO START THE GAME

Swimming.Trigger.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" and hit.Parent.Name == lplr.Name and Players:FindFirstChild(hit.Parent.Name) then

		if not Players[hit.Parent.Name].Sport.Lock3.Value then
			if not SwimmingGui.IsPlaying.Value then -- if the player touches the trigger while he hasn't even finished the previous game
				Start()			
			end
		else
			SwimmingGui.SwimmingLock.Visible = true
			wait(6)
			SwimmingGui.SwimmingLock.Visible = false
		end
	end
end)