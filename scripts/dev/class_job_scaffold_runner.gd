extends SceneTree

const UnitData = preload("res://scripts/data/unit_data.gd")
const BRAN: UnitData = preload("res://data/units/ally_bran.tres")
const NOAH: UnitData = preload("res://data/units/ally_noah.tres")
const TIA: UnitData = preload("res://data/units/ally_tia.tres")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if not _assert_unit_scaffold(BRAN, &"Sword", &"heavy", false):
        return
    if not _assert_unit_scaffold(NOAH, &"Staff", &"robe", true):
        return
    if not _assert_unit_scaffold(TIA, &"Bow", &"light", false):
        return

    print("[PASS] Class/job scaffold runner verified unit compatibility resolves through explicit class/job data.")
    quit(0)

func _assert_unit_scaffold(unit_data: UnitData, expected_weapon: StringName, expected_armor: StringName, expect_job: bool) -> bool:
    if unit_data == null:
        push_error("Class/job scaffold runner expected a unit resource.")
        quit(1)
        return false

    if unit_data.class_data == null:
        push_error("%s is missing class_data." % unit_data.display_name)
        quit(1)
        return false

    if expect_job and unit_data.job_data == null:
        push_error("%s is missing job_data." % unit_data.display_name)
        quit(1)
        return false

    if not unit_data.get_allowed_weapon_types().has(expected_weapon):
        push_error("%s expected weapon compatibility to include %s." % [unit_data.display_name, String(expected_weapon)])
        quit(1)
        return false

    if not unit_data.get_allowed_armor_types().has(expected_armor):
        push_error("%s expected armor compatibility to include %s." % [unit_data.display_name, String(expected_armor)])
        quit(1)
        return false

    return true
