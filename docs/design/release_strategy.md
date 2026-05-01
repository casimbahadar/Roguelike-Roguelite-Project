# Release strategy: four separate products, one shared engine

This is a locked decision. Update the rule in `CLAUDE.md` if it ever
changes; never quietly ship a different shape.

## What ships

Four standalone products, each on its own store page:

| Game | Working title | Steam | iOS | Google Play |
|---|---|---|---|---|
| 1 | Banner of Ashes (Sengoku) | own listing | own listing | own listing |
| 2 | Crystalfall Tactics (FE+JRPG) | own listing | own listing | own listing |
| 3 | Pocketkin Tactics (creature-collection) | own listing | own listing | own listing |
| 4 | Datapact Tactics (partner-bond) | own listing | own listing | own listing |

Each title has its own price, trailer, screenshots, icon, screenshots,
keywords, age rating, and audience-tuned store copy. There is **no
multi-game hub product** sold to players, and there is no overall
umbrella name customers ever see.

Why four separate products and not one bundle:

- **Audience fit**: Sengoku-warriors fans, FE/FF tactics fans, Pokemon-genre
  fans, and partner-bond fans are mostly disjoint. A single store
  listing forces every page to compromise on screenshots, copy,
  keywords, and rating.
- **Pricing**: each game can carry its own price ($14.99–$19.99 on
  Steam, $4.99–$6.99 mobile premium) without cannibalising the others.
- **Discoverability**: four store pages = four sets of tags, four
  trailers, four chances at "More like this" surfacing.
- **Risk isolation**: a flop or refund-storm on one title does not
  drag the others' Steam reviews, App Store ratings, or rankings.

## What is shared

Everything below the content layer:

- One Godot 4 project tree on disk (this repo).
- One `core/` engine: combat, run loop, save, meta, map gen, UI
  framework, AI archetypes, RunConfig.
- One CI: every push runs the same smoke suite against every theme
  pack.
- One bug fixed in `core/` is fixed in all four games.

What is *not* shared:

- Store pages, prices, trailers, marketing.
- The shipped binary: each export preset bundles **exactly one** theme
  pack and the player never sees the others.
- Save files: each game has its own save namespace (different app id /
  bundle id / save filename).

## How a build is targeted at one game

`core/ui/main.gd` resolves the active theme pack in this priority
order:

1. **Test/harness override**: `set_theme_pack(pack)` was called before
   `_ready` (used by smoke tests and by the in-engine title screen).
2. **Build feature tag**: the running build has one of these custom
   feature tags, set in the export preset's *Custom Features*:
   - `sengoku` → loads `res://games/sengoku/sengoku_pack.tres`
   - `crystal` → loads `res://games/crystal/crystal_pack.tres`
   - `pocketkin` → loads `res://games/pocketkin/pocketkin_pack.tres`
   - `datapact` → loads `res://games/datapact/datapact_pack.tres`
3. **Neither**: fall through to the dev-only title screen so a
   developer can pick a pack from the editor.

The mapping lives in `FEATURE_TAG_TO_PACK` in `core/ui/main.gd`. Adding
a fifth game means adding one entry there and a new export preset —
no engine changes.

### Per-product export presets

Each shipped product has its own export preset per platform.
Configure each preset in **Project → Export → Resources → Filters
to export non-resource files/folders** to include only its own
`games/<theme>/` tree (so the binary doesn't ship the other three
themes' assets), and in **Custom Features** set exactly one of the
four feature tags above.

Suggested preset matrix (12 presets total at launch):

| Preset name | Platform | Feature tag | Resource filter |
|---|---|---|---|
| Banner of Ashes — Steam | Linux/Windows/macOS | `sengoku` | `games/sengoku/*` |
| Banner of Ashes — iOS | iOS | `sengoku` | `games/sengoku/*` |
| Banner of Ashes — Android | Android | `sengoku` | `games/sengoku/*` |
| Crystalfall — Steam | Linux/Windows/macOS | `crystal` | `games/crystal/*` |
| Crystalfall — iOS | iOS | `crystal` | `games/crystal/*` |
| Crystalfall — Android | Android | `crystal` | `games/crystal/*` |
| Pocketkin — Steam | Linux/Windows/macOS | `pocketkin` | `games/pocketkin/*` |
| Pocketkin — iOS | iOS | `pocketkin` | `games/pocketkin/*` |
| Pocketkin — Android | Android | `pocketkin` | `games/pocketkin/*` |
| Datapact — Steam | Linux/Windows/macOS | `datapact` | `games/datapact/*` |
| Datapact — iOS | iOS | `datapact` | `games/datapact/*` |
| Datapact — Android | Android | `datapact` | `games/datapact/*` |

Each preset must also use a unique:

- App / bundle id (e.g. `com.studio.banner_of_ashes`).
- App / display name.
- Icon and splash assets.
- Save-file namespace (set per preset, picked up by `SaveSystem`).

## The title screen's actual role

The four-theme title screen (`core/ui/title_screen.tscn`) exists
**only** as an in-editor harness so we can test all four packs
against the same engine without juggling four export presets. It
must never appear in a shipped build. The feature-tag check above is
what guarantees this.

If the title screen ever ships to a real player, that's a build
configuration bug — the export preset is missing its feature tag.

## What this means for `core/`

- Nothing in `core/` may hard-code a theme id, theme path, or
  theme-specific class name. The `FEATURE_TAG_TO_PACK` constant in
  `main.gd` is the single registry; everything else reads from the
  loaded `ThemePack`.
- Adding a fifth game later is one new theme pack folder + one row in
  `FEATURE_TAG_TO_PACK` + one row of export presets. No engine churn.

## What this means for marketing/legal

- Trademark searches happen per title (USPTO TESS + EUIPO).
- Privacy policies and EULAs are per title (different bundle ids =
  different store reviews).
- Store keyword sets are per title and tuned to that genre's audience.
