local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local HouseBindableEvent = ServerStorage:WaitForChild("House")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HouseRemoteEvent = ReplicatedStorage:WaitForChild("House")

local FreeSpots = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20}
local TakenSpots = {}
local UpgradePrice = {25000,75000,250000,1000000}


-- LOAD THE PLAYER'S HOUSE

local function LoadHouse(plr, House, Spot)

	if plr and House and Spot then
		House = House:Clone()
		House:SetPrimaryPartCFrame(workspace.Houses.Placement["House"..tostring(Spot)].CFrame)
		House.Spot.Value = Spot
		House.Name = plr.Name

		-- Change the color of the house
		for i,v in ipairs(plr.House.Colors:GetChildren()) do
			if House:FindFirstChild(v.Name) then

				for a,b in ipairs(House[v.Name]:GetChildren()) do
					b.Color = v.Value
				end
			end
		end

		House.Parent = workspace.Houses
	end
end


-- LOAD THE PLAYER'S HOUSE WHEN HE JOINS

HouseBindableEvent.Event:Connect(function(plr)

	if not workspace.Houses:FindFirstChild(plr.Name) then
		-- Choose a spot for the player's house and set it as taken
		local TablePosition = math.random(1,#FreeSpots)
		local Spot = FreeSpots[TablePosition]

		table.insert(TakenSpots, Spot)
		table.remove(FreeSpots, TablePosition)

		-- Find the house that matches the player's tier
		local House = ServerStorage.Houses:FindFirstChild("Tier"..tostring(plr.House.Tier.Value))

		-- Load the house
		if House and workspace.Houses.Placement:FindFirstChild("House"..tostring(Spot)) then
			LoadHouse(plr, House, Spot)

			-- Change the sign that says "House of [player]"
			if workspace.Houses.Signs:FindFirstChild("Sign"..tostring(Spot)) then
				workspace.Houses.Signs["Sign"..tostring(Spot)].Player.SurfaceGui.Player.Text = plr.Name
			end
		end		
	end
end)


-- DELETE THE PLAYER'S HOUSE WHEN HE LEAVES

Players.PlayerRemoving:Connect(function(plr)
	if workspace.Houses:FindFirstChild(plr.Name) then

		-- Remove the spot from the taken spots and set back as free for other players
		local TablePosition = table.find(TakenSpots, workspace.Houses[plr.Name].Spot.Value)
		if TablePosition then
			table.remove(TakenSpots, TablePosition)
			table.insert(FreeSpots, workspace.Houses[plr.Name].Spot.Value)
		end

		-- Delete the house
		workspace.Houses[plr.Name]:Destroy()
	end
end)


-- PLAYER CUSTMIZES HIS HOUSE

HouseRemoteEvent.OnServerEvent:Connect(function(plr, Type, Part, Color)
		if Type and typeof(Type) == "string" then

		if Type == "Upgrade" then
			if UpgradePrice[plr.House.Tier.Value] then

				local EnoughMoney = MoneyBindableFunction:Invoke(plr, UpgradePrice[plr.House.Tier.Value], "-") -- check if player has enough money
				if EnoughMoney then

					plr.House.Tier.Value += 1
					HouseBindableEvent:Fire(plr, "Upgrade")

					if workspace.Houses:FindFirstChild(plr.Name) then
						LoadHouse(plr, ServerStorage.Houses:FindFirstChild("Tier"..tostring(plr.House.Tier.Value)), workspace.Houses[plr.Name].Spot.Value)
						workspace.Houses[plr.Name]:Destroy()
					end

					-- Delete the old script and add a new one to reset the touch events and get all the events for the new house
					local NewScript = plr.PlayerGui.House.House:Clone()
					plr.PlayerGui.House.House:Destroy()
					NewScript.Parent = plr.PlayerGui.House
				end
			end

		elseif Type == "Color" then
			
			if workspace.Houses:FindFirstChild(plr.Name) and workspace.Houses[plr.Name]:FindFirstChild(Part) then
				for i,v in ipairs(workspace.Houses[plr.Name][Part]:GetChildren()) do
					v.Color = Color
					
					if plr.House.Colors:FindFirstChild(Part) then
						plr.House.Colors[Part].Value = Color
					end
				end
			end

		elseif Type == "ValidateColor" then
			HouseBindableEvent:Fire(plr, "Color")
		end
	end
end)