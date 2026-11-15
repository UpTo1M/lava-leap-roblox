-- Lava Leap: everything the player sees (client).
-- Builds the whole UI in code so the place needs no pre-made GUI: a start
-- screen, a live HUD (timer, coins, wins, round), a center announcement
-- banner, and an end-of-round screen. Listens to ReplicatedStorage.Events.
-- HUD text stays clear of the top-left corner, where Roblox puts its own menu.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Format = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Format"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Events = ReplicatedStorage:WaitForChild("Events")
local GameStateEvent = Events:WaitForChild("GameState")
local AnnounceEvent = Events:WaitForChild("Announce")

-- ---------------------------------------------------------------- helpers
local function makeLabel(parent, name, text, size, color, position, anchor)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Text = text
	label.TextSize = size
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = color
	label.BackgroundTransparency = 1
	label.TextStrokeTransparency = 0.6
	label.Size = UDim2.fromOffset(400, 48)
	label.AnchorPoint = anchor or Vector2.new(0.5, 0)
	label.Position = position
	label.Parent = parent
	return label
end

local function makeButton(parent, name, text, size, position)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.TextSize = size
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.BackgroundColor3 = Color3.fromRGB(46, 160, 67)
	button.BorderSizePixel = 0
	button.Size = UDim2.fromOffset(260, 56)
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.Position = position
	button.AutoButtonColor = true
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button
	button.Parent = parent
	return button
end

local function makeChip(parent, name, position)
	local chip = Instance.new("Frame")
	chip.Name = name
	chip.Size = UDim2.fromOffset(170, 44)
	chip.AnchorPoint = Vector2.new(0.5, 0)
	chip.Position = position
	chip.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	chip.BackgroundTransparency = 0.25
	chip.BorderSizePixel = 0
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = chip
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Text = ""
	label.TextSize = 22
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Parent = chip
	chip.Parent = parent
	return chip
end

-- ---------------------------------------------------------------- gui root
local gui = Instance.new("ScreenGui")
gui.Name = "LavaLeapGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- ---------------------------------------------------------------- HUD
local hud = Instance.new("Frame")
hud.Name = "HUD"
hud.Size = UDim2.fromScale(1, 1)
hud.BackgroundTransparency = 1
hud.Visible = false
hud.Parent = gui

-- Timer sits top-center; coins top-right; wins below them; round top-center
-- under the timer. Nothing is drawn in the top-left corner.
local timerChip = makeChip(hud, "TimerChip", UDim2.new(0.5, 0, 0, 12))
timerChip.Size = UDim2.fromOffset(200, 52)
timerChip.Text.TextSize = 30
timerChip.Text.Text = "01:30"

local coinsChip = makeChip(hud, "CoinsChip", UDim2.new(1, -96, 0, 12))
coinsChip.Text.Text = "🪙 0"

local winsChip = makeChip(hud, "WinsChip", UDim2.new(1, -96, 0, 66))
winsChip.Text.Text = "🏆 0"

local roundLabel = makeLabel(hud, "RoundLabel", "Round 1", 20, Color3.fromRGB(255, 255, 255), UDim2.new(0.5, 0, 0, 68))
roundLabel.TextTransparency = 0.1

local banner = makeLabel(hud, "Banner", "", 34, Color3.fromRGB(255, 220, 80), UDim2.new(0.5, 0, 0.5, -120))
banner.Size = UDim2.fromOffset(700, 56)
local bannerSub = makeLabel(hud, "BannerSub", "", 20, Color3.fromRGB(255, 255, 255), UDim2.new(0.5, 0, 0.5, -64))
bannerSub.Size = UDim2.fromOffset(700, 36)

local bannerUntil = 0
local function showBanner(text, subtext)
	banner.Text = text
	bannerSub.Text = subtext or ""
	bannerUntil = os.clock() + Config.BANNER_TIME
end

AnnounceEvent.OnClientEvent:Connect(function(text, subtext)
	showBanner(text, subtext)
end)

-- ---------------------------------------------------------------- start screen
local startScreen = Instance.new("Frame")
startScreen.Name = "StartScreen"
startScreen.Size = UDim2.fromScale(1, 1)
startScreen.BackgroundColor3 = Color3.fromRGB(12, 10, 26)
startScreen.BackgroundTransparency = 0.15
startScreen.BorderSizePixel = 0
startScreen.Parent = gui

makeLabel(startScreen, "Title", "🌋 LAVA LEAP", 64, Color3.fromRGB(255, 120, 40), UDim2.new(0.5, 0, 0.5, -160)).Size = UDim2.fromOffset(700, 90)
makeLabel(startScreen, "Subtitle", "Sky Obby Rush  •  outrun the lava, grab the coins", 24, Color3.fromRGB(255, 255, 255), UDim2.new(0.5, 0, 0.5, -80)).Size = UDim2.fromOffset(700, 40)
makeLabel(startScreen, "HowTo", "Jump the floating platforms and reach the golden flag\nbefore the timer runs out. Touching the lava sends you back\nto the start. Moving platforms glide, cracked ones crumble.", 20, Color3.fromRGB(220, 220, 235), UDim2.new(0.5, 0, 0.5, -30)).Size = UDim2.fromOffset(700, 90)
makeLabel(startScreen, "Controls", "Move: WASD / Arrow keys  •  Jump: Space  •  Mobile: on-screen joystick", 18, Color3.fromRGB(180, 180, 200), UDim2.new(0.5, 0, 0.5, 70)).Size = UDim2.fromOffset(700, 36)

