# Reference-Driven Fun Upgrade Spec

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task after the checklist is approved for execution.

**Goal:** Obsidian `05-Research`의 관련 게임 분석을 바탕으로 `잿빛의 기억 / Farland Tactics`의 재미 밀도를 높이는 전투·성장·UI·회상 시스템 업그레이드 스펙을 정의한다.

**Architecture:** 신규 대형 시스템을 한 번에 만들지 않고, 이미 존재하는 boss phase, telegraph, interactive object, progression, save/load, cutscene, camp, runner 구조 위에 얇게 얹는다. 우선순위는 “플레이어가 매 턴 더 명확한 선택을 하고, 성공했을 때 즉시 보상을 느끼는 것”이다.

**Tech Stack:** Godot 4.6, GDScript, existing headless runner suite, data-driven `.tres` stages/units/skills, `scripts/battle/*`, `scripts/campaign/*`, `scripts/dev/*`.

---

## 1. Source References

### 1.1 Directly relevant game notes

- Obsidian: `05-Research/CaseStudies/turn rpg/Farland Tactics.md`
  - Post-battle bonus EXP pool
  - Telegraphed map secrets
  - Narrative-driven accessibility
- Obsidian: `05-Research/CaseStudies/turn rpg/Tactics Ogre Reborn.md`
  - Variable turn order / action cost pressure
  - Anti-grind level capping
  - Branching narrative with meta rewind
- Obsidian: `05-Research/CaseStudies/Tactical RPG/Triangle Strategy and Fire Emblem.md`
  - Social/camp context as combat motivation
  - Toolkit unit design
  - Narrative branch pressure without uncontrolled content explosion
- Obsidian: `05-Research/CaseStudies/turn rpg/Into the Breach.md`
  - Full enemy intent telegraph
  - Simple AI, complex board situations
  - Clarity over coolness
- Obsidian: `05-Research/CaseStudies/turn rpg/Legend of Cao Cao.md`
  - Clear unit matchup and terrain constraints
  - Visible route/karma gauge
  - Contextual terrain magic
- Obsidian: `05-Research/CaseStudies/turn rpg/XCOM 2.md`
  - Cover destruction / certainty tools
  - Deep bench pressure
  - Emotional probability caution
- Obsidian: `05-Research/CaseStudies/turn rpg/Sea of Stars.md`
  - Lock break
  - Action-forcing constraints
  - Removal of attrition
- Obsidian: `05-Research/CaseStudies/turn rpg/Darkest Dungeon.md`
  - Stress as a resource
  - Gradient availability
  - Permanent consequence caution
- Obsidian: `05-Research/CaseStudies/Mobile Turn-Based/FGO FEH and Tactical Hits.md`
  - Mobile optimized grid
  - Pre-battle planning dominance
  - Narrative-first retention

### 1.2 Project fit constraints

From the project wiki:

- Game identity: single-player tactics RPG, mobile-first UX.
- Promise: short, readable tactical battles; dark memory/identity campaign; authored chapter identity; camp as narrative/progression hub.
- Avoid: gacha, stamina, pay-to-win, massive uncontrolled branching, grind-heavy true ending requirements.

---

## 2. Design Principles

1. **Clarity before complexity**
   - If a mechanic cannot be explained in one HUD card, do not implement it yet.

2. **Use existing surfaces first**
   - Prefer extending `BattleHUD`, boss telegraph, stage objectives, result screen, and dev runners over adding new UI scenes.

3. **Every new combat pressure needs a counterplay**
   - If a boss announces a dangerous action, the player must have at least one clear way to weaken, redirect, delay, or cancel it.

4. **Theme and mechanics must converge**
   - “기억 / 망각 / 이름” should not be only story vocabulary. It should appear as pressure, resource, reward, and recovery.

5. **No broad re-architecture in the first pass**
   - RT system, full branching, or procedural maps are not first-pass work. Start with local, testable upgrades.

---

## 3. Feature Specs

## Feature A — Boss Lock Break

**Reference:** Sea of Stars / Chained Echoes, Into the Breach, existing boss phase runners.

**Goal:** Boss battles become tactical puzzles where the player sees a dangerous upcoming action and can weaken/cancel it by satisfying clear conditions.

### A.1 Core loop

1. Boss enters a charged phase.
2. HUD shows a `Lock Break` card:
   - incoming action name
   - countdown
   - lock requirements
   - consequence if failed
   - reward if broken
3. Player uses specific action categories, units, status cleanses, or stage objects to break locks.
4. Broken lock downgrades or cancels the boss action.

### A.2 First-pass lock types

Use simple symbolic lock requirements:

- `strike`: hit boss with direct attack.
- `skill`: hit boss with any skill.
- `cleanse`: remove or reduce `oblivion`/memory pressure.
- `object`: resolve required stage object.
- `name`: use name-anchor/name-call style command.
- `guard`: use defensive/formation action if available.

Do not build an elemental system yet.

### A.3 Boss applications

#### CH06_05 Valgar

Theme: iron oath, fortification, line control.

