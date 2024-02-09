-- to make cars bigger, move everything
-- then add the weld constrainsts (destroyed when moved)
-- eventually, change the responsiveness property of the steeringprismatic in the constraints folder

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local Gui = script:WaitForChild("VehicleGui")

local LocalPlayer = Players.LocalPlayer
local ScriptsFolder = script.Parent:WaitForChild("ScriptsReference").Value

local PlayerModule = LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")
local PlayerControlModule = require(PlayerModule:WaitForChild("ControlModule"))
local Keymap = require(ScriptsFolder.Keymap)
local InputImageLibrary = require(ScriptsFolder.InputImageLibrary)

local VehicleGui = {}
VehicleGui.__index = VehicleGui

local MAX_SPEED = 130

function VehicleGui.new(car, seat)
	local self = setmetatable({}, VehicleGui)

	self.connections = {}
	self.car = car
	self.localSeatModule = require(ScriptsFolder.LocalVehicleSeating)
	self.chassis = car:WaitForChild("Chassis")
	self.seat = self.chassis:WaitForChild("VehicleSeat")
	self.gui = Gui:Clone()
	self.gui.Name = "ActiveGui"
	self.gui.Parent = script
	self.Leave = self.gui:WaitForChild("Leave")
	self.exitButtonDesktop = self.gui:WaitForChild("ExitButtonDesktop")
	self.exitButtonMobile = self.gui:WaitForChild("ExitButtonMobile")
	return self
end

----Handle the enabling and disabling of the default roblox jump button----
local function getLocalHumanoid()
	if LocalPlayer.Character then
		return LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	end
end

local oldHumanoidJumpPower = 50
local jumpDisabled = false
local function enableJumpButton()
	local humanoid = getLocalHumanoid()
	if jumpDisabled and humanoid then
		humanoid.JumpPower = oldHumanoidJumpPower
		jumpDisabled = false
	end
end

local function disableJumpButton()
	local humanoid = getLocalHumanoid()
	if humanoid then
		oldHumanoidJumpPower = humanoid.JumpPower
		humanoid.JumpPower = 0
		jumpDisabled = true
	end
end

function VehicleGui:Enable(Seat, Key)

	if not Key then

		self.gui.Enabled = true

		self:EnableKeyboardUI()
		local function UpdateInputType(inputType)
			if inputType == Enum.UserInputType.Touch then
				self.exitButtonMobile.Visible = true
				self:EnableTouchUI()
			elseif inputType.Value >= Enum.UserInputType.Gamepad1.Value and
				inputType.Value <= Enum.UserInputType.Gamepad8.Value then
				self:EnableGamepadUI()
			elseif inputType == Enum.UserInputType.Keyboard then
				self.Leave.Visible = true
				self:EnableKeyboardUI()
			end
		end
		self.connections[#self.connections + 1] = UserInputService.LastInputTypeChanged:Connect(UpdateInputType)
		UpdateInputType(UserInputService:GetLastInputType())

		--Destroy when player gets out of vehicle
		function self.OnExit(Seat)
			self.Leave.Visible = false
			self.exitButtonDesktop.Visible = false
			self.exitButtonMobile.Visible = false
			self:Destroy()
		end
		self.localSeatModule.OnSeatExitEvent(self.OnExit)

		--Destroy if the gui has been destroyed
		self.connections[#self.connections + 1] = self.gui.AncestryChanged:Connect(function()
			if not self.gui:IsDescendantOf(game) then
				self:Destroy()
			end
		end)

		--Destroy if vehicle is no longer in workspace
		self.connections[#self.connections + 1] = self.chassis.AncestryChanged:Connect(function()
			if not self.chassis:IsDescendantOf(Workspace) then
				self:Destroy()
			end
		end)

		--Connect the exit seat button
		self.connections[#self.connections + 1] = self.exitButtonMobile.Activated:Connect(function()
			enableJumpButton()
			self:Destroy()
			self.localSeatModule.ExitSeat()
		end)

		self.connections[#self.connections + 1] = self.exitButtonMobile.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				self.exitButtonMobile.ImageTransparency = 1
				self.exitButtonMobile.Pressed.ImageTransparency = 0
			end
		end)
		self.connections[#self.connections + 1] = self.exitButtonMobile.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				self.exitButtonMobile.ImageTransparency = 0
				self.exitButtonMobile.Pressed.ImageTransparency = 1
			end
		end)

		self.connections[#self.connections + 1] = RunService.RenderStepped:Connect(function()
			--Update the steering input if touch controls are enabled
			if self.touchEnabled then
				self.throttleInput = -PlayerControlModule:GetMoveVector().Z
				self.steeringInput = -PlayerControlModule:GetMoveVector().X
			end
		end)
	end
end

function VehicleGui:Destroy()
	self.localSeatModule.DisconnectFromSeatExitEvent(self.OnExit)
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end
	if self.gui then
		self.gui:Destroy()
	end
	enableJumpButton()
end

--If both DriverControls are enabled and touch controls are enabled then the accelerate and brake buttons will appear.
function VehicleGui:EnableDriverControls()
	self.driverControlsEnabled = true
end


function VehicleGui:EnableTouchControls()
	if self.touchEnabled then return end
	self.touchEnabled = true

	disableJumpButton()
end

function VehicleGui:DisableTouchControls()
	if not self.touchEnabled  then return end
	self.touchEnabled = false

	enableJumpButton()
end

function VehicleGui:EnableKeyboardUI()
	self:DisableTouchControls()
end

function VehicleGui:EnableTouchUI()
	self:EnableTouchControls()
end

function VehicleGui:EnableGamepadUI()
	self:DisableTouchControls()
end

return VehicleGui
