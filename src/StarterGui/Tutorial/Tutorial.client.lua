local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TutorialRemoteEvent = ReplicatedStorage:WaitForChild("Tutorial")

local CurrentCamera = workspace.CurrentCamera
local TutorialFolder = workspace.Tutorials

local lplr = game.Players.LocalPlayer
local TutorialGui = lplr.PlayerGui:WaitForChild("Tutorial")
local StepText = TutorialGui:WaitForChild("Frame"):WaitForChild("TextLabel")

local Step = 1
local SecondsPerStud = 0.005

local StepTexts = {
	'You can play as a student on different subjects (maths, music, art...).',
	'You can also roleplay in a lot of jobs, to start working, you either have to enter the building',
	'or get into the red circles.',
	'Once you completed a task, you get both <font color="#2b993c">money ($)</font> and <font color="#2f82b6">experience (¤)</font> (level up your experience in all the jobs and get rewards).',
	'Collect and customize amazing pets (with custom names, name colors, trails...) and use their unique abilities.',
	'Buy awesome cars and customize them at the garage.',
	'Upgrade and customize your house to fit your style (amazing furnitures coming soon).',
	'Now you are ready to start playing. Have fun!',
}

local YesClicked, NoClicked, NextClicked, PlayClicked


-- TYPE WRITER EFFECT

local function TypeWriting(Text)
	
	StepText.MaxVisibleGraphemes = 0
	StepText.Text = Text
	
	-- Display the text character by character
	for i=1,#Text do -- for every character of the text
		StepText.MaxVisibleGraphemes = i -- add characters one by one
		RunService.Heartbeat:Wait() --  wait for 1/60th of a second (depends of the fps)
	end
	
	StepText.MaxVisibleGraphemes = -1 -- set it to -1 to display the full text
end


-- TWEEN THE CAMERA (FOLLOWING THE ROAD)

local function CreateStepTween(StepFolder)

	if StepFolder then
		for i=1,#StepFolder:GetChildren() do

			if StepFolder:FindFirstChild(i) then
				local Info = TweenInfo.new(
					(StepFolder[i].Position - TutorialFolder.CameraPosition.Position).Magnitude * SecondsPerStud,
					Enum.EasingStyle.Linear
				)

				local Tween = TweenService:Create(CurrentCamera, Info, {CFrame = StepFolder[i].CFrame})
				Tween:Play()
				Tween.Completed:Wait()
				
				TutorialFolder.CameraPosition.CFrame = CurrentCamera.CFrame
			end
		end
	end
end
CurrentCamera.CameraType = Enum.CameraType.Custom


-- TUTORIAL REMOTE EVENT FIRED FROM THE SERVER TO START THE TUTORIAL

script.Parent:WaitForChild("Loaded")
repeat wait(1) until script.Parent.Loaded.Value

if script.Parent.NewPlayer.Value then
--TutorialRemoteEvent.OnClientEvent:Connect(function()
	
	-- Show the welcome gui
	TutorialGui:WaitForChild("Welcome").Visible = true
	
	-- Player clicks yes to follow the tutorial
	YesClicked = TutorialGui.Welcome.Yes.MouseButton1Down:Connect(function()
		YesClicked:Disconnect()
		NoClicked:Disconnect()
		
		TutorialGui.Welcome.Visible = false
		
		CurrentCamera.CameraType = Enum.CameraType.Scriptable
		
		local Tween = TweenService:Create(CurrentCamera, TweenInfo.new((TutorialFolder.StartPosition.Position - TutorialFolder.CameraPosition.Position).Magnitude * SecondsPerStud, Enum.EasingStyle.Linear), {CFrame = TutorialFolder.StartPosition.CFrame})
		Tween:Play()
		Tween.Completed:Wait()
		wait(1)
		
		CreateStepTween(TutorialFolder[tostring(Step)])
		
		TutorialGui.Frame.Visible = true
		
		-- Write the text for each step
		StepText.Text = ""
		if StepTexts[Step] then
			TypeWriting(StepTexts[Step])
		end

		if not NextClicked then
			NextClicked = TutorialGui.Frame.Next.MouseButton1Down:Connect(function()
				
				-- Go to the next step and tween the camera
				Step += 1
				
				
				if Step < 7 then

					-- Tween the camera (following the road)
					CreateStepTween(TutorialFolder[tostring(Step)])

					-- Write the text for each step
					StepText.Text = ""
					if StepTexts[Step] then
						TypeWriting(StepTexts[Step])
					end

				-- If it's the last step
				elseif Step == 7 then
					NextClicked:Disconnect()
					
					TutorialGui.Frame.Next.Visible = false
					TutorialGui.Frame.Play.Visible = true
					
					PlayClicked = TutorialGui.Frame.Play.MouseButton1Down:Connect(function()
						Step += 1
						
						if Step == 8 then
							-- Write the text for each step
							StepText.Text = ""
							if StepTexts[Step] then
								TypeWriting(StepTexts[Step])
							end
							
						-- Player finished the tutorial
						else
							PlayClicked:Disconnect()
							TutorialGui.Frame.Visible = false
							CurrentCamera.CameraType = Enum.CameraType.Custom
						end
					end)
					
					if workspace.Houses:FindFirstChild(lplr.Name) and workspace.Houses[lplr.Name]:FindFirstChild("HouseCamera") then
						TweenService:Create(CurrentCamera, TweenInfo.new(4, Enum.EasingStyle.Linear), {CFrame = workspace.Houses[lplr.Name].HouseCamera.CFrame}):Play()
						wait(4)
					end
					
					-- Write the text for each step
					if StepTexts[Step] then
						TypeWriting(StepTexts[Step])
					end
				end
			end)
		end
	end)

	-- Player clicks no and starts to play
	NoClicked = TutorialGui.Welcome.No.MouseButton1Down:Connect(function()
		TutorialGui.Welcome.Visible = false
	end)
--end)
end