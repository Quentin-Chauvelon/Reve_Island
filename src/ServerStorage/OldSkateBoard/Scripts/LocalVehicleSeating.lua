local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")

local SEATING_ACTION_NAME = "VehicleChassisSeating"

local LocalPlayer = Players.LocalPlayer

local module = {}
module.OnExitFunctions = {}

local vehicle = script.Parent.Parent

local Remotes = vehicle.Remotes
	local ExitSeat = Remotes:WaitForChild("ExitSeat")

--Variables

local currentHumanoid = nil
local AnimationTracks = {}


local function getLocalHumanoid()
	if LocalPlayer.Character then
		return LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	end
end


---Exit function
function module.ExitSeat()
	local humanoid = getLocalHumanoid()
	if not humanoid then
		return false
	end
	local character = humanoid.Parent
	if character.Humanoid.Sit == true then
		for _, joint in ipairs(character.HumanoidRootPart:GetJoints()) do
			if joint.Name == "SeatWeld" then
				local promptLocation = joint.Part0:FindFirstChild("PromptLocation")
				if promptLocation then
					local proximityPrompt = promptLocation:FindFirstChildWhichIsA("ProximityPrompt")
					if proximityPrompt and proximityPrompt.Name == "EndorsedVehicleProximityPromptV1" then
						for _, func in pairs(module.OnExitFunctions) do
							func(joint.Part0)
						end
						ExitSeat:FireServer()

						for name, track in pairs(AnimationTracks) do
							track:Stop()
						end

						return true
					end
				end
			end
		end
	end
end

--Connect functions to seat exit
function module.OnSeatExitEvent(func)
	table.insert(module.OnExitFunctions, func)
end

function module.DisconnectFromSeatExitEvent(func)
	local newExitFunctions = {}
	for _, v  in ipairs(module.OnExitFunctions) do
		if v ~= func then
			table.insert(newExitFunctions, v)
		end
	end
	module.OnExitFunctions = newExitFunctions
end


--The server will fire the ExitSeat remote to the client when the humanoid has been removed from a seat.
--This script listens to that and uses it to prevent the humanoid tripping when exiting a seat.
--As the player is removed from the seat server side, this scripts listens to the event instead of being
-- inside the ExitSeat function so that:
-- A) The timing is right - the exit seat function will run before the character is unsat by the server
-- B) If a server script removes the player from a seat, the anti-trip will still run
local function antiTrip()
	local humanoid = getLocalHumanoid()
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end
Remotes.ExitSeat.OnClientEvent:Connect(function(doAntiTrip)
	for _, func in pairs(module.OnExitFunctions) do
		func(nil)
	end
	if doAntiTrip then
		antiTrip()
	end
end)

return module
