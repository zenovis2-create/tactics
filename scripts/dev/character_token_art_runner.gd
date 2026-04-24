extends SceneTree

const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")
const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const RIAN_DATA = preload("res://data/units/ally_rian.tres")
const SERIN_DATA = preload("res://data/units/ally_serin.tres")
const BRAN_DATA = preload("res://data/units/ally_bran.tres")
const TIA_DATA = preload("res://data/units/ally_tia.tres")
const ENEMY_RAIDER_DATA = preload("res://data/units/enemy_raider.tres")
const ENEMY_SKIRMISHER_DATA = preload("res://data/units/enemy_skirmisher.tres")
const VANGUARD_DATA = preload("res://data/units/ally_vanguard.tres")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if not await _assert_character_specific_art(RIAN_DATA, "knight.png", "Rian"):
        return
    if not await _assert_character_specific_art(SERIN_DATA, "mystic.png", "Serin"):
        return
    if not await _assert_character_specific_art(BRAN_DATA, "knight.png", "Bran"):
        return
    if not await _assert_character_specific_art(TIA_DATA, "ranger.png", "Tia"):
        return
    if not await _assert_character_specific_art(ENEMY_RAIDER_DATA, "vanguard.png", "Enemy Raider"):
        return
    if not await _assert_character_specific_art(ENEMY_SKIRMISHER_DATA, "ranger.png", "Enemy Skirmisher"):
        return
    if not await _assert_generic_fallback(VANGUARD_DATA, "vanguard.png", "Vanguard"):
        return
    print("[PASS] character_token_art_runner validated character-specific token art preference with generic fallback.")
    quit(0)

func _assert_character_specific_art(unit_data, generic_file: String, label: String) -> bool:
    var unit = UNIT_SCENE.instantiate()
    root.add_child(unit)
    unit.setup_from_data(unit_data)
    await process_frame
    var generic_texture = BattleArtCatalog.load_token_art(generic_file)
    var sprite_frames = BattleArtCatalog.load_character_sprite_frames(String(unit_data.display_name), "idle")
    if unit.character_sprite == null or unit.character_sprite.texture == null:
        return _fail("%s character sprite should resolve a texture." % label)
    if unit.character_sprite.texture == generic_texture:
        return _fail("%s should prefer character-specific art instead of generic %s." % [label, generic_file])
    if not sprite_frames.is_empty() and unit.character_sprite.texture != sprite_frames[0]:
        return _fail("%s should prefer sprite-first idle frame when sprite runtime frames exist." % label)
    if not unit.character_visual_root.visible:
        return _fail("%s should show character visual root when character art is available." % label)
    if unit.token_art.visible:
        return _fail("%s should hide fallback token art when character art is available." % label)
    unit.queue_free()
    await process_frame
    return true

func _assert_generic_fallback(unit_data, generic_file: String, label: String) -> bool:
    var unit = UNIT_SCENE.instantiate()
    root.add_child(unit)
    unit.setup_from_data(unit_data)
    await process_frame
    var generic_texture = BattleArtCatalog.load_token_art(generic_file)
    var character_texture = BattleArtCatalog.load_character_token_art("%s.png" % String(unit_data.display_name).to_lower())
    if character_texture != null:
        return _fail("%s fallback assertion requires a unit without character-specific art." % label)
    if unit.token_art.texture == null:
        return _fail("%s token art should resolve a fallback texture." % label)
    if generic_texture == null:
        return _fail("%s generic fallback texture %s should exist." % [label, generic_file])
    if unit.token_art.texture == null:
        return _fail("%s should resolve a visible generic fallback token texture." % label)
    if unit.character_visual_root.visible:
        return _fail("%s should keep character visual root hidden when no character art exists." % label)
    unit.queue_free()
    await process_frame
    return true

func _fail(message: String) -> bool:
    push_error(message)
    quit(1)
    return false
