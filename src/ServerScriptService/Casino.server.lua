local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local CasinoChipBindableEvent = ServerStorage:WaitForChild("CasinoChip")
local CasinoPetBindableFunction = ServerStorage:WaitForChild("CasinoPet")

local fortuneWheelRewards = {10000,0,2000,0,3000,0,2000,0,5000,0,2000,0,3000,0,2000,0,2000,0,3000,0,2000,0,5000,0,2000,0,3000,0,2000,0}
local TweenService = game:GetService("TweenService")

--[[
1 = casino chip
2 = 2 money
3 = pet
4 = 1 money
5 = 3 money
]]--
--local slotMachinesTargetRotation = {Vector3.new(21,90,-180), Vector3.new(89.98,-110.14,-20.14), Vector3.new(15,90,0), Vector3.new(-57,-90,0), Vector3.new(-51,90,180)}
--local slotMachinesTargetRotation = {69, -3, -75, -147, -219}
--local leftSlotMachinesTargetRotation = {159, 87, 15, -57, -129}
--local rightSlotMachinesTargetRotation = {21, 93, 165, -123, -51}
--local rightSlotMachinesTargetRotation = {21, 87, 15, -57, -51}
local leftSlotMachinesTargetRotationWheel1 = {
	{21,-90,-180},
	{87,90,0},
	{15,90,0},
	{-57,90,0},
	{-51,-90,-180}
}

local leftSlotMachinesTargetRotationWheel23 = {
	{21,-90,180},
	{87,90,0},
	{15,90,0},
	{-57,90,0},
	{-51,-90,180}
}

local rightSlotMachinesTargetRotation = {
	{21,90,180},
	{87,-90,0},
	{15,-90,0},
	{-57,-90,0},
	{-51,90,180}
}
--local slotMachinesTargetRotation = {Vector3.new(90, 69, 90), Vector3.new(90,-3,90), Vector3.new(90,-75,90), Vector3.new(-90,39,-90), Vector3.new(-90,-33,-90)}


-- FORTUNE WHEELS

