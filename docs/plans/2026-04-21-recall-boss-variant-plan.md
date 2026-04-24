# Recall Boss Variant Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 회상 토벌전 보스 3종에 objective-driven 후속 압박 행동을 추가하고 headless runner로 검증한다.

**Architecture:** 기존 `battle_controller.gd`의 hunt-specific AI 조건과 helper 메서드 구조를 재사용한다. 각 hunt는 새 action type 1개와 전용 helper 1개만 추가하고, `hunt_boss_variant_runner.gd`에서 선택/실행/flag를 검증한다.

**Tech Stack:** Godot 4.6, GDScript, StageData `.tres`, headless SceneTree runners

---

### Task 1: Add Basil hunt follow-up pressure

**Files:**
- Modify: `/Volumes/AI/tactics/scripts/dev/hunt_boss_variant_runner.gd`
- Modify: `/Volumes/AI/tactics/scripts/battle/battle_controller.gd`

**Step 1: Write the failing test**

Add a test that `HUNT_BASIL` chooses a new follow-up action once `hunt_basil_flood_rise_survived` is secured.

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/hunt_boss_variant_runner.gd`
Expected: FAIL because the new Basil action does not exist yet.

**Step 3: Write minimal implementation**

Add the new hunt Basil action branch and helper in `/Volumes/AI/tactics/scripts/battle/battle_controller.gd`.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/hunt_boss_variant_runner.gd`
Expected: PASS for the Basil assertions.

### Task 2: Add Saria hunt collapse pressure

**Files:**
- Modify: `/Volumes/AI/tactics/scripts/dev/hunt_boss_variant_runner.gd`
- Modify: `/Volumes/AI/tactics/scripts/battle/battle_controller.gd`

**Step 1: Write the failing test**

Add a test that `HUNT_SARIA` chooses a new collapse action once `hunt_saria_queue_preserved` is lost.

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/hunt_boss_variant_runner.gd`
Expected: FAIL because the new Saria action does not exist yet.

**Step 3: Write minimal implementation**

Add the new hunt Saria action branch and helper in `/Volumes/AI/tactics/scripts/battle/battle_controller.gd`.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/hunt_boss_variant_runner.gd`
Expected: PASS for the Saria assertions.

### Task 3: Upgrade Lete hunt execute pressure

**Files:**
- Modify: `/Volumes/AI/tactics/scripts/dev/hunt_boss_variant_runner.gd`
- Modify: `/Volumes/AI/tactics/scripts/battle/battle_controller.gd`

**Step 1: Write the failing test**

Change the hunt Lete marked-target expectation from generic `reckless_charge` to a hunt-specific execute pressure action.

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/hunt_boss_variant_runner.gd`
Expected: FAIL because hunt Lete still chooses the older action.

**Step 3: Write minimal implementation**

Prefer the new execute action in the `HUNT_LETE` branch when hound preservation is lost and a marked ally exists.

**Step 4: Run test to verify it passes**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/hunt_boss_variant_runner.gd`
Expected: PASS

### Task 4: Run hunt regressions

**Files:**
- Modify: `/Volumes/AI/tactics/docs/FARLAND_TACTICS_DEV_SPEC.md`
- Test: `/Volumes/AI/tactics/scripts/dev/hunt_boss_variant_runner.gd`
- Test: `/Volumes/AI/tactics/scripts/dev/hunt_battle_runner.gd`

**Step 1: Run regression tests**

Run:
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/hunt_boss_variant_runner.gd`
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/hunt_battle_runner.gd`

Expected: PASS
