# Late-Game Rule Object Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** CH08_05, CH09B_05, CH10_05에 상호작용 오브젝트를 추가하고, 상호작용이 late-game battlefield rules를 완화하는지 headless runner로 검증한다.

**Architecture:** 새 `InteractiveObjectData` 3개를 authoring하고 각 stage `.tres`에 연결한다. `battle_controller.gd`의 `_handle_stage_interaction_flags()`에 해당 object flag 처리와 stage-data mutation 완화 로직을 추가한다.

**Tech Stack:** Godot 4.6, GDScript, StageData `.tres`, InteractiveObjectData `.tres`, headless SceneTree runners

---

### Task 1: Add failing runner assertions

**Files:**
- Modify: `/Volumes/AI/tactics/scripts/dev/ch06_ch10_boss_surface_runner.gd`
- Modify: `/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd`

### Task 2: Add object resources and stage wiring

**Files:**
- Create: `/Volumes/AI/tactics/data/objects/ch08_05_transfer_gate_latch.tres`
- Create: `/Volumes/AI/tactics/data/objects/ch09b_05_archive_lectern.tres`
- Create: `/Volumes/AI/tactics/data/objects/ch10_05_anchor_chain.tres`
- Modify: `/Volumes/AI/tactics/data/stages/ch08_05_stage.tres`
- Modify: `/Volumes/AI/tactics/data/stages/ch09b_05_stage.tres`
- Modify: `/Volumes/AI/tactics/data/stages/ch10_05_stage.tres`

### Task 3: Wire interaction effects

**Files:**
- Modify: `/Volumes/AI/tactics/scripts/battle/battle_controller.gd`

### Task 4: Run regressions

**Files:**
- Test: `/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd`
- Test: `/Volumes/AI/tactics/scripts/dev/ch06_ch10_boss_surface_runner.gd`
