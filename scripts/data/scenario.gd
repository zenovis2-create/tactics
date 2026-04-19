class_name ScenarioData
extends Resource

const UnitData = preload("res://scripts/data/unit_data.gd")

@export var scenario_id: StringName = &"custom_001"
@export var scenario_title: String = ""
@export var scenario_description: String = ""
@export var author_name: String = "Anonymous"
@export var created_version: String = "1.0"
@export var difficulty_rating: int = 1  # 1-5 scale

@export var stages: Array[ScenarioStage] = []
@export var dialogue_catalog: Dictionary = {}
@export var win_conditions: Array[String] = ["defeat_all_enemies"]
@export var loss_conditions: Array[String] = ["all_allies_defeated"]
@export var recommended_level: int = 1
@export var tags: PackedStringArray = PackedStringArray()
@export var is_night_battle: bool = false
@export var weather_type: String = "clear"

func get_display_title() -> String:
	if not scenario_title.is_empty():
		return scenario_title
	return String(scenario_id)

func get_stage_count() -> int:
	return stages.size()

func get_dialogue(stage_id: StringName, key: String) -> String:
	if not dialogue_catalog.has(stage_id):
		return ""
	var stage_dialogues: Dictionary = dialogue_catalog.get(stage_id, {})
	return stage_dialogues.get(key, "")

class ScenarioStage extends Resource:
	@export var stage_id: StringName = &"stage_001"
	@export var stage_title: String = ""
	@export var map_width: int = 8
	@export var map_height: int = 8
	@export var ally_units: Array[UnitData] = []
	@export var enemy_units: Array[UnitData] = []
	@export var ally_spawns: Array[Vector2i] = []
	@export var enemy_spawns: Array[Vector2i] = []
	@export var blocked_cells: Array[Vector2i] = []
	@export var turn_limit: int = 20
	@export var terrain_features: Array[Dictionary] = []
	@export var briefing_text: String = ""
	@export var victory_text: String = ""
	@export var defeat_text: String = ""

	func get_display_title() -> String:
		if not stage_title.is_empty():
			return stage_title
		return String(stage_id)

	func is_cell_blocked(cell: Vector2i) -> bool:
		return blocked_cells.has(cell)
