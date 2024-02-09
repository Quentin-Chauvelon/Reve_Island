local Lighting = game:GetService("Lighting")
local Clock = script.Parent.Frame.Clock.TextLabel

while true do
	local Hours = math.floor(Lighting:GetMinutesAfterMidnight() / 60)
	local Minutes = Lighting:GetMinutesAfterMidnight() - (Hours * 60)
	
	if Hours < 10 then
		Hours = "0"..Hours -- add a 0 if the hour is under 10 to make it look better
	end
	
	if Minutes < 10 then
		Minutes = "0"..Minutes -- add a 0 if the minute is under 10 to make it look better
	end
	
	Clock.Text = Hours.." : "..Minutes
	wait(0.75) -- change this value according to the one in the DayNightCyle script
end