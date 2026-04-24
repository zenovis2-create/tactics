extends Node

const UnitData = preload("res://scripts/data/unit_data.gd")
const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")

func _ready() -> void:
    var test_units: Array[UnitData] = [
        preload("res://data/units/ally_vanguard.tres"),
        preload("res://data/units/ally_scout.tres"),
        preload("res://data/units/ally_rian.tres"),
        preload("res://data/units/enemy_raider.tres"),
        preload("res://data/units/enemy_skirmisher.tres"),
    ]

    print("=== ROLE GLYPH VERIFICATION ===")
    for unit_data in test_units:
        if unit_data == null:
            print("NULL unit_data!")
            continue
        var glyph := _get_role_glyph_for(unit_data)
        var class_data = unit_data.get_class_data()
        var resolved_class_name = "null"
        if class_data != null:
            resolved_class_name = class_data.display_name
        print("%s: glyph='%s' class_data=%s unit_id=%s" % [
            unit_data.display_name,
            glyph,
            resolved_class_name,
            unit_data.unit_id
        ])
        var fallback_texture = _get_generic_token_art_texture_for(unit_data)
        print("  -> token_art_texture: %s" % (fallback_texture if fallback_texture != null else "NULL"))

    get_tree().quit()

func _get_role_glyph_for(unit_data: UnitData) -> String:
    if unit_data == null:
        return "--"

    var job_name: String = ""
    if unit_data.job_data != null:
        job_name = unit_data.job_data.display_name.to_lower()
    var resolved_class_name: String = ""
    var resolved_class_data = unit_data.get_class_data()
    if resolved_class_data != null:
        resolved_class_name = resolved_class_data.display_name.to_lower()
    var weapon_types: PackedStringArray = unit_data.get_allowed_weapon_types()
    var primary_weapon: String = ""
    if not weapon_types.is_empty():
        primary_weapon = String(weapon_types[0]).to_lower()

    if unit_data.is_boss:
        return "BX"
    if job_name.contains("medic"):
        return "MD"
    if resolved_class_name.contains("ranger") or primary_weapon == "bow":
        return "AR"
    if resolved_class_name.contains("mystic") or primary_weapon == "staff" or primary_weapon == "tome":
        return "MY"
    if resolved_class_name.contains("knight"):
        return "KN"
    if resolved_class_name.contains("vanguard"):
        return "VG"
    if primary_weapon == "sword":
        return "SW"
    if primary_weapon == "lance":
        return "LN"
    return "UN"

func _get_generic_token_art_texture_for(unit_data: UnitData) -> Texture2D:
    var glyph := _get_role_glyph_for(unit_data)
    var file_name := ""
    match glyph:
        "BX":
            file_name = "boss.png"
        "MD":
            file_name = "medic.png"
        "AR":
            file_name = "ranger.png"
        "MY":
            file_name = "mystic.png"
        "VG":
            file_name = "vanguard.png"
        "KN", "SW", "LN":
            file_name = "knight.png"
        _:
            file_name = ""
    if file_name.is_empty():
        return null
    var resource_path := "res://assets/ui/production/unit_token_art/" + file_name
    if ResourceLoader.exists(resource_path):
        return load(resource_path)
    return null
