class_name TerrainMemoryService
extends Node

const ProgressionData = preload("res://scripts/data/progression_data.gd")
const StageData = preload("res://scripts/data/stage_data.gd")

const MARKER_VISIT_THRESHOLD: int = 5
const DEFAULT_MARKER_TYPE: String = "battle_scars"
const STAGE_RESOURCE_PATH: String = "res://data/stages/%s_stage.tres"

var terrain_damage_map: Dictionary = {}
var battle_visit_counts: Dictionary = {}
var persistent_markers: Array[Dictionary] = []

var _battle_last_visit_dates: Dictionary = {}
var _progression_data: ProgressionData = null

func bind_progression(data: ProgressionData) -> void:
	_progression_data = data
	if _progression_data == null:
		reset_state()
		return
	terrain_damage_map = _duplicate_nested_dictionary(_progression_data.terrain_damage_map)
	battle_visit_counts = _progression_data.battle_visit_counts.duplicate(true)
	persistent_markers = _duplicate_marker_array(_progression_data.persistent_markers)
	_battle_last_visit_dates = _progression_data.battle_last_visit_dates.duplicate(true)
	_sync_progression()

func reset_state() -> void:
	terrain_damage_map.clear()
	battle_visit_counts.clear()
	persistent_markers.clear()
	_battle_last_visit_dates.clear()
	_sync_progression()

func record_terrain_damage(chapter_id: String, tile_pos: Vector2i, damage_level: int) -> void:
	var normalized_chapter_id := _normalize_chapter_id(chapter_id)
	if normalized_chapter_id.is_empty() or damage_level <= 0:
		return
	var chapter_damage: Dictionary = terrain_damage_map.get(normalized_chapter_id, {}).duplicate(true)
	chapter_damage[tile_pos] = maxi(int(chapter_damage.get(tile_pos, 0)), damage_level)
	terrain_damage_map[normalized_chapter_id] = chapter_damage
	_sync_progression()

func record_battle_visit(chapter_id: String) -> void:
	var normalized_chapter_id := _normalize_chapter_id(chapter_id)
	if normalized_chapter_id.is_empty():
		return
	battle_visit_counts[normalized_chapter_id] = get_visit_count(normalized_chapter_id) + 1
	_battle_last_visit_dates[normalized_chapter_id] = Time.get_datetime_string_from_system()
	_try_add_persistent_marker(normalized_chapter_id)
	_sync_progression()

func get_damage_at(chapter_id: String, tile_pos: Vector2i) -> int:
	var normalized_chapter_id := _normalize_chapter_id(chapter_id)
	if normalized_chapter_id.is_empty():
		return 0
	return int((terrain_damage_map.get(normalized_chapter_id, {}) as Dictionary).get(tile_pos, 0))

func get_visit_count(chapter_id: String) -> int:
	var normalized_chapter_id := _normalize_chapter_id(chapter_id)
	if normalized_chapter_id.is_empty():
		return 0
	return max(0, int(battle_visit_counts.get(normalized_chapter_id, 0)))

func get_persistent_markers() -> Array[Dictionary]:
	return _duplicate_marker_array(persistent_markers)

func get_damage_map_for_chapter(chapter_id: String) -> Dictionary:
	var normalized_chapter_id := _normalize_chapter_id(chapter_id)
	if normalized_chapter_id.is_empty():
		return {}
	return (terrain_damage_map.get(normalized_chapter_id, {}) as Dictionary).duplicate(true)

func get_museum_location() -> String:
	var best_chapter_id := ""
	var best_count := 0
	for chapter_id_variant in battle_visit_counts.keys():
		var chapter_id := String(chapter_id_variant)
		var visit_count := get_visit_count(chapter_id)
		if visit_count > best_count or (visit_count == best_count and not chapter_id.is_empty() and (best_chapter_id.is_empty() or chapter_id < best_chapter_id)):
			best_count = visit_count
			best_chapter_id = chapter_id
	return best_chapter_id

func get_last_visit_date(chapter_id: String) -> String:
	var normalized_chapter_id := _normalize_chapter_id(chapter_id)
	if normalized_chapter_id.is_empty():
		return ""
	return String(_battle_last_visit_dates.get(normalized_chapter_id, "")).strip_edges()

func _try_add_persistent_marker(chapter_id: String) -> void:
	if get_visit_count(chapter_id) < MARKER_VISIT_THRESHOLD or _has_marker_for_chapter(chapter_id):
		return
	var stage_data := _load_stage_data(chapter_id)
	var origin_tile := _resolve_origin_tile(stage_data)
	persistent_markers.append({
		"chapter_id": chapter_id,
		"chapter_name": _resolve_chapter_name(stage_data, chapter_id),
		"position": origin_tile,
		"marker_type": DEFAULT_MARKER_TYPE,
		"chapter_origin": chapter_id,
		"visit_count": get_visit_count(chapter_id),
		"last_visit_date": get_last_visit_date(chapter_id)
	})

func _has_marker_for_chapter(chapter_id: String) -> bool:
	for marker in persistent_markers:
		if String(marker.get("chapter_id", "")).strip_edges() == chapter_id:
			return true
	return false

func _sync_progression() -> void:
	if _progression_data == null:
		return
	_progression_data.terrain_damage_map = _duplicate_nested_dictionary(terrain_damage_map)
	_progression_data.battle_visit_counts = battle_visit_counts.duplicate(true)
	_progression_data.persistent_markers = _duplicate_marker_array(persistent_markers)
	_progression_data.battle_last_visit_dates = _battle_last_visit_dates.duplicate(true)

func _duplicate_nested_dictionary(source: Dictionary) -> Dictionary:
	var duplicate: Dictionary = {}
	for chapter_id_variant in source.keys():
		duplicate[chapter_id_variant] = (source.get(chapter_id_variant, {}) as Dictionary).duplicate(true)
	return duplicate

func _duplicate_marker_array(source: Array) -> Array[Dictionary]:
	var duplicate: Array[Dictionary] = []
	for entry in source:
		if typeof(entry) == TYPE_DICTIONARY:
			duplicate.append((entry as Dictionary).duplicate(true))
	return duplicate

func _normalize_chapter_id(chapter_id: String) -> String:
	return chapter_id.strip_edges().to_lower()

func _load_stage_data(chapter_id: String) -> StageData:
	var resource_path := STAGE_RESOURCE_PATH % chapter_id.to_lower()
	if not ResourceLoader.exists(resource_path):
		return null
	var loaded := ResourceLoader.load(resource_path)
	return loaded as StageData if loaded is StageData else null

func _resolve_origin_tile(stage_data: StageData) -> Vector2i:
	if stage_data == null:
		return Vector2i.ZERO
	if stage_data.has_memorial_slot():
		return stage_data.memorial_slot
	if not stage_data.ally_spawns.is_empty():
		return stage_data.ally_spawns[0]
	return Vector2i(stage_data.grid_size.x / 2, stage_data.grid_size.y / 2)

func _resolve_chapter_name(stage_data: StageData, chapter_id: String) -> String:
	if stage_data != null:
		var title := stage_data.get_display_title().strip_edges()
		if not title.is_empty():
			return title
	return chapter_id.to_upper()
