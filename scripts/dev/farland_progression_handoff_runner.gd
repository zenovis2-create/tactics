extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CutsceneCatalog = preload("res://data/cutscenes/cutscene_catalog.gd")
const StageData = preload("res://scripts/data/stage_data.gd")

const CH01_STAGE: StageData = preload("res://data/stages/ch01_05_stage.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)

	await process_frame
	await process_frame

	battle.set_stage(CH01_STAGE)
	await process_frame
	await process_frame

	var finished_events: Array[Dictionary] = []
	battle.battle_finished.connect(func(result: StringName, stage_id: StringName) -> void:
		finished_events.append({
			"result": result,
			"stage_id": stage_id,
		})
	)

	var cutscene_log_before: int = battle.cutscene_player.get_event_log().size()
	battle.enemy_units.clear()

	if not battle._check_battle_end():
		return _fail("Expected forced victory check to resolve the battle.")

	await process_frame

	if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
		return _fail("Battle should end in VICTORY phase, got %s." % battle._phase_name(int(battle.current_phase)))

	if finished_events.size() != 1:
		return _fail("battle_finished should fire exactly once, got %d." % finished_events.size())

	var finished_event: Dictionary = finished_events[0]
	if finished_event.get("result") != &"victory":
		return _fail("battle_finished should emit victory, got %s." % String(finished_event.get("result", &"")))
	if finished_event.get("stage_id") != CH01_STAGE.stage_id:
		return _fail("battle_finished should preserve stage_id %s, got %s." % [String(CH01_STAGE.stage_id), String(finished_event.get("stage_id", &""))])

	var progression_data = battle.progression_service.get_data()
	if not progression_data.has_fragment(&"ch01_fragment"):
		return _fail("Stage clear should recover ch01_fragment for CH01_05.")
	if not progression_data.has_command(&"tactical_shift"):
		return _fail("Recovering ch01_fragment should unlock tactical_shift.")

	var progression_log: Array[Dictionary] = battle.progression_service.get_event_log()
	if not _has_progression_event(progression_log, "fragment_recovered", "fragment_id", "ch01_fragment"):
		return _fail("Progression log should record fragment_recovered for ch01_fragment.")
	if not _has_progression_event(progression_log, "command_unlocked", "command_id", "tactical_shift"):
		return _fail("Progression log should record tactical_shift unlock.")

	var cutscene_log: Array[Dictionary] = battle.cutscene_player.get_event_log()
	var victory_cutscene_entries := cutscene_log.slice(cutscene_log_before)
	if not _has_cutscene_start(victory_cutscene_entries, &"ch01_fragment_flash"):
		return _fail("Victory handoff should start ch01_fragment_flash.")
	var expected_clear_cutscene_id := _get_expected_clear_cutscene_id()
	if not _has_cutscene_start(victory_cutscene_entries, expected_clear_cutscene_id):
		return _fail("Victory handoff should keep clear cutscene %s." % String(expected_clear_cutscene_id))

	print("[PASS] Farland progression handoff runner validated fragment recovery, unlock mapping, clear-cutscene handoff, and victory resolution.")
	quit(0)

func _has_progression_event(log: Array[Dictionary], event_name: String, key: String, expected_value: String) -> bool:
	for entry in log:
		if entry.get("event", "") == event_name and String(entry.get(key, "")) == expected_value:
			return true
	return false

func _has_cutscene_start(log: Array[Dictionary], cutscene_id: StringName) -> bool:
	for entry in log:
		if entry.get("event", "") == "cutscene_started" and entry.get("id", &"") == cutscene_id:
			return true
	return false

func _get_expected_clear_cutscene_id() -> StringName:
	if CutsceneCatalog.get_cutscene(CH01_STAGE.clear_cutscene_id) != null:
		return CH01_STAGE.clear_cutscene_id
	return &"ch01_clear"

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
