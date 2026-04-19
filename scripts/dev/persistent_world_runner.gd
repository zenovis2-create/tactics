extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const HeirloomService = preload("res://scripts/battle/heirloom_service.gd")
const STAGE_RESOURCE: Resource = preload("res://data/stages/ch09a_04_stage.tres")

const SLOT_ID := 10
const CHAPTER_ID := "ch09a_04"
const DAMAGE_TILE := Vector2i(3, 4)

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save_service := SaveService.new()
	root.add_child(save_service)
	await process_frame
	save_service.delete_slot(SLOT_ID)

	var progression: ProgressionData = save_service.load_progression(SLOT_ID)
	_assert(progression != null, "Fresh slot_10 should load a default ProgressionData resource.")
	var terrain_memory := root.get_node_or_null("TerrainMemory")
	_assert(terrain_memory != null, "TerrainMemory autoload should be available at /root/TerrainMemory.")
	if _failed:
		quit(1)
		return

	terrain_memory.call("bind_progression", progression)
	if terrain_memory.has_method("reset_state"):
		terrain_memory.call("reset_state")
		terrain_memory.call("bind_progression", progression)

	for _index in range(2):
		terrain_memory.call("record_battle_visit", CHAPTER_ID)
	_assert(int(terrain_memory.call("get_visit_count", CHAPTER_ID)) == 2, "Two recorded visits should be stored before the memorial threshold.")
	_assert((terrain_memory.call("get_persistent_markers") as Array).is_empty(), "Persistent markers should stay hidden before the third battle.")

	terrain_memory.call("record_terrain_damage", CHAPTER_ID, DAMAGE_TILE, 2)
	_assert(int(terrain_memory.call("get_damage_at", CHAPTER_ID, DAMAGE_TILE)) == 2, "Recorded terrain damage should persist on the target tile.")
	_assert(int((progression.terrain_damage_map.get(CHAPTER_ID, {}) as Dictionary).get(DAMAGE_TILE, 0)) == 2, "ProgressionData should mirror the chapter-scoped terrain damage map.")
	if _failed:
		quit(1)
		return

	var save_error := save_service.save_progression(progression, SLOT_ID)
	_assert(save_error == OK, "slot_10 progression should save successfully after terrain memory writes.")
	var reloaded_progression: ProgressionData = save_service.load_progression(SLOT_ID)
	_assert(reloaded_progression != null, "slot_10 progression should reload after saving persistent terrain state.")
	terrain_memory.call("bind_progression", reloaded_progression)
	_assert(int(terrain_memory.call("get_visit_count", CHAPTER_ID)) == 2, "Visit count should persist after save + reload.")
	_assert(int(terrain_memory.call("get_damage_at", CHAPTER_ID, DAMAGE_TILE)) == 2, "Terrain damage should persist after save + reload.")

	terrain_memory.call("record_battle_visit", CHAPTER_ID)
	_assert(int(terrain_memory.call("get_visit_count", CHAPTER_ID)) == 3, "The third battle should cross the memorial threshold.")
	var markers: Array = terrain_memory.call("get_persistent_markers")
	_assert(markers.size() == 1, "Crossing the threshold should add one persistent battlefield marker.")
	if not markers.is_empty():
		var marker := markers[0] as Dictionary
		_assert(String(marker.get("chapter_id", "")) == CHAPTER_ID, "The marker should belong to the recorded chapter.")
		_assert(String(marker.get("marker_type", "")) == "battle_scars", "The marker should be tagged as battle_scars.")
	_assert(String(terrain_memory.call("get_museum_location")) == CHAPTER_ID, "The most-visited chapter should become the museum location.")
	var museum_structure := terrain_memory.call("get_museum_structure_for_chapter", CHAPTER_ID) as Dictionary
	_assert(String(museum_structure.get("marker_type", "")) == "battlefield_museum", "The most-visited chapter should expose a battlefield museum structure.")
	if _failed:
		quit(1)
		return

	var heirloom_service := HeirloomService.new()
	var heirloom = heirloom_service.generate_heirloom(reloaded_progression)
	var ng_plus_progression := ProgressionData.new()
	heirloom_service.apply_heirloom_to_ngplus(heirloom, ng_plus_progression)
	_assert(int((ng_plus_progression.terrain_damage_map.get(CHAPTER_ID, {}) as Dictionary).get(DAMAGE_TILE, 0)) == 2, "NG+ progression should inherit the stored terrain damage map.")
	_assert(int(ng_plus_progression.battle_visit_counts.get(CHAPTER_ID, 0)) == 3, "NG+ progression should inherit visit counts.")
	_assert(ng_plus_progression.persistent_markers.size() == 1, "NG+ progression should inherit persistent battlefield markers.")
	_assert(String(ng_plus_progression.encyclopedia_comments.get("terrain_museum_location", "")) == CHAPTER_ID, "NG+ progression should remember the museum location for world-map display.")
	if _failed:
		quit(1)
		return

	var main := await _boot_main()
	if main == null:
		quit(1)
		return
	main.battle_controller.progression_service.load_data(ng_plus_progression)
	main.battle_controller.set_stage(STAGE_RESOURCE)
	await process_frame
	await process_frame

	var board_snapshot: Dictionary = main.battle_controller.battle_board.get_persistent_world_snapshot()
	_assert(int(board_snapshot.get("damage_tile_count", 0)) > 0, "BattleBoard should render persistent terrain damage when the stage loads.")
	_assert(bool(board_snapshot.get("marker_visible", false)), "BattleBoard should expose the persistent memorial marker on the scarred battlefield.")
	_assert(bool(board_snapshot.get("museum_visible", false)), "BattleBoard should expose the battlefield museum structure on the most-visited map.")

	main.encyclopedia_panel.show_encyclopedia(ng_plus_progression, StringName(CHAPTER_ID.to_upper()))
	await process_frame
	main.encyclopedia_panel.select_tab("atlas")
	await process_frame
	var atlas_snapshot: Dictionary = main.encyclopedia_panel.get_snapshot()
	var atlas_text := String(atlas_snapshot.get("atlas_text", ""))
	_assert(atlas_text.find("전장의자국") != -1, "Atlas/world map view should render the battle-scar section.")
	_assert(atlas_text.find("전장의 museum") != -1, "Atlas/world map view should mention the battlefield museum structure.")
	_assert(atlas_text.find("Abandoned Officers") != -1 or atlas_text.find("CH09A_04") != -1, "Atlas/world map view should identify the scarred battlefield location.")
	await _teardown_main(main)
	if _failed:
		quit(1)
		return

	print("[PASS] persistent_world_runner: all assertions passed.")
	quit(0)

func _boot_main() -> Node:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.start_game_direct()
	await process_frame
	await process_frame
	return main

func _teardown_main(main: Node) -> void:
	if main == null:
		return
	main.queue_free()
	await process_frame
	await process_frame

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
