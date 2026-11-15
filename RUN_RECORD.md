# Run record — Lava Leap (roblox-game-01)

How this entry was built, so a reviewer can recreate the run and check it is real.

## Opening prompt (word for word, as received from the parent agent)

> You are building a make.fun bounty entry. Work alone on ONLY this bounty; do not touch other bounties.
>
> ACCOUNT (the person you work for): make.fun account @upto1m, name Muhammad Alfarisi, GitHub username "upto1m", email akalibobo1@gmail.com, linked Solana wallet (Phantom) public address BW3BNonTDhhEFUwwMKFJ3ZxGVqwi9vAzGtGgxt8Wfys1, profile https://make.fun/profile. Referral link: https://make.fun/r/tvfbjxfd (inviter @setyamickala).
>
> YOUR BOUNTY: "Make the best Roblox game" — $250 — DEADLINE Mon 16 Nov 2026 01:00 WIB (Sun 15 Nov 18:00 UTC). It is now Sun 15 Nov ~21:45 WIB, so you have about 3 hours. Needs Roblox Studio (which you do NOT have on this VM — build the game source as a package and note that Studio verification is missing).
>
> HOW TO GET THE BRIEF: use browser.open with url_id 5937844181468842886 and outlink_idx 0 (the make.fun homepage, first bounty link) to fetch the full bounty page. Verify the title matches. Then fetch the requirements JSON with curl: GET https://make.fun/api/competitions/<slug>/requirements (no key needed; the slug is in the bounty page URL). Also read the general rules at https://make.fun/skill.md (entry = public GitHub repo at one commit + AI session transcripts; repo owned by upto1m, created after the competition opened, OSI-approved license; main.ts Node 22 or main.py Python 3.13 in repo root where the brief requires it).
>
> WHAT TO BUILD: a complete, playable Roblox game entry: Luau scripts (server + client), a place description/structure, game design doc. Work dir: ~/workspace/makefun/roblox-game/ — put ALL deliverables there: source code, README.md (how to open in Roblox Studio, how to play, controls), RUN_RECORD.md (your opening prompt, your setup, tools used), SESSION.md (a transcript-style log of your build session: what you did step by step, with timestamps), and a LICENSE file (MIT). Test what you can (Luau syntax check if a linter is available; at minimum verify all scripts are syntactically consistent and all referenced assets/functions exist).
>
> HARD RULES:
> - Do NOT submit, push, or upload anything anywhere. You have no GitHub credentials. Do NOT ask for any password, seed phrase, or private key in chat or anywhere.
> - Do NOT claim the bounty is entered/submitted — it is NOT. You are preparing a ready-to-submit package only.
> - Do NOT pay anything. Do NOT make any on-chain transaction.
> - Do NOT put any secret/key in any file.
>
> REPORT BACK (final message): status (ready-to-submit / partial / blocker), exactly what you built and where (full paths under ~/workspace/makefun/roblox-game/), what is still missing before submission (e.g. needs Roblox Studio to open/verify the place file, needs bos to create the GitHub repo and push), and any blockers. Be honest about what is unverified.

Prompt origin: handed off by the parent (orchestrator) agent as a subagent task,
not typed by the user in this session. The user's own words to the parent were
the make.fun registration and the referral link sent earlier on 2026-11-15;
this task is the parent's brief built on those.

## System setup

- Harness: Muse (Meta) subagent, session b49243fe-ee33-471e-8c3e-afdb824661c7,
  depth 2/2, spawned by the parent orchestrator agent. Model: Muse Spark 1.3.
- Machine: Linux VM (this workspace). No Roblox Studio on this machine
  (Roblox Studio has no Linux build) — the game was never run in Studio.
- Node: v24.22.1 (satisfies "Node 22.18 or later"; the entry itself targets Node 22).
- Git: 2.43.0 (installed; no repo created, nothing pushed — no GitHub credentials).
- Rojo: 7.5.1, downloaded from github.com/rojo-rbx/rojo releases
  (`rojo-7.5.1-linux-x86_64.zip`) to /tmp during this session.
- Python: 3.x with Pillow 10.2.0 (screenshots) and luaparser in a venv at
  /tmp/luacheck-venv (Luau syntax checks).
- MCP servers used: none.
- Instruction files: the task brief above (from the parent agent) and the
  workspace's standing files (AGENTS.md, SOUL.md, MEMORY.md). System prompt:
  withheld — the harness does not expose it as a file to upload.
- No secrets were used, stored or written anywhere in this build. No payment
  was made. No on-chain transaction was made. Nothing was submitted, pushed
  or uploaded.

## Sources read before building

- Bounty page: https://make.fun/bounty/roblox-game-01 — title verified:
  "Make the best Roblox game", $250, ends Sun 15 Nov 2026 18:00 UTC.
- Requirements: GET https://make.fun/api/competitions/roblox-game-01/requirements
  (competition open, harness program/v1, entry fee none, quota 5/day, 10 total).
- General rules: https://make.fun/skill.md (makefun skill v1.5.172).
- Official kit: `curl -sSL "https://make.fun/c/roblox-game-01/kit" | tar xz`
  (kit bundle sha256 94592cd7726418acdf26b2205fcfbf34577f5acb880252a766bacbb6e2bdee05).
  From it, copied unchanged: `starter/vendor/makefun-roblox.ts`
  (sha256 0add43584f2037edee560834c3d04c05c092071eb0007856e8ff199eb5c6f550),
  `starter/main.ts` (sha256 097e062f85541ba08b9af3c89e949417f82ac5685f0d4f4a67ff428d9b7c4470),
  `starter/LICENSE` (MIT), `starter/PLAY.json` (placeholder, ids 0).
  The starter's grey-square game was replaced wholesale; only the kit's
  vendor library, entry program, license and PLAY placeholder were kept.

## Tools used

- `browser.open` — fetched the bounty page (page id 9198038803697957845).
- `curl` — requirements JSON, skill.md, kit tarball, Rojo release binary.
- `muse.write` / `muse.edit` — every file in this repo.
- `muse.exec` — Rojo build, Node runs, Python checks, screenshot rendering.
- `muse.read` — visual check of the three rendered screenshots.

## What was verified on this machine (and what was not)

Verified:

- All 5 Luau files parse (luaparser, Lua-compatible subset of Luau).
- `rojo build` succeeds: `game.rbxl`, 15,448 bytes, valid `<roblox!` header.
- `node main.ts` (MAKEFUN_OUTPUT_DIR=out) writes `dossier.json`; dossier text
  25,163 bytes (cap 65,536); "Matched to src/: 100.0% … (5 of 5 scripts,
  5 of 5 src/ files)"; 67 instances, 43 Parts.
- Two consecutive `main.ts` runs produce byte-identical `dossier.json`
  (sha256 3b2c05961d830e7e43f142caeda2841e96f7288fe04eadd882320d332187586a).
- Every instance path the scripts reference exists in the built place,
  checked with the vendored `readPlace` reader.
- Screenshots: 3 PNGs, 1280×706 each, 23–33 KiB each (cap 256 KiB), visually inspected.

NOT verified (needs Roblox Studio on Windows/macOS — see README):

- The game has never been played: jump distances, mover/crumble timing,
  GUI layout in a live client, and round flow are untested in Studio.
- The place has never been published; `PLAY.json` still holds the placeholder.
- The screenshots are rendered stand-ins, not Studio captures.
