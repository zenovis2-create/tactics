class_name JobData
extends Resource

const ClassData = preload("res://scripts/data/class_data.gd")

@export var job_id: StringName = &"job"
@export var display_name: String = "Job"
@export var class_data: ClassData
@export var weapon_types_allowed_override: PackedStringArray = PackedStringArray()
@export var armor_types_allowed_override: PackedStringArray = PackedStringArray()

func get_allowed_weapon_types() -> PackedStringArray:
    if not weapon_types_allowed_override.is_empty():
        return weapon_types_allowed_override
    if class_data != null:
        return class_data.weapon_types_allowed
    return PackedStringArray()

func get_allowed_armor_types() -> PackedStringArray:
    if not armor_types_allowed_override.is_empty():
        return armor_types_allowed_override
    if class_data != null:
        return class_data.armor_types_allowed
    return PackedStringArray()

