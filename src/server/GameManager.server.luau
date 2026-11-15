-- Lava Leap: round flow, leaderstats and wins (server).
-- Owns the game state machine: INTERMISSION -> PLAYING -> END -> INTERMISSION ...
-- Fires ReplicatedStorage.Events.GameState so every client HUD stays in sync,
-- and ReplicatedStorage.Events.Announce for center-screen banners.
-- The course itself (lava, coins, movers, crumble pads, finish) lives in Course.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Format = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Format"))

local Events = ReplicatedStorage:WaitForChild("Events")
local GameStateEvent = Events:WaitForChild("GameState")
local AnnounceEvent = Events:WaitForChild("Announce")

local STATE_INTERMISSION = "INTERMISSION"
local STATE_PLAYING = "PLAYING"
local STATE_END = "END"

local state = STATE_INTERMISSION
local stateEndsAt = os.clock() + Config.INTERMISSION_TIME
local roundStartAt = 0
local roundNumber = 0
local roundWinners = {} -- [player] = finish time in seconds, this round only
local winnerCount = 0

local function stateTimeLeft()
	return math.max(0, stateEndsAt - os.clock())
end

local function broadcast()
	GameStateEvent:FireAllClients({
		state = state,
		timeLeft = stateTimeLeft(),
		round = roundNumber,
		winners = winnerCount,
	})
end

local function announce(text, subtext)
	AnnounceEvent:FireAllClients(text, subtext or "")
end

local function setupLeaderstats(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = stats

	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Value = 0
	wins.Parent = stats

	local best = Instance.new("NumberValue")
	best.Name = "BestTime"
	best.Value = 0 -- 0 means "never finished yet"
	best.Parent = stats

	stats.Parent = player
end

local function respawnPlayer(player)
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Health = 0
		end
	end
end

local function respawnEveryone()
	for _, player in ipairs(Players:GetPlayers()) do
		respawnPlayer(player)
	end
end

-- Called by Course when a player touches the finish pad during PLAYING.
local function onPlayerFinished(player)
	if state ~= STATE_PLAYING then
		return
	end
	if roundWinners[player] then
		return -- one finish per player per round
	end
	local finishTime = os.clock() - roundStartAt
	roundWinners[player] = finishTime
	winnerCount = winnerCount + 1

	local stats = player:FindFirstChild("leaderstats")
	if stats then
		local wins = stats:FindFirstChild("Wins")
		if wins then
			wins.Value = wins.Value + 1
		end
		local coins = stats:FindFirstChild("Coins")
		if coins then
			coins.Value = coins.Value + Config.WIN_COIN_BONUS
		end
		local best = stats:FindFirstChild("BestTime")
		if best and (best.Value == 0 or finishTime < best.Value) then
			best.Value = finishTime
		end
	end

	if winnerCount == 1 then
		announce(player.DisplayName .. " finished first!", "Time " .. Format.clock(finishTime) .. "  •  +" .. tostring(Config.WIN_COIN_BONUS) .. " coins")
	else
		announce(player.DisplayName .. " finished!", "Time " .. Format.clock(finishTime))
	end
end

-- Course calls this through a BindableFunction it creates; keep the link loose
-- so this script never errors if Course loads in a different order.
local finishedSignal = Instance.new("BindableEvent")
finishedSignal.Name = "PlayerFinished"
finishedSignal.Event:Connect(onPlayerFinished)
finishedSignal.Parent = script

local function startRound()
	roundNumber = roundNumber + 1
	roundWinners = {}
	winnerCount = 0
	state = STATE_PLAYING
	roundStartAt = os.clock()
	stateEndsAt = roundStartAt + Config.ROUND_TIME
	respawnEveryone()
	announce("GO! Reach the flag!", "Round " .. tostring(roundNumber) .. "  •  " .. Format.clock(Config.ROUND_TIME) .. " on the clock")
	broadcast()
end

local function endRound(reason)
	state = STATE_END
	stateEndsAt = os.clock() + Config.END_TIME
	if winnerCount == 0 then
		announce("Time's up!", reason or "Nobody reached the flag this round.")
	else
		announce("Round over!", tostring(winnerCount) .. " player(s) finished.")
	end
	broadcast()
end

local function startIntermission()
	state = STATE_INTERMISSION
	stateEndsAt = os.clock() + Config.INTERMISSION_TIME
	roundWinners = {}
	winnerCount = 0
	respawnEveryone()
	announce("Next round soon", "Get ready on the start platform")
	broadcast()
end

Players.PlayerAdded:Connect(function(player)
	setupLeaderstats(player)
	-- Send the current state straight to the joiner; FireAllClients already
	-- covers everyone else on the next tick.
	task.spawn(function()
		task.wait(1)
		GameStateEvent:FireClient(player, {
			state = state,
			timeLeft = stateTimeLeft(),
			round = roundNumber,
			winners = winnerCount,
		})
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	setupLeaderstats(player)
end

-- Main loop. One tick a second is enough: the client counts the timer down
-- smoothly between broadcasts.
announce("Welcome to Lava Leap!", "Collect coins, dodge the lava, reach the flag")
while true do
	if state == STATE_INTERMISSION then
		if stateTimeLeft() <= 0 then
			startRound()
		end
	elseif state == STATE_PLAYING then
		if stateTimeLeft() <= 0 then
			endRound()
		end
	elseif state == STATE_END then
		if stateTimeLeft() <= 0 then
			startIntermission()
		end
	end
	broadcast()
	task.wait(1)
end
