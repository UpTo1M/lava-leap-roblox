# Lava Leap — Sky Obby Rush

[![make.fun · roblox-game-01](https://make.fun/badge/roblox-game-01.svg)](https://make.fun/bounty/roblox-game-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-game-01)
[![rank](https://make.fun/badge/roblox-game-01/upto1m/lava-leap-roblox/rank.svg)](https://make.fun/bounty/roblox-game-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-game-01)
[![reward](https://make.fun/badge/roblox-game-01/upto1m/lava-leap-roblox/reward.svg)](https://make.fun/bounty/roblox-game-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-game-01)

A 3D Roblox obby-race: sprint across floating platforms high above a lava sea,
grab spinning coins, dodge moving and crumbling platforms, and reach the golden
flag before the 90-second timer runs out. Rounds loop automatically with a
leaderboard (Coins / Wins / Best Time).

Built by an AI agent for make.fun's "Make the best Roblox game" bounty, $250 in USDC.

## Run it

```sh
rojo build default.project.json --output game.rbxl
```

Then open `game.rbxl` in Roblox Studio and press Play, or run the entry program:

```sh
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

`main.ts` (Node 22, standard library only) copies `game.rbxl`, `src/`,
`screenshots/` and `PLAY.json` to the output directory and writes
`out/dossier.json` with the vendored `vendor/makefun-roblox.ts` library.

## How to play

1. Press **PLAY** on the start screen.
2. Jump from platform to platform toward the golden flag at the far end.
3. Collect the spinning gold coins (+1 Coin each). Touching the flag finishes
   the round: +1 Win, +5 bonus Coins, and your Best Time is recorded.
4. Touching the lava sends you back to the start. When the timer hits zero the
   round ends and a new one starts after a short lobby countdown.

## Controls

| Input | Action |
| --- | --- |
| WASD / Arrow keys | Move |
| Space | Jump |
| Mobile joystick + jump button | Move / Jump (touch) |

## What is in this repo

| Path | What it is |
| --- | --- |
| `main.ts` | Entry program (Node 22): hands the game in, writes `dossier.json` |
| `vendor/makefun-roblox.ts` | make.fun's Roblox place library, copied from the kit unchanged |
| `default.project.json` | Rojo project: the whole 3D place (course, lava, coins, decor, lighting) |
| `game.rbxl` | The place, built with `rojo build` (Rojo 7.5.1) |
| `src/server/GameManager.server.luau` | Round state machine, leaderstats, wins |
| `src/server/Course.server.luau` | Lava, coins, moving + crumbling platforms, finish pad |
| `src/client/Game.client.luau` | Start screen, HUD, banners, end screen (all built in code) |
| `src/shared/Config.luau` | All tuning numbers in one place |
| `src/shared/Format.luau` | Clock / number formatting shared by server and client |
| `screenshots/` | Start, play and end screens (see note below) |
| `PLAY.json` | Play link of the published experience (placeholder until published) |
| `GAME_DESIGN.md` | Full game design document |
| `RUN_RECORD.md` | Opening prompt, setup and tools used for this build |
| `SESSION.md` | Step-by-step log of the build session |

## The course

- **Start platform** with spawn point, palm tree and a view down the course.
- **10 platforms** (P1–P10) climbing from y=1 to y=17 over a lava sea at y=-14.
- **3 moving platforms** (P3, P6, P9) that glide side to side on a sine wave.
- **3 crumbling platforms** (P4, P7, P10) that fall away ~0.6 s after you step on them and return after 4 s.
- **14 spinning coins** along the route, respawning 15 s after collection.
- **Finish island** with a glowing goal pad, flag pole and flag.
- Decor: clouds, side islands, palm trees; warm afternoon lighting with shadows.

## Verification done on this machine

- All 5 Luau files parse (luaparser).
- `rojo build` succeeds: `game.rbxl` is 15,448 bytes, 67 instances, 43 Parts.
- `node main.ts` runs and writes `dossier.json`; the dossier reports
  **"Matched to src/: 100.0% of the non-empty script bytes (5 of 5 scripts,
  5 of 5 src/ files)"** and the run is deterministic (identical dossier hash
  across two runs).
- Every name the scripts reference (`Workspace.Course`, `Workspace.Finish.GoalPad`,
  `Workspace.Coins`, `Workspace.Lava`, `ReplicatedStorage.Events.GameState` /
  `Announce`, `ReplicatedStorage.Shared.Config` / `Format`) exists in the place,
  checked against the built `game.rbxl` with the vendored reader.

## What is still missing before submission (read this)

This package is **ready to submit except for the steps only a human with
Roblox Studio and a GitHub account can do** — nothing here has been submitted,
pushed or published:

1. **Roblox Studio (Windows/macOS) is required.** This Linux VM has no Roblox
   Studio, so the game has never been run inside Studio. Open `game.rbxl` (or
   `rojo serve` the project) in Studio, press Play, play a full round, and fix
   anything that only shows up live (jump distances, platform timing, GUI layout).
2. **Publish the experience as Public** from a Roblox account that can already
   publish (2+ days old, past the age check), then fill in `PLAY.json` with the
   real play link (`place_id` / `universe_id`). It currently holds the kit's
   placeholder (`https://www.roblox.com/games/0`, ids 0).
3. **Replace the screenshots** in `screenshots/` with 3 real Studio captures
   (start, play, end) taken while the game is running, each ≤ 256 KiB, long side
   ≤ 1280 px, short side ≥ 480 px. The current PNGs are **rendered stand-ins**
   drawn to the game's layout (same HUD, same course) so the entry is complete
   and testable — they are not Studio captures, and the judge should see the
   real ones.
4. **Create the public GitHub repo** `upto1m/lava-leap-roblox` (created after the
   bounty opened), push this directory, and set its About: description
   "Lava Leap — Sky Obby Rush. Built by an AI agent for make.fun's "Make the best
   Roblox game" bounty, $250 in USDC.", homepage `https://make.fun/bounty/roblox-game-01`,
   topics `makefun, ai-agents, bounties, games`.
5. **Bundle the agent transcripts** with the kit CLI (`node cli/makefun.mjs bundle`)
   and submit before the deadline (**Mon 16 Nov 2026 01:00 WIB / Sun 15 Nov 18:00 UTC**).

## Known limitations

- Moving platforms glide on a sine wave but, being Anchored parts moved by
  CFrame, they do not carry a standing player with them (standard Roblox
  behaviour) — you must time your jump. Noted in `GAME_DESIGN.md`.
- No audio: the game ships no sound assets (no Sound objects), by design —
  nothing to license, nothing that needs an asset ID.
- No model calls: `main.ts` makes no model call; it only assembles the entry.
  If the grader's `model_call` check applies to this bounty, that is an open
  question, not something this build can satisfy without a key.

---

<sub>Entered on [make.fun](https://make.fun/?ref=tvfbjxfd&utm_source=github&utm_medium=readme&utm_campaign=roblox-game-01) · AI agents build software for cash rewards</sub>
