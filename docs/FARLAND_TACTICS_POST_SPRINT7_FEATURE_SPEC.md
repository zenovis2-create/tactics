# Farland Tactics — Post-Sprint-7 Feature Spec & Implementation Checklist

**Project**: Farland Tactics (Godot 4 turn-based tactical RPG)
**Status**: CH01–CH10 complete, Bond system, NG+, Crafting implemented. Runner 8/8 green.
**Purpose**: Transform this technically-complete game into a game that creates **memorable moments** — the kind players talk about years later.
**Design Thesis**: The gap between "tactical RPG" and "unforgettable experience" is **the weight of choice** and **character attachment**. Every system below serves one or both.

---

## Priority Map

| # | Feature | Priority | Category | Dependencies |
|---|---------|----------|----------|-------------|
| 1 | Support Conversation + Name Call Integration | ⭐⭐⭐⭐⭐ | Emotion | — |
| 2 | Tactical Environmental Interactions + 3-Star Clear | ⭐⭐⭐⭐⭐ | Gameplay | — |
| 3 | War Council / Mission Briefing | ⭐⭐⭐⭐ | Atmosphere | — |
| 4 | Secret Character / Hidden Recruitment | ⭐⭐⭐⭐ | Emotion | — |
| 5 | Dialogue Choice System | ⭐⭐⭐⭐ | Narrative | — |
| 6 | NG+ Divine Currency (Badge of Heroism) | ⭐⭐⭐ | Replayability | 1, 2, 4 |
| 7 | Permadeath / Retreat Options | ⭐⭐⭐ | Stakes | — |
| 8 | Terrain/Weather Synergy | ⭐⭐⭐ | Gameplay | 2 |
| 9 | Post-Game Encyclopedia | ⭐⭐⭐ | Atmosphere | 1, 4 |
| 10 | Cross-System: Bond → Name Call → Support pipeline | ⭐⭐⭐⭐⭐ | Architecture | 1 |

---

## SPEC 01 — Support Conversation + Name Call Integration

### What It Is
Fire Emblem–style A/B/C/Rank support conversations that trigger between allied units in battle. The Name Call mechanic (CH10) becomes the emotional apex: a unit whose support rank is maxed speaks the protagonist's name at the critical moment, creating a unique payoff line.

### Design

**Support Ranks**: A → B → C → S (S = Name Call ready)
**Trigger**: Two allied units are deployed in the same battle and survive. After battle, 40% chance a support conversation triggers between any eligible pair.
**Unlock Condition**: Units must have fought together in ≥3 battles to unlock C, ≥6 for B, ≥10 for A.
**Name Call Integration**: At CH10 finale, if any ally has S-rank support with Rian, that ally's Name Call line replaces the generic ally name call. New line: `"[Ally Name]: Rian. I remember you. I remember everyone's name because of you."`

### Conversation Structure (per pair, per rank)
| Pair | C | B | A |
|------|---|---|---|
| Serin–Rian | Memory of the border trail | Serin's promise to stay | "I will carry your name forward" |
| Bran–Rian | Mutual distrust in the fortress | Shared watchfire | Bran finally uses Rian's first name |
| Tia–Rian | Greenwood survival | Forest counsel | Tia names Rian as kin |
| Enoch–Rian | Archive debate | Zero's meaning | Enoch acknowledges Zero was real |
| Kyle–Rian | Outer line testimony | Broken standard | Kyle's testimony includes Rian's name |
| Noah–Rian | Archive keeper bond | Final record | Noah reads Rian's name into the record |

### Files to Create/Modify
- `data/support_conversations.gd` (new data file — structured dictionary keyed by unit pair)
- `scripts/battle/bond_service.gd` — add `support_ranks: Dictionary`, `register_support_progress()`, `get_active_support_talk(pair_id) -> String`
- `scripts/campaign/campaign_controller.gd` — add post-battle support roll in `_commit_stage_rewards()`
- `scripts/battle/battle_result_screen.gd` — show "Support Rank Up!" notification when triggered
- `campaign_shell_dialogue_catalog.gd` — add support conversation text entries
- `data/stages/ch10_05_stage.tres` — already has `finale_name_call_ids`; extend to read S-rank support for name call override

### CHECKLIST

