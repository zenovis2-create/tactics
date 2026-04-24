extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH03_LOST_FOREST = preload("res://data/stages/ch03_01_stage.tres")

var _failed: bool = false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	battle.set_stage(CH03_LOST_FOREST)

	await process_frame
	await process_frame

	_assert_equal(String(CH03_LOST_FOREST.win_condition), "resolve_all_interactions", "CH03_01 should use interaction-based victory.")
	if _failed:
		return

	_assert_equal(battle.interactive_objects.size(), 2, "CH03_01 should author two trail markers.")
	if _failed:
		return

	for object_actor in battle.interactive_objects:
		_assert_equal(String(object_actor.object_data.object_type), "shrine", "CH03_01 trail markers should route through the shrine family.")
		if _failed:
			return
		var icon: TextureRect = object_actor.get_node_or_null("Icon")
		if icon == null or icon.texture == null:
			_fail("CH03_01 shrine marker should resolve a runtime icon texture.")
			return

	var ally = battle.ally_units[0]
	for object_actor in battle.interactive_objects:
		battle._resolve_interaction(ally, object_actor)
		await process_frame

	if not battle._check_battle_end():
		_fail("CH03_01 should enter victory when all shrine markers are resolved.")
		return

	if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
		_fail("CH03_01 should finish in BattlePhase.VICTORY after the last shrine marker resolves.")
		return

	battle.queue_free()
	await process_frame
	print("[PASS] CH03 shrine route runner validated shrine-family routing and interaction victory flow.")
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
