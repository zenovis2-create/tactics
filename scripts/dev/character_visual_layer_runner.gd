extends SceneTree

const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")
const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const RIAN_DATA = preload("res://data/units/ally_rian.tres")
const BRAN_DATA = preload("res://data/units/ally_bran.tres")
const TIA_DATA = preload("res://data/units/ally_tia.tres")
const SERIN_DATA = preload("res://data/units/ally_serin.tres")
const ENEMY_RAIDER_DATA = preload("res://data/units/enemy_raider.tres")
const ENEMY_SKIRMISHER_DATA = preload("res://data/units/enemy_skirmisher.tres")
const VANGUARD_DATA = preload("res://data/units/ally_vanguard.tres")
const SCOUT_DATA = preload("res://data/units/ally_scout.tres")
const UnitData = preload("res://scripts/data/unit_data.gd")
const BASIC_ATTACK = preload("res://data/skills/basic_attack.tres")
const VANGUARD_CLASS = preload("res://data/classes/cls_vanguard.tres")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if not await _assert_character_art_layer_visible(RIAN_DATA, "Rian"):
        return
    if not await _assert_character_art_layer_visible(SERIN_DATA, "Serin"):
        return
    if not await _assert_character_art_layer_visible(BRAN_DATA, "Bran"):
        return
    if not await _assert_character_art_layer_visible(TIA_DATA, "Tia"):
        return
    if not await _assert_character_art_layer_visible(ENEMY_RAIDER_DATA, "Enemy Raider"):
        return
    if not await _assert_character_art_layer_visible(ENEMY_SKIRMISHER_DATA, "Enemy Skirmisher"):
        return
    if not await _assert_character_art_layer_visible(VANGUARD_DATA, "Vanguard"):
        return
    if not await _assert_character_art_layer_visible(SCOUT_DATA, "Scout"):
        return
    if not await _assert_character_art_layer_hidden_for_generic_unit():
        return
    print("[PASS] character_visual_layer_runner validated ally sprite-first visual layer behavior and generic fallback.")
    quit(0)

func _assert_character_art_layer_visible(unit_data, label: String) -> bool:
    var unit = UNIT_SCENE.instantiate()
    root.add_child(unit)
    unit.setup_from_data(unit_data)
    await process_frame
    var art_layer: CanvasItem = unit.get_node_or_null("CharacterVisualRoot")
    if art_layer == null:
        return _fail("Unit scene should expose CharacterVisualRoot layer.")
    if not art_layer.visible:
        return _fail("%s should show CharacterVisualRoot when character art exists." % label)
    var sprite_frames = BattleArtCatalog.load_character_sprite_frames(String(unit_data.display_name), "idle")
    if sprite_frames.is_empty():
        return _fail("%s should have idle sprite frames for sprite-first rendering." % label)
    if unit.character_sprite.texture != sprite_frames[0]:
        return _fail("%s should render the first idle sprite frame instead of token-photo art." % label)
    if unit.token_art.visible:
        return _fail("%s should hide generic token art when CharacterVisualRoot is available." % label)
    unit.queue_free()
    await process_frame
    return true

func _assert_character_art_layer_hidden_for_generic_unit() -> bool:
    var unit = UNIT_SCENE.instantiate()
    root.add_child(unit)
    unit.setup_from_data(_make_generic_vanguard())
    await process_frame
    var art_layer: CanvasItem = unit.get_node_or_null("CharacterVisualRoot")
    if art_layer == null:
        return _fail("Unit scene should expose CharacterVisualRoot layer.")
    if art_layer.visible:
        return _fail("Generic units without character art should keep CharacterVisualRoot hidden.")
    if not unit.token_art.visible:
        return _fail("Generic units should keep token art visible as fallback.")
    unit.queue_free()
    await process_frame
    return true

func _make_generic_vanguard() -> UnitData:
    var unit := UnitData.new()
    unit.unit_id = &"generic_vanguard_visual_fallback"
    unit.display_name = "Fallback Vanguard"
    unit.faction = "ally"
    unit.max_hp = 10
    unit.attack = 4
    unit.defense = 2
    unit.movement = 3
    unit.attack_range = 1
    unit.default_skill = BASIC_ATTACK
    unit.class_data = VANGUARD_CLASS
    return unit

func _fail(message: String) -> bool:
    push_error(message)
    quit(1)
    return false
