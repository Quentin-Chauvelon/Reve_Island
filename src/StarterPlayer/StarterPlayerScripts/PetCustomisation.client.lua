local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetCustomisationRemoteEvent = ReplicatedStorage:WaitForChild("PetCustomisation")

local lplr = game.Players.LocalPlayer
local EquippedPet = lplr:WaitForChild("PetCustomisations"):WaitForChild("EquippedPet")
local Inventory = lplr.PlayerGui:WaitForChild("Pets"):WaitForChild("Frame"):WaitForChild("Inventory")
local PetShop = workspace.PetShop
local Rename = lplr.PlayerGui.Pets:WaitForChild("RenameGui")
local Trail = PetShop.Trail
local TrailCustomise = Trail.Board.SurfaceGui.Customise
local Sparkles = PetShop.Sparkles
local SparklesCustomise = Sparkles.Board.SurfaceGui.Customise
local RenameColor = PetShop.RenameColor
local RenameCustomise = RenameColor.Board.SurfaceGui.Customise
local PetsGui = lplr.PlayerGui.Pets.Frame
local PackColors = PetsGui.Pack.Frame
local SwimmingFaster

local CustomisationTable = { -- table for all the customisations
	Equipped = "",
	Trail = false,
	TrailColor = {
		"1, 1, 1"	
	},
	Sparkles = false,
	SparklesColor = {
		"1, 1, 1"	
	},
	Rename = "",
	RenameColorSelected = "",
	RenameColor = {}
}


-- IF PLAYER EQUIPS/UNEQUIPS A PET

local function EquippingPet(ClickedPet)
	
	local ClickedPetRarity = Inventory.ScrollingFrame:WaitForChild(ClickedPet).Rarity.Text -- get the pet rarity
	local OldPet = nil

	if EquippedPet.Value ~= "" then -- if player has got a pet equipped
		OldPet = EquippedPet.Value -- get the equipped pet
		Inventory.ScrollingFrame[OldPet].BackgroundColor3 = Color3.fromRGB(136, 181, 223)
		Inventory.ScrollingFrame[OldPet].PetName.Text = OldPet -- set the text in the inventory back to the name (it was "equipped" before)
	end

	if ClickedPet == OldPet then -- if player is not unequipping the pet (by clicking two times on the same pet)
		CustomisationTable["Equipped"] = "" -- remove the pet name (to save no pet equipped)	
	else
		CustomisationTable["Equipped"] = ClickedPet -- change the equipped pet name in the table
		Inventory.ScrollingFrame[ClickedPet].BackgroundColor3 = Color3.fromRGB(23, 199, 10) -- change name and color of the pet in the inventory
		Inventory.ScrollingFrame[ClickedPet].PetName.Text = "Equipped"
	end

	PetCustomisationRemoteEvent:FireServer("Equip", ClickedPet, OldPet, ClickedPetRarity) -- fire the server to create the pet next to the player

	if SwimmingFaster and lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
		SwimmingFaster:Disconnect() -- disconnect the swimming event
		lplr.Character:FindFirstChild("Humanoid").WalkSpeed = 20
		SwimmingFaster = nil -- set it to nil otherwise if SwimmingFaster is always true
	end

	-- If the player is equipping or unequipping the jellyfish or the little sea monster pets
	if ClickedPet == "Jellyfish" or ClickedPet == "LittleSeaMonster" or ClickedPet == "Shark" and ClickedPet ~= OldPet then
		if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then

			-- If the player is unequipping it
			if SwimmingFaster then
				if not ((ClickedPet == "Jellyfish" and EquippedPet.Value == "LittleSeaMonster") or (ClickedPet == "LittleSeaMonster" and EquippedPet.Value == "Jellyfish")) then
					SwimmingFaster:Disconnect() -- disconnect the swimming event
					lplr.Character:FindFirstChild("Humanoid").WalkSpeed = 20
					SwimmingFaster = nil -- set it to nil otherwise if SwimmingFaster is always true 
				end

				-- If the player is equipping it
			else
				SwimmingFaster = lplr.Character:FindFirstChild("Humanoid").StateChanged:Connect(function(OldState, NewState)
					-- If the player is already swiming, set his walkspeed to 30
					if lplr.Character:FindFirstChild("Humanoid"):GetState() == Enum.HumanoidStateType.Swimming then
						lplr.Character:FindFirstChild("Humanoid").WalkSpeed = 30
					end

					-- If the player is swimming, set his walkspeed to 30, otherwise, set it to 20
					if NewState == Enum.HumanoidStateType.Swimming then
						lplr.Character:FindFirstChild("Humanoid").WalkSpeed = 30
					else
						lplr.Character:FindFirstChild("Humanoid").WalkSpeed = 20
					end
				end)
			end
		end
	end
