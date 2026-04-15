# Codex Workflow

## 1. Working Principle

Codex performs best on this project when tasks are small, bounded, and validated with explicit acceptance criteria.

Avoid prompts like:

- "make the whole game"
- "build everything for the SRPG"

Prefer prompts that define:

- exact scope
- technical constraints
- acceptance criteria
- verification expectations

## 2. Required Context for Every Task

Start implementation prompts with:

```text
Read docs/game_spec.md and docs/engineering_rules.md first.
```

Then restate the project context:

```text
We are building a mobile-first 2D tactics RPG in Godot 4.
```

## 3. Standard Constraint Block

Use this block as the default constraint set:

```text
Constraints:
- GDScript only
- Use TileMapLayer, not TileMap
- Use Resource-based data for UnitData, SkillData, and StageData
- Use AStarGrid2D for pathfinding
- Keep the project runnable after changes
- Do not add plugins
```

## 4. First Vertical Slice Prompt

```text
Read docs/game_spec.md and docs/engineering_rules.md first.

We are building a mobile-first 2D tactics RPG in Godot 4.
Constraints:
- GDScript only
- Use TileMapLayer, not TileMap
- Use Resource-based data for UnitData, SkillData, and StageData
- Use AStarGrid2D for pathfinding
- Keep the project runnable after changes
- Do not add plugins

Task:
Create the first vertical slice of the battle prototype.

Required features:
- One BattleScene with an 8x8 square grid
- 2 ally units and 2 enemy units
- Click/tap a unit to select it
- Show reachable tiles
- Move to a selected tile
- Attack an adjacent enemy
- Wait to end the unit's action
- Enemy phase with simple nearest-target AI
- Victory and defeat popup UI

Acceptance criteria:
- The project opens without script errors
- One full battle can be played from start to finish
- Balance values are stored in data resources, not hardcoded in scene nodes
- Changed files are summarized at the end
- Remaining TODOs are listed separately

After making changes, run available checks and fix syntax/runtime issues you can reproduce.
```

## 5. Follow-Up Task Order

Use the following order after the first battle loop works:

1. Apply `move_cost`, `terrain_type`, and `defense_bonus` through tile custom data
2. Expand enemy AI from nearest-target logic to range and threat-aware logic
3. Improve mobile HUD button size and action layout
4. Externalize stage data and unit placement into `Resource` files
5. Prepare Android export settings and validation notes

## 6. Task Template for Ongoing Work

```text
Read docs/game_spec.md and docs/engineering_rules.md first.

Task:
[one specific feature only]

Constraints:
- [repeat only the relevant technical limits]

Acceptance criteria:
- [observable condition 1]
- [observable condition 2]
- [observable condition 3]

Verification:
- Run available checks
- Fix issues you can reproduce
- Summarize changed files
- List remaining TODOs separately
```

## 7. Practical Operating Rules

- Work on one feature at a time
- Always state completion conditions
- Stabilize the battle system before spending time on art polish
- Finish the desktop battle loop before touch-specific polish
- Validate Android earlier than iOS for first deployment checks
- Keep the project square-grid and top-down until the prototype is stable

## 8. Scope Discipline

Do not expand into the following until the vertical slice is solid:

- save/load
- progression
- equipment
- class systems
- campaign structure
- monetization
- network features

## 9. Why This Workflow Fits the Project

This project benefits from fast local iteration because:

- Godot scene editing is easiest when the game is visible while changes are made
- SRPG prototypes depend on repeated map and UI adjustments
- mobile touch UX needs frequent manual checks
- Codex is more reliable when structure and acceptance criteria are fixed up front
