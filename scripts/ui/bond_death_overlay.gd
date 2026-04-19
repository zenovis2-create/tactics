class_name BondDeathOverlay
extends CanvasLayer

signal bond_death_started
signal bond_ending_complete

const BondEndingRegistry = preload("res://scripts/battle/bond_ending_registry.gd")
const BondEnding = BondEndingRegistry.BondEnding

const FLASH_DURATION := 0.3
const VIGNETTE_FADE_DURATION := 0.5
const PAIR_HOLD_DURATION := 1.0
const TYPEWRITER_DURATION := 4.0
const CONTEMPLATION_HOLD_DURATION := 2.2
const FADE_TO_BLACK_DURATION := 2.0
const SLOW_MOTION_TIME_SCALE := 0.35

var _sequence_token: int = 0
var _slow_motion_previous_scale: float = 1.0

@onready var _screen_flash: ColorRect = _ensure_screen_flash()
@onready var dark_vignette: ColorRect = _ensure_dark_vignette()
@onready var _content_stack: VBoxContainer = _ensure_content_stack()
@onready var pair_names: Label = _ensure_pair_names_label()
@onready var _ending_title: Label = _ensure_ending_title_label()
@onready var ending_text: Label = _ensure_ending_text_label()
@onready var fade_out: AnimationPlayer = _ensure_fade_out_player()

func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_reset_visual_state()

func trigger_bond_ending(ending: BondEnding) -> void:
	if ending == null:
		return
	var resolved_pair_names := _build_pair_names(ending)
	var resolved_title := ending.ending_title.strip_edges()
	var resolved_text := ending.ending_text.strip_edges()
	if resolved_pair_names.is_empty() or resolved_text.is_empty():
		return

	_sequence_token += 1
	var token := _sequence_token
	bond_death_started.emit()
	visible = true
	_enter_slow_motion()
	_reset_visual_state()

	pair_names.text = resolved_pair_names
	_ending_title.text = resolved_title if not resolved_title.is_empty() else "Bond Ending"
	ending_text.text = ""

	_screen_flash.visible = true
	var flash_tween := create_tween()
	flash_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	flash_tween.tween_property(_screen_flash, "modulate:a", 0.0, FLASH_DURATION)
	await _wait_real_time(FLASH_DURATION)
	if token != _sequence_token:
		return
	_screen_flash.visible = false

	dark_vignette.visible = true
	var vignette_tween := create_tween()
	vignette_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	vignette_tween.tween_property(dark_vignette, "modulate:a", 0.82, VIGNETTE_FADE_DURATION)
	await _wait_real_time(VIGNETTE_FADE_DURATION)
	if token != _sequence_token:
		return

	pair_names.visible = true
	_ending_title.visible = true
	var title_tween := create_tween()
	title_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	title_tween.set_parallel(true)
	title_tween.tween_property(pair_names, "modulate:a", 1.0, 0.35)
	title_tween.tween_property(_ending_title, "modulate:a", 1.0, 0.35)
	title_tween.tween_property(pair_names, "position:y", 0.0, 0.35)
	title_tween.tween_property(_ending_title, "position:y", 0.0, 0.35)
	await _wait_real_time(PAIR_HOLD_DURATION)
	if token != _sequence_token:
		return

	ending_text.visible = true
	ending_text.modulate.a = 1.0
	await _type_in_text(resolved_text, TYPEWRITER_DURATION, token)
	if token != _sequence_token:
		return

	await _wait_real_time(CONTEMPLATION_HOLD_DURATION)
	if token != _sequence_token:
		return

	_play_fade_out(FADE_TO_BLACK_DURATION)
	await _wait_real_time(FADE_TO_BLACK_DURATION)
	if token != _sequence_token:
		return

	_exit_slow_motion()
	bond_ending_complete.emit()

func clear_overlay() -> void:
	_sequence_token += 1
	_exit_slow_motion()
	visible = false
	_reset_visual_state()

func _type_in_text(full_text: String, duration: float, token: int) -> void:
	var normalized := full_text.strip_edges()
	if normalized.is_empty():
		return
	var total_characters: int = max(1, normalized.length())
	var step_duration: float = duration / float(total_characters)
	for character_index in range(total_characters):
		if token != _sequence_token:
			return
		ending_text.text = normalized.substr(0, character_index + 1)
		await _wait_real_time(step_duration)

func _play_fade_out(duration: float) -> void:
	if fade_out != null and fade_out.has_animation("fade_out"):
		fade_out.play("fade_out")
		return
	var fade_tween := create_tween()
	fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_tween.set_parallel(true)
	fade_tween.tween_property(dark_vignette, "modulate:a", 1.0, duration)
	fade_tween.tween_property(pair_names, "modulate:a", 0.0, duration * 0.75)
	fade_tween.tween_property(_ending_title, "modulate:a", 0.0, duration * 0.75)
	fade_tween.tween_property(ending_text, "modulate:a", 0.0, duration * 0.75)

