local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TypingRemoteEvent = ReplicatedStorage:WaitForChild("Typing")
local Money = ReplicatedStorage:WaitForChild("Money")
local ComputerRoom = workspace.ComputerRoom
local lplr = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ComputerGui = lplr.PlayerGui:WaitForChild("Computer"):WaitForChild("Screen")
local Idioms = ComputerGui:WaitForChild("Idioms")
local Competitive = ComputerGui:WaitForChild("Competitive")

local IdiomsPlay = false -- variable to restart the idioms typing test if player didn't close the gui
local CompetitivePlay = false -- variable to restart the competitive typing test if player didn't close the gui
local Start = 0
local End = 0
local FullText = ""
local WalkSpeed = 20
local debounce = false

-- when clicking on got it for the help, need to know if player is playing the idioms or the competitive typing test to visible it back

local EnglishIdioms = {
	"A bird in the hand is worth two in the bush",
	"A penny saved is a penny earned",
	"A picture is worth 1000 words",
	"Actions speak louder than words",
	"Birds of a feather flock together",
	"Do unto others as you would have them to unto you",
	"Don't count your chickens before they hatch",
	"Don't give up your day job",
	"Don't put all your eggs in one basket",
	"Every cloud has a silver lining",
	"Good things come to those who wait",
	"He's a chip off the old block",
	"It ain't over till the fat lady sings",
	"Kill two birds with one stone",
	"Look before you leap",
	"Slow and steady wins the race",
	"Take it with a grain of salt",
	"The best thing since sliced bread",
	"There are other fish in the sea",
	"There's a method to his madness",
	"There's no such thing as a free lunch",
	"You can't have your cake and eat it too",
	"You can't judge a book by its cover",
	"Give someone the benefit of the doubt",
	"Go back to the drawing board",
	"Time flies when you're having fun",
	"We'll cross that bridge when we come to it",
	"Your guess is as good as mine"
}

local FrenchIdioms = {
	"Ne pas vendre la peau de l'ours avant de l'avoir tué",
	"Chacun son métier, les vaches seront bien gardées",
	"Il ne faut pas mettres tous ses oeufs dans le même panier",
	"A quelque chose malheur est bon",
	"Tout vient à point à qui sait attendre",
	"Tel père, tel fils",
	"Faire d'une pierre deux coups",
	"Regarder où on met les pieds",
	"Rien ne sert de courir, il faut partir à point",
	"Take it with a grain of salt",
	"Ca ne casse pas trois pattes à un canard",
	"Un de perdu, dix de retrouvés",
	"On n'a rien sans rien",
	"Tu ne peux pas avoir le beurre et l'argent du beurre",
	"Les apparences sont parfois trompeuses",
	"Accorder le bénéfice du doute",
	"Revenir à la case départ",
	"Le temps passe vite quand on s'amuse",
	"Tirer des plans sur la comète",
	"Je n'en sais pas plus que vous",
	"Tant qu'il y a de la vie, il y a de l'espoir",
	"Après la pluie vient le beau temps"
}

local EnglishWords = {
	"the ", "of ", "and ", "a ", "to ", "in ", "he ", "have ", "it ", "that ", "for ",
	"they ", "with ", "as ", "not ", "on ", "she ", "at ", "by ", "this ", "we ", "you ", "do ", "but ",
	"from ", "or ", "which ", "one ", "would ", "all ", "will ", "there ", "say ", "who ", "make ", "when ",
	"can ", "more ", "if ", "no ", "man ", "out ", "other ", "so ", "what ", "time ", "up ", "go ", "about ",
	"than ", "into ", "could ", "state ", "only ", "new ", "year ", "some ", "take ", "come ", "these ",
	"know ", "see ", "use ", "get ", "like ", "then ", "first ", "any ", "work ", "now ", "may ", "such ",
	"give ", "over ", "think ", "most ", "even ", "find ", "day ", "also ", "after ", "way ", "many ",
	"must ", "look ", "before ", "great ", "back ", "through ", "long ", "where ", "much ", "should ",
	"well ", "people ", "down ", "own ", "just ", "because ", "good ", "each ", "those ", "feel ", "seem ",
	"how ", "high ", "too ", "place ", "little ", "world ", "very ", "still ", "nation ", "hand ", "old ",
	"life ", "tell ", "write ", "become ", "here ", "show ", "house ", "both ", "between ", "need ",
	"mean ","call ", "develop ", "under ", "last ", "right ", "move ", "thing ", "general ", "school ",
	"never ", "same ", "another ", "begin ", "while ", "number ", "part ", "turn ", "real ", "leave ",
	"might ", "want ", "point ", "form ", "off ", "child ", "few ", "small ", "since ", "against ",
	"ask ", "late ", "home ", "interest ", "large ", "person ", "end ", "open ", "public ", "follow ",
	"during ", "present ", "without ", "again ", "hold ", "govern ", "around ", "possible ", "head ",
	"consider ", "word ", "program ", "however ", "lead ", "system ", "set ", "order ", "eye ", "plan ",
	"run ", "keep ", "face ", "fact ", "group ", "play ", "stand ", "increase ", "early ", "course ",
	"change ", "help ", "line ", "country "
}

