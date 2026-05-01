# Visual + audio style guide

A brief for art, animation, UI, sound, and music. This is a
living doc — update it when style decisions firm up. Bind every
content asset to one of the four games' tone notes (game1, game2,
game3, game4 design docs); this guide covers the cross-game
language.

## Cross-game principles

- **Original character designs only.** No Koei Tecmo, Square
  Enix, Nintendo, Intelligent Systems, Game Freak, or Bandai
  Namco character look-alikes. When a brief reaches "this
  reminds me of [franchise character]", redesign. See
  `CLAUDE.md` for the legally locked rules.
- **Painterly over pixel.** Rough digital painting (think
  Yoshitaka Amano framing, Studio Ghibli landscape sense, but
  in our own palette and line work) reads as adult, considered,
  and avoids the shovelware-pixel-art bin on Steam.
- **Restrained palette.** Each game gets a 4-6 color core
  palette plus 1-2 accent colors. Saturation stays mid-range;
  avoid neon. UI text on backgrounds always passes WCAG AA
  contrast.
- **Clear silhouettes.** Every unit reads as a single shape at
  thumbnail size. If two units silhouette identically the
  player can't tell them apart in battle. Test by exporting
  64x64 grayscale silhouettes at art-review time.
- **No anime-coded character designs.** Big eyes + small mouth +
  spiky hair tropes signal mass-market gacha and pull our
  audience signal away from the tactics-RPG core. We're aiming
  at 25-45 PC tactics fans, not 13-21 mobile gacha fans.
- **One idle, one move, one strike.** Every unit needs at least
  these three animation states. Hits and deaths can be 4-8
  frames; idle can be 2-4 frames at 4 FPS.

## Per-game tone

| Game | Period feel | Palette anchor | Music | Reference (atmospheric, not stylistic) |
|---|---|---|---|---|
| Banner of Ashes (G1, Sengoku) | Grim historical, low fantasy | Restrained earth + red + gold; black ink for line work | Shakuhachi, taiko, biwa; sparse | Hokusai/Yoshitoshi woodblock prints |
| Crystalfall Tactics (G2, FE-foundation high fantasy) | Heroic-melancholy painterly | Crystal-blues, amber, deep forest greens | Orchestral plus solo violin / koto for crystal motif | Yoshida-school silhouette discipline |
| Pocketkin Tactics (G3, creature collection) | Sun-drenched expedition | Warm naturals — leaf greens, ochre, sky blue | Wind instruments + light strings | Studio Ghibli landscape paintings |
| Datapact Tactics (G4, partner-bond) | Heroic-bittersweet, slightly mythic | Bronze, deep red, ivory; metallic accents | Orchestral with one signature motif per Pact | Ralph McQuarrie atmospheric concept work |

## Character design rules

- **No franchise mascots.** No Cloud-coded silver-hair-buster-
  sword silhouettes (G2). No Pikachu-coded
  yellow-electric-rodent silhouettes (G3). No Agumon-coded
  yellow-T-rex silhouettes (G4). No Lu-Bu-coded red-armor-
  halberd silhouettes (G1).
- **Class-readable proportions.** Heavy units are wider; fast
  units are narrower; flying units have a clear vertical lift
  in their idle pose.
- **Realistic adult range.** Avoid extremes: no waifish
  fanservice teens, no chibi proportions, no bara muscle bulk
  unless the class explicitly calls for it (e.g. Sumo Brawler).
- **Faces speak.** Major characters get a portrait that reads
  as a specific person. Generic units may share a portrait
  template tinted per side.

## UI rules

- **Touch first.** Minimum 44pt tap target on phone (we use
  48-56px in practice for buttons). 16-24px margins between
  interactive controls. No hover-only behavior.
- **Readable on a 5.4" phone in sunlight.** 16pt minimum body
  text. High-contrast text on solid backgrounds. No long body
  text in italics.
- **Reusable theme Resource.** `games/<theme>/ui_theme.tres`
  recolors every Control through Godot's Theme system. Code
  never bakes UI colors; only the theme does.
- **Animation is a flourish.** Tween-based UI animations max
  150ms. Skip animation on the second tap of the same button
  (don't force the player to wait for a re-emit).
- **Status colors stay consistent across screens:**
  Player units: `Color(0.40, 0.78, 0.50)` — green
  Enemy units:  `Color(0.85, 0.42, 0.42)` — red
  Locked items: `Color(1, 1, 1, 0.45)` — dimmed white
  Victory tint: `Color(0.55, 0.90, 0.60)` — green
  Defeat tint:  `Color(0.95, 0.45, 0.45)` — red
  See `core/ui/battle_screen.gd` and
  `core/ui/result_screen.gd` for the canonical hex values.

## Sound design rules

- **No looping ambient drone.** Background music has a clear
  intro / loop / outro. Battle SFX are short and panned center.
- **One-shot SFX library coverage:**
  hit_light, hit_heavy, hit_crit, miss,
  ability_physical, ability_magical, ability_heal,
  unit_die, button_press, screen_transition, victory_sting,
  defeat_sting, gold_pickup, relic_pickup. Mix to roughly the
  same loudness; a soft compressor on the bus is fine.
- **Music loops are 60-90 seconds** so the player isn't trapped
  in a 4-minute orchestral piece during a 20-minute Skirmish.
- **Mute by default in settings.** Many phone-tactics players
  play with audio off. Default `BGM` and `SFX` sliders to 60%,
  not 100%, so the first launch isn't loud.
- **No interstitial stings on routine actions.** A button press
  is a click, not a fanfare. Save the orchestral stings for
  victory / defeat / relic-grant.

## Asset checklist for the slice

When art and audio start, the asset list for the Game 1
vertical slice is roughly:

- 8 player class portraits + 12 enemy unit portraits.
- 8 player class sprites (idle/move/strike) + 12 enemy.
- 6 hand-crafted map backgrounds + 6 procedural-template
  tilesets (forest, hill, road, water, wall variants).
- 1 Hub background, 1 Map background, 1 Battle background per
  hand-crafted map, 1 Result background (win + lose variants).
- Portraits for the 4 starting Lord-Wardens (slice).
- Cover art for the storefront — landscape 1920x1080 + square
  1024x1024.
- 14 SFX one-shots (above) + 1 hub track + 1 battle track +
  1 boss track + 1 victory sting + 1 defeat sting.
- 8 event illustrations (one per slice event) at small size
  (e.g. 512x256).

## Look-alike enforcement

Before shipping, run a "silhouette test" on every unit:

1. Export to grayscale at 64x64.
2. Place next to top results from a Pokemon/Digimon/FE/FF
   image search for a similar archetype.
3. If a non-fan can't tell yours apart from the franchise
   archetype, redesign.

Also: run trademark search on every NAMED character (not just
game titles) before any marketing. Cheap insurance.
