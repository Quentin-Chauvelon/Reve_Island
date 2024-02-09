local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlackjackRemoteFunction = ReplicatedStorage:WaitForChild("Blackjack")
local CardsFolder = ReplicatedStorage:WaitForChild("Cards")
local HiddenCard = CardsFolder:WaitForChild("HiddenCard")
local CurrentCamera = workspace.CurrentCamera

local BlackjackGui = script.Parent
local yourDeck = BlackjackGui:WaitForChild("YourDeck")
local dealerDeck = BlackjackGui:WaitForChild("DealerDeck")

local YouPossibleOutcomes = {0}
local DealerPossibleOutcomes = {0}
local HitCliked, StandClicked, HelpClicked


local function reset(win, score)
	
	-- delete all the cards in the player's deck (can't do ClearAllChildren because of the UIGridLayout)
	for i,v in ipairs(yourDeck:GetChildren()) do
		if not v:IsA("UIGridLayout") then
			v:Destroy()
		end
	end
	
	-- delete all the cards in the dealer's deck (can't do ClearAllChildren because of the UIGridLayout)
	for i,v in ipairs(dealerDeck:GetChildren()) do
		if not v:IsA("UIGridLayout") then
			v:Destroy()
		end
	end
	
	-- hide all the ui elements
	BlackjackGui.Hit.Visible = false
	BlackjackGui.Stand.Visible = false
	BlackjackGui.Help.Visible = false
	BlackjackGui.HelpButton.Visible = false
	BlackjackGui.You.Visible = false
	BlackjackGui.Dealer.Visible = false
	
	-- reset the outcomes
	YouPossibleOutcomes = {0}
	DealerPossibleOutcomes = {0}
	
	-- show him what he earnt or lost
	if win then
		
		if score and score == 21 then
			BlackjackGui.BlackjackText.Visible = true
			wait(5)
			BlackjackGui.BlackjackText.Visible = false

		else
			BlackjackGui.Win.Visible = true
			wait(5)
			BlackjackGui.Win.Visible = false
		end

	else
		BlackjackGui.Lose.Visible = true
		wait(5)
		BlackjackGui.Lose.Visible = false
	end
	
	-- change the camera type and reenable the proximity prompt
	CurrentCamera.CameraType = Enum.CameraType.Custom
	workspace.Casino.Blackjack.Table.ProximityPrompt.Enabled = true
end


local function getCardValue(player, PossibleOutcomes, card)
	
	-- get the value of the card (0-13) (0 : J, 1 : ace, 2-10 : 2-10, 11 : Q, 12 : K)
	local value = card % 13

	-- ace
	if value == 1 then
		
		-- get the number of possible outcomes
		local outcomesLength = #PossibleOutcomes
		
		for i,v in pairs(PossibleOutcomes) do
			
			-- duplicate the values at the end of the table and add 1 to non duplicated values
			if i <= outcomesLength then
				table.insert(PossibleOutcomes, v)
				PossibleOutcomes[i] += 1
				
			-- add 11 to the duplicated values
			elseif i > outcomesLength and i <= outcomesLength * 2 then
				PossibleOutcomes[i] += 11
				
			else
				break
			end
		end

		-- remove all the values that are above 21 or the ones that are duplicates
		for i=#PossibleOutcomes, 1, -1 do
			if PossibleOutcomes[i] > 21 then
				table.remove(PossibleOutcomes, i)

			else
				if i > 1 then
					for k = 1, i - 1 do
						if PossibleOutcomes[k] == PossibleOutcomes[i] then
							table.remove(PossibleOutcomes, i)
						end
					end
				end
			end
		end


		-- normal card (2-10)
	elseif value >= 2 and value <= 10 then
		for i = 1,#PossibleOutcomes do
			PossibleOutcomes[i] += value
		end

		-- face (J, Q, K)
	elseif value == 0 or value >= 11 then
		for i = 1,#PossibleOutcomes do
			PossibleOutcomes[i] += 10
		end
	end
	
	-- change the text that shows the points
	if #PossibleOutcomes > 0 then
		
		-- change the first value
		if player == 1 then
			BlackjackGui.You.Text = "You: "..tostring(PossibleOutcomes[1])
		else
			BlackjackGui.Dealer.Text = "Dealer: "..tostring(PossibleOutcomes[1])
		end
		
		-- if the is more than 1 value in the table, add 'or XX' to the text
		if #PossibleOutcomes > 1 then
			for i,v in pairs(PossibleOutcomes) do

				if i == 1 then continue end

				if player == 1 then
					BlackjackGui.You.Text = BlackjackGui.You.Text.." or "..tostring(v)
				else
					BlackjackGui.Dealer.Text = BlackjackGui.Dealer.Text.." or "..tostring(v)
				end
			end
		end
	end
