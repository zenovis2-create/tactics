extends SceneTree

const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")
const RIAN_DATA = preload("res://data/units/ally_rian.tres")
const UnitData = preload("res://scripts/data/unit_data.gd")
const BASIC_ATTACK = preload("res://data/skills/basic_attack.tres")
const VANGUARD_CLASS = preload("res://data/classes/cls_vanguard.tres")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if not await _assert_character_animation_stack_for_rian():
        return
    if not await _assert_attack_animation_transitions_for_rian():
        return
    if not await _assert_hit_animation_transitions_for_rian():
        return
    if not await _assert_defeat_animation_holds_before_cleanup():
        return
    if not await _assert_generic_unit_keeps_stack_hidden():
        return
    print("[PASS] character_animation_ready_runner validated Sprite2D + AnimationPlayer character stack.")
    quit(0)

func _assert_character_animation_stack_for_rian() -> bool:
    var unit = UNIT_SCENE.instantiate()
    root.add_child(unit)
    unit.setup_from_data(RIAN_DATA)
    await process_frame

    var visual_root: Node2D = unit.get_node_or_null("CharacterVisualRoot")
    var sprite: Sprite2D = unit.get_node_or_null("CharacterVisualRoot/CharacterSprite")
    var animation_player: AnimationPlayer = unit.get_node_or_null("CharacterVisualRoot/CharacterAnimationPlayer")
    if visual_root == null or sprite == null or animation_player == null:
        return _fail("Rian should expose CharacterVisualRoot/CharacterSprite/CharacterAnimationPlayer nodes.")
    if not visual_root.visible:
        return _fail("Rian should show CharacterVisualRoot when character art exists.")
    if sprite.texture == null:
        return _fail("Rian CharacterSprite should resolve a texture.")
    for animation_name in ["idle", "move", "attack", "hit", "defeat"]:
        if not animation_player.has_animation(animation_name):
            return _fail("CharacterAnimationPlayer should define %s animation." % animation_name)
    if animation_player.current_animation != "idle":
        return _fail("Rian should start on idle animation.")
    var first_texture := sprite.texture
    await create_timer(0.12).timeout
    if sprite.texture == first_texture:
        return _fail("Rian idle state should advance over battle sprite frames.")

    unit.queue_free()
    await process_frame
    return true

func _assert_attack_animation_transitions_for_rian() -> bool:
    var unit = UNIT_SCENE.instantiate()
    root.add_child(unit)
    unit.setup_from_data(RIAN_DATA)
    await process_frame

    var animation_player: AnimationPlayer = unit.get_node_or_null("CharacterVisualRoot/CharacterAnimationPlayer")
    unit.grid_position = Vector2i(1, 1)
    unit.position = Vector2(64.0, 64.0)
    unit.play_attack_animation(Vector2i(2, 1), 64.0)
    if animation_player.current_animation != "attack":
        return _fail("Rian should switch to attack animation during attack lunge.")
    await create_timer(0.30).timeout
    if unit.is_animating_attack():
        return _fail("Attack animation should finish and clear animating flag.")
    if animation_player.current_animation != "idle":
        return _fail("Rian should return to idle animation after attack finishes.")

    unit.queue_free()
    await process_frame
    return true

func _assert_hit_animation_transitions_for_rian() -> bool:
    var unit = UNIT_SCENE.instantiate()
    root.add_child(unit)
    unit.setup_from_data(RIAN_DATA)
    await process_frame

    var animation_player: AnimationPlayer = unit.get_node_or_null("CharacterVisualRoot/CharacterAnimationPlayer")
    var sprite: Sprite2D = unit.get_node_or_null("CharacterVisualRoot/CharacterSprite")
    unit.apply_damage(1)
    if animation_player.current_animation != "hit":
        return _fail("Rian should switch to hit animation when taking non-lethal damage.")
    await process_frame
    if sprite == null:
        return _fail("Rian should expose CharacterSprite for hit-pose validation.")
    if sprite.rotation_degrees == 0.0 and sprite.scale == Vector2(0.42, 0.42):
        return _fail("Rian hit reaction should visibly change pose, not only switch animation name.")
    await create_timer(0.28).timeout
    if animation_player.current_animation != "idle":
        return _fail("Rian should return to idle animation after hit reaction finishes.")
    if absf(sprite.rotation_degrees) > 0.01:
        return _fail("Rian hit pose should settle back to neutral rotation after the reaction.")

    unit.queue_free()
    await process_frame
    return true

func _assert_defeat_animation_holds_before_cleanup() -> bool:
    var unit = UNIT_SCENE.instantiate()
    root.add_child(unit)
    unit.setup_from_data(RIAN_DATA)
    await process_frame

    var animation_player: AnimationPlayer = unit.get_node_or_null("CharacterVisualRoot/CharacterAnimationPlayer")
    var sprite: Sprite2D = unit.get_node_or_null("CharacterVisualRoot/CharacterSprite")
    unit.apply_damage(unit.current_hp)
    if animation_player.current_animation != "defeat":
        return _fail("Rian should switch to defeat animation on lethal damage.")
    await create_timer(0.10).timeout
    if sprite == null:
        return _fail("Rian should expose CharacterSprite for defeat-pose validation.")
    if absf(sprite.rotation_degrees) < 10.0:
        return _fail("Rian defeat reaction should visibly tilt the sprite before cleanup.")
    if sprite.modulate.a >= 0.95:
        return _fail("Rian defeat reaction should dim the sprite before cleanup.")
    if not unit.is_inside_tree():
        return _fail("Defeat animation should keep the unit in tree briefly before cleanup.")
    await create_timer(0.36).timeout
    await process_frame
    if is_instance_valid(unit) and unit.is_inside_tree():
        return _fail("Defeated unit should clean up after defeat animation finishes.")
    return true

func _assert_generic_unit_keeps_stack_hidden() -> bool:
    var unit = UNIT_SCENE.instantiate()
    root.add_child(unit)
    unit.setup_from_data(_make_generic_vanguard())
    await process_frame

    var visual_root: Node2D = unit.get_node_or_null("CharacterVisualRoot")
    if visual_root == null:
        return _fail("Unit scene should expose CharacterVisualRoot even for fallback units.")
    if visual_root.visible:
        return _fail("Fallback units without character art should keep CharacterVisualRoot hidden.")
    if not unit.token_art.visible:
        return _fail("Fallback units should keep token art visible.")

    unit.queue_free()
    await process_frame
    return true

func _make_generic_vanguard() -> UnitData:
    var unit := UnitData.new()
    unit.unit_id = &"generic_vanguard_animation_fallback"
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
