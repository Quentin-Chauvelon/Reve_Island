local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishingRemoteEvent = ReplicatedStorage:WaitForChild("Fishing")

local FishingGui = script.Parent
local FishingSelectionGui = FishingGui:WaitForChild("Select")
local RodsShopGui = FishingGui:WaitForChild("BuyRods")
local BaitsShopGui = FishingGui:WaitForChild("BuyBaits")

local lplr = game.Players.LocalPlayer

local CurrentCamera = workspace.CurrentCamera
local ShopTools = workspace.Lake.Shop.Tools

local RodsList = {"WoodenRod", "GraphiteRod", "AluminiumRod", "Carrod"}
local BaitsList = {"PinkBait", "GreenBait", "RedOrangeBait", "RainbowBait"}
local SellMultiplier = {
	Salmon = 70,
	Cod = 75,
	Trout = 130,
	Catfish = 135,
	Eel = 160,
	Pufferfish = 165,
	Swordfish = 225,
	Shark = 230
}

FishingSelectionGui:WaitForChild("NavigationButtons")
FishingGui.BuyRods:WaitForChild("LeftArrow")
FishingGui.BuyRods:WaitForChild("RightArrow")
FishingGui.BuyRods:WaitForChild("Close")
FishingGui.BuyBaits:WaitForChild("LeftArrow")
FishingGui.BuyBaits:WaitForChild("RightArrow")
FishingGui.BuyBaits:WaitForChild("Close")


-- DISPLAY THE RODS GUI

local function HideAllGuis()
	for i,v in ipairs(FishingSelectionGui:GetChildren()) do
		if not v:IsA("UIAspectRatioConstraint") and v.Name ~= "NavigationButtons" then
			v.Visible = false
		end
	end
end

-- RODS
FishingSelectionGui.NavigationButtons.RodsButton.MouseButton1Down:Connect(function()
	HideAllGuis()
	FishingSelectionGui.Rods.Visible = true
	FishingSelectionGui.RodsBuy.Visible = true
end)

-- BAITS
FishingSelectionGui.NavigationButtons.BaitsButton.MouseButton1Down:Connect(function()
	HideAllGuis()
	FishingSelectionGui.Baits.Visible = true
	FishingSelectionGui.BaitsBuy.Visible = true
end)

-- FISHES
FishingSelectionGui.NavigationButtons.FishesButton.MouseButton1Down:Connect(function()
	HideAllGuis()
	
	for i,v in ipairs(FishingSelectionGui.Fishes:GetChildren()) do
		if not v:IsA("UIGridLayout") then		
			v.MoneyEarnt.Visible = false -- hide the money earnt
			v.Total.Visible = true -- show the total
			v.Total.Text = "Total : "..tostring(lplr.Fishing.Fishes:FindFirstChild(v.Name).Value) -- change the total text to the number of fishes the player has
		end
	end

	FishingSelectionGui.Fishes.Visible = true
end)


-- GET ALL THE SELECT BUTTONS CLICKED EVENTS FOR THE RODS AND THE BAITS

local function SelectButtonClicked(Item)
	Item.Select.MouseButton1Down:Connect(function()
		FishingRemoteEvent:FireServer("Equip", Item.Name) -- fire the server to give the tool to the player
	end)
end

for i,v in ipairs(FishingSelectionGui.Rods:GetChildren()) do
	if v:FindFirstChild("Select") then
		SelectButtonClicked(v)
	end
end

for i,v in ipairs(FishingSelectionGui.Baits:GetChildren()) do
	if v:FindFirstChild("Select") then
		SelectButtonClicked(v)
	end
end


-- PLAYER CLICKS ON THE RODS BUY BUTTON ON THE SELECT GUI

FishingSelectionGui.RodsBuy.MouseButton1Down:Connect(function()
	CurrentCamera.CameraType = Enum.CameraType.Scriptable -- move the camera to the tool
	CurrentCamera.CFrame = ShopTools.WoodenRodCamera.CFrame
	
	FishingSelectionGui.Visible = false -- hide the selection gui
	RodsShopGui.WoodenRod.Visible = true -- show the tool information
	RodsShopGui.RightArrow.Visible = true
	RodsShopGui.Owned.Visible = true
	RodsShopGui.Close.Visible = true -- show the close button
	RodsShopGui.CurrentTool.Value = "WoodenRod" -- change the current tool value
end)


-- PLAYER CLICKS ON THE BAITS BUY BUTTON ON THE SELECT GUI

