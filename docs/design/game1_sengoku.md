# Game 1 — Sengoku (working title: Banner of Ashes)

## Pitch

A Fire-Emblem-style tactics-roguelite set in an alternate Sengoku
Japan where a cursed comet has fractured time. Warlords, ronin,
shinobi, sohei, and onmyoji clash across shifting battlefields.
Real historical figures appear as **legendary commanders**; the
supporting roster is original.

The campaign is a Slay-the-Spire-style branching node map with
permadeath for run-units (one optional revive token to soften
mobile audiences). Bonds between units persist across runs as
permanent unlocks — the emotional hook is FE, the structural hook
is StS.

## Tone

Grim historical drama with low fantasy. Yokai exist but are rare;
oni, kitsune, and tengu appear at higher acts. Visual reference:
woodblock prints (Hokusai, Yoshitoshi) — bold lines, restrained
palette, splashes of red and gold. **Not** anime-styled, **not**
Koei-Tecmo-styled.

## Setting hook: the Cursed Comet

A red comet split the sky over Sengoku Japan. Battlefields slip
between eras, dead warlords return, and the same battle can be
fought twice with different outcomes. This is the in-fiction
explanation for:

- **Roguelite runs** — each run is one "fold" of the comet's curse.
- **Permadeath that doesn't ruin meta** — units who die are still
  remembered between runs (bond memory persists).
- **Branching fates** — events let the player rewrite a battle's
  outcome at a cost.

## Core gameplay loop

1. Pick a starting commander from the unlocked roster.
2. Branch through a campaign map: battle, elite, event, shop,
   camp, shrine, boss.
3. Grid tactical battles. Permadeath. One revive token per run
   (Standard / Long); none in Iron Run.
4. Recruit / replace units between nodes; build supports/bonds
   that unlock combo arts.
5. Boss at the end of each act; final boss closes the run.
6. Convert run earnings on death/victory into permanent
   meta-currency that unlocks commanders, classes, relics,
   starting loadouts, cosmetics.

See `run_formats.md` for the full set of run lengths.

## Theme-specific systems

- **Honor / Dishonor meter**. Event choices nudge the meter. High
  honor unlocks loyalist allies and bushido relics; low honor
  unlocks mercenary and shinobi paths plus shadow-tier relics.
- **Clan banners (relics)**. Each clan banner gives a passive:
  Takeda → cavalry charge bonus, Uesugi → terrain immunity,
  Date → critical-hit window widened, etc. Banners are the most
  powerful relic tier and one is offered after each act boss.
- **Weather + terrain**. Rain disables matchlocks. Fog limits
  archer range. Rivers bisect maps mid-battle. Snow slows movement
  for non-mounted, non-snowshoe units.
- **Formation**. Pre-battle squad placement and stance
  (vanguard / skirmish / holdfast). Stance applies a
  battle-long passive — choosing it is a real strategic decision.

## Classes

8 in the vertical slice (Ashigaru, Samurai, Yari Cavalry, Yumi
Archer, Shinobi, Sohei, Onmyoji, Tactician). 56 total at full
launch. Full roster: see `classes.md`.

## Vertical slice scope (~6–10 weeks of focused work)

- 1 act, 8–12 nodes, 1 mid-boss + 1 act boss
- 4 playable starting commanders, 8 classes, 12 enemy archetypes
- 6 hand-crafted maps + 3 procedural map templates
- 15 abilities, 10 relics, 8 events
- Full meta-progression hub
- Tutorial (first 3 battles)
- Skirmish run format only — Standard unlocks once Skirmish is
  beatable end-to-end with placeholder art

## Out of scope for the slice (parking lot)

- Saga / Endless / Boss Rush / Iron run formats
- Mounted-archer micro (Yumi Cavalry adds enough complexity it
  wants its own balancing pass)
- Cosmetic IAP plumbing
- Voice barks (text only in slice)
- Online leaderboards

## IP guardrails (recap from CLAUDE.md)

- No Koei-Tecmo character names, designs, music motifs.
- Historical figures use only public-domain biographical facts;
  portraits and personality are original interpretations.
- Art must avoid look-alike risk with Samurai Warriors / Nioh /
  Ghost of Tsushima signature characters. When in doubt, redesign.
- Run candidate game titles through USPTO TESS and EUIPO before
  any marketing pass.
