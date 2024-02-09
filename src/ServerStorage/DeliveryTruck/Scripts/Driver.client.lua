local Workspace = game:GetService("Workspace")
local Marketplace = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RadioRemoteEvent = ReplicatedStorage:WaitForChild("Radio")

local CarValue = script:WaitForChild("CarValue")
local Car = CarValue.Value

local InputEnded = true
local Radio = false
local Headlights = false
local Horn = false
local HazardsLight = false

local RAW_INPUT_ACTION_NAME = "VehicleChassisRawInput"
local EXIT_ACTION_NAME = "VehicleChassisExitVehicle"

--Get modules

--Initialize Chassis
local ScriptsFolder = Car:FindFirstChild("Scripts")
local RadioGui = ScriptsFolder:WaitForChild("LocalVehicleGui"):WaitForChild("VehicleGui"):WaitForChild("Radio")
local Chassis = require(ScriptsFolder:WaitForChild("Chassis"))
Chassis.InitializeDrivingValues()
Chassis.Reset()

--Set up gui - has its own class
local VehicleGui = require(script.Parent:WaitForChild("LocalVehicleGui")).new(Car)
VehicleGui:Enable("Driver", nil)
VehicleGui:EnableDriverControls()

local Keymap = require(ScriptsFolder.Keymap)
local _rawInput = Keymap.newInputTable()
local LocalVehicleSeating = require(ScriptsFolder.LocalVehicleSeating)

local function _clearInput()
	for k, v in pairs(_rawInput) do
		_rawInput[k] = 0
	end
end

--Objects
local DriverSeat = Chassis.driverSeat


--Actions done on the car (headlights, horn...)
local function CarActions(Input, gameProcessed, Ended)
	if InputEnded and not gameProcessed then
		if Input.UserInputType == Enum.UserInputType.Keyboard then
			if Input.KeyCode == Enum.KeyCode.V then
				VehicleGui:Enable("Driver", "V")

			elseif Input.KeyCode == Enum.KeyCode.R then
				VehicleGui:Enable("Driver", "R")
				InputEnded = false
			elseif Input.KeyCode == Enum.KeyCode.F then
				VehicleGui:Enable("Driver", "F")
				InputEnded = false

			elseif Input.KeyCode == Enum.KeyCode.G then
				VehicleGui:Enable("Driver", "G")
				InputEnded = false

			elseif Input.KeyCode == Enum.KeyCode.H then
				VehicleGui:Enable("Driver", "H")
				InputEnded = false
			end
		end
		wait(0.5) -- if not waiting, then tapping is considered as a full input
		InputEnded = true
	end
end

UserInputService.InputBegan:Connect(CarActions)
UserInputService.InputEnded:Connect(CarActions)


-- Radio
local RadioGui = script.Parent:WaitForChild("LocalVehicleGui"):WaitForChild("ActiveGui"):WaitForChild("Radio")
local Sound = Car.Body.Radio.Sound
local IsSongPlaying = false

RadioGui.SongID.Activated:Connect(function()
	RadioGui.SongID.TextBox:CaptureFocus()
end)

RadioGui.SongID.Search.Activated:Connect(function()
	if Sound then

		local success, songinfo = pcall(Marketplace.GetProductInfo, Marketplace, tonumber(RadioGui.SongID.TextBox.Text))

		if success and songinfo.AssetTypeId == 3 then

			RadioRemoteEvent:FireServer("Play", tonumber(RadioGui.SongID.TextBox.Text))

			Sound.SoundId = "rbxassetid://"..songinfo.AssetId -- set the sound id 
			RadioGui.SongPlaying.SongName.Text = "Loading..." -- loading text before it loads
			Sound.Loaded:Wait() -- wait for the sound to load
			RadioGui.SongPlaying.SongName.Text = songinfo.Name.." ("..Sound.TimeLength.."s)" -- display the name and the length of the sound
			--IsSongPlaying = true -- song is playing
			--Sound:Play() -- play the sound

			--coroutine.wrap(function()
			--	RunService.Stepped:Connect(function()
			--		if IsSongPlaying then
			--			RadioGui.SongPlaying.Time.Size = UDim2.new((Sound.TimePosition / Sound.TimeLength),0,0.15,0) -- update the size of the time bar	
			--		else
			--			return -- return to avoid runservice.stepped with nothing inside
			--		end	
			--	end)
			--end)() -- call coroutine
		else
			RadioGui.SongPlaying.SongName.Text = "Can't load song" -- can't load sound
			return
		end
	end
end)

