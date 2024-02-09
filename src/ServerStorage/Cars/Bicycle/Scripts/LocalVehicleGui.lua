local MarketPlaceService = game:GetService("MarketplaceService")
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

local Radio = false
local Headlights = false
local Horn = false
local HazardsLights = false

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
	self.keyDisplayDesktop = self.gui:WaitForChild("KeyDisplayDesktop")
	self.keyButtonsMobile = self.gui:WaitForChild("KeyButtonsMobile")
	self.flipButtonMobile = self.keyButtonsMobile:WaitForChild("Flip")
	self.radioButtonMobile = self.keyButtonsMobile:WaitForChild("Radio")
	self.headlightsButtonMobile = self.keyButtonsMobile:WaitForChild("Headlights")
	self.hornButtonMobile = self.keyButtonsMobile:WaitForChild("Horn")
	self.hazardsLightsButtonMobile = self.keyButtonsMobile:WaitForChild("HazardsLights")
	self.exitButtonDesktop = self.gui:WaitForChild("ExitButtonDesktop")
	self.exitButtonMobile = self.gui:WaitForChild("ExitButtonMobile")
	self.radioGui = self.gui:WaitForChild("Radio")
	
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
	local HazardsLightsOn = function()
		--while HazardsLights == true do
			--self.car.Body.FrontLeftLight.Transparency = 0
			--self.car.Body.FrontRightLight.Transparency = 0
			
			--self.car.Body.LeftIndicator.Transparency = 0
			--self.car.Body.RightIndicator.Transparency = 0
			--wait(0.5)
			--self.car.Body.FrontLeftLight.Transparency = 0.5
			--self.car.Body.FrontRightLight.Transparency = 0.5
			--self.car.Body.LeftIndicator.Transparency = 0.5
			--self.car.Body.RightIndicator.Transparency = 0.5
			--wait(0.5)
		--end
	end

	if not Key then

		self.gui.Enabled = true

		self:EnableKeyboardUI()
		local function UpdateInputType(inputType)
			if inputType == Enum.UserInputType.Touch then
				self.exitButtonMobile.Visible = true
				if Seat == "Driver" then
					self.keyButtonsMobile.Visible = true
				end
				self:EnableTouchUI()
			elseif inputType.Value >= Enum.UserInputType.Gamepad1.Value and
				inputType.Value <= Enum.UserInputType.Gamepad8.Value then
				self:EnableGamepadUI()
			elseif inputType == Enum.UserInputType.Keyboard then
				if Seat == "Driver" then
					self.keyDisplayDesktop.Visible = true
				elseif Seat == "Passenger" then
					self.exitButtonDesktop.Visible = true
				end
				self:EnableKeyboardUI()
			end
		end
		self.connections[#self.connections + 1] = UserInputService.LastInputTypeChanged:Connect(UpdateInputType)
		UpdateInputType(UserInputService:GetLastInputType())

		--Destroy when player gets out of vehicle
		function self.OnExit(Seat)
			self.keyDisplayDesktop.Visible = false
			self.exitButtonDesktop.Visible = false
			self.exitButtonMobile.Visible = false
			self.keyButtonsMobile.Visible = false
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

		self.connections[#self.connections + 1] = self.flipButtonMobile.Activated:Connect(function()
			--Tell if a seat is flipped
			local UpVector = self.car.Chassis.VehicleSeat.CFrame.upVector
			local Angle = math.deg(math.acos(UpVector:Dot(Vector3.new(0, 1, 0))))
			if Angle >= 70 then
				local Chassis = require(self.car.Chassis.VehicleSeat.Parent.Parent.Scripts.Chassis)
				Chassis.Redress()
			end
		end)

		self.connections[#self.connections + 1] = self.radioButtonMobile.Activated:Connect(function()
			if LocalPlayer.GamePasses.Radio.Value then
				-- If the player already owns the pass, he can't buy it again

				if Radio then
					Radio = false
					self.radioGui.Visible = false
				else
					Radio = true
					self.radioGui.Visible = true
				end

			else
				MarketPlaceService:PromptGamePassPurchase(LocalPlayer, 42480240)
			end
		end)

		self.connections[#self.connections + 1] = self.headlightsButtonMobile.Activated:Connect(function()
			if Headlights then
				Headlights = false
				self.car.Body.FrontLeftLight.SpotLight.Enabled = false
				self.car.Body.FrontRightLight.SpotLight.Enabled = false
			else
				Headlights = true
				self.car.Body.FrontLeftLight.SpotLight.Enabled = true
				self.car.Body.FrontRightLight.SpotLight.Enabled = true
			end
		end)

		self.connections[#self.connections + 1] = self.hornButtonMobile.Activated:Connect(function()
			if Horn then
				Horn = false
				self.car.Effects.CarHorn:Play()

			else
				Horn = true
				self.car.Effects.CarHorn:Stop()
				self.car.Effects.CarHorn.TimePosition = 0
			end
		end)

		self.connections[#self.connections + 1] = self.hazardsLightsButtonMobile.Activated:Connect(function()
			if HazardsLights then
				HazardsLights = false
				local HazardsLightsCoroutine = coroutine.wrap(HazardsLightsOn)
				HazardsLightsCoroutine()
			else
				HazardsLights = true
				local HazardsLightsCoroutine = coroutine.wrap(HazardsLightsOn)
				HazardsLightsCoroutine()
			end
		end)

	elseif Key == "V" then
		--Tell if a seat is flipped
		local UpVector = self.car.Chassis.VehicleSeat.CFrame.upVector
		local Angle = math.deg(math.acos(UpVector:Dot(Vector3.new(0, 1, 0))))
		if Angle >= 70 then
			local Chassis = require(self.car.Chassis.VehicleSeat.Parent.Parent.Scripts.Chassis)
			Chassis.Redress()
		end

	elseif Key == "R" then
		if LocalPlayer.GamePasses.Radio.Value then
			-- If the player already owns the pass, he can't buy it again

			if Radio then
				Radio = false
				self.radioGui.Visible = false
			else
				Radio = true
				self.radioGui.Visible = true
			end

		else
			MarketPlaceService:PromptGamePassPurchase(LocalPlayer, 42480240)
		end

	elseif Key == "F" then
		if Headlights then
			Headlights = false
			self.car.Body.FrontLeftLight.SpotLight.Enabled = false
			self.car.Body.FrontRightLight.SpotLight.Enabled = false
		else
			Headlights = true
			self.car.Body.FrontLeftLight.SpotLight.Enabled = true
			self.car.Body.FrontRightLight.SpotLight.Enabled = true
		end

	elseif Key == "G" then
		if Horn then
			Horn = false
			self.car.Effects.CarHorn:Play()

		else
			Horn = true
			self.car.Effects.CarHorn:Stop()
			self.car.Effects.CarHorn.TimePosition = 0
		end

	elseif Key == "H" then
		if HazardsLights then
			HazardsLights = false
			local HazardsLightsCoroutine = coroutine.wrap(HazardsLightsOn)
			HazardsLightsCoroutine()
		else
			HazardsLights = true
			local HazardsLightsCoroutine = coroutine.wrap(HazardsLightsOn)
			HazardsLightsCoroutine()
		end
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
