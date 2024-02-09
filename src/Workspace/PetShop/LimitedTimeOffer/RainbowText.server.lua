local Text1 = game.Workspace.PetShop.LimitedTimeOffer.Part.SurfaceGui.TextLabel.UIGradient
local Text2 = game.Workspace.PetShop.LimitedTimeOffer.Egg.Right.Frame.Unique.UIGradient
local Text3 = game.Workspace.PetShop.LimitedTimeOffer.Egg.Left.Frame.Rarity.UIGradient
local Lights = game.Workspace.PetShop.LimitedTimeOffer.Lights
local Egg = game.Workspace.PetShop.LimitedTimeOffer.Egg

local RotateGradient = coroutine.wrap(function()
	while true do
		for i=0,360,5 do
			Text1.Rotation = i
			Text2.Rotation = i
			Text3.Rotation = i
			wait()
		end
	end
end)

local MulticolorLights = coroutine.wrap(function()
	while true do
		for i=0,255,10 do
			Lights.Color = Color3.fromRGB(255,i,0)
			wait(.1)
		end
		for i=255,0,-10 do
			Lights.Color = Color3.fromRGB(i,255,0)
			wait(.1)
		end
		for i=0,255,10 do
			Lights.Color = Color3.fromRGB(0,255,i)
			wait(.1)
		end
		for i=255,0,-10 do
			Lights.Color = Color3.fromRGB(0,i,255)
			wait(.1)
		end
		for i=0,255,10 do
			Lights.Color = Color3.fromRGB(i,0,255)
			wait(.1)
		end
		for i=255,0,-10 do
			Lights.Color = Color3.fromRGB(255,0,i)
			wait(.1)
		end
	end
end)

local NeonEgg = coroutine.wrap(function()
	while true do
		for i=0,0.4,0.05 do
			Egg.Transparency = i
			wait(0.1)
		end
		for i=0.4,0,-0.05 do
			Egg.Transparency = i
			wait(0.1)
		end
	end
end)


RotateGradient()
MulticolorLights()
NeonEgg()