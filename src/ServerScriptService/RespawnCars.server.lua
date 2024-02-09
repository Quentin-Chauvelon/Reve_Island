local ServerStorage = game:GetService("ServerStorage")
local CarsStorage = ServerStorage:WaitForChild("Cars")

local RespawnCars = workspace:WaitForChild("RespawnCars")
local RespawnCarsPosition = RespawnCars:WaitForChild("Positions")
local Casters = RespawnCars:WaitForChild("Caster")

while true do
	
	-- For all the cars positions, check if the corresponding car (same name) is in the respawn cars folder, otherwise it has been taken
	for i,v in ipairs(RespawnCarsPosition:GetChildren()) do
		if not RespawnCars:FindFirstChild(v.Name) then

			if Casters:FindFirstChild(v.Name.."Caster") and Casters:FindFirstChild(v.Name.."CasterDirection") then
				
				-- Check if there is nothing in the way to spawn the car
				local RaycastResult = workspace:Raycast(Casters[v.Name.."Caster"].Position, (Casters[v.Name.."CasterDirection"].Position - Casters[v.Name.."Caster"].Position).Unit * 27)
				
				if not RaycastResult then

					-- Respawn the car
					if CarsStorage:FindFirstChild(v.CarName.Value) then
						local Car = CarsStorage[v.CarName.Value]:Clone()
						Car:SetPrimaryPartCFrame(v.CFrame)
						Car.Name = v.Name
						Car.Parent = RespawnCars
					end
				end
			end
		end
		wait(2)
		
	end
	wait(5)
end