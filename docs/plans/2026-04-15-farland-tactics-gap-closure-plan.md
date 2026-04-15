# Farland Tactics Gap Closure Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Turn the Farland Tactics comparison analysis for **잿빛의 기억** into small, runnable, repo-grounded vertical slices that materially improve battle feedback, progression readability, save/load usability, tactical depth, and camp-facing presentation.

**Architecture:** Keep the current ownership split intact: `BattleController` remains the runtime battle orchestrator, `ProgressionService` remains the campaign meta-state owner, and `CampaignController`/`CampController` remain shell-flow coordinators. Prefer runner-backed vertical slices and schema fixes before new systems, and treat true XP/leveling as explicit new work rather than hidden "polish."

**Tech Stack:** Godot 4.6, GDScript, Resource-driven data, SceneTree headless runners, runnable gates in `docs/milestone_runnable_gates.md`

---

## 1. Purpose

This document converts the Farland Tactics gap analysis into an execution plan that matches the current codebase.

The intent is **not** to broadly "make the game better." The intent is to close the highest-value gaps in a sequence that:

1. keeps the repo runnable after every slice,
2. builds on systems already present in the repo,
3. exposes progression and payoff to the player more clearly, and
4. defers truly new systems until the existing shell is fully leveraged.

---

## 2. Repo-Grounded Starting Point

### 2.1 What already exists and should be reused

- `scripts/data/progression_data.gd`
  - already owns `burden`, `trust`, `recovered_fragments`, `ending_tendency`, and `unlocked_commands`
- `scripts/battle/progression_service.gd`
  - already applies Burden/Trust deltas, recovers fragments, and unlocks commands from fragment ids
- `scripts/battle/bond_service.gd`
  - already owns companion bond levels and support-attack eligibility
- `scripts/data/stage_data.gd`
  - already owns terrain metadata, objective fields, and start/clear cutscene ids
- `scripts/battle/save_service.gd`
  - already persists `ProgressionData` and writes sidecar JSON metadata
- `scripts/ui/save_load_panel.gd`
  - already renders slot cards and emits save/load/delete signals
- `scripts/battle/battle_hud.gd`
  - already owns selection summary, transition reason copy, inventory overlay, and a `result_popup`
- `scripts/battle/unit_actor.gd`
  - already owns damage flash, token visuals, terrain badge, and defeat handling
- `scripts/battle/ai_service.gd`
  - already has a deterministic nearest-target baseline with legality-aware pathing
- `scripts/main.gd`
  - already wires title, defeat, battle, save/load, and campaign mode BGM state
- `scripts/campaign/campaign_controller.gd`
  - already owns chapter/stage reward logs, memory/evidence/letter records, and camp handoff data

### 2.2 Real mismatches that should be fixed first

#### A. Fragment id mismatch

- `ProgressionService.FRAGMENT_COMMAND_UNLOCKS` uses ids like `ch01_fragment`
- existing victory/progression flows are already chapter-structured, but the plan must verify that the emitted fragment ids match unlock expectations exactly

**Implication:** progression visibility work should start only after fragment recovery and command unlock contracts are deterministic.

#### B. Save slot metadata mismatch

- `SaveLoadPanel` expects slot-card-safe metadata such as `exists`, `chapter`, `burden`, `trust`, and `saved_at`
- `SaveService._write_sidecar()` currently serializes `ProgressionData.to_debug_dict()` plus `saved_at`

**Implication:** save/load UX polish should begin with the data contract, not with UI cosmetics.

#### C. "레벨업" is not a current system

There is no real per-unit XP/level system in the repo today.

That means the phrase **"기억 복원 레벨업"** currently has two valid interpretations:

1. **Repo-native interpretation (recommended first):** use Burden/Trust/fragment recovery as the player-facing memory-restoration progression layer.
2. **Explicit new-system interpretation:** add unit XP/level/stat growth as a separate system after current progression, result, and shell surfaces are stable.

This plan assumes **(1) first**, then reserves true XP/leveling as optional Sprint 7 new work.

---

## 3. Quality Target

The Farland comparison highlighted four quality axes:

- combat readability,
- progression payoff,
- narrative density in the loop,
- presentation.

This plan closes those gaps in this order:

1. **Contracts and visibility fixes**
2. **Battle-result and save/load loop completion**
3. **Memory-restoration progression surfacing**
4. **Unlocks and tactical depth**
5. **Flavor and visual polish**

