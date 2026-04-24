class_name SkillData
extends Resource

const ProgressionData = preload("res://scripts/data/progression_data.gd")
const MAX_SKILL_LEVEL: int = 5
const EXP_CURVE: Dictionary = {
    1: 30,
    2: 60,
    3: 100,
    4: 150,
}

@export var skill_id: StringName = &"basic_attack"
@export var display_name: String = "Basic Attack"
@export_multiline var description: String = ""
@export var skill_type: StringName = &"attack"
@export var range: int = 1
@export var power_modifier: int = 0
@export var mp_cost: int = 0
@export var sp_cost: int = 0
@export var targeting_rule: StringName = &"adjacent_enemy"
@export var status_type: StringName = &""
@export var status_chance: float = 0.0
@export var status_stacks: int = 0
@export var status_duration: int = 0
@export var status_power: int = 0
@export var status_effect: Dictionary = {}
@export var unlock_condition: Dictionary = {}
@export var unlock_flag: StringName = &""
@export var skill_level: int = 1
@export var skill_exp: int = 0
@export var power_modifier_by_level: Dictionary = {}

func is_unlocked(progression_data: ProgressionData) -> bool:
    if progression_data == null:
        return unlock_condition.is_empty() and unlock_flag == &""

    if unlock_flag != &"" and not bool(progression_data.flags.get(String(unlock_flag), false)):
        return false

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
    if unlock_condition.is_empty() and unlock_flag == &"":
        return ""

    var parts: Array[String] = []

    if unlock_flag != &"":
        parts.append("플래그 %s" % String(unlock_flag))

    if unlock_condition.has("trust_min"):
        parts.append("신뢰 %d이상" % int(unlock_condition.get("trust_min", 0)))

    if unlock_condition.has("burden_max"):
        parts.append("부담 %d이하" % int(unlock_condition.get("burden_max", 9)))

    if unlock_condition.has("fragment"):
        parts.append("기억 %s" % String(unlock_condition.get("fragment", "")))

    return " / ".join(parts)

func applies_status() -> bool:
    if get_status_type() != &"":
        return true
    return not status_effect.is_empty()

func get_status_type() -> StringName:
    if status_type != &"":
        return status_type
    if status_effect.has("type"):
        return StringName(String(status_effect.get("type", "")))
    return &""

func get_status_stacks() -> int:
    if status_stacks > 0:
        return status_stacks
    if status_effect.has("stacks"):
        return maxi(int(status_effect.get("stacks", 1)), 1)
    return 1

func get_status_duration() -> int:
    if status_duration > 0:
        return status_duration
    if status_effect.has("duration"):
        return maxi(int(status_effect.get("duration", 1)), 1)
    return 1

func get_status_power() -> int:
    if status_power != 0:
        return status_power
    if status_effect.has("power"):
        return int(status_effect.get("power", 0))
    return 0

func exp_to_next_level(current_level: int) -> int:
    if current_level >= MAX_SKILL_LEVEL:
        return 0
    return int(EXP_CURVE.get(current_level, 0))

func exp_remaining() -> int:
    if is_max_level():
        return 0
    return maxi(exp_to_next_level(skill_level) - skill_exp, 0)

func is_max_level() -> bool:
    return skill_level >= MAX_SKILL_LEVEL

func get_effective_power_modifier() -> int:
    var bonus: int = int(power_modifier_by_level.get(skill_level, 0))
    return power_modifier + bonus

func has_resource_cost() -> bool:
    return mp_cost > 0 or sp_cost > 0

func get_resource_cost_text() -> String:
    var parts: Array[String] = []
    if mp_cost > 0:
        parts.append("MP %d" % mp_cost)
    if sp_cost > 0:
        parts.append("SP %d" % sp_cost)
    return " / ".join(parts)