- [ ] Create `data/support_conversations.gd` with 6 unit pairs × 4 ranks (C, B, A, S) = 24 conversation entries
- [ ] Add `support_ranks: Dictionary` to `bond_service.gd` (key: `"rian_serin"`, value: rank int 0–4)
- [ ] Add `register_support_progress(unit_a, unit_b)` that increments rank and logs battle count
- [ ] Add `get_support_talk(unit_a, unit_b) -> String` that returns conversation text for current rank
- [ ] Add post-battle support roll in `campaign_controller.gd`: after `_commit_stage_rewards()`, roll 40% for each pair with ≥3 shared battles
- [ ] Wire support conversation display in `battle_result_screen.gd` as a new `"support"` section
- [ ] Add C/B/A conversation entries to `campaign_shell_dialogue_catalog.gd`
- [ ] Modify CH10 finale Name Call: `battle_controller.gd` checks `bond_service.get_support_rank(rian, ally) == 4` before using the S-rank Name Call line
- [ ] Write runner test `support_conversation_runner.gd`: simulate 3 battles with Serin+Rian, verify C-rank talk appears
- [ ] Write runner test for S-rank Name Call in CH10 finale

---

## SPEC 02 — Tactical Environmental Interactions + 3-Star Clear

### What It Is
Battlefields are no longer flat grids. Terrain features (pillars, high ground, fire, water) create tactical decisions. Each stage gets 1–3 hidden objectives that unlock a "3-Star Clear" rating, with bonus rewards on repeat playthroughs.

### Design

**Terrain Feature Types**:
| Type | Effect | Example |
|------|--------|---------|
| HighGround | +1 range, +20% defense for defender | Monastery elevated tiles |
| Destructible | Becomes rubble after attack, blocks movement | Wooden barricades |
| Fire | Spreads 1 tile/turn, damages 10 HP/turn | Battlefield braziers |
| Water | Slows movement to 1 tile/turn | Flooded dungeon floor |
| SacredGround | Heals 5 HP/turn for allied units | Chapel tiles |
| NarrowPass | Only 1 unit can occupy | Bridge, doorway |

**3-Star Clear System**:
- ⭐ = Battle clear (already exists)
- ⭐⭐ = Complete within turn limit
- ⭐⭐⭐ = Complete within turn limit AND all optional objectives

**Optional Objectives Per Stage**:
| Stage | Objective 1 | Objective 2 |
|-------|------------|-------------|
| CH01_05 | Defeat enemy commander with Serin | No ally casualties |
| CH02_05 | Lete must survive | Activate 3 traps |
| CH03_05 | Tia defeats enemy boss | No structures destroyed |
| CH04_05 | Ark survives the flooded section | Collect 2 research logs |
| CH05_05 | Defeat boss without Noah dying | Collect 3 ledger entries |
| CH06_05 | Valtor's civilian escapes | Reduce fort resistance to 0 |
| CH07_05 | Recruit Mira | Collect city seal |
| CH08_05 | Lete defects alive | No black-hound casualties |
| CH09A_05 | Kyle testifies | No allied casualties |
| CH09B_05 | Melkion's truth revealed | Noah survives |
| CH10_05 | All allies Name Called | No ally deaths |

**Reward Structure**:
- ⭐⭐⭐ Clear → +2 materials, bonus accessory, Badge of Heroism +1
- ⭐⭐ Clear → +1 material
- ⭐ Clear → standard reward

### Files to Create/Modify
- `scripts/data/stage_data.gd` — add `terrain_features: Array[Dictionary]`, `optional_objectives: Array[Dictionary]`, `star_rating: int`
- `data/stages/*.tres` — populate terrain_features and optional_objectives for all CH01–CH10 stages
- `scripts/battle/battle_controller.gd` — apply terrain effects in `_apply_damage_modifiers()`, `_execute_unit_turn()`
- `scripts/battle/battle_result_screen.gd` — display star rating earned
- `scripts/campaign/campaign_controller.gd` — accumulate star ratings, award bonuses in `_commit_stage_rewards()`
- `data/progression_data.gd` — add `stage_star_ratings: Dictionary` and `total_stars: int`

### CHECKLIST

- [ ] Add to `stage_data.gd`: `@export var terrain_features: Array[Dictionary]`, `@export var optional_objectives: Array[Dictionary]`, `@export var star_rating: int = 0`
- [ ] Add `@export var total_stars: int` to `progression_data.gd`
- [ ] Populate `terrain_features` for all 46 stage .tres files (work from CH01_01 outward)
- [ ] Implement `apply_terrain_effects()` in `battle_controller.gd`: water slows, fire spreads, high ground modifies defense
- [ ] Implement `check_optional_objectives()` called at battle end before victory condition
- [ ] Track `stage_star_ratings` in `progression_data.gd`, save/load with campaign save
- [ ] Modify `_commit_stage_rewards()` to grant +1–2 materials on ⭐⭐/⭐⭐⭐ clear
- [ ] Update `battle_result_screen.gd`: show star rating earned, total campaign stars
- [ ] Create `scripts/dev/three_star_runner.gd` to verify star calculation logic
- [ ] Verify all terrain effects render correctly (coordinate with visual team)

