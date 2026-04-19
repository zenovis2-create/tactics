class_name StageData
extends Resource

const UnitData = preload("res://scripts/data/unit_data.gd")
const InteractiveObjectData = preload("res://scripts/data/interactive_object_data.gd")

@export var stage_id: StringName = &"stage_001"
@export var choice_point_id: StringName = &""
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
@export var interactive_objects: Array[InteractiveObjectData] = []
@export var win_condition: StringName = &"defeat_all_enemies"
@export var loss_condition: StringName = &"all_allies_defeated"
@export_multiline var objective_text: String = ""
@export var interaction_objective_texts: PackedStringArray = PackedStringArray()
@export var interaction_objective_state_ids: Array[StringName] = []
@export var rescue_objective_id: StringName = &""
@export var rescue_objective_required_count: int = 0
@export var rescue_objective_object_ids: Array[StringName] = []
@export var hold_objective_id: StringName = &""
@export var hold_objective_required_turns: int = 0
@export var finale_name_anchor_ids: Array[StringName] = []
@export var finale_minimum_name_anchors: int = 0
@export var ally_attack_bonus: int = 0
@export var ally_defense_bonus: int = 0
@export var start_cutscene_id: StringName = &""
@export var clear_cutscene_id: StringName = &""
@export_multiline var next_destination_summary: String = ""

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
