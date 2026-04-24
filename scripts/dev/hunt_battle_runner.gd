extends SceneTree

const CampController = preload("res://scripts/camp/camp_controller.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CutsceneCatalog = preload("res://data/cutscenes/cutscene_catalog.gd")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var progression := ProgressionData.new()
	progression.unlocked_hunt_ids = [&"hunt_basil", &"hunt_saria", &"hunt_lete"]

	var camp := CampController.new()
	root.add_child(camp)
	await process_frame
	camp.enter_camp(&"ch08", {}, progression)

	for hunt_case in [
		{"hunt_id": &"hunt_basil", "stage_id": &"HUNT_BASIL", "title": "회상 토벌전: 바실", "objective_id": "hunt_basil_flood_rise_survived", "start_cutscene_id": &"hunt_basil_launch", "clear_cutscene_id": &"hunt_basil_return", "min_enemy_count": 3, "required_blocked": Vector2i(6, 2), "required_terrain": {"cell": Vector2i(4, 2), "type": "flooded"}, "required_object_id": "hunt_basil_sluice_wheel"},
		{"hunt_id": &"hunt_saria", "stage_id": &"HUNT_SARIA", "title": "회상 토벌전: 사리아", "objective_id": "hunt_saria_queue_preserved", "start_cutscene_id": &"hunt_saria_launch", "clear_cutscene_id": &"hunt_saria_return", "min_enemy_count": 3, "required_blocked": Vector2i(9, 4), "required_terrain": {"cell": Vector2i(8, 2), "type": "hymn"}, "required_object_id": "hunt_saria_choir_lectern"},
		{"hunt_id": &"hunt_lete", "stage_id": &"HUNT_LETE", "title": "회상 토벌전: 레테", "objective_id": "hunt_lete_black_hounds_preserved", "start_cutscene_id": &"hunt_lete_launch", "clear_cutscene_id": &"hunt_lete_return", "min_enemy_count": 3, "required_blocked": Vector2i(7, 4), "required_terrain": {"cell": Vector2i(6, 2), "type": "shadow"}, "required_object_id": "hunt_lete_gate_latch"},
	]:
		if not camp.select_hunt(hunt_case.hunt_id):
			return _fail("CampController should allow selecting unlocked hunt %s." % String(hunt_case.hunt_id))
		var resolved_stage = camp.get_selected_hunt_stage()
		if resolved_stage == null:
			return _fail("Selected hunt %s should resolve to StageData." % String(hunt_case.hunt_id))
		if resolved_stage.stage_id != hunt_case.stage_id:
			return _fail("Selected hunt %s should resolve stage id %s, got %s." % [String(hunt_case.hunt_id), String(hunt_case.stage_id), String(resolved_stage.stage_id)])
		if resolved_stage.stage_title != hunt_case.title:
			return _fail("Selected hunt %s should expose the hunt title." % String(hunt_case.hunt_id))
		if resolved_stage.optional_objectives.is_empty():
			return _fail("Hunt stage %s should expose a hunt-specific optional objective." % String(hunt_case.stage_id))
		var first_objective: Dictionary = resolved_stage.optional_objectives[0]
		if String(first_objective.get("id", "")) != String(hunt_case.objective_id):
			return _fail("Hunt stage %s should expose objective %s." % [String(hunt_case.stage_id), String(hunt_case.objective_id)])
		if resolved_stage.start_cutscene_id != hunt_case.start_cutscene_id:
			return _fail("Hunt stage %s should expose start_cutscene_id %s." % [String(hunt_case.stage_id), String(hunt_case.start_cutscene_id)])
		if resolved_stage.clear_cutscene_id != hunt_case.clear_cutscene_id:
			return _fail("Hunt stage %s should expose clear_cutscene_id %s." % [String(hunt_case.stage_id), String(hunt_case.clear_cutscene_id)])
		var start_cutscene = CutsceneCatalog.get_cutscene(resolved_stage.start_cutscene_id)
		var clear_cutscene = CutsceneCatalog.get_cutscene(resolved_stage.clear_cutscene_id)
		if start_cutscene == null or start_cutscene.get_beat_count() <= 0:
			return _fail("Hunt stage %s should resolve a valid start cutscene." % String(hunt_case.stage_id))
		if clear_cutscene == null or clear_cutscene.get_beat_count() <= 0:
			return _fail("Hunt stage %s should resolve a valid clear cutscene." % String(hunt_case.stage_id))

		var battle = BATTLE_SCENE.instantiate()
		root.add_child(battle)
		await process_frame
		if not camp.launch_selected_hunt_battle(battle):
			return _fail("CampController should launch selected hunt %s into battle." % String(hunt_case.hunt_id))
		if battle.stage_data == null or battle.stage_data.stage_id != hunt_case.stage_id:
			return _fail("BattleController should load %s after hunt launch." % String(hunt_case.stage_id))
		if battle.enemy_units.is_empty():
			return _fail("Hunt battle %s should spawn at least one enemy." % String(hunt_case.stage_id))
		if battle.enemy_units.size() < int(hunt_case.min_enemy_count):
			return _fail("Hunt battle %s should spawn at least %d enemies after the variation pass." % [String(hunt_case.stage_id), int(hunt_case.min_enemy_count)])
		if battle.interactive_objects.size() < 1:
			return _fail("Hunt battle %s should author at least one interactive object after the rule-object pass." % String(hunt_case.stage_id))
		var saw_boss: bool = false
		for enemy in battle.enemy_units:
			if is_instance_valid(enemy) and enemy.unit_data != null and enemy.unit_data.is_boss:
				saw_boss = true
				break
		if not saw_boss:
			return _fail("Hunt battle %s should include a boss enemy." % String(hunt_case.stage_id))
		var object_actor = battle.interactive_objects[0]
		if String(object_actor.object_data.object_id) != String(hunt_case.required_object_id):
			return _fail("Hunt battle %s should expose object %s." % [String(hunt_case.stage_id), String(hunt_case.required_object_id)])
		if not battle.stage_data.blocked_cells.has(hunt_case.required_blocked):
			return _fail("Hunt battle %s should include blocked cell %s after the variation pass." % [String(hunt_case.stage_id), str(hunt_case.required_blocked)])
		var required_terrain: Dictionary = hunt_case.required_terrain
		var terrain_cell: Vector2i = required_terrain.get("cell", Vector2i.ZERO)
		var terrain_type: String = String(required_terrain.get("type", ""))
		if String(battle.stage_data.get_terrain_type(terrain_cell)) != terrain_type:
			return _fail("Hunt battle %s should expose terrain type %s at %s after the variation pass." % [String(hunt_case.stage_id), terrain_type, str(terrain_cell)])
		var ally = battle.ally_units[0]
		ally.set_grid_position(object_actor.grid_position + Vector2i(0, 1), battle.stage_data.cell_size)
		battle._resolve_interaction(ally, object_actor)
		match String(hunt_case.stage_id):
			"HUNT_BASIL":
				if not bool(battle.battle_objective_flags.get("hunt_basil_sluice_open", false)):
					return _fail("HUNT_BASIL interaction should open the sluice rule flag.")
			"HUNT_SARIA":
				if not bool(battle.battle_objective_flags.get("hunt_saria_choir_lectern", false)):
					return _fail("HUNT_SARIA interaction should set the choir lectern rule flag.")
			"HUNT_LETE":
				if not bool(battle.battle_objective_flags.get("hunt_lete_gate_latch", false)):
					return _fail("HUNT_LETE interaction should set the gate latch rule flag.")
		battle.queue_free()
		await process_frame

	print("[PASS] hunt_battle_runner: hunt selection resolves real StageData and battle bootstraps for all hunts.")
	quit(0)

func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	push_error(message)
	quit(1)