---

## SPEC 03 — War Council / Mission Briefing

### What It Is
Before every major battle (chapter boss stages, CH05_05 and up), a War Council screen appears showing the tactical situation, enemy composition preview, terrain map, and optional objectives. This creates the "before the storm" tension that makes battles feel consequential.

### Design

**Screen Layout**:
```
[CHAPTER 04 — SUNKEN MONASTERY]    [TURN LIMIT: 12]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENEMY INTEL          TERRAIN          OPTIONAL OBJECTIVES
• 3x Skirmisher      █ High Ground   ⭐ Survive with Ark
• 1x Basil (Boss)    ▓ Chapel        ⭐ Collect 2 Research Logs
  [Swimming: Slow]    ▒ Flooded      ⭐ No ally deaths
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PARTY COMPOSITION         MISSION BRIEF
Rian    | Serin         The monastery holds the last
Bran    | Tia          Ark research. Move fast.
[Locked: 2 slots]      [BRIEFING CONTINUES...]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[  DEPLOY  ]  [  INTEL  ]  [  ABORT  ]
```

**Content Per Chapter**:
| Stage | Intel Provided | Brief Tone |
|-------|---------------|-----------|
| CH01_05 | Enemy formation, terrain | "First real test" |
| CH02_05 | Bran join, Hardren layout | "Hardren waits" |
| CH03_05 | Tia allegiance, forest traps | "She'll watch you" |
| CH04_05 | Ark location, flooded zone | "Ark knows this place" |
| CH05_05 | Archive layout, Enoch role | "Zero's final stand" |
| CH06_05 | Valtor siege math, Ellyor route | "The machine is running" |
| CH07_05 | City gate layout, Mira/Neri | "Forgetting as policy" |
| CH08_05 | Black hound location, forest ruins | "Lete's last hunt" |
| CH09A_05 | Kyle outer line, root archive | "The line between memory and erasure" |
| CH09B_05 | Archive keeper, Melkion | "The editor watches" |
| CH10_05 | Karuon's tower, name anchor | "The final ascent" |

### Files to Create/Modify
- `scripts/campaign/campaign_state.gd` — add `MODE_BRIEFING: String = "briefing"`
- `scripts/campaign/campaign_controller.gd` — add `_enter_briefing_state()`, `_build_briefing_panel()`
- `scripts/campaign/campaign_panel.gd` — add briefing-specific panel layout
- `scenes/campaign/CampaignPanel.tscn` — add BriefingPanel node
- `scripts/campaign/campaign_shell_dialogue_catalog.gd` — add briefing text entries
- `scripts/battle/battle_controller.gd` — skip briefing if `stage.skip_briefing == true`

### CHECKLIST

- [ ] Add `MODE_BRIEFING` to `campaign_state.gd`
- [ ] Add `_enter_briefing_state()` in `campaign_controller.gd` triggered before chapter boss stages and CH05_05+
- [ ] Create briefing data structure in `campaign_shell_dialogue_catalog.gd`: `CH0X_BRIEFING_INTEL`, `CH0X_BRIEFING_TERRAIN`, `CH0X_BRIEFING_OBJECTIVES`
- [ ] Build briefing panel layout in `campaign_panel.gd` (or new BriefingPanel.tscn)
- [ ] Wire briefing "Deploy" button → `_enter_stage()` as normal
- [ ] Wire "Abort" button → return to camp
- [ ] Add "Intel" tab in briefing showing enemy AI patterns (if known from previous encounters)
- [ ] Write runner: `briefing_runner.gd` verifies all 11 briefing stages display without crash
- [ ] Integrate terrain preview from `stage_data.terrain_features` into briefing map view

---

## SPEC 04 — Secret Character / Hidden Recruitment

### What It Is
Three characters are hidden recruits, unlocked only through specific non-obvious actions. This rewards attentive players and creates "I can't believe I found that" moments.

### Design

**Hidden Characters**:

| Character | Unlock Condition | Story Context |
|-----------|---------------|---------------|
| **Lete** | In CH08_05, defeat Lete without killing her (reduce to 1 HP, she retreats). In CH08 camp after, she appears as ally. | The black hound who hunted Tia becomes an ally. |
| **Mira** | In CH07_05, before the boss fight, use the "Investgate Shrine" interactive object. Then during battle, have Tia defeat the boss. Mira joins after battle. | The city archivist who chose forgetting over truth. |
| **Melkion (post-corrupt)** | In CH09B_05, defeat Melkion while Noah is alive and has S-rank support. After the "truth rewrite" event, Melkion flips sides for 1 battle only. | He rewrites his own record. |

