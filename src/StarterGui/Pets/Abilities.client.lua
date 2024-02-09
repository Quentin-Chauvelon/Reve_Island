local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AbilitiesRemoteFunction = ReplicatedStorage:WaitForChild("Abilities")
local PermanentAbilitiesRemoteEvent = ReplicatedStorage:WaitForChild("PermanentAbilities")

local debounce1 = false
local debounce2 = false
local lplr = game.Players.LocalPlayer
local EquippedPet = lplr:WaitForChild("PetCustomisations"):WaitForChild("EquippedPet")
local PetsGui = lplr.PlayerGui:WaitForChild("Pets")
local GravityGui = PetsGui:WaitForChild("Frame"):WaitForChild("Gravity")
local FlyGui = PetsGui:WaitForChild("Frame"):WaitForChild("Buttons"):WaitForChild("Fly")
local SetGravity, HeadHit


-- FLY (Pets : angel, aqua dragon, bee, reindeer)

local function Fly(Duration)
	
	if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") and lplr.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FlyBV") and lplr.Character:FindFirstChild("Humanoid") then
		FlyGui.Visible = true

		local FlyKeyPressed, FlyKeyReleased, FlyButtonUpTouched, FlyButtonDownTouched, FlyButtonUpReleased, FlyButtonDownReleased

		FlyKeyPressed = UserInputService.InputBegan:Connect(function(Input)
			-- Player presses E to go up and Q (A because it is qwerty) to go down
			if Input.KeyCode == Enum.KeyCode.E then
				lplr.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FlyBV").Velocity = Vector3.new(0,15,0)
			elseif Input.KeyCode == Enum.KeyCode.Q then
				lplr.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FlyBV").Velocity = Vector3.new(0,-15,0)
			end
		end)

		FlyKeyReleased = UserInputService.InputEnded:Connect(function(Input)
			if Input.KeyCode == Enum.KeyCode.E or Input.KeyCode == Enum.KeyCode.A then
				lplr.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FlyBV").Velocity = Vector3.new(0,0,0)
			end
		end)

		FlyButtonUpTouched = FlyGui.Up.MouseButton1Down:Connect(function()
			lplr.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FlyBV").Velocity = Vector3.new(0,15,0)
		end)

		FlyButtonDownTouched = FlyGui.Down.MouseButton1Down:Connect(function()
			lplr.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FlyBV").Velocity = Vector3.new(0,-15,0)
		end)

		FlyButtonUpReleased = FlyGui.Up.MouseButton1Up:Connect(function()
			lplr.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FlyBV").Velocity = Vector3.new(0,0,0)
		end)

		FlyButtonDownReleased = FlyGui.Down.MouseButton1Up:Connect(function()
			lplr.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FlyBV").Velocity = Vector3.new(0,0,0)
		end)

		wait(Duration)

		-- Reset events and hide gui
		FlyKeyPressed:Disconnect()
		FlyKeyReleased:Disconnect()
		FlyButtonUpTouched:Disconnect()
		FlyButtonDownTouched:Disconnect()
		FlyButtonUpReleased:Disconnect()
		FlyButtonDownReleased:Disconnect()
		FlyGui.Visible = false
	end
end


-- COOLDOWN

local function Cooldown(Ability, Duration)
	Ability = lplr.PlayerGui.Pets.Frame.Buttons:FindFirstChild("Ability"..Ability.."Button")
	
	if Ability then
		Ability.Cooldown.Size = UDim2.new(1,0,1,0)
		Ability.Cooldown.Visible = true
		
		local Step = -1 / (5 * Duration)
		
		for i=1,0,Step do
			Ability.Cooldown.Size = UDim2.new(1,0,i,0)
			wait(0.2)
		end
		
		Ability.Cooldown.Size = UDim2.new(1,0,0,0)
		Ability.Cooldown.Visible = false
	end
end


-- EVENT FIRED FROM THE SERVER