The reason for this order is simple: the repo already has the underlying systems for steps 1-4 in partial form, so the fastest quality gain comes from surfacing and integrating them, not inventing new mechanics immediately.

---

## 4. Planning Principles

### 4.1 Vertical slices only

Do not do a giant "progression overhaul" branch.

Each sprint must deliver something the player can perceive:

- a clearer result screen,
- a real save/load entry point,
- a visible memory-restoration summary,
- a more tactical enemy turn,
- a more legible bond/support payoff.

### 4.2 TDD / runner-first rhythm

Every task in this document follows the same loop:

1. Write or extend a failing runner.
2. Run it and confirm failure.
3. Make the smallest implementation change.
4. Re-run the sprint runner and the affected smoke gate.
5. Commit atomically.

### 4.3 UI mirrors, services decide

Maintain the repo rule already expressed in `docs/plans/2026-04-12-systems-combat-progression-design.md`:

- battle-critical rules stay in runtime services/controllers,
- campaign progression stays in progression/campaign services,
- UI reads state and presents it, but does not own gameplay authority.

### 4.4 Preserve runnable gates

After every sprint, keep these green:

- `bash scripts/dev/check_runnable_gate0.sh`
- `godot4 --headless --path . -s scripts/dev/m1_playtest_runner.gd`
- sprint-specific runners added by this plan

---

## 5. Milestone Alignment

This work should move the project toward existing runnable gates rather than invent a second quality framework.

| Gate | Relevance to this plan |
|---|---|
| Gate 0 | Every sprint must keep scene/resource/script integrity intact |
| Gate 1 | Battle feedback and result handoff must preserve the core battle loop |
| Gate 1.5 | Result/camp/save work must preserve campaign shell glue |
| Gate 2 | AI and readability work should move the game closer to tactical depth |

---

## 6. Sprint Overview

| Sprint | Theme | Why now |
|---|---|---|
| Sprint 0 | Contracts and schema fixes | Removes real repo mismatches before visible work |
| Sprint 1 | Battle feedback and result handoff | Fastest quality gain with current systems |
| Sprint 2 | Save/load flow polish | Makes the RPG loop feel real, not backend-only |
| Sprint 3 | Memory-restoration progression surface | Exposes the existing Burden/Trust/fragment loop to the player |
| Sprint 4 | Unlock surface and command visibility | Turns hidden progression into perceived growth |
| Sprint 5 | AI depth and bond synergy clarity | Adds tactical depth after contracts are stable |
| Sprint 6 | Accessory flavor and presentation polish | Late-stage payoff once systems are legible |
| Sprint 7 (optional) | True XP/leveling | Explicit new work only if still desired |

---

## 7. Sprint 0 — Contracts and Schema Fixes

**Goal:** establish safe rails for progression and save/load before adding new player-facing surfaces.

### Task 0-A: Add a progression handoff contract runner

**Files:**
- Create: `scripts/dev/farland_progression_handoff_runner.gd`
- Modify: `scripts/battle/battle_controller.gd`
- Modify: `scripts/battle/progression_service.gd`
- Test: `scripts/dev/farland_progression_handoff_runner.gd`

**Step 1: Write the failing test**

Create a runner that asserts:

- stage clear emits a deterministic fragment recovery event
- fragment id and command unlock mapping are consistent
- clear-cutscene handoff still occurs
- `battle_finished` victory flow still resolves

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path . -s scripts/dev/farland_progression_handoff_runner.gd`

Expected: FAIL on at least one progression handoff assertion before fixes.

**Step 3: Write minimal implementation**

Make fragment-id mapping deterministic and chapter-aware without moving progression authority out of `ProgressionService`.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path . -s scripts/dev/farland_progression_handoff_runner.gd`

Expected: PASS

### Task 0-B: Fix save slot metadata contract

**Files:**
- Modify: `scripts/battle/save_service.gd`
- Modify: `scripts/ui/save_load_panel.gd`
- Test: `scripts/dev/save_load_runner.gd`
- Test: `scripts/dev/ui_screens_runner.gd`

**Step 1: Write the failing test**

Extend save/load coverage so slot cards require:

