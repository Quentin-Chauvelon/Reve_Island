local Players = game:GetService("Players")
local WarnBindableEvent = game:GetService("ServerStorage"):WaitForChild("Warn")
local WarnRemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Ban") -- this event should never be fire, it's a honey pot. If it's fire, then it's a hacker

-- add different types of importance (Type : "Ban", "Important" and "Normal"
-- send them to 3 different trello cards (for the ban, give them a message like : "You have been banned for : Exploiting. If you are innocent, you will be unban within 24h


WarnRemoteEvent.OnServerEvent:Connect(function(plr)
	wait(120)
	plr:Kick("Exploiting is not allowed!")
end)

WarnBindableEvent.Event:Connect(function(plr, Type, Reason, Source, Time)
	-- Type :
	-- Normal : something that doesn't need to be check fast and is not really important
	-- Important : something which almost obviously shows that the player exploited but doesn't require an immediate action
	-- Ban : something which obvious shows that the player exploited and requires an immediate ban
	
	--if plr and Type and Reason and Source and Time then
	--	warn(plr.Name.." ("..Players:FindFirstChild(plr.Name).UserId..") "..Reason..". Script : "..Source..". Fired at "..Time)
	--end

	if Type == "Ban" then
		-- add a wait(120) so that player doesn't know why he has been banned ?
		plr:Kick("You have been banned for : Exploiting. Your ban will be reviewed within 48 hours.")
		-- add to datastore
	end
end)

-- player (userid) reason. Script : Source. Fired at Time