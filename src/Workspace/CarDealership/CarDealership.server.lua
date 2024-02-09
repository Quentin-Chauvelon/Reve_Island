local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local BuyCarBindableEvent = ServerStorage:WaitForChild("BuyCar")
local MoneyBindableEvent = ServerStorage:WaitForChild("Money")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuyCarRemoteEvent = ReplicatedStorage:WaitForChild("BuyCar")

local CarDealership = workspace.CarDealership
local Direction = "Left"
local i = 1

local CarPrice = {
	Car1 = 100000, -- Bicycle
	Car2 = 250000, -- Nimi
	Car3 = 500000 -- Sedan
}


-- PLAYER HAS CLICKED THE BUY BUTTON TO BUY A CAR

BuyCarRemoteEvent.OnServerEvent:Connect(function(plr, Car)
	
	local CarValue = plr.Cars:FindFirstChild(Car) -- look for the car value in the folder to see if the player owns the car
	
	if CarValue then -- if the car value was found
		
		if CarValue.Value == false then -- if it is false, the player doesn't own the car and can then buy it
			local Price = CarPrice[Car]
			
			if Price then
				if plr:FindFirstChild("PetCustomisations") and plr:FindFirstChild("PetCustomisations"):FindFirstChild("EquippedPet") and plr:FindFirstChild("PetCustomisations"):FindFirstChild("EquippedPet").Value == "Fox" then
					Price = math.floor(Price * 0.9)
				end  

				local EnoughMoney = MoneyBindableEvent:Invoke(plr, CarPrice[Car], "-") -- check if player has enough money to buy the car
				if EnoughMoney == true then -- if the player has enough money

					BuyCarBindableEvent:Fire(plr, Car) -- fire the datastore to save the car the player just bought
					BuyCarRemoteEvent:FireClient(plr) -- fire client to hide the gui

					--local Raycast1Result = workspace:Raycast(CarDealership.RayCasting.Caster1.Position, (CarDealership.RayCasting.Caster1Direction.Position - CarDealership.RayCasting.Caster1.Position).Unit*25) -- check if there is something in the way or if we can spawn a car
					--local Raycast2Result = workspace:Raycast(CarDealership.RayCasting.Caster2.Position, (CarDealership.RayCasting.Caster2Direction.Position - CarDealership.RayCasting.Caster2.Position).Unit*25)

					--i = 1 -- variable used to move the raycaster multiple times by multiplying by i (i increasing by 1 each time)

					--while Raycast1Result or Raycast2Result do
					--	CarDealership.RayCasting:SetPrimaryPartCFrame(CarDealership.RayCasting.PrimaryPart.CFrame + (CarDealership.MoveCasterLeft.Position - CarDealership.RayCasting.Root.Position).Unit * i * 12) -- move the raycasters 12 * i studs away to the left
					--	CarDealership.RayCasting:SetPrimaryPartCFrame(CarDealership.RayCasting.PrimaryPart.CFrame + (CarDealership.MoveCasterLeft.Position - CarDealership.RayCasting.Root.Position).Unit * i * 12)

					--	Raycast1Result = workspace:Raycast(CarDealership.RayCasting.Caster1.Position, (CarDealership.RayCasting.Caster1Direction.Position - CarDealership.RayCasting.Caster1.Position).Unit*25)
					--	Raycast2Result = workspace:Raycast(CarDealership.RayCasting.Caster2.Position, (CarDealership.RayCasting.Caster2Direction.Position - CarDealership.RayCasting.Caster2.Position).Unit*25)

					--	Direction = "Left" -- moved to the left

					--	if Raycast1Result or Raycast2Result then -- if there is nothing in the way
					--		CarDealership.RayCasting:SetPrimaryPartCFrame(CarDealership.RayCasting.PrimaryPart.CFrame + (CarDealership.MoveCasterRight.Position - CarDealership.RayCasting.Root.Position).Unit * i * 24) -- move the raycasters 12 * i studs away to the right
					--		CarDealership.RayCasting:SetPrimaryPartCFrame(CarDealership.RayCasting.PrimaryPart.CFrame + (CarDealership.MoveCasterRight.Position - CarDealership.RayCasting.Root.Position).Unit * i * 24)

					--		Raycast1Result = workspace:Raycast(CarDealership.RayCasting.Caster1.Position, (CarDealership.RayCasting.Caster1Direction.Position - CarDealership.RayCasting.Caster1.Position).Unit*25)
					--		Raycast2Result = workspace:Raycast(CarDealership.RayCasting.Caster2.Position, (CarDealership.RayCasting.Caster2Direction.Position - CarDealership.RayCasting.Caster2.Position).Unit*25)

					--		Direction = "Right"	-- moved to the right
					--	end

					--	CarDealership.RayCasting:SetPrimaryPartCFrame(CarDealership.CarPosition.CFrame) -- reset the position of the raycasters

					--	i = i + 1 -- add 1 to i to move the raycasters further each time

					--	if i > 4 then -- if i is greater than 4 then the raycaster are too far away to spawn a car
					--		break
					--	end

					--end		
					--local CarClone = CarDealership.Cars:FindFirstChild(Car) -- find the car

					--if CarClone then -- if the car was found
					--	CarClone = CarClone:Clone() -- clone the car
					--	CarClone.Parent = workspace.Cars -- parent it to the car folder in the workspace
					--	CarDealership.DownPosition.CFrame = CarDealership.DownPosition.CFrame + (CarDealership.MoveCasterLeft.Position - CarDealership.RayCastingRootPosition.Position).Unit * i * 12 -- move the DownPosition part at the same distance as the car clone to then move it away from the car dealership
					--	CarClone:SetPrimaryPartCFrame(CarDealership.RayCastingRootPosition.CFrame + (CarDealership.MoveCasterLeft.Position - CarDealership.RayCastingRootPosition.Position).Unit * i * 12 + Vector3.new(0,20,0)) -- move the car clone

					--	if CarClone.PrimaryPart.Size.X > CarClone.PrimaryPart.Size.Z then -- if the x size of the car is greater than the z size
					--		CarClone:SetPrimaryPartCFrame(CarClone.PrimaryPart.CFrame + (CarDealership.DownPosition.Position - CarClone.PrimaryPart.Position).Unit * (CarClone.PrimaryPart.Size.X - 25) / 2) -- if the car is bigger than the raycasting root, then move it away even more from the car dealership
					--	else -- else if the z size is greater than the x size
					--		CarClone:SetPrimaryPartCFrame(CarClone.PrimaryPart.CFrame + (CarDealership.DownPosition.Position - CarClone.PrimaryPart.Position).Unit * (CarClone.PrimaryPart.Size.Z - 25) / 2)
					--	end

					--	CarDealership.DownPosition.CFrame = CarDealership.DownPosition.CFrame - (CarDealership.MoveCasterLeft.Position - CarDealership.RayCastingRootPosition.Position).Unit * i * 12 -- reset the DownPosition part position

					--	i = 1 -- reset i
					--end

					workspace:FindFirstChild(plr.Name).HumanoidRootPart.CFrame = CarDealership.PlayerPlacement.CFrame -- teleport the player out of the car dealership
				end
			end
		end
	end
end)

