# Status Icon Polish Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** `UnitActor`에 primary status용 소형 배지를 추가하고 상태별 코드/색/가시성을 headless runner로 검증한다.

**Architecture:** 현재 status priority 계산은 유지하고, 그 결과를 소비하는 배지 UI만 추가한다. `Unit.tscn`에 작은 배지 노드를 추가하고 `unit_actor.gd`가 visibility/text/color를 갱신한다.

**Tech Stack:** Godot 4.6, GDScript, `.tscn`, headless SceneTree runner

---

### Task 1: Add failing status badge tests

**Files:**
- Modify: `/Volumes/AI/tactics/scripts/dev/status_visual_runner.gd`

**Step 1: Write the failing test**

Add assertions for:
- oblivion badge visibility + `망`
- fear badge visibility + `공`
- mark/boss mark badge priority

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/status_visual_runner.gd`
Expected: FAIL because the badge snapshot keys do not exist yet.

### Task 2: Add badge nodes and runtime bindings

**Files:**
- Modify: `/Volumes/AI/tactics/scenes/battle/Unit.tscn`
- Modify: `/Volumes/AI/tactics/scripts/battle/unit_actor.gd`

**Step 1: Write minimal implementation**

Add `StatusBadgeBack` and `StatusBadgeLabel`, then expose:
- visible
- label text
- color

based on primary status.

**Step 2: Run test to verify it passes**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/status_visual_runner.gd`
Expected: PASS
