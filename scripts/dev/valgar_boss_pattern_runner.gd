extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH06_05_STAGE = preload("res://data/stages/ch06_05_stage.tres")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_valgar_fortify_surface():
		return
	if not await _assert_ch06_keep_interaction_objective():
		return
	print("[PASS] valgar_boss_pattern_runner: all assertions passed.")
	quit(0)

func _spawn_battle() -> Node:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	battle.set_stage(CH06_05_STAGE)
	await process_frame
	await process_frame
	return battle

func _assert_valgar_fortify_surface() -> bool:
	var battle = await _spawn_battle()
	var boss = battle.enemy_units[0]
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"fortification"
	var action: Dictionary = battle._ai_action_valgar(boss)
	if String(action.get("type", "")) != "valgar_fortify":
		return _fail("CH06_05 fortification phase should prioritize valgar_fortify.")
	battle._apply_enemy_action(boss, action)
	await process_frame
	if not bool(battle.battle_objective_flags.get("valgar_fortified", false)):
		return _fail("CH06_05 valgar_fortify should expose valgar_fortified.")
	if int(battle.enemy_damage_reduction_turns_by_unit.get(boss.get_instance_id(), 0)) <= 0:
		return _fail("CH06_05 valgar_fortify should grant active damage reduction turns to the boss.")
	if float(battle.enemy_damage_multiplier_by_unit.get(boss.get_instance_id(), 1.0)) >= 1.0:
		return _fail("CH06_05 valgar_fortify should reduce incoming damage multiplier for the boss.")
	if String(battle.hud.transition_reason_label.text).strip_edges().is_empty():
		return _fail("CH06_05 valgar_fortify should surface a readable HUD transition reason.")
	battle.queue_free()
	await process_frame
	return true

func _assert_ch06_keep_interaction_objective() -> bool:
	var battle = await _spawn_battle()
	var ally = battle.ally_units[0]
	if battle.interactive_objects.size() < 2:
		return _fail("CH06_05 should spawn keep interaction objects for Valgar objective routing.")
	var keep_dais = battle.interactive_objects[0]
	var barricade_latch = battle.interactive_objects[1]
	if StringName(keep_dais.object_data.object_id) != &"ch06_05_keep_dais":
		return _fail("CH06_05 keep dais interaction order drifted.")
	if StringName(barricade_latch.object_data.object_id) != &"ch06_05_barricade_latch":
		return _fail("CH06_05 barricade latch interaction order drifted.")
	ally.set_grid_position(keep_dais.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, keep_dais)
	await process_frame
	ally.set_grid_position(barricade_latch.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
	battle._resolve_interaction(ally, barricade_latch)
	await process_frame
	if not bool(battle.battle_objective_flags.get("fort_resistance_zero", false)):
		return _fail("CH06_05 should complete fort_resistance_zero after both keep interactions resolve.")
	var objective_state: Dictionary = battle.get_objective_state_snapshot()
	if StringName(objective_state.get("state_id", &"")) != &"valgar_keep_broken":
		return _fail("CH06_05 objective state should advance to valgar_keep_broken after both interactions.")
	if String(battle.hud.objective_label.text).find("완전히 무너졌다") == -1:
		return _fail("CH06_05 objective surface should advance to the fully-broken keep text after both interactions.")
	battle.queue_free()
	await process_frame
	return true

func _fail(message: String) -> bool:
	if _failed:
		return false
	_failed = true
	push_error(message)
	quit(1)
	return false
