extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_saria_mind_control_phase_uses_charm():
		return
	print("[PASS] saria_mind_control_runner: all assertions passed.")
	quit(0)

func _assert_saria_mind_control_phase_uses_charm() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var stage := StageData.new()
	stage.stage_id = &"saria_mind_control_stage"
	stage.stage_title = "Saria Mind Control"
	stage.grid_size = Vector2i(6, 6)
	stage.cell_size = Vector2i(64, 64)
	stage.win_condition = &"defeat_all_enemies"
	stage.ally_units = [_make_ally(&"ally_rian", "Rian"), _make_ally(&"ally_serin", "Serin")]
	stage.enemy_units = [load("res://data/units/enemy_saria.tres")]
	stage.ally_spawns = [Vector2i(1, 4), Vector2i(2, 4)]
	stage.enemy_spawns = [Vector2i(2, 2)]
	battle.set_stage(stage)
	await process_frame
	await process_frame

	var saria = battle.enemy_units[0]
	battle.boss_phase_by_unit[saria.get_instance_id()] = &"mind_control"
	var action: Dictionary = battle._ai_action_saria(saria)
	if String(action.get("type", "")) != "charm_gaze":
		return _fail("Saria mind_control phase should prioritize charm_gaze.")

	battle._apply_enemy_action(saria, action)
	await process_frame
	await process_frame

	var target = battle.ally_units[0]
	if battle._get_unit_visual_status_turns(target, &"charm") <= 0 and battle._get_unit_visual_status_turns(battle.ally_units[1], &"charm") <= 0:
		return _fail("Saria charm_gaze should apply charm to an ally target.")
	if not bool(battle.battle_objective_flags.get("saria_mind_control_active", false)):
		return _fail("Saria mind control should expose a battle objective/runtime flag.")
	if battle.hud.transition_reason_label.text.find("Mind Control Applied") == -1:
		return _fail("Saria mind control should expose a dedicated HUD reason.")

	battle.queue_free()
	await process_frame
	return true

func _make_ally(unit_id: StringName, display_name: String) -> UnitData:
	var unit := UnitData.new()
	unit.unit_id = unit_id
	unit.display_name = display_name
	unit.faction = "ally"
	unit.max_hp = 12
	unit.attack = 4
	unit.defense = 1
	unit.movement = 3
	unit.attack_range = 1
	unit.default_skill = load("res://data/skills/basic_attack.tres")
	return unit

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