FishingSelectionGui.BaitsBuy.MouseButton1Down:Connect(function()
	CurrentCamera.CameraType = Enum.CameraType.Scriptable -- move the camera to the tool
	CurrentCamera.CFrame = workspace.Lake.Shop.Tools.BaitsCamera.CFrame

	FishingSelectionGui.Visible = false -- hide the selection gui
	BaitsShopGui.PinkBait.Visible = true -- show the tool information
	BaitsShopGui.RightArrow.Visible = true
	BaitsShopGui.Buy.Visible = true
	BaitsShopGui.Close.Visible = true -- show the close button
	BaitsShopGui.CurrentTool.Value = "PinkBait" -- change the current tool value
end)


-- PLAYER CHANGES THE TOOL DISPLAYED IN THE SHOP

local function ToolShopArrowClicked(ToolType, Tool)
	
	if FishingGui:FindFirstChild("Buy"..ToolType) then	
		
		local ToolShopGui = FishingGui:FindFirstChild("Buy"..ToolType)
		
		ToolShopGui.CurrentTool.Value = Tool -- change the current tool value to the new tool

		for i,v in ipairs(ToolShopGui:GetChildren()) do -- hide all the frames and the buy and owned images
			if v:IsA("Frame") or v.Name == "Buy" or v.Name == "Owned" then
				v.Visible = false
			end
		end
		
		if ToolType == "Rods" then -- if it's a rod, tween the camera
			if ShopTools:FindFirstChild(Tool.."Camera") then -- if the tool camera was found
				local TweenCamera = TweenService:Create(CurrentCamera, TweenInfo.new(1), {CFrame = ShopTools:FindFirstChild(Tool.."Camera").CFrame}) -- tween the camera to the new tool
				TweenCamera:Play()
			end

		else -- if it's a bait, tween the gui position
			ToolShopGui:FindFirstChild(Tool).Visible = true	
		end
		
		ToolShopGui:FindFirstChild(Tool).Visible = true -- show the tool information

		if lplr.Fishing:FindFirstChild(ToolType):FindFirstChild(Tool).Value == true then -- if the player already owns the tool
			ToolShopGui.Owned.Visible = true -- show the owned image
		else
			ToolShopGui.Buy.Visible = true -- else show the buy button
		end
	end
end


-- PLAYER CLICKS ONE OF THE LEFT ARROW OF THE RODS SHOP GUI

