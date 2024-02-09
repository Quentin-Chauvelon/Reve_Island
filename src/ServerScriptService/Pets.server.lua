local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

local ServerStorage = game:GetService("ServerStorage")
local PetSaveBindableEvent = ServerStorage:WaitForChild("PetSave")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local WarnBindableEvent = ServerStorage:WaitForChild("Warn")
local EquipPetBindableEvent = ServerStorage:WaitForChild("EquipPet")
local AbilitiesBindableEvent = ServerStorage:WaitForChild("Abilities")
local CasinoPetBindableFunction = ServerStorage:WaitForChild("CasinoPet")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EquipPet = ReplicatedStorage:WaitForChild("EquipPet")
local PetSaveRemoteFunction = ReplicatedStorage:WaitForChild("PetSave")
local PetCustomisationRemoteEvent = ReplicatedStorage:WaitForChild("PetCustomisation")
local PermanentAbilitiesRemoteEvent = ReplicatedStorage:WaitForChild("PermanentAbilities")

local Egg = workspace.PetShop.HachingRoom.Egg
local PetRarity = nil
local PlayerList = {}
local SizeProperties = {"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}

local debounce = false

-- TABLE WITH ALL THE PETS INFORMATIONS (NAME, RARITY, ABILITIES)

local InformationsTable = { 
	Alien = {
		"Alien",
		"Legendary",
		"Teleport back to spawn",
		"Control gravity"
	},
	Angel = {
		"Angel",
		"Legendary",
		"Fly (10s)",
		"Paradise (coming soon)" 
	},
	AquaDragon = {
		"Aqua dragon",
		"Legendary",
		"Fly (10s)",
		"Earn more money (x1,2)"
	},
	Bat = {
		"Bat",
		"Common",
		"Can stick to ceilings",
		""
	},
	Bear = {
		"Bear",
		"Common",
		"Bigger (x1,5)",
		""
	},
	Bee = {
		"Bee",
		"Common",
		"Fly (3s)",
		""
	},
	Bull = {
		"Bull",
		"Common",
		"Teleport to the mines",
		""
	},
	Bunny = {
		"Bunny",
		"Common",
		"Higher jump (x1,5)",
		""
	},
	Cat = {
		"Cat",
		"Common",
		"Night vision",
		"Faster (x1,05)"
	},
	Cow = {
		"Cow",
		"Common",
		"Earn more farming experience (x1,2)",
		""
	},
	Crab = {
		"Crab",
		"Common",
		"Teleport to the port",
		""
	},
	Demon = {
		"Demon",
		"Epic",
		"Acces to the hell",
		"Earn more money (x1,2)"
	},
	Dog = {
		"Dog",
		"Common",
		"Faster (x1,1)",
		""
	},
	Donut = {
		"Donut",
		"Rare",
		"More pizza chef experience (x1,2) (coming soon...)",
		"More delivery experience (x1,2)"
	},
	Duck = {
		"Duck",
		"Common",
		"Teleport to the lake",
		""
	},
	Fox = {
		"Fox",
		"Epic",
		"Cheaper cars (-10%)",
		"Spawn trampolines"
	},
	GoldenCat = {
		"Golden cat",
		"Rare",
		"Night vision",
		"Emits light"
	},
	Gumdrop = {
		"Gumdrop",
		"Rare",
		"More chances to win at jackpot machines (coming soon)",
		"Teleport to the casino"
	},
	HellishGolem = {
		"Hellish golem",
		"Common",
		"Can go to hell",
		""
	},
	IceGolem = {
		"Ice golem",
		"Rare",
		"Acces to the ice caves",
		"Spawn a skating rink"
	},
	Jellyfish = {
		"Jellyfish",
		"Rare",
		"Emits light",
		"Swims faster (x1.5)"
	},
	Koala = {
		"Koala",
		"Common",
		"Slower (x0,8)",
		"Earn more money (x1,05)"
	},
	LavaLord = {
		"Lava lord",
		"Common",
		"Immunity to lava",
		""
	},
	LightBat = {
		"Light bat",
		"Common",
		"Emits light",
		"Can stick to ceilings"
	},
	LightDemon = {
		"Light demon",
		"Common",
		"Access to the hell",
		"Emits light"
	},
	Lightning = {
		"Lightning",
		"Common",
		"Summon lightning",
		""
	},
	LittleCreature = {
		"Little creature",
		"Rare",
		"Teleport to your house",
		"Combine the 4 little pets (coming soon)"
	},
	LittleDemon = {
		"Little demon",
		"Rare",
		"Acces to the hell",
		"Combine the 4 little pets (coming soon)"
	},
	LittleDragon = {
		"Little dragon",
		"Rare",
		"Spits fire",
		"Combine the 4 little pets (coming soon)"
	},
	LittleSeaMonster = {
		"Little sea monster",
		"Rare",
		"Swim faster (x1,5)",
		"Combine the 4 little pets (coming soon)"
	},
	Monkey = {
		"Monkey",
		"Epic",
		"Faster (x1,2)",
		"Jump higher (x1,5)"
	},
	Monster = {
		"Monster",
		"Common",
		"Bigger (x2)",
		""
	},
	Mouse = {
		"Mouse",
		"Common",
		"Smaller (÷2)",
		""
	},
	MythicalDemon = {
		"Mythical demon",
		"Rare",
		"Access to the hell",
		"Throw firework"
	},
	Ninja = {
		"Ninja",
		"Rare",
		"Invisible (10s)",
		"Speed (x5 for 5s)"
	},
	Panda = {
		"Panda",
		"Common",
		"Teleport to forest",
		""
	},
	Pig = {
		"Pig",
		"Common",
		"Teleport to farms",
		""
	},
	PsychicScorpion = {
		"Psychic scorpion",
		"Epic",
		"Teleport to somewhere random",
		"Spawn trampolines"
	},
	Pumpkin = {
		"Pumpkin",
		"Rare",
		"Crops grow faster (10%)",
		"More farming experience (1,2)"
	},
	Reindeer = {
		"Reindeer",
		"Rare",
		"Fly at the mountain",
		"Teleport to the mountain"
	},
	Robot = {
		"Robot",
		"Rare",
		"coming soon",
		"Better rates when saving money (+0.0001%)"
	},
	Shark = {
		"Shark",
		"Common",
		"Swim faster (x1,5)",
		""
	},
	SkeletonDeer = {
		"Skeleton deer",
		"Common",
		"50% less likely to die",
		""
	},
	SkeletonPup = {
		"Skeleton pup",
		"Common",
		"50% less likely to die",
		""
	},
	Snowman = {
		"Snowman",
		"Common",
		"Throw snowballs",
		"Leave a snow trail behind you"
	},
	Star = {
		"Star",
		"Rare",
		"Emits light",
		"Shooting star"
	},
	Turkey = {
		"Turkey",
		"Rare",
		"Cheaper to upgrade house (-5%)",
		""
	},
	Wizard = {
		"Wizard",
		"Epic",
		"Gives a random effect",
		"Earn more money (x1,15)"
	},
}


-- RESET ALL ABILITIES

local function ResetAbilities(plr, Character)
	
	if Character then
		local Humanoid = Character:FindFirstChild("Humanoid")

		if Humanoid then
			Humanoid.WalkSpeed = 20
			Humanoid.JumpHeight = 7.2
			plr.Stats.MoneyMultiplier.Value = 1
			
			for _, property in pairs(SizeProperties) do
				if Humanoid:FindFirstChild(property) then
					Humanoid:FindFirstChild(property).Value = 1
				end
			end
		end
		
		PermanentAbilitiesRemoteEvent:FireClient(plr, Character, "Alien", false)
	end
end


-- FUNCTION TO ADD A POINT LIGHT TO THE PETS (THOSE WHICH HAVE THE ABILITY : EMITS LIGHT)

local function PetLight(Pet)
	if Pet and Pet:FindFirstChild("HitBox") then
		local Light = Instance.new("PointLight")
		Light.Brightness = 3
		Light.Range = 15
		Light.Parent = Pet:FindFirstChild("HitBox")
	end
end


-- SET THE ABILITIES EITHER WHEN THE PET IS EQUIPPED OR WHEN THE ABILITIES ARE REENABLED

local function EnableAbilities(plr, Character, Humanoid, NewPet)
		
	if plr and Character and Humanoid and NewPet then
		
		if NewPet == "Alien" then
			PermanentAbilitiesRemoteEvent:FireClient(plr, Character, "Alien", true)

		elseif NewPet == "AquaDragon" then
			plr.Stats.MoneyMultiplier.Value = 1.2

		elseif NewPet == "Bear" then
			for _, property in pairs(SizeProperties) do
				if Humanoid:FindFirstChild(property) then
					Humanoid:FindFirstChild(property).Value = 1.5
				end
			end

		elseif NewPet == "Bunny" then
			Humanoid.JumpHeight = 10.8

		elseif NewPet == "Cat" then
			Humanoid.WalkSpeed = 21
			PermanentAbilitiesRemoteEvent:FireClient(plr, Character, "Cat", true)

		elseif NewPet == "Dog" then
			Humanoid.WalkSpeed = 22

		elseif NewPet == "GoldenCat" then
			PetLight(Humanoid:FindFirstChild("GoldenCat"))
			PermanentAbilitiesRemoteEvent:FireClient(plr, Character, "GoldenCat", true)

		elseif NewPet == "Jellyfish" then
			PetLight(Humanoid:FindFirstChild("JellyFish"))
			
		elseif NewPet == "Koala" then
			Humanoid.WalkSpeed = 16
			plr.Stats.MoneyMultiplier.Value = 1.05

		elseif NewPet == "LightBat" then
			PetLight(Humanoid:FindFirstChild("LightBat"))
			
		elseif NewPet == "Monkey" then
			Humanoid.WalkSpeed = 24
			Humanoid.JumpHeight = 10.8

		elseif NewPet == "Monster" then
			for _, property in pairs(SizeProperties) do
				if Humanoid:FindFirstChild(property) then
					Humanoid:FindFirstChild(property).Value = 2
				end
			end

		elseif NewPet == "Mouse" then
			for _, property in pairs(SizeProperties) do
				if Humanoid:FindFirstChild(property) then
					Humanoid:FindFirstChild(property).Value = 0.5
				end
			end

		elseif NewPet == "Snowman" then
			
			if Character:FindFirstChild("LeftFoot") and Character:FindFirstChild("RightFoot") then
				local LeftAttachment = Instance.new("Attachment")
				LeftAttachment.Position = Vector3.new(-1,0,0)
				LeftAttachment.Name = "SnowmanAttachment"
				LeftAttachment.Parent = Character:FindFirstChild("LeftFoot")

				local RightAttachment = Instance.new("Attachment")
				RightAttachment.Position = Vector3.new(1,0,0)
				RightAttachment.Name = "SnowmanAttachment"
				RightAttachment.Parent = Character:FindFirstChild("RightFoot")

				local Trail = Instance.new("Trail")
				Trail.Name = "SnowmanTrail"
				Trail.Attachment0 = LeftAttachment
				Trail.Attachment1 = RightAttachment
				Trail.LightInfluence = 0
				Trail.Transparency = 0
				Trail.Lifetime = 5
				Trail.Parent = Character:FindFirstChild("LeftFoot")
			end

		elseif NewPet == "Star" then
			PetLight(Humanoid:FindFirstChild("Star"))

		elseif NewPet == "Wizard" then
			plr.Stats.MoneyMultiplier.Value = 1.15
		end
	end
end


-- CREATE THE TABLE FOR EACH PLAYER

Players.PlayerAdded:Connect(function(plr)
	PlayerList[plr.Name] = {}
	PlayerList[plr.Name]["OwnedPets"] = {}
	PlayerList[plr.Name]["Customisations"] = {
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
		RenameColor = {
			"1, 1, 1"
		}
	}
end)

Players.PlayerRemoving:Connect(function(plr)
	PlayerList[plr.Name] = nil
end)


-- GET SAVED PETS TABLE

PetSaveBindableEvent.Event:Connect(function(plr, Pickup, SavedPetsData, SavedCustomisationsData)	
	if Pickup == "PetsScript" then
		if SavedPetsData then -- if player has data
			PlayerList[plr.Name]["OwnedPets"] = SavedPetsData

			local PetsGui = plr.PlayerGui:WaitForChild("Pets"):WaitForChild("Frame")
			local Inventory = PetsGui:WaitForChild("Inventory")

			for i,v in ipairs(PlayerList[plr.Name]["OwnedPets"]) do
				local LoadPet = string.split(v,"|") -- saved data in the table is as follow : NumberOfTimePlayerHasTheSamePet|PetName
				local Number = LoadPet[1] -- string needs to be split into the number and the name
				local PetName = LoadPet[2]			

				-- add the pet to the inveotry
				local LoadInventory = Inventory.Template:Clone()
				LoadInventory.Name = PetName
				LoadInventory.Parent = Inventory.ScrollingFrame
				LoadInventory.PetName.Text = InformationsTable[PetName][1]
				LoadInventory.Rarity.Text = InformationsTable[PetName][2]
				LoadInventory.Ability1.Text = "- "..InformationsTable[PetName][3]
				LoadInventory.Ability2.Text = "- "..InformationsTable[PetName][4]
				
				local LoadPetRarity = InformationsTable[PetName][2]
				if LoadPetRarity == "Common" then -- change the sparkles color and the newpet gui rarity color based on the rarity
					LoadInventory.Rarity.TextColor3 = Color3.fromRGB(55, 138, 189)
				elseif LoadPetRarity == "Rare" then
					LoadInventory.Rarity.TextColor3 = Color3.fromRGB(32, 189, 45)
				elseif LoadPetRarity == "Epic" then
					LoadInventory.Rarity.TextColor3 = Color3.fromRGB(159, 68, 189)
				else
					LoadInventory.Rarity.TextColor3 = Color3.fromRGB(220, 147, 21)
				end
				
				local FindPet = nil
				for i,v in ipairs(ReplicatedStorage.Pets:GetChildren()) do
					FindPet = v:FindFirstChild(PetName)
					if FindPet then break end
				end
				
				local LoadPetClone = FindPet:Clone()
				LoadPetClone.Parent = LoadInventory.ViewportFrame

				local LoadPetCamera = Instance.new("Camera")
				LoadPetCamera.Name = "PetCamera"
				LoadPetCamera.CFrame = CFrame.new(LoadInventory.ViewportFrame[PetName].PrimaryPart.Position + LoadInventory.ViewportFrame[PetName].PrimaryPart.CFrame.LookVector * 3, LoadInventory.ViewportFrame[PetName].PrimaryPart.Position)
				LoadInventory.ViewportFrame.CurrentCamera = LoadPetCamera	
				LoadInventory.Visible = true
				LoadPetCamera.Parent = LoadInventory.ViewportFrame
				
				local LoadMultiple = Inventory.ScrollingFrame:FindFirstChild(PetName).Multiple.TextLabel
				LoadMultiple.Number.Value = tonumber(Number)
				LoadMultiple.Text = LoadMultiple.Number.Value
				if tonumber(Number) > 1 then	
					Inventory.ScrollingFrame:FindFirstChild(PetName).Multiple.Visible = true	
				end
			end
		end

		if SavedCustomisationsData then -- if player has customisations
			PlayerList[plr.Name]["Customisations"] = SavedCustomisationsData
		end
	end
end)


-- PLAYER OPENS AN EGG

local function PlayerOpensEgg(plr, Rarity, Script)
	
	print(Rarity)
	if Rarity and typeof(Rarity) == "string" and (Rarity == "Common" or Rarity == "Rare" or Rarity == "Epic" or Rarity == "Legendary") then
		local EnoughMoney
		if Script and typeof(Script) == "string" and Script == "Casino" then
			EnoughMoney = true
		else
			EnoughMoney = MoneyBindableFunction:Invoke(plr, workspace.PetShop.HachingRoom.Prices[Rarity].Value, "-")
		end
		
		if EnoughMoney == true then
			Egg.Sparkles.Enabled = false -- reset
			Egg.Size = Vector3.new(6, 7.633, 6)
			Egg.Position = workspace.PetShop.HachingRoom.PetPlacement.Position + Vector3.new(0,16.5,0)

			local RandomNumber = math.random(1,100) -- number to determine the rarity of the pet

			if Rarity == "Common" then -- choose the rarity of the pet depending on the rarity of the egg
				if RandomNumber <= 95 then
					PetRarity = "Common"
				else
					PetRarity = "Rare"
				end

			elseif Rarity == "Rare" then
				if RandomNumber <= 50 then
					PetRarity = "Common"
				elseif RandomNumber > 50 and RandomNumber <=95 then
					PetRarity = "Rare"
				else
					PetRarity = "Epic"
				end

			elseif Rarity == "Epic" then
				if RandomNumber <= 20 then
					PetRarity = "Common"
				elseif RandomNumber > 20 and RandomNumber <= 70 then
					PetRarity = "Rare"
				elseif RandomNumber > 70 and RandomNumber <= 95 then
					PetRarity = "Epic"
				else
					PetRarity = "Legendary"
				end

			elseif Rarity == "Legendary" then
				if RandomNumber <= 30 then
					PetRarity = "Rare"
				elseif RandomNumber > 30 and RandomNumber <= 80 then
					PetRarity = "Epic"
				else
					PetRarity = "Legendary"
				end
			end

			local PetsGui = plr.PlayerGui.Pets.Frame
			local Inventory = PetsGui.Inventory

			if PetRarity == "Common" then -- change the sparkles color and the newpet gui rarity color based on the rarity
				Egg.Sparkles.SparkleColor = Color3.fromRGB(55, 138, 189)
				PetsGui.NewPet.PetInformation.Rarity.Text = "Common"
				PetsGui.NewPet.PetInformation.Rarity.TextColor3 = Color3.fromRGB(55, 138, 189)
			elseif PetRarity == "Rare" then
				Egg.Sparkles.SparkleColor = Color3.fromRGB(32, 189, 45)
				PetsGui.NewPet.PetInformation.Rarity.Text = "Rare"
				PetsGui.NewPet.PetInformation.Rarity.TextColor3 = Color3.fromRGB(32, 189, 45)
			elseif PetRarity == "Epic" then
				Egg.Sparkles.SparkleColor = Color3.fromRGB(159, 68, 189)
				PetsGui.NewPet.PetInformation.Rarity.Text = "Epic"
				PetsGui.NewPet.PetInformation.Rarity.TextColor3 = Color3.fromRGB(159, 68, 189)
			else
				Egg.Sparkles.SparkleColor = Color3.fromRGB(220, 147, 21)
				PetsGui.NewPet.PetInformation.Rarity.Text = "Legendary"
				PetsGui.NewPet.PetInformation.Rarity.TextColor3 = Color3.fromRGB(220, 147, 21)
			end

			local PetFolder = ReplicatedStorage:WaitForChild("Pets"):FindFirstChild(PetRarity)
			if PetFolder then
				local PetList = PetFolder:GetChildren()
				local ChosenPet = PetList[math.random(1, #PetList)]
				if ChosenPet then

					-- ADD PET TO THE INVENTORY
					if not Inventory.ScrollingFrame:FindFirstChild(ChosenPet.Name) then
						local PetInventory = Inventory.Template:Clone()
						PetInventory.Name = ChosenPet.Name
						PetInventory.Parent = Inventory.ScrollingFrame
						PetInventory.PetName.Text = InformationsTable[ChosenPet.Name][1]
						PetInventory.Rarity.Text = PetRarity
						PetInventory.Ability1.Text = "- "..InformationsTable[ChosenPet.Name][3]
						PetInventory.Ability2.Text = "- "..InformationsTable[ChosenPet.Name][4]
						if PetRarity == "Common" then -- change the sparkles color and the newpet gui rarity color based on the rarity
							PetInventory.Rarity.TextColor3 = Color3.fromRGB(55, 138, 189)
						elseif PetRarity == "Rare" then
							PetInventory.Rarity.TextColor3 = Color3.fromRGB(32, 189, 45)
						elseif PetRarity == "Epic" then
							PetInventory.Rarity.TextColor3 = Color3.fromRGB(159, 68, 189)
						else
							PetInventory.Rarity.TextColor3 = Color3.fromRGB(220, 147, 21)
						end
						local Pet = ChosenPet:Clone()
						Pet.Parent = workspace
						Pet.Parent = PetInventory.ViewportFrame

						local PetCamera  = Instance.new("Camera")
						PetCamera.Name = "PetCamera"
						PetCamera.Parent = PetInventory.ViewportFrame
						PetCamera.CFrame = CFrame.new(PetInventory.ViewportFrame[Pet.Name].PrimaryPart.Position + PetInventory.ViewportFrame[Pet.Name].PrimaryPart.CFrame.LookVector *3, PetInventory.ViewportFrame[Pet.Name].PrimaryPart.Position)
						PetInventory.ViewportFrame.CurrentCamera = PetCamera

						PetInventory.Visible = true
						PetInventory.Multiple.TextLabel.Number.Value = PetInventory.Multiple.TextLabel.Number.Value + 1
					end


					-- ADD THE PET TO THE TABLE

					local Multiple = Inventory.ScrollingFrame[ChosenPet.Name].Multiple.TextLabel.Number

					local AlreadyOwnedPet = table.find(PlayerList[plr.Name]["OwnedPets"], Multiple.Value.."|"..ChosenPet.Name)
					if AlreadyOwnedPet then
						Multiple.Value = Multiple.Value + 1
						PlayerList[plr.Name]["OwnedPets"][AlreadyOwnedPet] = Multiple.Value.."|"..ChosenPet.Name
						Inventory.ScrollingFrame[ChosenPet.Name].Multiple.TextLabel.Text = Multiple.Value
						Inventory.ScrollingFrame[ChosenPet.Name].Multiple.Visible = true
					else
						table.insert(PlayerList[plr.Name]["OwnedPets"], 1, Multiple.Value.."|"..ChosenPet.Name)
					end

					PetSaveBindableEvent:Fire(plr, "DatastoreScript", "Pet", PlayerList[plr.Name]["OwnedPets"])
					return ChosenPet, PetRarity
				end
			end
		end
	end
end

PetSaveRemoteFunction.OnServerInvoke = PlayerOpensEgg
CasinoPetBindableFunction.OnInvoke = PlayerOpensEgg


-- PLAYER CUSTOMISES HIS PET

PetCustomisationRemoteEvent.OnServerEvent:Connect(function(plr, CustomisationType, Param1, Param2, Param3)
	--while debounce do -- wait for the function to finish running
	--	wait(0.1)
	--end
	
	if not debounce then
		debounce = true

		local Character = workspace:FindFirstChild(plr.Name) -- get the player character
		local Pet = nil
		if Character:FindFirstChild(plr.PetCustomisations.EquippedPet.Value) then -- get the player's pet if he has one equipped
			Pet = Character:FindFirstChild(plr.PetCustomisations.EquippedPet.Value)
		end


		-- EQUIP

		if CustomisationType == "Equip" then
			local NewPet = Param1
			local OldPet = PlayerList[plr.Name]["Customisations"]["Equipped"]
			
			if OldPet then
				if not workspace[plr.Name]:FindFirstChild(OldPet) then
					OldPet = ""
				end
			end
			
			local PetRarity = Param3
			
			if typeof(NewPet) == "string" and typeof(PetRarity) == "string" then
				if plr.PlayerGui:WaitForChild("Pets"):WaitForChild("Frame"):WaitForChild("Inventory"):WaitForChild("ScrollingFrame"):FindFirstChild(NewPet) then -- if player onws the pet he tries to equip
					
					if NewPet == OldPet then -- if player is equipping the same pet (so actually unequipping)
						plr.PetCustomisations.EquippedPet.Value = "" -- remove the pet from the equipped pet value
						PlayerList[plr.Name]["Customisations"]["Equipped"] = ""
						--EquipPetBindableEvent:Fire(plr, nil, OldPet) -- fire the event for the abilities

					else
						plr.PetCustomisations.EquippedPet.Value = NewPet -- set the new pet to the equipped pet value
						PlayerList[plr.Name]["Customisations"]["Equipped"] = NewPet
						
						EquipPetBindableEvent:Fire(plr, NewPet, OldPet) -- fire the event for the abilities
					end

					local Character = workspace:FindFirstChild(plr.Name) -- get the player character

					if Character.HumanoidRootPart:FindFirstChild("CharacterAttachment") then -- if player has an attachment for a pet, then remove it
						Character.HumanoidRootPart:FindFirstChild("CharacterAttachment"):Destroy()
					end

					if OldPet then -- if player already had a pet equipped, then remove it
						if Character:FindFirstChild(OldPet) then	
							Character:FindFirstChild(OldPet):Destroy()
						end
						
						ResetAbilities(plr, Character)
					end

					if NewPet ~= OldPet then -- if the player is not equipping the same pet

						local NewPetClone = ReplicatedStorage.Pets[PetRarity][NewPet]:Clone() -- clone the pet
						NewPetClone:SetPrimaryPartCFrame(Character.HumanoidRootPart.CFrame) -- set its cframe to the player
						
						local ModelSize = NewPetClone.PrimaryPart.Size -- get the size of the pet (to move it further from the player if it's bigger, and closer if it's smaller)

						local CharacterAttachment = Instance.new("Attachment", Character.HumanoidRootPart) -- create an attachment in the player
						CharacterAttachment.Visible = false
						CharacterAttachment.Name = "CharacterAttachment"
						CharacterAttachment.Position = Vector3.new(3,1,0) + ModelSize

						local PetAttachment = Instance.new("Attachment", NewPetClone.PrimaryPart) -- create an attachment in the pet
						PetAttachment.Visible = false

						local AlignPosition = Instance.new("AlignPosition", NewPetClone) -- align the position of the pet to the player
						AlignPosition.MaxForce = 7500
						AlignPosition.Attachment0 = PetAttachment
						AlignPosition.Attachment1 = CharacterAttachment
						AlignPosition.Responsiveness = 50

						local AlignOrientation = Instance.new("AlignOrientation", NewPetClone) -- align the orientation of the pet to the player
						AlignOrientation.MaxTorque = 2000
						AlignOrientation.Attachment0 = PetAttachment
						AlignOrientation.Attachment1 = CharacterAttachment
						AlignOrientation.Responsiveness = 100

						local PetNameDisplay = Instance.new("BillboardGui", NewPetClone) -- show the name of the pet above it
						PetNameDisplay.Size = UDim2.new(10,0,0.8,0)
						PetNameDisplay.SizeOffset = Vector2.new(0,2)

						local TextLabel = Instance.new("TextLabel", PetNameDisplay) -- create the pet name gui
						TextLabel.Size = UDim2.new(1,0,1,0)
						TextLabel.BackgroundTransparency = 1
						if plr.PetCustomisations.PetName.Value ~= "" then
							TextLabel.Text = plr.PetCustomisations.PetName.Value
						else
							TextLabel.Text = plr.Name.."'s "..NewPet
						end
						TextLabel.TextScaled = true
						TextLabel.Font = Enum.Font.Cartoon

						if TextLabel:FindFirstChild("UIGradient") then
							TextLabel:FindFirstChild("UIGradient"):Destroy()
						end

						if plr.PetCustomisations.MulticolorRename.Value == true then -- create the color for the name
							TextLabel.TextColor3 = Color3.new(1,1,1)
							local UIGradient = Instance.new("UIGradient", TextLabel)
							UIGradient.Color = ColorSequence.new{
								ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
								ColorSequenceKeypoint.new(0.2, Color3.new(1,1,0)),
								ColorSequenceKeypoint.new(0.4, Color3.new(0,1,0)),
								ColorSequenceKeypoint.new(0.6, Color3.new(0,1,1)),
								ColorSequenceKeypoint.new(0.8, Color3.new(0,0,1)),
								ColorSequenceKeypoint.new(1, Color3.new(1,0,1))
							}
						else
							TextLabel.TextColor3 = plr.PetCustomisations.RenameColor.Value
						end

						NewPetClone.Parent = Character -- parent the pet to the player
						
						local Humanoid = Character:FindFirstChild("Humanoid")
						if Humanoid then
														
							-- DISABLE PERMANENT ABILITIES

							if NewPet == "Alien" then
								PermanentAbilitiesRemoteEvent:FireClient(plr, Character, NewPet, false)

							elseif NewPet == "GoldenCat" or NewPet == "Jellyfish"
							or NewPet == "LightBat" or NewPet == "Star" then
								if Humanoid:FindFirstChild(NewPet) and Humanoid:FindFirstChild(NewPet).HitBox:FindFirstChild("PointLight") then
									Humanoid:FindFirstChild(NewPet).HitBox:FindFirstChild("PointLight"):Destroy()
								end	
								
							elseif NewPet == "Snowman" then
								-- Destroy the attachments and the trail
								if Character:FindFirstChild("LeftFoot") then
									if Character:FindFirstChild("LeftFoot"):FindFirstChild("SnowmanAttachment") then
										Character:FindFirstChild("LeftFoot"):FindFirstChild("SnowmanAttachment"):Destroy()
									end
									if Character:FindFirstChild("LeftFoot"):FindFirstChild("SnowmanTrail") then
										Character:FindFirstChild("LeftFoot"):FindFirstChild("SnowmanTrail"):Destroy()
									end
								end

								if Character:FindFirstChild("RightFoot") and Character:FindFirstChild("RightFoot"):FindFirstChild("SnowmanAttachment") then
									Character:FindFirstChild("RightFoot"):FindFirstChild("SnowmanAttachment"):Destroy()
								end
							end

							-- SET PERMANENT ABILITIES								
							
							-- If the player doesn't have his abilities disabled
							if not plr.PetAbilitiesDisabled.Value then
								
								EnableAbilities(plr, Character, Humanoid, NewPet)
							end
						end


						-- IF PLAYER OWNS THE TRAIL

						if plr.PetCustomisations.Trail.Value == true then
							local Attachment0 = Instance.new("Attachment") -- create the two attachments and the trail
							Attachment0.Position = Vector3.new(0,1,0)
							Attachment0.Parent = workspace:WaitForChild(plr.Name):WaitForChild(NewPet).PrimaryPart

							local Attachment1 = Instance.new("Attachment") -- create the attachments for the trail
							Attachment1.Position = Vector3.new(0,-1,0)
							Attachment1.Parent = workspace[plr.Name][NewPet].PrimaryPart

							local CreateTrail = Instance.new("Trail", workspace[plr.Name][NewPet].PrimaryPart)
							CreateTrail.Lifetime = 1
							CreateTrail.Attachment0 = Attachment0
							CreateTrail.Attachment1 = Attachment1

							if plr.PetCustomisations.MulticolorTrail.Value == true then -- if player has equipped the multicolor trail
								workspace[plr.Name][NewPet].PrimaryPart.Trail.Color = ColorSequence.new{ -- multicolor color sequence
									ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
									ColorSequenceKeypoint.new(0.2, Color3.new(1,1,0)),
									ColorSequenceKeypoint.new(0.4, Color3.new(0,1,0)),
									ColorSequenceKeypoint.new(0.6, Color3.new(0,1,1)),
									ColorSequenceKeypoint.new(0.8, Color3.new(0,0,1)),
									ColorSequenceKeypoint.new(1, Color3.new(1,0,1))
								}
							else
								local TrailTable = string.split(tostring(plr.PetCustomisations.TrailColor.Value), ",") -- if player has equipped a unicolor trail
								CreateTrail.Color = ColorSequence.new(Color3.new(TrailTable[1], TrailTable[2], TrailTable[3])) -- change the color sequence to the color
								plr.PetCustomisations.MulticolorTrail.Value = false -- change the value to know that it's not a multicolor trail
							end
						end


						-- IF PLAYER OWNS THE SPARKLES

						if plr.PetCustomisations.Sparkles.Value == true then

							for i,v in ipairs(workspace[plr.Name][NewPet].PrimaryPart:GetChildren()) do
								if v:IsA("Sparkles") then
									v:Destroy()
								end
							end

							local CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][NewPet].PrimaryPart)

							if plr.PetCustomisations.MulticolorSparkles.Value == true then -- if player has equipped the multicolor sparkles
								CreateSparkles.SparkleColor = Color3.new(1,0,0)

								CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][NewPet].PrimaryPart)
								CreateSparkles.SparkleColor = Color3.new(1,1,0)

								CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][NewPet].PrimaryPart)
								CreateSparkles.SparkleColor = Color3.new(0,1,0)

								CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][NewPet].PrimaryPart)
								CreateSparkles.SparkleColor = Color3.new(0,1,1)

								CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][NewPet].PrimaryPart)
								CreateSparkles.SparkleColor = Color3.new(0,0,1)

								CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][NewPet].PrimaryPart)
								CreateSparkles.SparkleColor = Color3.new(1,0,1)
							else
								local SparklesTable = string.split(tostring(plr.PetCustomisations.SparklesColor.Value), ",")-- if player has equipped a unicolor sparkles
								CreateSparkles.SparkleColor = Color3.new(SparklesTable[1], SparklesTable[2], SparklesTable[3]) -- change the color sequence to the color
								plr.PetCustomisations.MulticolorSparkles.Value = false -- change the value to know that it's not a multicolor sparkles
							end
						end
					end
					PetSaveBindableEvent:Fire(plr, "DatastoreScript", "Customisation", PlayerList[plr.Name]["Customisations"])
				else WarnBindableEvent:Fire(plr, "Important", "is trying to equip a pet that he doesn't own, pet : "..NewPet, "Pets", os.time()) end
			else WarnBindableEvent:Fire(plr, "Normal", "is firing the customisation  remote event with unexpected types of value (NewPet : "..NewPet..", PetRarity : "..PetRarity..")", "Pets", os.time()) end

			-- RENAME

		elseif CustomisationType == "Rename" then
			
			coroutine.wrap(function()
				local PetName = Param1

				if typeof(PetName) == "string" then	

					--local FilteredName = ""
					local success, FilteredResult = pcall(function() -- filter text to detect inappropriate names
						return TextService:FilterStringAsync(PetName, plr.UserId)
					end)
					
					coroutine.wrap(function()
						if success then
							local FilteredName = FilteredResult:GetNonChatStringForBroadcastAsync()

							if PetName == FilteredName then -- check if the name is appropriate (if it has been filtered)

								if string.len(PetName) < 20 then

									local EnoughMoney = MoneyBindableFunction:Invoke(plr, 20000, "-")
									if EnoughMoney == true then

										plr.PetCustomisations.PetName.Value = FilteredName
										if Pet then
											Pet.BillboardGui.TextLabel.Text = FilteredName
										end
										PlayerList[plr.Name]["Customisations"]["Rename"] = FilteredName -- change the name in the table
										PetSaveBindableEvent:Fire(plr, "DatastoreScript", "Customisation", PlayerList[plr.Name]["Customisations"]) -- save the customisations table
									end
								else
									plr.PlayerGui.Pets.RenameGui.PetName.Text = "This name is too long, please choose another one."
									wait(8)
									plr.PlayerGui.Pets.RenameGui.PetName.Text = "Enter your pet's name here"
								end

							else
								plr.PlayerGui.Pets.RenameGui.PetName.Text = "This name can't be used, please choose another one."
								wait(8)
								plr.PlayerGui.Pets.RenameGui.PetName.Text = "Enter your pet's name here"
							end

						else
							plr.PlayerGui.Pets.RenameGui.PetName.Text = "Your name couldn't be filtered, please retry in a few minutes."
							wait(8)
							plr.PlayerGui.Pets.RenameGui.PetName.Text = "Enter your pet's name here"
						end
					end)()
						
				else WarnBindableEvent:Fire(plr, "Normal", "is firing the customisation  remote event with unexpected types of value (PetName : "..PetName..")", "Pets", os.time()) end
			end)()


			-- UNLOCK TRAIL

		elseif CustomisationType == "Trail" then

			if not PlayerList[plr.Name]["Customisations"]["Trail"] then -- if player didn't already bought the trail
				local EnoughMoney = MoneyBindableFunction:Invoke(plr, 50000, "-")
				if EnoughMoney == true then

					plr.PetCustomisations.Trail.Value = true -- change the trail value
					PlayerList[plr.Name]["Customisations"]["Trail"] = "1, 1, 1" -- change the trail value in the table
					PetSaveBindableEvent:Fire(plr, "DatastoreScript", "Customisation", PlayerList[plr.Name]["Customisations"]) -- save customisations table
					local EquippedPet = PlayerList[plr.Name]["Customisations"]["EquippedPet"]

					if EquippedPet and EquippedPet ~= "" then				
						if workspace[plr.Name]:FindFirstChild(EquippedPet).PrimaryPart:FindFirstChild("Trail") then
							local Attachment0 = Instance.new("Attachment") -- create the attachments and the trail
							Attachment0.Position = Vector3.new(0,1,0)
							Attachment0.Parent = workspace[plr.Name]:FindFirstChild(EquippedPet).PrimaryPart

							local Attachment1 = Instance.new("Attachment")
							Attachment1.Position = Vector3.new(0,-1,0)
							Attachment1.Parent = workspace[plr.Name]:FindFirstChild(EquippedPet).PrimaryPart

							local CreateTrail = Instance.new("Trail", workspace[plr.Name]:FindFirstChild(EquippedPet).PrimaryPart)
							CreateTrail.Lifetime = 1
							CreateTrail.Attachment0 = Attachment0
							CreateTrail.Attachment1 = Attachment1

							workspace[plr.Name]:FindFirstChild(EquippedPet).PrimaryPart.Trail.Color = ColorSequence.new(Color3.new(1,1,1)) -- make the trail white
						end
					end
				end
			end

			-- UNLOCK TRAIL COLOR

		elseif CustomisationType == "TrailColor" then

			local Type = Param1
			local Color = Param2

			if PlayerList[plr.Name]["Customisations"]["Trail"] and PlayerList[plr.Name]["Customisations"]["Trail"] ~= false then -- if player alredy bought the trail
				if typeof(Color) == "string" then

					local EquippedPet = PlayerList[plr.Name]["Customisations"]["Equipped"]

					if Color == "Multicolor" then

						if Type == "Buy" then -- if player is buying the trail					
							local EnoughMoney = MoneyBindableFunction:Invoke(plr, 35000, "-")
							if EnoughMoney == true then

								if EquippedPet and EquippedPet ~= "" then
									workspace[plr.Name]:FindFirstChild(EquippedPet).PrimaryPart.Trail.Color = ColorSequence.new{ -- create the gradient for the multicolor trail
										ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
										ColorSequenceKeypoint.new(0.2, Color3.new(1,1,0)),
										ColorSequenceKeypoint.new(0.4, Color3.new(0,1,0)),
										ColorSequenceKeypoint.new(0.6, Color3.new(0,1,1)),
										ColorSequenceKeypoint.new(0.8, Color3.new(0,0,1)),
										ColorSequenceKeypoint.new(1, Color3.new(1,0,1))
									}
								end

								PlayerList[plr.Name]["Customisations"]["Trail"] = "Multicolor" -- change the trail value in the table
								table.insert(PlayerList[plr.Name]["Customisations"]["TrailColor"], 1, "Multicolor") -- add the color to the trail color in the table
								plr.PetCustomisations.MulticolorTrail.Value = true
								plr.PetCustomisations.TrailColor.Value = Color3.new(1,1,1) -- change the trail to white, otherwise the gradient wouldn't work
							end

						elseif Type == "Equip" then -- if player already own the trail and is equipping it
							if table.find(PlayerList[plr.Name]["Customisations"]["TrailColor"], "Multicolor") then

								if EquippedPet and EquippedPet ~= "" then
									workspace[plr.Name]:FindFirstChild(EquippedPet).PrimaryPart.Trail.Color = ColorSequence.new{ -- create the gradient for the multicolor trail
										ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
										ColorSequenceKeypoint.new(0.2, Color3.new(1,1,0)),
										ColorSequenceKeypoint.new(0.4, Color3.new(0,1,0)),
										ColorSequenceKeypoint.new(0.6, Color3.new(0,1,1)),
										ColorSequenceKeypoint.new(0.8, Color3.new(0,0,1)),
										ColorSequenceKeypoint.new(1, Color3.new(1,0,1))
									}
								end

								PlayerList[plr.Name]["Customisations"]["Trail"] = "Multicolor" -- change the trail value in the table
								plr.PetCustomisations.MulticolorTrail.Value = true
								plr.PetCustomisations.TrailColor.Value = Color3.new(1,1,1) -- change the trail to white, otherwise the gradient wouldn't work
							end
						else WarnBindableEvent:Fire(plr, "Normal", "is firing the trail customisation remote event with an unexpected type ("..Type.." instead of buy or equip)", "Pets", os.time()) end

					else -- if player is buying an unicolor trail

						local TrailTable = string.split(Color, ",") -- get the color by splitting the string
						if #TrailTable == 3 then
							local R = math.floor(tonumber((TrailTable[1] * 255) + 0.5))
							local G = math.floor(tonumber((TrailTable[2] * 255) + 0.5))
							local B = math.floor(tonumber((TrailTable[3] * 255) + 0.5))

							if workspace.PetShop.Trail.Board.SurfaceGui.Customise.ColorPicker:FindFirstChild(tostring(R..","..G..","..B)) then

								if Type == "Buy" then -- if player is buying the trail					

									local EnoughMoney = MoneyBindableFunction:Invoke(plr, 10000, "-")
									if EnoughMoney == true then
										if EquippedPet and EquippedPet ~= "" and workspace[plr.Name]:FindFirstChild(EquippedPet).HitBox:FindFirstChild("Trail") then
											workspace[plr.Name]:FindFirstChild(EquippedPet):FindFirstChild("HitBox").Trail.Color = ColorSequence.new(Color3.new(TrailTable[1], TrailTable[2], TrailTable[3]))
										end

										PlayerList[plr.Name]["Customisations"]["Trail"] = Color -- change the trail value in the table
										table.insert(PlayerList[plr.Name]["Customisations"]["TrailColor"], 1, Color) -- add the color to the trail color in the table
										plr.PetCustomisations.TrailColor.Value = Color3.new(TrailTable[1], TrailTable[2], TrailTable[3])	
										plr.PetCustomisations.MulticolorTrail.Value = false	
									end
									
								elseif Type == "Equip" then -- if player already own the trail and is equipping it
									if table.find(PlayerList[plr.Name]["Customisations"]["TrailColor"], Color) then

										if EquippedPet and EquippedPet ~= "" and workspace[plr.Name][EquippedPet].HitBox:FindFirstChild("Trail") then
											workspace[plr.Name]:FindFirstChild(EquippedPet):FindFirstChild("HitBox"):FindFirstChild("Trail").Color = ColorSequence.new(Color3.new(TrailTable[1], TrailTable[2], TrailTable[3]))
										end

										PlayerList[plr.Name]["Customisations"]["Trail"] = Color -- change the trail value in the table
										plr.PetCustomisations.TrailColor.Value = Color3.new(TrailTable[1], TrailTable[2], TrailTable[3])	
										plr.PetCustomisations.MulticolorTrail.Value = false	
									end
								else WarnBindableEvent:Fire(plr, "Normal", "is firing the trail customisation remote event with an unexpected type ("..Type.." instead of buy or equip)", "Pets", os.time()) end
							else WarnBindableEvent:Fire(plr, "Important", "is firing the trail customisation remote event with a color which is not supposed to be used (Color : "..Color..")", "Pets", os.time()) end
						else WarnBindableEvent:Fire(plr, "Important", "is firing the trail customisation remote event with an unexpected color (Color : "..Color..")", "Pets", os.time()) end
					end

					PetSaveBindableEvent:Fire(plr, "DatastoreScript", "Customisation", PlayerList[plr.Name]["Customisations"]) -- save customisations table

				else WarnBindableEvent:Fire(plr, "Normal", "is firing the trail customisation remote event with unexpected types of value (Color : "..Color..")", "Pets", os.time()) end
			end


			-- UNLOCK SPARKLES

		elseif CustomisationType == "Sparkles" then

			if not PlayerList[plr.Name]["Customisations"]["Sparkles"] then
				local EnoughMoney = MoneyBindableFunction:Invoke(plr, 50000, "-")
				if EnoughMoney then

					plr.PetCustomisations.Sparkles.Value = true -- unlock the sparkles
					PlayerList[plr.Name]["Customisations"]["Sparkles"] = "1, 1, 1" -- change the sparkles value in the table
					PetSaveBindableEvent:Fire(plr, "DatastoreScript", "Customisation", PlayerList[plr.Name]["Customisations"]) -- save customisations table
					local EquippedPet = PlayerList[plr.Name]["Customisations"]["EquippedPet"]

					if EquippedPet and EquippedPet ~= "" then
						local CreateSparkles = Instance.new("Sparkles", workspace[plr.Name]:FindFirstChild(EquippedPet).PrimaryPart) -- create the sparkles
						CreateSparkles.SparkleColor = Color3.new(1,0,0)
					end
				end
			end			


			-- UNLOCK SPARKLES COLOR

		elseif CustomisationType == "SparklesColor" then

			local Type = Param1
			local Color = Param2

			if PlayerList[plr.Name]["Customisations"]["Sparkles"] and PlayerList[plr.Name]["Customisations"]["Sparkles"] ~= false then
				if typeof(Color) == "string" then

					local EquippedPet = PlayerList[plr.Name]["Customisations"]["Equipped"]

					if Color == "Multicolor" then

						if Type == "Buy" then -- if player is buying the trail

							local EnoughMoney = MoneyBindableFunction:Invoke(plr, 35000, "-")
							if EnoughMoney == true then

								if EquippedPet and EquippedPet ~= "" then

									for i,v in ipairs(workspace[plr.Name]:FindFirstChild(EquippedPet).PrimaryPart:GetChildren()) do -- delete all sparkles
										if v:IsA("Sparkles") then
											v:Destroy()
										end
									end

									local CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][plr.PetCustomisations.EquippedPet.Value].PrimaryPart)
									CreateSparkles.SparkleColor = Color3.new(1,0,0)

									CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][plr.PetCustomisations.EquippedPet.Value].PrimaryPart)
									CreateSparkles.SparkleColor = Color3.new(1,1,0)

									CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][plr.PetCustomisations.EquippedPet.Value].PrimaryPart)
									CreateSparkles.SparkleColor = Color3.new(0,1,0)

									CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][plr.PetCustomisations.EquippedPet.Value].PrimaryPart)
									CreateSparkles.SparkleColor = Color3.new(0,1,1)

									CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][plr.PetCustomisations.EquippedPet.Value].PrimaryPart)
									CreateSparkles.SparkleColor = Color3.new(0,0,1)

									CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][plr.PetCustomisations.EquippedPet.Value].PrimaryPart)
									CreateSparkles.SparkleColor = Color3.new(1,0,1)
								end

								PlayerList[plr.Name]["Customisations"]["Sparkles"] = "Multicolor" -- change the sparkles value in the table
								table.insert(PlayerList[plr.Name]["Customisations"]["SparklesColor"], 1, "Multicolor") -- add the color to the sparkles color in the table
								plr.PetCustomisations.MulticolorSparkles.Value = true
								plr.PetCustomisations.SparklesColor.Value = Color3.new(1,1,1)

							end
						elseif Type == "Equip" then
							if table.find(PlayerList[plr.Name]["Customisations"]["TrailColor"], "Multicolor") then

								if EquippedPet and EquippedPet ~= "" then

									for i,v in ipairs(workspace[plr.Name]:FindFirstChild(EquippedPet).PrimaryPart:GetChildren()) do -- delete all sparkles
										if v:IsA("Sparkles") then
											v:Destroy()
										end
									end

									local CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][plr.PetCustomisations.EquippedPet.Value].PrimaryPart)
									CreateSparkles.SparkleColor = Color3.new(1,0,0)

									CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][plr.PetCustomisations.EquippedPet.Value].PrimaryPart)
									CreateSparkles.SparkleColor = Color3.new(1,1,0)

									CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][plr.PetCustomisations.EquippedPet.Value].PrimaryPart)
									CreateSparkles.SparkleColor = Color3.new(0,1,0)

									CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][plr.PetCustomisations.EquippedPet.Value].PrimaryPart)
									CreateSparkles.SparkleColor = Color3.new(0,1,1)

									CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][plr.PetCustomisations.EquippedPet.Value].PrimaryPart)
									CreateSparkles.SparkleColor = Color3.new(0,0,1)

									CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][plr.PetCustomisations.EquippedPet.Value].PrimaryPart)
									CreateSparkles.SparkleColor = Color3.new(1,0,1)
								end

								PlayerList[plr.Name]["Customisations"]["Sparkles"] = "Multicolor" -- change the sparkles value in the table
								plr.PetCustomisations.MulticolorSparkles.Value = true
								plr.PetCustomisations.SparklesColor.Value = Color3.new(1,1,1)
							end

						else WarnBindableEvent:Fire(plr, "Normal", "is firing the sparkles customisation remote event with an unexpected type ("..Type.." instead of buy or equip)", "Pets", os.time()) end

					else -- if player is buying an unicolor trail
						local SparklesTable = string.split(Color, ",")
						if #SparklesTable == 3 then
							local R = math.floor(tonumber((SparklesTable[1] * 255) + 0.5))
							local G = math.floor(tonumber((SparklesTable[1] * 255) + 0.5))
							local B = math.floor(tonumber((SparklesTable[1] * 255) + 0.5))

							if workspace.PetShop.Sparkles.Board.SurfaceGui.Customise.ColorPicker:FindFirstChild(tostring(R..","..G..","..B)) then

								if Type == "Buy" then -- if player is buying the trail

									local EnoughMoney = MoneyBindableFunction:Invoke(plr, 10000, "-")
									if EnoughMoney == true then
										if EquippedPet and EquippedPet ~= "" then

											for i,v in ipairs(workspace[plr.Name]:FindFirstChild(EquippedPet).PrimaryPart:GetChildren()) do -- delete all sparkles
												if v:IsA("Sparkles") then
													v:Destroy()
												end
											end

											local CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][plr.PetCustomisations.EquippedPet.Value].PrimaryPart)
											CreateSparkles.SparkleColor = Color3.new(SparklesTable[1], SparklesTable[2], SparklesTable[3])
										end

										PlayerList[plr.Name]["Customisations"]["Sparkles"] = Color
										table.insert(PlayerList[plr.Name]["Customisations"]["SparklesColor"], 1, Color)
										plr.PetCustomisations.SparklesColor.Value = Color3.new(SparklesTable[1], SparklesTable[2], SparklesTable[3])
										plr.PetCustomisations.MulticolorSparkles.Value = false
									end
								elseif Type == "Equip" then

									if table.find(PlayerList[plr.Name]["Customisations"]["SparklesColor"], Color) then

										if EquippedPet and EquippedPet ~= "" then

											for i,v in ipairs(workspace[plr.Name]:FindFirstChild(EquippedPet).PrimaryPart:GetChildren()) do -- delete all sparkles
												if v:IsA("Sparkles") then
													v:Destroy()
												end
											end

											local CreateSparkles = Instance.new("Sparkles", workspace[plr.Name][plr.PetCustomisations.EquippedPet.Value].PrimaryPart)
											CreateSparkles.SparkleColor = Color3.new(SparklesTable[1], SparklesTable[2], SparklesTable[3])
										end

										PlayerList[plr.Name]["Customisations"]["Sparkles"] = Color
										plr.PetCustomisations.SparklesColor.Value = Color3.new(SparklesTable[1], SparklesTable[2], SparklesTable[3])
										plr.PetCustomisations.MulticolorSparkles.Value = false

									end
								else WarnBindableEvent:Fire(plr, "Normal", "is firing the sparkles customisation remote event with an unexpected type ("..Type.." instead of buy or equip)", "Pets", os.time()) end
							else WarnBindableEvent:Fire(plr, "Important", "is firing the sparkles customisation remote event with a color which is not supposed to be used (Color : "..Color..")", "Pets", os.time()) end
						else WarnBindableEvent:Fire(plr, "Important", "is firing the sparkles customisation remote event with an unexpected color (Color : "..Color..")", "Pets", os.time()) end
					end

					PetSaveBindableEvent:Fire(plr, "DatastoreScript", "Customisation", PlayerList[plr.Name]["Customisations"]) -- save the table

				else WarnBindableEvent:Fire(plr, "Normal", "is firing the sparkles customisation remote event with unexpected types of value (Color : "..Color..")", "Pets", os.time()) end
			end

				-- UNLOCK RENAME COLOR	

		elseif CustomisationType == "RenameColor" then
			local Type = Param1
			local Color = Param2

			if typeof(Color) == "string" then

				local EquippedPet = PlayerList[plr.Name]["Customisations"]["Equipped"]

				if Color == "Multicolor" then

					if Type == "Buy" then -- if player is buying the sparkles

						local EnoughMoney = MoneyBindableFunction:Invoke(plr, 40000, "-")
						if EnoughMoney == true then

							if EquippedPet and EquippedPet ~= "" then

								if workspace[plr.Name]:FindFirstChild(EquippedPet).BillboardGui.TextLabel:FindFirstChild("UIGradient") then
									workspace[plr.Name]:FindFirstChild(EquippedPet).BillboardGui.TextLabel:FindFirstChild("UIGradient"):Destroy()
								end

								workspace[plr.Name]:FindFirstChild(EquippedPet).BillboardGui.TextLabel.TextColor3 = Color3.new(1,1,1)
								local UIGradient = Instance.new("UIGradient", workspace[plr.Name]:FindFirstChild(EquippedPet).BillboardGui.TextLabel)
								UIGradient.Color = ColorSequence.new{
									ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
									ColorSequenceKeypoint.new(0.2, Color3.new(1,1,0)),
									ColorSequenceKeypoint.new(0.4, Color3.new(0,1,0)),
									ColorSequenceKeypoint.new(0.6, Color3.new(0,1,1)),
									ColorSequenceKeypoint.new(0.8, Color3.new(0,0,1)),
									ColorSequenceKeypoint.new(1, Color3.new(1,0,1))
								}
							end

							PlayerList[plr.Name]["Customisations"]["RenameColorSelected"] = "Multicolor" -- change the rename color value in the table
							table.insert(PlayerList[plr.Name]["Customisations"]["RenameColor"], 1, "Multicolor")
							plr.PetCustomisations.MulticolorRename.Value = true -- value to know that it is a multicolor value
							plr.PetCustomisations.RenameColor.Value = Color3.new(1,1,1)								
						end

					elseif Type == "Equip" then	
						if table.find(PlayerList[plr.Name]["Customisations"]["RenameColor"], "Multicolor") then

							if EquippedPet and EquippedPet ~= "" then

								if workspace[plr.Name]:FindFirstChild(EquippedPet).BillboardGui.TextLabel:FindFirstChild("UIGradient") then
									workspace[plr.Name]:FindFirstChild(EquippedPet).BillboardGui.TextLabel:FindFirstChild("UIGradient"):Destroy()
								end

								workspace[plr.Name]:FindFirstChild(EquippedPet).BillboardGui.TextLabel.TextColor3 = Color3.new(1,1,1)
								local UIGradient = Instance.new("UIGradient", workspace[plr.Name]:FindFirstChild(EquippedPet).BillboardGui.TextLabel)
								UIGradient.Color = ColorSequence.new{
									ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
									ColorSequenceKeypoint.new(0.2, Color3.new(1,1,0)),
									ColorSequenceKeypoint.new(0.4, Color3.new(0,1,0)),
									ColorSequenceKeypoint.new(0.6, Color3.new(0,1,1)),
									ColorSequenceKeypoint.new(0.8, Color3.new(0,0,1)),
									ColorSequenceKeypoint.new(1, Color3.new(1,0,1))
								}
							end

							PlayerList[plr.Name]["Customisations"]["RenameColorSelected"] = "Multicolor" -- change the rename color value in the table
							plr.PetCustomisations.MulticolorRename.Value = true -- value to know that it is a multicolor value
							plr.PetCustomisations.RenameColor.Value = Color3.new(1,1,1)
						end

					else WarnBindableEvent:Fire(plr, "Normal", "is firing the sparkles customisation remote event with an unexpected type ("..Type.." instead of buy or equip)", "Pets", os.time()) end

				else -- if player is buying an unicolor trail
					local RenameTable = string.split(Color, ",") -- get the rgb value of the color
					if #RenameTable == 3 then
						local R = math.floor(tonumber((RenameTable[1] * 255) + 0.5))
						local G = math.floor(tonumber((RenameTable[1] * 255) + 0.5))
						local B = math.floor(tonumber((RenameTable[1] * 255) + 0.5))

						if workspace.PetShop.RenameColor.Board.SurfaceGui.Customise.ColorPicker:FindFirstChild(tostring(R..","..G..","..B)) then

							if Type == "Buy" then -- if player is buying the trail

								local EnoughMoney = MoneyBindableFunction:Invoke(plr, 25000, "-")
								if EnoughMoney == true then

									if EquippedPet and EquippedPet ~= "" then

										if workspace[plr.Name]:FindFirstChild(EquippedPet).BillboardGui.TextLabel:FindFirstChild("UIGradient") then
											workspace[plr.Name]:FindFirstChild(EquippedPet).BillboardGui.TextLabel:FindFirstChild("UIGradient"):Destroy()
										end

										workspace[plr.Name]:FindFirstChild(EquippedPet).BillboardGui.TextLabel.TextColor3 = Color3.new(RenameTable[1], RenameTable[2], RenameTable[3]) -- change the rename color to the rbg values
									end

									PlayerList[plr.Name]["Customisations"]["RenameColorSelected"] = Color
									table.insert(PlayerList[plr.Name]["Customisations"]["RenameColor"], 1, Color)
									plr.PetCustomisations.RenameColor.Value = Color3.new(RenameTable[1], RenameTable[2], RenameTable[3])	 -- change the color value to the rgb values
									plr.PetCustomisations.MulticolorRename.Value = false -- set the multicolor value to false	
								end
							elseif Type == "Equip" then
								
								if table.find(PlayerList[plr.Name]["Customisations"]["RenameColor"], Color) then -- if player owns the color he is trying to equip

									if EquippedPet and EquippedPet ~= "" then
										
										if workspace[plr.Name]:FindFirstChild(EquippedPet).BillboardGui.TextLabel:FindFirstChild("UIGradient") then
											workspace[plr.Name]:FindFirstChild(EquippedPet).BillboardGui.TextLabel:FindFirstChild("UIGradient"):Destroy()
										end

										workspace[plr.Name]:FindFirstChild(EquippedPet).BillboardGui.TextLabel.TextColor3 = Color3.new(RenameTable[1], RenameTable[2], RenameTable[3]) -- change the rename color to the rbg values
									end

									PlayerList[plr.Name]["Customisations"]["RenameColorSelected"] = Color
									plr.PetCustomisations.RenameColor.Value = Color3.new(RenameTable[1], RenameTable[2], RenameTable[3])	 -- change the color value to the rgb values
									plr.PetCustomisations.MulticolorRename.Value = false -- set the multicolor value to false	
								end
							else WarnBindableEvent:Fire(plr, "Normal", "is firing the rename color customisation remote event with an unexpected type ("..Type.." instead of buy or equip)", "Pets", os.time()) end
						else WarnBindableEvent:Fire(plr, "Important", "is firing the rename color customisation remote event with a color which is not supposed to be used (Color : "..Color..")", "Pets", os.time()) end
					else WarnBindableEvent:Fire(plr, "Important", "is firing the rename color customisation remote event with an unexpected color (Color : "..Color..")", "Pets", os.time()) end
				end

				PetSaveBindableEvent:Fire(plr, "DatastoreScript", "Customisation", PlayerList[plr.Name]["Customisations"]) -- save the table

			else WarnBindableEvent:Fire(plr, "Normal", "is firing the sparkles customisation remote event with unexpected types of value (Color : "..Color..")", "Pets", os.time()) end
			
		elseif CustomisationType == "Pack" then
			
			local EnoughMoney = MoneyBindableFunction:Invoke(plr, 40000, "-")
			if EnoughMoney == true then

				for i=1,4 do
					local RandomNumber = math.random(1,100) -- choose a "type"
					local Object = nil
					local Text = nil
					local ChosenColor = nil

					if RandomNumber <= 32 then -- player unlocks a trail color
						Object = "TrailColor"
						Text = "Trail color"
						local TrailList = workspace.PetShop.Trail.Board.SurfaceGui.Customise.ColorPicker:GetChildren()
						while true do -- use a while loop in case, it would pick the UIGridLayout
							ChosenColor = TrailList[math.random(1, #TrailList)] -- choose a random color from the frame
							if ChosenColor:IsA("ImageButton") then
								break
							end
						end

					elseif RandomNumber > 32 and RandomNumber <= 64 then -- player unlocks a sparkles color
						Object = "SparklesColor"
						Text = "Sparkles color"
						local SparklesList = workspace.PetShop.Sparkles.Board.SurfaceGui.Customise.ColorPicker:GetChildren()
						while true do -- use a while loop in case, it would pick the UIGridLayout
							ChosenColor = SparklesList[math.random(1, #SparklesList)] -- choose a random color from the frame
							if ChosenColor:IsA("ImageButton") then
								break
							end
						end	

					elseif RandomNumber > 64 and RandomNumber <= 96 then -- player unlocks a name color
						Object = "RenameColor"
						Text = "Name color"
						local NameList = workspace.PetShop.RenameColor.Board.SurfaceGui.Customise.ColorPicker:GetChildren()
						while true do -- use a while loop in case, it would pick the UIGridLayout
							ChosenColor = NameList[math.random(1, #NameList)] -- choose a random color from the frame
							if ChosenColor:IsA("ImageButton") then
								break
							end
						end	

					else -- player unlocks a multicolor object
						local RandomObject = math.random(1,3)

						if RandomObject == 1 then -- player unlocks a multicolor trail
							Object = "TrailColor"
							Text = "Rainbow trail"
						elseif RandomObject == 2 then -- player unlocks a multicolor sparkles
							Object = "SparklesColor"
							Text = "Rainbow sparkles"
						else -- player unlocks a multicolor name
							Object = "RenameColor"
							Text = "Rainbow name"
						end

						local MulticolorOwned = table.find(PlayerList[plr.Name]["Customisations"][Object], "Multicolor")
						if not MulticolorOwned then
							table.insert(PlayerList[plr.Name]["Customisations"][Object], 1, "Multicolor") -- add the color to the table
							plr.PlayerGui.Pets.Frame.Pack.Frame["Color"..i].TextLabel.Text = Text
							plr.PlayerGui.Pets.Frame.Pack.Frame["Color"..i].Frame.BackgroundColor3 = Color3.new(1,1,1)
							local UIGradient = Instance.new("UIGradient", plr.PlayerGui.Pets.Frame.Pack.Fram["Color"..i].Frame)
							UIGradient.Color = ColorSequence.new{
								ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
								ColorSequenceKeypoint.new(0.2, Color3.new(1,1,0)),
								ColorSequenceKeypoint.new(0.4, Color3.new(0,1,0)),
								ColorSequenceKeypoint.new(0.6, Color3.new(0,1,1)),
								ColorSequenceKeypoint.new(0.8, Color3.new(0,0,1)),
								ColorSequenceKeypoint.new(1, Color3.new(1,0,1))
							}				
						end
					end


					-- ADD THE COLOR TO THE PACK GUI

					if RandomNumber <= 96 then
						local ColorOwned = table.find(PlayerList[plr.Name]["Customisations"][Object], tostring(ChosenColor.BackgroundColor3))
						if not ColorOwned then
							table.insert(PlayerList[plr.Name]["Customisations"][Object], 1, tostring(ChosenColor.BackgroundColor3)) -- add the color to the table
						end
						plr.PlayerGui.Pets.Frame.Pack.Frame["Color"..i].TextLabel.Text = Text
						plr.PlayerGui.Pets.Frame.Pack.Frame["Color"..i].Frame.BackgroundColor3 = ChosenColor.BackgroundColor3
					end
				end
			end
		end
		
		PetCustomisationRemoteEvent:FireClient(plr, "Table", PlayerList[plr.Name]["Customisations"])		
		
		debounce = false
	end
end)


-- CREATE FOLDER AND VALUES

game.Players.PlayerAdded:Connect(function(plr)

	local Inventory = Instance.new("Folder", plr)
	Inventory.Name = "Inventory"

	local Customisations = Instance.new("Folder", plr)
	Customisations.Name = "PetCustomisations"

	local EquippedPet = Instance.new("StringValue", Customisations)
	EquippedPet.Name = "EquippedPet"

	local PetName = Instance.new("StringValue", Customisations)
	PetName.Name = "PetName"

	local Trail = Instance.new("BoolValue", Customisations)
	Trail.Name = "Trail"

	local TrailColor = Instance.new("Color3Value", Customisations)
	TrailColor.Name = "TrailColor"

	local MulticolorTrail = Instance.new("BoolValue", Customisations)
	MulticolorTrail.Name = "MulticolorTrail"

	local Sparkles = Instance.new("BoolValue", Customisations)
	Sparkles.Name = "Sparkles"

	local SparklesColor = Instance.new("Color3Value", Customisations)
	SparklesColor.Name = "SparklesColor"

	local MulticolorSparkles = Instance.new("BoolValue", Customisations)
	MulticolorSparkles.Name = "MulticolorSparkles"

	local RenameColor = Instance.new("Color3Value", Customisations)
	RenameColor.Name = "RenameColor"
	RenameColor.Value = Color3.new(1,1,1)

	local MulticolorRename = Instance.new("BoolValue", Customisations)
	MulticolorRename.Name = "MulticolorRename"
end)


-- PLAYER GETS HIS ABLITIES ENABLED OR DISABLED

AbilitiesBindableEvent.Event:Connect(function(plr, Disable)
	
	if Disable then
		ResetAbilities()
		
	else
		if plr.Character and plr.Character:FindFirstChild("Humanoid") then
			EnableAbilities(plr, plr.Character, plr.Character.Humanoid, plr.PetCustomisations.EquippedPet.Value)
		end
	end
	
end)