end


-- GET DATA AND LOAD THE PET CUSTOMISATIONS

PetCustomisationRemoteEvent.OnClientEvent:Connect(function(Type, SavedPetsData)
	if Type == "Load" then
		if SavedPetsData and next(SavedPetsData) ~= nil then
			if SavedPetsData["Equipped"] ~= "" then
				CustomisationTable["Equipped"] = SavedPetsData["Equipped"] -- set the table vale to the load table value
				EquippingPet(SavedPetsData["Equipped"]) -- fire the equipping function with the pet
			end

			if SavedPetsData["Rename"] ~= "" then
				CustomisationTable["Rename"] = SavedPetsData["Rename"]
			end

			if SavedPetsData["RenameColorSelected"] ~= "" then
				CustomisationTable["RenameColorSelected"] = SavedPetsData["RenameColorSelected"]
			end

			if SavedPetsData["RenameColor"] then
				local WhiteRename = table.find(SavedPetsData["RenameColor"], "1, 1, 1")
				if not WhiteRename then
					table.insert(CustomisationTable["RenameColor"], 1, "1, 1, 1")
				end
				for i,v in ipairs(SavedPetsData["RenameColor"]) do
					table.insert(CustomisationTable["RenameColor"], 1, tostring(v))
				end 
			end

			if SavedPetsData["Trail"] and SavedPetsData["Trail"] ~= false then -- if player bought the trail
				CustomisationTable["Trail"] = SavedPetsData["Trail"]
				Trail.Board.SurfaceGui.Buy.Visible =  false -- hide the buy and show the customise
				Trail.Board.SurfaceGui.Customise.Visible = true
			end

			if SavedPetsData["TrailColor"] then
				for i,v in ipairs(SavedPetsData["TrailColor"]) do
					table.insert(CustomisationTable["TrailColor"], 1, tostring(v))
				end
			end

			if SavedPetsData["Sparkles"] and SavedPetsData["Sparkles"] ~= false then -- if player bought the sparkles
				CustomisationTable["Sparkles"] = SavedPetsData["Sparkles"]
				Sparkles.Board.SurfaceGui.Buy.Visible =  false -- hide the buy and show the customise
				Sparkles.Board.SurfaceGui.Customise.Visible = true
			end

			if SavedPetsData["SparklesColor"] then
				for i,v in ipairs(SavedPetsData["SparklesColor"]) do
					table.insert(CustomisationTable["SparklesColor"], 1, tostring(v))
				end 
			end
		end

	elseif Type == "Table" then	-- update table when buying a customisation
		CustomisationTable = SavedPetsData
	end
end)


-- GET THE INVENTORY BUTTONS

for i,v in ipairs(Inventory.ScrollingFrame:GetChildren()) do -- for all the pets that were already in the inventory
	if v:IsA("ImageButton") then
		v.MouseButton1Down:Connect(function() -- get click on all the buttons
			EquippingPet(v.Name)
		end)
	end
end

Inventory.ScrollingFrame.ChildAdded:Connect(function(child) -- for all the eggs that are opened
	if child:IsA("ImageButton") then
		child.MouseButton1Down:Connect(function() -- get click on all the buttons
			EquippingPet(child.Name)
		end)
	end
end)


-- RENAME THE PET

Rename.Buy.Activated:Connect(function()
	if Rename.PetName.Text ~= ""  and Rename.PetName.Text ~= "Enter your pet's name here" then -- to prevent players from buying a pet without name or with the "placeholder" text
		PetCustomisationRemoteEvent:FireServer("Rename", Rename.PetName.Text) -- fire server to display the name for all players
	end
end)


