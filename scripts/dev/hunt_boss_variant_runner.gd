extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const HUNT_BASIL = preload("res://data/stages/hunt_basil_stage.tres")
const HUNT_SARIA = preload("res://data/stages/hunt_saria_stage.tres")
const HUNT_LETE = preload("res://data/stages/hunt_lete_stage.tres")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_hunt_basil_prefers_flood_pressure():
		return
	if not await _assert_hunt_basil_switches_to_banner_after_flood_survival():
		return
	if not await _assert_hunt_basil_backwash_after_flood_survival():
		return
	if not await _assert_hunt_saria_prefers_queue_break():
		return
	if not await _assert_hunt_saria_escalates_to_oblivion_field():
		return
	if not await _assert_hunt_saria_switches_to_memory_burn_after_queue_loss():
		return
	if not await _assert_hunt_saria_choir_break_after_queue_loss():
		return
	if not await _assert_hunt_lete_prefers_hound_cover():
		return
	if not await _assert_hunt_lete_switches_to_shadow_feint_after_hounds_break():
		return
	if not await _assert_hunt_lete_prefers_reckless_charge_on_marked_target_after_hound_loss():
		return
	print("[PASS] hunt_boss_variant_runner: all assertions passed.")
	quit(0)

func _assert_hunt_basil_prefers_flood_pressure() -> bool:
	var battle = await _make_battle(HUNT_BASIL)
	var boss = battle.enemy_units[0]
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"flood_rise"
	var action: Dictionary = battle._ai_action_basil(boss)
	if String(action.get("type", "")) != "basil_altar_purge":
		return _fail("HUNT_BASIL should prioritize basil_altar_purge during flood_rise.")
	battle.queue_free()
	return true

func _assert_hunt_basil_switches_to_banner_after_flood_survival() -> bool:
	var battle = await _make_battle(HUNT_BASIL)
	var boss = battle.enemy_units[0]
	boss.set_grid_position(Vector2i(6, 2), battle.stage_data.cell_size)
	battle.ally_units[0].set_grid_position(Vector2i(6, 3), battle.stage_data.cell_size)
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"purge_judgment"
	battle.battle_objective_flags["hunt_basil_flood_rise_survived"] = true
	var action: Dictionary = battle._ai_action_basil(boss)
	if String(action.get("type", "")) != "hunt_basil_backwash_surge":
		return _fail("HUNT_BASIL should switch to hunt_basil_backwash_surge once the flood survival objective is already secured.")
	battle.queue_free()
	return true

func _assert_hunt_basil_backwash_after_flood_survival() -> bool:
	var battle = await _make_battle(HUNT_BASIL)
	var boss = battle.enemy_units[0]
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"purge_judgment"
	battle.battle_objective_flags["hunt_basil_flood_rise_survived"] = true
	battle._use_hunt_basil_backwash_surge(boss)
	if not bool(battle.battle_objective_flags.get("hunt_basil_backwash_surge", false)):
		return _fail("HUNT_BASIL should surface hunt_basil_backwash_surge when Basil turns the secured floodline back on the player.")
	if String(battle.stage_data.get_terrain_type(Vector2i(4, 2))) != "flooded":
		return _fail("HUNT_BASIL backwash surge should extend flood pressure deeper into the central lane.")
	battle.queue_free()
	return true

func _assert_hunt_saria_prefers_queue_break() -> bool:
	var battle = await _make_battle(HUNT_SARIA)
	var boss = battle.enemy_units[0]
	boss.set_grid_position(Vector2i(2, 2), battle.stage_data.cell_size)
	battle.ally_units[0].set_grid_position(Vector2i(2, 3), battle.stage_data.cell_size)
	battle.ally_units[1].set_grid_position(Vector2i(3, 3), battle.stage_data.cell_size)
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"civilian_unrest"
	var action: Dictionary = battle._ai_action_saria(boss)
	if String(action.get("type", "")) != "charm_gaze":
		return _fail("HUNT_SARIA should prioritize charm_gaze to break the queue early.")
	battle.queue_free()
	return true

