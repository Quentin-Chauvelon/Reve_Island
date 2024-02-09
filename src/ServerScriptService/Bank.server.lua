local ServerStorage = game:GetService("ServerStorage")
local MoneyBindableFunction = ServerStorage:WaitForChild("Money")
local BankBindableEvent = ServerStorage:WaitForChild("Bank")
local WarnBindableEvent = ServerStorage:WaitForChild("Warn")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BankRemoteEvent = ReplicatedStorage:WaitForChild("Bank")

local debounce = false


BankRemoteEvent.OnServerEvent:Connect(function(plr, Type, Amount)
	
	
	if Type and Amount and typeof(Type) == "string" and typeof(Amount) == "string" then
		
		Amount = tonumber((Amount:gsub("%D+", "")))
		
		if Amount and plr.Stats:FindFirstChild("MoneyMultiplier") then
			
			if Type == "Withdraw" then
				if Amount <= plr.Stats.BankAccount.Value then -- if player is trying to withdraw less money than what he has in his bank account
					BankBindableEvent:Fire(plr, Amount, "-")
					
					-- If the player has the double money gamepass, divide the amount to withdraw by 2, otherwise the player could double his money each time he withdraws
					if plr.GamePasses.DoubleMoney.Value then
						MoneyBindableFunction:Invoke(plr, Amount / plr.Stats.MoneyMultiplier.Value / 2, "+")
					else
						MoneyBindableFunction:Invoke(plr, Amount / plr.Stats.MoneyMultiplier.Value, "+")
					end
				end

			elseif Type == "Deposit" then
				local EnoughMoney = MoneyBindableFunction:Invoke(plr, Amount / plr.Stats.MoneyMultiplier.Value, "-")
				if EnoughMoney == true then
					BankBindableEvent:Fire(plr, Amount, "+")
				end

			else WarnBindableEvent:Fire(plr, "Important", "is firing the bank remote event with an unexpected value (Type : "..Type.." instead of withdraw or deposit)", "Bank", os.time()) end
		end
	else WarnBindableEvent:Fire(plr, "Important", "is firing the bank remote event with nil values", "Bank", os.time()) end
end)