for i,v in ipairs(workspace.Casino.FortuneWheels:GetChildren()) do
	v.Wheel.ProximityPrompt.Triggered:Connect(function(plr)

		if not v.IsSpinning.Value then
			if plr.Stats.CasinoChips.Value > 0 then
				CasinoChipBindableEvent:Fire(plr, 1, "-")

				v.IsSpinning.Value = true
				v.Wheel.ProximityPrompt.Enabled = false

				local rewardIndex = math.random(1, #fortuneWheelRewards)

				local angle = rewardIndex / #fortuneWheelRewards * 360 - (360 / #fortuneWheelRewards / 2)
				local offset = -math.random() * 360 / #fortuneWheelRewards
				local spins = math.random(10,20) * 360
				angle += offset + spins


				local spinTime = math.random(10, 15)

				local tween = TweenService:Create(v.Wheel.SurfaceGui.ImageLabel, TweenInfo.new(spinTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = angle})
				--local tween = TweenService:Create(v.Wheel, TweenInfo.new(spinTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {CFrame = v.Wheel.CFrame * CFrame.Angles(-math.rad(angle), 0, 0)})
				tween:Play()

				tween.Completed:Wait()
				v.Wheel.SurfaceGui.ImageLabel.Rotation = v.Wheel.SurfaceGui.ImageLabel.Rotation % 360

				if fortuneWheelRewards[rewardIndex] ~= 0 then
					MoneyBindableFunction:Invoke(plr, fortuneWheelRewards[rewardIndex], "+")
				end			

				v.Wheel.ProximityPrompt.Enabled = true
				v.IsSpinning.Value = false
			end
		end
	end)
end


-- RIGHT SLOT MACHINES

for i,v in ipairs(workspace.Casino.RightSlotMachines:GetChildren()) do
	v.ProximityPrompt.ProximityPrompt.Triggered:Connect(function(plr)

		if not v.IsSpinning.Value then
			if plr.Stats.CasinoChips.Value > 0 then
				CasinoChipBindableEvent:Fire(plr, 1, "-")
				
				v.IsSpinning.Value = true
				v.ProximityPrompt.ProximityPrompt.Enabled = false
				v.Prize.SurfaceGui.TextLabel.Text = ""

				local rewardIndex1 = math.random(1,5)
				local rewardIndex2 = math.random(1,5)
				local rewardIndex3 = math.random(1,5)

				--local spins = math.random(10,20) * 360

				--local angle = rewardIndex / #fortuneWheelRewards * 360 - (360 / #fortuneWheelRewards / 2)
				--local offset = -math.random() * 360 / #fortuneWheelRewards
				--local spins = math.random(10,20) * 360
				--angle += offset + spins

				local spinTime = math.random(5, 7)
				local numberOfSpins = math.random(30,40)

				coroutine.wrap(function()
					local tween = TweenService:Create(v.Wheel1, TweenInfo.new(spinTime / (numberOfSpins / 2), Enum.EasingStyle.Back, Enum.EasingDirection.In), {CFrame = v.Wheel1.CFrame * CFrame.Angles(-math.rad(179), 0, 0)})
					tween:Play()
					tween.Completed:Wait()

					for i = 1, numberOfSpins do
						local tween = TweenService:Create(v.Wheel1, TweenInfo.new(spinTime / (numberOfSpins * 6) + (i^3 / (numberOfSpins^3.1)), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.Wheel1.CFrame * CFrame.Angles(-math.rad(179), 0, 0)})
						tween:Play()
						tween.Completed:Wait()
					end

					local cpt = 0

					repeat
						local tween = TweenService:Create(v.Wheel1, TweenInfo.new(0.03, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.Wheel1.CFrame * CFrame.Angles(-math.rad(5), 0, 0)})
						tween:Play()
						tween.Completed:Wait()
						cpt += 1
					until (v.Wheel1.Orientation.X < rightSlotMachinesTargetRotation[rewardIndex1][1] + 5 and v.Wheel1.Orientation.X > rightSlotMachinesTargetRotation[rewardIndex1][1] - 5 and v.Wheel1.Orientation.Y == rightSlotMachinesTargetRotation[rewardIndex1][2]) or cpt > 100

					TweenService:Create(v.Wheel1, TweenInfo.new(0.03, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Orientation = Vector3.new(rightSlotMachinesTargetRotation[rewardIndex1][1], rightSlotMachinesTargetRotation[rewardIndex1][2], rightSlotMachinesTargetRotation[rewardIndex1][3])}):Play()
				end)()

				coroutine.wrap(function()
					local tween = TweenService:Create(v.Wheel2, TweenInfo.new((spinTime + 3) / (numberOfSpins / 2), Enum.EasingStyle.Back, Enum.EasingDirection.In), {CFrame = v.Wheel2.CFrame * CFrame.Angles(-math.rad(179), 0, 0)})
					tween:Play()
					tween.Completed:Wait()

					for i = 1, numberOfSpins do
						local tween = TweenService:Create(v.Wheel2, TweenInfo.new((spinTime + 3) / (numberOfSpins * 6) + (i^3 / (numberOfSpins^3.1)), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.Wheel2.CFrame * CFrame.Angles(-math.rad(179), 0, 0)})
						tween:Play()
						tween.Completed:Wait()
					end

					local cpt = 0

					repeat
						local tween = TweenService:Create(v.Wheel2, TweenInfo.new(0.03, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.Wheel2.CFrame * CFrame.Angles(-math.rad(5), 0, 0)})
						tween:Play()
						tween.Completed:Wait()
						cpt += 1
					until (v.Wheel2.Orientation.X < rightSlotMachinesTargetRotation[rewardIndex2][1] + 5 and v.Wheel2.Orientation.X > rightSlotMachinesTargetRotation[rewardIndex2][1] - 5 and v.Wheel2.Orientation.Y == rightSlotMachinesTargetRotation[rewardIndex2][2]) or cpt > 100

					TweenService:Create(v.Wheel2, TweenInfo.new(0.03, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Orientation = Vector3.new(rightSlotMachinesTargetRotation[rewardIndex2][1], rightSlotMachinesTargetRotation[rewardIndex2][2], rightSlotMachinesTargetRotation[rewardIndex2][3])}):Play()
				end)()

				coroutine.wrap(function()
					local tween = TweenService:Create(v.Wheel3, TweenInfo.new((spinTime + 6) / (numberOfSpins / 2), Enum.EasingStyle.Back, Enum.EasingDirection.In), {CFrame = v.Wheel3.CFrame * CFrame.Angles(-math.rad(179), 0, 0)})
					tween:Play()
					tween.Completed:Wait()

					for i = 1, numberOfSpins do
						local tween = TweenService:Create(v.Wheel3, TweenInfo.new((spinTime + 6) / (numberOfSpins * 6) + (i^3 / (numberOfSpins^3.1)), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.Wheel3.CFrame * CFrame.Angles(-math.rad(179), 0, 0)})
						tween:Play()
						tween.Completed:Wait()
					end

					local cpt = 0

					repeat
						local tween = TweenService:Create(v.Wheel3, TweenInfo.new(0.03, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.Wheel3.CFrame * CFrame.Angles(-math.rad(5), 0, 0)})
						tween:Play()
						tween.Completed:Wait()
						cpt += 1
					until (v.Wheel3.Orientation.X < rightSlotMachinesTargetRotation[rewardIndex3][1] + 5 and v.Wheel3.Orientation.X > rightSlotMachinesTargetRotation[rewardIndex3][1] - 5 and v.Wheel3.Orientation.Y == rightSlotMachinesTargetRotation[rewardIndex3][2]) or cpt > 100

					TweenService:Create(v.Wheel3, TweenInfo.new(0.03, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Orientation = Vector3.new(rightSlotMachinesTargetRotation[rewardIndex3][1], rightSlotMachinesTargetRotation[rewardIndex3][2], rightSlotMachinesTargetRotation[rewardIndex3][3])}):Play()

					--rewards
					local rewardsTable = {rewardIndex1, rewardIndex2, rewardIndex3}
					table.sort(rewardsTable)

					-- Three casino chips
					if rewardsTable[1] == 1 and rewardsTable[2] == 1 and rewardsTable[3] == 1 then
						CasinoChipBindableEvent:Fire(plr, 2, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(98,98,98)
						v.Prize.SurfaceGui.TextLabel.Text = "2 chips"

						-- Two casino chips and any third
					elseif rewardsTable[1] == 1 and rewardsTable[2] == 1 then
						CasinoChipBindableEvent:Fire(plr, 1, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(98,98,98)
						v.Prize.SurfaceGui.TextLabel.Text = "1 chips"

						-- Three pets
					elseif rewardsTable[1] == 3 and rewardsTable[2] == 3 and rewardsTable[3] == 3 then
						local pet, rarity = CasinoPetBindableFunction:Invoke(plr, "Rare", "Casino")

						if rarity then
							if rarity == "Common" then
								v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(55, 138, 189)
							elseif rarity == "Rare" then
								v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(32, 189, 45)
							elseif rarity == "Epic" then
								v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(159, 68, 189)
							else
								v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(220, 147, 21)
							end
						end

						if pet then
							v.Prize.SurfaceGui.TextLabel.Text = tostring(pet)
						end

						-- One money 2, one money 1 and one money 3
					elseif rewardsTable[1] == 2 and rewardsTable[2] == 4 and rewardsTable[3] == 5 then
						MoneyBindableFunction:Invoke(plr, 4000, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(37, 171, 27)
						v.Prize.SurfaceGui.TextLabel.Text = "$4000"

						-- Three money 2
					elseif (rewardsTable[1] == 2 and rewardsTable[2] == 2 and rewardsTable[3] == 2) then
						MoneyBindableFunction:Invoke(plr, 7500, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(37, 171, 27)
						v.Prize.SurfaceGui.TextLabel.Text = "$7500"

						-- Three money 1
					elseif (rewardsTable[1] == 4 and rewardsTable[2] == 4 and rewardsTable[3] == 4) then
						MoneyBindableFunction:Invoke(plr, 5000, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(37, 171, 27)
						v.Prize.SurfaceGui.TextLabel.Text = "$5000"

						-- Three money 3
					elseif (rewardsTable[1] == 5 and rewardsTable[2] == 5 and rewardsTable[3] == 5) then
						MoneyBindableFunction:Invoke(plr, 10000, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(37, 171, 27)
						v.Prize.SurfaceGui.TextLabel.Text = "$10000"

						-- Two money 2 and any third
					elseif (rewardsTable[2] == 2 and (rewardsTable[1] == 2 or rewardsTable[3] == 2)) then
						MoneyBindableFunction:Invoke(plr, 2000, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(37, 171, 27)
						v.Prize.SurfaceGui.TextLabel.Text = "$2000"

						-- Two money 1 and any third				
					elseif (rewardsTable[2] == 4 and (rewardsTable[1] == 4 or rewardsTable[3] == 4)) then
						MoneyBindableFunction:Invoke(plr, 1000, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(37, 171, 27)
						v.Prize.SurfaceGui.TextLabel.Text = "$1000"

						-- Two money 3 and any third				
					elseif (rewardsTable[2] == 5 and (rewardsTable[1] == 5 or rewardsTable[3] == 5)) then
						MoneyBindableFunction:Invoke(plr, 3000, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(37, 171, 27)
						v.Prize.SurfaceGui.TextLabel.Text = "$3000"

					else
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.new(1,1,1)
						v.Prize.SurfaceGui.TextLabel.Text = "Nothing :'("
					end

					v.ProximityPrompt.ProximityPrompt.Enabled = true
					v.IsSpinning.Value = false
				end)()

				--local TweenService = game:GetService("TweenService")
				--local spinTime = math.random(5, 7)
				--local v = workspace.Casino.RightSlotMachines.SlotMachine1
				--local numberOfSpins = math.random(30,40)
				--local tween = TweenService:Create(v.Wheel2, TweenInfo.new((spinTime + 6) / (numberOfSpins / 2), Enum.EasingStyle.Back, Enum.EasingDirection.In), {CFrame = v.Wheel2.CFrame * CFrame.Angles(-math.rad(179), 0, 0)})
				--tween:Play()
				--tween.Completed:Wait()
				--for i = 1, numberOfSpins do
				--	local tween = TweenService:Create(v.Wheel2, TweenInfo.new((spinTime + 6) / (numberOfSpins * 6) + (i^3 / (numberOfSpins^3.1)), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.Wheel2.CFrame * CFrame.Angles(-math.rad(179), 0, 0)})
				--	tween:Play()
				--	tween.Completed:Wait()
				--end

				--local cpt = 0

				--repeat
				--	local tween = TweenService:Create(v.Wheel2, TweenInfo.new(0.03, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.Wheel2.CFrame * CFrame.Angles(-math.rad(5), 0, 0)})
				--	tween:Play()
				--	tween.Completed:Wait()
				--	cpt += 1
				--until (v.Wheel2.Orientation.X < -50 and v.Wheel2.Orientation.X > -64 and v.Wheel2.Orientation.Y == -90) or cpt > 100
				--TweenService:Create(v.Wheel2, TweenInfo.new(0.03, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Orientation = Vector3.new(-57, -90, 0)}):Play()


				--coroutine.wrap(function()
				--	local speed = math.random(10,20)
				--	local speed1, speed2, speed3 = speed, speed + 1, speed + 2
				--	local con

				--	con = game:GetService("RunService").Heartbeat:Connect(function(dt)
				--		v.Wheel1.CFrame *= CFrame.Angles(dt * speed1, 0, 0)
				--		v.Wheel2.CFrame *= CFrame.Angles(dt * speed2, 0, 0)
				--		v.Wheel3.CFrame *= CFrame.Angles(dt * speed3, 0, 0)
				--		--speed  = math.max(speed - (dt * 2), 0)
				--		speed1  = speed1 - (dt * 2)
				--		speed2  = speed2 - (dt * 2)
				--		speed3  = speed3 - (dt * 2)

				--		if speed3 < 0.5 then
				--			con:Disconnect()
				--		end
				--	end)

				--TweenService:Create(v.Wheel1, TweenInfo.new(spinTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = Vector3.new(rightSlotMachinesTargetRotation[rewardIndex1] + spins, -90, 0)}):Play()
				--wait(0.5)

				--TweenService:Create(v.Wheel2, TweenInfo.new(spinTime + 3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = Vector3.new(rightSlotMachinesTargetRotation[rewardIndex2] + spins, -90, 0)}):Play()
				--wait(0.5)

				--local tween3 = TweenService:Create(v.Wheel3, TweenInfo.new(spinTime + 6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = Vector3.new(rightSlotMachinesTargetRotation[rewardIndex3] + spins, -90, 0)})
				--tween3:Play()

				--tween3.Completed:Wait()
				--end)()
			end
		end
	end)
end


-- LEFT SLOT MACHINES

for i,v in ipairs(workspace.Casino.LeftSlotMachines:GetChildren()) do
	v.ProximityPrompt.ProximityPrompt.Triggered:Connect(function(plr)

		if not v.IsSpinning.Value then
			if plr.Stats.CasinoChips.Value > 0 then
				CasinoChipBindableEvent:Fire(plr, 1, "-")
				
				v.IsSpinning.Value = true
				v.ProximityPrompt.ProximityPrompt.Enabled = false
				v.Prize.SurfaceGui.TextLabel.Text = ""

				local rewardIndex1 = math.random(1,5)
				local rewardIndex2 = math.random(1,5)
				local rewardIndex3 = math.random(1,5)

				--local spins = math.random(10,20) * 360

				--local angle = rewardIndex / #fortuneWheelRewards * 360 - (360 / #fortuneWheelRewards / 2)
				--local offset = -math.random() * 360 / #fortuneWheelRewards
				--local spins = math.random(10,20) * 360
				--angle += offset + spins

				local spinTime = math.random(5, 7)
				local numberOfSpins = math.random(30,40)

				coroutine.wrap(function()
					local tween = TweenService:Create(v.Wheel1, TweenInfo.new(spinTime / (numberOfSpins / 2), Enum.EasingStyle.Back, Enum.EasingDirection.In), {CFrame = v.Wheel1.CFrame * CFrame.Angles(-math.rad(179), 0, 0)})
					tween:Play()
					tween.Completed:Wait()

					for i = 1, numberOfSpins do
						local tween = TweenService:Create(v.Wheel1, TweenInfo.new(spinTime / (numberOfSpins * 6) + (i^3 / (numberOfSpins^3.1)), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.Wheel1.CFrame * CFrame.Angles(-math.rad(179), 0, 0)})
						tween:Play()
						tween.Completed:Wait()
					end

					local cpt = 0

					repeat
						local tween = TweenService:Create(v.Wheel1, TweenInfo.new(0.03, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.Wheel1.CFrame * CFrame.Angles(-math.rad(5), 0, 0)})
						tween:Play()
						tween.Completed:Wait()
						cpt += 1
					until (v.Wheel1.Orientation.X < leftSlotMachinesTargetRotationWheel1[rewardIndex1][1] + 5 and v.Wheel1.Orientation.X > leftSlotMachinesTargetRotationWheel1[rewardIndex1][1] - 5 and v.Wheel1.Orientation.Y == leftSlotMachinesTargetRotationWheel1[rewardIndex1][2]) or cpt > 100

					TweenService:Create(v.Wheel1, TweenInfo.new(0.03, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Orientation = Vector3.new(leftSlotMachinesTargetRotationWheel1[rewardIndex1][1], leftSlotMachinesTargetRotationWheel1[rewardIndex1][2], leftSlotMachinesTargetRotationWheel1[rewardIndex1][3])}):Play()
				end)()

				coroutine.wrap(function()
					local tween = TweenService:Create(v.Wheel2, TweenInfo.new((spinTime + 3) / (numberOfSpins / 2), Enum.EasingStyle.Back, Enum.EasingDirection.In), {CFrame = v.Wheel2.CFrame * CFrame.Angles(-math.rad(179), 0, 0)})
					tween:Play()
					tween.Completed:Wait()

					for i = 1, numberOfSpins do
						local tween = TweenService:Create(v.Wheel2, TweenInfo.new((spinTime + 3) / (numberOfSpins * 6) + (i^3 / (numberOfSpins^3.1)), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.Wheel2.CFrame * CFrame.Angles(-math.rad(179), 0, 0)})
						tween:Play()
						tween.Completed:Wait()
					end

					local cpt = 0

					repeat
						local tween = TweenService:Create(v.Wheel2, TweenInfo.new(0.03, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.Wheel2.CFrame * CFrame.Angles(-math.rad(5), 0, 0)})
						tween:Play()
						tween.Completed:Wait()
						cpt += 1
					until (v.Wheel2.Orientation.X < leftSlotMachinesTargetRotationWheel23[rewardIndex2][1] + 5 and v.Wheel2.Orientation.X > leftSlotMachinesTargetRotationWheel23[rewardIndex2][1] - 5 and v.Wheel2.Orientation.Y == leftSlotMachinesTargetRotationWheel23[rewardIndex2][2]) or cpt > 100

					TweenService:Create(v.Wheel2, TweenInfo.new(0.03, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Orientation = Vector3.new(leftSlotMachinesTargetRotationWheel23[rewardIndex2][1], leftSlotMachinesTargetRotationWheel23[rewardIndex2][2], leftSlotMachinesTargetRotationWheel23[rewardIndex2][3])}):Play()
				end)()

				coroutine.wrap(function()
					local tween = TweenService:Create(v.Wheel3, TweenInfo.new((spinTime + 6) / (numberOfSpins / 2), Enum.EasingStyle.Back, Enum.EasingDirection.In), {CFrame = v.Wheel3.CFrame * CFrame.Angles(-math.rad(179), 0, 0)})
					tween:Play()
					tween.Completed:Wait()

					for i = 1, numberOfSpins do
						local tween = TweenService:Create(v.Wheel3, TweenInfo.new((spinTime + 6) / (numberOfSpins * 6) + (i^3 / (numberOfSpins^3.1)), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.Wheel3.CFrame * CFrame.Angles(-math.rad(179), 0, 0)})
						tween:Play()
						tween.Completed:Wait()
					end

					local cpt = 0

					repeat
						local tween = TweenService:Create(v.Wheel3, TweenInfo.new(0.03, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.Wheel3.CFrame * CFrame.Angles(-math.rad(5), 0, 0)})
						tween:Play()
						tween.Completed:Wait()
						cpt += 1
					until (v.Wheel3.Orientation.X < leftSlotMachinesTargetRotationWheel23[rewardIndex3][1] + 5 and v.Wheel3.Orientation.X > leftSlotMachinesTargetRotationWheel23[rewardIndex3][1] - 5 and v.Wheel3.Orientation.Y == leftSlotMachinesTargetRotationWheel23[rewardIndex3][2]) or cpt > 100

					TweenService:Create(v.Wheel3, TweenInfo.new(0.03, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Orientation = Vector3.new(leftSlotMachinesTargetRotationWheel23[rewardIndex3][1], leftSlotMachinesTargetRotationWheel23[rewardIndex3][2], leftSlotMachinesTargetRotationWheel23[rewardIndex3][3])}):Play()

					--rewards
					local rewardsTable = {rewardIndex1, rewardIndex2, rewardIndex3}
					table.sort(rewardsTable)

					-- Three casino chips
					if rewardsTable[1] == 1 and rewardsTable[2] == 1 and rewardsTable[3] == 1 then
						CasinoChipBindableEvent:Fire(plr, 2, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(98,98,98)
						v.Prize.SurfaceGui.TextLabel.Text = "2 chips"

						-- Two casino chips and any third
					elseif rewardsTable[1] == 1 and rewardsTable[2] == 1 then
						CasinoChipBindableEvent:Fire(plr, 1, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(98,98,98)
						v.Prize.SurfaceGui.TextLabel.Text = "1 chips"

						-- Three pets
					elseif rewardsTable[1] == 3 and rewardsTable[2] == 3 and rewardsTable[3] == 3 then
						local pet, rarity = CasinoPetBindableFunction:Invoke(plr, "Rare", "Casino")

						if rarity then
							if rarity == "Common" then
								v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(55, 138, 189)
							elseif rarity == "Rare" then
								v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(32, 189, 45)
							elseif rarity == "Epic" then
								v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(159, 68, 189)
							else
								v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(220, 147, 21)
							end
						end

						if pet then
							v.Prize.SurfaceGui.TextLabel.Text = tostring(pet)
						end

						-- One money 2, one money 1 and one money 3
					elseif rewardsTable[1] == 2 and rewardsTable[2] == 4 and rewardsTable[3] == 5 then
						MoneyBindableFunction:Invoke(plr, 4000, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(37, 171, 27)
						v.Prize.SurfaceGui.TextLabel.Text = "$4000"

						-- Three money 2
					elseif (rewardsTable[1] == 2 and rewardsTable[2] == 2 and rewardsTable[3] == 2) then
						MoneyBindableFunction:Invoke(plr, 7500, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(37, 171, 27)
						v.Prize.SurfaceGui.TextLabel.Text = "$7500"

						-- Three money 1
					elseif (rewardsTable[1] == 4 and rewardsTable[2] == 4 and rewardsTable[3] == 4) then
						MoneyBindableFunction:Invoke(plr, 5000, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(37, 171, 27)
						v.Prize.SurfaceGui.TextLabel.Text = "$5000"

						-- Three money 3
					elseif (rewardsTable[1] == 5 and rewardsTable[2] == 5 and rewardsTable[3] == 5) then
						MoneyBindableFunction:Invoke(plr, 10000, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(37, 171, 27)
						v.Prize.SurfaceGui.TextLabel.Text = "$10000"

						-- Two money 2 and any third
					elseif (rewardsTable[2] == 2 and (rewardsTable[1] == 2 or rewardsTable[3] == 2)) then
						MoneyBindableFunction:Invoke(plr, 2000, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(37, 171, 27)
						v.Prize.SurfaceGui.TextLabel.Text = "$2000"

						-- Two money 1 and any third				
					elseif (rewardsTable[2] == 4 and (rewardsTable[1] == 4 or rewardsTable[3] == 4)) then
						MoneyBindableFunction:Invoke(plr, 1000, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(37, 171, 27)
						v.Prize.SurfaceGui.TextLabel.Text = "$1000"

						-- Two money 3 and any third				
					elseif (rewardsTable[2] == 5 and (rewardsTable[1] == 5 or rewardsTable[3] == 5)) then
						MoneyBindableFunction:Invoke(plr, 3000, "+")
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.fromRGB(37, 171, 27)
						v.Prize.SurfaceGui.TextLabel.Text = "$3000"

					else
						v.Prize.SurfaceGui.TextLabel.TextColor3 = Color3.new(1,1,1)
						v.Prize.SurfaceGui.TextLabel.Text = "Nothing :'("
					end

					v.ProximityPrompt.ProximityPrompt.Enabled = true
					v.IsSpinning.Value = false
				end)()

				--local TweenService = game:GetService("TweenService")
				--local spinTime = math.random(5, 7)
				--local v = workspace.Casino.RightSlotMachines.SlotMachine1
				--local numberOfSpins = math.random(30,40)
				--local tween = TweenService:Create(v.Wheel2, TweenInfo.new((spinTime + 6) / (numberOfSpins / 2), Enum.EasingStyle.Back, Enum.EasingDirection.In), {CFrame = v.Wheel2.CFrame * CFrame.Angles(-math.rad(179), 0, 0)})
				--tween:Play()
				--tween.Completed:Wait()
				--for i = 1, numberOfSpins do
				--	local tween = TweenService:Create(v.Wheel2, TweenInfo.new((spinTime + 6) / (numberOfSpins * 6) + (i^3 / (numberOfSpins^3.1)), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.Wheel2.CFrame * CFrame.Angles(-math.rad(179), 0, 0)})
				--	tween:Play()
				--	tween.Completed:Wait()
				--end

				--local cpt = 0

				--repeat
				--	local tween = TweenService:Create(v.Wheel2, TweenInfo.new(0.03, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.Wheel2.CFrame * CFrame.Angles(-math.rad(5), 0, 0)})
				--	tween:Play()
				--	tween.Completed:Wait()
				--	cpt += 1
				--until (v.Wheel2.Orientation.X < -50 and v.Wheel2.Orientation.X > -64 and v.Wheel2.Orientation.Y == -90) or cpt > 100
				--TweenService:Create(v.Wheel2, TweenInfo.new(0.03, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Orientation = Vector3.new(-57, -90, 0)}):Play()


				--coroutine.wrap(function()
				--	local speed = math.random(10,20)
				--	local speed1, speed2, speed3 = speed, speed + 1, speed + 2
				--	local con

				--	con = game:GetService("RunService").Heartbeat:Connect(function(dt)
				--		v.Wheel1.CFrame *= CFrame.Angles(dt * speed1, 0, 0)
				--		v.Wheel2.CFrame *= CFrame.Angles(dt * speed2, 0, 0)
				--		v.Wheel3.CFrame *= CFrame.Angles(dt * speed3, 0, 0)
				--		--speed  = math.max(speed - (dt * 2), 0)
				--		speed1  = speed1 - (dt * 2)
				--		speed2  = speed2 - (dt * 2)
				--		speed3  = speed3 - (dt * 2)

				--		if speed3 < 0.5 then
				--			con:Disconnect()
				--		end
				--	end)

				--TweenService:Create(v.Wheel1, TweenInfo.new(spinTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = Vector3.new(rightSlotMachinesTargetRotation[rewardIndex1] + spins, -90, 0)}):Play()
				--wait(0.5)

				--TweenService:Create(v.Wheel2, TweenInfo.new(spinTime + 3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = Vector3.new(rightSlotMachinesTargetRotation[rewardIndex2] + spins, -90, 0)}):Play()
				--wait(0.5)

				--local tween3 = TweenService:Create(v.Wheel3, TweenInfo.new(spinTime + 6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = Vector3.new(rightSlotMachinesTargetRotation[rewardIndex3] + spins, -90, 0)})
				--tween3:Play()

				--tween3.Completed:Wait()
				--end)()
			end
		end
	end)
end


-- PROBABILITIES OF WINNING AT THE SLOTS MACHINES
--local r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, noR = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
--local iterations = 100000
--for i = 1,iterations do
--	local rewardsTable = {math.random(1,5), math.random(1,5), math.random(1,5)}
--	table.sort(rewardsTable)

--	if rewardsTable[1] == 1 and rewardsTable[2] == 1 and rewardsTable[3] == 1 then
--		r1 += 1
--	elseif rewardsTable[1] == 1 and rewardsTable[2] == 1 then
--		r2 += 1
--	elseif rewardsTable[1] == 3 and rewardsTable[2] == 3 and rewardsTable[3] == 3 then
--		r3 += 1
--	elseif rewardsTable[1] == 2 and rewardsTable[2] == 4 and rewardsTable[3] == 5 then
--		r4 += 1
--	elseif (rewardsTable[1] == 2 and rewardsTable[2] == 2 and rewardsTable[3] == 2) then
--		r5 += 1
--	elseif (rewardsTable[1] == 4 and rewardsTable[2] == 4 and rewardsTable[3] == 4) then
--		r6 += 1
--	elseif (rewardsTable[1] == 5 and rewardsTable[2] == 5 and rewardsTable[3] == 5) then
--		r7 += 1
--	elseif (rewardsTable[2] == 2 and (rewardsTable[1] == 2 or rewardsTable[3] == 2)) then
--		r8 += 1
--	elseif (rewardsTable[2] == 4 and (rewardsTable[1] == 4 or rewardsTable[3] == 4)) then
--		r9 += 1
--	elseif (rewardsTable[2] == 5 and (rewardsTable[1] == 5 or rewardsTable[3] == 5)) then
--		r10 += 1
--	else
--		noR += 1
--	end
--end
--print("chance of winning nothing : "..noR / iterations * 100)
--print("chance of 1 : "..r1 / iterations * 100)
--print("chance of 2 : "..r2 / iterations * 100)
--print("chance of 3 : "..r3 / iterations * 100)
--print("chance of 4 : "..r4 / iterations * 100)
--print("chance of 5 : "..r5 / iterations * 100)
--print("chance of 6 : "..r6 / iterations * 100)
--print("chance of 7 : "..r7 / iterations * 100)
--print("chance of 8 : "..r8 / iterations * 100)
--print("chance of 9 : "..r9 / iterations * 100)
--print("chance of 10 : "..r10 / iterations * 100)


--local part = script.Parent
--local TweenService = game:GetService("TweenService")
--local slowestSpeed = 1
--local spinStep = math.pi/36 --three steps per section
--local friction = 0.5 --percent per step

--local function Spin(initialSpeed)

--	if initialSpeed <= slowestSpeed then
--		return
--	end
--	local speed = initialSpeed
--	local style = TweenInfo.new(1/speed,Enum.EasingStyle.Linear)
--	local target = {CFrame = part.CFrame * CFrame.Angles(0,spinStep,0)}
--	local tween = TweenService:Create(part,style,target)

--	local connection

--	local function OnCompletion()

--		connection:Disconnect()
--		speed = speed - (initialSpeed*friction/100)
--		if speed < slowestSpeed then
--			return
--		end
--		style = TweenInfo.new(1/speed,Enum.EasingStyle.Linear)
--		target = {CFrame = part.CFrame * CFrame.Angles(0,spinStep,0)}
--		tween = TweenService:Create(part,style,target)

--		connection = tween.Completed:Connect(OnCompletion)
--		tween:Play()
--	end

--	connection = tween.Completed:Connect(OnCompletion)
--	tween:Play()

--end

--Spin(50+math.random(50))