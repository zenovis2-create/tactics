extends Node2D

const GROUND_TILE_PATH_A := "res://assets/environment/fortress_tile_01/runtime/fortress_tile_01_integration_v01.png"
const GROUND_TILE_PATH_B := "res://assets/environment/fortress_tile_02/runtime/fortress_tile_02_integration_v01.png"
const EDGE_TILE_PATH := "res://assets/environment/fortress_edge_01/runtime/fortress_edge_01_integration_v01.png"
const ALTAR_PATH := "res://assets/props/altar_01/runtime/altar_01_integration_v01.png"
const LEVER_PATH := "res://assets/props/lever_01/runtime/lever_01_integration_v01.png"
const GATE_CONTROL_PATH := "res://assets/props/gate_control_01/runtime/gate_control_01_integration_v01.png"
const SHIELD_PATH := "res://assets/props/paladin_shield/runtime/paladin_shield_integration_v01.png"

const CHARACTER_CONFIGS := {
	"rian": {
		"label": "Rian",
		"root": "res://assets/characters/sprite_anchor_rian/runtime",
		"animations": ["idle", "move", "attack"],
		"fps": {"idle": 6.0, "move": 8.0, "attack": 8.0},
		"position": Vector2(-250, 20),
	},
	"bran": {
		"label": "Bran",
		"root": "res://assets/characters/sprite_anchor_bran/runtime",
		"animations": ["idle", "move", "attack"],
		"fps": {"idle": 6.0, "move": 8.0, "attack": 8.0},
		"position": Vector2(-70, 34),
	},
	"enemy_raider": {
		"label": "Enemy Raider",
		"root": "res://assets/characters/sprite_anchor_enemy_raider/runtime",
		"animations": ["idle", "move", "attack"],
		"fps": {"idle": 6.0, "move": 8.0, "attack": 8.0},
		"position": Vector2(250, -22),
	},
	"enemy_skirmisher": {
		"label": "Enemy Skirmisher",
		"root": "res://assets/characters/sprite_anchor_enemy_skirmisher/runtime",
		"animations": ["idle", "move", "attack"],
		"fps": {"idle": 6.0, "move": 8.0, "attack": 8.0},
		"position": Vector2(430, -40),
	},
}

const CHARACTER_ORDER := ["rian", "bran", "enemy_raider", "enemy_skirmisher"]
const ANIMATION_CYCLE := ["idle", "move", "attack"]

@onready var title_label: Label = $CanvasLayer/Panel/VBox/TitleLabel
@onready var hint_label: Label = $CanvasLayer/Panel/VBox/HintLabel
@onready var state_label: Label = $CanvasLayer/Panel/VBox/StateLabel
@onready var summary_label: Label = $CanvasLayer/Panel/VBox/SummaryLabel
@onready var ground_root: Node2D = $GroundRoot
@onready var prop_root: Node2D = $PropRoot
@onready var character_root: Node2D = $CharacterRoot

var _current_animation_index := 0
var _sprites: Dictionary = {}


func _ready() -> void:
	_build_ground()
	_build_props()
	_build_characters()
	title_label.text = "CH06 Iron Keep Preview"
	hint_label.text = "Left/Right: switch state   Space: replay"
	summary_label.text = "Goal: validate fortress-family ground, edge, objective, and support assets under heavier siege and iron-keep pressure."
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
	if texture_a == null or texture_b == null:
		push_warning("Missing iron-keep ground textures.")
		return
	for x in range(-4, 5):
		for y in range(-2, 3):
			var sprite := Sprite2D.new()
			sprite.texture = texture_a if (x + y) % 2 == 0 else texture_b
			sprite.position = Vector2(x * 180, y * 118 + 220)
			sprite.modulate = Color(0.92, 0.92, 0.96, 0.92 if (x + y) % 2 == 0 else 0.84)
			sprite.scale = Vector2(0.62, 0.62)
			ground_root.add_child(sprite)

	var edge_texture := _load_runtime_png(EDGE_TILE_PATH)
	if edge_texture != null:
		for x in range(-4, 5):
			var edge := Sprite2D.new()
			edge.texture = edge_texture
			edge.position = Vector2(x * 180, -30)
			edge.scale = Vector2(1.3, 1.3)
			ground_root.add_child(edge)


func _build_props() -> void:
	_add_prop(ALTAR_PATH, Vector2(470, 34), Vector2(0.38, 0.38))
	_add_prop(LEVER_PATH, Vector2(160, 90), Vector2(2.3, 2.3))
	_add_prop(GATE_CONTROL_PATH, Vector2(610, 98), Vector2(2.7, 2.7))
	_add_prop(SHIELD_PATH, Vector2(-390, 112), Vector2(0.2, 0.2))


func _add_prop(path: String, pos: Vector2, scale_value: Vector2) -> void:
	var texture := _load_runtime_png(path)
	if texture == null:
		return
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = scale_value
	prop_root.add_child(sprite)


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
		label.position = sprite.position + Vector2(-60, 120)
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
		else:
			sprite.play("idle")
	state_label.text = "Current focus: %s" % animation_name
