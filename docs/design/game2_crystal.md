# Game 2 — FE-foundation high fantasy (working title: Crystalfall Tactics)

## Pitch

A Fire-Emblem-foundation tactics-roguelite in an original
high-fantasy world. The world's last Crystal is shattering;
tactics squads chase shards across floating islands. FE mechanics
form the chassis (weapon triangle, mounted/flying/foot triangle,
supports/bonds, permadeath, lord-led campaigns). Final-Fantasy /
classic-JRPG flavor is layered on top **as mechanics and motifs
only** — job system, crystals, airships, summon archetypes,
dragoons — under fully original names, designs, and lore.

The same shared `core/` engine that runs Game 1 runs this; the
delta is content (data, art, audio, narrative) and theme-specific
systems.

## Tone

High fantasy, painterly, slightly bittersweet. Visual reference:
Yoshitaka Amano (atmospherically, not stylistically), Akihiko
Yoshida-school silhouette discipline, but rendered in our own
distinct palette and line work. Pointedly **not** anime
character-design language; pointedly **not** Square Enix
character designs.

## Setting hook: the Last Crystal

The Crystal that holds the sky aloft is breaking. Each fragment
falls to a floating island and rewrites the rules of magic on
that island for as long as it remains there. The lord-led
expedition that recovers the most shards before the Crystal
fully shatters decides what the new world looks like.

In-fiction this gives us:

- **Roguelite runs** — each run is one expedition; failing means
  another faction recovered the shards instead.
- **Per-act rule changes** — a shard's element flavors the act's
  combat and triangle rotation.
- **Permadeath** — falling on a floating island means falling.

## Core gameplay loop

1. Pick a Lord (the run's commander); their starting party and
   class options are seeded by which Lord you chose.
2. Branch through the campaign map (same Slay-the-Spire-style
   node graph as Game 1).
3. Grid tactical battles. FE-style permadeath. Optional revive
   token in Standard / Long; none in Iron Run.
4. Recruit / replace units between nodes. Build supports/bonds
   for combo arts and shared passives.
5. Spend Crystal shards at oracle nodes to alter the next act's
   rules.
6. Boss at the end of each act; final boss closes the run.
7. Convert run earnings into permanent meta-currency that
   unlocks Lords, jobs, classes, summon relics, cosmetics.

## Theme-specific systems

- **Job system.** Once unlocked, units can swap jobs between
  runs. Abilities learned in one job persist as **passives** in
  the next. This is the FF-flavored mechanic but the *job names
  themselves* stay generic (Dragoon, Geomancer, Time Mage are
  fine; Onion Knight, Mime, Calculator are out).
- **Summon-archetype relics.** Ultimate-tier relics with
  once-per-act board-wide effects (e.g., "Vael, the Tideborn"
  for a tidal wipe; "Saerith of the Ember Court" for a fire
  storm). All summons are wholly original entities — never the
  FF roster.
- **Crystal shards.** Collected during a run, spent at oracle
  nodes to alter the next act's rules: change the triangle
  rotation, raise/lower enemy density, flavor terrain.
- **FE-style supports.** Bond pairs accumulate ranks across
  runs. Enough rank unlocks combo arts (paired attacks, shared
  passives) — same emotional hook as Game 1, re-skinned for
  Crystalfall.
- **Airships (flavor only at launch).** Hub-to-hub travel between
  acts is framed as airship voyages: a narrative seam with
  optional event vignettes. **Not** a gameplay unit type at
  launch (scope discipline).

## Lord system

A Lord is the commander you start each run with. Lords have:

- A signature class on a unique promotion path.
- A starting kit (one tied unit, one tied relic, one tied event
  hook).
- A bond mesh — Lords have pre-existing bonds with a small set
  of recruitable units, so each Lord *plays differently* even
  before the player customizes anything.

Slice ships with **2 Lords**. Full launch targets **6**.

## Classes

8 in the vertical slice (Lord, Knight, Cavalier, Pegasus Knight,
Archer, Mage, Cleric, Thief). 60 total at full launch. Full
roster: see `classes.md`.

## Vertical slice scope (~4–6 weeks once core engine is hardened)

- 1 act, 8–12 nodes, 1 mid-boss + 1 act boss
- 2 Lords, 8 classes, 12 enemy archetypes
- 6 hand-crafted maps + 3 procedural map templates
- 15 abilities, 10 relics (3 of which are summon archetypes), 8 events
- Job-system stub: 2 secondary jobs unlockable, 1 passive carry-over slot
- Full meta-progression hub
- Tutorial (first 3 battles)
- Skirmish run format only — Standard unlocks once Skirmish is
  beatable end-to-end

## Out of scope for the slice (parking lot)

- Saga / Endless / Boss Rush / Iron run formats
- Airships as gameplay units (flavor only)
- More than 2 Lords
- Voice barks (text only)
- Online leaderboards
- Crystal-shard rule modifiers beyond 4 baseline rules

## IP guardrails (recap from CLAUDE.md)

- FE-foundation **mechanics**, never FE-named entities. No
  Marth/Roy/Ike/Byleth analog with the same silhouette.
- FF-flavored **mechanics and motifs**, never FF-named entities.
  No "Bahamut", no "Materia", no "Crystal of Fire/Water/Wind/Earth"
  arrangement. Our cosmology is original.
- Summon names invented from scratch and run through trademark
  before any marketing.
- Job names: tactics-RPG genre-generic terms only. The list of
  acceptable terms includes Dragoon, Geomancer, Time Mage, Red
  Mage, Sage, Sniper, Paladin, Sorcerer, Druid, Berserker. Not
  acceptable: Onion Knight, Mime, Calculator, Blue Mage (too
  Final-Fantasy-distinctive when paired with our other motifs),
  Bard-of-tides, etc. — see `CLAUDE.md` for the binding rule.