func _assert_hunt_saria_escalates_to_oblivion_field() -> bool:
	var battle = await _make_battle(HUNT_SARIA)
	var boss = battle.enemy_units[0]
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"mind_control"
	battle.battle_runtime_counters["hunt_saria_queue_turns"] = 2
	var action: Dictionary = battle._ai_action_saria(boss)
	if String(action.get("type", "")) != "saria_oblivion_field":
		return _fail("HUNT_SARIA should escalate to saria_oblivion_field once queue pressure is already late.")
	battle.queue_free()
	return true

func _assert_hunt_saria_switches_to_memory_burn_after_queue_loss() -> bool:
	var battle = await _make_battle(HUNT_SARIA)
	var boss = battle.enemy_units[0]
	boss.set_grid_position(Vector2i(9, 2), battle.stage_data.cell_size)
	battle.ally_units[0].set_grid_position(Vector2i(9, 3), battle.stage_data.cell_size)
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"final_purge"
	battle.battle_objective_flags.erase("hunt_saria_queue_preserved")
	var action: Dictionary = battle._ai_action_saria(boss)
	if String(action.get("type", "")) != "hunt_saria_choir_break":
		return _fail("HUNT_SARIA should switch to hunt_saria_choir_break once the queue preservation objective is lost.")
	battle.queue_free()
	return true

func _assert_hunt_saria_choir_break_after_queue_loss() -> bool:
	var battle = await _make_battle(HUNT_SARIA)
	var boss = battle.enemy_units[0]
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"final_purge"
	battle.battle_objective_flags.erase("hunt_saria_queue_preserved")
	battle._use_hunt_saria_choir_break(boss)
	if not bool(battle.battle_objective_flags.get("hunt_saria_choir_break", false)):
		return _fail("HUNT_SARIA should surface hunt_saria_choir_break when the prayer line has already collapsed.")
	for ally in battle.ally_units:
		if ally == null or not is_instance_valid(ally):
			continue
		if int(battle._get_unit_visual_status_turns(ally, &"fear")) <= 0:
			return _fail("HUNT_SARIA choir break should leave allies in a fear state.")
	battle.queue_free()
	return true

func _assert_hunt_lete_prefers_hound_cover() -> bool:
	var battle = await _make_battle(HUNT_LETE)
	var boss = battle.enemy_units[0]
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"berserk_rush"
	battle.battle_objective_flags["hunt_lete_black_hounds_preserved"] = true
	var action: Dictionary = battle._ai_action_lete(boss)
	if String(action.get("type", "")) != "lete_scatter_cover":
		return _fail("HUNT_LETE should prioritize lete_scatter_cover while the black-hound preservation objective is still active.")
	battle.queue_free()
	return true

func _assert_hunt_lete_switches_to_shadow_feint_after_hounds_break() -> bool:
	var battle = await _make_battle(HUNT_LETE)
	var boss = battle.enemy_units[0]
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"berserk_rush"
	battle.battle_objective_flags.erase("hunt_lete_black_hounds_preserved")
	var action: Dictionary = battle._ai_action_lete(boss)
	if String(action.get("type", "")) != "lete_shadow_feint":
		return _fail("HUNT_LETE should switch to lete_shadow_feint once black-hound preservation is lost.")
	battle.queue_free()
	return true

func _assert_hunt_lete_prefers_reckless_charge_on_marked_target_after_hound_loss() -> bool:
	var battle = await _make_battle(HUNT_LETE)
	var boss = battle.enemy_units[0]
	var target = battle.ally_units[0]
	boss.set_grid_position(Vector2i(7, 2), battle.stage_data.cell_size)
	target.set_grid_position(Vector2i(7, 3), battle.stage_data.cell_size)
	battle.boss_phase_by_unit[boss.get_instance_id()] = &"berserk_rush"
	battle.battle_objective_flags.erase("hunt_lete_black_hounds_preserved")
	battle._set_unit_visual_status(target, &"mark", 2)
	var action: Dictionary = battle._ai_action_lete(boss)
	if String(action.get("type", "")) != "lete_black_hound_execute":
		return _fail("HUNT_LETE should prefer lete_black_hound_execute against a marked ally once black-hound preservation is lost.")
	battle.queue_free()
	return true

func _make_battle(stage_res: Resource):
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame
	battle.set_stage(stage_res.duplicate(true))
	await process_frame
	await process_frame
	return battle

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
