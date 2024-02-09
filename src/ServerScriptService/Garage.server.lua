local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local SkateBoard = ServerStorage.Cars:WaitForChild("SkateBoard")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GarageRemoteEvent = ReplicatedStorage:WaitForChild("Garage")

local Garage = workspace.Garage
local Cars = workspace.Cars

local PlayerDebounce = {} -- table used to wait before allowing the player to use the garage again (cooldown otherwise when the player leaves the garage, he touches the trigger which closes the garage again before the player can even leave)
local PlayerDebounceTime = 6 -- cooldown time before the player can enter the garage again

local debounce = false


-- SPAWN A SKATEBOARD FOR THE PLAYER

local function SpawnSkateBoard(plr)
	
	if workspace:FindFirstChild(plr.Name) and workspace[plr.Name]:FindFirstChild("HumanoidRootPart") then
		local SkateBoardClone = SkateBoard:Clone()
		SkateBoardClone.Name = plr.Name
		SkateBoardClone:SetPrimaryPartCFrame(CFrame.new(workspace:FindFirstChild(plr.Name):FindFirstChild("HumanoidRootPart").Position + Vector3.new(8,5,0)))
		SkateBoardClone.Parent = Cars
	end
end



-- FUNCTION TO CLOSE THE GARAGE DOOR

local function CloseGarage(hit, GarageValue)

	if script:FindFirstChild("Garage"..GarageValue.."Open").Value == true then -- if the garage is free (used to avoid unnecessary triggering when player is moving inside the garage)

		local plr = hit.Parent.Parent.Name -- get the player from the name of the car

		if Players:FindFirstChild(plr) then -- if the player is found

			if not table.find(PlayerDebounce, plr) then -- if the player is not in cooldown (have left the garage for more than 6 seconds)

				script:FindFirstChild("Garage"..GarageValue).Value = plr -- value used to know which player is in which garage (used to later to find the garage the player is in)

				--Players:FindFirstChild(plr).PlayerGui.Garage.Enabled = true -- enable the garage screen gui

				Garage:FindFirstChild("Door"..GarageValue.."Close").CanCollide = true -- make the door close part collideable so that the player can't trigger the door and leave before it closes

				local OpenDoor = TweenService:Create(Garage:FindFirstChild("GarageDoor"..GarageValue).PrimaryPart, TweenInfo.new(2.5), {CFrame = Garage:FindFirstChild("Door"..GarageValue.."Close").CFrame}) -- tween to open the garage door
				OpenDoor:Play() -- play the tween

				script:FindFirstChild("Garage"..GarageValue.."Open").Value = false -- change the garage open value to false

				GarageRemoteEvent:FireClient(Players:FindFirstChild(plr))
			end
		end
	end
end


-- GARAGE TRIGGERS TO CLOSE THE DOORS

Garage.Door1CloseTrigger.Touched:Connect(function(hit) -- garage 1
	if not debounce then
		debounce = true

		if hit.Parent.Parent.Parent:IsA("Folder") and hit.Parent.Parent.Parent.Name == "Cars" then -- the part that is expected to touch is the big part that is the size of the whole car and thus the Parent.Parent.Parent is the folder that stores all the cars (called "Cars") 
			CloseGarage(hit, 1) -- fire the close garage with params : hit and the garage value
		end

		wait(0.1)
		debounce = false
	end
end)

Garage.Door2CloseTrigger.Touched:Connect(function(hit) -- garage 2
	if not debounce then
		debounce = true

		if hit.Parent.Parent.Parent:IsA("Folder") and hit.Parent.Parent.Parent.Name == "Cars" then
			CloseGarage(hit, 2)			
		end

		wait(0.1)
		debounce = false
	end
end)

Garage.Door3CloseTrigger.Touched:Connect(function(hit) -- garage 3
	if not debounce then
		debounce = true

		if hit.Parent.Parent.Parent:IsA("Folder") and hit.Parent.Parent.Parent.Name == "Cars" then
			CloseGarage(hit, 3)			
		end

		wait(0.1)
		debounce = false
	end
end)


-- ON CLIENT LEAVE BUTTON CLICK