- `exists`
- `chapter`
- `burden`
- `trust`
- `ending_tendency`
- `saved_at`

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path . -s scripts/dev/save_load_runner.gd`

Expected: FAIL on slot metadata shape.

**Step 3: Write minimal implementation**

Adjust the sidecar schema and panel expectations so the UI reads exactly what the save layer produces.

**Step 4: Run test to verify it passes**

Run:

- `godot4 --headless --path . -s scripts/dev/save_load_runner.gd`
- `godot4 --headless --path . -s scripts/dev/ui_screens_runner.gd`

Expected: PASS

### Sprint 0 Checklist

- [ ] `farland_progression_handoff_runner.gd` added
- [ ] Fragment ids and unlock ids reconciled
- [ ] Save sidecar includes slot-card-safe metadata
- [ ] `SaveLoadPanel` reads the real slot schema
- [ ] Gate 0 PASS
- [ ] Progression/save/load runners PASS

---

## 8. Sprint 1 — Battle Feedback and Result Handoff

**Goal:** replace the current bare result surface with a real battle-to-camp payoff summary.

### Task 1-A: Expand the battle result surface

**Files:**
- Modify: `scripts/battle/battle_hud.gd`
- Modify: `scripts/battle/battle_controller.gd`
- Modify: `scenes/battle/BattleHUD.tscn`
- Test: `scripts/dev/battle_result_runner.gd`

**Step 1: Write the failing test**

Add a runner that asserts a victory result can expose:

- objective outcome
- recovered memory/evidence/letter entries
- fragment/command unlock summary
- burden/trust delta summary if affected by the stage

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path . -s scripts/dev/battle_result_runner.gd`

Expected: FAIL because only minimal result UI exists today.

**Step 3: Write minimal implementation**

Extend the existing HUD/result flow first. Do not add a separate full-screen scene unless the existing `BattleHUD` surface becomes clearly unworkable.

**Step 4: Run test to verify it passes**

Run:

- `godot4 --headless --path . -s scripts/dev/battle_result_runner.gd`
- `godot4 --headless --path . -s scripts/dev/m1_playtest_runner.gd`

Expected: PASS

### Task 1-B: Improve in-battle readability without changing authority

**Files:**
- Modify: `scripts/battle/battle_hud.gd`
- Modify: `scripts/battle/unit_actor.gd`
- Modify: `scripts/battle/battle_controller.gd`
- Test: `scripts/dev/m3_ui_runner.gd`

**Step 1: Write the failing test**

Extend UI coverage to assert more readable feedback for:

- support attack resolution
- status application resolution
- objective/interaction result copy
- result and transition visibility on compact/mobile layouts

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path . -s scripts/dev/m3_ui_runner.gd`

Expected: FAIL on at least one readability assertion.

**Step 3: Write minimal implementation**

Use the current HUD transition-reason and selection-summary surfaces before adding new widgets.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path . -s scripts/dev/m3_ui_runner.gd`

Expected: PASS

### Sprint 1 Checklist

- [ ] `battle_result_runner.gd` added
- [ ] Result summary includes rewards and progression-facing outputs
- [ ] Existing `BattleHUD` remains mobile-readable
- [ ] Support/status/objective readability improved
- [ ] Gate 0 PASS
- [ ] `m1_playtest_runner.gd` PASS
- [ ] `m3_ui_runner.gd` PASS

---

## 9. Sprint 2 — Save/Load Flow Polish

**Goal:** make save/load feel like a real SRPG ritual instead of a hidden service.

### Task 2-A: Add real camp-facing save/load entry points

**Files:**
- Modify: `scripts/main.gd`
- Modify: `scripts/campaign/campaign_controller.gd`
- Modify: `scripts/campaign/campaign_panel.gd`
- Modify: `scripts/ui/save_load_panel.gd`
- Test: `scripts/dev/save_load_runner.gd`
- Test: `scripts/dev/ui_screens_runner.gd`

**Step 1: Write the failing test**

Add or extend runner assertions so the player can:

- open save mode from a real camp-facing flow
- open load mode from title via the actual panel
- preserve autosave behavior and manual slots

**Step 2: Run test to verify it fails**

Run:

- `godot4 --headless --path . -s scripts/dev/save_load_runner.gd`
- `godot4 --headless --path . -s scripts/dev/ui_screens_runner.gd`

Expected: FAIL on panel entry-point flow.

**Step 3: Write minimal implementation**