-- PREVIEW THE TRAIL

local function TrailPreview(Color, TrailR, TrailG, TrailB)
	if Trail:FindFirstChild("PetPreviewed") then -- if a pet is already previewed
		Trail:FindFirstChild("PetPreviewed"):Destroy()
	end

	local TrailPetClone = nil
	if EquippedPet.Value == "" then -- if player hasn't got a pet equipped
		TrailPetClone = ReplicatedStorage.Pets.Common.Cat:Clone() -- preview with a cat
	else
		for i,v in ipairs(ReplicatedStorage.Pets:GetChildren()) do -- loop through the rarity folders to find the equipped pet and clone it
			if v:FindFirstChild(EquippedPet.Value) then
				TrailPetClone = v:FindFirstChild(EquippedPet.Value):Clone()
				break
			end
		end
	end

	TrailPetClone.Parent = Trail
	TrailPetClone.Name = "PetPreviewed"
	TrailPetClone.PrimaryPart.Anchored = true
	TrailPetClone:SetPrimaryPartCFrame(Trail.PetPlacement.CFrame)

	local PetAttachment = Instance.new("Attachment", TrailPetClone.PrimaryPart)

	Trail.AttachmentPart.Beam.Attachment1 = PetAttachment

	if TrailR then
		Trail.AttachmentPart.Beam.Color = ColorSequence.new(Color3.new(TrailR,TrailG,TrailB)) -- split the rgb values into 3 variables otherwise it doesn't work
	else
		if Color == "Multicolor" then
			Trail.AttachmentPart.Beam.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
				ColorSequenceKeypoint.new(0.2, Color3.new(1,1,0)),
				ColorSequenceKeypoint.new(0.4, Color3.new(0,1,0)),
				ColorSequenceKeypoint.new(0.6, Color3.new(0,1,1)),
				ColorSequenceKeypoint.new(0.8, Color3.new(0,0,1)),
				ColorSequenceKeypoint.new(1, Color3.new(1,0,1))
			}
		else
			Trail.AttachmentPart.Beam.Color = ColorSequence.new(Color3.new(1,1,1))
		end
	end
end

