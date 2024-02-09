local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeathRemoteEvent = ReplicatedStorage:WaitForChild("Death")

local lplr = game.Players.LocalPlayer
local AgeGui = lplr:WaitForChild("leaderstats"):WaitForChild("Age")
local MoneyGui = lplr:WaitForChild("leaderstats"):WaitForChild("Money")
local SavedGui = lplr.PlayerGui:WaitForChild("Death"):WaitForChild("PetSave")
local TombstoneGui = script.Parent:WaitForChild("Tombstone")
local WhiteBackground = script.Parent.WhiteBackground

local Graveyard = workspace.Graveyard
local CurrentCamera = workspace.CurrentCamera
local Color = 0

-- ~1/25190 (0.00397%) to be 100 years old


-- REMOTE EVENT THAT FIRES AT NIGHT TIME
DeathRemoteEvent.OnClientEvent:Connect(function(Age, Saved, Hospital)
	
	-- if player is busy doing something (such as a race, or playing in the factory...), wait for him to finish what he was doing	
	if not lplr.CanDie then
		repeat wait(1) until lplr.CanDie
	end
	
	-- If the player got saved by his pet
	if Saved then
		SavedGui.Visible = true
		wait(8)
		SavedGui.Visible = false
		
	elseif Age then
		WhiteBackground.Visible = true
		
		-- Show the white background (fade transparency)
		TweenService:Create(WhiteBackground, TweenInfo.new(1), {Transparency = 0}):Play()
		wait(1.5)
		
		-- Move the camera to the graveyard one
		CurrentCamera.CameraType = Enum.CameraType.Scriptable
		CurrentCamera.CFrame = Graveyard.GraveyardCamera.CFrame
		
		-- Hide the white background (fade back transparency)
		TweenService:Create(WhiteBackground, TweenInfo.new(1), {Transparency = 1}):Play()
		wait(4)
		
		-- Tween the camera to the tombstone
		TweenService:Create(CurrentCamera, TweenInfo.new(1.5, Enum.EasingStyle.Quart), {CFrame = Graveyard.TombstoneCamera.CFrame}):Play()
		wait(2.5)
		TombstoneGui.PlayerName.Text = lplr.Name
		TombstoneGui.Age.Text = Age.." years old"
		
		-- Show the name and the age of player on the tombstone (fade transparency)
		TweenService:Create(TombstoneGui.PlayerName, TweenInfo.new(2), {TextTransparency = 0}):Play()
		wait(1.25)
		TweenService:Create(TombstoneGui.Age, TweenInfo.new(2), {TextTransparency = 0}):Play()
		wait(5)
		
		-- Tween the camera to look down to the tomb
		TweenService:Create(CurrentCamera, TweenInfo.new(1), {CFrame = Graveyard.TombCamera.CFrame}):Play()
		wait(1)
		
		-- Tween the camera into the ground
		TweenService:Create(CurrentCamera, TweenInfo.new(2.5), {CFrame = Graveyard.BurriedCamera.CFrame}):Play()
		wait(2.5)
		
		-- Money earnt text based on the age of the player
		-- If the player died in the hospital, he doesn't get any money
		if Hospital then
			WhiteBackground.Money.Text = "You died at the age of "..tostring(Age).."!"
			
			-- Otherwise, he gets money based on the age at which he died
			-- 0-59 : 41 000 - 100 000
			-- 60-99 : 27 500 - 125 000
			-- 100 : 150 000
		else
			if Age < 60 then
				WhiteBackground.Money.Text = "You died at the age of "..tostring(Age).." and so you earn $"..tostring(((100 - Age) * 1000)).."!"
			elseif Age >= 60 and Age <= 99 then
				WhiteBackground.Money.Text = "You died at the age of "..tostring(Age).." and so you earn $"..tostring(((Age - 49) * 2500)).."!"
			elseif Age == 100 then
				WhiteBackground.Money.Text = "You died at the age of "..tostring(Age).." and so you earn $150 000!"
			end
		end
		
		-- Show the white background (fade transparency)
		TweenService:Create(WhiteBackground, TweenInfo.new(10), {Transparency = 0}):Play()
		wait(10)
		
		for i,v in ipairs(WhiteBackground:GetChildren()) do
			v.Visible = true
		end
		wait(10)
		for i,v in ipairs(WhiteBackground:GetChildren()) do
			v.Visible = false
		end
		
		-- Hide the white background (fade transparency)
		TweenService:Create(WhiteBackground, TweenInfo.new(10), {Transparency = 1}):Play()	
		
		TombstoneGui.PlayerName.TextTransparency = 1
		TombstoneGui.Age.TextTransparency = 1
		
		if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
			lplr.Character:FindFirstChild("Humanoid").Health = 0
			wait(6)
			CurrentCamera.CameraType = Enum.CameraType.Custom
		end	
	end
end)
	
	
--if Age then
--	if Age < 60 then -- if player is 60 or younger
--		Frame.Money.Text = "Unfortunately you died at the age of "..Age..". You earn $200 000!"

--	elseif Age >= 60 and Age <= 99 then -- if player is between 60 and 99 years old
--		Frame.Money.Text = "Unfortunately you died at the age of "..Age..". You earn $"..((Age - 59) * 1000).."!"

--	elseif Age == 100 then -- if player is 100 years old
--		Frame.Money.Text = "Unfortunately you died at the age of 100 years old. You earn $200 000!"
--	end

--	script.Parent.Parent.Night.Frame.Visible = false
--	for i=1,-0.05,-0.05 do -- change the trasparency smoothly
--		Frame.BackgroundTransparency = i -- change the transparency of all the childs of frame
--		Frame.Dead.TextTransparency = i
--		Frame.Money.TextTransparency = i
--		Frame.Reborn.TextTransparency = i
--		Color = Color + 1
--		Frame.BackgroundColor3 = Color3.new((12*Color)/255, (12*Color)/255, (12*Color)/255)
--		wait(0.15) -- change this value to transparent things faster or slower
--	end

--	wait(11)

--	for i=0,1.1,0.1 do -- change the trasparency smoothly
--		Frame.BackgroundTransparency = i -- change the transparency of all the childs of frame
--		Frame.Dead.TextTransparency = i
--		Frame.Money.TextTransparency = i
--		Frame.Reborn.TextTransparency = i
--		wait(0.05) -- change this value to transparent things faster or slower
--	end
--	Frame.BackgroundColor3 = Color3.new(0,0,0)
--	Frame.Visible = false -- hide the death gui
--end

-- IF THE PET SAVED THE PLAYER

--if Saved then

--	SavedGui.Visible = true
--	wait(8)
--	SavedGui.Visible = false

--end