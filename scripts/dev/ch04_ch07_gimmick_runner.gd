extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH04_STAGE = preload("res://data/stages/ch04_05_stage.tres")
const CH07_STAGE = preload("res://data/stages/ch07_05_stage.tres")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_ch04_flooded_survival_flag():
		return
	if not await _assert_ch07_mira_recruit_flag():
		return
	if not await _assert_ch04_flood_spread_pressure():
		return
	if not await _assert_ch07_civilian_pressure_failure():
		return
	if not await _assert_ch07_single_objective_buys_time():
		return
	print("[PASS] ch04_ch07_gimmick_runner: all assertions passed.")
	quit(0)

func _assert_ch04_flooded_survival_flag() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var stage = CH04_STAGE.duplicate(true)
	stage.set("ally_spawns", [Vector2i(1, 2), Vector2i(2, 2)])
	stage.set("enemy_spawns", [Vector2i(6, 1), Vector2i(6, 2)])
	battle.set_stage(stage)
	await process_frame
	await process_frame

	battle._handle_stage_move_flags(battle.ally_units[0], Vector2i(1, 1))
	await process_frame

	if not bool(battle.battle_objective_flags.get("ark_survives_flooded_section", false)):
		return _fail("CH04_05 should mark flooded-section survival when the vanguard reaches flooded ground.")

	battle.queue_free()
	await process_frame
	return true

func _assert_ch07_mira_recruit_flag() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var stage = CH07_STAGE.duplicate(true)
	battle.set_stage(stage)
	await process_frame
	await process_frame

	battle._handle_stage_interaction_flags("ch07_05_city_seal")
	battle._handle_stage_interaction_flags("ch07_05_prayer_dais")
	await process_frame

	if not bool(battle.battle_objective_flags.get("collect_city_seal", false)):
		return _fail("CH07_05 should still mark collect_city_seal after city seal interaction.")
	if not bool(battle.battle_objective_flags.get("prayer_dais_secured", false)):
		return _fail("CH07_05 should still mark prayer_dais_secured after dais interaction.")
	if not bool(battle.battle_objective_flags.get("recruit_mira", false)):
		return _fail("CH07_05 should recruit Mira once the city seal and prayer dais are both secured.")

	battle.queue_free()
	await process_frame
	return true

func _assert_ch04_flood_spread_pressure() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var stage = CH04_STAGE.duplicate(true)
	battle.set_stage(stage)
	await process_frame
	await process_frame

	battle.battle_objective_flags["basil_altar_purged"] = true
	battle._update_stage_pressure_state()
	await process_frame

	if not bool(battle.battle_objective_flags.get("basil_flood_risen", false)):
		return _fail("CH04_05 should mark basil_flood_risen after altar purge pressure spreads the flood.")
	if battle.stage_data.get_terrain_type(Vector2i(2, 1)) != &"flooded":
		return _fail("CH04_05 flood pressure should convert adjacent altar cells into flooded terrain.")
	if not bool(battle.battle_objective_flags.get("basil_logs_at_risk", false)):
		return _fail("CH04_05 should mark basil_logs_at_risk once the flood reaches unrecovered research logs.")
	battle._update_stage_pressure_state()
	await process_frame
	if not bool(battle.battle_objective_flags.get("basil_logs_lost", false)):
		return _fail("CH04_05 should eventually mark basil_logs_lost if flooded research logs remain unrecovered.")

	battle.queue_free()
	await process_frame
	return true

func _assert_ch07_civilian_pressure_failure() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var stage = CH07_STAGE.duplicate(true)
	battle.set_stage(stage)
	await process_frame
	await process_frame

	for _turn in range(4):
		battle._update_stage_pressure_state()
		await process_frame

	if not bool(battle.battle_objective_flags.get("mira_queue_at_risk", false)):
		return _fail("CH07_05 should surface mira_queue_at_risk before the rescue window collapses.")
	if not bool(battle.battle_objective_flags.get("mira_queue_lost", false)):
		return _fail("CH07_05 should eventually mark mira_queue_lost if the prayer line is ignored.")

	battle.queue_free()
	await process_frame
	return true

func _assert_ch07_single_objective_buys_time() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var stage = CH07_STAGE.duplicate(true)
	battle.set_stage(stage)
	await process_frame
	await process_frame

	battle._handle_stage_interaction_flags("ch07_05_city_seal")
	for _turn in range(4):
		battle._update_stage_pressure_state()
		await process_frame

	if bool(battle.battle_objective_flags.get("mira_queue_lost", false)):
		return _fail("CH07_05 should buy extra time if one of the rescue objectives is secured early.")
	if int(battle.battle_runtime_counters.get("ch07_civilian_pressure_turns", 0)) >= 4:
		return _fail("CH07_05 should accumulate civilian pressure more slowly after one rescue objective is secured.")

	battle.queue_free()
	await process_frame
	return true

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
