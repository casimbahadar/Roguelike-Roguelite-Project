## Game 3 — FE-foundation creature collection (working title: Beastfold Tactics)

## Pitch

A Fire-Emblem-style tactics-roguelite where each "unit" you bring
into battle is one of a wide cast of original beasts you've
recruited along the way. FE mechanics are the chassis: grid
combat, an element triangle overlaying the weapon triangle, FE
supports/bonds, permadeath, lord-led campaigns. The
creature-collection layer is the seasoning: beasts encounter the
party at events, are recruitable on certain conditions, and grow
via multi-stage promotions tuned individually.

The genre touchstones are widespread (Persona, Shin Megami
Tensei, Etrian Odyssey, Monster Hunter Stories, Yokai Watch).
Pokemon is the most famous example but emphatically not our IP
source — see the IP guardrails section below.

## Tone

Sun-drenched expedition fantasy, painterly. A young
beast-warden corps surveys uncharted regions where civilization
fades into wilds. Visual reference: Studio Ghibli landscape
tradition (atmospherically, not stylistically), Yoshitaka Amano
for the painterly framing of the journal interludes. Pointedly
NOT anime-styled, NOT Pokemon-styled — bold lines, restrained
palette, original creature designs grounded in real-world
zoology + folklore (corvids, megafauna, deep-sea life,
northern-myth ungulates) rather than franchise tropes.

## Setting hook: the Beastfold

The Beastfold is the term in this world for the migratory bands
of wild beasts that emerge across the continent at the change of
each season. Wardens — the player's corps — track, tame, and
sometimes fight Beastfold members. A run is one season's
expedition; a recruited beast travels with the party, fights,
and (if it survives) ranks up at camp nodes between battles.

In-fiction this gives us:

- **Roguelite runs** — each run is one seasonal expedition; a
  failed expedition means the rival corps recruited the beasts
  you missed.
- **Permadeath** — a fallen beast doesn't return; its bond with
  its trainer becomes a relic instead.
- **Bond-as-relic** — extends the FE supports system: when a
  beast dies, the trainer keeps a memorial relic that grants a
  passive in future runs.

## Core gameplay loop

1. Pick a Lord-Warden from the unlocked roster. Their starting
   trio is fixed; subsequent runs can swap.
2. Branch through the campaign map (same Slay-the-Spire-style
   node graph as Games 1 and 2).
3. Grid tactical battles. FE-style permadeath; one revive token
   per run on Standard / Long.
4. Recruit beasts at certain Event nodes (Tame action,
   pacification check, gift events) and at boss kills.
5. Camp nodes are where beasts level and promote; supports
   between trainer + beast accumulate ranks here.
6. Boss at end of each act; final boss closes the run.
7. Convert run earnings into permanent meta-currency — unlock
   new Lord-Wardens, new beast archetypes, recruit-rate
   improvements, cosmetics.

See `run_formats.md` for run lengths.

## Creature-collection systems

- **Element triangle.** Six elements: Fire, Water, Wind, Earth,
  Light, Dark. FE-style rotation: Fire > Wind > Earth > Water >
  Fire (the four-cycle); Light <-> Dark mirror each other and sit
  outside the cycle. Element triangle and weapon triangle stack:
  a Fire-element Sword beats a Wind-element Axe by both
  triangles. Designers pick whether a class is locked to one
  element (most beast classes), splits two (some hybrids), or is
  elementally neutral (most human warden classes).
- **Recruit checks.** Beasts encountered at events have a
  recruit threshold (level + bond + relic). Failing the check
  triggers a battle instead. Some beasts can only be recruited
  by specific Lord-Wardens.
- **Multi-stage promotions.** Each beast has an individual
  growth path of 3-4 stages. Promotion stones / story flags
  gate transitions. Stages are NOT named with Pokemon's tier
  names (no "Stage 1 Evolution"); ours use natural-language
  tags: *fledgling*, *prime*, *paragon*, *legend*.
