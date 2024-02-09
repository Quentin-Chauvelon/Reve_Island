local Debris = game:GetService("Debris")
local cooldown = false


script.Parent.BowRemoteEvent.OnServerEvent:Connect(function(plr, instruction, charge, mHit)
	if script.Parent.Parent == plr.Character and not cooldown and instruction == "shoot" then

		cooldown = true

		local newArrow = script.Parent.Arrow:Clone()
		script.Parent.Arrow.Transparency = 1
		newArrow.CFrame = CFrame.new(newArrow.Position, mHit.Position)
		newArrow.Orientation = Vector3.new(0,180,0)
		newArrow.Velocity = mHit.LookVector * charge * 180
		newArrow.Parent = workspace
		
		local touched = false

		newArrow.Touched:Connect(function(hit)
			if hit.Parent and hit.Parent ~= plr.Character and hit.Parent.Name ~= "Bow" and hit.Parent.Name ~= "LayersTriggers" and not touched then

				touched = true
				newArrow:Destroy()
				
				-- If a bow is touching the miner, damage or kill him 
				if hit.Parent:FindFirstChild("Humanoid") and hit.Parent:FindFirstChild("HitCooldown") then
					
					-- If the sword deals more damage than the miner's health, destroy and respawn him
					if (charge * 700) >= hit.Parent:FindFirstChild("Humanoid").Health then

						-- Find the spawn position that has the miner index to respawn him
						for i,v in ipairs(workspace.Mines.SpawnPositions:GetChildren()) do
							if v.Index.Value == hit.Parent.Index.Value then -- if the part index is the same as the miner's one
								v.Respawn.Value = true -- respawn him
								break
							end
						end

						hit.Parent:Destroy() -- destroy the miner

						-- Otherwise, damage him
					else
						hit.Parent:FindFirstChild("Humanoid"):TakeDamage(charge * 700)
					end
				end
			end
		end)

		script.Parent.BowRemoteEvent:FireClient(plr, newArrow, charge)
		wait(1)
		script.Parent.Arrow.Transparency = 0
		cooldown = false


	elseif instruction == "string" then
		script.Parent.Bow.Middle.Position = charge
		script.Parent.Bow.WeldConstraint.Part1 = mHit
	end
end)