local function Ability(Character, Pet, Equipped)
	
	if Character and Pet and Equipped ~= nil then

		-- Set gravity (Alien ability 2)
		if Pet == "Alien" then
			
			if Equipped then
				GravityGui.Visible = true

				-- Change gravity when the player types something
				SetGravity = GravityGui.SetGravity:GetPropertyChangedSignal("Text"):Connect(function()
					GravityGui.SetGravity.Text = GravityGui.SetGravity.Text:gsub("%D+", "")

					-- If the player doesn't have his abilities disabled
					if not lplr.PetAbilitiesDisabled.Value then

						-- Apply Gravity and change player's jump height
						if tonumber(GravityGui.SetGravity.Text) and tonumber(GravityGui.SetGravity.Text) >= 1 or tonumber(GravityGui.SetGravity.Text) <= 999 then
							workspace.Gravity = tonumber(GravityGui.SetGravity.Text)

							if Character:FindFirstChild("Humanoid") then
								Character:FindFirstChild("Humanoid").JumpHeight = math.max(-0.17 * tonumber(GravityGui.SetGravity.Text) + 41.7, 7.5)
							end
						end
					end
				end)

			else
				workspace.Gravity = 196.2
				
				if Character:FindFirstChild("Humanoid") then
					Character.Humanoid.JumpHeight = 7.5
				end
				
				GravityGui.Visible = false
				GravityGui.SetGravity.Text = ""
				
				if SetGravity then
					SetGravity:Disconnect()
				end
			end

		-- Night vision (Cat ability 1, Golden cat ability 1)		
		elseif Pet == "Cat" or Pet == "GoldenCat" then

			coroutine.wrap(function()
				while EquippedPet.Value == "Cat" or EquippedPet.Value == "GoldenCat" do -- night vision loop

					if Lighting.ClockTime >= 18 or Lighting.ClockTime <= 6 then -- if it's night time
						Lighting.Ambient = Color3.fromRGB(255,255,255) -- brighter ambient light to make it feel like it's the day
					else -- if it's day time
						Lighting.Ambient = Color3.fromRGB(100,100,100) -- normal ambient light
					end

					wait(10)	
				end

				Lighting.Ambient = Color3.fromRGB(100,100,100) -- normal ambient light
			end)()
		end
	end
end


-- FIRE THE ABILITY FUNCTION TO ACTIVATE THEM ONCE IF THE PLAYER HAS THE PET EQUIPPED

Ability(lplr.Character, EquippedPet.Value, true)


-- FIRE THE ABILITY FUNCTION EACH TIME THE PLAYER EQUIPS OR UNEQUIPS A PET

PermanentAbilitiesRemoteEvent.OnClientEvent:Connect(function(Character, Pet, Equipped)
	Ability(Character, Pet, Equipped)
end)


-- ABILITY 1 BUTTON CLICK

lplr.PlayerGui.Pets.Frame.Buttons.Ability1Button.MouseButton1Click:Connect(function()
	
	if not debounce1 then
		debounce1 = true

		local CooldownTime = AbilitiesRemoteFunction:InvokeServer(1)
		
		if CooldownTime > 0 then
			
			if EquippedPet.Value == "Angel" or EquippedPet.Value == "AquaDragon" then
				coroutine.resume(coroutine.create(Fly), 15)
			end

			if EquippedPet.Value == "Bee" then
				coroutine.resume(coroutine.create(Fly), 3)
			end

			if EquippedPet.Value == "Reindeer" then
				coroutine.resume(coroutine.create(Fly), 20)
			end
			
			Cooldown(1, CooldownTime)
		end

		wait(0.1)
		debounce1 = false
	end
end)


-- ABILITY 2 BUTTON CLICK

lplr.PlayerGui.Pets.Frame.Buttons.Ability2Button.MouseButton1Click:Connect(function()
	if not debounce2 then
		debounce2 = true
			
		local CooldownTime = AbilitiesRemoteFunction:InvokeServer(2)

		if CooldownTime > 0 then
			Cooldown(2, CooldownTime)

			if EquippedPet.Value == "Star" then
				local StartPosition = Vector3.new(math.random(-1250,1250), 150, math.random(-1250,1250))
				local EndPosition = Vector3.new(math.random(-1250,1250), 150, math.random(-1250,1250))

				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				workspace.CurrentCamera.CFrame = CFrame.new(StartPosition, Vector3.new(0,-10,0))

				TweenService:Create(workspace.CurrentCamera, TweenInfo.new(15, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {CFrame = CFrame.new(EndPosition)}):Play()
				wait(15)
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			end
		end
		
		wait(0.1)
		debounce2 = false
	end
end)


-- ABILITY 1 AND 2 TEXTS UNDER THE BUTTONS

lplr.PlayerGui.Pets.Frame.Buttons.Ability1Button.MouseEnter:Connect(function()
	lplr.PlayerGui.Pets.Frame.Buttons.Ability1.Visible = true
end)

lplr.PlayerGui.Pets.Frame.Buttons.Ability1Button.MouseLeave:Connect(function()
	lplr.PlayerGui.Pets.Frame.Buttons.Ability1.Visible = false
end)

lplr.PlayerGui.Pets.Frame.Buttons.Ability2Button.MouseEnter:Connect(function()
	lplr.PlayerGui.Pets.Frame.Buttons.Ability2.Visible = true
end)

lplr.PlayerGui.Pets.Frame.Buttons.Ability2Button.MouseLeave:Connect(function()
	lplr.PlayerGui.Pets.Frame.Buttons.Ability2.Visible = false
end)