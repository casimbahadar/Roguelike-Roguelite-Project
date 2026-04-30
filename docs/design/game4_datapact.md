# Game 4 — FE-foundation partner-bond (working title: Datapact Tactics)

The placeholder title uses *Data* to nod at the Digimon
*digital monster* genre and *pact* to telegraph the FE-flavored
lord-vessel bond at the heart of the campaign. Both halves are
genre-generic words; the combination needs heightened USPTO
TESS / EUIPO clearance before any marketing — and the
in-fiction terminology stays away from "digital", "code", and
"cyber" so the gameplay tone reads as high fantasy rather than
sci-fi (the inspiration is genre-shape, not aesthetic).

## Pitch

A Fire-Emblem-style tactics-roguelite where every lord is paired
with a single evolving partner — a *vessel* — that grows through
multi-stage promotions alongside them. FE mechanics are the
chassis (grid combat, weapon triangle, supports, permadeath,
lord-led campaigns). The partner-bond layer is the seasoning:
each lord's vessel is the campaign's emotional centerpiece,
gaining new forms and abilities at story flags rather than at
arbitrary level thresholds.

The partner-creature genre touchstones include Persona, Yokai
Watch, Shin Megami Tensei, and the FE-Awakening pair-up system
itself. Digimon is the most famous example with a focus on
multi-stage transformation but emphatically not our IP source —
see the IP guardrails section below.

## Tone

Heroic-bittersweet high fantasy, painterly. The *vessel* is
described in-fiction as a soul bound to a host body that grows
alongside its lord; the bond is intimate, precarious, and
campaign-defining. Visual reference: Yoshida-school silhouette
discipline, Ralph McQuarrie atmospheric concept work for the
larger forms — pointedly NOT Digimon-styled (no
mecha-organic-monster body language, no
horns-and-belt-buckles design tropes), pointedly NOT
shounen-anime-styled.

## Setting hook: the Pact

The Pact is an ancient covenant by which a high-born or chosen
mortal binds a wandering soul into a paired form. The vessel
grows in stages as the bond deepens — from a fragile *fledgling*
to a *bonded* primary form, then *sworn* and *ascendant*
(neutral, made-up names — none are franchise-loaned). Each
stage unlocks new abilities, larger silhouettes, and access to
new classes the lord can field.

In-fiction this gives us:

- **Roguelite runs** — each run is one chapter of the lord's
  Pact campaign; failure means the bond regresses one stage and
  the campaign restarts with that scarring.
- **Multi-stage promotion** — the FE promotion system extended
  to four stages instead of two; each stage takes longer to
  earn and unlocks larger battlefield effects.
- **Permadeath** — a vessel cannot die mid-run (the lord
  protects it), but the lord *can* die, which collapses the
  Pact and ends the run permanently.

## Core gameplay loop

1. Pick a Lord-Pact pair from the unlocked roster. Each pair is
   a curated combination — designer-chosen — with a unique arc.
2. Branch through the campaign map (same Slay-the-Spire-style
   node graph as Games 1, 2, and 3).
3. Grid tactical battles. Vessel fights alongside the lord;
   FE-style permadeath for non-pact units.
4. Recruit secondary party members from events; they have
   normal supports with the lord but cannot Pact.
5. Story flag nodes (a new node kind — the same `MapNode.Kind`
   enum, just adding `STORY` later) trigger Vessel promotion.
   Each promotion is hand-authored and gates abilities.
6. Boss at end of each act; final boss closes the run. Final
   boss of the run unlocks the *ascendant* form for the next
   run on Long campaign.
7. Convert run earnings into permanent meta-currency — unlock
   new Lord-Pact pairs, new vessel classes, narrative branches,
   cosmetics.

See `run_formats.md` for run lengths.

## Vessel system

- **Vessel = a paired companion class.** Mechanically a unit
  that occupies a tile and acts on the lord's side, but with
  three distinguishing traits:
  1. **Mortality is a per-run player choice** (see *Vessel
     mortality* section below).
  2. **Multi-stage promotions** triggered by story flags, not
     XP thresholds. Each stage replaces the vessel's class
     wholesale (new sprite, new stat block, new ability set).
  3. **Pact bond** — the vessel-lord pair has a permanent
     support rank that can never be reset. High bond unlocks
     paired arts (lord-vessel combo attacks).

## Vessel mortality (player choice at run start)

Every run prompts the player to pick how their vessel handles
death. The choice is per-run, not per-format — Skirmish,
Standard, Long, and Saga all offer both modes. The choice goes
into the run save record and surfaces on the post-run summary.

- **Restored Pact** (default, narrative-focused). Vessels
  cannot die mid-battle. When HP hits 0, the vessel reverts to
  its fledgling form and is sidelined for the remainder of the
  battle; the next camp node restores it. The campaign reads
  as the planned emotional through-line — the partner is
  always there for the next chapter.
- **Permabond** (challenge-focused). Full FE-style permadeath
  for the vessel. When HP hits 0, the vessel dies for real;
  the lord can fight on for the remainder of the run, but the
  Pact is severed and lord-vessel combo arts are no longer
  available. Recruited secondary units already had FE
  permadeath; this just extends it to the partner.
  Permabond runs grant a small permanent meta-currency bonus
  on completion to acknowledge the higher stakes.

