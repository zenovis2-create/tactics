# Late-Game Battlefield Rule Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** CH08_05, CH09B_05, CH10_05에 phase-linked battlefield rule mutation을 추가하고 headless runners로 검증한다.

**Architecture:** 기존 boss action/phase helpers 안에서 `stage_data.terrain_types`, `terrain_move_costs`, `terrain_defense_bonuses`, `blocked_cells`를 최소 수정하고 `battle_board.queue_redraw()`를 호출한다. 새 규칙은 스테이지별 고정 셀만 사용한다.

**Tech Stack:** Godot 4.6, GDScript, StageData mutation, headless SceneTree runners

---

### Task 1: Add failing battlefield-rule assertions

**Files:**
- Modify: `/Volumes/AI/tactics/scripts/dev/lategame_boss_pattern_runner.gd`

**Step 1: Write the failing test**

Add assertions for:
- CH08 shadow-lane expansion on `berserk_rush`
- CH09B revision terrain rewrite on `archive_mode`
- CH10 bell-lane pressure on `name_severance`

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/lategame_boss_pattern_runner.gd`
Expected: FAIL because these battlefield mutations do not exist yet.

### Task 2: Implement minimal battlefield mutations

**Files:**
- Modify: `/Volumes/AI/tactics/scripts/battle/battle_controller.gd`

**Step 1: Write minimal implementation**

Add helper methods that mutate stage data and redraw the board:
- CH08: extend pursuit shadow lane and release one blocked pursuit cell
- CH09B: stamp revision terrain cells in archive mode
- CH10: add bell pressure lane plus one new blocked choke cell

**Step 2: Run test to verify it passes**

Run:
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/lategame_boss_pattern_runner.gd`
- `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ch06_ch10_boss_surface_runner.gd`

Expected: PASS