Trail.Board.SurfaceGui.Buy.Preview.Activated:Connect(function() -- fire function with no arguments (used nil, otherwise got "random" values
	TrailPreview(nil,nil,nil,nil)
end)


-- BUY THE TRAIL

Trail.Board.SurfaceGui.Buy.Buy.Activated:Connect(function()
	if Trail:FindFirstChild("PetPreviewed") then
		Trail:FindFirstChild("PetPreviewed"):Destroy()
	end

	if lplr.leaderstats.Money.Value >= 50000 then
		Trail.Board.SurfaceGui.Buy.Visible =  false -- hide the buy and show the customise
		Trail.Board.SurfaceGui.Customise.Visible = true

		PetCustomisationRemoteEvent:FireServer("Trail")
	end
end)



-- BUY AND PREVIEW THE TRAIL COLORS

local function TrailColor(Color, Type, R, G, B)
	if R then
		if R ~= 1 and R ~= 0 then R = string.format("%." .. (6) .. "f", R) end -- keep only 6 number after the coma for decimal number (not equal to 0 and 1)
		if G ~= 1 and G ~= 0 then G = string.format("%." .. (6) .. "f", G) end
		if B ~= 1 and B ~= 0 then B = string.format("%." .. (6) .. "f", B) end
	end

	TrailCustomise.ColorDisplay.UIGradient.Enabled = false -- change the board gui
	TrailCustomise.ColorSelected.Price.Text = "$10000"
	TrailCustomise.ColorDisplay.BackgroundColor3 = Color3.new(R,G,B)
	TrailCustomise.ColorSelected.Visible = true
	TrailCustomise.Owned.Visible = false

	if Color == "Multicolor" then
		if table.find(CustomisationTable["TrailColor"], "Multicolor") then
			TrailCustomise.ColorSelected.Visible = false
			TrailCustomise.ColorDisplay.BackgroundColor3 = Color3.new(1,1,1)
			TrailCustomise.ColorDisplay.UIGradient.Enabled = true
			TrailCustomise.Owned.Visible = true
			if Type ~= "Buy" then
				PetCustomisationRemoteEvent:FireServer("TrailColor", "Equip", "Multicolor") -- fire server to change the color of the trail (so everyone can see it)
			end
		else
			TrailCustomise.ColorSelected.Price.Text = "$35000"
			TrailCustomise.ColorDisplay.BackgroundColor3 = Color3.new(1,1,1)
			TrailCustomise.ColorDisplay.UIGradient.Enabled = true
		end
	end
	if R then
		local FindTrailColor = table.find(CustomisationTable["TrailColor"], R..", "..G..", "..B)
		
		if FindTrailColor then
			TrailCustomise.ColorSelected.Visible = false
			TrailCustomise.Owned.Visible = true
			TrailCustomise.ColorSelected.Visible = false
			TrailCustomise.Owned.Visible = true
			
			if Type ~= "Buy" then
				PetCustomisationRemoteEvent:FireServer("TrailColor", "Equip", R..", "..G..", "..B) -- fire server to change the color of the trail (so everyone can see it)
			end
		end
	end
end


-- DETECT THE TRAIL COLOR BUTTONS CLICK

for i,v in ipairs(TrailCustomise.ColorPicker:GetChildren()) do -- for all the pets that were already in the inventory
	if v:IsA("ImageButton") then
		v.Activated:Connect(function() -- get click on all the buttons
			TrailColor(nil, nil, v.BackgroundColor3.R, v.BackgroundColor3.G, v.BackgroundColor3.B)
		end)
	end
end


-- DETECT THE MULTICOLOR BUTTON CLICK

TrailCustomise.Multicolor.Activated:Connect(function()
	TrailColor("Multicolor", nil, nil, nil, nil)
end)


-- DETECT THE PREVIEW TRAIL COLOR BUTTON CLICK

TrailCustomise.ColorSelected.Preview.Activated:Connect(function()
	if TrailCustomise.ColorDisplay.UIGradient.Enabled == true then
		TrailPreview("Multicolor", nil, nil, nil)
	else
		TrailPreview(nil, TrailCustomise.ColorDisplay.BackgroundColor3.R, TrailCustomise.ColorDisplay.BackgroundColor3.G, TrailCustomise.ColorDisplay.BackgroundColor3.B)
	end
end)


-- DETECT THE BUY TRAIL COLOR BUTTON CLICK

TrailCustomise.ColorSelected.Buy.Activated:Connect(function()
	if Trail:FindFirstChild("PetPreviewed") then
		Trail:FindFirstChild("PetPreviewed"):Destroy()
	end

	if TrailCustomise.ColorDisplay.UIGradient.Enabled == true then -- if uigradient is enable, then it means that it is the multicolor
		table.insert(CustomisationTable["TrailColor"], 1, "Multicolor") -- add the trail color to the table to save it
		TrailColor("Multicolor", "Buy", nil, nil, nil) -- equip the color
		CustomisationTable["Trail"] = "Multicolor"  -- change the selected color in the table
		PetCustomisationRemoteEvent:FireServer("TrailColor", "Buy", "Multicolor") -- fire server to change the color of the trail (so everyone can see it)
	else
		table.insert(CustomisationTable["TrailColor"], 1, tostring(TrailCustomise.ColorDisplay.BackgroundColor3))
		TrailColor(nil, "Buy", TrailCustomise.ColorDisplay.BackgroundColor3.R, TrailCustomise.ColorDisplay.BackgroundColor3.G, TrailCustomise.ColorDisplay.BackgroundColor3.B)
		CustomisationTable["Trail"] = tostring(TrailCustomise.ColorDisplay.BackgroundColor3)
		PetCustomisationRemoteEvent:FireServer("TrailColor", "Buy", CustomisationTable["Trail"])
	end
end)


-- PREVIEW THE SPARKLES

local function SparklesPreview(Color, SparklesR, SparklesG, SparklesB) -- see trail functions for comments
	if Sparkles:FindFirstChild("PetPreviewed") then
		Sparkles:FindFirstChild("PetPreviewed"):Destroy()
	end

	local SparklesPetClone = nil

	if EquippedPet.Value == "" then
		SparklesPetClone = ReplicatedStorage.Pets.Common.Cat:Clone()
	else
		for i,v in ipairs(ReplicatedStorage.Pets:GetChildren()) do
			if v:FindFirstChild(EquippedPet.Value) then
				SparklesPetClone = v:FindFirstChild(EquippedPet.Value):Clone()
				break
			end
		end
	end

	SparklesPetClone.Parent = Sparkles
	SparklesPetClone.Name = "PetPreviewed"
	SparklesPetClone.PrimaryPart.Anchored = true
	SparklesPetClone:SetPrimaryPartCFrame(Sparkles.PetPlacement.CFrame)

	for i,v in ipairs(Sparkles.PetPlacement:GetChildren()) do
		if v:IsA("Sparkles") then
			v:Destroy()
		end
	end

	local CreateSparkles = Instance.new("Sparkles", Sparkles.PetPlacement)
	if SparklesR then
		Sparkles.PetPlacement.Sparkles.SparkleColor = Color3.new(SparklesR,SparklesG,SparklesB)
	else	
		if Color == "Multicolor" then
			CreateSparkles.SparkleColor = Color3.new(1,0,0)

			CreateSparkles = Instance.new("Sparkles", Sparkles.PetPlacement)
			CreateSparkles.SparkleColor = Color3.new(1,1,0)

			CreateSparkles = Instance.new("Sparkles", Sparkles.PetPlacement)
			CreateSparkles.SparkleColor = Color3.new(0,1,0)

			CreateSparkles = Instance.new("Sparkles", Sparkles.PetPlacement)
			CreateSparkles.SparkleColor = Color3.new(0,1,1)

			CreateSparkles = Instance.new("Sparkles", Sparkles.PetPlacement)
			CreateSparkles.SparkleColor = Color3.new(0,0,1)

			CreateSparkles = Instance.new("Sparkles", Sparkles.PetPlacement)
			CreateSparkles.SparkleColor = Color3.new(1,0,1)
		else
			Sparkles.PetPlacement.Sparkles.SparkleColor = Color3.new(1,1,1) -- if previewed before buying the sprakles
		end
	end
end

Sparkles.Board.SurfaceGui.Buy.Preview.Activated:Connect(function()
	SparklesPreview(nil,nil,nil,nil)
end)


-- BUY THE SPARKLES

Sparkles.Board.SurfaceGui.Buy.Buy.Activated:Connect(function()
	if Sparkles:FindFirstChild("PetPreviewed") then
		Sparkles:FindFirstChild("PetPreviewed"):Destroy()
		for i,v in ipairs(Sparkles.PetPlacement:GetChildren()) do
			if v:IsA("Sparkles") then
				v:Destroy()
			end
		end
	end
	
	if lplr.leaderstats.Money.Value >= 50000 then
		Sparkles.Board.SurfaceGui.Buy.Visible =  false -- hide the buy and show the customise
		Sparkles.Board.SurfaceGui.Customise.Visible = true

		PetCustomisationRemoteEvent:FireServer("Sparkles")
	end
end)



-- BUY AND PREVIEW THE SPARKLES COLORS

local function SparklesColor(Color, Type, R, G, B)
	if R ~= nil then
		if R ~= 1 and R ~= 0 then R = string.format("%." .. (6) .. "f", R) end
		if G ~= 1 and G ~= 0 then G = string.format("%." .. (6) .. "f", G) end
		if B ~= 1 and B ~= 0 then B = string.format("%." .. (6) .. "f", B) end
	end

	SparklesCustomise.ColorDisplay.UIGradient.Enabled = false -- change the board gui
	SparklesCustomise.ColorSelected.Price.Text = "$10000"
	SparklesCustomise.ColorDisplay.BackgroundColor3 = Color3.new(R,G,B)
	SparklesCustomise.ColorSelected.Visible = true
	SparklesCustomise.Owned.Visible = false

	if Color == "Multicolor" then
		if table.find(CustomisationTable["SparklesColor"], "Multicolor") then
			SparklesCustomise.ColorSelected.Visible = false
			SparklesCustomise.ColorDisplay.BackgroundColor3 = Color3.new(1,1,1)
			SparklesCustomise.ColorDisplay.UIGradient.Enabled = true
			SparklesCustomise.Owned.Visible = true
			if Type ~= "Buy" then
				PetCustomisationRemoteEvent:FireServer("SparklesColor", "Equip", "Multicolor") -- fire the server to change the sparkles color
			end

		else
			SparklesCustomise.ColorSelected.Price.Text = "$35000"
			SparklesCustomise.ColorDisplay.BackgroundColor3 = Color3.new(1,1,1)
			SparklesCustomise.ColorDisplay.UIGradient.Enabled = true
		end
	end

	if R ~= nil then
		local FindSparklesColor = table.find(CustomisationTable["SparklesColor"], R..", "..G..", "..B)
		if FindSparklesColor then
			SparklesCustomise.ColorSelected.Visible = false
			SparklesCustomise.Owned.Visible = true
			SparklesCustomise.ColorSelected.Visible = false
			SparklesCustomise.Owned.Visible = true
			if Type ~= "Buy" then			
				PetCustomisationRemoteEvent:FireServer("SparklesColor", "Equip", R..", "..G..", "..B) -- fire the server to change the sparkles color
			end
		end
	end
end


-- DETECT THE SPARKLES COLOR BUTTONS CLICK
for i,v in ipairs(SparklesCustomise.ColorPicker:GetChildren()) do -- for all the pets that were already in the inventory
	if v:IsA("ImageButton") then
		v.Activated:Connect(function() -- get click on all the buttons
			SparklesColor(nil, nil, v.BackgroundColor3.R, v.BackgroundColor3.G, v.BackgroundColor3.B)
		end)
	end
end


-- DETECT THE MULTICOLOR BUTTON CLICK

SparklesCustomise.Multicolor.Activated:Connect(function()
	SparklesColor("Multicolor", nil, nil, nil, nil)
end)


-- DETECT THE PREVIEW SPARKLES COLOR BUTTON CLICK

SparklesCustomise.ColorSelected.Preview.Activated:Connect(function()
	if SparklesCustomise.ColorDisplay.UIGradient.Enabled == true then
		SparklesPreview("Multicolor", nil, nil, nil)
	else
		SparklesPreview(nil, SparklesCustomise.ColorDisplay.BackgroundColor3.R, SparklesCustomise.ColorDisplay.BackgroundColor3.G, SparklesCustomise.ColorDisplay.BackgroundColor3.B)
	end
end)


-- DETECT THE BUY COLOR SPARKLES BUTTON CLICK

SparklesCustomise.ColorSelected.Buy.Activated:Connect(function()
	if Sparkles:FindFirstChild("PetPreviewed") then
		Sparkles:FindFirstChild("PetPreviewed"):Destroy()
		for i,v in ipairs(Sparkles.PetPlacement:GetChildren()) do
			if v:IsA("Sparkles") then
				v:Destroy()
			end
		end
	end

	if SparklesCustomise.ColorDisplay.UIGradient.Enabled == true then
		table.insert(CustomisationTable["SparklesColor"], 1, "Multicolor")
		SparklesColor("Multicolor", "Buy", nil, nil, nil)
		CustomisationTable["Sparkles"] = "Multicolor"
		PetCustomisationRemoteEvent:FireServer("SparklesColor", "Buy", "Multicolor")
	else
		table.insert(CustomisationTable["SparklesColor"], 1, tostring(SparklesCustomise.ColorDisplay.BackgroundColor3))
		SparklesColor(nil, "Buy", SparklesCustomise.ColorDisplay.BackgroundColor3.R, SparklesCustomise.ColorDisplay.BackgroundColor3.G, SparklesCustomise.ColorDisplay.BackgroundColor3.B)
		CustomisationTable["Sparkles"] = tostring(SparklesCustomise.ColorDisplay.BackgroundColor3)
		PetCustomisationRemoteEvent:FireServer("SparklesColor", "Buy", CustomisationTable["Sparkles"])
	end
end)


-- PREVIEW THE RENAME COLOR

local function RenamePreview(Color, RenameR, RenameG, RenameB) -- see the trail functions for comments
	if RenameColor:FindFirstChild("PetPreviewed") then
		RenameColor:FindFirstChild("PetPreviewed"):Destroy()
	end

	local RenamePetClone = nil

	if EquippedPet.Value == "" then
		RenamePetClone = ReplicatedStorage.Pets.Common.Cat:Clone()
	else
		for i,v in ipairs(ReplicatedStorage.Pets:GetChildren()) do
			if v:FindFirstChild(EquippedPet.Value) then
				RenamePetClone = v:FindFirstChild(EquippedPet.Value):Clone()
				break
			end
		end
	end

	RenamePetClone.Parent = RenameColor
	RenamePetClone.Name = "PetPreviewed"
	RenamePetClone.PrimaryPart.Anchored = true
	RenamePetClone:SetPrimaryPartCFrame(RenameColor.PetPlacement.CFrame)

	if RenamePetClone:FindFirstChild("BillboardGui") then
		RenamePetClone:FindFirstChild("BillboardGui"):Destroy()
	end

	local BillboardGui = Instance.new("BillboardGui", RenamePetClone) -- show the name of the pet above it
	BillboardGui.Size = UDim2.new(10,0,0.8,0)
	BillboardGui.SizeOffset = Vector2.new(0,2)

	local TextLabel = Instance.new("TextLabel", BillboardGui)
	TextLabel.Size = UDim2.new(1,0,1,0)
	TextLabel.BackgroundTransparency = 1
	if EquippedPet.Value ~= "" then
		TextLabel.Text = lplr.Name.."'s "..EquippedPet.Value
	else
		TextLabel.Text = lplr.Name.."'s Cat"
	end
	TextLabel.TextScaled = true
	TextLabel.Font = Enum.Font.Cartoon

	if RenameR then
		TextLabel.TextColor3 = Color3.new(RenameR, RenameG, RenameB)
	else	
		if Color == "Multicolor" then
			local UIGradient = Instance.new("UIGradient", TextLabel)
			UIGradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
				ColorSequenceKeypoint.new(0.2, Color3.new(1,1,0)),
				ColorSequenceKeypoint.new(0.4, Color3.new(0,1,0)),
				ColorSequenceKeypoint.new(0.6, Color3.new(0,1,1)),
				ColorSequenceKeypoint.new(0.8, Color3.new(0,0,1)),
				ColorSequenceKeypoint.new(1, Color3.new(1,0,1))
			}
			TextLabel.TextColor3 = Color3.new(1,1,1)
		else
			TextLabel.TextColor3 = Color3.new(1,1,1) -- if previewed before buying the sprakles
		end
	end