Keep autosave slot behavior intact. Prefer wiring through the existing `CampaignPanel`/main shell before inventing new camp-only scenes.

**Step 4: Run test to verify it passes**

Run the same two runners again.

Expected: PASS

### Task 2-B: Polish slot presentation and deletion safety

**Files:**
- Modify: `scripts/battle/save_service.gd`
- Modify: `scripts/ui/save_load_panel.gd`
- Test: `scripts/dev/save_load_runner.gd`

**Step 1: Write the failing test**

Require consistent display of:

- chapter summary
- burden/trust snapshot
- ending tendency
- timestamp
- delete-confirmation behavior if absent

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path . -s scripts/dev/save_load_runner.gd`

Expected: FAIL on presentation or deletion safety.

**Step 3: Write minimal implementation**

Keep slot cards deterministic and driven by `peek_slot()`.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path . -s scripts/dev/save_load_runner.gd`

Expected: PASS

### Sprint 2 Checklist

- [ ] Save panel reachable from camp-facing flow
- [ ] Load panel reachable from title via actual panel flow
- [ ] Slot cards consistently show summary metadata
- [ ] Delete flow is safe and explicit
- [ ] Gate 0 PASS
- [ ] Save/load UI runners PASS

---

## 10. Sprint 3 — Memory-Restoration Progression Surface

**Goal:** turn existing Burden/Trust/fragment progression into a player-facing memory-restoration loop.

### Task 3-A: Surface progression in camp and campaign summaries

**Files:**
- Modify: `scripts/camp/camp_controller.gd`
- Modify: `scripts/data/camp_data.gd`
- Modify: `scripts/campaign/campaign_controller.gd`
- Modify: `scripts/campaign/campaign_panel.gd`
- Test: `scripts/dev/camp_runner.gd`
- Test: `scripts/dev/m3_ui_runner.gd`

**Step 1: Write the failing test**

Add assertions so camp/campaign summaries expose:

- current burden/trust bands
- recovered fragments count or list
- newly logged memory/evidence/letter records tied to the last stage

**Step 2: Run test to verify it fails**

Run:

- `godot4 --headless --path . -s scripts/dev/camp_runner.gd`
- `godot4 --headless --path . -s scripts/dev/m3_ui_runner.gd`

Expected: FAIL on progression visibility.

**Step 3: Write minimal implementation**

Use the data that already exists in `CampaignController` reward/memory/evidence/letter logs before introducing a new meta data model.

**Step 4: Run test to verify it passes**

Run the same two runners again.

Expected: PASS

### Task 3-B: Ensure result-to-record handoff integrity

**Files:**
- Modify: `scripts/battle/battle_controller.gd`
- Modify: `scripts/campaign/campaign_controller.gd`
- Test: `scripts/dev/farland_progression_handoff_runner.gd`

**Step 1: Write the failing test**

Require that battle result, camp record lists, and autosave all reflect the same post-stage state without duplication.

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path . -s scripts/dev/farland_progression_handoff_runner.gd`

Expected: FAIL on at least one duplicate or missing handoff condition.

**Step 3: Write minimal implementation**

Fix the state handoff boundary rather than adding one-off UI-only patches.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path . -s scripts/dev/farland_progression_handoff_runner.gd`

Expected: PASS

### Sprint 3 Checklist

- [ ] Camp and campaign surfaces show Burden/Trust/fragment state
- [ ] Result summary and camp records show the same post-stage truth
- [ ] No duplicate memory/evidence/letter entries across handoff
- [ ] Gate 0 PASS
- [ ] Camp/progression runners PASS

---

## 11. Sprint 4 — Unlock Surface and Command Visibility

**Goal:** make progression feel like growth by surfacing unlock state, not just storing it.

**Important:** this sprint should still be built on top of the existing fragment + Burden/Trust meta loop. Do not secretly convert it into a full XP system.

### Task 4-A: Expose unlock visibility through player-facing flows

**Files:**
- Modify: `scripts/battle/progression_service.gd`
- Modify: `scripts/data/progression_data.gd`
- Modify: `scripts/battle/battle_controller.gd`
- Modify: `scripts/battle/battle_hud.gd`
- Modify: `scripts/campaign/campaign_panel.gd`
- Test: `scripts/dev/command_unlock_runner.gd`
- Test: `scripts/dev/m4_progression_runner.gd`

