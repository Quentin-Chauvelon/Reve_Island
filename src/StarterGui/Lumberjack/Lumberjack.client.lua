local TweenService = game:GetService("TweenService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LumberjackRemoteEvent = ReplicatedStorage:WaitForChild("Lumberjack")

local LumberjackGui = script.Parent
local ToolsSelectionGui = LumberjackGui.Select.Tools
local CurrentCamera = workspace.CurrentCamera
local ToolShopGui = LumberjackGui:WaitForChild("BuyTool")

local lplr = game.Players.LocalPlayer

local TreesChoppedDown = lplr:WaitForChild("Lumberjack"):WaitForChild("TreesChoppedDown")
local ShopTools = workspace.LumberjackHut.Shop.Tools

local ToolsList = {"WoodenAxe", "StoneAxe", "IronAxe", "SteelAxe", "DiamondAxe", "Shears", "Basket", "Mystree"}


-- GET ALL THE TOOLS SELECT CLICKED EVENT

for i,v in ipairs(ToolsSelectionGui:GetChildren()) do
	if v:FindFirstChild("Select") then
		v.Select.MouseButton1Down:Connect(function()
			ToolsSelectionGui.Parent:TweenPosition(UDim2.new(0.5,0,2,0)) -- tween the position down
			wait(1)
			ToolsSelectionGui.Parent.Visible = false
			LumberjackRemoteEvent:FireServer("Equip", v.Name) -- fire the server to give the tool to the player
		end)
	end
end


-- PLAYER CLICKS ON THE BUY BUTTON ON THE SELECT GUI

LumberjackGui.Select.BuyButton.MouseButton1Down:Connect(function()
	CurrentCamera.CameraType = Enum.CameraType.Scriptable -- move the camera to the tool
	CurrentCamera.CFrame = ShopTools.WoodenAxeCamera.CFrame
	LumberjackGui.Select.Visible = false -- hide the selection gui
	ToolShopGui.WoodenAxe.Visible = true -- show the tool information
	ToolShopGui.RightArrow.Visible = true
	ToolShopGui.Owned.Visible = true
	ToolShopGui.Close.Visible = true -- show the close button
	ToolShopGui.CurrentTool.Value = "WoodenAxe" -- change the current tool value
end)


-- PLAYER CHANGES THE TOOL DISPLAYED IN THE SHOP

local function ToolShopArrowClicked(Tool)
	
	ToolShopGui.CurrentTool.Value = Tool -- change the current tool value to the new tool
	
	for i,v in ipairs(ToolShopGui:GetChildren()) do -- hide all the frames and the buy and owned images
		if v:IsA("Frame") or v.Name == "Buy" or v.Name == "Owned" then
			v.Visible = false
		end
	end
	
	if ShopTools:FindFirstChild(Tool.."Camera") then -- if the tool camera was found
		
		local TweenCamera = TweenService:Create(CurrentCamera, TweenInfo.new(1), {CFrame = ShopTools:FindFirstChild(Tool.."Camera").CFrame}) -- tween the camera to the new tool
		TweenCamera:Play()
		
		ToolShopGui:FindFirstChild(Tool).Visible = true -- show the tool information
		
		if lplr.Lumberjack.Tools:FindFirstChild(Tool).Value then -- if the player already owns the tool
			ToolShopGui.Owned.Visible = true -- show the owned image
		else
			ToolShopGui.Buy.Visible = true -- else show the buy button
		end
	end	
end



-- PLAYER CLICKS ONE OF THE ARROW OF THE SHOP GUI

ToolShopGui.LeftArrow.MouseButton1Down:Connect(function() -- when player clicks on the left arrow
	if ToolsList[1] == ToolShopGui.CurrentTool.Value then -- if the player is not already at the very left of the tools (otherwise shouldn't be moving left anymore)
		ToolShopGui.LeftArrow.Visible = false -- hide the left arrow
		return -- return because it should be impossible
			
	elseif ToolsList[2] == ToolShopGui.CurrentTool.Value then -- if the player is at the second tool
		ToolShopGui.LeftArrow.Visible = false -- hide the left arrow (because it becomes the first tool once moved)
		
	else
		ToolShopGui.LeftArrow.Visible = true -- else show the left arrow
	end
	
	ToolShopGui.RightArrow.Visible = true -- show the right arrow anyways
	
	local ToolPositionInTable = table.find(ToolsList, ToolShopGui.CurrentTool.Value) -- find the tool in the table to get the position
	if ToolPositionInTable then -- if the tool was found
	
		local NewTool = ToolsList[ToolPositionInTable - 1] -- change the tool to the previous one (the one on the left in the table)
		
		ToolShopArrowClicked(NewTool) -- call the function with the new tool as argument
	end
end)

ToolShopGui.RightArrow.MouseButton1Down:Connect(function() -- when player clicks on the right arrow
	if ToolsList[#ToolsList] == ToolShopGui.CurrentTool.Value then
		ToolShopGui.RightArrow.Visible = false
		return

	elseif ToolsList[#ToolsList - 1] == ToolShopGui.CurrentTool.Value then
		ToolShopGui.RightArrow.Visible = false

	else
		ToolShopGui.RightArrow.Visible = true
	end

	ToolShopGui.LeftArrow.Visible = true

	local ToolPositionInTable = table.find(ToolsList, ToolShopGui.CurrentTool.Value)
	if ToolPositionInTable then

		local NewTool = ToolsList[ToolPositionInTable + 1]

		ToolShopArrowClicked(NewTool)
	end
end)


-- PLAYER CLICKS THE BUY BUTTON ON THE SHOP GUI

ToolShopGui.Buy.MouseButton1Down:Connect(function()
	CurrentCamera.CameraType = Enum.CameraType.Custom -- sets the camera type back to custom
	
	for i,v in ipairs(ToolShopGui:GetChildren()) do -- hide all the children of the shop gui (that are not string values)
		if not v:IsA("StringValue") then
			v.Visible = false
		end
	end
	
	LumberjackGui.Select.Visible = true -- show the selection gui (for the animation)
	
	LumberjackRemoteEvent:FireServer("Buy", ToolShopGui.CurrentTool.Value) -- fire the remote event to buy the tool and get the animation
end)


-- PLAYER CLICKS THE CLOSE BUTTON ON THE SHOP GUI

ToolShopGui.Close.MouseButton1Down:Connect(function()
	CurrentCamera.CameraType = Enum.CameraType.Custom -- sets the camera type back to custom
	
	for i,v in ipairs(ToolShopGui:GetChildren()) do -- hide all the children of the shop gui (that are not string values)
		if not v:IsA("StringValue") then
			v.Visible = false
		end
	end
	
	LumberjackGui.Select.Visible = true -- show the selection gui (for the animation)
end)


---- PLAYER CLICKS THE SELL BUTTON ON THE SELECT GUI

--LumberjackGui.Select.SellButton.MouseButton1Down:Connect(function()
--	LumberjackGui.Select.Visible = false
--	LumberjackGui.Sell.Visible = true
	
--	for i,v in ipairs(LumberjackGui.Sell.Items:GetChildren()) do
--		if v:IsA("Frame") then
--			if lplr.Lumberjack:FindFirstChild(v.Name) then
--				v.Total.Text = "Total : "..tostring(lplr.Lumberjack:FindFirstChild(v.Name).Value) -- displays the number of items the player has

--				v.AllButton.MouseButton1Down:Connect(function() -- player clicks the all button
--					v.ChooseAmount.TextBox.Text = tostring(lplr.Lumberjack:FindFirstChild(v.Name).Value) -- change the text box to the number of items the player has
--				end)
--			end

--			v.ChooseAmount.TextBox:GetPropertyChangedSignal("Text"):Connect(function() -- remove everything that isn't a number from the textbox
--				v.ChooseAmount.TextBox.Text = v.ChooseAmount.TextBox.Text:gsub("%D+", "")
--				v.MoneyEarnt.Text = "+ $"..v.ChooseAmount.TextBox.Text
--			end)
			
--			v.SellButton.MouseButton1Down:Connect(function() -- players sells the item
--				if v.ChooseAmount.TextBox.Text ~= "" then
--					local Amount = tonumber(v.ChooseAmount.TextBox.Text) -- get the amount

--					if Amount <= lplr.Lumberjack:FindFirstChild(v.Name).Value then -- if player has enough item

--						LumberjackRemoteEvent:FireServer("Sell", v.Name, tonumber(v.ChooseAmount.TextBox.Text)) -- fire the remote event
--						v.Total.Text = "Total : "..lplr.Lumberjack:FindFirstChild(v.Name).Value -- update the number of items the player has
--						v.ChooseAmount.TextBox.Text = "" -- reset the text box
--					end
--				end
--			end)
--		end
--	end
--end)


---- REMOVES ANYTHING THAT ISN'T A NUMBER FROM THE TEXTBOX + CHANGE THE MONEY EARNT TEXT

--for i,v in ipairs(LumberjackGui.Sell.Items:GetChildren()) do -- loop through the frame with the items
--	if v:IsA("Frame") then -- if it's a frame
		
--		if lplr.Lumberjack:FindFirstChild(v) then -- if the item is found
--			v.Total.Text = "Total"..tostring(lplr.Lumberjack:FindFirstChild(v).Value) -- change the total number of items the player owns 

--			v.AllButton.MouseButton1Down:Connect(function() -- get the all button clicks event
--				v.ChooseAmount.TextBox.Text = lplr.Lumberjack:FindFirstChild(v).Value -- change the value to the max number of items the player has
--			end)
--		end

--		v.ChooseAmount.TextBox:GetPropertyChangedSignal("Text"):Connect(function() -- filter the text to only have numbers
--			v.ChooseAmount.TextBox.Text = v.ChooseAmount.TextBox.Text:gsub("%D+", "")
--			if v.ChooseAmount.TextBox.Text ~= "" then
--				if v.Name == "Wood" then
--					v.MoneyEarnt.Text = "+ $"..tostring(tonumber(v.ChooseAmount.TextBox.Text) * 2) -- change the money earnt based on the text
--				elseif v.Name == "Leaf" then
--					v.MoneyEarnt.Text = "+ $"..tostring(tonumber(v.ChooseAmount.TextBox.Text) * 4) -- change the money earnt based on the text
--				elseif v.Name == "Apple" then
--					v.MoneyEarnt.Text = "+ $"..tostring(tonumber(v.ChooseAmount.TextBox.Text) * 5) -- change the money earnt based on the text
--				end
--			end
--		end)
--	end
--end


-- PLAYER CLICKS THE SELL BUTTON ON THE SELECT GUI

LumberjackGui.Select.SellButton.MouseButton1Down:Connect(function()
	LumberjackGui.Select.Visible = false
	LumberjackGui.Sell.Visible = true

	for i,v in ipairs(LumberjackGui.Sell.Items:GetChildren()) do
		if v:IsA("Frame") then
			if lplr.Lumberjack:FindFirstChild(v.Name) then
				v.Total.Text = "Total : "..tostring(lplr.Lumberjack:FindFirstChild(v.Name).Value) -- displays the number of items the player has

				v.AllButton.MouseButton1Down:Connect(function() -- player clicks the all button
					v.ChooseAmount.TextBox.Text = tostring(lplr.Lumberjack:FindFirstChild(v.Name).Value) -- change the text box to the number of items the player has
				end)
			end

			v.ChooseAmount.TextBox:GetPropertyChangedSignal("Text"):Connect(function() -- remove everything that isn't a number from the textbox
				v.ChooseAmount.TextBox.Text = v.ChooseAmount.TextBox.Text:gsub("%D+", "")
				if v.ChooseAmount.TextBox.Text ~= "" then
					if v.Name == "Wood" then
						v.MoneyEarnt.Text = "+ $"..tostring(tonumber(v.ChooseAmount.TextBox.Text) * 2) -- change the money earnt based on the text
					elseif v.Name == "Leaf" then
						v.MoneyEarnt.Text = "+ $"..tostring(tonumber(v.ChooseAmount.TextBox.Text) * 4) -- change the money earnt based on the text
					elseif v.Name == "Apple" then
						v.MoneyEarnt.Text = "+ $"..tostring(tonumber(v.ChooseAmount.TextBox.Text) * 5) -- change the money earnt based on the text
					end
				end
			end)

			v.SellButton.MouseButton1Down:Connect(function() -- players sells the item
				if v.ChooseAmount.TextBox.Text ~= "" then
					local Amount = tonumber(v.ChooseAmount.TextBox.Text) -- get the amount

					if Amount <= lplr.Lumberjack:FindFirstChild(v.Name).Value then -- if player has enough item

						LumberjackRemoteEvent:FireServer("Sell", v.Name, tonumber(v.ChooseAmount.TextBox.Text)) -- fire the remote event
						v.Total.Text = "Total : "..lplr.Lumberjack:FindFirstChild(v.Name).Value -- update the number of items the player has
						v.ChooseAmount.TextBox.Text = "" -- reset the text box
					end
				end
			end)
		end
	end
end)


-- PLAYER CLICKS ON THE BACK BUTTON IN THE SELL GUI

LumberjackGui.Sell.BackButton.MouseButton1Down:Connect(function() -- go back to the selection gui
	LumberjackGui.Sell.Visible = false
	LumberjackGui.Select.Visible = true
end)