end


-- BUY AND PREVIEW THE RENAME COLOR COLORS

local function SetRenameColor(Color, Type, R, G, B)
	if R ~= nil then
		if R ~= 1 and R ~= 0 then R = string.format("%." .. (6) .. "f", R) end
		if G ~= 1 and G ~= 0 then G = string.format("%." .. (6) .. "f", G) end
		if B ~= 1 and B ~= 0 then B = string.format("%." .. (6) .. "f", B) end
	end

	RenameCustomise.ColorDisplay.UIGradient.Enabled = false
	RenameCustomise.ColorSelected.Price.Text = "$25000"
	RenameCustomise.ColorDisplay.BackgroundColor3 = Color3.new(R,G,B)
	RenameCustomise.ColorSelected.Visible = true
	RenameCustomise.Owned.Visible = false

	if Color == "Multicolor" then
		if table.find(CustomisationTable["RenameColor"], "Multicolor") then
			RenameCustomise.ColorSelected.Visible = false
			RenameCustomise.ColorDisplay.BackgroundColor3 = Color3.new(1,1,1)
			RenameCustomise.ColorDisplay.UIGradient.Enabled = true
			RenameCustomise.Owned.Visible = true
			if Type ~= "Buy" then
				PetCustomisationRemoteEvent:FireServer("RenameColor", "Equip", "Multicolor")
			end

		else
			RenameCustomise.ColorSelected.Price.Text = "$40000"
			RenameCustomise.ColorDisplay.BackgroundColor3 = Color3.new(1,1,1)
			RenameCustomise.ColorDisplay.UIGradient.Enabled = true
		end
	end

	if R ~= nil then
		local FindRenameColor = nil
		FindRenameColor = table.find(CustomisationTable["RenameColor"], R..", "..G..", "..B)
		if FindRenameColor then
			RenameCustomise.ColorSelected.Visible = false
			RenameCustomise.Owned.Visible = true
			RenameCustomise.ColorSelected.Visible = false
			RenameCustomise.Owned.Visible = true
			if Type ~= "Buy" then
				PetCustomisationRemoteEvent:FireServer("RenameColor", "Equip", R..", "..G..", "..B)
			end
		end
	end
