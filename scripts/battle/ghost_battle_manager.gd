class_name GhostBattleManager
extends Node

const GhostFormationData = preload("res://scripts/data/ghost_formation_data.gd")
const GhostFormationExtractor = preload("res://scripts/battle/ghost_formation_extractor.gd")
const ChronicleEntry = preload("res://scripts/battle/chronicle_entry.gd")
const ChronicleGenerator = preload("res://scripts/battle/chronicle_generator.gd")

signal ghost_battle_started(ghost_id: StringName)
signal ghost_battle_defeated(ghost_id: StringName, formation_name: String)
signal new_ghost_registered(ghost_data: GhostFormationData)

var ghost_registry: Array[GhostFormationData] = []
var active_ghost_id: StringName = StringName()
var ghost_battles_defeated: Array[StringName] = []

func _ready() -> void:
	_load_ghost_registry()

func register_ghost_from_chronicle_entry(entry: ChronicleEntry, player_tag: String = "Player", is_anonymous: bool = true) -> GhostFormationData:
	var ghost := GhostFormationExtractor.extract_from_chronicle_entry(entry, player_tag, is_anonymous)
	ghost_registry.append(ghost)
	_new_ghost_registered(ghost)
	_save_ghost_registry()
	return ghost

func register_ghost_from_battle_log(battle_log: Array, player_tag: String, chapter_id: String, is_anonymous: bool = true) -> GhostFormationData:
	var ghost := GhostFormationExtractor.extract_from_battle_log(battle_log, player_tag, chapter_id, is_anonymous)
	ghost_registry.append(ghost)
	_new_ghost_registered(ghost)
	_save_ghost_registry()
	return ghost

func start_ghost_battle(ghost_id: StringName) -> bool:
	if not has_ghost(ghost_id):
		push_warning("[GhostBattleManager] Ghost not found: ", ghost_id)
		return false
	active_ghost_id = ghost_id
	ghost_battle_started.emit(ghost_id)
	print("[GhostBattleManager] Ghost battle started: ", ghost_id)
	return true

func defeat_active_ghost() -> bool:
	if active_ghost_id == StringName():
		return false
	if not ghost_battles_defeated.has(active_ghost_id):
		ghost_battles_defeated.append(active_ghost_id)
	var ghost: GhostFormationData = get_ghost(active_ghost_id)
	if ghost != null:
		ghost_battle_defeated.emit(active_ghost_id, ghost.get_display_name())
		print("[GhostBattleManager] Defeated ghost: %s (%s)" % [active_ghost_id, ghost.get_display_name()])
	active_ghost_id = StringName()
	return true

func get_ghost(ghost_id: StringName) -> GhostFormationData:
	for ghost: GhostFormationData in ghost_registry:
		if ghost.ghost_id == ghost_id:
			return ghost
	return null

func has_ghost(ghost_id: StringName) -> bool:
	return get_ghost(ghost_id) != null

func get_all_ghosts() -> Array[GhostFormationData]:
	return ghost_registry.duplicate()

func get_active_ghost() -> GhostFormationData:
	if active_ghost_id == StringName():
		return null
	return get_ghost(active_ghost_id)

func get_defeated_count() -> int:
	return ghost_battles_defeated.size()

func get_total_ghost_count() -> int:
	return ghost_registry.size()

func is_ghost_defeated(ghost_id: StringName) -> bool:
	return ghost_battles_defeated.has(ghost_id)

func get_ghosts_by_chapter(chapter_id: String) -> Array[GhostFormationData]:
	var result: Array[GhostFormationData] = []
	for ghost: GhostFormationData in ghost_registry:
		if ghost.chapter_id == chapter_id:
			result.append(ghost)
	return result