Both modes share the same `RunState` data and run loop; the
mortality choice is one boolean on the run save. Permabond
defeat doesn't auto-end the run — losing the vessel is a
narrative gut-punch but the lord may yet succeed. (Iron Run as
a *run format* further removes the lord's revive token; the
two settings stack: Permabond + Iron Run = a fully ironclad
expedition.)
- **Stage names — neutral and made-up.** Fledgling, bonded,
  sworn, ascendant. Note that *none of those four are
  Digimon's tier names* (which are *baby / in-training / rookie
  / champion / ultimate / mega*). Different cadence (4 vs 6
  stages), different names, different mechanic emphasis.
- **Promotion items.** Story flags + a Pact Stone item (rare,
  obtained from boss drops or shrines) gate promotions. Story
  flags ensure narrative pacing; the stone makes promotion feel
  earned.
- **Vessel archetypes — slice 4 of ~16 at full launch.**
  - Wyrmling (draconic, ranged breath attacks, multi-stage to
    Wyrm).
  - Sprite (small fey, healing/utility, multi-stage to Spirit).
  - Wraith (shadow, dodge-tank, multi-stage to Specter).
  - Beastform (bestial, melee bruiser, multi-stage to
    Worldbeast).

## Lord system

Slice ships with 2 Lord-Pact pairs; full launch targets 6.

A Lord-Pact pair has:

- A signature lord class (Vanguard, Warden, Bard-of-Storms,
  etc.) that is themed to its vessel.
- A vessel archetype permanently bound to that lord (hand-paired
  by design).
- A unique narrative arc for each act — the campaign reads
  differently depending on which pair you picked.
- A unique pact passive (Wyrmling-Lord's *Skybinding* lets the
  lord ride the vessel once it reaches *bonded*; Sprite-Lord's
  *Twin Souls* shares hp pool between lord and vessel; etc.).

## Classes

Two distinct grids: human Lord/Companion classes and Vessel
classes. Each follows the same FE Class Resource as Games 1, 2,
and 3.

**Human classes — slice 6 of ~28 at full launch.**

Slice picks: Vanguard (lord-tier), Warden, Bard-of-Storms,
Hunter, Cleric, Strategist.

**Vessel classes — slice 4 base + their multi-stage forms at
full launch (16 archetypes × 4 stages = 64 distinct vessel
class entries, though only the 4 base + their first promotions
ship in the slice).**

Slice picks: Wyrmling → Wyrm, Sprite → Spirit, Wraith →
Specter, Beastform → Worldbeast.

The number is high because each stage is a separate ClassDef
.tres — designers tune each form independently.

## Vertical slice scope (~6-9 weeks once Games 1/2 cores ship)

- 1 act, 8-12 nodes including 2 hand-authored story-flag nodes
  that gate vessel promotion.
- 2 Lord-Pact pairs, 6 human classes, 4 vessel archetypes ×
  2 stages each (so 8 vessel ClassDefs).
- 6 hand-crafted maps + 3 procedural map templates.
- 15 abilities, 10 relics (3 are Pact-bond memorial relics from
  failed runs), 8 events including 3 narrative-arc events.
- Promotion-stone economy: 1 promotion path active for the
  slice (fledgling → bonded), others stubbed.
- Tutorial (first 3 battles + the first promotion arc).
- Skirmish run format only.

## Out of scope for the slice (parking lot)

- Saga / Endless / Boss Rush / Iron run formats.
- Vessel fusion (combining two vessels into a hybrid form) —
  designed but post-launch.
- Pact dissolution / re-pairing — initial design says no, the
  Pact is monogamous per lord. May revisit.
- Online leaderboards, daily seeded runs.

## IP guardrails (recap from CLAUDE.md)

- No Digimon franchise names, designs, music motifs, or
  silhouettes. No franchise-coded creatures: no Agumon-coded
  yellow-T-rex, no Greymon-coded horned-dinosaur boss, no
  Patamon-coded white-flying-pig.
- No franchise terminology: not "Digivolve" / "Digivolution"
  (trademarked), not "Digimon", not "Digivice", not "Mega
  level" / "Ultimate level" as proper nouns. Multi-stage
  promotion uses our four neutral names: fledgling, bonded,
  sworn, ascendant.
- The mechanic of multi-stage promotion is shared with Persona,
  Shin Megami Tensei, Yokai Watch, FE Awakening's reclass
  system, and arguably Pokemon. Mechanics aren't IP — the
  franchise's specific naming and creature designs are.
- Working title runs through USPTO TESS and EUIPO before any
  marketing pass — and does so with extra scrutiny since
  Bandai Namco owns aggressively in this category.

## Marketability angle

Partner-bond + true tactics is even thinner than creature
collection. The mass-market partner-bond games (Pokemon,
Digimon, Yokai Watch) are all 1v1 turn-based JRPGs, not grid
tactics. Vessel Pact targets tactics-RPG fans who want a deeper
emotional through-line than FE typically delivers — the lord
and their evolving partner as the campaign's heart.
