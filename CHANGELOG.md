# Changelog

This file tracks per-slice and per-game milestones. Granular
commit history lives on PRs; this is the high-level
"what shipped when" log.

## Unreleased — Slice 1: Banner of Ashes (Game 1, Sengoku)

The Game 1 vertical-slice content + engine work, on
`claude/fire-emblem-roguelike-games-FadWA` and tracked by PR #2.

### Engine
- Godot 4 project bootstrap (`project.godot`, `.gitignore`,
  mobile + desktop export presets).
- Combat layer: `CombatGrid` with terrain (PLAIN / FOREST /
  HILL / ROAD / WATER / WALL), `CombatUnit` with relic-buff
  hooks and per-battle ability use tracking, `TurnManager`
  with FE-style move-then-attack and three pluggable AI
  policies (Aggressive / Defensive / Ranged).
- `DamageFormula`: weapon triangle (SWORD > AXE > LANCE)
  with ±2 modifier, weapon-range table, and ability damage
  resolver respecting kind (PHYSICAL / MAGICAL).
- Run layer: `RunConfig` Resource (parameterizes every run
  format), branching `MapGenerator` with non-crossing edges
  + scripted-layout shortcut, `RunState` walker.
- Meta layer: `SaveSystem` (JSON, cross-platform), `MetaState`
  (run completions, currency, unlocks), `MetaUnlocks` (run-
  format unlock graph).
- Platform stubs: `PlatformIAP`, `PlatformAds` (no-op
  contracts pinned for the launch sprint).

### Content (Sengoku slice targets)
- 8 player classes (`.tres`): Ashigaru, Samurai, Yari Cavalry,
  Yumi Archer, Shinobi, Sohei, Onmyoji, Tactician.
- 12 enemy archetypes (`.tres`): bandits, ronin, cavalry,
  archers, casters, shinobi, fanatics, an act-2 boss daimyo
  with escorts.
- 8 encounters across BATTLE / ELITE / BOSS slots.
- 15 abilities, all four kinds covered (PHYSICAL, MAGICAL,
  HEAL, BUFF). Each class has a signature ability.
- 10 relics across all 4 rarities, all 4 effect kinds.
- 8 events with original-character flavor (wandering monks,
  battlefield priestesses, captured scouts, omen-bird
  encounters, pilgrim offerings, etc.).
- 6 hand-crafted maps + 3 procedural battlefield templates.
- 5 run formats: tutorial, skirmish, standard, long, iron.

### UI
- 9 screens: Hub, Map (with branch picker), Battle (HP bars
  + side-color coding), Result (color-coded outcome), Event,
  Shop, Camp, Shrine, plus Main glue.
- Touch-friendly tap targets (≥48px), mobile-readable
  defaults, color-coded statuses across screens.

### Tests
- 19 headless smoke tests in CI: combat, ranged AI, run loop,
  meta save/unlocks, hub, map screen, battle screen, platform
  stubs, branching map, event screen, relic buffs, abilities,
  shop, shrine, terrain, hand-crafted maps, tutorial scripted
  layout, and the end-to-end Main glue scene.

### Documentation
- `CLAUDE.md` — locked rules for all four games.
- `docs/design/` — design intent for each game, run formats,
  classes, monetization, marketability, style guide, save
  format reference.

### Out-of-scope for this slice (future work)
- Real art (portraits, sprites, tilesets, UI theme).
- Real audio (SFX library, music, voice barks).
- Tooltip-overlay tutorial copy (waiting for playtest signal).
- Game 2 (Crystalfall Tactics) theme pack — starts after
  Game 1 ships.
- Games 3 (Pocketkin Tactics) and 4 (Datapact Tactics) —
  start in parallel after Game 2 ships.
