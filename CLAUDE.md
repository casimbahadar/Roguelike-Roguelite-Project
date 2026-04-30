# Personal coding standards

These rules apply to this project. Project-specific context can be
added below as the design firms up.

## Working style

- **Keep code simple but effective.** Use as few lines and files as
  the task actually needs. No premature abstraction, no scaffolding
  for hypothetical future requirements.
- **Take small steps and commit frequently.** Many small commits
  beat one large one — they keep the working tree recoverable and
  guard against timeouts or API errors mid-task. Push often.
- **Analyze for bugs while coding, not after.** Read each change as
  you write it: edge cases, off-by-ones, error paths, type
  mismatches. Don't defer correctness to a later review pass.

## Project rules (locked)

These are decisions for this repo that bind every session. Update
this list as new decisions land — never silently override.

- **Engine**: Godot 4 only.
- **Branch policy**: development lands on
  `claude/fire-emblem-roguelike-games-FadWA` or its descendants. Never
  push directly to `main`. Use draft PRs.
- **Two games, one engine**: a shared `core/` plus theme packs under
  `games/sengoku/` (Game 1) and `games/crystal/` (Game 2). Nothing in
  `core/` may import from `games/*` — the dependency arrow is one-way.
- **Game 1 — Sengoku**: original characters plus public-domain
  historical warlords. No Koei Tecmo IP, art look-alikes, or music
  motifs.
- **Game 2 — FE-foundation high fantasy**: Fire-Emblem mechanics are
  the chassis (weapon triangle, mounted/flying/foot triangle,
  supports/bonds, permadeath, lord-led campaigns). Final-Fantasy /
  classic-JRPG flavor is layered on top *only as mechanics and
  motifs* (job system, crystals, airships, summon archetypes,
  dragoons) — never as named entities. All summons, deities, cities,
  and characters are original. No Square Enix IP.
- **Generic vs trademarked names**: tactics-RPG terms used widely
  across the genre (Dragoon, Geomancer, Time Mage, Red Mage,
  Paladin, Sage, Sniper) are fine. Distinctive FF names (Onion
  Knight, Mime, Calculator, etc.) are out.
- **Run formats**: Skirmish / Standard / Long / Saga / Endless /
  Boss Rush / Daily / Iron are all built by parameterizing one
  `RunConfig` Resource. No parallel run-loop codepaths.
- **Data over code**: gameplay numbers live in `.tres` Resources.
  Code reads them; it never bakes constants.
- **Save format**: JSON-serializable strings only, for cross-platform
  cloud sync. No engine-specific binary blobs in saves.
- **Mobile parity**: every UI screen is testable with touch input
  from day one. No "we'll add mobile later" fallbacks.
- **Monetization**: Steam = premium one-time purchase. Mobile =
  premium with **only cosmetic** IAP and **only optional rewarded**
  ads. No pay-to-win, no interstitials, no energy timers, ever.
- **Trademark**: run any candidate game title through USPTO TESS and
  EUIPO before any marketing. Working titles ("Banner of Ashes",
  "Crystalfall Tactics") are placeholders.
