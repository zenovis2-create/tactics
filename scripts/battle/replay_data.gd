class_name ReplayData
extends Resource

# Replay data for the Replay Market — stores a recorded battle session

var replay_id: StringName = &""
var chapter_id: String = ""
var stage_id: String = ""
var battle_date: String = ""
var uploader_name: String = "Anonymous"

var turn_count: int = 0
var star_rating: int = 1
var is_anonymous: bool = true
var faction_tag: String = ""

var player_tag: String = "Anonymous"
var replay_title: String = "Untitled Replay"

var battle_log: Array = []
var seed_value: int = 0

var difficulty_rating: int = 1
var allied_units: PackedStringArray = PackedStringArray()
var enemy_units: PackedStringArray = PackedStringArray()
var terrain_type: String = "plains"
var victory_achieved: bool = false

func get_display_title() -> String:
	if is_anonymous:
		return "%s — %s (★%d)" % [chapter_id, stage_id, star_rating]
	return "%s by %s — %s (★%d)" % [replay_title, uploader_name, stage_id, star_rating]

func get_turns_display() -> String:
	return "%d turns" % turn_count

func get_difficulty_stars() -> String:
	return "★".repeat(difficulty_rating) + "☆".repeat(maxi(0, 5 - difficulty_rating))

func get_uploader_display() -> String:
	if is_anonymous:
		return "Anonymous"
	return uploader_name

static func create_from_dict(data: Dictionary) -> ReplayData:
	var replay := ReplayData.new()
	replay.replay_id = StringName(data.get("replay_id", ""))
	replay.chapter_id = data.get("chapter_id", "")
	replay.stage_id = data.get("stage_id", "")
	replay.battle_date = data.get("battle_date", "")
	replay.uploader_name = data.get("uploader_name", "Anonymous")
	replay.turn_count = data.get("turn_count", 0)
	replay.star_rating = data.get("star_rating", 1)
	replay.is_anonymous = data.get("is_anonymous", true)
	replay.faction_tag = data.get("faction_tag", "")
	replay.player_tag = data.get("player_tag", "Anonymous")
	replay.replay_title = data.get("replay_title", "Untitled Replay")
	replay.battle_log = Array(data.get("battle_log", []))
	replay.seed_value = data.get("seed_value", 0)
	replay.difficulty_rating = data.get("difficulty_rating", 1)
	replay.allied_units = PackedStringArray(data.get("allied_units", []))
	replay.enemy_units = PackedStringArray(data.get("enemy_units", []))
	replay.terrain_type = data.get("terrain_type", "plains")
	replay.victory_achieved = data.get("victory_achieved", false)
	return replay

func to_dict() -> Dictionary:
	return {
		"replay_id": String(replay_id),
		"chapter_id": chapter_id,
		"stage_id": stage_id,
		"battle_date": battle_date,
		"uploader_name": uploader_name,
		"turn_count": turn_count,
		"star_rating": star_rating,
		"is_anonymous": is_anonymous,
		"faction_tag": faction_tag,
		"player_tag": player_tag,
		"replay_title": replay_title,
		"battle_log": Array(battle_log),
		"seed_value": seed_value,
		"difficulty_rating": difficulty_rating,
		"allied_units": Array(allied_units),
		"enemy_units": Array(enemy_units),
		"terrain_type": terrain_type,
		"victory_achieved": victory_achieved
	}
