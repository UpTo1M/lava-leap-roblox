-- Lava Leap: shared tuning constants.
-- Required by the server (GameManager, Course) and the client (Game).
-- Change a number here and the whole game retunes; no other file holds magic numbers.

local Config = {}

-- Round flow (seconds)
Config.ROUND_TIME = 90 -- time to reach the finish once a round starts
Config.INTERMISSION_TIME = 10 -- lobby countdown between rounds
Config.END_TIME = 8 -- results screen before the next round

-- Coins
Config.COIN_RESPAWN_TIME = 15 -- seconds before a collected coin comes back
Config.WIN_COIN_BONUS = 5 -- bonus coins paid when a player finishes

-- Hazards
Config.LAVA_DAMAGE = 100 -- touching lava is fatal
Config.CRUMBLE_DELAY = 0.6 -- seconds after first touch before a crumble platform falls
Config.CRUMBLE_RESPAWN_TIME = 4 -- seconds before a crumbled platform returns

-- Moving platforms: keyed by platform name in Workspace.Course.
-- axis: "X" or "Z"; distance: studs each way from home; speed: cycles per second.
Config.MOVERS = {
	P3 = { axis = "X", distance = 8, speed = 0.25 },
	P6 = { axis = "Z", distance = 6, speed = 0.35 },
	P9 = { axis = "X", distance = 10, speed = 0.45 },
}

-- Platforms that crumble and fall away shortly after a player steps on them.
Config.CRUMBLE_PLATFORMS = { "P4", "P7", "P10" }

-- Where the lava sea sits (Workspace.Lava). Anything below this Y is lava.
Config.LAVA_TOP_Y = -13

-- Client polish
Config.BANNER_TIME = 3 -- seconds a center announcement stays up
Config.COUNTDOWN_BEEP_AT = 5 -- last seconds of a round shown in red

return Config
