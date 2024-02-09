local Age = game.Players.LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Age")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Night = ReplicatedStorage:WaitForChild("Night")
local MoneyRemoteEvent = ReplicatedStorage:WaitForChild("Money")
local AgeRemoteEvent = ReplicatedStorage:WaitForChild("Age")
local Frame = script.Parent.Frame


-- WAIT FOR NIGHT TIME

Night.OnClientEvent:Connect(function()
	local char = game.Players.LocalPlayer.Character.Name
	game.Workspace[char].Humanoid.WalkSpeed = 0

	Frame.Age.Text = Age.Value
	Frame.Visible = true 


	-- MAKE THE FRAME NO LONGER TRANSPARENT

	for i=1,-0.05,-0.05 do -- change the trasparency smoothly
		Frame.BackgroundTransparency = i -- change the transparency of all the childs of frame
		Frame.TextBox.TextTransparency = i
		Frame.YearsOld.TextTransparency = i
		Frame.Age.TextTransparency = i
		Frame.Money.TextTransparency = i
		if Age.Value == 2 then -- if player will have 3 years old
			Frame.Child.TextTransparency = i -- player will become a  child
		elseif Age.Value == 17 then -- player will have 18 years old
			Frame.Adult.TextTransparency = i -- player will become a adult
		elseif Age.Value == 59 then -- if player will have 60 years
			Frame.Retired.TextTransparency = i -- player will become a retired
		end
		wait(0.15) -- change this value to transparent things faster or slower
	end
	wait(2)


	-- TELEPORT PLAYERS TO THE SPAWNS

	local SpawnFolder = game.Workspace.Spawn.CanTP:GetChildren() -- get all the spawns
	local RandomSpawn = SpawnFolder[math.random(1,#SpawnFolder)]
	game.Workspace[char].HumanoidRootPart.CFrame = CFrame.new(RandomSpawn.Position) + Vector3.new(0,5,0)


	-- CHANGE THE AGE

	AgeRemoteEvent:FireServer(1) -- add 1 to the age of the player and change his team
	MoneyRemoteEvent:FireServer(50) -- add 50 money to the player
	Frame.Age.Text = Age.Value + 1 -- change the player age value
	wait(9)


	-- MAKE THE FRAME TRANSPARENT

	for i=0,1.1,0.1 do -- change the transparency smoothly
		Frame.BackgroundTransparency = i -- change transparency of all the childs of frame
		Frame.TextBox.TextTransparency = i
		Frame.YearsOld.TextTransparency = i
		Frame.Age.TextTransparency = i
		Frame.Money.TextTransparency = i
		if Age.Value == 3 then -- if player is 3 years old
			Frame.Child.TextTransparency = i
		elseif Age.Value == 18 then
			Frame.Adult.TextTransparency = i
		elseif Age.Value == 60 then
			Frame.Retired.TextTransparency = i
		end
		wait(0.05)
	end
	Frame.Visible = false
	game.Workspace[char].Humanoid.WalkSpeed = 20
end)