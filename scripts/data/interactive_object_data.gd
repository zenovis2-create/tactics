class_name InteractiveObjectData
extends Resource

@export var object_id: StringName = &"interactive_object"
@export var display_name: String = "Object"
@export_enum("chest", "lever", "door", "gate", "altar") var object_type: String = "chest"
@export var grid_position: Vector2i = Vector2i.ZERO
@export var interaction_range: int = 1
@export var blocks_movement_while_active: bool = false
@export var blocks_movement_when_resolved: bool = false
@export var one_time_use: bool = true
@export var reward_text: String = ""
@export var interaction_text: String = ""
