# Recall Battle Variation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 회상 토벌전 3종에 stage-data 기반 전장 변주를 추가하고 headless runner로 검증한다.

**Architecture:** 런타임 로직은 유지하고 `hunt_battle_runner.gd`가 각 hunt stage의 적 수, 차단선, 지형 타입을 직접 확인한다. 구현은 `data/stages/hunt_*.tres` 수정만으로 끝낸다.

**Tech Stack:** Godot 4.6, GDScript runner, StageData `.tres`

---

### Task 1: Add failing stage variation assertions

**Files:**
- Modify: `/Volumes/AI/tactics/scripts/dev/hunt_battle_runner.gd`

**Step 1: Write the failing test**

Add assertions for per-hunt:
- enemy count >= 3
- stage-specific terrain/blocked-cell variation

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/hunt_battle_runner.gd`
Expected: FAIL because current stages are still the lighter variants.

### Task 2: Update hunt stage data

**Files:**
- Modify: `/Volumes/AI/tactics/data/stages/hunt_basil_stage.tres`
- Modify: `/Volumes/AI/tactics/data/stages/hunt_saria_stage.tres`
- Modify: `/Volumes/AI/tactics/data/stages/hunt_lete_stage.tres`

**Step 1: Write minimal implementation**

Adjust each stage with:
- one extra enemy resource entry and spawn
- one extra terrain/blocked-cell variation matching the hunt theme

**Step 2: Run test to verify it passes**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/hunt_battle_runner.gd`
Expected: PASS
