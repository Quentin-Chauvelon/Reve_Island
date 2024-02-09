-- 6858402017

local ProximityPromptService = game:GetService("ProximityPromptService")
local screenGui = script.Parent
local CarValue = script:WaitForChild("CarValue")
local Car = CarValue.Value
local Keymap = require(Car.Scripts.Keymap)
local InputImageLibrary = require(Car.Scripts.InputImageLibrary)
local lplr = game.Players.LocalPlayer

local MIN_FLIP_ANGLE = 70 --degrees from vertical

--Tell if a seat is flipped
local function isFlipped(Seat)
	local UpVector = Seat.CFrame.upVector
	local Angle = math.deg(math.acos(UpVector:Dot(Vector3.new(0, 1, 0))))
	return Angle >= MIN_FLIP_ANGLE
end

local function createPrompt(prompt, inputType)

	-- If the player owns the car, show him the enter gui, otherwise show him the price gui
	--print("car", lplr:FindFirstChild("Cars"), prompt.Parent.Parent.Parent.Parent.Body.Body.PriceGui.CarName.Value, lplr.Cars:FindFirstChild(prompt.Parent.Parent.Parent.Parent.Body.Body.PriceGui.CarName.Value))
	if not prompt.Parent.Parent.Parent.Parent:FindFirstChild("Body") or not prompt.Parent.Parent.Parent.Parent.Body:FindFirstChild("Body") or not prompt.Parent.Parent.Parent.Parent.Body.Body:FindFirstChild("PriceGui") or (lplr:FindFirstChild("Cars") and lplr.Cars:FindFirstChild(prompt.Parent.Parent.Parent.Parent.Body.Body.PriceGui.CarName.Value) and lplr.Cars[prompt.Parent.Parent.Parent.Parent.Body.Body.PriceGui.CarName.Value].Value) then

		local seat = prompt.Parent.Parent
		local buttonGui = script:WaitForChild("ButtonGuiPrototype")
		local promptUI = buttonGui:Clone()
		promptUI.Name = "ButtonGui"
		promptUI.Enabled = true
		promptUI.Adornee = prompt.Parent


		local BackgroundDesktop = promptUI:WaitForChild("BackgroundDesktop")
		local EnterDesktopButton = BackgroundDesktop:WaitForChild("DesktopButton")
		local DesktopButtonPrompt = BackgroundDesktop:WaitForChild("ButtonPrompt")
		local EnterMobileButton = promptUI:WaitForChild("MobileButton")
		local MobileImage = EnterMobileButton:WaitForChild("ImageLabel")

		--Switch button type
		local DriverButtonId
		local DriverButtonPressedId
		local PassengerButtonId
		local PassengerButtonPressedId

		if inputType == Enum.ProximityPromptInputType.Keyboard or inputType == Enum.ProximityPromptInputType.Gamepad then
			EnterMobileButton.Visible = false

			DriverButtonId = "rbxassetid://6858646286"
			DriverButtonPressedId = "rbxassetid://2848250902"
			PassengerButtonId = "rbxassetid://6856222377"
			PassengerButtonPressedId = "rbxassetid://2848251564"
			--EnterImageButton.Size = UDim2.new(0, 37, 0, 37)

			BackgroundDesktop.Visible = true
			--BackgroundDesktop.Size =  UDim2.new(0, 97, 0, 46)
			--BackgroundDesktop.Position = UDim2.new(0.5, 28, 0.5, 0)

			--ButtonPrompt.Visible = true
			--ButtonPrompt.Image = "rbxassetid://2935912536"
			--ButtonPrompt.Size = UDim2.new(0, 36, 0, 36)
			--ButtonPrompt.Position = UDim2.new(0.5, -46, 0.5, 0)
			--ButtonPrompt.TextLabel.Visible = true

			--Display the correct key
			--ButtonPrompt.TextLabel.Text = Keymap.EnterVehicleKeyboard.Name

			--elseif inputType == Enum.ProximityPromptInputType.Gamepad then
			--	DriverButtonId = "rbxassetid://2848635029"
			--	DriverButtonPressedId = "rbxassetid://2848635029"
			--	PassengerButtonId = "rbxassetid://2848636545"
			--	PassengerButtonPressedId = "rbxassetid://2848636545"
			--	EnterImageButton.Size = UDim2.new(0, 60, 0, 60)

			--	BackgroundDesktop.Visible = false

			--	ButtonPrompt.Visible = true
			--	--ButtonPrompt.Image = "rbxassetid://408462759"
			--	ButtonPrompt.Size = UDim2.new(0, 46, 0, 46)
			--	ButtonPrompt.Position = UDim2.new(0.5, -63, 0.5, 0)
			--	ButtonPrompt.ImageRectSize = Vector2.new(71, 71)
			--	ButtonPrompt.ImageRectOffset = Vector2.new(512, 600)
			--	ButtonPrompt.TextLabel.Visible = false

			--	--Set the correct image for the gamepad button prompt
			--	local template = InputImageLibrary:GetImageLabel(Keymap.EnterVehicleGamepad, "Light")
			--	ButtonPrompt.Image = template.Image
			--	ButtonPrompt.ImageRectOffset = template.ImageRectOffset
			--	ButtonPrompt.ImageRectSize = template.ImageRectSize

		elseif inputType == Enum.ProximityPromptInputType.Touch then
			BackgroundDesktop.Visible = false

			DriverButtonId = "rbxassetid://6858646286"
			DriverButtonPressedId = "rbxassetid://2847898354"
			PassengerButtonId = "rbxassetid://6856222377"
			PassengerButtonPressedId = "rbxassetid://2848218107"
			--EnterImageButton.Size = UDim2.new(0, 44, 0, 44)		

			EnterMobileButton.Visible = true

			EnterMobileButton.InputBegan:Connect(function(input)
				prompt:InputHoldBegin()
			end)

			EnterMobileButton.InputEnded:Connect(function(input)
				prompt:InputHoldEnd()
			end)

			promptUI.Active = true
		end

		--if isFlipped(seat) then
		--	FlipImageButton.Visible = true
		--	EnterImageButton.Visible = false
		--else
		--	FlipImageButton.Visible = false
		--	EnterImageButton.Visible = true
		--end

		if seat.Name == "VehicleSeat" then
			EnterDesktopButton.Image = DriverButtonId
			EnterDesktopButton.Pressed.Image = DriverButtonPressedId
			MobileImage.Image = DriverButtonId
			MobileImage.Pressed.Image = DriverButtonPressedId
		else
			EnterDesktopButton.Image = PassengerButtonId
			EnterDesktopButton.Pressed.Image = PassengerButtonPressedId
			MobileImage.Image = PassengerButtonId
			MobileImage.Pressed.Image = PassengerButtonPressedId
		end

		return promptUI

		-- Player doesn't own the car
	else
		-- Copy the empty price billboard so that when the player moves away from the car, the prompt hidden function fires and we can hide the real price billboard gui
		local priceGui = script:WaitForChild("PricePrototype")
		local promptUI = priceGui:Clone()
		promptUI.Name = "PriceGui"
		promptUI.Adornee = prompt.Parent


		prompt.Parent.Parent.Parent.Parent.Body.Body.PriceGui.Enabled = true

		return promptUI
	end
end

ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
	if prompt.Name == "EndorsedVehicleProximityPromptV1" then
		local promptUI = createPrompt(prompt, inputType)
		promptUI.Parent = screenGui
		prompt.PromptHidden:Wait()

		if prompt.Parent.Parent.Parent.Parent.Body:FindFirstChild("Body") then
			prompt.Parent.Parent.Parent.Parent.Body.Body.PriceGui.Enabled = false
		end

		promptUI.Parent = nil
	end
end)
