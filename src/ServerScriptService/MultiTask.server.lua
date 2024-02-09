local Players = game:GetService("Players")

local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableEvent = ServerStorage:WaitForChild("Money")
local AgeBindableEvent = ServerStorage:WaitForChild("Age")
local WarnBindableEvent = ServerStorage:WaitForChild("Warn")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MultitaskRemoteEvent = ReplicatedStorage:WaitForChild("Multitask")
local DeathRemoteEvent = ReplicatedStorage:WaitForChild("Death")
local CardDropRemoteEvent = ReplicatedStorage:WaitForChild("DropCard")

local Villa = game.Workspace.Villa

local PlayerList = {}

-- CREATHE THE TABLE FOR EACH PLAYER

Players.PlayerAdded:Connect(function(plr)
	PlayerList[plr.Name] = {} -- index : [1] = PrepareMealsDebounce, [2] = DeliverMealsDebounce
	table.insert(PlayerList[plr.Name], 1, 0)
	table.insert(PlayerList[plr.Name], 2, 0)
end)

Players.PlayerRemoving:Connect(function(plr)
	PlayerList[plr.Name] = nil
	
	if plr.Name == workspace.School.BestStudent.Board.SurfaceGui.StudentName.Value == plr.Name then
		local BestStudent = ""
		local NumberOfCompletedLevels = 0
		
		for i,v in ipairs(Players:GetChildren()) do
			if v:FindFirstChild("CompletedLevels") and v:FindFirstChild("CompletedLevels").Value > NumberOfCompletedLevels then
				NumberOfCompletedLevels = v:FindFirstChild("CompletedLevels").Value
				BestStudent = v.Name
			end
		end

		if Players:FindFirstChild(BestStudent) then
			workspace.School.BestStudent.Board.SurfaceGui.CompletedLevels.Value = NumberOfCompletedLevels

			local content, isReady = Players:GetUserThumbnailAsync(Players[BestStudent].UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

			workspace.School.BestStudent.Board.SurfaceGui.Player.Image = content
			workspace.School.BestStudent.Board.SurfaceGui.StudentName.Value = BestStudent
			workspace.School.BestStudent.Board.SurfaceGui.TextLabel.Text = "Best student : "..BestStudent
		end
	end
end)


-- change player's age when dying in the hospital

MultitaskRemoteEvent.OnServerEvent:Connect(function(plr, Type)
	
	if Type then
		
		if Type == "Hospital" then -- if player dies in the hospital
			DeathRemoteEvent:FireClient(plr, plr.leaderstats.Age.Value, false, true)
			wait(0.5)
			AgeBindableEvent:Fire(plr, 0, "Set")
		end
		
	else WarnBindableEvent:Fire(plr, "Normal", "is firing the multitask remote event with nil values", "MultiTask", os.time()) end
end)


-- drop card in the villa

CardDropRemoteEvent.OnServerEvent:Connect(function(plr)
	game.Workspace[plr.Name].Card.Parent = Villa
	Villa.Card.Handle.Anchored = true
	Villa.Card.Handle.CFrame = Villa.CardPlacement.CFrame
	Villa.Card.Handle.Anchored = false
end)


-- VOLCANO ENTRANCE

workspace.Volcano.Lava.Trigger.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" and hit.Parent:FindFirstChild("Humanoid") and Players:FindFirstChild(hit.Parent.Name) then
		if Players:FindFirstChild(hit.Parent.Name):FindFirstChild("PetCustomisations") and Players:FindFirstChild(hit.Parent.Name):FindFirstChild("PetCustomisations"):FindFirstChild("EquippedPet") then

			if Players:FindFirstChild(hit.Parent.Name):FindFirstChild("PetCustomisations"):FindFirstChild("EquippedPet").Value ~= "Demon"
			and Players:FindFirstChild(hit.Parent.Name):FindFirstChild("PetCustomisations"):FindFirstChild("EquippedPet").Value ~= "HellishGolem"
			and Players:FindFirstChild(hit.Parent.Name):FindFirstChild("PetCustomisations"):FindFirstChild("EquippedPet").Value ~= "LightGolem"
			and Players:FindFirstChild(hit.Parent.Name):FindFirstChild("PetCustomisations"):FindFirstChild("EquippedPet").Value ~= "MythicalGolem" then
				hit.Parent:FindFirstChild("Humanoid").Health = 0
			end
		end
	end
end)


-- VOLCANO TELEPORT OUT

workspace.Volcano.TeleportOut.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" then
		hit.CFrame = workspace.Volcano.PlayerPlacement.CFrame
	end
end)


-- ICE CAVE ENTRANCE

workspace.IceCave.Entrance.Touched:Connect(function(hit)
	if hit.Name == "HumanoidRootPart" and Players:FindFirstChild(hit.Parent.Name) then
		if Players:FindFirstChild(hit.Parent.Name):FindFirstChild("PetCustomisations") and Players:FindFirstChild(hit.Parent.Name):FindFirstChild("PetCustomisations"):FindFirstChild("EquippedPet") then

			if Players:FindFirstChild(hit.Parent.Name):FindFirstChild("PetCustomisations"):FindFirstChild("EquippedPet").Value ~= "IceGolem" then
				hit.CFrame = workspace.IceCave.OutTp.CFrame
			end
		end
	end
end)

-- DEBOUNCE FOR EACH PLAYER

--while wait(1) do
--	for i, v in next, PlayerList do
--		if v[1] > 0 then
--			v[1] = v[1] - 1
--		end

--		if v[2] > 0 then
--			v[2] = v[2] - 1
--		end
--	end
--end