end


-- DETECT THE RENAME COLOR BUTTONS CLICK
for i,v in ipairs(RenameCustomise.ColorPicker:GetChildren()) do -- for all the pets that were already in the inventory
	if v:IsA("ImageButton") then
		v.Activated:Connect(function() -- get click on all the buttons
			SetRenameColor(nil, nil, v.BackgroundColor3.R, v.BackgroundColor3.G, v.BackgroundColor3.B)
		end)
	end
end


-- DETECT THE MULTICOLOR BUTTON CLICK

RenameCustomise.Multicolor.Activated:Connect(function()
	SetRenameColor("Multicolor", nil, nil, nil, nil)
end)


-- DETECT THE PREVIEW RENAME COLOR BUTTON CLICK

RenameCustomise.ColorSelected.Preview.Activated:Connect(function()
	if RenameCustomise.ColorDisplay.UIGradient.Enabled == true then
		RenamePreview("Multicolor", nil, nil, nil)
	else
		RenamePreview(nil, RenameCustomise.ColorDisplay.BackgroundColor3.R, RenameCustomise.ColorDisplay.BackgroundColor3.G, RenameCustomise.ColorDisplay.BackgroundColor3.B)
	end
end)


-- DETECT THE BUY COLOR RENAME BUTTON CLICK

