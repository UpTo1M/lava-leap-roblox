-- Lava Leap: the course itself (server).
-- Lava kills, coins spin and pay out, moving platforms glide, crumble pads fall
-- away under your feet, and the finish pad reports wins to GameManager.
-- Every behaviour reads its tuning from Shared.Config; nothing is hard-coded here
-- except the shape of the course, which default.project.json defines.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local courseFolder = Workspace:WaitForChild("Course")
local finishFolder = Workspace:WaitForChild("Finish")
local coinsFolder = Workspace:WaitForChild("Coins")
local lava = Workspace:WaitForChild("Lava")
local goalPad = finishFolder:WaitForChild("GoalPad")

-- The finish signal GameManager listens on (created by GameManager.server).
local gameManager = nil
local finishedSignal = nil
task.spawn(function()
	local server = game:GetService("ServerScriptService"):WaitForChild("Server")
	gameManager = server:WaitForChild("GameManager")
	finishedSignal = gameManager:WaitForChild("PlayerFinished")
end)

-- ---------------------------------------------------------------- lava
local lavaCooldown = {} -- [player] = last kill time, stops double-kills

local function onLavaTouched(part)
	local character = part.Parent
	if not character then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	local now = os.clock()
	if lavaCooldown[player] and now - lavaCooldown[player] < 1 then
		return
	end
	lavaCooldown[player] = now
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid.Health = 0
	end
end

lava.Touched:Connect(onLavaTouched)

-- Safety net: anything that slips below the lava (a flung character, a
-- platform glitch) is respawned instead of falling forever.
RunService.Heartbeat:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local root = character:FindFirstChild("HumanoidRootPart")
			if root and root.Position.Y < Config.LAVA_TOP_Y - 20 then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health > 0 then
					humanoid.Health = 0
				end
			end
		end
	end
end)

-- ---------------------------------------------------------------- coins
local coinHome = {} -- [coin part] = home CFrame
local coinBusy = {} -- [coin part] = true while collected and waiting to respawn

for _, coin in ipairs(coinsFolder:GetChildren()) do
	if coin:IsA("BasePart") then
		coinHome[coin] = coin.CFrame
		coin.Touched:Connect(function(part)
			if coinBusy[coin] then
				return
			end
			local character = part.Parent
			if not character then
				return
			end
			local player = Players:GetPlayerFromCharacter(character)
			if not player then
				return
			end
			coinBusy[coin] = true
			coin.Transparency = 1
			coin.CanTouch = false
			local stats = player:FindFirstChild("leaderstats")
			if stats then
				local coins = stats:FindFirstChild("Coins")
				if coins then
					coins.Value = coins.Value + 1
				end
			end
			task.delay(Config.COIN_RESPAWN_TIME, function()
				coin.Transparency = 0
				coin.CanTouch = true
				coinBusy[coin] = false
			end)
		end)
	end
end

-- Coins spin in place so players can spot them from across the course.
RunService.Heartbeat:Connect(function(dt)
	for coin, home in pairs(coinHome) do
		if not coinBusy[coin] and coin.Parent then
			coin.CFrame = home * CFrame.Angles(0, os.clock() * 1.5, 0)
		end
	end
end)

-- ---------------------------------------------------------------- movers
local movers = {} -- {part, homeCFrame, axis, distance, speed}
for name, spec in pairs(Config.MOVERS) do
	local platform = courseFolder:FindFirstChild(name)
	if platform and platform:IsA("BasePart") then
		table.insert(movers, {
			part = platform,
			home = platform.CFrame,
			axis = spec.axis,
			distance = spec.distance,
			speed = spec.speed,
		})
	end
end

RunService.Heartbeat:Connect(function()
	local t = os.clock()
	for _, mover in ipairs(movers) do
		local offset = math.sin(t * math.pi * 2 * mover.speed) * mover.distance
		local shift = Vector3.new(0, 0, 0)
		if mover.axis == "X" then
			shift = Vector3.new(offset, 0, 0)
		else
			shift = Vector3.new(0, 0, offset)
		end
		mover.part.CFrame = mover.home + shift
	end
end)

-- ---------------------------------------------------------------- crumble pads
local crumbling = {} -- [platform] = true while it is falling / gone

for _, name in ipairs(Config.CRUMBLE_PLATFORMS) do
	local platform = courseFolder:FindFirstChild(name)
	if platform and platform:IsA("BasePart") then
		local homeCFrame = platform.CFrame
		platform.Touched:Connect(function(part)
			if crumbling[platform] then
				return
			end
			local character = part.Parent
			if not character then
				return
			end
			if not Players:GetPlayerFromCharacter(character) then
				return
			end
			crumbling[platform] = true
			task.delay(Config.CRUMBLE_DELAY, function()
				platform.CanCollide = false
				platform.Transparency = 0.7
				task.delay(Config.CRUMBLE_RESPAWN_TIME, function()
					platform.CFrame = homeCFrame
					platform.CanCollide = true
					platform.Transparency = 0
					crumbling[platform] = false
				end)
			end)
		end)
	end
end

-- ---------------------------------------------------------------- finish
local finishCooldown = {} -- [player] = last finish time

goalPad.Touched:Connect(function(part)
	local character = part.Parent
	if not character then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	local now = os.clock()
	if finishCooldown[player] and now - finishCooldown[player] < 2 then
		return
	end
	finishCooldown[player] = now
	if finishedSignal then
		finishedSignal:Fire(player)
	end
end)

print("Lava Leap course ready: " .. tostring(#coinsFolder:GetChildren()) .. " coins, " .. tostring(#movers) .. " movers, " .. tostring(#Config.CRUMBLE_PLATFORMS) .. " crumble pads.")
