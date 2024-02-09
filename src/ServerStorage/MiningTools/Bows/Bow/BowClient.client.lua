local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local mouse = game.Players.LocalPlayer:GetMouse()
local buttonDown = false
local lplr = game.Players.LocalPlayer
local connection1, connection2, connection3, connection4, connection5

script.Parent:WaitForChild("BowRemoteEvent")


-- DSEKTOP

script.Parent.Equipped:Connect(function()
	connection1 = mouse.Button1Down:Connect(function()
		buttonDown = true
	end)

	connection2 = mouse.Button1Up:Connect(function()
		script.Parent.BowRemoteEvent:FireServer("shoot", -script.Parent.Bow.Middle.Position.Z, mouse.Hit)
		buttonDown = false
	end)


	-- MOBILE

	connection3 = UserInputService.TouchStarted:Connect(function()
		buttonDown = true
	end)

	connection4 = UserInputService.TouchEnded:Connect(function()
		script.Parent.BowRemoteEvent:FireServer("shoot", -script.Parent.Bow.Middle.Position.Z, mouse.Hit)
		buttonDown = false
	end)

	
	connection5 = RunService.RenderStepped:Connect(function()
		if buttonDown then
			script.Parent.Bow.Middle.Position = script.Parent.Bow.Middle.Position:Lerp(Vector3.new(0, 0, -1.5), 0.1)
		else    
			script.Parent.Bow.Middle.Position = script.Parent.Bow.Middle.Position:Lerp(Vector3.new(0, 0, -0.5), 0.7)
		end
	end)
end)


-- DISCONNECT EVENT ON TOOL UNEQUIPPED

script.Parent.Unequipped:Connect(function()
	connection1:Disconnect()
	connection2:Disconnect()
	connection3:Disconnect()
	connection4:Disconnect()
	connection5:Disconnect()
end)


-- FAKE ARROW (BECAUSE THE ARROW FIRED FROM THE SERVER LAGS WHEN SHOT (IT STOPS MID AIR FOR A SECOND WHICH LOOKS ODD))

script.Parent.BowRemoteEvent.OnClientEvent:Connect(function(arrow, charge)

	arrow:Destroy() -- destroy the server arrow to avoid having 2 arrows
	
	-- Create and fire the new arrow
	local newArrow = script.Parent.Arrow:Clone()
	newArrow.Transparency = 0
	newArrow.CFrame = CFrame.new(newArrow.Position, mouse.Hit.Position + Vector3.new(0,90,0))
	newArrow.Orientation = Vector3.new(0,180,0)
	newArrow.Velocity = mouse.Hit.LookVector * charge * 180
	newArrow.Parent = workspace

	newArrow.Touched:Connect(function(hit) -- destroy it once it touches something
		if hit.Parent ~= lplr.Character and hit.Parent.Name ~= "Bow" then
			newArrow:Destroy()
		end
	end)
end)


-- DRAW THE BOW

while wait(0.1) do
	script.Parent.BowRemoteEvent:FireServer("string", script.Parent.Bow.Middle.Position, script.Parent.Bow.WeldConstraint.Part1)
end