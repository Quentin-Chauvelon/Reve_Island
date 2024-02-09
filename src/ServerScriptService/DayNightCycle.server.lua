local lighting = game:GetService("Lighting")
local minutes = 480

while true do
	lighting:SetMinutesAfterMidnight(minutes)
	minutes = minutes + 1
	wait(0.83)
end