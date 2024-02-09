local Eggs = workspace.PetShop.Eggs
local CommonPets = nil
local RarePets = nil
local EpicPets = nil
local LegendaryPets = nil

local WaitTime = 8 -- time to wait before changing pet

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
		"Swim faster (x1.5)"
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

CommonPets = coroutine.wrap(function()
	while true do
		for i,v in ipairs(game.ReplicatedStorage.Pets.Common:GetChildren()) do
			local CommonClone = v:Clone()
			CommonClone.PrimaryPart.Anchored = true
			CommonClone.Parent = Eggs.Common.DisplayCase.PetPlacement
			CommonClone.PrimaryPart.CFrame = Eggs.Common.DisplayCase.PetPlacement.CFrame
			Eggs.Common.DisplayCase.Stats.BillboardGui.Frame.PetName.Text = InformationsTable[tostring(v)][1]
			Eggs.Common.DisplayCase.Stats.BillboardGui.Frame.Ability1.Text = "- "..InformationsTable[tostring(v)][3]
			if InformationsTable[tostring(v)][4] then
				Eggs.Common.DisplayCase.Stats.BillboardGui.Frame.Ability2.Text = "- "..InformationsTable[tostring(v)][4]
			end
			wait(WaitTime)
			CommonClone:Destroy()	
		end
	end
end)


RarePets = coroutine.wrap(function()
	while true do
		for i,v in ipairs(game.ReplicatedStorage.Pets.Rare:GetChildren()) do
			local RareClone = v:Clone()
			RareClone.PrimaryPart.Anchored = true
			RareClone.Parent = Eggs.Rare.DisplayCase.PetPlacement
			RareClone.PrimaryPart.CFrame = Eggs.Rare.DisplayCase.PetPlacement.CFrame
			Eggs.Rare.DisplayCase.Stats.BillboardGui.Frame.PetName.Text = InformationsTable[tostring(v)][1]
			Eggs.Rare.DisplayCase.Stats.BillboardGui.Frame.Ability1.Text = "- "..InformationsTable[tostring(v)][3]
			if InformationsTable[tostring(v)][4] then
				Eggs.Rare.DisplayCase.Stats.BillboardGui.Frame.Ability2.Text = "- "..InformationsTable[tostring(v)][4]
			end
			wait(WaitTime)
			RareClone:Destroy()
		end
	end
end)


EpicPets = coroutine.wrap(function()
	while true do
		for i,v in ipairs(game.ReplicatedStorage.Pets.Epic:GetChildren()) do
			local EpicClone = v:Clone()
			EpicClone.PrimaryPart.Anchored = true
			EpicClone.Parent = Eggs.Epic.DisplayCase.PetPlacement
			EpicClone.PrimaryPart.CFrame = Eggs.Epic.DisplayCase.PetPlacement.CFrame
			Eggs.Epic.DisplayCase.Stats.BillboardGui.Frame.PetName.Text = InformationsTable[tostring(v)][1]
			Eggs.Epic.DisplayCase.Stats.BillboardGui.Frame.Ability1.Text = "- "..InformationsTable[tostring(v)][3]
			if InformationsTable[tostring(v)][4] then
				Eggs.Epic.DisplayCase.Stats.BillboardGui.Frame.Ability2.Text = "- "..InformationsTable[tostring(v)][4]
			end
			wait(WaitTime)
			EpicClone:Destroy()
		end
	end
end)


LegendaryPets = coroutine.wrap(function()
	while true do
		for i,v in ipairs(game.ReplicatedStorage.Pets.Legendary:GetChildren()) do
			local LegendaryClone = v:Clone()
			LegendaryClone.PrimaryPart.Anchored = true
			LegendaryClone.Parent = Eggs.Legendary.DisplayCase.PetPlacement
			LegendaryClone.PrimaryPart.CFrame = Eggs.Legendary.DisplayCase.PetPlacement.CFrame
			Eggs.Legendary.DisplayCase.Stats.BillboardGui.Frame.PetName.Text = InformationsTable[tostring(v)][1]
			Eggs.Legendary.DisplayCase.Stats.BillboardGui.Frame.Ability1.Text = "- "..InformationsTable[tostring(v)][3]
			if InformationsTable[tostring(v)][4] then
				Eggs.Legendary.DisplayCase.Stats.BillboardGui.Frame.Ability2.Text = "- "..InformationsTable[tostring(v)][4]
			end
			wait(WaitTime)
			LegendaryClone:Destroy()
		end
	end
end)

CommonPets()
RarePets()
EpicPets()
LegendaryPets()