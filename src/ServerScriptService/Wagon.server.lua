local ServerStorage = game:GetService("ServerStorage")
local WagonTrack = workspace.Mines.Wagon

local function SpawnWagon()
	local WagonClone = ServerStorage.MiningTools:WaitForChild("Wagon"):Clone()
	WagonClone:SetPrimaryPartCFrame(WagonTrack.WagonPosition.CFrame)
	WagonClone.Parent = WagonTrack
	
	-- Get the seating events
	WagonTrack.Wagon.Seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		
		if WagonTrack:FindFirstChild("Wagon") then
			
			if WagonTrack:FindFirstChild("Wagon").Seat.Occupant then
				-- Give an angular velocity to the wheels to move the wagon
				for i,v in ipairs(WagonTrack:FindFirstChild("Wagon").Wheels:GetChildren()) do
					if v:FindFirstChild("BodyAngularVelocity") then
						v:FindFirstChild("BodyAngularVelocity").AngularVelocity = Vector3.new(-20,0,0)
					end
				end

			else
				-- Destroy the wagon
				WagonTrack:FindFirstChild("Wagon"):Destroy()

				-- Spawn new wagon
				SpawnWagon()
			end
		end
	end)
end

-- Spawn the wagon once when the game launches
SpawnWagon()


-- INCREASE THE SPEED OF THE WAGON WHEN IT TOUCHES THE TRIGGER

WagonTrack.IncreaseSpeed.Touched:Connect(function(hit)
	if hit.Parent.Parent.Name == "Wagon" and hit.Parent.Parent.Parent.Name == "Wagon" then
		
		-- Give the wheels a higher angular velocity
		for i,v in ipairs(WagonTrack.Wagon.Wheels:GetChildren()) do
			if v:FindFirstChild("BodyAngularVelocity") then
				v:FindFirstChild("BodyAngularVelocity").AngularVelocity = Vector3.new(-100,0,0)
			end
		end
	end
end)


-- DESTROY THE WAGON AND SPAWN A NEW ONE ONCE IT REACHES THE END

WagonTrack.EndBlock.Touched:Connect(function(hit)
	if hit.Parent.Parent.Name == "Wagon" and hit.Parent.Parent:FindFirstChild("Seat") then -- if hit is the wagon
		
		-- If there is a player in the seat, teleport him
		if hit.Parent.Parent:FindFirstChild("Seat").Occupant and hit.Parent.Parent:FindFirstChild("Seat").Occupant.Parent:FindFirstChild("HumanoidRootPart") then
			hit.Parent.Parent:FindFirstChild("Seat").Occupant.Parent:FindFirstChild("HumanoidRootPart").CFrame = WagonTrack.TeleportPart.CFrame
		end
		
		-- Destroy the wagon
		hit.Parent.Parent:Destroy()
		
		-- Spawn new wagon
		SpawnWagon()
	end
end)

for i,v in ipairs(workspace.Streets.YellowLines:GetChildren()) do
	v.Texture:Destroy()
	v.Transparency = 0
	v.Material = Enum.Material.Plastic
	v.Color = Color3.fromRGB(245,205,48)
end