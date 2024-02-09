script.Parent.Touched:Connect(function(hit)
	local Character = hit.Parent
	local Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid then
		Humanoid.Sit = true
	end
end)