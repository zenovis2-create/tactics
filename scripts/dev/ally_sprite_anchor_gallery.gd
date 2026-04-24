extends Node2D

const CHARACTER_CONFIGS := {
    "serin": {
        "label": "Serin",
        "root": "res://assets/characters/sprite_anchor_serin/runtime",
        "animations": ["idle", "cast", "attack"],
        "fps": {"idle": 6.0, "cast": 8.0, "attack": 8.0},
    },
    "rian": {
        "label": "Rian",
        "root": "res://assets/characters/sprite_anchor_rian/runtime",
        "animations": ["idle", "move", "attack"],
        "fps": {"idle": 6.0, "move": 8.0, "attack": 8.0},
    },
    "tia": {
        "label": "Tia",
        "root": "res://assets/characters/sprite_anchor_tia/runtime",
        "animations": ["idle", "move", "attack"],
        "fps": {"idle": 6.0, "move": 8.0, "attack": 8.0},
    },
    "bran": {
        "label": "Bran",
        "root": "res://assets/characters/sprite_anchor_bran/runtime",
        "animations": ["idle", "move", "attack"],
        "fps": {"idle": 6.0, "move": 8.0, "attack": 8.0},
    },
}

const CHARACTER_ORDER := ["serin", "rian", "tia", "bran"]
const SLOT_POSITIONS := [
    Vector2(-360, -80),
    Vector2(-120, -80),
    Vector2(120, -80),
    Vector2(360, -80),
]

@onready var state_label: Label = $CanvasLayer/Panel/VBox/StateLabel
@onready var hint_label: Label = $CanvasLayer/Panel/VBox/HintLabel
@onready var title_label: Label = $CanvasLayer/Panel/VBox/TitleLabel
@onready var roster_label: Label = $CanvasLayer/Panel/VBox/RosterLabel

var _current_animation_index := 0
var _sprites: Array[AnimatedSprite2D] = []


func _ready() -> void:
    _build_gallery()
    title_label.text = "Ally Sprite Anchor Gallery"
    hint_label.text = "Left/Right: switch state   Space: replay"
    _play_current_animation()


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_right"):
        _current_animation_index = (_current_animation_index + 1) % _get_animation_cycle().size()
        _play_current_animation()
        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed("ui_left"):
        _current_animation_index = posmod(_current_animation_index - 1, _get_animation_cycle().size())
        _play_current_animation()
        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed("ui_accept"):
        _play_current_animation()
        get_viewport().set_input_as_handled()


func _build_gallery() -> void:
    for index in range(CHARACTER_ORDER.size()):
        var key: String = String(CHARACTER_ORDER[index])
        var config: Dictionary = CHARACTER_CONFIGS[key]

        var sprite := AnimatedSprite2D.new()
        sprite.name = "%sSprite" % key.capitalize()
        sprite.position = SLOT_POSITIONS[index]
        sprite.sprite_frames = _build_sprite_frames(config)
        add_child(sprite)
        _sprites.append(sprite)

        var label := Label.new()
        label.text = String(config.get("label", key.capitalize()))
        label.position = sprite.position + Vector2(-40, 140)
        add_child(label)

    roster_label.text = "Roster: Serin / Rian / Tia / Bran"


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


func _get_animation_cycle() -> Array[String]:
    return ["idle", "move", "cast", "attack"]


func _play_current_animation() -> void:
    var cycle := _get_animation_cycle()
    var animation_name: String = cycle[_current_animation_index]

    for index in range(_sprites.size()):
        var key: String = String(CHARACTER_ORDER[index])
        var config: Dictionary = CHARACTER_CONFIGS[key]
        var animations: Array = config.get("animations", [])
        var sprite := _sprites[index]

        if animations.has(animation_name):
            sprite.visible = true
            sprite.play(animation_name)
        else:
            sprite.visible = true
            if animations.has("idle"):
                sprite.play("idle")

    state_label.text = "Current focus: %s" % animation_name
