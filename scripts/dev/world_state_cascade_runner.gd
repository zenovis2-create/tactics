extends SceneTree

const ProgressionService = preload("res://scripts/battle/progression_service.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")

const DECISION_POINT_PATH := "res://scripts/battle/decision_point.gd"
const CASCADE_PATH := "res://scripts/battle/cascade_calculator.gd"
const SLOT_ID := 5

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var decision_script = load(DECISION_POINT_PATH)
	if decision_script == null:
		_fail("decision_point.gd is missing.")
		return

	var cascade_script = load(CASCADE_PATH)
	if cascade_script == null:
		_fail("cascade_calculator.gd is missing.")
		return

	var progression_service := ProgressionService.new()
	root.add_child(progression_service)
	var save_service := SaveService.new()
	root.add_child(save_service)
	await process_frame

	save_service.delete_slot(SLOT_ID)
	var fresh_progression = save_service.load_progression(SLOT_ID)
	progression_service.load_data(fresh_progression)
	save_service.save_progression(fresh_progression, SLOT_ID)

	var decision_point = decision_script.new()
	var cascade = cascade_script.new()
	root.add_child(decision_point)
	root.add_child(cascade)
	await process_frame

	if decision_point.has_method("bind_progression_service"):
		decision_point.bind_progression_service(progression_service)
	if cascade.has_method("bind_progression_service"):
		cascade.bind_progression_service(progression_service)
	if cascade.has_method("connect_decision_point"):
		cascade.connect_decision_point(decision_point)

	var progression = progression_service.get_data()
	if progression == null:
		_fail("Progression data was unavailable.")
		return
	if not progression.has_method("to_debug_dict"):
		_fail("ProgressionData is missing to_debug_dict().")
		return

	var debug_snapshot: Dictionary = progression.to_debug_dict()
	if not debug_snapshot.has("world_state_bits"):
		_fail("ProgressionData debug snapshot should expose world_state_bits.")
		return

	progression.world_state_bits["spared_leonika"] = true
	if not cascade.has_method("apply_pending_cascades"):
		_fail("Cascade calculator is missing apply_pending_cascades().")
		return
	if not cascade.has_method("get_active_modifiers"):
		_fail("Cascade calculator is missing get_active_modifiers().")
		return

	cascade.apply_pending_cascades(7)
	var active_modifiers: Dictionary = cascade.get_active_modifiers()
	if int(active_modifiers.get("enemy_faction_strength", 0)) != -20:
		_fail("Expected enemy_faction_strength modifier -20 after spared_leonika CH07 application.")
		return

	progression.world_state_bits["burned_bridge"] = true
	cascade.apply_pending_cascades(6)
	active_modifiers = cascade.get_active_modifiers()
	if int(active_modifiers.get("battle_terrain_flood_level", 0)) != 1:
		_fail("Expected flood level modifier +1 after burned_bridge CH06 application.")
		return

	if not progression.cascade_effects is Array or progression.cascade_effects.size() < 2:
		_fail("Expected at least two cascade effects to be tracked in progression data.")
		return

	print("[PASS] world_state_cascade_runner: world-state cascade decisions validated.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