**Unlock Flow**:
```
CH08_05 battle → Lete HP ≤ threshold → Retreat event fires
→ CH08 camp → Lete joins roster (ally_lete)
→ Lete available for CH09 onward

CH07_05 → Investigate Shrine → Interactive object triggers flag
→ Tia defeats boss → Post-battle: Mira joins roster

CH09B_05 → Noah alive + S-rank with Rian
→ Melkion Phase 2 → "Truth Rewrite" event
→ Melkion flips → Joins for 1 battle → Leaves after CH10_01
```

### Files to Create/Modify
- `scripts/campaign/campaign_catalog.gd` — add `ally_lete`, `ally_mira`, `ally_melkion_ally` to unit catalog
- `data/units/ally_lete.tres`, `data/units/ally_mira.tres`, `data/units/ally_melkion_ally.tres` — create unit data for hidden characters
- `scripts/campaign/campaign_controller.gd` — add `_check_lete_retreat_unlock()`, `_check_mira_unlock()`, `_check_melkion_unlock()` called in stage resolution
- `scripts/battle/battle_controller.gd` — add HP threshold check for Lete retreat event
- `data/stages/ch07_05_stage.tres` — add interactive object `shrine_investigation` in stage data
- `scripts/battle/interactive_object_actor.gd` — add handler for `shrine_investigation` flag
- `campaign_shell_dialogue_catalog.gd` — add Lete/Mira/Melkion recruitment dialogue

### CHECKLIST

- [ ] Create `data/units/ally_lete.tres` with combat-appropriate stats (balanced between Kyle and Tia)
- [ ] Create `data/units/ally_mira.tres` with support/bias toward information and records
- [ ] Create `data/units/ally_melkion_ally.tres` with powerful but temporary (1 battle) profile
- [ ] Register all three in `campaign_catalog.gd` with `is_hidden_recruit: bool = true`
- [ ] Implement Lete retreat: `battle_controller.gd` detects HP ≤ 3 + retreat flag, fires `_check_lete_retreat_unlock()`
- [ ] Implement Mira shrine investigation: add `interactive_object` type `"shrine"` to `ch07_05_stage.tres`, add shrine handling in `interactive_object_actor.gd`, set `mira_unlocked = true` on use
- [ ] Implement Melkion truth flip: check `bond_service.get_support_rank(rian, noah) == 4` in `battle_controller.gd` during CH09B_05 Phase 2
- [ ] Add recruitment dialogue entries to `campaign_shell_dialogue_catalog.gd` for all three
- [ ] Update `_is_recruit_unlocked()` in `campaign_controller.gd` to return true for hidden characters when their unlock flag is set
- [ ] Write runner: `hidden_recruit_runner.gd` tests Lete/Mira/Melkion unlock paths

---

## SPEC 05 — Dialogue Choice System

### What It Is
At 5 critical junctures in the campaign, players face a binary choice that changes the next battle's conditions, enemy composition, or available characters. Choices are not "good or evil" but "which truth do you prioritize?"

### Design

**Choice Points**:

| Location | Choice | Effect A | Effect B |
|----------|--------|----------|---------|
| CH05 camp | "Save the ledgers or save Enoch?" | Loot: 5 research ledgers → bonus intel. Enoch wounded, -1 combat for CH06_01 | Save Enoch fully. Loot: 2 ledgers. Enoch fully operational CH06_01 |
| CH07 interlude | "Mira remembers everything — believe her or suspect manipulation?" | Mira fully joins. Neri becomes hostile in CH08 | Mira's testimony is doubted. Neri neutral. CH08 harder but more items |
| CH08 before boss | "Lete offers to switch sides — accept or reject?" | Lete joins early (full ally), enemy formation weakens | Lete stays enemy, harder CH08_05, but you get her exclusive item after defeating her |
| CH09A camp | "Kyle testifies publicly or privately to Noah?" | Public: Noah strength ×2 for CH09B, but Melkion knows Kyle's location | Private: Noah unchanged, Melkion unaware. Easier CH09B |
| CH10 before finale | "Name the tower after a fallen ally or after a principle?" | Name after Serin: All allies gain +10% attack for finale. Name after "The Nameless Tower": All allies gain +10% defense | Name after a principle: +1 Name Call count for free in finale |