RenameCustomise.ColorSelected.Buy.Activated:Connect(function()
	if RenameColor:FindFirstChild("PetPreviewed") then
		RenameColor:FindFirstChild("PetPreviewed"):Destroy()
	end

	if RenameCustomise.ColorDisplay.UIGradient.Enabled == true then
		table.insert(CustomisationTable["RenameColor"], 1, "Multicolor")
		SetRenameColor("Multicolor", "Buy", nil, nil, nil)
		CustomisationTable["RenameColorSelected"] = "Multicolor"
		PetCustomisationRemoteEvent:FireServer("RenameColor", "Buy", "Multicolor")
	else
		table.insert(CustomisationTable["RenameColor"], 1, tostring(RenameCustomise.ColorDisplay.BackgroundColor3))
		SetRenameColor(nil, "Buy", RenameCustomise.ColorDisplay.BackgroundColor3.R, RenameCustomise.ColorDisplay.BackgroundColor3.G, RenameCustomise.ColorDisplay.BackgroundColor3.B)
		CustomisationTable["RenameColorSelected"] = tostring(RenameCustomise.ColorDisplay.BackgroundColor3)
		PetCustomisationRemoteEvent:FireServer("RenameColor", "Buy", CustomisationTable["RenameColorSelected"])
	end
end)


-- BUY A PACK

PetShop.Pack.Board.SurfaceGui.Buy.Activated:Connect(function()
	for i,v in ipairs(PackColors:GetChildren()) do
		if v:IsA("Frame") then
			if v.Frame:FindFirstChild("UIGradient") then
				v.Frame:FindFirstChild("UIGradient"):Destroy()
			end
		end
	end

	PetCustomisationRemoteEvent:FireServer("Pack")

	PetsGui.Pack.Visible = true
	PetsGui.Pack:TweenPosition(UDim2.new(0.5,0,0.14,0), nil, nil, 0.5)
	wait(0.5)
end)


-- CLOSE THE PACK GUI

PetsGui.Pack.Close.MouseButton1Down:Connect(function()
	PetsGui.Pack:TweenPosition(UDim2.new(0.5,0,1.1,0), nil, nil, 0.5)
	wait(0.5)
	PetsGui.Pack.Visible = false
end)