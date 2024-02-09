local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Scripts = script.Parent
local TopModel = Scripts.Parent

local UniqueName = TopModel.Name.. "_" ..HttpService:GenerateGUID()

local ChassisModel = TopModel.Chassis
local EffectsFolder = TopModel.Effects

local Effects = require(Scripts.Effects)
local Chassis = require(Scripts.Chassis)
local VehicleSeating = require(Scripts.VehicleSeating)
local RemotesFolder = TopModel.Remotes
local BindableEventsFolder = TopModel.BindableEvents


-- LocalScripts that are cloned and deployed
local DriverScriptPrototype = Scripts.Driver
local PassengerScriptPrototype = Scripts.Passenger
local LocalGuiModulePrototype = Scripts.LocalVehicleGui

-- Note that this has not been refactored into a class yet
Chassis.InitializeDrivingValues()

-- This module is a class with a new() constructor function
local EffectsInstance = Effects.new(ChassisModel, EffectsFolder, TopModel)

VehicleSeating.SetRemotesFolder(RemotesFolder)
VehicleSeating.SetBindableEventsFolder(BindableEventsFolder)

local CharacterRemovingConnection = nil
local CharacterRemovingConnection = nil

local DriverSeat = Chassis.GetDriverSeat()

local LEG_PARTS_TO_REMOVE = {"RightFoot", "RightLowerLeg", "LeftFoot", "LeftLowerLeg"}
local ATTACHMENTS_TO_REMOVE = {"BodyBackAttachment", "WaistBackAttachment", "HatAttachment"}


local function setHatsAndLegsTransparency(obj, transparency)
	if obj:IsA("Humanoid") then
		obj = obj.Parent
	elseif obj:IsA("Player") then
		obj = obj.Character
	end

	for _, child in ipairs(obj:GetChildren()) do
		if child:IsA("Accoutrement") then
			local handle = child:FindFirstChild("Handle")
			if handle then
				local shouldRemove = false
				for _, attachmentName in ipairs(ATTACHMENTS_TO_REMOVE) do
					if handle:FindFirstChild(attachmentName) then
						shouldRemove = true
					end
				end

				if shouldRemove then
					handle.Transparency = transparency
				end
			end
		end
	end

	for _, legName in ipairs(LEG_PARTS_TO_REMOVE) do
		local legPart = obj:FindFirstChild(legName)
		if legPart then
			legPart.Transparency = transparency
		end
	end
end

local function onExitSeat(obj, seat)
	if obj:IsA("Player") then
		script.Parent.Parent.Driver.Value = ""
		script.Parent.Parent.Body.Windshield.Beam.Attachment1 = nil
		RemotesFolder.ExitSeat:FireClient(obj, false)

		local playerGui = obj:FindFirstChildOfClass("PlayerGui")
		if playerGui then
			playerGui.BusStation.Frame.Visible = false -- open close door + stop sign gui
			local scriptContainer = playerGui:FindFirstChild(UniqueName .. "_ClientControls")
			if scriptContainer then
				scriptContainer:Destroy()
			end
		end
	end

	setHatsAndLegsTransparency(obj, 0)

	if obj:IsA("Humanoid") then
		obj.Sit = false
	end

	if CharacterRemovingConnection then
		CharacterRemovingConnection:Disconnect()
		CharacterRemovingConnection = nil
	end

	if seat == DriverSeat then
		DriverSeat:SetNetworkOwnershipAuto()
		Chassis.Reset()
		EffectsInstance:Disable()
	end
end

local function onEnterSeat(obj, seat)
	if seat and seat.Occupant then
		local ShouldTakeOffHats = true
		local prop = TopModel:GetAttribute("TakeOffAccessories")

		if prop ~= nil then
			ShouldTakeOffHats = prop
		end

		if ShouldTakeOffHats then
			setHatsAndLegsTransparency(seat.Occupant, 1)
		end
	end

	if not obj:IsA("Player") then
		return
	end

	local playerGui = obj:FindFirstChildOfClass("PlayerGui")
	if playerGui then
		playerGui.BusStation.Frame.Visible = true -- open close door + stop sign gui
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = UniqueName .. "_ClientControls"
		screenGui.ResetOnSpawn = true
		screenGui.Parent = playerGui
		
		CharacterRemovingConnection = obj.CharacterRemoving:Connect(function()
			onExitSeat(obj)
		end)

		local localGuiModule = LocalGuiModulePrototype:Clone()
		localGuiModule.Parent = screenGui

		if seat == DriverSeat then
			script.Parent.Parent.Driver.Value = obj.Name
			
			-- If the player is already driving another bus, delete it
			if workspace.Cars:FindFirstChild(obj.Name) and TopModel ~= workspace.Cars[obj.Name] then
				workspace.Cars[obj.Name]:Destroy()
			end
			
			TopModel.Name = obj.Name
			TopModel.Parent = workspace.Cars
			
			game.ServerStorage.BusStop:Fire(obj, script.Parent.Parent.Line.Value)
			local driverScript = DriverScriptPrototype:Clone()
			driverScript.CarValue.Value = TopModel
			driverScript.Parent = screenGui
			driverScript.Disabled = false

			DriverSeat:SetNetworkOwner(obj)
			EffectsInstance:Enable()
		else
			local passengerScript = PassengerScriptPrototype:Clone()
			passengerScript.CarValue.Value = TopModel
			passengerScript.Parent = screenGui
			passengerScript.Disabled = false
		end

		local scriptsReference = Instance.new("ObjectValue")
		scriptsReference.Name = "ScriptsReference"
		scriptsReference.Value = Scripts
		scriptsReference.Parent = screenGui
	end
end

--Listen to seat enter/exit
VehicleSeating.AddSeat(DriverSeat, onEnterSeat, onExitSeat)

local function playerAdded(player)
	local playerGui = player:WaitForChild("PlayerGui")

	if not playerGui:FindFirstChild("VehiclePromptScreenGui") then
		local screenGui = Instance.new("ScreenGui")
		screenGui.ResetOnSpawn = false
		screenGui.Name = "VehiclePromptScreenGui"
		screenGui.Parent = playerGui

		local newLocalVehiclePromptGui = Scripts.LocalVehiclePromptGui:Clone()
		newLocalVehiclePromptGui.CarValue.Value = TopModel
		newLocalVehiclePromptGui.Parent = screenGui
	end
end

Players.PlayerAdded:Connect(playerAdded)

for _, player in ipairs(Players:GetPlayers()) do
	playerAdded(player)
end

