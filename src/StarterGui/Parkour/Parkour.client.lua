local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ParkourRemoteEvent = ReplicatedStorage:WaitForChild("Parkour")

local lplr = game.Players.LocalPlayer
local ParkourGui = script.Parent
local Parkour = workspace.School.Parkour

local YesButtonClicked, NoButtonClicked


-- RESET 

local function Reset()
	if YesButtonClicked and NoButtonClicked then
		YesButtonClicked:Disconnect()
		NoButtonClicked:Disconnect()
		YesButtonClicked = nil
		NoButtonClicked = nil
	end
end


-- PLAYER STARTS THE GAME (BY TOUCHING THE TRIGGER)

ParkourRemoteEvent.OnClientEvent:Connect(function(Type, Goals)

	if Type == "Start" then

		if lplr.Sport.Lock4.Value then
			ParkourGui.ParkourLock.Visible = true
			wait(6)
			ParkourGui.ParkourLock.Visible = false

		else
			-- Get confirmation that the player wants to play the level
			ParkourGui.Frame.Visible = true

			if not YesButtonClicked and not NoButtonClicked then
				YesButtonClicked = ParkourGui.Frame.YesButton.MouseButton1Down:Connect(function()
					Reset()

					ParkourGui.Frame.Visible = false

					ParkourRemoteEvent:FireServer("Start")

					if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
						lplr.Character.HumanoidRootPart.CFrame = Parkour.PlayerPlacement.CFrame
					end
				end)

				-- Player clicks no (doesn't want to play the parkour game)
				NoButtonClicked = ParkourGui.Frame.NoButton.MouseButton1Down:Connect(function()
					ParkourGui.Frame.Visible = false
					Reset()

					if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
						lplr.Character.HumanoidRootPart.CFrame = Parkour.PlayerPlacementOut.CFrame
					end
				end)
			end
		end
		
	-- If the player completed the parkour
	elseif Type == "End" then
		ParkourGui.Completed.Visible = true
		wait(6)
		ParkourGui.Completed.Visible = false
	end
end)