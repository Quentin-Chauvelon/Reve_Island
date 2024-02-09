-- WEEKLY

--local WeekDay = 0
--local Hours = 0
--local Minutes = 0 

--while true do
--	local Now = os.date("!*t", os.time()) -- get the time (UTC time)
	
--	if Now.wday == 1 then
--		WeekDay = 0
--	else
--		WeekDay = 8 - Now.wday -- determine the number of week days left
--	end
--	Hours = 23 - Now.hour -- hours left
--	Minutes = 60 - Now.min -- minutes left
	
--	script.Parent.Text = "Ends in "..WeekDay.." days "..Hours.." hours "..Minutes.." minutes"
--	wait(60)
--end


-- MONTHLY

local Day = 0
local Hours = 0
local Minutes = 0 

while true do
	local Now = os.date("!*t", os.time()) -- get the time (UTC time)

	Day = 31 - Now.day -- determine the number of days left in the month
	Hours = 23 - Now.hour -- hours left
	Minutes = 60 - Now.min -- minutes left

	workspace.ComputerRoom.Timer.SurfaceGui.Frame.TimeLeft.Text = "Ends in "..Day.." days "..Hours.." hours "..Minutes.." minutes"
	workspace.Factory.Timer.SurfaceGui.Frame.TimeLeft.Text = "Ends in "..Day.." days "..Hours.." hours "..Minutes.." minutes"
	workspace.RaceTrack.Timer.SurfaceGui.Frame.TimeLeft.Text = "Ends in "..Day.." days "..Hours.." hours "..Minutes.." minutes"
	wait(60)
end