end


BlackjackRemoteFunction.OnClientInvoke = function(Type, cardsTable)

	if Type == "Start" and cardsTable and #cardsTable > 1 then
		
		-- disable the proximity prompt
		workspace.Casino.Blackjack.Table.ProximityPrompt.Enabled = false
		
		-- tween the camera above the table
		CurrentCamera.CameraType = Enum.CameraType.Scriptable
		TweenService:Create(CurrentCamera, TweenInfo.new(1), {CFrame = workspace.Casino.Blackjack.Camera.CFrame}):Play()

		wait(2)
		
		-- tween 4 cards to the table face down
		local hiddenCardClone1 = HiddenCard:Clone()
		hiddenCardClone1.Parent = BlackjackGui
		hiddenCardClone1.LayoutOrder = 0
		hiddenCardClone1:TweenPosition(UDim2.new(0.5,0,0.65,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.3)

		wait(0.3)
		hiddenCardClone1.Parent = yourDeck

		local hiddenCardClone2 = HiddenCard:Clone()
		hiddenCardClone2.Parent = BlackjackGui
		hiddenCardClone2.LayoutOrder = 1
		hiddenCardClone2:TweenPosition(UDim2.new(0.5,0,0.65,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.3)

		wait(0.3)
		hiddenCardClone2.Parent = yourDeck

		local hiddenCardClone3 = HiddenCard:Clone()
		hiddenCardClone3.Position = UDim2.new(0.5,0,-0.2,0)
		hiddenCardClone3.Parent = BlackjackGui
		hiddenCardClone3.LayoutOrder = 0
		hiddenCardClone3:TweenPosition(UDim2.new(0.5,0,0.15,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.3)

		wait(0.3)
		hiddenCardClone3.Parent = dealerDeck

		local hiddenCardClone4 = HiddenCard:Clone()
		hiddenCardClone4.Position = UDim2.new(0.5,0,-0.2,0)
		hiddenCardClone4.LayoutOrder = 1
		hiddenCardClone4.Parent = BlackjackGui
		hiddenCardClone4:TweenPosition(UDim2.new(0.5,0,0.15,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.3)

		wait(0.3)
		hiddenCardClone4.Parent = dealerDeck

		wait(1)

		local cardClone1, cardClone2, cardClone3
		
		-- reveal the 3 first cards
		if CardsFolder:FindFirstChild("Card"..tostring(cardsTable[#cardsTable])) then
			cardClone1 = CardsFolder["Card"..tostring(cardsTable[#cardsTable])]:Clone()

			getCardValue(1, YouPossibleOutcomes, cardsTable[#cardsTable])
			table.remove(cardsTable, #cardsTable)

			cardClone1.LayoutOrder = 0
			hiddenCardClone1:Destroy()
			cardClone1.Parent = yourDeck
		end

		wait(0.5)

		if CardsFolder:FindFirstChild("Card"..tostring(cardsTable[#cardsTable])) then
			cardClone2 = CardsFolder["Card"..tostring(cardsTable[#cardsTable])]:Clone()

			getCardValue(1, YouPossibleOutcomes, cardsTable[#cardsTable])
			table.remove(cardsTable, #cardsTable)

			cardClone2.LayoutOrder = 1
			hiddenCardClone2:Destroy()
			cardClone2.Parent = yourDeck
		end

		wait(0.5)

		if CardsFolder:FindFirstChild("Card"..tostring(cardsTable[#cardsTable])) then
			cardClone3 = CardsFolder["Card"..tostring(cardsTable[#cardsTable])]:Clone()

			getCardValue(2, DealerPossibleOutcomes, cardsTable[#cardsTable])
			table.remove(cardsTable, #cardsTable)

			cardClone3.LayoutOrder = 0
			hiddenCardClone3:Destroy()
			cardClone3.Parent = dealerDeck
		end

		wait(0.5)
		
		-- show the ui elements
		BlackjackGui.Dealer.Visible = true
		BlackjackGui.You.Visible = true

		BlackjackGui.Hit.Visible = true
		BlackjackGui.Stand.Visible = true
		BlackjackGui.HelpButton.Visible = true

		if not HitCliked and not StandClicked and not HelpClicked then
			
			-- player clicks the hit button
			HitCliked = BlackjackGui.Hit.MouseButton1Down:Connect(function()

				-- fire the server to get a card
				local nextCard = BlackjackRemoteFunction:InvokeServer("Hit")
				
				if nextCard then
					-- tween the card to the table face down
					local hiddenCardClone = HiddenCard:Clone()
					hiddenCardClone.Parent = BlackjackGui
					hiddenCardClone.LayoutOrder = #BlackjackGui.YourDeck:GetChildren()
					hiddenCardClone:TweenPosition(UDim2.new(0.5,0,0.65,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.3)

					wait(0.3)
					hiddenCardClone.Parent = yourDeck

					wait(0.5)
					
					-- reveal the card
					local cardClone
					if CardsFolder:FindFirstChild("Card"..tostring(nextCard)) then
						cardClone = CardsFolder["Card"..tostring(nextCard)]:Clone()

						getCardValue(1, YouPossibleOutcomes, nextCard)

						cardClone.LayoutOrder = #BlackjackGui.YourDeck:GetChildren()
						hiddenCardClone:Destroy()
						cardClone.Parent = yourDeck
					end
				end
			end)
			
			-- player clicks the stand button
			StandClicked = BlackjackGui.Stand.MouseButton1Down:Connect(function()
				
				-- fire the server to know if player lost or won
				local win, score = BlackjackRemoteFunction:InvokeServer("Stand")
				
				-- if score is a number then, the player either got a blackjack or burst (went over 21)
				if score and typeof(score) == "number" then
					reset(win, score)
					
				-- if score is a table, than it's score is actually the cards the dealer got
				elseif score and typeof(score) == "table" then
					
					-- show all the cards the dealer got
					for i,v in ipairs(score) do
						
						-- tween the card to the table face down (only if i > 1 because there is already a card face down on the table)
						local hiddenCardClone
						if i > 1 then
							hiddenCardClone = HiddenCard:Clone()
							hiddenCardClone.Parent = BlackjackGui
							hiddenCardClone.Position = UDim2.new(0.5,0,-0.2,0)
							hiddenCardClone.LayoutOrder = #BlackjackGui.DealerDeck:GetChildren()
							hiddenCardClone:TweenPosition(UDim2.new(0.5,0,0.15,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.3)

							wait(0.3)
							hiddenCardClone.Parent = dealerDeck
						end
						
						wait(1)
						
						-- reveal the card
						local cardClone
						if CardsFolder:FindFirstChild("Card"..tostring(v)) then
							cardClone = CardsFolder["Card"..tostring(v)]:Clone()

							getCardValue(2, DealerPossibleOutcomes, v)

							cardClone.LayoutOrder = #BlackjackGui.DealerDeck:GetChildren()
							
							-- there is already a card face down on the table
							if i == 1 then
								if dealerDeck:FindFirstChild("HiddenCard") then
									dealerDeck.HiddenCard:Destroy()
								end
							else
								hiddenCardClone:Destroy()
							end

							cardClone.Parent = dealerDeck
						end
					end
					
					wait(3)
					reset(win)
				end
			end)
			
			-- show/hide the help
			HelpClicked = BlackjackGui.HelpButton.MouseButton1Down:Connect(function()
				if BlackjackGui.Help.Visible then
					BlackjackGui.Help.Visible = false
				else
					BlackjackGui.Help.Visible = true
				end
			end)
		end
		
	-- server fires the remote function with argument type = stand (player burst (went over 21))
	elseif Type == "Stand" then
		if cardsTable and typeof(cardsTable) == "number" then
			
			-- tween the card that made him burst to the table face down
			local hiddenCardClone = HiddenCard:Clone()
			hiddenCardClone.Parent = BlackjackGui
			hiddenCardClone.LayoutOrder = #BlackjackGui.YourDeck:GetChildren()
			hiddenCardClone:TweenPosition(UDim2.new(0.5,0,0.65,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.3)

			wait(0.3)
			hiddenCardClone.Parent = yourDeck

			wait(0.5)
			
			-- reveal the card
			local cardClone
			if CardsFolder:FindFirstChild("Card"..tostring(cardsTable)) then
				cardClone = CardsFolder["Card"..tostring(cardsTable)]:Clone()

				getCardValue(1, YouPossibleOutcomes, cardsTable)

				cardClone.LayoutOrder = #BlackjackGui.YourDeck:GetChildren()
				hiddenCardClone:Destroy()
				cardClone.Parent = yourDeck
			end
			
			wait(3)
		end
		
		reset(false, 0)
	end
end