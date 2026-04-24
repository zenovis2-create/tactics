# Status Icon Texture Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 상태 배지에 상태별 소형 아이콘 텍스처를 추가하고 headless runner로 검증한다.

**Architecture:** 새 외부 에셋 파일을 추가하지 않고 `TelegraphTextureLibrary`에서 procedural texture를 생성해 재사용한다. `UnitActor`는 primary status를 기반으로 badge text, badge color, badge icon kind를 함께 갱신한다.

**Tech Stack:** Godot 4.6, GDScript, Texture2D/ImageTexture, headless SceneTree runner

---

### Task 1: Add failing icon assertions

**Files:**
- Modify: `/Volumes/AI/tactics/scripts/dev/status_visual_runner.gd`

**Step 1: Write the failing test**

Add assertions for:
- `status_badge_icon_visible == true`
- correct `status_badge_icon_kind` per primary status

**Step 2: Run test to verify it fails**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/status_visual_runner.gd`
Expected: FAIL because badge icon snapshot keys do not exist yet.

### Task 2: Add badge icon node and procedural textures

**Files:**
- Modify: `/Volumes/AI/tactics/scenes/battle/Unit.tscn`
- Modify: `/Volumes/AI/tactics/scripts/battle/unit_actor.gd`
- Modify: `/Volumes/AI/tactics/scripts/battle/telegraph_texture_library.gd`

**Step 1: Write minimal implementation**

Add:
- `StatusBadgeIcon` node
- snapshot keys for icon visibility/kind
- procedural status icon textures in `TelegraphTextureLibrary`

**Step 2: Run test to verify it passes**

Run: `godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/status_visual_runner.gd`
Expected: PASS
