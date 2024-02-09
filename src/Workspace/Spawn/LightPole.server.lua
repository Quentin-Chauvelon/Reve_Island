local Lighting = game:GetService("Lighting")

while true do
	if Lighting.ClockTime > 18 and Lighting.ClockTime < 22 then
		for i,v in ipairs(game.Workspace.Spawn.LightPoles:GetChildren()) do
			for i,v in ipairs(v:GetChildren()) do
				if v.Name == "Light" then
					v.SpotLight.Enabled = true
				end
			end
		end
	end

	if Lighting.ClockTime > 22 and Lighting.ClockTime < 22.5 then
		wait(5)
			for i,v in ipairs(game.Workspace.Spawn.LightPoles:GetChildren()) do
				for i,v in ipairs(v:GetChildren()) do
					if v.Name == "Light" then
						v.SpotLight.Enabled = false
					end
				end
		end
	end

	wait(1)
end