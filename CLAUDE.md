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
- **Four games, one engine**: a shared `core/` plus theme packs
  under `games/sengoku/` (Game 1), `games/crystal/` (Game 2),
  `games/pocketkin/` (Game 3), and `games/datapact/` (Game 4).
  Nothing in `core/` may import from `games/*` — the dependency
  arrow is one-way.
- **Sequencing**: Game 1 vertical slice ships first. Game 2
  begins after Game 1's slice is internally validated. Games 3
  and 4 enter pre-production only after Game 1 or Game 2 has
  shipped — they reuse the same core/ and benefit from a
  hardened combat / run / meta layer. No parallel full-team work
  on more than one game at a time.
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
- **Game 3 — FE-foundation creature collection** (working title
  *Pocketkin Tactics* — "Pocket" telegraphs the Pokemon-genre
  collection theme; "kin" telegraphs the FE-flavored
  trainer-companion bond): Fire-Emblem grid tactics combined with a
  creature-collection loop — recruitable beasts encountered through
  events, an element triangle that overlays the FE weapon triangle,
  multi-stage promotions for individual creatures, and bonds with
  trainers persisting as relics across runs. **No Pokemon IP**: no
  specific creature names from the franchise, no Pokeball-coded
  capture device silhouettes, no Pikachu-coded designs (no
  yellow-electric-rodent silhouettes, no specific franchise mascots),
  and we never use "Pokemon", "Pokeball", "Trainer Battle", or other
  trademarked terms as proper nouns. The genre-generic terms
  (capture, recruit, partner, evolve, type advantage) are mechanics,
  not IP, and stay fair game.
- **Game 4 — FE-foundation partner-bond** (working title
  *Datapact Tactics* — "Data" telegraphs the Digimon-genre
  *digital monster* theme; "pact" telegraphs the FE-flavored
  lord-vessel covenant): Fire-Emblem grid tactics combined with a partner-bond loop
  — each lord pairs with one evolving companion that goes through
  multi-stage promotions (neutral terms only: Fledgling → Bonded →
  Sworn → Ascendant or similar) and a heavier narrative arc
  reminiscent of partner-creature genres. **No Digimon IP**: no
  specific franchise creature names, no "Digivolve" / "Digivolution"
  terminology (that exact word is trademarked), no
  Digimon-signature silhouettes (no Agumon-coded yellow-T-rex,
  Greymon-coded horned dinosaur, etc.). Multi-stage promotion is a
  mechanic shared with Persona, Shin Megami Tensei, Yokai Watch, and
  classic FE itself — that mechanic is fine; the franchise's
  specific creatures and naming aren't.
- **Generic vs trademarked names**: tactics-RPG terms used widely
  across the genre (Dragoon, Geomancer, Time Mage, Red Mage,
  Paladin, Sage, Sniper) are fine. Distinctive FF names (Onion
  Knight, Mime, Calculator, etc.) are out. Element type names
  (Fire / Water / Wind / Earth / Light / Dark) are universal across
  RPGs and fine for Games 3 and 4. Specific franchise type names
  used as proper nouns ("Pokemon-type", "Mega-Evolution",
  "Digivice") are out.
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
  "Crystalfall Tactics", "Pocketkin Tactics", "Datapact Tactics")
  are placeholders — all four are slated for a re-brainstorm and
  formal selection later. Game titles also need brand-clearance for
  the creature-collection and partner-bond games specifically
  (because those genres are dominated by entrenched IP — Pokemon
  and Digimon monitor closely for confusingly similar marks).