**Step 1: Write the failing test**

Add assertions so newly unlocked commands or progression states are visible through:

- battle result summary
- camp/campaign summary surfaces
- progression runner snapshots

**Step 2: Run test to verify it fails**

Run:

- `godot4 --headless --path . -s scripts/dev/command_unlock_runner.gd`
- `godot4 --headless --path . -s scripts/dev/m4_progression_runner.gd`

Expected: FAIL on visibility or schema coverage.

**Step 3: Write minimal implementation**

Expose unlock state in a read-friendly way without relocating unlock authority from `ProgressionService`.

**Step 4: Run test to verify it passes**

Run the same two runners again.

Expected: PASS

### Task 4-B: Lock the interpretation of "memory restoration leveling"

**Files:**
- Modify: this plan or a follow-up plan only if scope changes
- No gameplay files unless true XP is explicitly approved

**Decision rule:**

- If current progression surfacing satisfies the design goal, stop here.
- If true per-unit leveling is still required, spin it out into Sprint 7 as explicit new work.

### Sprint 4 Checklist

- [ ] Unlock state is visible in result/camp/progression surfaces
- [ ] Fragment-gated and Burden/Trust-gated outputs are clearly distinguished
- [ ] No hidden full-XP system added by accident
- [ ] Gate 0 PASS
- [ ] Unlock/progression runners PASS

---

## 12. Sprint 5 — AI Depth and Bond Synergy Clarity

**Goal:** improve tactical depth with existing system hooks rather than rewriting battle rules from scratch.

### Task 5-A: Add deterministic threat-aware AI scoring

**Files:**
- Modify: `scripts/battle/ai_service.gd`
- Modify: `scripts/battle/battle_controller.gd` only if needed for explicit fallback/reporting
- Test: `scripts/dev/ai_depth_runner.gd`
- Test: `scripts/dev/m1_core_loop_contract_runner.gd`

**Step 1: Write the failing test**

Require that enemy AI:

- preserves legal movement/action guarantees
- uses a deterministic scoring model more meaningful than nearest-target-only
- retains explicit wait/fallback behavior when no legal plan exists

**Step 2: Run test to verify it fails**

Run:

- `godot4 --headless --path . -s scripts/dev/ai_depth_runner.gd`
- `godot4 --headless --path . -s scripts/dev/m1_core_loop_contract_runner.gd`

Expected: FAIL on scoring behavior while legality remains enforced.

**Step 3: Write minimal implementation**

Upgrade plan scoring first; do not rework the entire phase machine.

**Step 4: Run test to verify it passes**

Run the same two runners again.

Expected: PASS

### Task 5-B: Surface bond/support payoff more clearly

**Files:**
- Modify: `scripts/battle/bond_service.gd`
- Modify: `scripts/battle/battle_controller.gd`
- Modify: `scripts/battle/battle_hud.gd`
- Test: `scripts/dev/bond_runner.gd`

**Step 1: Write the failing test**

Require support-attack flow to expose clearer feedback in battle and result summaries.

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path . -s scripts/dev/bond_runner.gd`

Expected: FAIL on clarity or missing output.

**Step 3: Write minimal implementation**

Leverage existing support attack rules before adding new bond mechanics.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path . -s scripts/dev/bond_runner.gd`

Expected: PASS

### Sprint 5 Checklist

- [ ] `ai_depth_runner.gd` added
- [ ] AI remains legal and becomes more tactically expressive
- [ ] Support-attack feedback is clearer in HUD/result flows
- [ ] Gate 0 PASS
- [ ] AI/bond runners PASS

---

## 13. Sprint 6 — Accessory Flavor and Presentation Polish

**Goal:** improve emotional density and SRPG identity after the systems loop is already visible.

### Task 6-A: Upgrade accessory flavor text and surfaces

**Files:**
- Modify: `data/accessories/*.tres`
- Modify: `scripts/campaign/campaign_controller.gd`
- Modify: `scripts/campaign/campaign_panel.gd`
- Test: `scripts/dev/lategame_accessory_runner.gd`

**Step 1: Write the failing test**

Add assertions so accessory summaries can be surfaced in camp/campaign-facing views without missing or malformed data.

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path . -s scripts/dev/lategame_accessory_runner.gd`

Expected: FAIL on at least one missing or unexposed summary path.

**Step 3: Write minimal implementation**

Normalize flavor text by chapter/theme, but do not alter equip rules or stat behavior.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path . -s scripts/dev/lategame_accessory_runner.gd`

