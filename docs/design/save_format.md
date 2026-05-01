# Save format reference

Saves are plain JSON written to Godot's `user://` directory.
The schema is whatever `MetaState.to_dict()` emits; this doc
documents the shape so future migrations stay backwards-
compatible.

## File location

- All platforms: `user://meta.json` resolves per-platform:
  - Linux: `~/.local/share/godot/app_userdata/Roguelike Roguelite Project/meta.json`
  - macOS: `~/Library/Application Support/Godot/app_userdata/Roguelike Roguelite Project/meta.json`
  - Windows: `%APPDATA%\Godot\app_userdata\Roguelike Roguelite Project\meta.json`
  - iOS / Android: app sandbox container.
- The path constant lives on `SaveSystem.DEFAULT_PATH`.

## Schema (current)

```json
{
  "unlocked_run_formats": ["tutorial", "skirmish", "daily"],
  "unlocked_classes": [],
  "unlocked_commanders": [],
  "meta_currency": 0,
  "runs_completed": {},
  "runs_attempted": {},
  "best_runs": {},
  "cosmetics_owned": []
}
```

Field-by-field:

| Field | Type | Meaning |
|---|---|---|
| `unlocked_run_formats` | `Array<String>` | RunConfig ids the hub may show as unlocked (StringName → String round-trip). |
| `unlocked_classes` | `Array<String>` | ClassDef ids the player may field. Empty in slice — every class is auto-available. |
| `unlocked_commanders` | `Array<String>` | Lord ids unlocked. Reserved for the Lord system; empty in slice. |
| `meta_currency` | `int` | Cross-run currency for hub purchases. Cumulative; never decreases except via meta-shop spend. |
| `runs_completed` | `Object<String, int>` | Per-format completion count, used by `MetaUnlocks.is_unlocked`. |
| `runs_attempted` | `Object<String, int>` | Per-format attempt count for telemetry / soft-launch metrics. |
| `best_runs` | `Object<String, Object>` | Per-format best-run record (seed, time_seconds, score). Reserved; the slice doesn't write this yet. |
| `cosmetics_owned` | `Array<String>` | Cosmetic-IAP ids (StringName → String). Empty in slice. |

## Cross-platform sync

The whole file is a UTF-8 JSON document with no
engine-specific binary blobs (`CLAUDE.md` rule). For cloud
sync:

- iOS: iCloud Documents directory or Game Center Save Game.
- Android: Google Play Saved Games API.
- Steam: Steam Cloud (`SaveGames` directory).

A future `core/platform/cloud_save.gd` will own this; for the
slice the local `user://meta.json` is the single source of
truth.

## Migration policy

When the schema needs to change:

1. **Additive change** (new field): add to `MetaState.to_dict()`
   and read it in `from_dict()` with a sensible default
   (`d.get("new_field", default_value)`). Old saves keep
   working — they just don't have the new field, default
   applies.
2. **Renamed field**: keep reading the old key in `from_dict()`
   for at least one shipping version, then remove. Document in
   this file when the deprecation lands.
3. **Removed field**: stop reading it; ignore extra keys in
   from_dict (already the default). Don't error on saves that
   still contain the old key.
4. **Type change**: write a one-time migration in `from_dict()`
   that detects the old type and converts.

Never break load on existing saves — players' streaks /
unlocks are emotionally load-bearing.

## Versioning hook

Not currently in the schema, but a `"schema_version": 1`
top-level int can land later. Plan: bump on every breaking
schema change, and `from_dict()` runs the appropriate
migration chain (1 → 2 → 3 → ...).

## Receipts and DLC

IAP receipts are intentionally NOT stored in `meta.json` —
they're validated server-side per `core/platform/iap.gd`. A
DLC entitlement check at hub-load time consults the platform
SDK, not the local save.

## Privacy

`meta.json` contains no PII. It's fine to include in support
bug-report attachments verbatim. If telemetry is added later,
that goes through a separate file (`user://telemetry.json`)
with explicit opt-in (see `monetization.md` ATT/DMA rules).
