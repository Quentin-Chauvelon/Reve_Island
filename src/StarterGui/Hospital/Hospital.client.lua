local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local MultitaskRemoteEvent = ReplicatedStorage:WaitForChild("Multitask")
local Lethal = workspace.Hospital.Interior.Lethal
local DoubleDoor = workspace.Hospital.Interior.Doors.DoubleDoor
local lplr = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HospitalGui = lplr.PlayerGui.Hospital
local Confirmation = HospitalGui.Confirmation.Frame
local WhiteFade = HospitalGui.WhiteFade

local OpenDoorDebounce = false
local debounce = false

local OpenLeftDoor = TweenService:Create(DoubleDoor.LeftDoor.PrimaryPart, TweenInfo.new(1), {CFrame = DoubleDoor.LeftDoorOpen.CFrame})
local OpenRightDoor = TweenService:Create(DoubleDoor.RightDoor.PrimaryPart, TweenInfo.new(1), {CFrame = DoubleDoor.RightDoorOpen.CFrame})
local CloseLeftDoor = TweenService:Create(DoubleDoor.LeftDoor.PrimaryPart, TweenInfo.new(1), {CFrame = DoubleDoor.LeftDoorClose.CFrame})
local CloseRightDoor = TweenService:Create(DoubleDoor.RightDoor.PrimaryPart, TweenInfo.new(1), {CFrame = DoubleDoor.RightDoorClose.CFrame})

-- PLAYER TRIGGERS THE DOORS

workspace.Hospital.Interior.DoorTrigger.Touched:Connect(function(hit)
	if not OpenDoorDebounce then

		OpenDoorDebounce = true

		-- tweens to open and close doors		
		OpenLeftDoor:Play()
		OpenRightDoor:Play()
		wait(3)

		CloseLeftDoor:Play()
		CloseRightDoor:Play()
		wait(2)

		OpenDoorDebounce = false
	end
end)


-- PLAYER TRIGGERS THE DEATH GUI

Lethal.Trigger.Touched:Connect(function(hit)

	if hit.Parent.Name == lplr.Name then
		if not debounce then
			debounce = true	


			local WalkSpeed = workspace[lplr.Name].Humanoid.WalkSpeed
			workspace[lplr.Name].Humanoid.WalkSpeed = 0
			Camera.CameraType = Enum.CameraType.Scriptable

			local TweenCamera = TweenService:Create(Camera, TweenInfo.new(1), {CFrame = Lethal.CameraPlacement.CFrame})

			TweenCamera:Play()
			wait(1)

			Confirmation.Visible = true -- show gui to confirm that they want to restart
			Confirmation:TweenSize(UDim2.new(0.5,0,0.5,0), nil, nil, 0.5)
			wait(1)

			Confirmation.Yes.MouseButton1Down:Connect(function() -- if player clicks yes
						
				Confirmation:TweenSize(UDim2.new(0,0,0,0), nil, nil, 0.5)
				wait(0.5)
				Confirmation.Visible = false

			--	WhiteFade.Visible = true -- slowly fade screen to white
			--	for i=1,-0.05,-0.05 do
			--		WhiteFade.BackgroundTransparency = i
			--		wait(0.2)
			--	end

			--	wait(3)

				MultitaskRemoteEvent:FireServer("Hospital")

			--	local hum = workspace[lplr.Name]:FindFirstChild("Humanoid") -- kill player
			--	if hum then
			--		hum.Health = 0
			--	end

			--	wait(1)
			--	Camera.CFrame = CFrame.new(0,6,0) -- put the camera to the center of the map (where player respawns), otherwise when fading gui out, player sees the hospital before respawning (and can't have a longer wait because when player respawns the script resets)

			--	for i=0,1.05,0.05 do -- slowly fade screen back to normal
			--		WhiteFade.BackgroundTransparency = i
			--		wait(0.2)
			--	end
			--	WhiteFade.Visible = false

			--	Camera.CameraType = Enum.CameraType.Custom
			--	workspace[lplr.Name].Humanoid.WalkSpeed = WalkSpeed
			--	debounce = false
			end)

			Confirmation.No.MouseButton1Down:Connect(function() -- if player clicks no
				Confirmation:TweenSize(UDim2.new(0,0,0,0), nil, nil, 0.5)
				wait(0.5)
				Confirmation.Visible = false

				wait(0.5)
				Camera.CameraType = Enum.CameraType.Custom	
				workspace[lplr.Name].HumanoidRootPart.CFrame = CFrame.new(Lethal.PlayerPlacement.Position)
				workspace[lplr.Name].Humanoid.WalkSpeed = WalkSpeed
				debounce = false
			end)
		end
	end
end)