func _wait_real_time(duration: float) -> void:
	await get_tree().create_timer(duration, true, false, true).timeout

func _enter_slow_motion() -> void:
	_slow_motion_previous_scale = Engine.time_scale
	Engine.time_scale = SLOW_MOTION_TIME_SCALE

func _exit_slow_motion() -> void:
	Engine.time_scale = _slow_motion_previous_scale

func _reset_visual_state() -> void:
	if _screen_flash != null:
		_screen_flash.visible = false
		_screen_flash.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if dark_vignette != null:
		dark_vignette.visible = false
		dark_vignette.modulate = Color(0.0, 0.0, 0.0, 0.0)
	if pair_names != null:
		pair_names.visible = false
		pair_names.modulate = Color(1.0, 1.0, 1.0, 0.0)
		pair_names.position = Vector2(0.0, 10.0)
	if _ending_title != null:
		_ending_title.visible = false
		_ending_title.modulate = Color(1.0, 1.0, 1.0, 0.0)
		_ending_title.position = Vector2(0.0, 14.0)
	if ending_text != null:
		ending_text.visible = false
		ending_text.modulate = Color(1.0, 1.0, 1.0, 0.0)
		ending_text.text = ""

func _ensure_screen_flash() -> ColorRect:
	var rect := get_node_or_null("screen_flash") as ColorRect
	if rect != null:
		return rect
	rect = ColorRect.new()
	rect.name = "screen_flash"
	rect.anchor_right = 1.0
	rect.anchor_bottom = 1.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.color = Color.WHITE
	add_child(rect)
	move_child(rect, 0)
	return rect

func _ensure_dark_vignette() -> ColorRect:
	var rect := get_node_or_null("dark_vignette") as ColorRect
	if rect != null:
		return rect
	rect = ColorRect.new()
	rect.name = "dark_vignette"
	rect.anchor_right = 1.0
	rect.anchor_bottom = 1.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.color = Color(0.02, 0.02, 0.03, 1.0)
	add_child(rect)
	return rect

func _ensure_content_stack() -> VBoxContainer:
	var stack := get_node_or_null("Content") as VBoxContainer
	if stack != null:
		return stack
	stack = VBoxContainer.new()
	stack.name = "Content"
	stack.anchor_left = 0.18
	stack.anchor_top = 0.24
	stack.anchor_right = 0.82
	stack.anchor_bottom = 0.78
	stack.offset_left = 0.0
	stack.offset_top = 0.0
	stack.offset_right = 0.0
	stack.offset_bottom = 0.0
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_theme_constant_override("separation", 12)
	add_child(stack)
	return stack

func _ensure_pair_names_label() -> Label:
	var label := _content_stack.get_node_or_null("pair_names") as Label
	if label != null:
		return label
	label = Label.new()
	label.name = "pair_names"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", _build_system_font(700))
	label.add_theme_font_size_override("font_size", 24)
	_content_stack.add_child(label)
	return label

func _ensure_ending_title_label() -> Label:
	var label := _content_stack.get_node_or_null("ending_title") as Label
	if label != null:
		return label
	label = Label.new()
	label.name = "ending_title"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", _build_system_font(700))
	label.add_theme_font_size_override("font_size", 28)
	_content_stack.add_child(label)
	return label

func _ensure_ending_text_label() -> Label:
	var label := _content_stack.get_node_or_null("ending_text") as Label
	if label != null:
		return label
	label = Label.new()
	label.name = "ending_text"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", _build_system_font(400))
	label.add_theme_font_size_override("font_size", 20)
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_stack.add_child(label)
	return label

func _ensure_fade_out_player() -> AnimationPlayer:
	var player := get_node_or_null("fade_out") as AnimationPlayer
	if player != null:
		return player
	player = AnimationPlayer.new()
	player.name = "fade_out"
	add_child(player)
	return player

func _build_system_font(weight: int) -> SystemFont:
	var font := SystemFont.new()
	font.font_weight = weight
	return font

func _build_pair_names(ending: BondEnding) -> String:
	var names: Array[String] = []
	for unit_id in ending.units:
		var normalized := String(unit_id).strip_edges().trim_prefix("ally_").trim_suffix("_ally")
		if normalized.is_empty():
			continue
		names.append(normalized.capitalize())
	if names.is_empty():
		var pair_id := ending.pair_id.strip_edges()
		if pair_id.is_empty():
			return "Bonded Pair"
		for pair_part in pair_id.split("+", false):
			names.append(pair_part.capitalize())
	return " & ".join(names)