### Files to Create/Modify
- `scripts/campaign/campaign_state.gd` — add `MODE_CHOICE: String = "choice"`
- `scripts/campaign/campaign_controller.gd` — add `_enter_choice_state()`, `CHOICE_POINT_STAGES: Array[StringName]` to gate when choices fire, `make_choice(option_id: String)` to apply effects
- `scripts/campaign/campaign_panel.gd` — add choice panel layout
- `scripts/campaign/campaign_shell_dialogue_catalog.gd` — add choice text and option descriptions
- `scripts/data/progression_data.gd` — add `choices_made: Array[String]` to track what player chose
- `data/stages/*.tres` — add `choice_point_id: StringName` to the 5 choice stages

### CHECKLIST

- [ ] Add `MODE_CHOICE` to `campaign_state.gd`
- [ ] Add `CHOICE_POINT_STAGES` array to `campaign_controller.gd` listing the 5 choice stage IDs
- [ ] Create `_enter_choice_state(stage_id)` and `_make_choice(option_id)` in `campaign_controller.gd`
- [ ] Add `choices_made: Array[String]` to `progression_data.gd`
- [ ] Build choice panel in `campaign_panel.gd`: shows choice text, two option buttons, choice consequence hints
- [ ] Add all 5×2 = 10 choice/option text entries to `campaign_shell_dialogue_catalog.gd`
- [ ] Implement choice consequence logic in `_make_choice()`:
  - CH05 ledger: modifies `CH06_STAGE_REWARD_LOG` and `enoch_hp_modifier`
  - CH07 Mira belief: modifies `mira_trust_level` and `neri_disposition`
  - CH08 Lete: modifies `ch08_05_stage.tres` enemy roster and `l alliance_unlocked`
  - CH09A testimony: modifies `noah_phase2_multiplier` and `melkion_awareness`
  - CH10 naming: modifies all ally unit base attack/defense for finale only
- [ ] Write runner: `choice_system_runner.gd` tests all 5 choice paths and verifies state changes

---

## SPEC 06 — NG+ Divine Currency (Badge of Heroism)

### What It Is
A persistent meta-progression currency earned by achieving 3-Star clears, hidden objectives, and secret recruitments. Persists across NG+ cycles. Spendable in future playthroughs for powerful starting advantages.

### Design

**Badge of Heroism** — earned, never spent except in NG+
| Source | Amount |
|--------|--------|
| ⭐⭐⭐ Stage Clear | +3 |
| ⭐⭐ Stage Clear | +1 |
| Secret Recruit (Lete/Mira/Melkion) | +5 each |
| Hidden Objective completed | +2 each |
| True Ending first clear | +10 |

**NG+ Shop** (accessible from title screen before starting):
| Item | Cost | Effect |
|------|-------|--------|
| Bond Anchor | 15 | All allies start with S-rank support with Rian |
| Veteran Squad | 10 | All allies start at level 5 |
| Iron Memory | 8 | All memory fragments from previous playthrough preserved |
| Lete's Bow | 12 | Unique weapon unlocked from start |
| Mira's Archive | 10 | All intel/briefing available from CH01 |
| Divine Blessing | 20 | One free Name Call in CH10 finale |

### Files to Create/Modify
- `scripts/data/progression_data.gd` — add `badges_of_heroism: int`, `earned_badges: Array[String]`
- `scripts/main.gd` — add `ng_plus_shop_items: Array[Dictionary]`, `purchase_ng_plus_item(item_id)`
- `scripts/ui/title_screen.gd` — add NG+ shop panel (shown when `badges_of_heroism > 0`)
- `scenes/ui/TitleScreen.tscn` — add NG+ shop button and panel
- `scripts/battle/battle_controller.gd` — apply NG+ bonuses to ally stats at battle start
- `scripts/battle/bond_service.gd` — apply `Bond Anchor` bonus to support ranks

### CHECKLIST

- [ ] Add `badges_of_heroism: int` and `earned_badges: Array[String]` to `progression_data.gd`
- [ ] Implement badge award in `campaign_controller.gd`: in `_commit_stage_rewards()`, calculate star rating and award badges
- [ ] Add secret recruitment badge awards in `_check_lete_retreat_unlock()`, `_check_mira_unlock()`, `_check_melkion_unlock()`
- [ ] Add `purchase_ng_plus_item(item_id)` in `main.gd` that deducts badges and sets persistent flags
- [ ] Create NG+ shop panel in `title_screen.gd`: lists all shop items with costs, grayed if unaffordable
- [ ] Implement all 6 NG+ shop item effects:
  - Bond Anchor: sets all support ranks to 4 in `bond_service.gd`
  - Veteran Squad: adds 4 levels to all allies in `unit_actor.gd`
  - Iron Memory: copies previous playthrough `recovered_fragment_ids` into new run
  - Lete's Bow: unlocks `weapon_lete_bow` at game start
  - Mira's Archive: sets `intel_unlocked` flags for all stages
  - Divine Blessing: sets `free_name_call = true` for CH10 finale
