local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FeedbackRemoteEvent = ReplicatedStorage:WaitForChild("Feedback")

local lplr = game.Players.LocalPlayer
local FeedbackGUI = script.Parent
FeedbackGUI:WaitForChild("Frame"):WaitForChild("Frame"):WaitForChild("Player").Text = lplr.Name


-- PLAYER OPENS AND CLOSES THE GUI

FeedbackGUI.Button.MouseButton1Down:Connect(function()
	
	-- If the gui is opened, close it, otherwise open it
	if FeedbackGUI.Open.Value then
		FeedbackGUI.Open.Value = false
		
		-- Hide gui
		FeedbackGUI.Frame:TweenPosition(UDim2.new(-0.5,0,0.5,0))
		wait(1)
		FeedbackGUI.Frame.Visible = false
		
		
	else
		FeedbackGUI.Open.Value = true

		-- Show gui
		FeedbackGUI.Frame.Frame.Visible = true
		FeedbackGUI.Frame.Thanks.Visible = false
		FeedbackGUI.Frame.Visible = true
		FeedbackGUI.Frame:TweenPosition(UDim2.new(0.5,0,0.5,0))
	end
end)


-- PLAYER CLICKS THE SEND BUTTON

FeedbackGUI.Frame.Frame.Send.MouseButton1Down:Connect(function()
	if lplr.CanSendFeedback.Value then
		FeedbackRemoteEvent:FireServer(FeedbackGUI.Frame.Frame.Frame.Feedback.Text)
		FeedbackGUI.Frame.Frame.Visible = false
		FeedbackGUI.Frame.Thanks.Visible = true

	else
		FeedbackGUI.Frame.Frame.Visible = false
		FeedbackGUI.Frame.Once.Visible = true
	end
end)