- Charged action: `Iron Bastion Order`
- Countdown: 2 player phases
- Locks:
  - `strike` x1
  - `object` x1 via keep/battery/fortress object if present
- Failure: boss gains damage reduction and nearby enemies gain ATK.
- Break: boss loses fortify bonus for one turn; result popup notes “대장 명령이 끊겼다.”

#### CH07_05 Saria

Theme: name erasure, mind control, ritual city.

- Charged action: `Choir of Forgetting`
- Countdown: 2 player phases
- Locks:
  - `name` x1
  - `cleanse` x1
- Failure: applies oblivion/charm pressure to 1–2 allies.
- Break: prevents charm and reduces oblivion application.

#### CH08_05 Lete

Theme: black hound, pursuit, transfer gate.

- Charged action: `Hound Pincer`
- Countdown: 2 player phases
- Locks:
  - `object` x1 via `ch08_05_transfer_gate_latch`
  - `skill` x1
- Failure: Lete gains movement/attack tempo.
- Break: Lete loses chase pressure for one turn.

#### CH09B_05 Melkion

Theme: archive rewrite, false record.

- Charged action: `Archive Rewrite`
- Countdown: 2 player phases
- Locks:
  - `object` x1 via `ch09b_05_archive_lectern`
  - `name` or `skill` x1
- Failure: objective hint/result state becomes harsher, or memory pressure increases.
- Break: result screen shows “개정 기록이 흔들렸다.”

#### CH10_05 Karuon

Theme: final bell, anchor chain, name survival.

- Charged action: `Final Toll`
- Countdown: 3 player phases
- Locks:
  - `object` x1 via `ch10_05_anchor_chain`
  - `object` x1 via `ch10_05_bell_dais`
  - `name` x1
- Failure: heavy party pressure, no instant wipe.
- Break: final toll is downgraded; true-ending criteria surface gets positive feedback.

### A.4 Data model

Preferred minimal runtime dictionary, not a new Resource yet:

```gdscript
var boss_lock_state_by_unit: Dictionary = {
    boss_instance_id: {
        "action_id": &"final_toll",
        "display_name": "Final Toll",
        "countdown": 3,
        "locks_required": {"object": 2, "name": 1},
        "locks_progress": {"object": 0, "name": 0},
        "broken": false
    }
}
```

If this grows beyond first pass, promote to `scripts/data/boss_lock_data.gd` later.

### A.5 Required UI

- `BattleHUD` gets a compact lock card or extends existing transition card.
- Card text format:

```text
보스 예고: Final Toll (3턴)
해제 조건: 오브젝트 0/2 · 이름 0/1
실패 시: 전원 망각 압박
해제 시: 종소리 약화
```

### A.6 Required runners

- Create or extend: `scripts/dev/boss_lock_break_runner.gd`
- Extend: `scripts/dev/lategame_boss_pattern_runner.gd`
- Extend: `scripts/dev/ch06_ch10_boss_surface_runner.gd`

Acceptance:

- Each target boss can create lock state.
- Each lock type can increment progress.
- Broken lock changes next boss action outcome.
- HUD snapshot exposes lock text.

---

## Feature B — Enemy Intent Clarity Upgrade

**Reference:** Into the Breach, Pattern - Telegraphed Intents.

**Goal:** Player should know what dangerous enemy actions are coming and what can be done about them.

### B.1 Scope

First pass is not full AI preview. It is boss/high-risk action preview only.

Expose:

- actor name
- target unit or target tile if known
- damage/pressure estimate if available
- countdown
- counterplay hint

### B.2 HUD text examples

```text
다음 위협: Saria → Serin
효과: 망각 1 + 매혹 가능
대응: 이름 부름 또는 정화로 약화
```

```text
다음 위협: Karuon — Final Toll
효과: 전원 피해 + 망각 압박
대응: Anchor Chain / Bell Dais / Name Anchor
```

### B.3 Implementation constraints

- Use existing `transition_reason_label`, objective hint label, or a new small panel only if necessary.
- Avoid cluttering every enemy unit with icons in first pass.
- Boss and elite actions first.

### B.4 Acceptance

- Boss lock runner can assert readable intent text.
- No text overflow in headless HUD snapshot.
- Existing boss runners still pass.

---

## Feature C — Memory / Oblivion as Combat Resource

**Reference:** Darkest Dungeon stress, project memory/identity theme.

**Goal:** `oblivion` becomes a readable tactical pressure with recovery and risk/reward, not just a hidden status.

### C.1 First-pass rule

Keep it simple:

- 0 stack: normal.
- 1 stack: warning state; HUD shows affected unit.
- 2 stacks: one tactical penalty or skill restriction.
- 3 stacks: severe but recoverable pressure; never surprise-kill.

### C.2 Recovery tools

- name-call command reduces or blocks oblivion.
- stage object can reduce party pressure on specific maps.
- camp/result screen records who carried memory pressure.

### C.3 Optional risk/reward

For later pass only:

- Some memory skills become stronger at 1–2 oblivion stacks.
- Do not add this until baseline clarity is complete.