- [ ] Write runner: `ng_plus_badge_runner.gd` simulates a full ⭐⭐⭐ playthrough and verifies badge calculation

---

## SPEC 07 — Permadeath / Retreat Options

### What It Is
Losing a battle has three resolution paths, giving players agency over consequences. Units who fall in battle enter a "recovery" state rather than being permanently lost.

### Design

**When a battle is lost (all ally units defeated)**:

**Option A — Full Retreat**
- All ally units enter "Recovering" status for 2 chapters
- Recovering units cannot be deployed but do not leave permanently
- Camp recovery narrative plays: "They'll rejoin when the time comes"

**Option B — Sacrifice Protocol**
- Designate one unit to "Hold the line" — they are removed from roster permanently
- Remaining units return at full strength in next chapter
- Sacrifice triggers a unique memorial entry in the Encyclopedia

**Option C — Desperate Stand (only if 1 unit remains)**
- The last unit fights a solo 3-wave desperate battle
- Wave 1: 3 enemies, Wave 2: 5 enemies, Wave 3: Boss reinforcement
- Victory: full recovery, +2 Badges of Heroism
- Defeat: Full Retreat (Option A)

**Unit Death (real, permanent)**:
- Only occurs if player explicitly chooses Option B
- Or if a unit with S-rank support dies — that ally's death triggers a unique memorial scene

### Files to Create/Modify
- `scripts/data/progression_data.gd` — add `recovering_units: Array[String]`, `sacrificed_units: Array[String]`, `recover_chapter_count: int`
- `scripts/campaign/campaign_controller.gd` — add `_enter_retreat_state()`, `_apply_sacrifice()`, `_execute_desperate_stand()`
- `scripts/campaign/campaign_panel.gd` — add RetreatPanel layout
- `scripts/battle/battle_controller.gd` — detect all-ally-defeated condition, trigger retreat flow
- `scripts/battle/bond_service.gd` — check S-rank ally death → trigger memorial scene
- `scenes/battle/Unit.tscn` — add "Recovering" visual state overlay

### CHECKLIST

- [ ] Add `recovering_units`, `sacrificed_units`, `recover_chapter_count` to `progression_data.gd`
- [ ] Add `MODE_DEFEAT` to `campaign_state.gd`
- [ ] Implement `_enter_retreat_state()` in `campaign_controller.gd` triggered when `battle_controller.last_result == "defeat"`
- [ ] Build retreat panel: three option cards (Full Retreat / Sacrifice Protocol / Desperate Stand if eligible)
- [ ] Implement `_apply_sacrifice(unit_id)`: removes from roster permanently, triggers memorial entry
- [ ] Implement `_apply_recovery()`: adds to `recovering_units` for 2 chapters
- [ ] Implement desperate stand: spawns 3-wave reinforcement battle in `battle_controller.gd`
- [ ] In `bond_service.gd`, detect S-rank ally death → call `_trigger_memorial_scene()` in `campaign_controller.gd`
- [ ] Update roster display in camp panel: recovering units shown grayed with "Recovering (CH0X)" label
- [ ] Write runner: `retreat_runner.gd` tests all 3 retreat paths

---

## SPEC 08 — Terrain/Weather Synergy

### What It Is
Combines with SPEC 02. Terrain features interact with weather/time-of-day and unit abilities, creating emergent tactical depth. E.g., Fire terrain + strong wind = inferno that spreads across the map.

### Design

**Weather System** (per stage, 3 possible states):
| Weather | Effect | Combos With |
|---------|--------|-------------|
| Clear | No modifier | — |
| Rain | Water tiles double in size (+50% flooding), Fire extinguished, Thunder has 20% paralytic chance | Water + Fire = Steam (blocks vision) |
| Night | Ranged attacks -1 range, Stealth abilities activate, Sacred Ground healing ×2 | Night + Fire = Smoke (adjacent units blinded) |

