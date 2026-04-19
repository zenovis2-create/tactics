class_name GhostFormationExtractor
extends RefCounted

const GhostFormationData = preload("res://scripts/data/ghost_formation_data.gd")
const ChronicleEntry = preload("res://scripts/battle/chronicle_entry.gd")

const STRATEGY_KEYWORDS: Dictionary = {
	"aggressive": ["broke", "assault", "charge", "crush", "smash"],
	"defensive": ["held", "weathered", "stood", "endured", "blocked"],
	"balanced": ["maneuvered", "moved", "adjusted", "shifted"],
	"overwhelming": ["flooded", "swept", "crushed", "demolished"],
	"calculated": ["patient", "waited", "planned", "designed", "quiet"]
}

const TERRAIN_PREFERENCES: Dictionary = {
	"plains": ["plain", "field", "open", "meadow"],
	"hills": ["ridge", "hill", "high", "elevated", "cliffs"],
	"forest": ["forest", "woods", "tree", "grove"],
	"fortress": ["wall", "fort", "gate", "rampart", "fortress"],
	"urban": ["street", "ruin", "village", "town"],
	"river": ["river", "ford", "bridge", "stream", "water"]
}

static func extract_from_chronicle_entry(entry: ChronicleEntry, player_tag: String = "Player", is_anonymous: bool = true) -> GhostFormationData:
	var ghost := GhostFormationData.new()
	ghost.player_tag = player_tag
	ghost.is_anonymous = is_anonymous
	ghost.chapter_id = entry.chapter_id
	ghost.battle_date = entry.entry_date

	var battle_log := _extract_battle_log_from_narrative(entry.narrative_text)
	ghost.turn_count = _estimate_turn_count(entry)
	ghost.avg_turns = float(ghost.turn_count)
	ghost.preferred_terrain = _detect_preferred_terrain(entry.narrative_text)
	ghost.strategy_type = _detect_strategy_type(entry.narrative_text)
	ghost.difficulty_rating = _estimate_difficulty(entry, ghost.turn_count)
	ghost.allies_deployed = _extract_allies_from_narrative(entry.narrative_text)
	ghost.enemies_faced = _extract_enemies_from_narrative(entry.narrative_text)
	ghost.victory_margin = _detect_victory_margin(entry)
	ghost.unique_tactics = _extract_unique_tactics(entry)

	ghost.ghost_id = &"ghost_%s_%s" % [ghost.chapter_id, _generate_short_id()]
	ghost.formation = _build_formation_array(ghost)

	return ghost

static func extract_from_battle_log(battle_log: Array, player_tag: String, chapter_id: String, is_anonymous: bool = true) -> GhostFormationData:
	var ghost := GhostFormationData.new()
	ghost.player_tag = player_tag
	ghost.is_anonymous = is_anonymous
	ghost.chapter_id = chapter_id
	ghost.battle_date = Time.get_date_string_from_system()

	var summary := _summarize_battle_log(battle_log)
	ghost.turn_count = summary.get("turn_count", 10)
	ghost.avg_turns = float(ghost.turn_count)
	ghost.preferred_terrain = summary.get("terrain", "plains")
	ghost.strategy_type = summary.get("strategy", "balanced")
	ghost.difficulty_rating = summary.get("difficulty", 2)
	var allies_raw: Array = summary.get("allies", [])
	ghost.allies_deployed = PackedStringArray(allies_raw)
	var enemies_raw: Array = summary.get("enemies", [])
	ghost.enemies_faced = PackedStringArray(enemies_raw)
	ghost.victory_margin = summary.get("margin", "moderate")
	var tactics_raw: Array = summary.get("tactics", [])
	ghost.unique_tactics = PackedStringArray(tactics_raw)

	ghost.ghost_id = &"ghost_%s_%s" % [chapter_id, _generate_short_id()]
	ghost.formation = _build_formation_array(ghost)

	return ghost

static func _extract_battle_log_from_narrative(narrative: String) -> Dictionary:
	return {"narrative": narrative}

static func _estimate_turn_count(entry: ChronicleEntry) -> int:
	var text := entry.narrative_text.to_lower()
	if text.contains("final exchange") or text.contains("last"):
		return 20
	if text.contains("deliberate order") or text.contains("patient"):
		return 12
	if text.contains("quick") or text.contains("swift"):
		return 6
	if text.contains("after"):
		var words: Array = text.split(" ")
		for i in range(words.size()):
			if words[i] == "after" and i + 1 < words.size():
				var next_word: String = words[i + 1]
				if next_word.is_valid_int():
					return mini(int(next_word), 30)
	return 10

