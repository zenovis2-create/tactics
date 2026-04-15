# Milestone Runnable Gates

This project must remain runnable after each milestone.

## Gate 0: Skeleton Integrity

- `project.godot` points to a valid `run/main_scene`.
- All `.tscn` ext_resource paths resolve.
- All `.tres` script/resource references resolve.
- Scripts define expected classes for scene attachments.

## Gate 1: Vertical Slice Loop

- Player can select ally unit.
- Reachable tiles can be queried from `PathService`.
- Unit can move and resolve one attack or wait.
- Enemy phase executes from `AIService`.
- Victory/defeat popup appears.
- Battle phase transitions are explicit and logged with reasons.
- Per-unit action state follows `READY -> MOVED -> ACTED -> EXHAUSTED` or `DOWNED`.
- `Main` can still boot a battle directly through the campaign shell without scene wiring errors.

## Gate 1.5: Campaign Shell Glue

- `Main` can load the Chapter 1 ordered stage chain without moving progression logic into `BattleController`.
- Stage clear can hand off into a placeholder cutscene panel.
- Final Chapter 1 clear can hand off into a placeholder camp/interlude panel.
- Existing battle smoke coverage remains green after shell integration.

## Gate 2: Tactical Depth

- Terrain metadata (`move_cost`, `terrain_type`, `blocked`) influences movement/combat.
- AI uses threat-aware decision model.
- HUD remains touch-readable on mobile dimensions.

## Gate 3: Deployment Readiness

- Android export template validated.
- Input checked on at least one touch device.
- Target scene runs at acceptable performance for MVP map complexity.

## Validation Steps

Promotion note:

- Use `docs/release_confidence_policy.md` to decide whether a build or patch can move forward after these milestone checks pass.

If Godot is installed locally:

1. `godot4 --headless --path . --quit`
2. `godot4 --headless --path . --script res://scripts/dev/m1_playtest_runner.gd`
3. `godot4 --headless --path . --script res://scripts/dev/m2_campaign_flow_runner.gd`
4. `godot4 --path .` and run one full battle manually if milestone scope requires interactive verification.
5. Record failures and fix before advancing milestone status.

If Godot is not installed in current environment:

1. Run `scripts/dev/check_runnable_gate0.sh`.
2. Keep scene/script/resource names stable.
3. Defer runtime validation to the next environment with Godot installed.
