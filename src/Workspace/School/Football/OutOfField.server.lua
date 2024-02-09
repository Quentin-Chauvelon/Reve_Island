local wall1 = game.Workspace.School.Football.Wall1
local wall2 = game.Workspace.School.Football.Wall2
local wall3 = game.Workspace.School.Football.Wall3
local wall4 = game.Workspace.School.Football.Wall4

local function onPartTouched(OutOfField)
	if  OutOfField:IsA("Part") and OutOfField.Name == "Ball" then
		OutOfField.Anchored = true
		OutOfField.RotVelocity = Vector3.new(0,0,0)
		OutOfField.Velocity = Vector3.new(0,0,0)
		OutOfField.CFrame = game.Workspace.School.Football.BallPlacement.CFrame
		wait(0.1)
		OutOfField.Anchored = false
	end
end

wall1.Touched:Connect(onPartTouched)
wall2.Touched:Connect(onPartTouched)
wall3.Touched:Connect(onPartTouched)
wall4.Touched:Connect(onPartTouched)