RadioGui.SongPlaying.Play.Activated:Connect(function()
	--Sound:Resume() -- resume the sound
	--IsSongPlaying = true -- sound is playing
	RadioRemoteEvent:FireServer("Resume")
end)

RadioGui.SongPlaying.Pause.Activated:Connect(function()
	--Sound:Pause() -- pause the sound
	--IsSongPlaying = false -- sound is not playing
	RadioRemoteEvent:FireServer("Pause")
end)

local function unbindActions()
	ContextActionService:UnbindAction(RAW_INPUT_ACTION_NAME)
	ContextActionService:UnbindAction(EXIT_ACTION_NAME)
end

local function onExitSeat(Seat)
	unbindActions()
	_clearInput()
	ProximityPromptService.Enabled = true
	LocalVehicleSeating.DisconnectFromSeatExitEvent(onExitSeat)
	script.Disabled = true
end
LocalVehicleSeating.OnSeatExitEvent(onExitSeat)

--Disable script if car is removed from workspace
Car.AncestryChanged:Connect(function()
	if not Car:IsDescendantOf(Workspace) then
		unbindActions()

		LocalVehicleSeating.ExitSeat()
		LocalVehicleSeating.DisconnectFromSeatExitEvent(onExitSeat)
		-- stop seated anim
		--print("car removed from workspace")

		script.Disabled = true
		ProximityPromptService.Enabled = true
	end
end)

local function exitVehicle(action, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then
		LocalVehicleSeating.ExitSeat()
		-- stop seated anim
	end
end

local function _updateRawInput(_, inputState, inputObj)
	local key = inputObj.KeyCode
	local data = Keymap.getData(key)
	
	if not data then 
		return
	end
	
	local axis = data.Axis
	local val = 0
	
	if axis then
		val = inputObj.Position:Dot(axis)
	else
		val = (inputState == Enum.UserInputState.Begin or inputState == Enum.UserInputState.Change) and 1 or 0
	end
	
	val = val * (data.Sign or 1)
	
	_rawInput[key] = val
	
	if data.Pass then
		return Enum.ContextActionResult.Pass
	end
end

local function _calculateInput(action)
	-- Loop through all mappings for this action and calculate a resultant value from the raw input
	local mappings = Keymap[action]
	local val = 0
	local absVal = val
	
	for _, data in ipairs(mappings) do
		local thisVal = _rawInput[data.KeyCode]
		if math.abs(thisVal) > absVal then
			val = thisVal
			absVal = math.abs(val)
		end
	end
	
	return val
end

ContextActionService:BindAction(
	EXIT_ACTION_NAME,
	exitVehicle,
	false,
	Keymap.EnterVehicleGamepad,
	Keymap.EnterVehicleKeyboard,
	Enum.KeyCode.Space
)

ContextActionService:BindActionAtPriority(
	RAW_INPUT_ACTION_NAME,
	_updateRawInput,
	false,
	Enum.ContextActionPriority.High.Value,
	unpack(Keymap.allKeys()))

--Interpret input
local function getInputValues()
	if UserInputService:GetLastInputType() ~= Enum.UserInputType.Touch then
		---Let the control module handle all none-touch controls
		script.Throttle.Value = _calculateInput("Throttle") - _calculateInput("Brake")
		script.Steering.Value = _calculateInput("SteerLeft") + _calculateInput("SteerRight")

	else --The vehicle gui handles all the touch controls
		script.Throttle.Value = VehicleGui.throttleInput
		script.Steering.Value = VehicleGui.steeringInput
	end
end

ProximityPromptService.Enabled = false

-- Driver Input Loop --
while script.Parent ~= nil do
	--Update throttle, steer
	getInputValues()

	local currentVel = Chassis.GetAverageVelocity()

	local steer = script.Steering.Value
	Chassis.UpdateSteering(steer, currentVel)

	-- Taking care of throttling
	local throttle = script.Throttle.Value
	script.AngularMotorVelocity.Value = currentVel
	script.ForwardVelocity.Value = DriverSeat.CFrame.LookVector:Dot(DriverSeat.Velocity)
	Chassis.UpdateThrottle(currentVel, throttle)

	wait()
end