Expected: PASS

### Task 6-B: Final HUD/result presentation tightening

**Files:**
- Modify: `scripts/battle/battle_hud.gd`
- Modify: `scripts/battle/unit_actor.gd`
- Test: `scripts/dev/m3_ui_runner.gd`

**Step 1: Write the failing test**

Require cleaner hierarchy and readability for:

- status badges
- result summary emphasis
- support-attack feedback
- compact layout behavior

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path . -s scripts/dev/m3_ui_runner.gd`

Expected: FAIL on one or more readability assertions.

**Step 3: Write minimal implementation**

Tighten the current surfaces rather than re-skinning the whole UI theme in the same sprint.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path . -s scripts/dev/m3_ui_runner.gd`

Expected: PASS

### Sprint 6 Checklist

- [ ] Accessory summaries are consistent and surfaced in player-facing flows
- [ ] HUD/result hierarchy is cleaner
- [ ] Mobile readability remains intact
- [ ] Gate 0 PASS
- [ ] Accessory/UI runners PASS

---

## 14. Sprint 7 (Optional) — True XP / Leveling System

**Goal:** add actual per-unit leveling only if the repo-native progression surface still feels insufficient.

**Status:** explicit new work. Do not begin this sprint until Sprints 0-6 are done or consciously deprioritized.

### Candidate scope

- `scripts/data/unit_data.gd` or a new runtime/unit progression model gets explicit level/exp fields
- battle rewards gain exp distribution rules
- result screen gains exp/level-up display
- unlocks are reconciled with, not duplicated by, existing Burden/Trust/fragment systems

### Exit condition for greenlighting Sprint 7

- current Burden/Trust/fragment progression has been surfaced and playtested
- result/camp/save loop feels complete
- the team still believes missing per-unit growth is the main remaining Farland gap

### Sprint 7 Checklist

- [ ] Scope approved explicitly as new work
- [ ] Interaction with existing progression systems defined before code begins
- [ ] Dedicated plan written before implementation

---

## 15. Global Checklist

### Core dependency chain

- [ ] Fragment-id contract fixed before unlock visibility work
- [ ] Save sidecar schema fixed before save/load UX polish
- [ ] Result summary built before camp-facing memory-restoration polish
- [ ] Existing support-attack baseline surfaced before adding new bond mechanics
- [ ] Existing accessory summaries surfaced before writing major new flavor systems

### Runnable gate checklist after every sprint

- [ ] `bash scripts/dev/check_runnable_gate0.sh`
- [ ] `godot4 --headless --path . -s scripts/dev/m1_playtest_runner.gd`
- [ ] sprint-specific runner set
- [ ] regression notes recorded before advancing

### Atomic commit checklist

- [ ] one commit per runner-backed slice
- [ ] tests/contracts first
- [ ] smallest implementation second
- [ ] presentation/copy polish third
- [ ] no mixed commits spanning AI + save/load + UI in one shot

---

## 16. Recommended Commit Sequence

1. `test: add progression handoff contract runner`
2. `fix: align fragment unlock mapping with victory flow`
3. `test: cover save slot metadata contract`
4. `fix: return slot metadata expected by save load panel`
5. `test: add battle result summary runner`
6. `feat: expand battle result summary and reward visibility`
7. `feat: wire save load panel into camp and title flows`
8. `feat: surface burden trust and recovered records in camp`
9. `test: add command unlock visibility runner`
10. `feat: expose progression unlock state in player flows`
11. `test: add threat-aware ai runner`
12. `feat: upgrade ai scoring without breaking legality`
13. `feat: polish bond feedback and accessory summaries`

---

## 17. Final Recommendation

If the objective is **"파랜드택틱스 체감 품질에 더 가까워지기"**, the best first implementation order is:

1. Sprint 0
2. Sprint 1
3. Sprint 2
4. Sprint 3

That sequence alone should already make the game feel much closer to a complete SRPG loop because it adds:

- visible payoff after battle,
- visible persistence between battles,
- visible memory/progression carry-over,
- and a more believable RPG ritual around saving, recovering, and preparing.

Only after that should the plan branch into deeper tactical AI work or explicit XP/leveling.
