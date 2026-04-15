# CH1 Campaign Shell Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a thin Chapter 1 campaign shell above the existing battle scene so `Main` can progress through staged battle, cutscene, and camp placeholder states without broadening into save/load or meta systems.

**Architecture:** Keep `BattleController` battle-only and move progression orchestration into a new `Main`-level campaign controller/shell. Extend `StageData` only with the minimum fields needed for ordered stage progression and cutscene/camp hooks, then validate the flow with a deterministic Godot smoke runner.

**Tech Stack:** Godot 4.x, GDScript, `.tscn` scenes, `.tres` resources, headless Godot smoke tests

---

### Task 1: Add the failing campaign-shell smoke runner

**Files:**
- Create: `scripts/dev/m2_campaign_flow_runner.gd`
- Modify: `scenes/Main.tscn`
- Modify: `scripts/main.gd`

**Step 1: Write the failing test**

Add a `SceneTree` runner that instantiates `Main.tscn`, expects `Main` to expose campaign-shell state, advances through a deterministic clear path, and fails because `Main` currently only wraps a single `BattleScene`.

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path . --script res://scripts/dev/m2_campaign_flow_runner.gd`
Expected: FAIL because the campaign state API and stage-chain flow do not exist yet.

**Step 3: Write minimal implementation**

Introduce only the shell API surface needed for the runner to inspect active mode, active stage id, and transition progression.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path . --script res://scripts/dev/m2_campaign_flow_runner.gd`
Expected: PASS with the stage chain advancing through battle and placeholder narrative states.

### Task 2: Build the thin `Main`-level campaign shell

**Files:**
- Modify: `scripts/main.gd`
- Modify: `scenes/Main.tscn`
- Create: `scripts/campaign/campaign_controller.gd`
- Create: `scripts/campaign/campaign_state.gd`
- Create: `scenes/campaign/CampaignPanel.tscn`
- Create: `scripts/campaign/campaign_panel.gd`

**Step 1: Write the failing test**

Expand the runner to expect:
- ordered stage-chain loading
- battle clear transitioning into cutscene/interlude placeholder UI
- final Chapter 1 handoff into camp placeholder state

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path . --script res://scripts/dev/m2_campaign_flow_runner.gd`
Expected: FAIL because those transitions are not yet implemented.

**Step 3: Write minimal implementation**

Create a `CampaignController` owned by `Main` that:
- owns the ordered Chapter 1 flow definition
- swaps active view state between battle and simple narrative/camp placeholders
- tells the existing `BattleScene` which stage to load
- listens for battle result completion and advances to the next flow node

Keep the panel text-only and deterministic; no save/load, branching, or equipment/camp subsystems.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path . --script res://scripts/dev/m2_campaign_flow_runner.gd`
Expected: PASS with shell transitions logged in order.

### Task 3: Extend stage resources with minimal progression metadata

**Files:**
- Modify: `scripts/data/stage_data.gd`
- Modify: `data/stages/tutorial_stage.tres`
- Create: `data/stages/ch01_02_stage.tres`
- Create: `data/stages/ch01_03_stage.tres`
- Create: `data/stages/ch01_04_stage.tres`
- Create: `data/stages/ch01_05_stage.tres`

**Step 1: Write the failing test**

Make the runner assert that each stage has a stable id/title plus optional intro/outro hook metadata and can be loaded by the campaign shell in a fixed order.

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path . --script res://scripts/dev/m2_campaign_flow_runner.gd`
Expected: FAIL because the resource metadata and Chapter 1 stage set are incomplete.

**Step 3: Write minimal implementation**

Add only the fields needed for M2 glue:
- display title
- start/clear cutscene ids
- optional next destination summary

Reuse current battle data patterns so each new stage remains runnable with the existing `BattleController`.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path . --script res://scripts/dev/m2_campaign_flow_runner.gd`
Expected: PASS with ordered stage metadata resolved.

### Task 4: Keep the current battle loop runnable

**Files:**
- Modify only if required by integration: `scripts/battle/battle_controller.gd`
- Modify only if required by integration: `scripts/dev/m1_playtest_runner.gd`

**Step 1: Write the failing test**

Re-run the existing M1 runner after shell integration and confirm whether `Main` changes broke the single-battle loop assumptions.

**Step 2: Run test to verify it fails or stays green**

Run: `godot4 --headless --path . --script res://scripts/dev/m1_playtest_runner.gd`
Expected: either PASS immediately or expose a specific compatibility gap caused by the shell.

**Step 3: Write minimal implementation**

Adapt only the startup path or test harness needed to preserve the current battle smoke coverage.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path . --script res://scripts/dev/m1_playtest_runner.gd`
Expected: PASS.

### Task 5: Validate static and runtime gates

**Files:**
- Modify: `docs/scene_script_structure.md`
- Modify: `docs/milestone_runnable_gates.md`

**Step 1: Write the failing test**

Use the shell runner plus headless boot as the gate evidence for the new scene/script structure.

**Step 2: Run validation**

Run:
- `godot4 --headless --path . --quit`
- `godot4 --headless --path . --script res://scripts/dev/m1_playtest_runner.gd`
- `godot4 --headless --path . --script res://scripts/dev/m2_campaign_flow_runner.gd`

Expected: all commands PASS.

**Step 3: Write minimal documentation updates**

Update the structure and runnable-gate docs to record the new campaign-shell ownership boundary and validation path.

**Step 4: Re-run validation**

Repeat the three commands above and confirm they remain green.
