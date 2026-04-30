# Monetization

`CLAUDE.md` locks the rules: Steam = premium one-time purchase.
Mobile = premium with **only cosmetic** IAP and **only optional
rewarded** ads. **No** pay-to-win, **no** interstitials, **no**
energy timers, ever.

This doc lays out how that policy turns into prices, plumbing,
and a launch sequence.

## Steam (both games)

- **Premium one-time purchase**, target **$14.99–$19.99** per
  game (tactics-roguelite range — see `marketability.md` for
  comps).
- **No microtransactions** in the Steam build.
- **No ads** in the Steam build, including no in-game cross-promo
  to mobile.
- **Cosmetic DLC packs** ($2.99–$4.99) post-launch only after the
  game has a stable cadence of cosmetic content. Skip if we can't
  commit to one pack per quarter.
- **Soundtrack DLC** as a separate $4.99–$7.99 product if a
  composer agreement allows it.

## Mobile (iOS / Google Play)

### Tier 1 — premium (default)

- **Paid app, $4.99–$6.99**, full game.
- Cloud save via the same JSON save format as Steam (per
  `CLAUDE.md`).
- Optional cosmetic IAP, see "Cosmetic IAP" below.
- **No ads** in the premium tier.

### Tier 2 — free with unlock IAP (post-launch experiment)

- App is free; first run format (Skirmish) and the first act of
  Standard are unlocked.
- One **single $4.99 IAP** unlocks the full game forever.
- Cosmetic IAP also offered.
- **Optional rewarded ads only**, see "Rewarded ads" below.
- Ship Tier 2 only if Tier 1 mobile data shows we're being
  out-discovered by free competitors. A/B carefully — the wrong
  free split kills full-game conversion.

### Cosmetic IAP

- **What sells**: alternate unit skins, banner designs, victory
  animations, hub decorations, portrait frames.
- **What does not exist**: stat boosts, XP boosts, currency
  boosts, gacha, lootboxes, "starter packs" with gameplay items.
- **Price tiers**: $0.99 / $1.99 / $2.99 single packs; $4.99 /
  $9.99 bundles. No tier above $9.99 — anything more reads as
  predatory in this genre.
- **Discoverability**: a single Cosmetics shop in the meta hub.
  No interstitial popups, no nag screens, no "gift offers."
- **Cadence**: budget one cosmetic pack per quarter post-launch
  per game. If we can't sustain that, drop cosmetic IAP entirely
  rather than ship a dying shop.

### Rewarded ads (Tier 2 only)

- **One reward**: an extra meta-currency draw per day.
- **Where**: hub screen, behind a single optional button.
- **No** interstitials. **No** ads between battles. **No** ads
  during battles. **No** ads on death screens. **No** ads on app
  launch.
- **Daily cap**: 1 rewarded ad per 24 hours. Beyond that the
  button is disabled with a friendly cooldown message.
- **Privacy**: respect ATT (iOS) and DMA (EU) properly. Default
  to non-personalized ads when the user opts out.

## Receipt validation

All IAP — Steam DLC, mobile premium upgrade, cosmetic packs —
flows through a server-side receipt validation stub. Build the
interface now (per the plan, Step 9), harden before launch.

- iOS: validate App Store receipts via Apple's verifyReceipt
  endpoint (or its successor).
- Android: validate Play Billing tokens via Google Play
  Developer API.
- Steam: SteamUser auth ticket + ISteamMicroTxn for any DLC.
- Failure mode: cosmetic stays locked client-side until a valid
  receipt is confirmed; never block gameplay on a network
  hiccup.

## Pricing across regions

- iOS / Google Play: use platform-recommended price tiers for
  each region rather than a flat USD conversion. China, Brazil,
  India, Turkey, Argentina need lower tiers to be competitive.
- Steam: enable regional pricing per Valve's recommendations.
  Don't manually undercut — it gets re-keyed and reimported.
- All prices reviewed quarterly post-launch.

## Anti-patterns we will not ship

- **Energy / stamina systems**. Players can play as long as they
  want, period.
- **Daily login rewards** that escalate or punish missed days.
  A simple Daily Run leaderboard is fine; "3 free spins" is not.
- **Interstitial ads** of any kind, anywhere.
- **Pay-to-win**: no XP boosters, no rare-relic shortcuts, no
  unit-revive purchases.
- **Lootboxes / gacha**: no randomized paid outcomes.
- **Predatory FOMO sales**: no countdown timers on cosmetic
  bundles, no "limited time only" cosmetics that never come back.
- **Forced account linking**: an optional cloud-sync account is
  fine; a required account to play is not.
- **Forced data collection**: telemetry must be opt-in on first
  launch, not opt-out.

## Launch sequence

1. Build IAP/ads interfaces during normal development; leave
   bodies as no-op stubs.
2. Wire real IAP bodies in the final 4 weeks before submission;
   test against sandbox accounts on both stores.
3. Test ad SDK on a Tier-2 build only when Tier 2 is greenlit.
4. Soft-launch in 1–2 small markets (NZ, PH, CA) for 2–4 weeks.
   Gate global launch on D1 ≥ 35%, D7 ≥ 12%, no top-3 crash bug
   outstanding (see `marketability.md`).
5. Global launch. Post-launch cadence: cosmetic pack per
   quarter (per game, only if sustainable) and a free balance
   patch every 6–8 weeks for the first year.
