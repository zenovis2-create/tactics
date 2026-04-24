# Recall Rule Object Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** recall hunt 3종에 상호작용 오브젝트를 추가하고, 상호작용이 pressure rule을 실제로 바꾸는지 headless runner로 검증한다.

**Architecture:** 각 hunt stage에 `InteractiveObjectData` resource를 1개씩 추가한다. `battle_controller.gd`의 `_handle_stage_interaction_flags()`와 hunt pressure update helpers에서 해당 오브젝트 flag를 읽어 stage rule을 분기한다.

**Tech Stack:** Godot 4.6, GDScript, StageData `.tres`, InteractiveObjectData `.tres`, headless SceneTree runners

---

### Task 1: Add failing hunt interaction assertions

**Files:**
- Modify: `/Volumes/AI/tactics/scripts/dev/hunt_battle_runner.gd`

**Step 1: Write the failing test**

Add assertions for:
- each hunt stage authors one interactive object
- interaction flips a hunt-specific flag or battlefield state

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/hunt_battle_runner.gd`
Expected: FAIL because recall hunts do not author interactive objects yet.

### Task 2: Add recall object resources and stage wiring

**Files:**
- Create: `/Volumes/AI/tactics/data/objects/hunt_basil_sluice_wheel.tres`
- Create: `/Volumes/AI/tactics/data/objects/hunt_saria_choir_lectern.tres`
- Create: `/Volumes/AI/tactics/data/objects/hunt_lete_gate_latch.tres`
- Modify: `/Volumes/AI/tactics/data/stages/hunt_basil_stage.tres`
- Modify: `/Volumes/AI/tactics/data/stages/hunt_saria_stage.tres`
- Modify: `/Volumes/AI/tactics/data/stages/hunt_lete_stage.tres`

**Step 1: Write minimal implementation**

Author one object per hunt and place it in a tactically relevant cell.

**Step 2: Run test to verify it still fails on missing runtime effect**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/hunt_battle_runner.gd`
Expected: FAIL at the interaction-effect assertion.

### Task 3: Wire recall rule effects

**Files:**
- Modify: `/Volumes/AI/tactics/scripts/battle/battle_controller.gd`

**Step 1: Write minimal implementation**

Add stage-specific handling:
- Basil wheel stops flood spread
- Saria lectern slows queue pressure
- Lete latch opens one blocked choke cell

**Step 2: Run test to verify it passes**

Run:
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/hunt_battle_runner.gd`
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/hunt_boss_variant_runner.gd`

Expected: PASS
