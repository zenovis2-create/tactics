class_name SkillData
extends Resource

@export var skill_id: StringName = &"basic_attack"
@export var display_name: String = "Basic Attack"
@export var range: int = 1
@export var power_modifier: int = 0
@export var targeting_rule: StringName = &"adjacent_enemy"
@export var unlock_condition: Dictionary = {}

func is_unlocked(progression_data: ProgressionData) -> bool:
    if progression_data == null:
        return unlock_condition.is_empty()

    if unlock_condition.is_empty():
        return true

    if unlock_condition.has("trust_min") and progression_data.trust < int(unlock_condition.get("trust_min", 0)):
        return false

    if unlock_condition.has("burden_max") and progression_data.burden > int(unlock_condition.get("burden_max", 9)):
        return false

    if unlock_condition.has("fragment"):
        var fragment_id := StringName(String(unlock_condition.get("fragment", "")))
        if fragment_id == &"" or not progression_data.has_fragment(fragment_id):
            return false

    return true

func get_unlock_description() -> String:
    if unlock_condition.is_empty():
        return ""

    var parts: Array[String] = []

    if unlock_condition.has("trust_min"):
        parts.append("신뢰 %d이상" % int(unlock_condition.get("trust_min", 0)))

    if unlock_condition.has("burden_max"):
        parts.append("부담 %d이하" % int(unlock_condition.get("burden_max", 9)))

    if unlock_condition.has("fragment"):
        parts.append("기억 %s" % String(unlock_condition.get("fragment", "")))

    return " / ".join(parts)
