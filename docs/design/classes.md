# Class rosters (Game 1 + Game 2)

Each game targets **≥ 50 classes** total, with **8 in the vertical
slice** so we can balance and ship the slice without painting
ourselves into a corner. `→` indicates a promotion path.

Real / signature characters sit *on top of* this grid as unique
units with bespoke kits. The class roster defines the *mechanical
archetypes* the game balances around — characters are content;
classes are the engine.

---

## Game 1 — Sengoku (Banner of Ashes), 56 classes

**Vertical slice (8):** Ashigaru, Samurai, Yari Cavalry, Yumi
Archer, Shinobi, Sohei, Onmyoji, Tactician.

**Foot infantry**

- Ashigaru → Bushi → Samurai
- Ronin
- Ji-samurai
- Kensei
- Iaijutsu Master
- Onibi-Ronin (fire-imbued)
- Sohei → Sohei Abbot
- Komuso (flute-mask shock troop)
- Yamabushi (mountain ascetic)
- Yari Ashigaru → Naginata Sohei
- Naginata Mistress
- Bo Master
- Sumo Brawler

**Cavalry**

- Sengoku Cavalier → Sengoku Paladin
- Yari Cavalry
- Yumi Cavalry (mounted archer)
- Naginata Cavalier
- Daimyo (mounted lord)
- Banner Lord (cavalry commander)

**Ranged**

- Yumi Archer → Daikyu Marksman
- Tanegashima Gunner (matchlock)
- Fukiya Skirmisher (blowdart)
- Bow Hunter
- Crossbow Levy

**Stealth / skirmish**

- Shinobi
- Kunoichi
- Iga Spy
- Koga Saboteur
- Yamadachi (bandit)
- Wako (coastal raider)
- Kabukimono (flamboyant duelist)

**Magic / spiritual**

- Onmyoji → Daionmyoji
- Miko (shrine maiden, healer) → Kannushi (priest)
- Fudoki Shugenja
- Kuji-In Adept (ninja sorcery)
- Hojin Master (paper-talisman caster)
- Shikigami Summoner

**Heavy / elite**

- Oyoroi Bushi (great-armor samurai)
- Tate-mochi (shield-bearer)
- Hatamoto (banner-protector elite guard)
- Akuma Slayer (oni hunter)

**Special / fantasy (this is an alt-Sengoku setting — fantasy is in)**

- Tengu Knight (winged)
- Kitsune Trickster (fox spirit)
- Oni-touched Berserker (demon-blooded)
- Uminushi (sea-spirit warrior)
- Yokai-bound Tamer
- Hokkaido Dragon Disciple (manakete-equivalent transforming)

**Support / utility**

- Gunshi (Tactician)
- Biwa-hoshi (blind lute monk, bard)
- Shirabyoshi (dancer)
- Camp Cook (morale buffer)

**Legendary commanders (unique units, not generic classes):**
Oda Nobunaga, Tokugawa Ieyasu, Takeda Shingen, Uesugi Kenshin, Date
Masamune, Tachibana Ginchiyo, Hattori Hanzo, etc. — each tied to a
thematic class with bespoke skills and original portrait/voice work.

---

## Game 2 — FE-foundation high fantasy (Crystalfall Tactics), 60 classes

**Vertical slice (8):** Lord, Knight, Cavalier, Pegasus Knight,
Archer, Mage, Cleric, Thief.

**Foot infantry**

- Recruit → Soldier → Sentinel
- Fighter → Warrior → Berserker
- Mercenary → Hero → Champion
- Brawler → Grappler
- Myrmidon → Swordmaster → Blademaster
- Halberdier
- Spearman
- Trickster
- Duelist

**Stealth / skirmish**

- Thief → Rogue → Assassin
- Bandit → Brigand
- Pirate → Corsair

**Heavy / armor**

- Knight → General → Fortress
- Templar
- Great Knight

**Cavalry**

- Cavalier → Paladin → Gold Knight
- Lancer (mounted)
- Bow Knight
- Mage Knight (Dark Rider)
- Valkyrie (mounted healer)

**Flying**

- Pegasus Knight → Falcon Knight
- Wyvern Rider → Wyvern Lord
- Dragoon (FF-flavored jumping lance)
- Sky Sentinel

**Ranged**

- Archer → Sniper → Marksman
- Hunter → Ranger
- Arbalist (crossbow specialist)

**Arcane magic**

- Mage → Sage → Archsage
- Sorcerer
- Dark Mage / Shaman → Druid
- Witch
- Summoner
- Necromancer
- Geomancer
- Time Mage
- Red Mage (hybrid)
- Elementalist
- Spellblade

**Divine magic / support**

- Cleric → Bishop → Saint
- Priest
- War Monk
- War Cleric

**Performer / utility**

- Bard
- Dancer
- Songweaver
- Strategist (Tactician)

**Special / transforming**

- Dragonborn (Manakete-equivalent transforming dragon)
- Beastkin (transforming, sub-tribes: Wolfkin, Foxkin, Hawkkin)
- Vanguard (lord-tier promoted protag class)

---

## Implementation notes

- Each class is a `ClassDef` Resource with: stats, growths,
  movement type (foot/mounted/flying/transforming), weapon
  proficiencies, signature ability, promotion target (or empty),
  and a `theme: StringName` field marking sengoku/crystal/shared.
- A unit's *current* class is just a reference to a `ClassDef`;
  swapping classes between runs is a metadata change, not a unit
  recreation.
- Promotion is gated on level **and** an item or story flag, FE-style.
- All numbers live in `.tres`, not in code (per `CLAUDE.md`).
