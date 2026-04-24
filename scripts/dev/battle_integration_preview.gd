extends Node2D

const CHARACTER_CONFIGS := {
    "serin": {
        "label": "Serin",
        "root": "res://assets/characters/sprite_anchor_serin/runtime",
        "animations": ["idle", "cast", "attack"],
        "fps": {"idle": 6.0, "cast": 8.0, "attack": 8.0},
        "position": Vector2(-220, 40),
    },
    "rian": {
        "label": "Rian",
        "root": "res://assets/characters/sprite_anchor_rian/runtime",
        "animations": ["idle", "move", "attack"],
        "fps": {"idle": 6.0, "move": 8.0, "attack": 8.0},
        "position": Vector2(-60, 48),
    },
    "tia": {
        "label": "Tia",
        "root": "res://assets/characters/sprite_anchor_tia/runtime",
        "animations": ["idle", "move", "attack"],
        "fps": {"idle": 6.0, "move": 8.0, "attack": 8.0},
        "position": Vector2(100, 40),
    },
    "bran": {
        "label": "Bran",
        "root": "res://assets/characters/sprite_anchor_bran/runtime",
        "animations": ["idle", "move", "attack"],
        "fps": {"idle": 6.0, "move": 8.0, "attack": 8.0},
        "position": Vector2(260, 48),
    },
    "enemy_raider": {
        "label": "Enemy Raider",
        "root": "res://assets/characters/sprite_anchor_enemy_raider/runtime",
        "animations": ["idle", "move", "attack"],
        "fps": {"idle": 6.0, "move": 8.0, "attack": 8.0},
        "position": Vector2(430, -20),
    },
}

const CHARACTER_ORDER := ["serin", "rian", "tia", "bran", "enemy_raider"]
const ANIMATION_CYCLE := ["idle", "move", "cast", "attack"]
const GROUND_TILE_PATH_A := "res://assets/environment/forest_tile_01/runtime/forest_tile_01_clean_v01.png"
const GROUND_TILE_PATH_B := "res://assets/environment/forest_tile_02/runtime/forest_tile_02_clean_v01.png"
const GROUND_TILE_PATH_C := "res://assets/environment/fortress_tile_01/runtime/fortress_tile_01_clean_v01.png"
const ALTAR_ICON_PATH := "res://assets/props/altar_01/runtime/altar_01_integration_v01.png"
const SHIELD_PATH := "res://assets/props/paladin_shield/runtime/paladin_shield_integration_v01.png"

@onready var state_label: Label = $CanvasLayer/Panel/VBox/StateLabel
@onready var hint_label: Label = $CanvasLayer/Panel/VBox/HintLabel
@onready var title_label: Label = $CanvasLayer/Panel/VBox/TitleLabel
@onready var summary_label: Label = $CanvasLayer/Panel/VBox/SummaryLabel
@onready var ground_root: Node2D = $GroundRoot
@onready var character_root: Node2D = $CharacterRoot
@onready var prop_root: Node2D = $PropRoot

var _current_animation_index := 0
var _sprites: Dictionary = {}


func _ready() -> void:
    _build_ground()
    _build_prop_layer()
    _build_characters()
    title_label.text = "Battle Integration Preview"
    hint_label.text = "Left/Right: switch state   Space: replay"
    summary_label.text = "Goal: confirm character readability over forest ground and objective prop."
    _play_current_animation()


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_right"):
        _current_animation_index = (_current_animation_index + 1) % ANIMATION_CYCLE.size()
        _play_current_animation()
        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed("ui_left"):
        _current_animation_index = posmod(_current_animation_index - 1, ANIMATION_CYCLE.size())
        _play_current_animation()
        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed("ui_accept"):
        _play_current_animation()
        get_viewport().set_input_as_handled()


func _build_ground() -> void:
    var texture_a := _load_runtime_png(GROUND_TILE_PATH_A)
    var texture_b := _load_runtime_png(GROUND_TILE_PATH_B)
    var texture_c := _load_runtime_png(GROUND_TILE_PATH_C)
    if texture_a == null or texture_b == null or texture_c == null:
        push_warning("Missing ground tile textures for integration preview.")
        return

    for x in range(-5, 6):
        for y in range(-2, 3):
            var sprite := Sprite2D.new()
            var selector := posmod(x + y, 3)
            if selector == 0:
                sprite.texture = texture_a
            elif selector == 1:
                sprite.texture = texture_b
            else:
                sprite.texture = texture_c
            sprite.position = Vector2(x * 180, y * 120 + 210)
            sprite.modulate = Color(1, 1, 1, 0.92 if selector == 0 else (0.84 if selector == 1 else 0.88))
            sprite.scale = Vector2(0.62, 0.62)
            ground_root.add_child(sprite)


