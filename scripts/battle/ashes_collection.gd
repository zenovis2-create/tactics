class_name AshesCollection
extends Node

const ProgressionData = preload("res://scripts/data/progression_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

const RARITY_COMMON := "COMMON"
const RARITY_RARE := "RARE"
const RARITY_LEGENDARY := "LEGENDARY"
const DEFAULT_LAST_WORDS := "..."
const UNIT_RESOURCE_PATH := "res://data/units/%s.tres"

const STORY_ALIAS_OVERRIDES := {
	"ch04_boss_leonika": {
		"resource_unit_id": "enemy_basil",
		"enemy_name": "Leonika",
		"last_words": "당신이 이기는 것밖에 볼 수 없군요...",
		"chapter_defeated": "CH04",
		"rarity": RARITY_LEGENDARY
	},
	"ch07_enemy_captain": {
		"resource_unit_id": "enemy_saria",
		"enemy_name": "Enemy Captain",
		"last_words": "제 꿈이...",
		"chapter_defeated": "CH07",
		"rarity": RARITY_RARE
	},
	"ch08_shadow_knight": {
		"resource_unit_id": "enemy_lete",
		"enemy_name": "Shadow Knight",
		"last_words": "어둠이 날 부른다...",
		"chapter_defeated": "CH08",
		"rarity": RARITY_LEGENDARY
	},
	"ch09_dark_mage": {
		"resource_unit_id": "enemy_varten",
		"enemy_name": "Dark Mage",
		"last_words": "한 번쯤은... 빛을...",
		"chapter_defeated": "CH09",
		"rarity": RARITY_RARE
	},
	"ch10_final_enemy": {
		"resource_unit_id": "enemy_karon",
		"enemy_name": "Final Enemy",
		"last_words": "이것도 하나의 Ending이었다",
		"chapter_defeated": "CH10",
		"rarity": RARITY_LEGENDARY
	}
}

var ashes_collected: Array[Dictionary] = []
var current_stage_id: String = ""
var _progression_data: ProgressionData

func bind_progression(data: ProgressionData) -> void:
	_progression_data = data
	if _progression_data == null:
		ashes_collected.clear()
		return
	ashes_collected = _duplicate_entries(_progression_data.ashes_collected)

func reset_collection() -> void:
	ashes_collected.clear()
	current_stage_id = ""
	_sync_progression()

func set_current_stage(stage_id: String) -> void:
	current_stage_id = stage_id.strip_edges().to_upper()

func collect_ashes(enemy_id: String) -> void:
	var normalized_enemy_id := enemy_id.strip_edges()
	if normalized_enemy_id.is_empty() or _has_ashes(normalized_enemy_id):
		return
	var metadata := _resolve_enemy_metadata(normalized_enemy_id)
	ashes_collected.append(metadata)
	_sync_progression()

func get_ashes_count() -> int:
	return ashes_collected.size()

func get_ashes_by_rarity(rarity: String) -> Array:
	var normalized_rarity := _normalize_rarity(rarity)
	var matches: Array = []
	for entry in ashes_collected:
		if String(entry.get("rarity", RARITY_COMMON)) == normalized_rarity:
			matches.append((entry as Dictionary).duplicate(true))
	return matches

func get_memorial_wall_data() -> Array:
	return _duplicate_entries(ashes_collected)

func _has_ashes(enemy_id: String) -> bool:
	for entry in ashes_collected:
		if String(entry.get("enemy_id", "")) == enemy_id:
			return true
	return false

func _resolve_enemy_metadata(enemy_id: String) -> Dictionary:
	var alias: Dictionary = (STORY_ALIAS_OVERRIDES.get(enemy_id, {}) as Dictionary).duplicate(true)
	var resource_unit_id := String(alias.get("resource_unit_id", enemy_id)).strip_edges()
	var unit_data := _load_unit_data(resource_unit_id)
	var resolved_name := String(alias.get("enemy_name", "")).strip_edges()
	if resolved_name.is_empty() and unit_data != null:
		resolved_name = unit_data.display_name.strip_edges()
	if resolved_name.is_empty():
		resolved_name = _humanize_enemy_name(enemy_id)
	var resolved_last_words := String(alias.get("last_words", "")).strip_edges()
	if resolved_last_words.is_empty() and unit_data != null:
		resolved_last_words = unit_data.last_words.strip_edges()
	if resolved_last_words.is_empty():
		resolved_last_words = DEFAULT_LAST_WORDS
	var resolved_rarity := String(alias.get("rarity", "")).strip_edges()
	if resolved_rarity.is_empty() and unit_data != null:
		resolved_rarity = unit_data.rarity
	resolved_rarity = _normalize_rarity(resolved_rarity)
	return {
		"enemy_id": enemy_id,
		"enemy_name": resolved_name,
		"last_words": resolved_last_words,
		"chapter_defeated": _resolve_chapter_defeated(alias),
		"rarity": resolved_rarity
	}

func _resolve_chapter_defeated(alias: Dictionary) -> String:
	var chapter_text := String(alias.get("chapter_defeated", "")).strip_edges().to_upper()
	if not chapter_text.is_empty():
		return chapter_text
	if current_stage_id.is_empty():
		return ""
	var parts := current_stage_id.split("_", false)
	return parts[0].to_upper() if not parts.is_empty() else current_stage_id

func _load_unit_data(unit_id: String) -> UnitData:
	if unit_id.is_empty():
		return null
	var resource_path := UNIT_RESOURCE_PATH % unit_id
	if not ResourceLoader.exists(resource_path):
		return null
	var loaded := ResourceLoader.load(resource_path)
	return loaded as UnitData if loaded is UnitData else null

func _normalize_rarity(rarity: String) -> String:
	match rarity.strip_edges().to_upper():
		RARITY_RARE:
			return RARITY_RARE
		RARITY_LEGENDARY:
			return RARITY_LEGENDARY
		_:
			return RARITY_COMMON

func _humanize_enemy_name(enemy_id: String) -> String:
	var normalized := enemy_id.strip_edges()
	if normalized.begins_with("enemy_"):
		normalized = normalized.trim_prefix("enemy_")
	var parts := normalized.split("_", false)
	for index in range(parts.size()):
		parts[index] = String(parts[index]).capitalize()
	return " ".join(parts)

func _duplicate_entries(entries: Array) -> Array[Dictionary]:
	var copies: Array[Dictionary] = []
	for entry in entries:
		copies.append((entry as Dictionary).duplicate(true))
	return copies

func _sync_progression() -> void:
	if _progression_data == null:
		return
	_progression_data.ashes_collected = _duplicate_entries(ashes_collected)
