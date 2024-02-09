local Trigger = script.Parent

Trigger.Touched:Connect(function(hit)
	local Character = hit.Parent
	local Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid then
		Humanoid.JumpHeight = math.random(10,100)
		Humanoid.Jump = true
		wait(0.1)
		Humanoid.JumpHeight = 7.5
	end
end)