local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ConfirmationRemoteEvent = ReplicatedStorage:WaitForChild("BuyConfirmation")

local ConfirmationTable = {}


-- PLAYER WANTS TO BUY SOMETHING (NEED CONFIRMATION FIRST)

ConfirmationRemoteEvent.OnServerEvent:Connect(function(plr, Item, Price) -- server is only used to communicate between the client scripts
	if Item and Price and typeof(Item) == "string" and typeof(Price) == "number" and plr.leaderstats.Money.Value >= Price then
		ConfirmationRemoteEvent:FireClient(plr, Item) -- fire the client to confirm
	end
end)