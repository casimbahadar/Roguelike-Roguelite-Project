# Run formats

Both games ship the same set of run formats. Finishing a shorter
format unlocks the next longer one. Short formats fit a mobile
session; long formats give long-haul players a multi-hour campaign.

| Format | Acts / nodes | Approx. length | Unlocked by |
|---|---|---|---|
| **Skirmish** | 1 act, ~6 nodes, 1 boss | ~20 min | Available from start; doubles as the tutorial run |
| **Standard Campaign** | 3 acts, ~20–25 nodes, 3 bosses | ~60–75 min | Clear Skirmish once |
| **Long Campaign** | 5 acts, ~40–50 nodes, 5 bosses + final | ~2–3 hr (resumable) | Clear Standard on any commander |
| **Saga Run** | Branching narrative, 4–6 acts with character side chapters | ~3–4 hr | Clear Long Campaign once |
| **Endless Tower** | Floors that scale infinitely; leaderboards | session-defined | Clear Long Campaign once |
| **Boss Rush** | Bosses only, no shop nodes, mid-fight loadout swaps | ~30 min | Clear Standard once |
| **Daily Run** | Standard layout, shared seed, global leaderboard | ~60 min | Reach the meta hub (very early) |
| **Iron Run** | Standard layout, no revive tokens, single save slot, true permadeath | ~60 min | Clear Standard once |

## One Resource drives all of them

A single `RunConfig` Resource parameterizes every format. There is
**one** run-loop codepath; new formats are content additions, not
engine changes (per `CLAUDE.md`).

`RunConfig` fields (initial sketch — refine when implementing):

- `id: StringName` — `skirmish` / `standard` / `long` / `saga` / `endless` / `boss_rush` / `daily` / `iron`.
- `act_count: int`.
- `nodes_per_act: Vector2i` — min/max for procedural map gen.
- `boss_pool: Array[BossDef]` — ordered list, one per act.
- `revive_policy: enum { NONE, ONE_PER_RUN, ONE_PER_ACT }`.
- `seed_source: enum { RANDOM, DAILY_UTC, FIXED }` plus optional
  `fixed_seed: int`.
- `leaderboard_key: StringName` — empty string = no leaderboard.
- `unlock_requirement: UnlockDef` — checked on hub screen.
- `narrative_track: NarrativeTrackDef?` — only Saga uses this.
- `endless_scaling: EndlessCurveDef?` — only Endless uses this.

The hub screen renders one button per `RunConfig` whose
`unlock_requirement` is satisfied. Locked formats appear greyed-out
with their unlock condition shown — visible progression is itself a
retention hook.

## Resumability

Standard, Long, and Saga must save mid-turn so a mobile player can
close the app between battles or even between unit moves. Skirmish
and Boss Rush can save between battles only. Endless saves at the
top of each floor. Iron Run saves only at node transitions and
deletes the save on death.
