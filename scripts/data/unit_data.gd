class_name UnitData
extends Resource

const SkillData = preload("res://scripts/data/skill_data.gd")
const ClassData = preload("res://scripts/data/class_data.gd")
const JobData = preload("res://scripts/data/job_data.gd")

@export var unit_id: StringName = &"unit"
@export var display_name: String = "Unit"
@export_enum("ally", "enemy") var faction: String = "ally"
@export var max_hp: int = 10
@export var attack: int = 4
@export var defense: int = 2
@export var movement: int = 3
@export var attack_range: int = 1
@export var personality: String = "steady"
@export var default_skill: SkillData
@export var class_data: ClassData
@export var job_data: JobData
@export var weapon_types_allowed: PackedStringArray = PackedStringArray(["Sword", "Lance", "Bow", "Staff", "Tome"])
@export var armor_types_allowed: PackedStringArray = PackedStringArray(["light", "heavy", "robe"])
@export var is_boss: bool = false
@export var boss_pattern: StringName = &""
@export var applies_oblivion: bool = false  ## 이 적이 공격 대신 망각 스택을 적용할 수 있는지
@export var boss_phase_thresholds: Dictionary = {}  ## HP% → phase name, e.g. {50: &"enrage", 25: &"despair"}

func get_boss_phase_for_hp(hp_percent: float) -> StringName:
    ## Returns the current boss phase name for the given HP percentage.
    ## Phases are ordered by ascending threshold; the lowest threshold
    ## that HP% is at or below determines the active phase.
    ## E.g. thresholds {50: "enrage", 25: "despair"}:
    ##   - 51%+ → "" (normal)
    ##   - 25..50% → "enrage"
    ##   - 0..25% → "despair"
    if boss_phase_thresholds.is_empty():
        return &""
    var sorted_thresholds: Array = boss_phase_thresholds.keys()
    sorted_thresholds.sort()  # ascending: 25, 50
    for threshold in sorted_thresholds:
        if hp_percent <= float(threshold):
            return boss_phase_thresholds[threshold]
    return &""

func get_class_data() -> ClassData:
    if job_data != null and job_data.class_data != null:
        return job_data.class_data
    return class_data

func get_allowed_weapon_types() -> PackedStringArray:
    if job_data != null:
        var job_allowed: PackedStringArray = job_data.get_allowed_weapon_types()
        if not job_allowed.is_empty():
            return job_allowed
    var resolved_class: ClassData = get_class_data()
    if resolved_class != null and not resolved_class.weapon_types_allowed.is_empty():
        return resolved_class.weapon_types_allowed
    return weapon_types_allowed

func get_allowed_armor_types() -> PackedStringArray:
    if job_data != null:
        var job_allowed: PackedStringArray = job_data.get_allowed_armor_types()
        if not job_allowed.is_empty():
            return job_allowed
    var resolved_class: ClassData = get_class_data()
    if resolved_class != null and not resolved_class.armor_types_allowed.is_empty():
        return resolved_class.armor_types_allowed
    return armor_types_allowed
