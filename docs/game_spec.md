# Mobile Tactics RPG Game Spec

## 1. Project Summary

- Genre: single-player tactics RPG
- Perspective: 2D top-down
- Grid type: square grid
- Target session length: 5 to 10 minutes per battle
- Primary target: mobile-first prototype
- Creative direction: original IP with classic SRPG feel

## 2. Product Goal

Build a small but fully playable vertical slice that proves the core tactics loop works on mobile:

- select a unit
- preview movement range
- move on a grid
- attack or wait
- end turn
- resolve enemy turn
- reach victory or defeat

The first milestone is not content scale. It is battle loop stability, readability, and fast iteration.

## 3. Recommended Technical Direction

- Engine: Godot 4.x
- Language: GDScript only
- Development mode: local-first using Codex CLI or Codex IDE extension
- Pathfinding: `AStarGrid2D`
- Map workflow: `TileMapLayer`
- Data storage: Godot `Resource` files for units, skills, and stages

## 4. Platform Constraints

- Prioritize Android for first device validation
- Support desktop during development for faster iteration
- Treat iOS as a later deployment target because export requires macOS and Xcode
- Do not use Godot 4 C# mobile export for MVP because Android and iOS support is still experimental

## 5. Core Design Principles

- Mobile-first interaction over desktop convenience
- Square grid over isometric presentation
- System clarity over presentation polish
- Small feature surface over early content expansion
- Data-driven balance over hardcoded values
- Keep every change compatible with a runnable project state

## 6. Explicit Non-Goals for MVP

The following are out of scope for the first prototype:

- save/load systems
- equipment systems
- character growth
- class change systems
- campaign progression
- gacha or monetization features
- networking or multiplayer
- advanced cutscenes or narrative tooling
- final art production

## 7. MVP Scope

### 7.1 Battle Setup

- One battle scene
- One playable stage
- 8x8 square grid as default prototype size
- 10x10 allowed only if needed after the first loop is stable
- 2 ally units
- 2 enemy units

### 7.2 Terrain Types

- Plain: movement cost `1`
- Forest: movement cost `2`
- Wall: blocked tile

Future terrain values such as `defense_bonus` should be supported by the data model, even if the first combat pass does not fully use them.

### 7.3 Turn Loop

- Player phase
- Enemy phase
- Units act once per turn
- Each acting unit follows:
  - Select
  - Move
  - Attack or Wait

### 7.4 Combat Rules

- Basic adjacent attack for MVP
- One action per unit per turn
- A defeated unit is removed from active battle participation
- Victory: all enemy units defeated
- Defeat: all ally units defeated

### 7.5 Enemy AI

- Single AI type for MVP
- Find the nearest opposing unit
- Move toward that unit
- Attack if adjacent after movement
- Otherwise wait after completing movement

## 8. Player Experience Requirements

### 8.1 Input

- Support touch as the primary interaction model
- Support mouse in development builds
- Large tap targets for core actions
- Use simple and readable HUD actions

### 8.2 Feedback

- Clear selected-unit state
- Clear reachable-tile visualization
- Clear attackable-target state
- Clear turn-phase indication
- Clear victory and defeat popup UI

### 8.3 UX Simplicity

- No overloaded menus in MVP
- No hidden long-press dependencies
- Keep action choices visible and minimal
- Prefer direct tap flow over nested windows

## 9. Systems Breakdown

### 9.1 Battle Controller

Owns the battle state machine and high-level phase transitions.

Responsibilities:

- load stage setup
- coordinate player and enemy phases
- route requests to services
- resolve win/loss conditions

### 9.2 Turn Manager

Owns unit activation state.

Responsibilities:

- determine whose turn it is
- mark units as acted
- transition between player and enemy phases

### 9.3 Path Service

Owns movement path calculation.

Responsibilities:

- build or refresh pathfinding grid
- calculate reachable movement tiles
- provide movement path to a selected destination

### 9.4 Range Service

Owns range calculations.

Responsibilities:

- determine move range
- determine attack range
- determine valid target cells

### 9.5 Combat Service

Owns damage and battle resolution.

Responsibilities:

- calculate attack results
- apply HP changes
- determine unit defeat

### 9.6 AI Service

Owns enemy decision logic.

Responsibilities:

- choose target
- choose move tile
- trigger attack or wait action

## 10. Data Model Requirements

All gameplay values must live in data resources, not in scene-node inspector values unless they are purely visual layout values.

### 10.1 Unit Data

At minimum:

- unit id
- display name
- faction
- max HP
- attack
- defense
- movement
- attack range

### 10.2 Skill Data

At minimum:

- skill id
- display name
- range
- power or damage modifier
- targeting rule

MVP may use one basic attack skill only, but it should still be represented as data.

### 10.3 Stage Data

At minimum:

- stage id
- map reference
- ally spawn positions
- enemy spawn positions
- win condition
- loss condition

## 11. Map Data Requirements

Tile data should support custom metadata so tile-based rules are not hardcoded into controller logic.

Required custom fields:

- `move_cost`
- `terrain_type`
- `blocked`

Planned extension field:

- `defense_bonus`

## 12. Scene and Folder Baseline

```text
project/
  scenes/
    battle/
      BattleScene.tscn
      Unit.tscn
      GridCursor.tscn
      BattleHUD.tscn
  scripts/
    battle/
      battle_controller.gd
      turn_manager.gd
      path_service.gd
      range_service.gd
      combat_service.gd
      ai_service.gd
      input_controller.gd
    data/
      unit_data.gd
      skill_data.gd
      stage_data.gd
  data/
    units/
    skills/
    stages/
  docs/
    game_spec.md
    engineering_rules.md
    codex_workflow.md
```

## 13. Milestones

### Phase 1: First Playable Vertical Slice

- one stage
- one full battle from start to finish
- no script errors on project open
- no plugin dependency

### Phase 2: Tactical Depth Pass

- terrain metadata applied to combat and movement more fully
- smarter enemy AI
- cleaner mobile HUD
- externalized stage and placement data

### Phase 3: Deployment Readiness

- Android export setup
- device input validation
- performance pass on low-complexity scenes

## 14. IP and Content Direction

- Use original names, art direction, maps, story, and UI
- Inspiration from classic SRPG structure is acceptable
- Do not imitate proprietary characters, scenario text, or copyrighted assets

## 15. Definition of MVP Success

The MVP is successful when:

- the project opens without script errors
- one full battle can be completed from start to finish
- all gameplay-critical values are data-driven
- the mobile interaction flow is understandable without extra explanation
- the codebase remains simple enough for Codex to extend task by task
