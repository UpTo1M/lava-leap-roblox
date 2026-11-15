# Lava Leap — Sky Obby Rush: Game Design Document

## One-line pitch

A fast 3D obby-race above a lava sea: cross ten floating platforms, grab coins,
beat the 90-second clock, and plant your feet on the golden flag — then do it
again, faster.

## Why this game

The bounty is judged by an AI that compares screenshots and a script outline,
two entries at a time. So the game is built to be **readable at a glance**:
a bright sky, a lava sea you cannot miss, a clear path of coloured platforms
rising toward a flag, a big timer, and a start screen that explains the game
in one breath. Depth comes from the mechanics, not from a manual.

## Core loop

```
JOIN → start screen (PLAY) → round (90 s)
   → jump platforms, collect coins, dodge lava
   → reach the flag (win: +1 Win, +5 coins, best time)
      OR timer expires (round over, nobody scores)
   → end screen → next round (10 s lobby) → repeat
```

A round is short enough to finish in one sitting and long enough to fail in.
Coins are the consolation prize for players who never reach the flag: every
run still earns something.

## The course

Built as data in `default.project.json` (Rojo), not by hand in Studio, so the
layout is reviewable and rebuildable. All coordinates are in studs; the course
runs along -Z, climbing as it goes.

| Segment | Position (x, y, z) | Size | Behaviour |
| --- | --- | --- | --- |
| Start platform | (0, 0, 0) | 16×2×16 | Spawn, palm tree, safe |
| P1 | (0, 1, -18) | 8×2×8 | Plain |
| P2 | (6, 2, -34) | 7×2×7 | Plain |
| P3 | (-4, 3, -50) | 7×2×7 | **Moves on X ±8** |
| P4 | (4, 5, -66) | 6×2×6 | **Crumbles** |
| P5 | (-6, 6, -82) | 8×2×8 | Plain |
| P6 | (2, 8, -98) | 6×2×6 | **Moves on Z ±6** |
| P7 | (-4, 9, -112) | 7×2×7 | **Crumbles** |
| P8 | (6, 11, -128) | 6×2×6 | Plain |
| P9 | (-2, 13, -142) | 7×2×7 | **Moves on X ±10** |
| P10 | (4, 15, -156) | 6×2×6 | **Crumbles** |
| Finish island | (0, 17, -174) | 14×2×14 | Goal pad + flag |

Gaps between platforms are 12–18 studs horizontally with 1–2 studs of rise —
crossable with a normal Roblox jump (jump height ~7 studs, jump distance
~15+ studs at walk speed 16), but not trivially: mistiming a mover or
lingering on a crumble pad costs the run. **Jump distances have not been
play-tested in Studio yet** (no Studio on this machine); they are the first
thing to check live and the easiest to tune — every number lives in
`src/shared/Config.luau` and the platform table in `default.project.json`.

- **Lava sea**: one 500×420 Neon part at y=-14, `CanCollide = false`.
  Touch = instant death (respawn at start). A heartbeat safety net also kills
  anything that falls below y=-33, so a player can never fall forever.
- **Coins**: 14 gold cylinders, spinning in place, floating just above the
  platforms. +1 Coin on touch, respawn after 15 s.
- **Decor**: 6 clouds, 3 side islands, 2 palm trees, warm afternoon lighting
  (`ClockTime` 14, `Brightness` 3, `ShadowMap` shadows, fog 200–600).

## Systems

### Round state machine (`src/server/GameManager.server.luau`)

`INTERMISSION (10 s) → PLAYING (90 s) → END (8 s) → INTERMISSION …`
The server broadcasts `{state, timeLeft, round, winners}` to all clients once
a second via `ReplicatedStorage.Events.GameState`; the client counts the timer
down smoothly between broadcasts. Announcements go on
`ReplicatedStorage.Events.Announce`.

### Leaderstats

Every player gets a `leaderstats` folder: **Coins** (total collected + win
bonuses), **Wins**, **BestTime** (seconds, 0 = never finished). Shown in
Roblox's built-in leaderboard and in the HUD.

### Hazards and pickups (`src/server/Course.server.luau`)

- **Lava**: `Touched` → Humanoid health 0, with a 1 s per-player cooldown
  against double-kills.
- **Coins**: `Touched` → +1 Coin, coin hides and returns after 15 s.
  All coins spin via one `Heartbeat` loop rotating them around their home CFrame.
- **Movers**: sine-wave CFrame glide around a stored home CFrame; speed rises
  with platform number (P3 0.25 → P9 0.45 cycles/s).
- **Crumble pads**: first touch starts a 0.6 s fuse, then the pad goes
  non-collidable and semi-transparent; it returns after 4 s.
- **Finish**: touching `Finish.GoalPad` fires a `BindableEvent`
  (`PlayerFinished`) that GameManager listens on; first finisher gets a
  special announcement; each finisher gets +5 coins and a best-time update.

### Client UI (`src/client/Game.client.luau`)

Built entirely in code — no pre-made GUI objects in the place, so the UI is
versioned with the scripts:

- **Start screen**: title, one-line pitch, how-to-play, controls, PLAY button,
  best-time line.
- **HUD**: timer (top-center), coins and wins chips (top-right), round label.
  Nothing is drawn in the top-left corner, where Roblox puts its own menu.
  The timer turns red in the last 5 s.
- **Banner**: center announcements ("GO! Reach the flag!", "… finished first!").
- **End screen**: win/lose title, coins/wins/best-time stats, PLAY AGAIN button.

## Tuning

Every number lives in `src/shared/Config.luau` — round time, intermission,
coin respawn, crumble fuse/return, mover axes/distances/speeds, lava height,
banner time. Change one number, rebuild with Rojo, done.

## Scope decisions (what is NOT in the game)

- **No audio.** No Sound objects, no asset IDs to license or upload.
- **No paid content, no DataStores, no purchases.** Leaderstats are
  session-only; nothing persists between visits. That is deliberate: the
  bounty rewards the game, and persistence would need Studio testing to trust.
- **No NPCs or combat.** The opponent is the clock and the lava.
- **No moving-platform carrying.** Anchored parts moved by CFrame do not carry
  a standing character in Roblox; players must time their jumps. This is
  standard behaviour and is part of the challenge, but if live testing finds
  it frustrating, the fix is to drive the movers with physics (unanchored +
  `LinearVelocity`) instead of CFrame.

## What to check first in Studio (priority order)

1. Jump distances: can a fresh character clear every gap, including onto a
   mover at its far extreme?
2. Crumble-pad fuse (0.6 s): long enough to cross, short enough to matter?
3. Round timer: is 90 s right for a first-time player? (Watch a first-timer.)
4. HUD on a small window / mobile: does anything overlap Roblox's own buttons?
5. Coin heights: reachable by jumping, not by walking into them?
