local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VillaRemoteEvent = ReplicatedStorage:WaitForChild("Villa")

local lplr = game.Players.LocalPlayer
local VillaGui = script.Parent
local Choice = VillaGui.RobberText.Choice
local RobberTextLabel = VillaGui.RobberText.Robber.Frame.TextLabel

local Villa = workspace.Villa
local FallingTiles = Villa.Basement.FallingTiles
local Vault = Villa.Basement.Vault
local Step = 0
local FirstRob = false
local YesClickedOnce = false
local debounce = false
local WalkSpeed = 20
local CodeTrigger, AlarmTrigger, VaultTrigger


-- TYPE WRITTER EFFECT

local function TypeWrite(TextLabel, Text)
	TextLabel.Text = ""
	VillaGui.RobberText.ImageLabel:TweenSize(UDim2.new(0.1,0,0.179,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.3) -- animate the image to make it bigger
	wait(0.3)
	VillaGui.RobberText.Robber.Frame.Size = UDim2.new(0,0,1,0) -- change the size of textbox (had to make it small 0,0,0,0 before, otherwise you could have seen it before the robber image)
	VillaGui.RobberText.Robber.Frame:TweenSize(UDim2.new(1,0,1,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5) -- animate the box to make it bigger
	wait(0.5)

	TextLabel.Text = Text
	for i=1,#Text do -- for every character of the text
		TextLabel.MaxVisibleGraphemes = i -- add characters one by one
		RunService.Heartbeat:Wait() --  wait for 1/60th of a second (depends of the fps)
	end
	TextLabel.MaxVisibleGraphemes = -1
end


-- HIDE ROBBER TEXT ANIMATION

local function HideRobberText()
	VillaGui.RobberText.Robber.Frame:TweenSize(UDim2.new(0,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.5) -- animate the box to make it smaller
	wait(0.5)
	VillaGui.RobberText.Robber.Frame.Size = UDim2.new(0,0,0,0) -- have to make it in two steps to have a better animation
	VillaGui.RobberText.ImageLabel:TweenSize(UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.3) -- animating the robber image to make it smaller
end


-- EVENT FIRED FROM THE SERVER

VillaRemoteEvent.OnClientEvent:Connect(function(Type, Activator)

	if Type == "Start" then

		if Step == 0 then
			if not debounce then
				debounce = true

				TypeWrite(RobberTextLabel, "Hello there, I know the people living here keep a lot of money in their basement. Would you like to help me rob them ?")
				Choice.Visible = true

				if not FirstRob then
					FirstRob = true

					-- Yes/No hover animations
					Choice.Yes.MouseEnter:Connect(function() -- animate the yes button when player's mouse enter
						Choice.Yes:TweenPosition(UDim2.new(0.13,0,0.2,0), nil, nil, 0.15)
					end)

					Choice.Yes.MouseLeave:Connect(function() -- animate the yes button when player's mouse leave
						Choice.Yes:TweenPosition(UDim2.new(0.03,0,0.2,0), nil, nil, 0.15)
					end)

					Choice.No.MouseEnter:Connect(function() -- same for the no button
						Choice.No:TweenPosition(UDim2.new(0.1,0,0.5,0), nil, nil, 0.15)
					end)

					Choice.No.MouseLeave:Connect(function() -- same for the no button
						Choice.No:TweenPosition(UDim2.new(0,0,0.5,0), nil, nil, 0.15)
					end)

					-- Player clicks yes and wants to rob the house
					Choice.Yes.MouseButton1Down:Connect(function()
						Choice.Visible = false

						if Step == 0 then
							Step = 1

							-- Generate code
							local Code = math.random(1,9)..math.random(1,9)..math.random(1,9)..math.random(1,9)
							VillaGui.Code.CodeValue.Value = Code

							RobberTextLabel.Text = ""
							TypeWrite(RobberTextLabel, "Perfect! First, you need to open the portal. The code is "..tostring(Code)..". You only have 1 attempt.")

							VillaGui.RobberText.Ok.Visible = true

							if not YesClickedOnce then
								YesClickedOnce = true
								
								VillaGui.RobberText.Ok.MouseEnter:Connect(function() -- same for the ok button
									VillaGui.RobberText.Ok:TweenPosition(UDim2.new(0.52,0,0.45,0), nil, nil, 0.15)
								end)

								VillaGui.RobberText.Ok.MouseLeave:Connect(function() -- same for the ok button
									VillaGui.RobberText.Ok:TweenPosition(UDim2.new(0.5,0,0.45,0), nil, nil, 0.15)
								end)
								
								VillaGui.RobberText.Ok.MouseButton1Down:Connect(function()
									VillaGui.RobberText.Ok.Visible = false
									RobberTextLabel.Text = "" -- remove the text before animating the box

									HideRobberText()
									wait(0.3)
									debounce = false

									if Step == 1 then
										Step = 2


										-- CODE TO OPEN THE PORTAL

										CodeTrigger = Villa.CodeTrigger.Touched:Connect(function(hit)
											if hit.Parent:FindFirstChild("Humanoid") and Players:FindFirstChild(hit.Parent.Name) and hit.Parent.Name == lplr.Name then

												if Step == 2 then
													CodeTrigger:Disconnect()
													VillaGui.Code.Visible = true

													WalkSpeed = hit.Parent.Humanoid.WalkSpeed
													hit.Parent.Humanoid.WalkSpeed = 0												

													-- Clone the buttons so that when the player is done typing the code, we can delete the buttons and their clicked events
													local ButtonsClone = VillaGui.Code.Frame.ButtonsTemplate:Clone()
													ButtonsClone.Name = "Buttons"
													ButtonsClone.Visible = true

													for i,v in ipairs(ButtonsClone:GetChildren()) do
														if v:IsA("TextButton") then
															v.MouseButton1Down:Connect(function()

																VillaGui.Code.Frame.CodeText.TextLabel.Text = VillaGui.Code.Frame.CodeText.TextLabel.Text..v.Text

																-- If the player typed a 4 digit code
																if string.len(VillaGui.Code.Frame.CodeText.TextLabel.Text) >= 4 then

																	ButtonsClone:Destroy()
																	VillaGui.Code.Frame.ButtonsTemplate.Visible = true

																	-- If the code is right
																	if tonumber(VillaGui.Code.Frame.CodeText.TextLabel.Text) == VillaGui.Code.CodeValue.Value then

																		VillaGui.Code.Frame.CodeText.TextLabel.TextColor3 = Color3.fromRGB(0, 255, 29)
																		wait(1.5)
																		Step = 3

																		-- Open the portal
																		Villa.Portal.Portal1:SetPrimaryPartCFrame(Villa.Portal.Portal1Open.CFrame)
																		Villa.Portal.Portal2:SetPrimaryPartCFrame(Villa.Portal.Portal2Open.CFrame)


																		-- DEACTIVATE ALARM

																		AlarmTrigger = Villa.AlarmTrigger.Touched:Connect(function(hit)
																			if hit.Parent:FindFirstChild("Humanoid") and Players:FindFirstChild(hit.Parent.Name) and hit.Parent.Name == lplr.Name then

																				if Step == 3 then
																					AlarmTrigger:Disconnect()

																					WalkSpeed = hit.Parent.Humanoid.WalkSpeed
																					hit.Parent.Humanoid.WalkSpeed = 0

																					-- START THE ALARM

																					Villa.Alarm.PointLight.Enabled = true
																					TypeWrite(RobberTextLabel, "Be careful! There is an alarm. Don't set it off! You have 2 seconds to deactivate it by cutting the red wire.")
																					VillaGui.RobberText.Ok.Visible = true
																				end
																			end
																		end)


																		-- If the code is wrong
																	else
																		-- code bakground blinking red/black
																		VillaGui.Code.Frame.CodeText.BackgroundColor3 = Color3.new(1,0,0) -- change the background color to red and black back and forth
																		wait(0.2)
																		VillaGui.Code.Frame.CodeText.BackgroundColor3 = Color3.fromRGB(63,63,63)
																		wait(0.2)
																		VillaGui.Code.Frame.CodeText.BackgroundColor3 = Color3.new(1,0,0)
																		wait(0.2)
																		VillaGui.Code.Frame.CodeText.BackgroundColor3 = Color3.fromRGB(63,63,63)
																		wait(0.2)
																		VillaGui.Code.Frame.CodeText.BackgroundColor3 = Color3.new(1,0,0)
																		wait(0.2)
																		VillaGui.Code.Frame.CodeText.BackgroundColor3 = Color3.fromRGB(63,63,63)
																		wait(0.2)

																		Step = 0
																		hit.Parent.HumanoidRootPart.CFrame = workspace.Spawn.Spawns.SpawnLocation.CFrame
																	end

																	hit.Parent.Humanoid.WalkSpeed = WalkSpeed
																	VillaGui.Code.Visible = false
																	VillaGui.Code.Frame.ButtonsTemplate.Visible = false
																	VillaGui.Code.Frame.CodeText.TextLabel.Text = ""
																	VillaGui.Code.Frame.CodeText.TextLabel.TextColor3 = Color3.new(1,0,0)
																end
															end)
														end
													end

													ButtonsClone.Parent = VillaGui.Code.Frame
												end
											end
										end)


										-- DEACTIVATE ALARM

									elseif Step == 3 then
										local AlarmTimerOver = false
										local RedWireCut = false

										VillaGui.Alarm.Visible = true

										-- Create 4 random wires																				
										-- Create the tables for the wires connections
										local StartTable, EndTable = {1,2,3,4}, {1,2,3,4}

										for i=1,4 do
											-- Get a random start and a random end for each wire
											local RandomStart, RandomEnd = math.random(1, #StartTable), math.random(1, #EndTable)
											local Start, End = StartTable[RandomStart], EndTable[RandomEnd]

											-- Remove them from the table so that they can only be picked once
											table.remove(StartTable, RandomStart)
											table.remove(EndTable, RandomEnd)

											-- Clone the wire
											if VillaGui.Alarm.Frame.Wires:FindFirstChild("S"..tostring(Start).."E"..tostring(End)) then
												local Wire = VillaGui.Alarm.Frame.Wires["S"..tostring(Start).."E"..tostring(End)]:Clone()

												-- Change the color of the wire
												if i == 1 then
													Wire.BackgroundColor3 = Color3.new(1,0,0)
												elseif i == 2 then
													Wire.BackgroundColor3 = Color3.new(1,1,0)
												elseif i == 3 then
													Wire.BackgroundColor3 = Color3.new(0,1,0)
												elseif i == 4 then
													Wire.BackgroundColor3 = Color3.new(0,0,1)
												end

												Wire.Visible = true

												-- Get the wire click events
												Wire.MouseButton1Down:Connect(function()

													-- If the clicked wire is the red one
													if Wire.BackgroundColor3 == Color3.new(1,0,0) and not AlarmTimerOver then
														RedWireCut = true
														VillaGui.Alarm.Visible = false
														Step = 4

														TypeWrite(RobberTextLabel, "Great! The money is in the basement. Unfortunately, the trapdoor is locked. Try and find the card that will let you open it.")
														VillaGui.RobberText.Ok.Visible = true

													else
														Step = 0

														-- Teleport player
														if workspace:FindFirstChild(lplr.Name) then
															workspace[lplr.Name].HumanoidRootPart.CFrame = workspace.Spawn.Spawns.SpawnLocation.CFrame
														end

														-- Close the portal
														Villa.Portal.Portal1:SetPrimaryPartCFrame(Villa.Portal.Portal1Close.CFrame)
														Villa.Portal.Portal2:SetPrimaryPartCFrame(Villa.Portal.Portal2Close.CFrame)
													end

													-- Reset walkspeed
													if workspace:FindFirstChild(lplr.Name) then
														workspace[lplr.Name].Humanoid.WalkSpeed = WalkSpeed
													end

													AlarmTimerOver = false
													VillaGui.Alarm.Visible = false
													VillaGui.Alarm.Frame.SelectedWires:ClearAllChildren()
												end)

												Wire.Parent = VillaGui.Alarm.Frame.SelectedWires
											end
										end

										-- Timer
										local StartTime = tick()
										coroutine.wrap(function()
											while tick() - StartTime < 2 do
												VillaGui.Alarm.Frame.Time.TextLabel.Text = string.sub(tostring(2 - (tick() - StartTime)) or "", 1, 3)
												RunService.Heartbeat:Wait()
											end

											AlarmTimerOver = true
											Villa.Alarm.PointLight.Enabled = false

											-- If the player hasn't cut the red wire
											if not RedWireCut then
												RedWireCut = false
												Step = 0

												-- Teleport player
												if workspace:FindFirstChild(lplr.Name) then
													workspace[lplr.Name].HumanoidRootPart.CFrame = workspace.Spawn.Spawns.SpawnLocation.CFrame
												end

												-- Close the portal
												Villa.Portal.Portal1:SetPrimaryPartCFrame(Villa.Portal.Portal1Close.CFrame)
												Villa.Portal.Portal2:SetPrimaryPartCFrame(Villa.Portal.Portal2Close.CFrame)

												-- Reset walkspeed
												if workspace:FindFirstChild(lplr.Name) then
													workspace[lplr.Name].Humanoid.WalkSpeed = WalkSpeed
												end

												VillaGui.Alarm.Visible = false
												VillaGui.Alarm.Frame.SelectedWires:ClearAllChildren()
											end
										end)()

										-- If the player has cut the red wire
									elseif Step == 4 then
										VillaRemoteEvent:FireServer("Card")
									end
								end)
							end

							-- If the player is already playing and wants to stop the robbery
						else
							Step = 0
							Villa.Portal.Portal1:SetPrimaryPartCFrame(Villa.Portal.Portal1Close.CFrame)
							Villa.Portal.Portal2:SetPrimaryPartCFrame(Villa.Portal.Portal2Close.CFrame)
							Villa.Trapdoor.Trapdoor.CFrame = Villa.Trapdoor.TrapdoorClose.CFrame

							RobberTextLabel.Text = ""
							HideRobberText()

							-- Teleport the player out of the house
							if workspace:FindFirstChild(lplr.Name) then
								workspace[lplr.Name].HumanoidRootPart.CFrame = Villa.TeleportOut.CFrame
							end

							debounce = false
						end
					end)

					-- Player clicks no and doesn't want to rob the house
					Choice.No.MouseButton1Down:Connect(function()
						Choice.Visible = false

						if Step == 0 then
							-- Teleport the player out of the house
							if workspace:FindFirstChild(lplr.Name) then
								workspace[lplr.Name].HumanoidRootPart.CFrame = Villa.TeleportOut.CFrame
							end

							TypeWrite(RobberTextLabel, "Come back later if you want to be rich!")
							wait(5)
							RobberTextLabel.Text = "" -- remove the text before animating the box
						end

						-- If the player is already playing and clicks, it means he wants to keep playing and so only hide the gui
						HideRobberText()

						debounce = false -- allow for the trigger function to fire again
					end)
				end 				
			end

			-- Player touched the triggers while already doing the robbery
		else

			if not debounce then
				debounce = true
				TypeWrite(RobberTextLabel, "Are you sure you want to leave the robbery ?") -- fire the function to type the text
				Choice.Visible = true
			end
		end


	elseif Type == "Card" then

		if workspace:FindFirstChild(lplr.Name) then

			WalkSpeed = workspace[lplr.Name].Humanoid.WalkSpeed
			workspace[lplr.Name].Humanoid.WalkSpeed = 0

			Villa.TrapdoorLock.ClickPart.BrickColor = BrickColor.new("Bright green")
			TweenService:Create(Villa.Trapdoor.Trapdoor, TweenInfo.new(3), {CFrame = Villa.Trapdoor.TrapdoorOpen.CFrame}):Play()

			-- Animation to teleport player into the basement
			wait(3)
			VillaGui.WhiteScreen.Visible = true
			VillaGui.WhiteScreen:TweenSize(UDim2.new(1.5,0,1.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 1)			
			wait(1.5)
			workspace[lplr.Name].HumanoidRootPart.CFrame = Villa.PlayerPlacement.CFrame -- teleport the player
			Villa.Trapdoor.Trapdoor.CFrame = Villa.Trapdoor.TrapdoorClose.CFrame -- close the trapdoor
			wait(1.5)
			VillaGui.WhiteScreen:TweenSize(UDim2.new(0,0,0,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 1)
			wait(1)
			VillaGui.WhiteScreen.Visible = false

			workspace[lplr.Name].Humanoid.WalkSpeed = WalkSpeed
			
			-- Reset all activators color
			for i,v in ipairs(FallingTiles.Activators:GetChildren()) do
				if v:IsA("Model") then
					v.Activator.BrickColor = BrickColor.new("Really red")
				end
			end
		end

		Step = 0

		-- Close the portal
		Villa.Portal.Portal1:SetPrimaryPartCFrame(Villa.Portal.Portal1Close.CFrame)
		Villa.Portal.Portal2:SetPrimaryPartCFrame(Villa.Portal.Portal2Close.CFrame)
		
		
	elseif Type == "Activator" then
		if FallingTiles.Activators:FindFirstChild("Activator"..tostring(Activator)) then
			FallingTiles.Activators["Activator"..tostring(Activator)].Activator.BrickColor = BrickColor.new("Bright green")
		end
		
		
	elseif Type == "Vault" then
		TweenService:Create(FallingTiles.Door, TweenInfo.new(4), {Position = FallingTiles.DoorDownPlacement.Position}):Play()
		
		-- When the player touches the vault trigger, close the door and disconnect the event
		VaultTrigger = Villa.VaultTrigger.Touched:Connect(function(hit)
			if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) and hit.Parent.Name == lplr.Name then
				
				VaultTrigger:Disconnect()
				TweenService:Create(FallingTiles.Door, TweenInfo.new(4), {Position = FallingTiles.DoorPlacement.Position}):Play()
				
				-- Open the vault door
				TweenService:Create(Vault.VaultDoor.PrimaryPart, TweenInfo.new(3, Enum.EasingStyle.Quad), {CFrame = Vault.OpenVault.CFrame}):Play()
				wait(5)
				
				-- Open all the gold blinds
				TweenService:Create(Vault.Blind1, TweenInfo.new(5), {Position =  Vault.Blind1Open.Position}):Play()
				TweenService:Create(Vault.Blind2, TweenInfo.new(5), {Position =  Vault.Blind2Open.Position}):Play()
				TweenService:Create(Vault.Blind3, TweenInfo.new(5), {Position =  Vault.Blind3Open.Position}):Play()
				
				Vault.MoneyDisplay.SurfaceGui.TextLabel.TextColor3 = Color3.new(0,1,0)

				wait(1)

				for i=1,526 do
					Vault.MoneyDisplay.SurfaceGui.TextLabel.Text = "$"..tostring(10000 - 19*i)
					RunService.Heartbeat:Wait()
				end

				Vault.MoneyDisplay.SurfaceGui.TextLabel.Text = "$0"
				Vault.MoneyDisplay.SurfaceGui.TextLabel.TextColor3 = Color3.new(1,0,0)
				
				wait(5)
				
				VillaRemoteEvent:FireServer("Vault")
				
				Vault.MoneyDisplay.SurfaceGui.TextLabel.Text = "$10000"
				Vault.VaultDoor.PrimaryPart.CFrame = Vault.CloseVault.CFrame
				Vault.Blind1.Position = Vault.Blind1Close.Position
				Vault.Blind2.Position = Vault.Blind2Close.Position
				Vault.Blind3.Position = Vault.Blind3Close.Position
			end
		end)
	end
end)