local playButton = makeButton(startScreen, "PlayButton", "▶  PLAY", 28, UDim2.new(0.5, 0, 0.5, 140))
local bestLabel = makeLabel(startScreen, "BestLabel", "Best time: --:--", 18, Color3.fromRGB(255, 220, 80), UDim2.new(0.5, 0, 0.5, 190))
bestLabel.Size = UDim2.fromOffset(400, 32)

-- ---------------------------------------------------------------- end screen
local endScreen = Instance.new("Frame")
endScreen.Name = "EndScreen"
endScreen.Size = UDim2.fromScale(1, 1)
endScreen.BackgroundColor3 = Color3.fromRGB(12, 10, 26)
endScreen.BackgroundTransparency = 0.25
endScreen.BorderSizePixel = 0
endScreen.Visible = false
endScreen.Parent = gui

local endTitle = makeLabel(endScreen, "EndTitle", "Round over!", 48, Color3.fromRGB(255, 220, 80), UDim2.new(0.5, 0, 0.5, -90))
endTitle.Size = UDim2.fromOffset(700, 70)
local endStats = makeLabel(endScreen, "EndStats", "", 22, Color3.fromRGB(255, 255, 255), UDim2.new(0.5, 0, 0.5, -10))
endStats.Size = UDim2.fromOffset(700, 80)
local againButton = makeButton(endScreen, "AgainButton", "↻  PLAY AGAIN", 24, UDim2.new(0.5, 0, 0.5, 90))

-- ---------------------------------------------------------------- state
local currentState = "INTERMISSION"
local timeLeft = Config.INTERMISSION_TIME
local lastServerUpdate = os.clock()
local myBest = 0

local function refreshStats()
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		local coins = stats:FindFirstChild("Coins")
		if coins then
			coinsChip.Text.Text = "🪙 " .. tostring(coins.Value)
		end
		local wins = stats:FindFirstChild("Wins")
		if wins then
			winsChip.Text.Text = "🏆 " .. tostring(wins.Value)
		end
		local best = stats:FindFirstChild("BestTime")
		if best then
			myBest = best.Value
			bestLabel.Text = "Best time: " .. Format.bestTime(myBest)
		end
	end
end

local function openEndScreen(won)
	endScreen.Visible = true
	hud.Visible = true
	if won then
		endTitle.Text = "🏁 YOU FINISHED!"
		endTitle.TextColor3 = Color3.fromRGB(90, 230, 120)
	else
		endTitle.Text = "⏱ TIME'S UP!"
		endTitle.TextColor3 = Color3.fromRGB(255, 120, 90)
	end
	local stats = player:FindFirstChild("leaderstats")
	local coins = stats and stats:FindFirstChild("Coins")
	local wins = stats and stats:FindFirstChild("Wins")
	endStats.Text = "Coins: " .. tostring(coins and coins.Value or 0)
		.. "    Wins: " .. tostring(wins and wins.Value or 0)
		.. "\nBest time: " .. Format.bestTime(myBest)
end

playButton.MouseButton1Click:Connect(function()
	startScreen.Visible = false
	hud.Visible = true
end)

againButton.MouseButton1Click:Connect(function()
	endScreen.Visible = false
	hud.Visible = true
end)

GameStateEvent.OnClientEvent:Connect(function(snapshot)
	currentState = snapshot.state
	timeLeft = snapshot.timeLeft
	lastServerUpdate = os.clock()
	if snapshot.round and snapshot.round > 0 then
		roundLabel.Text = "Round " .. tostring(snapshot.round)
	end
	if currentState == "END" then
		-- Show the end screen once per round end; the server sends END
		-- snapshots every second, so only open it when it is not already up.
		if not endScreen.Visible and not startScreen.Visible then
			openEndScreen(false)
		end
	elseif currentState == "PLAYING" then
		endScreen.Visible = false
	end
	refreshStats()
end)

-- Watch leaderstats directly so coin pickups update the HUD instantly.
task.spawn(function()
	local stats = player:WaitForChild("leaderstats", 30)
	if stats then
		for _, value in ipairs(stats:GetChildren()) do
			if value:IsA("ValueBase") then
				value.Changed:Connect(refreshStats)
			end
		end
	end
	refreshStats()
end)

-- Smooth local countdown between the server's once-a-second broadcasts,
-- and banner auto-hide.
RunService.RenderStepped:Connect(function()
	if currentState == "PLAYING" or currentState == "INTERMISSION" then
		local shown = timeLeft - (os.clock() - lastServerUpdate)
		if shown < 0 then
			shown = 0
		end
		timerChip.Text.Text = Format.clock(shown)
		if currentState == "PLAYING" and shown <= Config.COUNTDOWN_BEEP_AT then
			timerChip.Text.TextColor3 = Color3.fromRGB(255, 90, 80)
		else
			timerChip.Text.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
	if os.clock() > bannerUntil then
		banner.Text = ""
		bannerSub.Text = ""
	end
end)

refreshStats()
print("Lava Leap client ready.")
