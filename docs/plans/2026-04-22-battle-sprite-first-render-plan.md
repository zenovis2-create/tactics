# Battle Sprite-First Render Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Convert ally battle rendering from static photo/token priority to sprite-frame priority using the existing runtime sprite sheets, while preserving token fallback for units without sprite support.

**Architecture:** Keep the current `Unit` scene and battle logic intact, but replace the art-resolution path for ally units so `CharacterVisualRoot` becomes a real frame-driven battle-sprite layer. Use explicit ally-name mapping to sprite anchor directories, load frame sequences through `BattleArtCatalog`, drive `idle/move/attack` state in `UnitActor`, and keep `TokenArt` only as fallback.

**Tech Stack:** Godot 4.6, GDScript, existing headless SceneTree runners, PNG frame sequences under `assets/characters/sprite_anchor_*/runtime`

---

### Task 1: Add explicit ally sprite-anchor mapping

**Files:**
- Modify: `scripts/battle/battle_art_catalog.gd`
- Test: `scripts/dev/ally_battle_sprite_runner.gd`

**Step 1: Write the failing test**

Create a runner that instantiates ally units and asserts:
- `Rian`, `Serin`, `Tia`, `Bran` resolve a non-empty `idle` frame list
- a generic unit like `ally_vanguard` resolves no sprite set

**Step 2: Run test to verify it fails**

Run:

```bash
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ally_battle_sprite_runner.gd
```

Expected: FAIL because no sprite-sequence loader exists yet.

**Step 3: Write minimal implementation**

In `battle_art_catalog.gd`:
- add a narrow explicit mapping from display names to sprite-anchor directories
- add loader helpers for runtime frame sequences:
  - `load_character_sprite_frames(unit_name: String, state: String) -> Array[Texture2D]`
- use the same image-loading pattern already used in the catalog
- sort frame files deterministically

**Step 4: Run test to verify it passes**

Run:

```bash
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ally_battle_sprite_runner.gd
```

Expected: PASS for allies, fallback unit returns no sprite frames.

**Step 5: Commit**

```bash
git add scripts/battle/battle_art_catalog.gd scripts/dev/ally_battle_sprite_runner.gd
git commit -m "feat: add ally battle sprite frame resolution"
```

### Task 2: Switch unit visual setup to sprite-first

**Files:**
- Modify: `scripts/battle/unit_actor.gd`
- Modify: `scenes/battle/Unit.tscn`
- Test: `scripts/dev/character_visual_layer_runner.gd`

**Step 1: Write the failing test**

Update `character_visual_layer_runner.gd` so it asserts:
- ally party units use sprite-layer visibility because runtime frames exist
- token art is hidden when sprite frames exist
- generic fallback units still show token art

**Step 2: Run test to verify it fails**

Run:

```bash
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/character_visual_layer_runner.gd
```

Expected: FAIL because sprite availability is not yet connected to visibility.

**Step 3: Write minimal implementation**

In `unit_actor.gd`:
- replace single-texture character loading with sprite-set loading
- store runtime frame arrays for `idle`, `move`, `attack`
- add `_has_character_sprite_set()` helper
- make `_setup_character_visuals()` choose sprite-first for mapped allies
- keep `TokenArt` fallback for missing sprite sets

In `Unit.tscn`:
- keep the same nodes, no structural rewrite
- only preserve sprite-first visibility behavior at runtime rather than scene default dependence

**Step 4: Run test to verify it passes**

Run:

```bash
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/character_visual_layer_runner.gd
```

Expected: PASS.

**Step 5: Commit**

```bash
git add scripts/battle/unit_actor.gd scenes/battle/Unit.tscn scripts/dev/character_visual_layer_runner.gd
git commit -m "feat: make ally battle rendering sprite-first"
```

### Task 3: Drive idle, move, and attack frame cycling

**Files:**
- Modify: `scripts/battle/unit_actor.gd`
- Test: `scripts/dev/character_animation_ready_runner.gd`

**Step 1: Write the failing test**

Update `character_animation_ready_runner.gd` so it asserts:
- ally units expose sprite-first visual state
- `idle` animation advances over the runtime frame set
- `attack` changes state and returns to `idle`
- generic fallback units still avoid the sprite path

**Step 2: Run test to verify it fails**

Run:

```bash
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/character_animation_ready_runner.gd
```

Expected: FAIL because the current `AnimationPlayer` is placeholder-only and not frame-driven.

**Step 3: Write minimal implementation**

In `unit_actor.gd`:
- add a small code-driven animation state system for sprite frames
- use `_process(delta)` or timer-driven frame stepping
- map:
  - idle -> looping idle frames
  - move -> looping move frames
  - attack -> play once, then return to idle
- use fallback rules:
  - hit -> idle if no dedicated hit set
  - defeat -> idle or last attack frame if no dedicated defeat set

Do not build a full animation-authoring system. Keep it minimal and local to battle units.

**Step 4: Run test to verify it passes**

Run:

```bash
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/character_animation_ready_runner.gd
```

Expected: PASS.

**Step 5: Commit**

```bash
git add scripts/battle/unit_actor.gd scripts/dev/character_animation_ready_runner.gd
git commit -m "feat: add frame-driven ally battle sprite states"
```

### Task 4: Connect move-state transitions to battle flow

**Files:**
- Modify: `scripts/battle/unit_actor.gd`
- Modify: `scripts/battle/battle_controller.gd`
- Test: `scripts/dev/ally_battle_sprite_runner.gd`

**Step 1: Write the failing test**

Extend the ally sprite runner so it asserts:
- when a unit begins repositioning, it enters `move`
- after relocation completes, it returns to `idle`

**Step 2: Run test to verify it fails**

Run:

```bash
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ally_battle_sprite_runner.gd
```

Expected: FAIL because snap movement does not yet signal visual move-state transitions.

**Step 3: Write minimal implementation**

Add a narrow visual hook:
- before `set_grid_position()` is applied for battle movement, enter `move`
- after position settles, return to `idle`

Do not redesign path interpolation in this wave. This task is only about not showing idle-photo state during movement.

**Step 4: Run test to verify it passes**

Run:

```bash
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ally_battle_sprite_runner.gd
```

Expected: PASS.

**Step 5: Commit**

```bash
git add scripts/battle/unit_actor.gd scripts/battle/battle_controller.gd scripts/dev/ally_battle_sprite_runner.gd
git commit -m "feat: hook move-state visuals into battle flow"
```

### Task 5: Run regression verification on existing battle art runners

**Files:**
- Modify if needed: `scripts/dev/character_token_art_runner.gd`
- Modify if needed: `scripts/dev/character_visual_layer_runner.gd`
- Modify if needed: `scripts/dev/character_animation_ready_runner.gd`

**Step 1: Run verification suite**

Run:

```bash
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/ally_battle_sprite_runner.gd
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/character_visual_layer_runner.gd
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/character_animation_ready_runner.gd
godot4 --headless --path /Volumes/AI/tactics --script res://scripts/dev/character_token_art_runner.gd
```

Expected:
- ally sprite runner: PASS
- character visual layer runner: PASS
- animation ready runner: PASS
- character token art runner: PASS with revised meaning, confirming sprite-first for mapped allies and fallback behavior for non-mapped units

**Step 2: Fix any breakage minimally**

Only update runner assertions that no longer match the new intended architecture.

**Step 3: Final commit**

```bash
git add scripts/dev/character_token_art_runner.gd scripts/dev/character_visual_layer_runner.gd scripts/dev/character_animation_ready_runner.gd scripts/dev/ally_battle_sprite_runner.gd
git commit -m "test: update battle render verification for sprite-first allies"
```