func _build_prop_layer() -> void:
    var altar_texture := _load_runtime_png(ALTAR_ICON_PATH)
    if altar_texture == null:
        push_warning("Missing altar icon texture for integration preview.")
        return

    var altar := Sprite2D.new()
    altar.texture = altar_texture
    altar.position = Vector2(470, 82)
    altar.scale = Vector2(0.52, 0.52)
    prop_root.add_child(altar)

    var halo := ColorRect.new()
    halo.position = altar.position + Vector2(-56, -56)
    halo.size = Vector2(112, 112)
    halo.color = Color(1.0, 0.92, 0.68, 0.18)
    prop_root.add_child(halo)

    var shield_texture := _load_runtime_png(SHIELD_PATH)
    if shield_texture == null:
        push_warning("Missing paladin shield texture for integration preview.")
        return

    var shield := Sprite2D.new()
    shield.texture = shield_texture
    shield.position = Vector2(-300, 118)
    shield.scale = Vector2(0.22, 0.22)
    prop_root.add_child(shield)


func _build_characters() -> void:
    for key_variant in CHARACTER_ORDER:
        var key: String = String(key_variant)
        var config: Dictionary = CHARACTER_CONFIGS[key]
        var sprite := AnimatedSprite2D.new()
        sprite.name = "%sSprite" % key.capitalize()
        sprite.position = config["position"]
        sprite.sprite_frames = _build_sprite_frames(config)
        character_root.add_child(sprite)
        _sprites[key] = sprite

        var label := Label.new()
        label.text = String(config.get("label", key))
        label.position = sprite.position + Vector2(-48, 120)
        character_root.add_child(label)


func _build_sprite_frames(config: Dictionary) -> SpriteFrames:
    var frames := SpriteFrames.new()
    var animations: Array = config.get("animations", [])
    var fps_cfg: Dictionary = config.get("fps", {})
    var root: String = String(config.get("root", ""))

    for animation_name_variant in animations:
        var animation_name := String(animation_name_variant)
        frames.add_animation(animation_name)
        frames.set_animation_loop(animation_name, animation_name == "idle" or animation_name == "move")
        frames.set_animation_speed(animation_name, float(fps_cfg.get(animation_name, 6.0)))

        for file_name in _list_pngs("%s/%s" % [root, animation_name]):
            var texture := _load_runtime_png("%s/%s/%s" % [root, animation_name, file_name])
            if texture != null:
                frames.add_frame(animation_name, texture)

    return frames


func _list_pngs(dir_path: String) -> PackedStringArray:
    var files := PackedStringArray()
    var dir := DirAccess.open(dir_path)
    if dir == null:
        push_warning("Could not open runtime frame directory %s" % dir_path)
        return files

    dir.list_dir_begin()
    while true:
        var file_name := dir.get_next()
        if file_name.is_empty():
            break
        if dir.current_is_dir():
            continue
        if file_name.to_lower().ends_with(".png"):
            files.append(file_name)
    dir.list_dir_end()
    files.sort()
    return files


func _load_runtime_png(resource_path: String) -> Texture2D:
    var absolute_path := ProjectSettings.globalize_path(resource_path)
    if not FileAccess.file_exists(absolute_path):
        return null
    var image := Image.new()
    if image.load(absolute_path) != OK:
        return null
    return ImageTexture.create_from_image(image)


func _play_current_animation() -> void:
    var animation_name: String = String(ANIMATION_CYCLE[_current_animation_index])

    for key_variant in CHARACTER_ORDER:
        var key: String = String(key_variant)
        var config: Dictionary = CHARACTER_CONFIGS[key]
        var animations: Array = config.get("animations", [])
        var sprite: AnimatedSprite2D = _sprites.get(key, null)
        if sprite == null:
            continue
        if animations.has(animation_name):
            sprite.play(animation_name)
        elif animations.has("idle"):
            sprite.play("idle")

    state_label.text = "Current focus: %s" % animation_name
