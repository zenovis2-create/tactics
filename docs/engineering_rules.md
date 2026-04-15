# Engineering Rules

## 1. Technical Baseline

- Use Godot `4.x`
- Use `GDScript` only
- Use `TileMapLayer`, not deprecated `TileMap`
- Use `AStarGrid2D` for square-grid pathfinding
- Use `Resource` files for `UnitData`, `SkillData`, and `StageData`
- Keep the project runnable after each completed task

## 2. Architecture Rules

- Separate gameplay logic from scene composition
- Separate code from balance and content data
- Prefer small services with single responsibilities
- Keep battle flow stateful but explicit
- Avoid hidden cross-scene dependencies

## 2.5 Campaign Shell Rules

- `main.gd` owns top-level boot wiring only
- `campaign_controller.gd` owns chapter flow orchestration and volatile session state only
- Authored chapter order, cutscene copy, reward tables, and unlock tables must not keep growing inside controller scripts
- Move authored campaign content into `data/` resources or dedicated registry/session modules before expanding another chapter tranche
- `campaign_panel.gd` and any future camp UI scripts are presentation only and must not calculate progression rules
- Battle controllers and services must not own chapter routing, camp state, or records presentation

## 3. Ownership by Script

### `battle_controller.gd`

- battle state machine
- phase changes
- win/loss checks
- orchestration between services

### `turn_manager.gd`

- unit activation order
- action completion state
- phase completion checks

### `path_service.gd`

- grid generation
- reachable cell queries
- path generation

### `range_service.gd`

- movement range
- attack range
- targetable cell queries

### `combat_service.gd`

- damage calculation
- HP updates
- unit defeat handling

### `ai_service.gd`

- enemy target selection
- movement decision
- attack or wait decision

### `input_controller.gd`

- touch and mouse interaction routing
- unit selection
- tile selection
- action confirmation input

## 4. Data Rules

- Do not hardcode unit stats in scene nodes
- Do not hardcode stage placements in unrelated controller scripts
- Store gameplay values in `Resource` assets under `data/`
- Keep scene files focused on layout, references, and visuals
- Treat battle values as editable content, not implementation constants

## 5. Tile Rules

- Terrain meaning must come from tile metadata
- Required tile metadata keys:
  - `move_cost`
  - `terrain_type`
  - `blocked`
- Optional planned key:
  - `defense_bonus`

## 6. UI and UX Rules

- Mobile-first HUD layout
- Large buttons for attack, wait, and cancel style actions
- Avoid tiny text and crowded controls
- Prefer one-tap actions where possible
- Maintain readable state feedback for selected unit, reachable cells, and current phase

## 7. Project Hygiene Rules

- Do not add plugins unless explicitly requested
- Do not refactor unrelated files
- Do not introduce C# or GDExtension for MVP
- Do not add premature meta-systems such as save, growth, inventory, or online features
- Keep file names and script names predictable and stable

## 8. Content Expansion Rules

Only add new systems after the current battle loop is stable.

Priority order:

1. Base battle loop
2. Terrain metadata integration
3. Better AI
4. Better HUD
5. Externalized stage data
6. Android export setup

## 8.5 Release And Export Rules

- Do not claim export readiness without a committed `export_presets.cfg`
- Do not claim demo-ready or release-ready without target-platform validation evidence
- Treat headless runner passes as build stability evidence, not as export validation
- Keep platform-specific setup and validation notes in docs once export work starts

## 9. Task Execution Rules for Codex

Every implementation task should:

- target one feature at a time
- include explicit acceptance criteria
- avoid incidental cleanup outside task scope
- end with a short changed-files summary
- end with a separate TODO list for follow-up work

## 10. Done Criteria

A task is only considered done when:

- the project still opens cleanly
- changed scripts do not produce syntax errors
- the target feature is manually testable
- any locally available checks have been run
- obvious reproducible issues found during the task have been fixed