local FrenchWords = {
	"le ", "de ", "un ", "etre ", "et ", "a ", "il ", "avoir ", "ne ", "je ", "son ", "que ",
	"se ", "qui ", "ce ", "dans ", "en ", "du ", "elle ", "au ", "de ", "ce ", "le ", "pour ", "pas ", "que ",
	"vous ", "par ", "sur ", "faire ", "plus ", "dire ", "me ", "on ", "mon ", "lui ", "nous ", "comme ",
	"mais ", "pouvoir ", "avec ", "tout ", "y ", "aller ", "voir ", "en ", "bien ", "ou ", "sans ", "tu ",
	"ou ", "leur ", "homme ", "si ", "deux ", "mari ", "moi ", "vouloir ", "te ", "femme ", "venir ", "quand ",
	"grand ", "celui ", "si ", "notre ", "devoir ", "la ",  "jour ", "prendre ", "meme ", "votre ", "tout ",
	"rien ", "petit ", "encore ", "aussi ", "quelque ", "dont ", "tout ", "mer ", "trouver ", "donner ",
	"temps ", "ça ", "peu ", "meme ", "falloir ", "sous ", "parler ", "alors ", "main ", "chose ", "ton ",
	"mettre ", "vie ", "savoir ", "yeux ", "passer ", "autre ", "apres ", "regarder ", "toujours ", "puis ",
	"jamais ", "cela ", "aimer ", "non ", "heure ", "croire ", "cent ", "monde ", "donc ", "enfant ", "fois ",
	"seul ", "autre ", "entre ", "vers ", "chez ", "demander ", "jeune ", "jusque ", "tres ", "moment ",
	"rester ", "repondre ", "tout ", "tete ", "pere ", "fille ", "mille ", "premier ", "car ", "entendre ",
	"ni ", "bon ", "trois ", "coeur ", "ainsi ", "an ", "quatre ", "un ", "terre ", "contre ", "dieu ",
	"monsieur ", "voix ", "penser ", "quel ", "arriver ", "maison ", "devant ", "coup ", "beau ", "connaître ",
	"devenir ", "air ", "mot ", "nuit ", "sentir ", "eau ", "vieux ", "sembler ", "moins ", "tenir ", "ici ",
	"comprendre ", "oui ", "rendre ", "toi ", "vingt ", "depuis ", "attendre ", "sortir ", "ami ", "trop ",
	"porte ", "lequel ", "chaque ", "amour ", "pendant ", "deja ", "pied ", "tant ", "gens ", "nom ", "vivre ",
	"reprendre ", "entrer ", "porter ", "pays ", "ciel ", "avant ", "frere ", "regard ", "chercher ", "ame ",
	"cote ", "mort "
}



-- WHEN PLAYER SITS AT A DESK

TypingRemoteEvent.OnClientEvent:Connect(function()
	if not debounce then
		debounce = true
		wait(0.5) -- wait for the seating animation to end otherwise player is sitting out of the chair
		WalkSpeed = workspace[lplr.Name].Humanoid.WalkSpeed
		workspace[lplr.Name].Humanoid.WalkSpeed = 0
		workspace[lplr.Name].HumanoidRootPart.Anchored = true

		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = ComputerRoom.CameraPlacement.CFrame

		local CameraZoom = TweenService:Create(Camera, TweenInfo.new(1), {CFrame = CFrame.new(ComputerRoom.CameraZoom.Position, ComputerRoom.Desks.Computer.Computer.Monitor.Position)})
		CameraZoom:Play() -- zoom on computer
		wait(1.5)
		ComputerGui.LFS.Visible = false -- remove the lfs screen
		wait(1)
		ComputerGui.Choice.Visible = true
		ComputerGui.Languages.Visible = true
	end
end)


