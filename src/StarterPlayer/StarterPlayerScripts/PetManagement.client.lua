local TweenService = game:GetService("TweenService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetSaveRemoteFunction = ReplicatedStorage:WaitForChild("PetSave")

local Eggs = workspace.PetShop.Eggs
local Egg = workspace.PetShop.HachingRoom.Egg
local Camera = workspace.CurrentCamera
local lplr = game.Players.LocalPlayer
local PetsGui = lplr.PlayerGui:WaitForChild("Pets"):WaitForChild("Frame")
local Inventory = PetsGui:WaitForChild("Inventory")
local Button = Inventory.Parent.Buttons.InventoryButton

local WalkSpeed = 16
local PetRarity = nil
local PetTable = {}
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
		"Common",
		"Emits light",
		"Swims faster (x1.5)"
	},
	Koala = {
		"Koala",
		"Rare",
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


-- FUNCTION TRIGGERED WHEN PLAYER PRESSES "E" NEXT TO AN EGG

local function ChoosePet(Rarity)
	PetsGui.Confirmation.Rarity.Value = Rarity
	PetsGui.Confirmation.Visible = true
	PetsGui.Confirmation:TweenPosition(UDim2.new(0.5,0,0.5,0), nil, nil, 0.5) -- confirmation message
end


-- IF PLAYER CLICKS ON "YES" TO BUY EGG

local function YesButton()
	if not debounce then
		debounce = true
		PetsGui.Confirmation:TweenPosition(UDim2.new(0.5,0,1.2,0), nil, nil, 0.5)
		wait(0.5)
		PetsGui.Confirmation.Visible = false
		
		local Rarity = PetsGui.Confirmation.Rarity.Value
		
		local Pet, Rarity = PetSaveRemoteFunction:InvokeServer(Rarity)
		print(Pet, Rarity)
		if Pet then
			
			WalkSpeed = workspace[lplr.Name].Humanoid.WalkSpeed
			workspace[lplr.Name].Humanoid.WalkSpeed = 0
			workspace[lplr.Name].HumanoidRootPart.Anchored = true

			-- HATCH THE EGG

			PetsGui.NewPet.PetInformation.PetName.Text = InformationsTable[Pet.Name][1] 
			PetsGui.NewPet.PetInformation.Ability1.Text = "- "..InformationsTable[Pet.Name][3]
			PetsGui.NewPet.PetInformation.Ability2.Text = "- "..InformationsTable[Pet.Name][4]
			wait(1)
			Camera.CameraType = Enum.CameraType.Scriptable
			Camera.CFrame = CFrame.new(workspace.PetShop.HachingRoom.CameraPart.Position, workspace.PetShop.HachingRoom.PetPlacement.Position)

			wait(1)

			local Goal = {}
			Goal.Position = workspace.PetShop.HachingRoom.PetPlacement.Position

			local Big = {}
			Big.Size = Vector3.new(7, 8.941, 7)

			local Small = {}
			Small.Size = Vector3.new(6, 7.633, 6)

			local Explode = {}
			Explode.Size = Vector3.new(8.1, 10.346, 8.1)

			local EggFall = TweenService:Create(Egg, TweenInfo.new(.3), Goal)
			local EggGrow = TweenService:Create(Egg, TweenInfo.new(1), Big)
			local EggShrink = TweenService:Create(Egg, TweenInfo.new(1), Small)
			local EggExploding = TweenService:Create(Egg, TweenInfo.new(4), Explode)
			local CameraZoom = TweenService:Create(Camera, TweenInfo.new(1, Enum.EasingStyle.Bounce), {CFrame = CFrame.new(workspace.PetShop.HachingRoom.ZoomPlacement.Position, workspace.PetShop.HachingRoom.PetPlacement.Position)})

			Egg.Transparency = 0
			EggFall:Play()
			wait(1)
			EggGrow:Play()
			wait(1)
			EggShrink:Play()
			wait(1)
			EggGrow:Play()
			wait(1)
			EggShrink:Play()
			wait(1)
			EggExploding:Play()
			Egg.Material = Enum.Material.Neon
			while Egg.Size.X < 8 do
				for i=0,0.4,0.05 do
					Egg.Transparency = i
					wait()
				end
				for i=0.4,0,-0.05 do
					Egg.Transparency = i
					wait()
				end
			end

			local Explosion = Instance.new("Explosion") -- explosion when the egg cracks
			Explosion.BlastRadius = 10
			Explosion.BlastPressure = 0
			Explosion.Position = Egg.Position
			Explosion.ExplosionType = Enum.ExplosionType.NoCraters
			Explosion.DestroyJointRadiusPercent = 0
			Explosion.Parent = Egg
			Egg.Transparency = 1
			Egg.Sparkles.Enabled = true
			
			local FindPet = ReplicatedStorage.Pets[Rarity]:FindFirstChild(Pet.Name)
			local PetClone = nil
			if FindPet then
				PetClone = FindPet:Clone() -- clone the pet when the egg hatches
				PetClone.Parent = workspace
				PetClone.HitBox.Anchored = true
				PetClone:SetPrimaryPartCFrame(workspace.PetShop.HachingRoom.PetPlacement.CFrame) -- move the pet to the egg
				CameraZoom:Play()
				wait(6)
			end
			Camera.CameraType = Enum.CameraType.Custom
			workspace[lplr.Name].HumanoidRootPart.Anchored = false


			-- SHOW THE NEW PET GUI

			if PetClone then
				PetClone.Parent = PetsGui.NewPet.PetInformation.ViewportFrame -- change the parent to see the pet in the new pet gui

				local NewPetCamera = Instance.new("Camera", PetsGui.NewPet.PetInformation.ViewportFrame)
				NewPetCamera.Name = "PetCamera"
				NewPetCamera.CFrame = CFrame.new(PetsGui.NewPet.PetInformation.ViewportFrame[Pet.Name].PrimaryPart.Position + PetsGui.NewPet.PetInformation.ViewportFrame[Pet.Name].PrimaryPart.CFrame.LookVector * 3, PetsGui.NewPet.PetInformation.ViewportFrame[Pet.Name].PrimaryPart.Position)
				PetsGui.NewPet.PetInformation.ViewportFrame.CurrentCamera = NewPetCamera	

				wait(1)
				PetsGui.NewPet.Visible = true
				PetsGui.NewPet:TweenPosition(UDim2.new(0.5,0,0.55,0), nil, nil, 0.5)

				PetsGui.NewPet.Close.MouseButton1Down:Connect(function()
					PetsGui.NewPet:TweenPosition(UDim2.new(0.5,0,1.5,0), nil, nil, 0.5)
					wait(.5)
					PetsGui.NewPet.Visible = false
					PetClone:Destroy()
				end)
			end
			
			workspace[lplr.Name].Humanoid.WalkSpeed = WalkSpeed
			workspace[lplr.Name].HumanoidRootPart.Anchored = false
		end
	end

	debounce = false
end


-- IF PLAYER OPENS THE INVENTORY (CLICKS THE PET BUTTON)

Button.MouseButton1Down:Connect(function()
	Button.Visible = false
	Inventory.Visible = true
	Inventory:TweenPosition(UDim2.new(0.5,0,0.54,0), nil, nil, 0.3)
	Inventory:TweenSize(UDim2.new(0.6,0,0.85,0), nil, nil, 0.3)
end)


-- IF PLAYER CLOSES THE INVENTORY (CROSS)

Inventory.Close.MouseButton1Down:Connect(function()
	Inventory:TweenPosition(UDim2.new(0.0397,0,0.083,0), nil, nil, 0.3)
	Inventory:TweenSize(UDim2.new(0.049451,0,0.1,0), nil, nil, 0.3)
	wait(0.3)
	Inventory.Visible = false
	Button.Visible = true
end)

PetsGui.Confirmation.Yes.MouseButton1Down:Connect(function() -- if player presses "E" and then clicks yes to open the egg
	YesButton()
end)

PetsGui.Confirmation.No.MouseButton1Down:Connect(function() -- if player presses "E" but then clicks no and doesn't open the egg
	PetsGui.Confirmation:TweenPosition(UDim2.new(0.5,0,1.2,0), nil, nil, 0.5)
	wait(0.5)
	PetsGui.Confirmation.Visible = false
end)

Eggs.Common.Egg.ProximityPrompt.Triggered:Connect(function() -- if player pressses "E" on the common egg
	ChoosePet("Common")
end)

Eggs.Rare.Egg.ProximityPrompt.Triggered:Connect(function()
	ChoosePet("Rare")
end)

Eggs.Epic.Egg.ProximityPrompt.Triggered:Connect(function()
	ChoosePet("Epic")
end)

Eggs.Legendary.Egg.ProximityPrompt.Triggered:Connect(function()
	ChoosePet("Legendary")
end)