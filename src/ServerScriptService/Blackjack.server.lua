local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local CasinoChipBindableEvent = ServerStorage:WaitForChild("CasinoChip")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlackjackRemoteFunction = ReplicatedStorage:WaitForChild("Blackjack")

local PlayerList = {}

math.randomseed(tick())

-- Create the deck of 52 cards
local cardsTable = {}
for i = 1,52 do
	table.insert(cardsTable, i)
end

table.clone(cardsTable)

-- function to shuffle the cards table
local function shuffle(array)
	local output = {}
	local random = math.random

	for index = 1, #array do
		local offset = index - 1
		local value = array[index]
		local randomIndex = offset*random()
		local flooredIndex = randomIndex - randomIndex%1

		if flooredIndex == offset then
			output[#output + 1] = value
		else
			output[#output + 1] = output[flooredIndex + 1]
			output[flooredIndex + 1] = value
		end
	end
	
	local shuffledCards = {}
	table.move(output, 1, 17, 1, shuffledCards)
	
	return shuffledCards
end


-- Only shuffle 17 cards because even if you only get the lowest values each time, you only need 17 cards maximum
-- 1+1+1+1+2+2+2+2+3+3+3 = 21
-- 3+4+4+4+4+5 = 24 
--local function shuffle(array)
--	local output = {}

--	for i = 1,17 do
--		table.insert(output, cardsTable[math.random(1,52)])
--	end

--	return output
--end


local function getCardValue(PossibleOutcomes, nextCard)
	
	-- get the value of the card (0-13) (0 : J, 1 : ace, 2-10 : 2-10, 11 : Q, 12 : K)
	local value = nextCard % 13

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

		-- figures (J, Q, K)
	elseif value == 0 or value >= 11 then
		for i = 1,#PossibleOutcomes do
			PossibleOutcomes[i] += 10
		end
	end
end


-- player stands
local function Stand(plr, playerList)
	
	-- get the score of the first value
	local score = playerList["PossibleOutcomes"][1]
	
	-- get the highest score under 21 out of all the outcomes
	for _,v in pairs(playerList["PossibleOutcomes"]) do
		if v > score and v <= 21 then
			score = v
		end
	end
	
	-- blackjack
	if score == 21 then
		MoneyBindableFunction:Invoke(plr, 5000, "+")
		return true, score
		
	-- burst
	elseif score > 21 then
		return false, score
	end
	
	-- get the score of the dealer
	local minimum = playerList["DealerPossibleOutcomes"][1]
	
	-- store the cards the player gets (to send to the client)
	local dealerCards = {}
	
	-- while the dealer's has a score under 17 or while he doesn't have a higher score than the player
	while (minimum < 17 and minimum <= score) and #dealerCards < 9 and #playerList["CardsTable"] > 0 do
		
		-- get the card the dealer is going to get
		local nextCard = playerList["CardsTable"][#playerList["CardsTable"]]
		
		-- remove it from the table to not pick it again
		table.remove(playerList["CardsTable"], #playerList["CardsTable"])
		
		-- add it to the dealerCards (for the client)
		table.insert(dealerCards, nextCard)
		getCardValue(playerList["DealerPossibleOutcomes"], nextCard)
		
		-- update the minimum value
		if #playerList["DealerPossibleOutcomes"] == 1 then
			minimum = playerList["DealerPossibleOutcomes"][1]
			
		else
			local hasMinimumChanged = false
			
			-- get the minimum from all the possible outcomes
			for i,v in ipairs(playerList["DealerPossibleOutcomes"]) do
				if v <= 21 and v > minimum then
					minimum = v
					hasMinimumChanged = true
				end
			end
			
			-- if the minimum hasn't not changed, it means the dealer went over 21, thus, we should stop
			if not hasMinimumChanged then
				break
			end
		end
	end
	
	-- if the player has a higher score than the dealer or the dealer burst
	if score >= minimum or minimum > 21 then
		
		-- player wins
		coroutine.wrap(function()
			wait(1.3 * #dealerCards + 3)
			MoneyBindableFunction:Invoke(plr, 3000, "+")
		end)()
		return true, dealerCards
	else
		
		-- otherwise, player loses
		return false, dealerCards
	end
end


-- when the player triggers the proximity prompt to play
workspace.Casino.Blackjack.Table.ProximityPrompt.Triggered:Connect(function(plr)
	
	if not PlayerList[plr.Name] then
		if plr.Stats.CasinoChips.Value > 0 then
			CasinoChipBindableEvent:Fire(plr, 1, "-")
			-- [1] = the cards that are going to be picked (selected randomly)
			-- [2] = the player's possible outcomes for the player (have to use a table because of the aces that count as 1 or 11)
			-- [3] = the dealer's possible outcomes
			PlayerList[plr.Name] = {
				CardsTable = shuffle(table.clone(cardsTable)),
				PossibleOutcomes = {0},
				DealerPossibleOutcomes = {0}
			}

			-- Copy the first 4 cards of the table 
			local startingCards = {}
			table.move(PlayerList[plr.Name]["CardsTable"], 14, 17, 1, startingCards)

			-- count the points of the first 3 cards
			for i = 17,14,-1 do

				if i >= 16 then
					getCardValue(PlayerList[plr.Name]["PossibleOutcomes"], PlayerList[plr.Name]["CardsTable"][i])
				elseif i == 15 then
					getCardValue(PlayerList[plr.Name]["DealerPossibleOutcomes"], PlayerList[plr.Name]["CardsTable"][i])
				end
				table.remove(PlayerList[plr.Name]["CardsTable"], i)
			end

			-- fire the client to show the cards
			BlackjackRemoteFunction:InvokeClient(plr, "Start", startingCards)
		end
	end
end)


BlackjackRemoteFunction.OnServerInvoke = function(plr, action)
	if action and typeof(action) == "string" and PlayerList[plr.Name] and PlayerList[plr.Name]["CardsTable"] and PlayerList[plr.Name]["PossibleOutcomes"] then
		
		-- playe hits
		if action == "Hit" then
			
			-- if there are cards left in the table
			if #PlayerList[plr.Name]["CardsTable"] > 0 then
				
				-- get the next card in the table and remove it
				local nextCard = PlayerList[plr.Name]["CardsTable"][#PlayerList[plr.Name]["CardsTable"]]
				table.remove(PlayerList[plr.Name]["CardsTable"], #PlayerList[plr.Name]["CardsTable"])

				getCardValue(PlayerList[plr.Name]["PossibleOutcomes"], nextCard)
				
				-- get the lowest outcome
				local minimum = 22
				for _,v in pairs(PlayerList[plr.Name]["PossibleOutcomes"]) do
					if v < minimum then
						minimum = v
					end
				end
				
				-- if the lowest outcome is over 21, the player loses
				if minimum > 21 then
					Stand(plr, PlayerList[plr.Name])
					PlayerList[plr.Name] = nil
					BlackjackRemoteFunction:InvokeClient(plr, "Stand", nextCard)
					return nil
				end

				return nextCard	
			end
			
			return false
			
		-- player stands
		elseif action == "Stand" then
			local win, score = Stand(plr, PlayerList[plr.Name])
			PlayerList[plr.Name] = nil
			return win, score
		end
	end
end