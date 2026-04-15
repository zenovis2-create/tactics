# Core Game Loop Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Harden the existing battle slice so battle flow, turn ownership, movement, AI, and interactive-object behavior satisfy a concrete headless runtime contract.

**Architecture:** Keep `BattleController` as the single phase orchestrator and preserve the current service split. Add runtime contract coverage first, then make the minimum controller/service changes required to satisfy those tests.

**Tech Stack:** Godot 4.6, GDScript, Resource-driven battle data, headless SceneTree test runners

---

### Task 1: Add a core-loop runtime contract runner

**Files:**
- Create: `scripts/dev/m1_core_loop_contract_runner.gd`
- Modify: `scripts/dev/m1_playtest_runner.gd`
- Test: `scripts/dev/m1_core_loop_contract_runner.gd`

**Step 1: Write the failing test**

Create a new headless runner that checks:

- one action package per ally per round
- manual end-turn forfeits remaining ally actions
- one-time object interaction cannot be repeated
- AI never proposes illegal movement into blocked or occupied cells

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path . -s scripts/dev/m1_core_loop_contract_runner.gd`
Expected: FAIL on at least one uncovered contract before implementation changes.

**Step 3: Write minimal implementation**

Add only the minimum runtime hooks or logic needed for the contract runner to observe and enforce the intended rules.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path . -s scripts/dev/m1_core_loop_contract_runner.gd`
Expected: PASS

### Task 2: Tighten controller and object action correctness

**Files:**
- Modify: `scripts/battle/battle_controller.gd`
- Modify: `scripts/battle/interactive_object_actor.gd`
- Test: `scripts/dev/m1_core_loop_contract_runner.gd`

**Step 1: Write the failing test**

Extend the contract runner to assert:

- interaction consumes the acting unit’s action package
- resolved one-time objects reject repeat interactions
- object blocking state updates are visible immediately after interaction

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path . -s scripts/dev/m1_core_loop_contract_runner.gd`
Expected: FAIL with an interaction or action-state assertion.

**Step 3: Write minimal implementation**

Adjust controller/object logic without moving responsibilities out of the existing architecture.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path . -s scripts/dev/m1_core_loop_contract_runner.gd`
Expected: PASS

### Task 3: Tighten AI legality and deterministic fallback behavior

**Files:**
- Modify: `scripts/battle/ai_service.gd`
- Modify: `scripts/battle/battle_controller.gd`
- Test: `scripts/dev/m1_core_loop_contract_runner.gd`

**Step 1: Write the failing test**

Add assertions for:

- AI only returns legal move destinations
- AI attack targets remain in range after movement resolution
- fallback wait behavior is explicit when no legal move exists

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path . -s scripts/dev/m1_core_loop_contract_runner.gd`
Expected: FAIL on an AI legality assertion.

**Step 3: Write minimal implementation**

Keep the current nearest-target deterministic baseline, but make legal-action guarantees explicit.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path . -s scripts/dev/m1_core_loop_contract_runner.gd`
Expected: PASS

### Task 4: Re-run the existing smoke playtest and static gate

**Files:**
- Test: `scripts/dev/check_runnable_gate0.sh`
- Test: `scripts/dev/m1_playtest_runner.gd`

**Step 1: Run Gate 0**

Run: `bash scripts/dev/check_runnable_gate0.sh`
Expected: `[PASS] Runnable Gate 0 integrity check passed.`

**Step 2: Run the smoke battle runner**

Run: `godot4 --headless --path . -s scripts/dev/m1_playtest_runner.gd`
Expected: `[PASS] M1 playtest runner completed battle to victory.`

**Step 3: If either fails, fix the smallest regression**

Modify only the battle-loop files needed to restore the existing smoke path.
