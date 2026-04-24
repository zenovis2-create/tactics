# Post-Sprint-7 Polish Pass Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Tune the post-Sprint-7 game feel, finish the remaining content and UX rollout, and add compact progression visibility in camp and save flows without rewriting existing systems.

**Architecture:** This plan keeps the current battle, result, camp, and save architecture intact. It changes only existing data, service constants, and presentation surfaces, with runner-first verification for each slice.

**Tech Stack:** Godot 4.6, GDScript, `.tres` data resources, headless SceneTree runners

---

### Task 1: Lock the balance-tuning contract

**Files:**
- Modify: `scripts/dev/ai_depth_runner.gd`
- Modify: `scripts/dev/bond_runner.gd`
- Modify: `scripts/dev/s7_unit_progression_runner.gd`
- Read: `scripts/battle/progression_service.gd`
- Read: `scripts/battle/battle_controller.gd`

**Step 1: Write the failing test**

Extend the runners to assert the intended light-tuning targets:
- EXP pacing feels slower or faster according to the chosen constants
- support attack payoff stays readable and bounded
- AI threat scoring still chooses legally but does not overvalue low-impact targets

**Step 2: Run test to verify it fails**

Run:
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/ai_depth_runner.gd`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/bond_runner.gd`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/s7_unit_progression_runner.gd`

Expected: FAIL on one or more tuned values.

**Step 3: Write minimal implementation**

Adjust only the smallest set of constants/thresholds in the existing services/controllers.

**Step 4: Run test to verify it passes**

Run the same three runners again.

Expected: PASS

**Step 5: Commit**

```bash
git add scripts/dev/ai_depth_runner.gd scripts/dev/bond_runner.gd scripts/dev/s7_unit_progression_runner.gd scripts/battle/progression_service.gd scripts/battle/battle_controller.gd scripts/battle/ai_service.gd
GIT_MASTER=1 git commit -m "feat: tune post-sprint7 combat pacing"
```

### Task 2: Roll accessory flavor text across the full catalog

**Files:**
- Modify: `data/accessories/*.tres`
- Modify: `scripts/dev/lategame_accessory_runner.gd`
- Optional verify: `scripts/campaign/campaign_controller.gd`
- Optional verify: `scripts/campaign/campaign_panel.gd`

**Step 1: Write the failing test**

Extend `lategame_accessory_runner.gd` so it fails if the non-late-game accessory catalog still has missing or duplicated flavor text in surfaced paths.

**Step 2: Run test to verify it fails**

Run:
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/lategame_accessory_runner.gd`

Expected: FAIL on at least one missing flavor path.

**Step 3: Write minimal implementation**

Fill the remaining accessory `.tres` files with distinct `flavor_text` values. Do not change stats or equip rules.

**Step 4: Run test to verify it passes**

Run the same runner again.

Expected: PASS

**Step 5: Commit**

```bash
git add data/accessories/*.tres scripts/dev/lategame_accessory_runner.gd
GIT_MASTER=1 git commit -m "feat: expand accessory flavor text rollout"
```

### Task 3: Apply unlock_condition to existing real skill data

**Files:**
- Modify: `data/skills/basic_attack.tres`
- Modify: `scripts/dev/s4b_skill_unlock_runner.gd`
- Read: `scripts/data/skill_data.gd`

**Step 1: Write the failing test**

Extend the skill unlock runner so it verifies the actual `.tres` data contains a real `unlock_condition` payload and that the resource still behaves correctly when loaded.

**Step 2: Run test to verify it fails**

Run:
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/s4b_skill_unlock_runner.gd`

Expected: FAIL on missing data-backed unlock condition assertions.

**Step 3: Write minimal implementation**

Set `unlock_condition` only on existing real skill resources. Do not create a larger catalog in this task.

**Step 4: Run test to verify it passes**

Run the same runner again.

Expected: PASS

**Step 5: Commit**

```bash
git add data/skills/basic_attack.tres scripts/dev/s4b_skill_unlock_runner.gd
GIT_MASTER=1 git commit -m "feat: apply unlock conditions to existing skill data"
```

### Task 4: Finish combat result and feedback readability

**Files:**
- Modify: `scripts/dev/m3_ui_runner.gd`
- Modify: `scripts/dev/battle_result_runner.gd`
- Modify: `scripts/dev/bond_runner.gd`
- Modify: `scripts/battle/battle_hud.gd`
- Modify: `scripts/battle/battle_result_screen.gd`
- Modify: `scripts/battle/battle_controller.gd`

**Step 1: Write the failing test**

Strengthen existing UI/result runners for:
- clearer EXP/level-up emphasis
- stronger support/bond readability
- stronger boss phase readability
- compact layout stability

**Step 2: Run test to verify it fails**

Run:
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/m3_ui_runner.gd`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/battle_result_runner.gd`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/bond_runner.gd`

Expected: FAIL on one or more readability assertions.

**Step 3: Write minimal implementation**

Tighten wording, hierarchy, and emphasis in existing HUD/result flows. Do not create a new scene.

**Step 4: Run test to verify it passes**

Run the same three runners again.

Expected: PASS

**Step 5: Commit**

```bash
git add scripts/dev/m3_ui_runner.gd scripts/dev/battle_result_runner.gd scripts/dev/bond_runner.gd scripts/battle/battle_hud.gd scripts/battle/battle_result_screen.gd scripts/battle/battle_controller.gd
GIT_MASTER=1 git commit -m "feat: tighten combat result and feedback readability"
```

### Task 5: Add compact unit progression to camp detail and save metadata

**Files:**
- Modify: `scripts/dev/camp_runner.gd`
- Modify: `scripts/dev/save_load_runner.gd`
- Modify: `scripts/campaign/campaign_controller.gd`
- Modify: `scripts/campaign/campaign_panel.gd`
- Modify: `scripts/battle/save_service.gd`
- Possibly modify: `scripts/ui/save_load_panel.gd`

**Step 1: Write the failing test**

Add assertions for:
- compact level/EXP visibility in camp party detail
- compact unit progression summary in save slot metadata
- save/load persistence of the summary fields

**Step 2: Run test to verify it fails**

Run:
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/camp_runner.gd`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/save_load_runner.gd`

Expected: FAIL on missing progression summaries.

**Step 3: Write minimal implementation**

Expose summary-only progression fields. Do not add a new progression management panel.

**Step 4: Run test to verify it passes**

Run the same two runners again.

Expected: PASS

**Step 5: Commit**

```bash
git add scripts/dev/camp_runner.gd scripts/dev/save_load_runner.gd scripts/campaign/campaign_controller.gd scripts/campaign/campaign_panel.gd scripts/battle/save_service.gd scripts/ui/save_load_panel.gd
GIT_MASTER=1 git commit -m "feat: surface compact progression in camp and saves"
```

### Task 6: Full regression and integrity gate

**Files:**
- Modify only if regressions force fixes
- Test: `scripts/dev/check_runnable_gate0.sh`
- Test: full relevant runner sweep

**Step 1: Run regression sweep**

Run:
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/lategame_accessory_runner.gd`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/m3_ui_runner.gd`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/battle_result_runner.gd`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/bond_runner.gd`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/ai_depth_runner.gd`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/s7_unit_progression_runner.gd`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/s4b_skill_unlock_runner.gd`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/camp_runner.gd`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --script scripts/dev/save_load_runner.gd`
- `bash scripts/dev/check_runnable_gate0.sh`

**Step 2: Fix only regression-causing issues**

Keep fixes minimal and scoped to this polish pass.

**Step 3: Re-run failing verifications**

Expected: all PASS.

**Step 4: Commit**

```bash
git add .
GIT_MASTER=1 git commit -m "fix: close regression gaps in polish pass"
```
