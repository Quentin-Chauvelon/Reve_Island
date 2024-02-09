local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HouseRemoteEvent = ReplicatedStorage:WaitForChild("House")

local HouseGui = script.Parent

local lplr = game.Players.LocalPlayer
local House = workspace.Houses:WaitForChild(lplr.Name)
local CurrentCamera = workspace.CurrentCamera
local WalkSpeed = 20
local UpgradeClicked, CloseClicked
local FirstTouch = false
local Part = ""


-- RESET GUIS, CAMERA, POSITION

local function Reset(hit)
	HouseGui.Upgrade.Visible = false
	HouseGui.Color.Visible = false
	HouseGui.Close.Visible = false

	CurrentCamera.CameraType = Enum.CameraType.Custom
	hit.Parent.Humanoid.WalkSpeed = WalkSpeed
	
	if workspace.Houses:FindFirstChild(lplr.Name) and workspace.Houses[lplr.Name]:FindFirstChild("TeleportOut") then
		hit.CFrame = workspace.Houses[lplr.Name].TeleportOut.CFrame
	end
end


-- PLAYER TOUCHES THE CUSTOMIZE BUTTON IN HIS HOUSE

House:WaitForChild("Customize").Touched:Connect(function(hit)

	if hit.Name == "HumanoidRootPart" and hit.Parent:FindFirstChild("Humanoid") and hit.Parent.Name == lplr.Name then

		WalkSpeed = hit.Parent.Humanoid.WalkSpeed
		hit.Parent.Humanoid.WalkSpeed = 0

		HouseGui.Upgrade.Visible = true
		HouseGui.Color.Visible = true
		HouseGui.Close.Visible = true

		-- Enable the upgrade gui
		if HouseGui.Upgrade:FindFirstChild("Tier"..tostring(lplr.House.Tier.Value + 1)) then
			HouseGui.Upgrade["Tier"..tostring(lplr.House.Tier.Value + 1)].Visible = true
		end

		-- Enable and disable the available parts based on the house tier
		if lplr.House.Tier.Value == 1 then
			HouseGui.Color.Parts.Porch.BackgroundColor3 = Color3.new(1,1,1)
			HouseGui.Color.Parts.Porch.UIGradient.Enabled = true
			HouseGui.Color.Parts.Porch.AutoButtonColor = false
			HouseGui.Color.Parts.Stairs.BackgroundColor3 = Color3.new(1,1,1)
			HouseGui.Color.Parts.Stairs.UIGradient.Enabled = true
			HouseGui.Color.Parts.Stairs.AutoButtonColor = false
			HouseGui.Color.Parts.Balcony.BackgroundColor3 = Color3.new(1,1,1)
			HouseGui.Color.Parts.Balcony.UIGradient.Enabled = true
			HouseGui.Color.Parts.Balcony.AutoButtonColor = false

		elseif lplr.House.Tier.Value == 2 then
			HouseGui.Color.Parts.Porch.BackgroundColor3 = Color3.new(1,1,1)
			HouseGui.Color.Parts.Porch.UIGradient.Enabled = true
			HouseGui.Color.Parts.Porch.AutoButtonColor = false
			HouseGui.Color.Parts.Stairs.BackgroundColor3 = Color3.fromRGB(181,255,196)
			HouseGui.Color.Parts.Stairs.UIGradient.Enabled = false
			HouseGui.Color.Parts.Stairs.AutoButtonColor = true
			HouseGui.Color.Parts.Balcony.BackgroundColor3 = Color3.fromRGB(181,255,196)
			HouseGui.Color.Parts.Balcony.UIGradient.Enabled = false
			HouseGui.Color.Parts.Balcony.AutoButtonColor = true

		elseif lplr.House.Tier.Value == 3 then
			HouseGui.Color.Parts.Porch.BackgroundColor3 = Color3.fromRGB(181,255,196)
			HouseGui.Color.Parts.Porch.UIGradient.Enabled = false
			HouseGui.Color.Parts.Porch.AutoButtonColor = true
			HouseGui.Color.Parts.Stairs.BackgroundColor3 = Color3.new(1,1,1)
			HouseGui.Color.Parts.Stairs.UIGradient.Enabled = true
			HouseGui.Color.Parts.Stairs.AutoButtonColor = false
			HouseGui.Color.Parts.Balcony.BackgroundColor3 = Color3.new(1,1,1)
			HouseGui.Color.Parts.Balcony.UIGradient.Enabled = true
			HouseGui.Color.Parts.Balcony.AutoButtonColor = false

		elseif lplr.House.Tier.Value == 4 or lplr.House.Tier.Value == 5 then
			HouseGui.Color.Parts.Porch.BackgroundColor3 = Color3.fromRGB(181,255,196)
			HouseGui.Color.Parts.Porch.UIGradient.Enabled = false
			HouseGui.Color.Parts.Porch.AutoButtonColor = true
			HouseGui.Color.Parts.Stairs.BackgroundColor3 = Color3.fromRGB(181,255,196)
			HouseGui.Color.Parts.Stairs.UIGradient.Enabled = false
			HouseGui.Color.Parts.Stairs.AutoButtonColor = true
			HouseGui.Color.Parts.Balcony.BackgroundColor3 = Color3.fromRGB(181,255,196)
			HouseGui.Color.Parts.Balcony.UIGradient.Enabled = false
			HouseGui.Color.Parts.Balcony.AutoButtonColor = true
		end


		-- UPGRADE

		-- Player clicks the button to upgrade his house
		if not FirstTouch then
			FirstTouch = true
			
			HouseGui.Upgrade.UpgradeButton.MouseButton1Down:Connect(function()
				Reset(hit)
				
				if HouseGui.Upgrade:FindFirstChild("Tier"..tostring(lplr.House.Tier.Value + 1)) then
					HouseGui.Upgrade["Tier"..tostring(lplr.House.Tier.Value + 1)].Visible = false
				end
				
				HouseRemoteEvent:FireServer("Upgrade")
			end)


			-- COLOR HOUSE

			for i,v in ipairs(HouseGui.Color.Parts:GetChildren()) do
				if v:IsA("TextButton") and v.AutoButtonColor then

					-- Player clicks one of the part to change its color
					v.MouseButton1Down:Connect(function()
						HouseGui.Upgrade.Visible = false
						HouseGui.Color.Visible = false
						Part = v.Name
						

						CurrentCamera.CameraType = Enum.CameraType.Scriptable

						if House:FindFirstChild(v.Name.."Camera") then
							TweenService:Create(CurrentCamera, TweenInfo.new(1), {CFrame = House[v.Name.."Camera"].CFrame}):Play()
						else
							TweenService:Create(CurrentCamera, TweenInfo.new(1), {CFrame = House.HouseCamera.CFrame}):Play()
						end

						if not HouseGui:FindFirstChild("Palette") then
							local Palette = HouseGui.PaletteTemplate:Clone()
							Palette.Name = "Palette"
							Palette.Visible = true

							-- Get all the palette color clicks
							for a,b in ipairs(Palette:GetChildren()) do
								if b:IsA("ImageButton") then
									b.MouseButton1Down:Connect(function()
										
										if House:FindFirstChild(Part) then
											HouseRemoteEvent:FireServer("Color", Part, b.BackgroundColor3)
										end
									end)
								end
							end

							Palette.Parent = HouseGui
							
						else
							HouseGui.Palette.Visible = true
						end
					end)
				end
			end


			-- CLOSE GUI

			HouseGui.Close.MouseButton1Down:Connect(function()

				if HouseGui:FindFirstChild("Palette") then

					if HouseGui.Palette.Visible then
						HouseGui.Palette.Visible = false
						HouseGui.Upgrade.Visible = true
						HouseGui.Color.Visible = true
						HouseRemoteEvent:FireServer("ValidateColor")
						return

					else
						HouseGui.Palette:Destroy()
					end
				end

				Reset(hit)
			end)
		end
	end
end)