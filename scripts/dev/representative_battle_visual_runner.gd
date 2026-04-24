extends SceneTree

const BASE_BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH07_REP_SCENE: PackedScene = preload("res://scenes/dev/ch07_representative_battle.tscn")
const CH09B_REP_SCENE: PackedScene = preload("res://scenes/dev/ch09b_representative_battle.tscn")
const CH10_REP_SCENE: PackedScene = preload("res://scenes/dev/ch10_representative_battle.tscn")

var _summary: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_scene_case("ch07", CH07_REP_SCENE, "city", ["ch07_05_prayer_dais", "ch07_05_city_seal"]):
		return
	if not await _assert_scene_case("ch09b", CH09B_REP_SCENE, "archive", ["ch09b_05_archive_lectern"]):
		return
	if not await _assert_scene_case("ch10", CH10_REP_SCENE, "final_bell", ["ch10_05_bell_dais", "ch10_05_anchor_chain"]):
		return
	if not _assert_camera_signatures_differ():
		return
	print("VISUAL_QA_SUMMARY=%s" % JSON.stringify({"representative_battles": _summary}))
	print("[PASS] representative_battle_visual_runner validated chapter-local landmark usage in representative battles.")
	quit(0)

func _assert_scene_case(case_id: String, scene_res: PackedScene, expected_family: String, expected_object_ids: Array[String]) -> bool:
	var battle = scene_res.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame
	var result := _assert_battle_contract(case_id, battle, expected_family, expected_object_ids)
	battle.queue_free()
	await process_frame
	return result

func _assert_battle_contract(case_id: String, battle: Node, expected_family: String, expected_object_ids: Array[String]) -> bool:
	var snapshot: Dictionary = battle.battle_board.get_surface_contract_snapshot()
	if String(snapshot.get("surface_family", "")) != expected_family:
		return _fail("Representative battle surface family mismatch. expected=%s actual=%s" % [expected_family, String(snapshot.get("surface_family", ""))])
	var object_ids: Array[String] = []
	var proximity_summary: Dictionary = {}
	for object_actor in battle.interactive_objects:
		if object_actor != null and is_instance_valid(object_actor) and object_actor.object_data != null:
			object_ids.append(String(object_actor.object_data.object_id))
	for expected_id in expected_object_ids:
		if not object_ids.has(expected_id):
			return _fail("Representative battle missing chapter-local object %s." % expected_id)
		var nearest_distance: int = _get_nearest_ally_distance_to_object(battle, expected_id)
		proximity_summary[expected_id] = nearest_distance
		if nearest_distance > 2:
			return _fail("Representative battle should stage an ally near chapter-local object %s." % expected_id)
	if battle.hud == null:
		return _fail("Representative battle should expose BattleHUD.")
	var hud_snapshot: Dictionary = battle.hud.get_layout_snapshot()
	if float(hud_snapshot.get("frame_width", 0.0)) <= 0.0:
		return _fail("Representative battle HUD should receive frame metrics.")
	_summary.append({
		"case": case_id,
		"surface_family": expected_family,
		"object_proximity": proximity_summary,
		"camera": {
			"position": [battle.battle_camera.position.x, battle.battle_camera.position.y] if battle.battle_camera != null else [0.0, 0.0],
			"zoom": [battle.battle_camera.zoom.x, battle.battle_camera.zoom.y] if battle.battle_camera != null else [1.0, 1.0],
		},
	})
	return true

func _assert_camera_signatures_differ() -> bool:
	if _summary.size() < 3:
		return _fail("Representative battle summary should include all chapter camera signatures.")
	var zooms: Array[String] = []
	for item in _summary:
		var camera: Dictionary = item.get("camera", {})
		var zoom: Array = camera.get("zoom", [1.0, 1.0])
		zooms.append("%s,%s" % [str(zoom[0]), str(zoom[1])])
	if zooms[0] == zooms[1] and zooms[1] == zooms[2]:
		return _fail("Representative battle camera zooms should not collapse into one identical framing.")
	return true

func _get_nearest_ally_distance_to_object(battle: Node, object_id: String) -> int:
	var object_cell := Vector2i(-999, -999)
	for object_actor in battle.interactive_objects:
		if object_actor != null and is_instance_valid(object_actor) and object_actor.object_data != null and String(object_actor.object_data.object_id) == object_id:
			object_cell = object_actor.grid_position
			break
	if object_cell.x < -100:
		return 999
	var nearest_distance := 999
	for ally in battle.ally_units:
		if ally == null or not is_instance_valid(ally):
			continue
		var distance := absi(ally.grid_position.x - object_cell.x) + absi(ally.grid_position.y - object_cell.y)
		nearest_distance = mini(nearest_distance, distance)
	return nearest_distance

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