--[[

the car dealership will work as follow :

Server :
On BuyCar server event :
Check in the settings if the player owns the car
If he doesn't, fire the money remote function to buy the car
Change the car's bool value in the car folder in the player to true
Fire the datastore to save the car the player just bought
Close the gui (tween ?)
Spawn a car outside of the shop, so that the player can take it (use raycasting to make sure there is nothing in the way)
--> have two raycast (12 studs or so apart and low to the ground), check if there is something, if not spawn car, if yes, enter a while CannotSpawnCar loop and move the raycasters x times 15 studs in each direction until a spot is freed
Teleport the player outside


WHEN A PLAYER ENTERS A CAR, PARENT IT TO A CAR FOLDER AND CHANGE THE NAME TO Player..sCar, then when player enters a car, check if he already has one and delete it (apply it to the bus and delivery truck if possible)


Gui :
When player clicks on one of the arrow :
Tween the size of the stats bar (use offset on the gradient to make it green to red only when full, otherwise mostly green or yellow (to show that it is not full))
Change the price
Change the name of the car
Change the image of the car (move camera or move object in front of the camera (table with the exact position to which you have to move the car so that it doesn'fits perfectly inside of the ViewportFrame))
Change the Buy/Own text (in the player, have a fodler (Name : "Cars"), with bool values corresponding to every single car in the game, if the value is true, it means that the player owns the car, and if it's false, it means that the player doesn't own the car)


When player enters a car, change its parent to a cars folder in the workspace + change the name to "PlayerName..sCar"
And then, when a player enters a car, check in the cars folder if the player already has a car, if true, delete the previous car (to prevent lag by not having too many cars at once)
Have a part in the car model that has the size of the whole model (use it to get the max values for the size of the car) --> set it to the primary part

ROTATE THE VEHICLE :
local StopTween = Instance.new("BoolValue", workspace)
StopTween.Name = "StopTween"
local TweenService = game:GetSesrvice("TweenService")
while StopTween.Value == false do
local TweenService = game:GetService("TweenService")
	local Tween = TweenService:Create(game.StarterGui.CarDealership.Test2.ViewportFrame.Car, TweenInfo.new(12, Enum.EasingStyle.Linear), {Orientation = game.StarterGui.CarDealership.Test2.ViewportFrame.Car.Orientation - Vector3.new(0,360,0)})
	Tween:Play()
	wait(6)
	Tween:Cancel()
	wait(1)
end
StopTween:Destroy()


CHANGE THE CAMERA CFRAME :
 game.StarterGui.Car.Test1.ViewportFrame.Test1Camera.CFrame = workspace.CurrentCamera.CFrame


ON GUI ARROW BUTTON CLICK :
Delete the previous car
When going right or left, change a value "i" to +1 or -1 and then look for the value [i] in the table, once i got that value, i get the name of the car, and the position associated with it to display the car in the viewportframe
Change i if it is too high or too low
--]]


--[[

CARS LIST :

Tesla Roadster
Lamborghini aventador
Buggati chiron
Family car (Renault twingo ?)
Peugeot 508 (or something like it) ?
Renault Captur (or something like it) ?
SUV
Pick up (huge american ones)
Old car (like the ones that we can usually sea at the sea)

Taxi ?

Bus accordéon
Bus

Big truck (18 wheeler ?)
Small truck (like delivery but better ?)

Helicopter (on the top of the car dealership ?)

--]]