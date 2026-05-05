class_name StageData
extends Resource

const UnitData = preload("res://scripts/data/unit_data.gd")
const InteractiveObjectData = preload("res://scripts/data/interactive_object_data.gd")

const ALLOWED_OBJECTIVE_TYPES: Array[StringName] = [&"defeat", &"seal", &"device", &"gate", &"escape", &"defend", &"branch"]

@export var stage_id: StringName = &"stage_001"
@export var stage_title: String = ""
@export var map_scene: PackedScene
@export var grid_size: Vector2i = Vector2i(8, 8)
@export var cell_size: Vector2i = Vector2i(64, 64)
@export var ally_units: Array[UnitData] = []
@export var enemy_units: Array[UnitData] = []
@export var ally_spawns: Array[Vector2i] = []
@export var enemy_spawns: Array[Vector2i] = []
@export var blocked_cells: Array[Vector2i] = []
@export var terrain_move_costs: Dictionary = {}
@export var terrain_types: Dictionary = {}
@export var terrain_defense_bonuses: Dictionary = {}
@export var terrain_features: Array[Dictionary] = []
@export var decorative_props: Array[Dictionary] = []
@export var optional_objectives: Array[Dictionary] = []
@export_range(0, 3, 1) var star_rating: int = 0
@export_enum("defeat", "seal", "device", "gate", "escape", "defend", "branch") var objective_type: String = "defeat"
@export var objective_target_object_ids: Array[StringName] = []
@export var turn_limit: int = 20
@export_enum("none", "reward_penalty", "defeat", "ending_branch") var turn_limit_policy: String = "reward_penalty"
@export var weather_type: String = "clear"  # clear | rain | night
@export var terrain_synergies_enabled: bool = true
@export var interactive_objects: Array[InteractiveObjectData] = []
@export var win_condition: StringName = &"defeat_all_enemies"
@export var loss_condition: StringName = &"all_allies_defeated"
@export_multiline var objective_text: String = ""
@export_multiline var stage_objective_hint: String = ""
@export var interaction_objective_texts: PackedStringArray = PackedStringArray()
@export var interaction_objective_state_ids: Array[StringName] = []
@export var landmark_labels: PackedStringArray = PackedStringArray()
@export var risk_forecast_cards: Array[Dictionary] = []
@export var reinforcement_wave_announcements: Array[Dictionary] = []
@export var rule_template_id: StringName = &""
@export var rule_template_modifiers: Dictionary = {}
@export var secret_hint_contract: Dictionary = {}
@export var choice_point_id: StringName = &""
@export var start_cutscene_id: StringName = &""
@export var clear_cutscene_id: StringName = &""
@export_multiline var next_destination_summary: String = ""
@export var post_battle_bark_rules: Array[Dictionary] = []

func is_cell_blocked(cell: Vector2i) -> bool:
    return blocked_cells.has(cell)

func get_move_cost(cell: Vector2i) -> int:
    return int(terrain_move_costs.get(cell, 1))

func get_terrain_type(cell: Vector2i) -> StringName:
    return StringName(terrain_types.get(cell, &"plain"))

func get_defense_bonus(cell: Vector2i) -> int:
    return int(terrain_defense_bonuses.get(cell, 0))

func get_display_title() -> String:
    if not stage_title.is_empty():
        return stage_title
    return String(stage_id)

func get_objective_type() -> StringName:
    var resolved_type := StringName(objective_type.strip_edges())
    if resolved_type in ALLOWED_OBJECTIVE_TYPES:
        return resolved_type
    return &"defeat"

func get_objective_target_object_ids() -> Array[StringName]:
    return objective_target_object_ids.duplicate()
