extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_charmed_ally_forced_attack():
		return
	if not await _assert_bond_guard_restrains_charm():
		return
	if not await _assert_never_forget_cleanses_charm():
		return
	if not await _assert_rescue_repositions_charmed_ally():
		return
	print("[PASS] charm_response_runner: all assertions passed.")
	quit(0)

func _assert_charmed_ally_forced_attack() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var stage := StageData.new()
	stage.stage_id = &"charm_response_stage"
	stage.stage_title = "Charm Response"
	stage.grid_size = Vector2i(5, 5)
	stage.cell_size = Vector2i(64, 64)
	stage.win_condition = &"defeat_all_enemies"
	stage.ally_units = [_make_ally(&"ally_rian", "Rian"), _make_ally(&"ally_serin", "Serin")]
	stage.enemy_units = [_make_enemy()]
	stage.ally_spawns = [Vector2i(1, 3), Vector2i(2, 3)]
	stage.enemy_spawns = [Vector2i(3, 1)]
	battle.set_stage(stage)
	await process_frame
	await process_frame

	var charmed = battle.ally_units[0]
	var target = battle.ally_units[1]
	battle._set_unit_visual_status(charmed, &"charm", 2)
	var target_hp_before: int = target.current_hp

	battle.current_phase = battle.BattlePhase.ROUND_END
	battle._begin_player_phase("charm_test_phase")
	await process_frame
	await process_frame

	if target.current_hp >= target_hp_before:
		return _fail("Charmed ally should force an attack against the nearest ally on player phase start.")
	if battle.turn_manager.get_unit_state(charmed) != battle.turn_manager.STATE_EXHAUSTED:
		return _fail("Charmed ally should be exhausted after the forced attack.")
	if battle.hud.transition_reason_label.text.find("Charm Forced Attack") == -1:
		return _fail("Forced charm action should expose a dedicated HUD reason.")

	battle.queue_free()
	await process_frame
	return true

func _assert_bond_guard_restrains_charm() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var stage := StageData.new()
	stage.stage_id = &"charm_restrain_stage"
	stage.stage_title = "Charm Restrain"
	stage.grid_size = Vector2i(5, 5)
	stage.cell_size = Vector2i(64, 64)
	stage.win_condition = &"defeat_all_enemies"
	stage.ally_units = [_make_ally(&"ally_rian", "Rian"), _make_ally(&"ally_serin", "Serin")]
	stage.enemy_units = [_make_enemy()]
	stage.ally_spawns = [Vector2i(1, 3), Vector2i(2, 3)]
	stage.enemy_spawns = [Vector2i(3, 1)]
	battle.set_stage(stage)
	await process_frame
	await process_frame

	var charmed = battle.ally_units[0]
	var restrainer = battle.ally_units[1]
	battle.bond_service.reset()
	battle.bond_service.apply_bond_delta(&"ally_serin", 5, "charm_restrain_contract")
	battle._set_unit_visual_status(charmed, &"charm", 2)
	var restrainer_hp_before: int = restrainer.current_hp

	battle.current_phase = battle.BattlePhase.ROUND_END
	battle._begin_player_phase("charm_restrain_phase")
	await process_frame
	await process_frame

	if restrainer.current_hp != restrainer_hp_before:
		return _fail("Bond-5 adjacent ally should restrain charm instead of taking friendly-fire damage.")
	if battle.hud.transition_reason_label.text.find("Charm Restrained") == -1:
		return _fail("Charm restraint should expose a dedicated HUD reason.")

	battle.queue_free()
	await process_frame
	return true

func _assert_never_forget_cleanses_charm() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var stage := StageData.new()
	stage.stage_id = &"charm_cleanse_stage"
	stage.stage_title = "Charm Cleanse"
	stage.grid_size = Vector2i(5, 5)
	stage.cell_size = Vector2i(64, 64)
	stage.win_condition = &"defeat_all_enemies"
	stage.ally_units = [load("res://data/units/ally_serin.tres"), load("res://data/units/ally_rian.tres")]
	stage.enemy_units = [_make_enemy()]
	stage.ally_spawns = [Vector2i(1, 3), Vector2i(2, 3)]
	stage.enemy_spawns = [Vector2i(3, 1)]
	battle.set_stage(stage)
	await process_frame
	await process_frame

	var caster = battle.ally_units[0]
	var target = battle.ally_units[1]
	var skill = load("res://data/skills/never_forget.tres")
	battle._set_unit_visual_status(target, &"charm", 2)
	if not battle.try_apply_charm_counterplay(caster, target, skill):
		return _fail("never_forget should resolve as a charm cleanse counterplay.")
	if battle._get_unit_visual_status_turns(target, &"charm") > 0:
		return _fail("Charm cleanse should clear the charm turns from the target.")
	if battle.hud.transition_reason_label.text.find("Charm Cleansed") == -1:
		return _fail("Charm cleanse should expose a dedicated HUD reason.")

	battle.queue_free()
	await process_frame
	return true

func _assert_rescue_repositions_charmed_ally() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var stage := StageData.new()
	stage.stage_id = &"charm_rescue_stage"
	stage.stage_title = "Charm Rescue"
	stage.grid_size = Vector2i(5, 5)
	stage.cell_size = Vector2i(64, 64)
	stage.win_condition = &"defeat_all_enemies"
	stage.ally_units = [load("res://data/units/ally_serin.tres"), load("res://data/units/ally_rian.tres")]
	stage.enemy_units = [_make_enemy()]
	stage.ally_spawns = [Vector2i(1, 3), Vector2i(2, 3)]
	stage.enemy_spawns = [Vector2i(3, 1)]
	battle.set_stage(stage)
	await process_frame
	await process_frame

	var caster = battle.ally_units[0]
	var target = battle.ally_units[1]
	var before_pos: Vector2i = target.grid_position
	var skill = load("res://data/skills/rescue.tres")
	battle._set_unit_visual_status(target, &"charm", 2)
	if not battle.try_apply_charm_counterplay(caster, target, skill):
		return _fail("rescue should resolve as a charm rescue counterplay.")
	if battle._get_unit_visual_status_turns(target, &"charm") > 0:
		return _fail("Charm rescue should clear the charm turns from the target.")
	if target.grid_position == before_pos:
		return _fail("Charm rescue should reposition the target to a nearby open cell.")
	if battle.hud.transition_reason_label.text.find("Charm Rescue") == -1:
		return _fail("Charm rescue should expose a dedicated HUD reason.")

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

func _make_enemy() -> UnitData:
	var unit := UnitData.new()
	unit.unit_id = &"enemy_dummy"
	unit.display_name = "Dummy"
	unit.faction = "enemy"
	unit.max_hp = 8
	unit.attack = 1
	unit.defense = 0
	unit.movement = 3
	unit.attack_range = 1
	unit.default_skill = load("res://data/skills/basic_attack.tres")
	return unit

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