-- IDIOMS BUTTON

ComputerGui.Choice.Idioms.MouseButton1Click:Connect(function()
	repeat wait() until IdiomsPlay == false -- wait for the previous typing test to finish
	repeat
		IdiomsPlay = true
		ComputerGui.Choice.Visible = false
		Idioms.Visible = true

		if ComputerGui.Languages.Language.Value == "French" then -- select an idiom based on the language
			Idioms.TextToType.Text = FrenchIdioms[math.random(1,#FrenchIdioms)]
		else
			Idioms.TextToType.Text = EnglishIdioms[math.random(1,#EnglishIdioms)]
		end

		Idioms.TypeHere.TextEditable = false -- player can't type

		for i=3,1,-1 do -- countdown
			Idioms.Timer.Text = i
			wait(1)
		end
		Idioms.Timer.Text = "Go"
		
		Idioms.TypeHere.TextEditable = true -- player can type
		if IdiomsPlay == true and ComputerGui.Help.Visible == false then -- if player hasn't close the gui (otherwise he would be frozen) and if hasn't open the help gui (otherwise he couldn't close it) --> issues because of the capture focus on the text box
			Idioms.TypeHere:CaptureFocus() -- force focus on the text (so that player doesn't have to click on it
		end
		wait(1)

		while true do
			Idioms.Timer.Seconds.Value = Idioms.Timer.Seconds.Value + 1 -- timer
			Idioms.Timer.Text = Idioms.Timer.Seconds.Value
			wait(1)

			if Idioms.Timer.Seconds.Value == 60 then -- if the timer reaches 60 which is the maximum
				break -- exit the while true
			end
			
			if not Idioms.TypeHere:IsFocused() then -- if player unselect the textbox
				break -- exit the while true
			end
		end
		
		Idioms.TypeHere.TextEditable = false -- player can't type
		Idioms.TypeHere:ReleaseFocus()
		Idioms.Timer.Seconds.Value = 0 -- set the time to 2 seconds because after the "go" text stays for 3 seconds (so the timer has to start at 3 (2 + 1))
		
		if Idioms.TypeHere.Text == Idioms.TextToType.Text and Idioms.TextToType.Text ~= "" then -- if player typed the correct phrase
			Idioms.Timer.TextColor3 = Color3.new(0,1,0) -- green timer text color
			TypingRemoteEvent:FireServer("Idioms", false, Idioms.Timer.Seconds.Value, "")
			wait(2)
			Idioms.Timer.TextColor3 = Color3.new(1,1,1) -- white timer text color
		else
			Idioms.Timer.TextColor3 = Color3.new(1,0,0) -- red timer text color
			wait(2)
			Idioms.Timer.TextColor3 = Color3.new(1,1,1) -- white timer text color
		end
		Idioms.TypeHere.Text = ""
	until IdiomsPlay == false -- if player has closed the gui then don't start again
end)


-- COMPETITIVE TYPING BUTTON

ComputerGui.Choice.Competitive.MouseButton1Click:Connect(function()
	repeat wait() until CompetitivePlay == false -- when the previous typing test to finish
	repeat
		CompetitivePlay = true -- to know if player is playing
		ComputerGui.Choice.Visible = false
		Competitive.Visible = true
		
		if ComputerGui.Languages.Language.Value == "French" then -- if playing in french
			FullText = "" -- reset the text to type
			for i=1,20 do -- create a text of 20 words
				local Text = FrenchWords[math.random(1,#FrenchWords)] -- choose a random word
				FullText= FullText..Text -- concatenate the text with the new word
			end
			FullText = FullText.."fin" -- add a "fin" at the end because all the random words have a space after them (and player wouldn't that they have to type the space)
			Competitive.TextToType.Text = FullText -- change the text to type
		else -- same for english
			FullText = ""
			for i=1,20 do
				local Text = EnglishWords[math.random(1,#EnglishWords)]
				FullText= FullText..Text
			end
			FullText = FullText.."end"
			Competitive.TextToType.Text = FullText
		end
				
		Competitive.TypeHere.TextEditable = false -- player can't type
		Competitive.Timer.TextXAlignment = Enum.TextXAlignment.Center -- center the text for the countdown
		for i=3,1,-1 do -- countodwn
			Competitive.Timer.Text = i
			wait(1)
		end
		Competitive.Timer.Text = "Go"

		Competitive.TypeHere.TextEditable = true -- playter can type
		
		if CompetitivePlay == true and ComputerGui.Help.Visible == false then -- if player is playing and the help is not visible
			
			TypingRemoteEvent:FireServer("Competitive", true, 0, Competitive.TextToType.Text)
			Competitive.TypeHere:CaptureFocus() -- force player to focus on the textbox
			Start = tick() -- get the start time
		end
		wait(1)
		Competitive.Timer.TextXAlignment = Enum.TextXAlignment.Left -- align the text to the left to display the time
		Competitive.Timer.Text = "Time : "
		
		while wait(0.5) do -- see focus lost event to get the end time
			if not Competitive.TypeHere:IsFocused() then -- if player is not focusing the textbox
				break -- stop
			end
		end
		
		local FinalTime = End - Start -- get the final time
		FinalTime = tonumber(string.format("%." ..(3).. "f", FinalTime)) -- round it to the millisecond
		
		Competitive.TypeHere.TextEditable = false -- player can't type
		Idioms.TypeHere:ReleaseFocus() -- release focus
		Competitive.Timer.Text = "Time : "..FinalTime -- display player's final time

		if Competitive.TypeHere.Text == Competitive.TextToType.Text then -- if player hasn't made any mistake
			Competitive.Timer.TextColor3 = Color3.new(0,1,0) -- green text
			TypingRemoteEvent:FireServer("Competitive", false, FinalTime, Competitive.TypeHere.Text)
			
			if FinalTime < lplr.Stats.TypingPb.Value then
				lplr.PlayerGui.Computer.Screen.Competitive.Pb.Text = "Best : "..FinalTime.."s" -- change the pb text
			end
			
			wait(5)
			Competitive.Timer.TextColor3 = Color3.new(1,1,1)
		else
			Competitive.Timer.TextColor3 = Color3.new(1,0,0) -- red text
			wait(3)
			Competitive.Timer.TextColor3 = Color3.new(1,1,1)
		end
		Competitive.TypeHere.Text = "" -- remove text
	until CompetitivePlay == false -- if player hasn't closed the gui
end)


-- IDIOMS CLOSE BUTTON

Idioms.Close.MouseButton1Click:Connect(function()
	IdiomsPlay = false -- don't restart the typing test after it finishes
	Idioms.Visible = false -- reset
	ComputerGui.LFS.Visible = true
	ComputerGui.Languages.Visible = false
	Idioms.TypeHere.Text = ""
	Idioms.TextToType.Text = ""
	Idioms.Timer.Seconds.Value = 0

	Camera.CameraType = Enum.CameraType.Custom	-- reset the camera, unsit and move player
	workspace[lplr.Name].Humanoid.WalkSpeed = WalkSpeed
	workspace[lplr.Name].HumanoidRootPart.Anchored = false
	wait(.1)
	workspace[lplr.Name].Humanoid.Sit = false
	wait(.1)
	workspace[lplr.Name].HumanoidRootPart.CFrame = ComputerRoom.PlayerPlacement.CFrame

	wait(1)
	debounce = false
end)


-- COMPETITIVE CLOSE BUTTON

Competitive.Close.MouseButton1Click:Connect(function()
	CompetitivePlay = false -- don't restart the typing test after it finishes
	Competitive.Visible = false -- reset
	ComputerGui.LFS.Visible = true
	ComputerGui.Languages.Visible = false
	Competitive.TypeHere.Text = ""

	Camera.CameraType = Enum.CameraType.Custom	-- reset the camera, unsit and move player
	workspace[lplr.Name].Humanoid.WalkSpeed = WalkSpeed
	workspace[lplr.Name].HumanoidRootPart.Anchored = false
	wait(.1)
	workspace[lplr.Name].Humanoid.Sit = false
	wait(.1)
	workspace[lplr.Name].HumanoidRootPart.CFrame = ComputerRoom.PlayerPlacement.CFrame

	wait(1)
	debounce = false
end)


-- HELP BUTTON

Idioms.Help.MouseButton1Click:Connect(function() -- shows help
	Idioms.Visible = false
	ComputerGui.Help.Visible = true
end)


-- HELP BUTTON

Competitive.Help.MouseButton1Click:Connect(function() -- shows help
	Competitive.Visible = false
	ComputerGui.Help.Visible = true
end)


-- "GOT IT" BUTTON IN THE HELP

ComputerGui.Help.TextButton.MouseButton1Click:Connect(function()
	ComputerGui.Help.Visible = false -- shows the back typing test
	if IdiomsPlay == true then
		Idioms.Visible = true
	elseif CompetitivePlay == true then
		Competitive.Visible = true
	else
		ComputerGui.LFS.Visible = true
	end
end)


-- ENGLISH BUTTON

ComputerGui.Languages.English.MouseButton1Click:Connect(function()
	-- english flag : Image by Pete Linforth from Pixabay
	ComputerGui.Languages.Language.Value = "English" -- set language to english
end)


-- FRENCH BUTTON

ComputerGui.Languages.French.MouseButton1Click:Connect(function()
	-- french flag : Image by Clker-Free-Vector-Images from Pixabay 
	ComputerGui.Languages.Language.Value = "French" -- set language to french
end)


-- TEXTBOX FOCUS LOST

Competitive.TypeHere.FocusLost:Connect(function()
	End = tick() -- get the end time
end)

-------------------------------------------------------------------------------------------------------

local Leaderboard = workspace.ComputerRoom.Leaderboard.SurfaceGui.Frame


-- RANKING BUTTON CLICK

Leaderboard.Ranking.MouseButton1Down:Connect(function() -- show the rankings
	Leaderboard.Header.Visible = true
	Leaderboard.ScrollingFrame.Visible = true
	Leaderboard.RewardFrame.Visible = false
	Leaderboard.Ranking.BackgroundColor3 = Color3.fromRGB(206, 206, 206) -- change the buttons colors
	Leaderboard.Ranking.TextColor3 = Color3.fromRGB(121, 121, 121)
	Leaderboard.Ranking.TopLeft.BackgroundColor3 = Color3.fromRGB(206, 206, 206)
	Leaderboard.Ranking.TopRight.BackgroundColor3 = Color3.fromRGB(206, 206, 206)
	
	Leaderboard.Reward.BackgroundColor3 = Color3.fromRGB(121, 121, 121)
	Leaderboard.Reward.TextColor3 = Color3.fromRGB(206, 206, 206)
	Leaderboard.Reward.TopLeft.BackgroundColor3 = Color3.fromRGB(121, 121, 121)
	Leaderboard.Reward.TopRight.BackgroundColor3 = Color3.fromRGB(121, 121, 121)
end)


-- REWARD BUTTON CLICK

Leaderboard.Reward.MouseButton1Down:Connect(function() -- show the rewards
	Leaderboard.RewardFrame.Visible = true
	Leaderboard.Header.Visible = false
	Leaderboard.ScrollingFrame.Visible = false
	Leaderboard.Reward.BackgroundColor3 = Color3.fromRGB(206, 206, 206)
	Leaderboard.Reward.TextColor3 = Color3.fromRGB(121, 121, 121) -- change the buttons colors
	Leaderboard.Reward.TopLeft.BackgroundColor3 = Color3.fromRGB(206, 206, 206)
	Leaderboard.Reward.TopRight.BackgroundColor3 = Color3.fromRGB(206, 206, 206)

	Leaderboard.Ranking.BackgroundColor3 = Color3.fromRGB(121, 121, 121)
	Leaderboard.Ranking.TextColor3 = Color3.fromRGB(206, 206, 206)
	Leaderboard.Ranking.TopLeft.BackgroundColor3 = Color3.fromRGB(121, 121, 121)
	Leaderboard.Ranking.TopRight.BackgroundColor3 = Color3.fromRGB(121, 121, 121)
end)