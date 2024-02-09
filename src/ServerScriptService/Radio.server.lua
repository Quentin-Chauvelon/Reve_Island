local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RadioRemoteEvent = ReplicatedStorage:WaitForChild("Radio")

local Cars = workspace.Cars


-- RADIO REMOTE EVENT FIRED FROM THE CLIENT (TO PLAY A SONG OR PAUSE IT)

RadioRemoteEvent.OnServerEvent:Connect(function(plr, Type, Song)

	if Type and typeof(Type) == "string" then
		if Cars:FindFirstChild(plr.Name) and Cars[plr.Name]:FindFirstChild("Body") and Cars[plr.Name].Body:FindFirstChild("Radio") and Cars[plr.Name].Body.Radio:FindFirstChild("Sound") then

			local Sound = Cars[plr.Name].Body.Radio.Sound
			
			-- Play the sound
			if Type == "Play" then

				if plr:FindFirstChild("GamePasses") and plr.GamePasses:FindFirstChild("Radio") and plr.GamePasses.Radio.Value then
					
					-- If the player already owns the pass, he can't buy it again
					if Song and typeof(Song) == "number" then

						local success, songinfo = pcall(MarketPlaceService.GetProductInfo, MarketPlaceService, Song)

						if success and songinfo.AssetTypeId == 3 then

							Sound.SoundId = "rbxassetid://"..songinfo.AssetId -- set the sound id 
							Sound.Loaded:Wait() -- wait for the sound to load
							Sound:Play() -- play the sound
						end
					end	
				end
				
			-- Pause the sound
			elseif Type == "Pause" then
				Sound:Pause()
				
			-- Resume the sound
			elseif Type == "Resume" then
				Sound:Resume()
			end
		end
	end
end)