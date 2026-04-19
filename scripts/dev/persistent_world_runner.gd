extends SceneTree

const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

const SLOT_ID := 10
const CHAPTER_ID := "ch04_01"
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
	if _failed:
		quit(1)
		return

	var terrain_memory := root.get_node_or_null("TerrainMemory")
	_assert(terrain_memory != null, "TerrainMemory autoload should be available at /root/TerrainMemory.")
	_assert(terrain_memory != null and terrain_memory.has_method("bind_progression"), "TerrainMemory should expose bind_progression(progression_data).")
	_assert(terrain_memory != null and terrain_memory.has_method("record_battle_visit"), "TerrainMemory should expose record_battle_visit(chapter_id).")
	_assert(terrain_memory != null and terrain_memory.has_method("record_terrain_damage"), "TerrainMemory should expose record_terrain_damage(chapter_id, tile_pos, damage_level).")
	_assert(terrain_memory != null and terrain_memory.has_method("get_visit_count"), "TerrainMemory should expose get_visit_count(chapter_id).")
	_assert(terrain_memory != null and terrain_memory.has_method("get_damage_at"), "TerrainMemory should expose get_damage_at(chapter_id, tile_pos).")
	_assert(terrain_memory != null and terrain_memory.has_method("get_persistent_markers"), "TerrainMemory should expose get_persistent_markers().")
	_assert(terrain_memory != null and terrain_memory.has_method("get_museum_location"), "TerrainMemory should expose get_museum_location().")
	if _failed:
		quit(1)
		return

	terrain_memory.call("bind_progression", progression)
	if terrain_memory.has_method("reset_state"):
		terrain_memory.call("reset_state")
		terrain_memory.call("bind_progression", progression)

	for _index in range(4):
		terrain_memory.call("record_battle_visit", CHAPTER_ID)
	_assert(int(terrain_memory.call("get_visit_count", CHAPTER_ID)) == 4, "Four recorded visits should raise ch04_01 visit_count to 4.")

	terrain_memory.call("record_terrain_damage", CHAPTER_ID, DAMAGE_TILE, 2)
	_assert(int(terrain_memory.call("get_damage_at", CHAPTER_ID, DAMAGE_TILE)) == 2, "Recorded damage should persist at ch04_01 (3,4) with level 2.")

	var early_markers: Array = terrain_memory.call("get_persistent_markers")
	_assert(early_markers.is_empty(), "Persistent markers should still be empty before the revisit threshold is crossed.")
	if _failed:
		quit(1)
		return

	var save_error := save_service.save_progression(progression, SLOT_ID)
	_assert(save_error == OK, "slot_10 progression should save successfully after terrain memory writes.")
	var reloaded_progression: ProgressionData = save_service.load_progression(SLOT_ID)
	_assert(reloaded_progression != null, "slot_10 progression should reload after saving persistent terrain state.")
	terrain_memory.call("bind_progression", reloaded_progression)
	_assert(int(terrain_memory.call("get_visit_count", CHAPTER_ID)) == 4, "Visit count should persist after saving and reloading slot_10.")
	_assert(int(terrain_memory.call("get_damage_at", CHAPTER_ID, DAMAGE_TILE)) == 2, "Terrain damage should persist after saving and reloading slot_10.")
	if _failed:
		quit(1)
		return

	for _index in range(2):
		terrain_memory.call("record_battle_visit", CHAPTER_ID)
	_assert(int(terrain_memory.call("get_visit_count", CHAPTER_ID)) == 6, "Two more visits should raise ch04_01 visit_count to 6.")

	var markers: Array = terrain_memory.call("get_persistent_markers")
	_assert(markers.size() == 1, "Crossing the revisit threshold should auto-add one persistent memorial marker.")
	_assert(String(terrain_memory.call("get_museum_location")) == CHAPTER_ID, "The most-visited chapter should become the museum location.")
	if _failed:
		quit(1)
		return

	print("[PASS] persistent_world_runner: all assertions passed.")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