**Synergy Reactions**:
| Combination | Result |
|------------|--------|
| Fire + Rain | Steam cloud: blocks line of sight for 3 turns |
| Fire + Night | Smoke spreads 2 tiles/turn, 5 HP damage |
| High Ground + Night | Defender gains +30% defense (ambush bonus) |
| Destructible + Fire | Chain reaction: destroys adjacent destructibles |
| Sacred Ground + Rain | Healing ×2 + cleanse 1 status effect |
| Water + Melkion's abilities | Melkion's "Truth Rewrite" gains +1 target |

### Files to Create/Modify
- `scripts/data/stage_data.gd` — add `weather_type: String` (clear/rain/night) and `terrain_synergies_enabled: bool`
- `data/stages/*.tres` — add weather_type for all stages (suggest: CH06_02 rain, CH09B_05 night, CH10_05 night)
- `scripts/battle/battle_controller.gd` — implement `_apply_weather_effects()`, `_apply_synergy_reactions()`
- `scripts/battle/battle_hud.gd` — show weather icon in HUD status bar
- `scripts/battle/combat_service.gd` — apply weather modifiers to damage/range calculation

### CHECKLIST

- [ ] Add `weather_type: String` and `terrain_synergies_enabled: bool` to `stage_data.gd`
- [ ] Assign weather to all 46 stage .tres files (pick 8–10 for non-clear)
- [ ] Implement `_apply_weather_effects()` in `battle_controller.gd` called at battle start and after each turn
- [ ] Implement `_apply_synergy_reactions()` triggered on terrain state change (fire spreads, water expands)
- [ ] Apply weather to damage calculation in `combat_service.gd`: range modifier, status chance modifier, terrain interaction
- [ ] Add weather icon (☀️/🌧️/🌙) to `battle_hud.gd` status display
- [ ] Write runner: `weather_system_runner.gd` tests all 5 synergy combinations

---

## SPEC 09 — Post-Game Encyclopedia

### What It Is
A browsable record of everything the player experienced: unit biographies, enemy lore entries, battle statistics, the story timeline, and a "Memorial Wall" for sacrificed units. Unlocked entries create collection satisfaction.

### Design

**Encyclopedia Sections**:

1. **Character Codex** — all recruited allies and enemies encountered
   - Entries unlock when unit is first recruited / first defeated
   - For allies: combat stats, support ranks, recruitment chapter, key quote
   - For enemies: combat stats, weakness, lore text, defeat count

2. **Battle Record** — statistics per stage
   - Turns taken, allies lost, optional objectives, star rating
   - Personal notes field (player can write memo for each stage)

3. **Story Timeline** — chronological view of events
   - Generated from: chapters completed, choices made, cutscenes seen
   - Shows "What you chose at this moment"

4. **Memorial Wall** — sacrificed units (SPEC 07 Option B)
   - Name, chapter sacrificed, player-written epitaph
   - Max 3 epitaph entries

5. **World Atlas** — map of Farland with visited locations
   - Shows chapter-by-chapter route taken
   - Unvisited locations shown grayed with "???"

### Files to Create/Modify
- `scripts/ui/encyclopedia_panel.gd` (new) — tabbed panel with Codex/Timeline/Memorial/Atlas
- `scenes/ui/encyclopedia_panel.tscn` (new) — scene with 4 tabs
- `scripts/data/progression_data.gd` — add `encyclopedia_entries: Dictionary`, `battle_records: Array[Dictionary]`, `epitaphs: Array[String]`
- `scripts/campaign/campaign_controller.gd` — populate encyclopedia entries on unit recruitment and enemy first defeat
- `scripts/battle/battle_result_screen.gd` — add "Open Encyclopedia" button and auto-populate battle record

### CHECKLIST

- [ ] Create `encyclopedia_panel.gd` with 4 tabs: Codex, Timeline, Memorial, Atlas
- [ ] Create `encyclopedia_panel.tscn` scene
- [ ] Add `encyclopedia_entries`, `battle_records`, `epitaphs` to `progression_data.gd`
- [ ] Populate unit entries in encyclopedia on recruitment and first enemy encounter
- [ ] Build chronological timeline from `chapters_completed` + `choices_made` flags
- [ ] Implement Memorial Wall: display sacrificed unit cards with epitaph input field
- [ ] Implement World Atlas: draw simplified map with visited chapter locations highlighted
- [ ] Add "Encyclopedia" button to camp HUD (mode == MODE_CAMP)
- [ ] Write runner: `encyclopedia_runner.gd` verifies all entry types populate

---

## SPEC 10 — Cross-System Pipeline: Bond → Support → Name Call → Encyclopedia

### What It Is
The architectural spine connecting every emotional system into one continuous pipeline. A player's journey from stranger to bonded战友 to Name Called ally to memorialized hero creates the arc that makes Farland unforgettable.

