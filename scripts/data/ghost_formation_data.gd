class_name GhostFormationData
extends Resource

var ghost_id: StringName = &""
var player_tag: String = "Anonymous"
var is_anonymous: bool = true
var chapter_id: String = ""
var stage_id: String = ""

var formation: Array[Dictionary] = []
var avg_turns: float = 0.0
var turn_count: int = 0
var preferred_terrain: String = ""
var difficulty_rating: int = 1
var faction_name: String = ""
var battle_date: String = ""

var allies_deployed: PackedStringArray = PackedStringArray()
var enemies_faced: PackedStringArray = PackedStringArray()
var strategy_type: String = "balanced"
var victory_margin: String = "close"
var unique_tactics: PackedStringArray = PackedStringArray()

func get_display_name() -> String:
	if is_anonymous:
		return "Unknown Commander's Strategy"
	return "%s's Strategy" % player_tag

func get_turns_display() -> String:
	return "%.0f turns" % avg_turns

func get_difficulty_stars() -> String:
	return "★".repeat(difficulty_rating) + "☆".repeat(maxi(0, 5 - difficulty_rating))

static func create_from_dict(data: Dictionary) -> GhostFormationData:
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

func to_dict() -> Dictionary:
	return {
		"ghost_id": String(ghost_id),
		"player_tag": player_tag,
		"is_anonymous": is_anonymous,
		"chapter_id": chapter_id,
		"stage_id": stage_id,
		"avg_turns": avg_turns,
		"turn_count": turn_count,
		"preferred_terrain": preferred_terrain,
		"difficulty_rating": difficulty_rating,
		"faction_name": faction_name,
		"battle_date": battle_date,
		"strategy_type": strategy_type,
		"victory_margin": victory_margin,
		"unique_tactics": Array(unique_tactics),
		"allies_deployed": Array(allies_deployed),
		"enemies_faced": Array(enemies_faced),
		"formation": formation
	}
