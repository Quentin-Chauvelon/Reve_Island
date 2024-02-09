local Players = game:GetService("Players")

local Admins = {
	551795306
}

Players.PlayerAdded:Connect(function(plr)
	if table.find(Admins, plr.UserId) then -- check if player is an admin
		
		
		
	end
end)