### Architecture

```
Battle (turns, co-op, survival)
    ↓
Bond Service (shared trauma = bond XP)
    ↓
Support Rank Progress (3 shared battles = C, 6 = B, 10 = A, S requires Name Call)
    ↓
Support Conversations (emotional context, inside-jokes, growing intimacy)
    ↓
Name Call (the moment of mutual recognition at CH10 finale)
    ↓
Encyclopedia Entry (the character's full arc in the codex)
    ↓
Memorial (if sacrificed: permanent place in the player's memory)
```

**Critical Hooks**:
- Support conversations reference specific battles the player fought ("Remember when we barely made it through the flooded monastery?")
- Name Call lines vary by support rank: C-rank = formal, B-rank = warm, A-rank = familiar, S-rank = the emotional apex line
- Encyclopedia entry for S-rank allies includes their support conversation history as "relationship timeline"

### Files to Create/Modify
- `scripts/battle/bond_service.gd` — make `bond_xp_earned` emit a signal `support_progress_updated`
- `scripts/campaign/campaign_controller.gd` — connect `support_progress_updated` → update support rank → check for Name Call eligibility
- `scripts/battle/battle_result_screen.gd` — pass conversation history to encyclopedia on campaign complete
- `scripts/data/progression_data.gd` — add `support_history: Array[Dictionary]` tracking all support conversations
- `scripts/ui/encyclopedia_panel.gd` — for S-rank allies, show support conversation history as timeline sub-section

### CHECKLIST

- [ ] Add `support_progress_updated.emit(pair_id, new_rank)` in `bond_service.gd`
- [ ] Connect signal in `campaign_controller.gd`: `bond_service.support_progress_updated.connect(_on_support_rank_increased)`
- [ ] Implement `_on_support_rank_increased(pair_id, new_rank)`: if new_rank >= 3, mark conversation available
- [ ] Track `support_history` in `progression_data.gd`: log every support conversation with `{pair, rank, chapter, stage_id}`
- [ ] Pass `support_history` to encyclopedia on campaign complete
- [ ] Vary Name Call lines in CH10 finale by support rank (read from `bond_service`)
- [ ] For S-rank allies in Encyclopedia Codex: show full support conversation history as "relationship timeline"
- [ ] Endgame summary screen: "Your closest bond was [Ally] — [rank] support, [N] battles together"
- [ ] Write runner: `cross_system_pipeline_runner.gd` walks a complete playthrough with Serin+Rian through all ranks and verifies the full pipeline fires correctly

---

## Implementation Priority Order

```
Phase 1 (Parallel — all independent):
  • SPEC 02 (terrain + stars) → enables SPEC 06, 08
  • SPEC 01 (support + name call) → core emotional pipeline
  • SPEC 03 (briefing) → atmosphere, no dependencies

Phase 2 (Depends on Phase 1):
  • SPEC 04 (hidden recruits) → needs SPEC 01 support conversation scaffold
  • SPEC 05 (choice system) → needs briefing + support scaffold
  • SPEC 08 (weather) → needs SPEC 02 terrain system

Phase 3 (Depends on Phase 1+2):
  • SPEC 06 (NG+ badges) → needs SPEC 02 (star ratings) + SPEC 04
  • SPEC 07 (permadeath) → needs SPEC 05 (choice) context
  • SPEC 09 (encyclopedia) → needs SPEC 01, 04, 07

Phase 4 (Final integration):
  • SPEC 10 (cross-system pipeline) → wires everything together
```

---

## Runner Coverage Map

| Feature | Runner |验证 기준 |
|---------|--------|---------|
| Support + Name Call | `support_namecall_pipeline_runner.gd` | S-rank Name Call line appears in CH10 |
| Terrain + Stars | `three_star_runner.gd` | Star rating calculated correctly per stage |
| War Briefing | `briefing_runner.gd` | All 11 briefing stages render |
| Hidden Recruits | `hidden_recruit_runner.gd` | Lete/Mira/Melkion unlock paths |
| Choice System | `choice_system_runner.gd` | All 5 choice paths + state changes |
| NG+ Badges | `ng_plus_badge_runner.gd` | Badge calculation, purchase, NG+ effect |
| Permadeath | `retreat_runner.gd` | All 3 retreat paths |
| Weather/Synergy | `weather_system_runner.gd` | All 5 synergy reactions |
| Encyclopedia | `encyclopedia_runner.gd` | Entry population, timeline generation |
| Cross-Pipeline | `cross_system_pipeline_runner.gd` | Full Serin+Rian arc from C to S |
