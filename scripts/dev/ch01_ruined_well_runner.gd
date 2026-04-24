extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH01_RUINED_WELL = preload("res://data/stages/ch01_03_stage.tres")

var _failed: bool = false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	battle.set_stage(CH01_RUINED_WELL)

	await process_frame
	await process_frame

	_assert_equal(String(CH01_RUINED_WELL.win_condition), "resolve_all_interactions", "CH01_03 should use interaction-based victory.")
	if _failed:
		return

	_assert_equal(battle.interactive_objects.size(), 2, "CH01_03 should author two investigation points.")
	if _failed:
		return

	var object_ids: Array[StringName] = []
	var well_actor = null
	for object_actor in battle.interactive_objects:
		object_ids.append(StringName(object_actor.object_data.object_id))
		if StringName(object_actor.object_data.object_id) == &"ch01_03_ruined_well":
			well_actor = object_actor

	if not object_ids.has(&"ch01_03_supply_cache"):
		_fail("CH01_03 should include the supply cache interaction object.")
		return
	if well_actor == null:
		_fail("CH01_03 should include the ruined well interaction object.")
		return

	_assert_equal(String(well_actor.object_data.object_type), "well", "Ruined well should now route through the well family.")
	if _failed:
		return

	var icon: TextureRect = well_actor.get_node_or_null("Icon")
	if icon == null or icon.texture == null:
		_fail("Ruined well should resolve a runtime icon texture.")
		return

	var ally = battle.ally_units[0]
	for object_actor in battle.interactive_objects:
		battle._resolve_interaction(ally, object_actor)
		await process_frame

	if not battle._check_battle_end():
		_fail("CH01_03 should enter victory when all interaction points are resolved.")
		return

	if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
		_fail("CH01_03 should finish in BattlePhase.VICTORY after the last interaction resolves.")
		return

	battle.queue_free()
	await process_frame
	print("[PASS] CH01 ruined well runner validated well-family routing and interaction victory flow.")
	quit(0)


func _assert_equal(actual, expected, message: String) -> void:
	if actual == expected:
		return
	_fail("%s Expected %s, got %s." % [message, str(expected), str(actual)])


func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	push_error(message)
	quit(1)
