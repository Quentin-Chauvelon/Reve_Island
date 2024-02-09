local DataStoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FeedbackRemoteEvent = ReplicatedStorage:WaitForChild("Feedback")
local FeedbackDataStore = DataStoreService:GetDataStore("Feedback")
local Key = "Feedback1" -- save all feedback under one key in tables


--[[
USE THIS CODE TO SEE ALL THE FEEDBACKS (CHANGE THE KEY TO RESET THE DATASTORE)

local FeedbackData = game:GetService("DataStoreService"):GetDataStore("Feedback"):GetAsync("Feedback1")
for i,v in pairs(FeedbackData) do
	print(tostring(v[1]).." wrote : "..v[2])
end
--]]

-- PLAYER SENDS A FEEDBACK

FeedbackRemoteEvent.OnServerEvent:Connect(function(plr, Feedback)
	if Feedback and typeof(Feedback) == "string" and #Feedback < 400 then
		if plr:FindFirstChild("CanSendFeedback") and plr.CanSendFeedback.Value then
			
			plr.CanSendFeedback.Value = false -- player can't send more feedback unless it quits
			
			local success, PlayerTable = pcall(function()
				return FeedbackDataStore:GetAsync(Key)
			end)
			
			if success then
				local UserId = plr.UserId
				local AlreadySentFeedback = false
				
				for i,v in pairs(PlayerTable) do
					if UserId == v[1] then
						AlreadySentFeedback = true
						break
					end
				end
				
				if not AlreadySentFeedback then
					MoneyBindableFunction:Invoke(plr, 10000, "+")
				end
				
				local success, errormessage = pcall(function()
					FeedbackDataStore:UpdateAsync(Key, function(Old)
						Old = Old or {}
						table.insert(Old, {UserId, Feedback})
						return Old
					end)
				end)
			end
		end
	end
end)