func get_champion_board() -> Array[Dictionary]:
	var champions: Array[Dictionary] = []
	var by_difficulty: Dictionary = {}
	for ghost: GhostFormationData in ghost_registry:
		var key: int = ghost.difficulty_rating
		if not by_difficulty.has(key) or by_difficulty[key].avg_turns > ghost.avg_turns:
			by_difficulty[key] = ghost

	var sorted_keys: Array = by_difficulty.keys()
	sorted_keys.sort()
	for key in sorted_keys:
		var ghost: GhostFormationData = by_difficulty[key]
		champions.append({
			"rank": champions.size() + 1,
			"ghost_id": ghost.ghost_id,
			"name": ghost.get_display_name(),
			"chapter": ghost.chapter_id,
			"turns": ghost.avg_turns,
			"difficulty": ghost.difficulty_rating,
			"is_defeated": is_ghost_defeated(ghost.ghost_id)
		})
	return champions

func _new_ghost_registered(ghost: GhostFormationData) -> void:
	new_ghost_registered.emit(ghost)

func _load_ghost_registry() -> void:
	var save_path := "user://ghost_registry.dat"
	if not FileAccess.file_exists(save_path):
		return
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	if data == null:
		return
	ghost_registry.clear()
	ghost_battles_defeated.clear()
	if data.has("ghosts"):
		for ghost_data: Dictionary in data["ghosts"]:
			var ghost: GhostFormationData = _dict_to_ghost(ghost_data)
			if ghost != null:
				ghost_registry.append(ghost)
	if data.has("defeated"):
		for ghost_id: String in data["defeated"]:
			ghost_battles_defeated.append(StringName(ghost_id))

func _save_ghost_registry() -> void:
	var save_path := "user://ghost_registry.dat"
	var data: Dictionary = {
		"ghosts": [],
		"defeated": Array(ghost_battles_defeated)
	}
	for ghost: GhostFormationData in ghost_registry:
		data["ghosts"].append(_ghost_to_dict(ghost))
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_error("[GhostBattleManager] Failed to save registry")
		return
	file.store_string(JSON.stringify(data))
	file.close()

func _ghost_to_dict(ghost: GhostFormationData) -> Dictionary:
	return {
		"ghost_id": String(ghost.ghost_id),
		"player_tag": ghost.player_tag,
		"is_anonymous": ghost.is_anonymous,
		"chapter_id": ghost.chapter_id,
		"stage_id": ghost.stage_id,
		"avg_turns": ghost.avg_turns,
		"turn_count": ghost.turn_count,
		"preferred_terrain": ghost.preferred_terrain,
		"difficulty_rating": ghost.difficulty_rating,
		"faction_name": ghost.faction_name,
		"battle_date": ghost.battle_date,
		"strategy_type": ghost.strategy_type,
		"victory_margin": ghost.victory_margin,
		"unique_tactics": Array(ghost.unique_tactics),
		"allies_deployed": Array(ghost.allies_deployed),
		"enemies_faced": Array(ghost.enemies_faced),
		"formation": ghost.formation
	}

func _dict_to_ghost(data: Dictionary) -> GhostFormationData:
	var ghost := GhostFormationData.new()
	ghost.ghost_id = StringName(data.get("ghost_id", ""))
	ghost.player_tag = data.get("player_tag", "Anonymous")
	ghost.is_anonymous = data.get("is_anonymous", true)
	ghost.chapter_id = data.get("chapter_id", "")
	ghost.stage_id = data.get("stage_id", "")
	ghost.avg_turns = data.get("avg_turns", 0.0)
	ghost.turn_count = data.get("turn_count", 0)
	ghost.preferred_terrain = data.get("preferred_terrain", "plains")
	ghost.difficulty_rating = data.get("difficulty_rating", 1)
	ghost.faction_name = data.get("faction_name", "")
	ghost.battle_date = data.get("battle_date", "")
	ghost.strategy_type = data.get("strategy_type", "balanced")
	ghost.victory_margin = data.get("victory_margin", "moderate")
	ghost.unique_tactics = PackedStringArray(data.get("unique_tactics", []))
	ghost.allies_deployed = PackedStringArray(data.get("allies_deployed", []))
	ghost.enemies_faced = PackedStringArray(data.get("enemies_faced", []))
	ghost.formation = Array(data.get("formation", []))
	return ghost

func clear_all_ghosts() -> void:
	ghost_registry.clear()
	ghost_battles_defeated.clear()
	_save_ghost_registry()