GarageRemoteEvent.OnServerEvent:Connect(function(plr, Type, Value) -- on client remote event fired

	if Type and typeof(Type) == "string" then

		if Type == "Leave" then
			local PlayerGarage = nil

			for i=1,3 do -- loop through the 3 garages values to know which garage the player is in
				if script:FindFirstChild("Garage"..tostring(i)).Value == plr.Name then -- if the garage value is the same as the player name, then the player is inside
					PlayerGarage = i -- garage where the player is
					break
				end
			end
			
			if PlayerGarage then -- if the player was found in a garage

				coroutine.wrap(function() -- coroutine for the cooldown
					table.insert(PlayerDebounce, plr.Name) -- add the player to the table to know that he is on cooldown
					wait(PlayerDebounceTime) -- wait (6 seconds)

					local TablePosition = table.find(PlayerDebounce, plr.Name) -- find the position of the player in the table
					if TablePosition then -- if the player was found
						table.remove(PlayerDebounce, TablePosition) -- remove the player from the table so that he can enter the garage again
					end
				end)()
				
				script:FindFirstChild("Garage"..PlayerGarage).Value = "" -- reset the garage value becaues the plaeyr is not in anymore

				--plr.PlayerGui.Garage.Enabled = false -- hide the garage gui
				Garage:FindFirstChild("Door"..PlayerGarage.."Close").CanCollide = false -- make the garage closed door part uncolllideable so that the player can leave

				local CloseDoor = TweenService:Create(Garage:FindFirstChild("GarageDoor"..PlayerGarage).PrimaryPart, TweenInfo.new(2.5), {CFrame = Garage:FindFirstChild("Door"..PlayerGarage.."Open").CFrame}) -- tween to close the door
				CloseDoor:Play() -- play the tween

				script:FindFirstChild("Garage"..PlayerGarage.."Open").Value = true -- garage open value set to true so that players can go to the garage
			end
			
		-- Change the car license plate
		elseif Type == "Registration" then
			if Value and typeof(Value) == "string" then
				
				local RegistrationNumber = Value
				
				local success, FilteredResult = pcall(function() -- filter text to detect inappropriate names
					return TextService:FilterStringAsync(RegistrationNumber, plr.UserId)
				end)
				
				coroutine.wrap(function()
					if success then
						local FilteredName = FilteredResult:GetNonChatStringForBroadcastAsync()

						if RegistrationNumber == FilteredName then -- check if the name is appropriate (if it has been filtered)

							if string.len(RegistrationNumber) < 12 then

								if Cars:FindFirstChild(plr.Name) then
									if Cars[plr.Name].Body:FindFirstChild("Registration") then
										Cars[plr.Name].Body:FindFirstChild("Registration").SurfaceGui.TextLabel.Text = RegistrationNumber
									end
								end



							else
								plr.PlayerGui.Garage.Frame.InvalidName.Visible = true
								plr.PlayerGui.Garage.Frame.InvalidName.Text = "This name is too long, please choose another one."
								wait(8)
								plr.PlayerGui.Garage.Frame.InvalidName.Visible = false
							end

						else
							plr.PlayerGui.Garage.Frame.InvalidName.Visible = true
							plr.PlayerGui.Garage.Frame.InvalidName.Text = "This name can't be used, please choose another one."
							wait(8)
							plr.PlayerGui.Garage.Frame.InvalidName.Visible = false
						end

					else
						plr.PlayerGui.Garage.Frame.InvalidName.Visible = true
						plr.PlayerGui.Garage.Frame.InvalidName.Text = "Your name couldn't be filtered, please retry in a few minutes."
						wait(5)
						plr.PlayerGui.Garage.Frame.InvalidName.Visible = false
					end
				end)()
			end
			
		-- Change the car body color
		elseif Type == "Body" then
			if Value and typeof(Value) == "Color3" then
				
				local Color = Value
				
				if Cars:FindFirstChild(plr.Name) then
					if Cars[plr.Name].Body:FindFirstChild("Body") then
						Cars[plr.Name].Body:FindFirstChild("Body").Color = Color
					end
				end
			end
			
		-- Give or remove the skateboard from the player
		elseif Type == "SkateBoard" then
			
			-- If the player already has a car
			if Cars:FindFirstChild(plr.Name) then
				
				local IsVehicleASkateBoard = false
				
				-- If the vehicle is already a skateboard, we don't want to spawn another one, but if it isn't, we want
				if Cars[plr.Name]:GetAttribute("VehicleType") == "SkateBoard" then
					IsVehicleASkateBoard = true
				end
				
				-- Destroy the previous vehicles
				Cars[plr.Name]:Destroy()
				
				-- Spawn a skateboard
				if not IsVehicleASkateBoard then
					SpawnSkateBoard(plr)
				end
				
			else
				SpawnSkateBoard(plr)
			end
		end
	end
end)