- **Trainer bonds.** Each beast has a trainer (a Warden class
  unit). The trainer-beast pair builds support ranks across
  runs (FE supports). High bond unlocks paired arts (the
  trainer commands; the beast executes a special move).

## Lord system

Slice ships with 2 Lord-Wardens; full launch targets 6.

A Lord-Warden has:

- A signature class (a human warden archetype, e.g. Beastrider,
  Hawkmaster, Druid).
- A starting trio of beasts tied to that class (small, medium,
  flying — covering the basic three movement types).
- A bond mesh covering 8-12 specific beast archetypes with
  faster recruit and stronger arts when paired.
- A unique passive describing how their corps approaches the
  Beastfold (Beastrider's *Trail-Marked* gives faster movement
  on rough terrain; Hawkmaster's *Skybond* lets one flying
  beast warp once per battle; etc.).

## Classes

Two distinct grids: human Wardens (the trainers) and beasts
(the partners). Each follows the FE Class+Weapon model from
core/, plus the element layer.

**Human Wardens — slice 6 of ~24 at full launch.**

Slice picks: Beastrider, Hawkmaster, Druid, Hunter, Warden
Cleric, Strategist.

**Beasts — slice 12 of ~80 at full launch.**

Slice picks split across element and movement type:

- Fire / earthbound / small: Emberkit, Cinderfox.
- Water / earthbound / medium: Tidehound, Glasscarp (flying-fish
  hybrid).
- Wind / flying / small: Galefinch.
- Wind / flying / medium: Stormcrow.
- Earth / earthbound / heavy: Ironox, Quillback.
- Light / earthbound / medium: Auroch (radiant deer).
- Dark / earthbound / small: Nightveil (smoke-fox).
- Dark / flying / medium: Moonmoth.

Stat shapes follow the same ClassDef Resource as Games 1 and 2;
adding the element field is a one-line ClassDef extension.

## Vertical slice scope (~5-8 weeks once Games 1/2 cores ship)

- 1 act, 8-12 nodes, 1 mid-boss + 1 act boss.
- 2 Lord-Wardens, 6 human Warden classes, 12 beast classes
  (across all six elements, three movement types).
- 6 hand-crafted maps + 3 procedural map templates.
- 15 abilities, 10 relics (3 of which are bond-memorial
  relics), 8 events including 3 recruit events.
- Promotion-stone economy: 2 promotion paths active for the
  slice, others stubbed.
- Tutorial (first 3 battles).
- Skirmish run format only — Standard unlocks once Skirmish is
  beatable end-to-end.

## Out of scope for the slice (parking lot)

- Saga / Endless / Boss Rush / Iron run formats.
- Beast-vs-beast PvP / asynchronous battles (post-launch
  consideration).
- Full element-vs-element coverage of every type pairing
  (slice covers a representative subset; balancing all 36
  pairings is a launch-content milestone).
- Online leaderboards, daily seeded runs.
- Cosmetic IAP (skinned beasts) — designed but not wired.

## IP guardrails (recap from CLAUDE.md)

- No Pokemon franchise names, designs, music motifs, or
  silhouettes. No Pokeball-shaped capture device — ours is a
  bond-sigil rune.
- No franchise-coded creatures: no yellow-electric-rodent, no
  Charizard-coded fire-dragon-with-wings as the marketing
  marquee, no Eevee-coded fox-with-evolution-tree.
- No franchise terminology: not "Pokemon", not "Pokedex", not
  "Trainer Battle", not "Mega Evolution".
- Working title runs through USPTO TESS and EUIPO before any
  marketing pass — and does so with extra scrutiny since
  Pokemon owns *aggressively* in this category.
- Inspired-by language is fine in pitch decks ("for fans of
  creature-collection RPGs"); naming Pokemon by name in the
  storefront copy is not.

## Marketability angle

Creature collection + true tactics is a thin field. Pokemon
itself rarely steps into grid tactics; SMT does, but at a
darker, mature register. Beastfold targets the gap: warm
expedition tone, FE depth, original creature roster.