### C.4 Acceptance

- Status runner verifies stack thresholds.
- HUD shows unit pressure state.
- Ending criteria runner still passes.
- No hidden fail state is introduced.

---

## Feature D — Pre-Battle Planning Upgrade

**Reference:** FEH, Brown Dust, XCOM 2.

**Goal:** Before battle starts, deployment is a meaningful tactical decision, not just a roster picker.

### D.1 First-pass scope

Use briefing panel. Do not create a new scene yet.

Add to briefing:

- primary threat summary
- recommended formation hint
- first-turn danger note
- useful unit/skill hint

### D.2 Example briefing text

```text
전장 위협: 동쪽 궁병선이 첫 턴 후열을 노린다.
배치 힌트: 방패 유닛을 중앙 전열에 두고, 정화 계열은 후열에 둔다.
상호작용: 서쪽 장치를 먼저 해결하면 보스 압박이 약해진다.
```

### D.3 Acceptance

- Existing briefing runners can assert threat text.
- CH10_05 briefing still advances into battle.
- Save/load and shell runners remain green.

---

## Feature E — Bonus EXP / Result Reward Upgrade

**Reference:** Farland Tactics, Tactics Ogre.

**Goal:** Post-battle reward screen should make player feel their tactical choices mattered and help underused units catch up.

### E.1 First-pass result categories

Show simple result tags:

- MVP
- Protected ally
- Resolved object
- Broke boss lock
- Used name call
- Cleansed oblivion

### E.2 Bonus pool behavior

Existing bonus EXP pool remains.

Add display/recommendation only first:

- “추천 보너스 대상: 뒤처진 유닛”
- “기억 보상: 이름을 지킨 전투”

Manual allocation can be later if current result flow is not ready.

### E.3 Acceptance

- `battle_result_runner.gd` can assert new tags.
- Existing bonus EXP distribution tests remain green.

---

## Feature F — Unit Matchup / Terrain Identity Surface

**Reference:** Legend of Cao Cao, Langrisser Mobile.

**Goal:** Map identity and unit roles become more legible through simple matchup/terrain hints.

### F.1 First-pass scope

No full damage formula overhaul.

Add surface-level readability:

- role glyph / unit type label
- terrain hint in objective or HUD
- chapter-specific terrain rule copy

### F.2 Examples

- Forest: “궁병/은신 계열이 유리.”
- Flooded monastery: “수로는 이동을 늦추고 정화 장치를 중요하게 만든다.”
- Archive: “기록 장치는 망각 압박을 줄인다.”
- Final tower: “Anchor Chain과 Bell Dais가 최종 압박을 약화한다.”

### F.3 Acceptance

- No damage formula changes in first pass.
- HUD/briefing/objective text clarifies map identity.

---

## Feature G — Recall Battles / Memory Revisit

**Reference:** Tactics Ogre World Tarot, existing recall/hunt runners.

**Goal:** Player can revisit major boss memories without a full branch explosion.

### G.1 First-pass scope

Use existing recall/hunt surfaces if available.

Add “memory trial” entries for:

- Basil
- Saria
- Lete
- Melkion
- Karuon

### G.2 Reward model

- no mandatory grind
- cosmetic/record/review reward first
- optional small resource bonus later

### G.3 Acceptance

- Recall runner loads at least one memory trial.
- No main campaign progression corruption.
- Save/load still passes.

---

## Feature H — Battle UI Command Shortcuts

**Reference:** UI as a Thematic Weapon, Persona 5 style command immediacy.

**Goal:** Reduce repeated menu friction in short mobile-first battles.

### H.1 First-pass scope

Expose shortcut labels and input hints; do not redesign the full input model yet.

Suggested command surface:

- Attack
- Skill
- Wait
- Guard / Name Anchor
- Interact, when adjacent to object

### H.2 Acceptance

- HUD snapshot exposes selected unit command hints.
- Manual input runner can still click/select normally.
- No controller-only dependency.

---

## 4. Priority Order

### P0 — Highest impact, lowest rework

1. Feature A — Boss Lock Break
2. Feature B — Enemy Intent Clarity
3. Feature C — Memory / Oblivion clarity

### P1 — Strong UX and progression payoff

4. Feature D — Pre-Battle Planning
5. Feature E — Bonus EXP / Result Reward
6. Feature F — Unit/Terrain identity surface

### P2 — Retention and polish

7. Feature G — Recall Battles
8. Feature H — Battle UI Command Shortcuts

---

## 5. Non-Goals

Do not implement in this wave:

- full RT/initiative rework
- full procedural maps
- broad route branching with unique stages
- permadeath or long recovery injury system
- gacha/live-service mechanics
- new art pipeline requirements
- complex elemental surface simulation

---

## 6. Global Verification Gate

After each implementation slice, run the smallest relevant runner first, then the final gate if core behavior changed.

Minimum final gate command:

```bash
python3 /tmp/tactics_final_gate.py
```

Expected:

```text
TOTAL=37 PASS=37 FAIL=0
```

Save/load runners must be serial because `user://` save slots can race in parallel.
