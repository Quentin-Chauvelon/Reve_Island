local PlayerJumpsTable = {}

-- Destroy the trampoline after 25 seconds
game:GetService("Debris"):AddItem(script.Parent.Parent, 25)


-- BOUNCING PART TOUCHED EVENT

script.Parent.Touched:Connect(function(hit)
	
	if hit.Name == "LeftFoot" and hit.Parent:FindFirstChild("Humanoid") then
		if PlayerJumpsTable[hit.Parent.Name] then
			
			PlayerJumpsTable[hit.Parent.Name] *=  1.25 -- Multiply the jump height by 1.25 so that the player bounces higher
			hit.Parent:FindFirstChild("Humanoid").JumpHeight = math.min(PlayerJumpsTable[hit.Parent.Name], 200) -- Max jump height of 200
			hit.Parent:FindFirstChild("Humanoid").Jump = true
			
			coroutine.wrap(function()
				wait(0.2)
				hit.Parent:FindFirstChild("Humanoid").JumpHeight = 7.5
			end)()
		else
			PlayerJumpsTable[hit.Parent.Name] = 7.5
		end
	end
end)