local function LeftArrowClicked(ShopGui, ToolList, ToolType)
	
	if ToolList[1] == ShopGui.CurrentTool.Value then -- if the player is not already at the very left of the tools (otherwise shouldn't be moving left anymore)
		ShopGui.LeftArrow.Visible = false -- hide the left arrow
		return -- return because it should be impossible

	elseif ToolList[2] == ShopGui.CurrentTool.Value then -- if the player is at the second tool
		ShopGui.LeftArrow.Visible = false -- hide the left arrow (because it becomes the first tool once moved)

	else
		ShopGui.LeftArrow.Visible = true -- else show the left arrow
	end

	ShopGui.RightArrow.Visible = true -- show the right arrow anyways

	local ToolPositionInTable = table.find(ToolList, ShopGui.CurrentTool.Value) -- find the tool in the table to get the position
	if ToolPositionInTable then -- if the tool was found

		local NewTool = ToolList[ToolPositionInTable - 1] -- change the tool to the previous one (the one on the left in the table)

		ToolShopArrowClicked(ToolType, NewTool) -- call the function with the new tool as argument
	end
end

-- RODS
RodsShopGui.LeftArrow.MouseButton1Down:Connect(function() -- when player clicks on the left arrow
	LeftArrowClicked(RodsShopGui, RodsList, "Rods")
end)

-- BAITS
BaitsShopGui.LeftArrow.MouseButton1Down:Connect(function() -- when player clicks on the left arrow
	LeftArrowClicked(BaitsShopGui, BaitsList, "Baits")
end)


-- PLAYER CLICKS ON THE RIGHT ARROW ON THE BAITS SHOP GUI

local function RightArrowClicked(ShopGui, ToolList, ToolType)
	
	if ToolList[#ToolList] == ShopGui.CurrentTool.Value then
		ShopGui.RightArrow.Visible = false
		return

	elseif ToolList[#ToolList - 1] == ShopGui.CurrentTool.Value then
		ShopGui.RightArrow.Visible = false

	else
		ShopGui.RightArrow.Visible = true
	end

	ShopGui.LeftArrow.Visible = true

	local ToolPositionInTable = table.find(ToolList, ShopGui.CurrentTool.Value)
	if ToolPositionInTable then
		local NewTool = ToolList[ToolPositionInTable + 1]
		ToolShopArrowClicked(ToolType, NewTool)
	end
end

-- RODS
RodsShopGui.RightArrow.MouseButton1Down:Connect(function() -- when player clicks on the right arrow
	RightArrowClicked(RodsShopGui, RodsList, "Rods")
end)

-- BAITS
BaitsShopGui.RightArrow.MouseButton1Down:Connect(function() -- when player clicks on the left arrow
	RightArrowClicked(BaitsShopGui, BaitsList, "Baits")
end)


-- PLAYER CLICKS THE BUY BUTTON ON THE RODS AND BAITS SHOP GUI

local function BuyItem(ShopGui, ToolType)
	
	CurrentCamera.CameraType = Enum.CameraType.Custom -- set the camera type back to custom

	for i,v in ipairs(ShopGui:GetChildren()) do -- hide all the children of the shop gui (that are not string values)
		if not v:IsA("StringValue") then
			v.Visible = false
		end
	end

	FishingSelectionGui.Visible = true -- show the selection gui (for the animation)

	FishingRemoteEvent:FireServer("Buy", ToolType, ShopGui.CurrentTool.Value) -- fire the remote event to buy the tool and get the animation
end

-- RODS
RodsShopGui.Buy.MouseButton1Down:Connect(function()
	BuyItem(RodsShopGui, "Rods")
end)

-- BAITS
BaitsShopGui.Buy.MouseButton1Down:Connect(function()
	BuyItem(BaitsShopGui, "Baits")	
end)


-- PLAYER CLICKS THE CLOSE BUTTON ON THE RODS SHOP GUI

local function CloseShop(ShopGui)
	
	CurrentCamera.CameraType = Enum.CameraType.Custom -- sets the camera type back to custom

	for i,v in ipairs(ShopGui:GetChildren()) do -- hide all the children of the shop gui (that are not string values)
		if not v:IsA("StringValue") then
			v.Visible = false
		end
	end

	FishingSelectionGui.Visible = true -- show the selection gui (for the animation)
end

-- RODS
RodsShopGui.Close.MouseButton1Down:Connect(function()
	CloseShop(RodsShopGui)
end)

-- BAITS
BaitsShopGui.Close.MouseButton1Down:Connect(function()
	CloseShop(BaitsShopGui)
end)


-- PLAYER SELLS FISHES

for i,v in ipairs(FishingSelectionGui.Fishes:GetChildren()) do
	if v:IsA("ImageLabel") then

		if lplr.Fishing.Fishes:FindFirstChild(v.Name) then
			v.Total.Text = "Total : "..tostring(lplr.Fishing.Fishes:FindFirstChild(v.Name).Value) -- displays the number of items the player has

			v.Amount.TextBox.Focused:Connect(function() -- when player clicks on the textbox
				v.Total.Visible = false -- hide the total number of fishes the player has
				v.MoneyEarnt.Visible = true -- show the money he is gonna earn based on the amount of fishes he is selling
			end)

			v.Amount.TextBox:GetPropertyChangedSignal("Text"):Connect(function() -- remove everything that isn't a number from the textbox
				v.Amount.TextBox.Text = v.Amount.TextBox.Text:gsub("%D+", "")
				if v.Amount.TextBox.Text ~= "" then
					if SellMultiplier[v.Name] then
						v.MoneyEarnt.Text = "+ $"..tostring(tonumber(v.Amount.TextBox.Text) * SellMultiplier[v.Name])
					end
				end
			end)

			v.SellButton.MouseButton1Down:Connect(function() -- players sells the item

				v.MoneyEarnt.Visible = false -- hide the money the player should earn when selling
				v.Total.Visible = true -- show the total number of fishes the player owns

				if v.Amount.TextBox.Text ~= "" then
					local Amount = tonumber(v.Amount.TextBox.Text) -- get the amount

					if Amount <= lplr.Fishing.Fishes:FindFirstChild(v.Name).Value then -- if player has enough item

						FishingRemoteEvent:FireServer("Sell", v.Name, tonumber(v.Amount.TextBox.Text)) -- fire the remote event
						v.Total.Text = "Total : "..lplr.Fishing.Fishes:FindFirstChild(v.Name).Value -- update the number of items the player has
						v.Amount.TextBox.Text = "" -- reset the text box
					end
				end
			end)
		end
	end
end