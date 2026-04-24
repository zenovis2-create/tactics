extends Resource
class_name HuntData
@export var hunt_id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
@export var unlock_condition_flag: String = ""
@export var stage_id: StringName = &""
@export var difficulty: int = 1
@export var recommended_level: int = 1
@export var reward_memory_fragment: String = ""
@export var reward_evidence: Array[String] = []
@export var reward_materials: Array[Dictionary] = []
@export var reward_gold: int = 0
