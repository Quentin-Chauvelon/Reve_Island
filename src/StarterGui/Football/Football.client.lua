local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FootballRemoteEvent = ReplicatedStorage:WaitForChild("Football")

local lplr = game.Players.LocalPlayer
local FootballGui = script.Parent
local Football = workspace.School.Football
local TimeOut = false
local Score = 0

local YesButtonClicked, NoButtonClicked


-- RESET GUIS, EVENTS...

local function Reset()
	FootballGui.Frame.Visible = false
	FootballGui.Timer.Visible = false
	FootballGui.Instructions.Visible = false
	
	if YesButtonClicked and NoButtonClicked then
		YesButtonClicked:Disconnect()
		NoButtonClicked:Disconnect()
		YesButtonClicked = nil
		NoButtonClicked = nil
	end

	if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
		lplr.Character:FindFirstChild("HumanoidRootPart").CFrame = Football.PlayerPlacementOut.CFrame
	end
end


-- END OF GAME

local function EndOfGame()
	FootballRemoteEvent:FireServer("Stop")
	wait(6)
	FootballGui.Completed.Visible = false
	FootballGui.Fail.Visible = false
end


-- PLAYER STARTS THE GAME (BY TOUCHING THE TRIGGER)

FootballRemoteEvent.OnClientEvent:Connect(function(Type, Goals)

	if Type == "Start" then

		-- If someone is already playing, tell the player to wait
		if Football.IsSomeonePlaying.Value then
			FootballGui.SomeoneAlreadyPlaying.Visible = true
			wait(6)
			FootballGui.SomeoneAlreadyPlaying.Visible = false

		else
			if lplr.Sport.Lock4.Value then
				FootballGui.FootballLock.Visible = true
				wait(6)
				FootballGui.FootballLock.Visible = false

			else
				-- Get confirmation that the player wants to play the level
				FootballGui.Frame.Visible = true

				if not YesButtonClicked and not NoButtonClicked then
					YesButtonClicked = FootballGui.Frame.YesButton.MouseButton1Down:Connect(function()

						YesButtonClicked:Disconnect()
						NoButtonClicked:Disconnect()

						FootballGui.Frame.Visible = false
						FootballGui.Instructions.Visible = true

						FootballRemoteEvent:FireServer("Start")

						if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
							lplr.Character.HumanoidRootPart.CFrame = Football.PlayerPlacement.CFrame

							FootballGui.Countdown.Visible = true

							-- Countdown
							for i=3,1,-1 do
								FootballGui.Countdown.Text = tostring(i)
								wait(0.5)
							end

							FootballGui.Countdown.Text = "Go!"
							wait(1)
							FootballGui.Countdown.Visible = false
							FootballGui.Timer.Visible = true

							coroutine.wrap(function()
								for i=35,0,-1 do
									FootballGui.Timer.Text = tostring(i)
									wait(1)

									if TimeOut then
										break
									end
								end

								TimeOut = false

								if Score == 4 then
									FootballGui.Completed.Visible = true
								else
									FootballGui.Fail.Visible =  true	
								end

								Reset()
								EndOfGame()
							end)()
						end
					end)

					-- Player clicks no (doesn't want to play the Football game)
					NoButtonClicked = FootballGui.Frame.NoButton.MouseButton1Down:Connect(function()
						Reset()
					end)
				end
			end
		end

	elseif Type == "End" then
		TimeOut = true
		Score = Goals
	end
end)