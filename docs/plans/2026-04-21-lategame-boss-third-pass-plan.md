# Late-Game Boss Third Pass Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** CH08 Lete, CH09B Melkion, CH10 Karuon의 late-game boss phase에 각 1개의 체감형 특수 행동을 추가하고 headless runner로 검증한다.

**Architecture:** 기존 `battle_controller.gd`의 boss AI dispatch, phase transition, HUD transition reason, objective flag 구조를 재사용한다. 새 behavior는 resource schema 변경 없이 phase-specific action branch와 helper method를 최소 추가하는 방식으로 넣는다.

**Tech Stack:** Godot 4.6, GDScript, `.tres` UnitData resources, headless SceneTree runners

---

### Task 1: Extend the late-game runner for Lete

**Files:**
- Modify: `/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd`
- Test: `/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd`

**Step 1: Write the failing test**

Add an assertion that `berserk_rush` phase can emit a new Lete execute-style action after a marked target exists, and that resolving it sets a dedicated objective flag.

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/lategame_boss_pattern_runner.gd`
Expected: FAIL because the new Lete action/flag does not exist yet.

**Step 3: Write minimal implementation**

Add one phase-specific action branch in `/Volumes/AI/tactics/scripts/battle/battle_controller.gd` plus a helper that records the event, HUD reason, and flag.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/lategame_boss_pattern_runner.gd`
Expected: PASS for the Lete assertions.

**Step 5: Commit**

```bash
git add /Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd /Volumes/AI/tactics/scripts/battle/battle_controller.gd
git commit -m "feat: deepen lete berserk pursuit pressure"
```

### Task 2: Extend the late-game runner for Melkion

**Files:**
- Modify: `/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd`
- Modify: `/Volumes/AI/tactics/scripts/battle/battle_controller.gd`
- Test: `/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd`

**Step 1: Write the failing test**

Add an assertion that `archive_mode` can choose a new Melkion sentence-style action after `revision_field`, and that resolving it sets a dedicated objective flag and visible runtime pressure.

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/lategame_boss_pattern_runner.gd`
Expected: FAIL because the new Melkion action/flag does not exist yet.

**Step 3: Write minimal implementation**

Add the new action selection and helper method in `/Volumes/AI/tactics/scripts/battle/battle_controller.gd`, reusing existing mark/terrain suppression state where possible.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/lategame_boss_pattern_runner.gd`
Expected: PASS for the Melkion assertions.

**Step 5: Commit**

```bash
git add /Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd /Volumes/AI/tactics/scripts/battle/battle_controller.gd
git commit -m "feat: deepen melkion archive rewrite pressure"
```

### Task 3: Extend the late-game runner for Karuon

**Files:**
- Modify: `/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd`
- Modify: `/Volumes/AI/tactics/scripts/battle/battle_controller.gd`
- Test: `/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd`

**Step 1: Write the failing test**

Add an assertion that `name_severance` or `final_toll` can emit a new Karuon bell/edict pressure action and that the resolution leaves a dedicated objective flag plus bond/name-call pressure state.

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/lategame_boss_pattern_runner.gd`
Expected: FAIL because the new Karuon action/flag does not exist yet.

**Step 3: Write minimal implementation**

Add the new Karuon action branch and helper in `/Volumes/AI/tactics/scripts/battle/battle_controller.gd`, preserving the current `all_allies_name_called` and `karon_final_toll` contracts.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/lategame_boss_pattern_runner.gd`
Expected: PASS for the Karuon assertions.

**Step 5: Commit**

```bash
git add /Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd /Volumes/AI/tactics/scripts/battle/battle_controller.gd
git commit -m "feat: deepen karuon endgame pressure"
```

### Task 4: Run regression checks

**Files:**
- Modify: `/Volumes/AI/tactics/docs/FARLAND_TACTICS_DEV_SPEC.md`
- Test: `/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd`
- Test: `/Volumes/AI/tactics/scripts/dev/ch10_shell_runner.gd`

**Step 1: Write the failing test**

No new failing test for this task; use regression runners as the gate.

**Step 2: Run test to verify it fails**

If a regression appears:

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ch10_shell_runner.gd`
Expected: Any failure reveals an unintended integration break.

**Step 3: Write minimal implementation**

Fix only the regression surface required to keep the newly added boss actions compatible with the shell/runtime flow.

**Step 4: Run test to verify it passes**

Run:
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/lategame_boss_pattern_runner.gd`
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ch10_shell_runner.gd`

Expected: PASS

**Step 5: Commit**

```bash
git add /Volumes/AI/tactics/scripts/battle/battle_controller.gd /Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd /Volumes/AI/tactics/docs/FARLAND_TACTICS_DEV_SPEC.md
git commit -m "feat: add third-pass late-game boss pressure"
```
