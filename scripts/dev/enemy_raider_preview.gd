extends Node2D

const ROOT_DIR := "res://assets/characters/sprite_anchor_enemy_raider/runtime"
const ANIMATION_DIRS := {
    "idle": ROOT_DIR + "/idle",
    "move": ROOT_DIR + "/move",
    "attack": ROOT_DIR + "/attack",
}
const ANIMATION_ORDER := ["idle", "move", "attack"]
const ANIMATION_FPS := {
    "idle": 6.0,
    "move": 8.0,
    "attack": 8.0,
}

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var title_label: Label = $CanvasLayer/Panel/VBox/TitleLabel
@onready var hint_label: Label = $CanvasLayer/Panel/VBox/HintLabel
@onready var state_label: Label = $CanvasLayer/Panel/VBox/StateLabel

var _current_animation_index := 0


func _ready() -> void:
    var frames := SpriteFrames.new()
    for animation_name in ANIMATION_ORDER:
        frames.add_animation(animation_name)
        frames.set_animation_loop(animation_name, animation_name == "idle" or animation_name == "move")
        frames.set_animation_speed(animation_name, float(ANIMATION_FPS.get(animation_name, 6.0)))
        _append_frames(animation_name, frames)

    animated_sprite.sprite_frames = frames
    animated_sprite.centered = true
    _play_current_animation()

    title_label.text = "Enemy Raider Preview"
    hint_label.text = "Left/Right: switch state   Space: replay current"


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_right"):
        _current_animation_index = (_current_animation_index + 1) % ANIMATION_ORDER.size()
        _play_current_animation()
        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed("ui_left"):
        _current_animation_index = posmod(_current_animation_index - 1, ANIMATION_ORDER.size())
        _play_current_animation()
        get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed("ui_accept"):
        _play_current_animation()
        get_viewport().set_input_as_handled()


func _play_current_animation() -> void:
    var animation_name: String = String(ANIMATION_ORDER[_current_animation_index])
    animated_sprite.play(animation_name)
    state_label.text = "Current: %s" % animation_name


func _append_frames(animation_name: String, frames: SpriteFrames) -> void:
    for file_name in _list_pngs(ANIMATION_DIRS.get(animation_name, "")):
        var texture := _load_runtime_png("%s/%s/%s" % [ROOT_DIR, animation_name, file_name])
        if texture != null:
            frames.add_frame(animation_name, texture)


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