static func _detect_preferred_terrain(narrative: String) -> String:
	var text := narrative.to_lower()
	for terrain in TERRAIN_PREFERENCES:
		for keyword in TERRAIN_PREFERENCES[terrain]:
			if text.contains(keyword):
				return terrain
	return "plains"

static func _detect_strategy_type(narrative: String) -> String:
	var text := narrative.to_lower()
	var max_matches: int = 0
	var best_strategy: String = "balanced"

	for strategy in STRATEGY_KEYWORDS:
		var matches: int = 0
		for keyword in STRATEGY_KEYWORDS[strategy]:
			if text.contains(keyword):
				matches += 1
		if matches > max_matches:
			max_matches = matches
			best_strategy = strategy

	return best_strategy

static func _estimate_difficulty(entry: ChronicleEntry, turn_count: int) -> int:
	var style: ChronicleEntry.ChronicleStyle = entry.style
	match style:
		ChronicleEntry.ChronicleStyle.BATTLE:
			if turn_count >= 15:
				return 5
			elif turn_count >= 10:
				return 4
			return 3
		ChronicleEntry.ChronicleStyle.POETIC:
			return 2
		_:
			if turn_count <= 8:
				return 2
			elif turn_count <= 15:
				return 3
			return 4

static func _extract_allies_from_narrative(narrative: String) -> Array[String]:
	return []

static func _extract_enemies_from_narrative(narrative: String) -> Array[String]:
	return []

static func _detect_victory_margin(entry: ChronicleEntry) -> String:
	var triggers: Array = entry.trigger_events
	if triggers.has("desperate_victory"):
		return "close"
	if triggers.has("overwhelming_force"):
		return "overwhelming"
	if triggers.has("quiet_strategy"):
		return "decisive"
	return "moderate"

static func _extract_unique_tactics(entry: ChronicleEntry) -> Array[String]:
	var tactics: Array[String] = []
	var triggers: Array = entry.trigger_events
	if triggers.has("desperate_victory"):
		tactics.append("Last-stand Tactics")
	if triggers.has("weather_master"):
		tactics.append("Weather Manipulation")
	if triggers.has("quiet_strategy"):
		tactics.append("Attrition Warfare")
	if triggers.has("overwhelming_force"):
		tactics.append("Fire Superiority")
	return tactics

static func _summarize_battle_log(battle_log: Array) -> Dictionary:
	var summary := {
		"turn_count": 10,
		"terrain": "plains",
		"strategy": "balanced",
		"difficulty": 2,
		"allies": [],
		"enemies": [],
		"margin": "moderate",
		"tactics": []
	}
	for entry: Dictionary in battle_log:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		summary["turn_count"] = maxi(summary["turn_count"], int(entry.get("turn_count", 10)))
		var terrain: String = entry.get("terrain", "")
		if not terrain.is_empty():
			summary["terrain"] = terrain
		var enemies: Array = entry.get("enemies_defeated", [])
		if enemies.size() > 0:
			summary["enemies"] = enemies
		var allies: Array = entry.get("allies_deployed", [])
		if allies.size() > 0:
			summary["allies"] = allies
	return summary

static func _build_formation_array(ghost: GhostFormationData) -> Array[Dictionary]:
	var formation: Array[Dictionary] = []
	var enemy_count: int = ghost.enemies_faced.size()
	if enemy_count <= 0:
		enemy_count = 3

	var base_positions: Array[Vector2i] = []
	match ghost.strategy_type:
		"aggressive":
			base_positions = [Vector2i(6, 3), Vector2i(6, 4), Vector2i(7, 3)]
		"defensive":
			base_positions = [Vector2i(2, 3), Vector2i(2, 4), Vector2i(1, 3)]
		"balanced":
			base_positions = [Vector2i(4, 2), Vector2i(5, 4), Vector2i(6, 3)]
		"overwhelming":
			base_positions = [Vector2i(5, 2), Vector2i(6, 3), Vector2i(7, 4), Vector2i(5, 4)]
		_:
			base_positions = [Vector2i(5, 3), Vector2i(6, 4), Vector2i(5, 5)]

	for i in range(mini(enemy_count, base_positions.size())):
		formation.append({
			"unit_id": "ghost_enemy_%d" % i,
			"position": base_positions[i],
			"role": "standard"
		})

	return formation

static func _generate_short_id() -> String:
	return str(int(Time.get_unix_time_from_system()) % 100000).pad_zeros(5)
