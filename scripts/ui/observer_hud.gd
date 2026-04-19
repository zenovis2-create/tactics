class_name ObserverHUD
extends Control

# Observer HUD — displays unit positions, HP, and status during battle observation
# Shows unit cards at the bottom of the screen during observer mode

signal unit_selected(unit_id: String)
signal follow_unit_toggled(unit_id: String)

const MAX_VISIBLE_UNITS := 12

var _is_visible: bool = false
var _observed_units: Array = []  # Array[Dictionary] with unit info
var _followed_unit_id: String = ""
var _commentary_label: Label = null
var _unit_list: HBoxContainer = null

class UnitDisplayInfo:
	var unit_id: String = ""
	var unit_name: String = ""
	var hp_current: int = 0
	var hp_max: int = 1
	var position: Vector3 = Vector3.ZERO
	var statusEffects: Array[String] = []
	var faction: String = ""
	var is_selected: bool = false

func _ready() -> void:
	visible = false
	_modulate = Color(1, 1, 1, 0.9)
	_build_ui()

func _build_ui() -> void:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	add_child(vbox)
	vbox.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	vbox.offset_top = -200
	vbox.offset_bottom = 0

	var unit_scroll := ScrollContainer.new()
	unit_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	unit_scroll.custom_minimum_size.y = 120.0
	vbox.add_child(unit_scroll)

	_unit_list = HBoxContainer.new()
	_unit_list.add_theme_constant_override("separation", 8)
	unit_scroll.add_child(_unit_list)

	var commentary := Label.new()
	commentary.text = "Tactical Commentary:"
	commentary.add_theme_font_size_override("font_size", 16)
	vbox.add_child(commentary)

	_commentary_label = Label.new()
	_commentary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_commentary_label.custom_minimum_size.y = 40.0
	vbox.add_child(_commentary_label)

	var follow_hint := Label.new()
	follow_hint.text = "Right-click unit to follow | Scroll to zoom | WASD to pan"
	follow_hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	follow_hint.add_theme_font_size_override("font_size", 12)
	vbox.add_child(follow_hint)

func show_hud() -> void:
	_is_visible = true
	visible = true

func hide_hud() -> void:
	_is_visible = false
	visible = false

func is_visible() -> bool:
	return _is_visible

func update_units(unit_data: Array) -> void:
	_observed_units.clear()
	for data: Dictionary in unit_data:
		var info := UnitDisplayInfo.new()
		info.unit_id = data.get("unit_id", "")
		info.unit_name = data.get("name", "Unknown")
		info.hp_current = data.get("hp", 0)
		info.hp_max = data.get("hp_max", 1)
		info.position = data.get("position", Vector3.ZERO)
		info.statusEffects = Array(data.get("status_effects", []))
		info.faction = data.get("faction", "neutral")
		_observed_units.append(info)
	_refresh_unit_display()

func _refresh_unit_display() -> void:
	if _unit_list == null:
		return
	for child in _unit_list.get_children():
		_unit_list.remove_child(child)
		child.queue_free()
	var shown: int = 0
	for info: UnitDisplayInfo in _observed_units:
		if shown >= MAX_VISIBLE_UNITS:
			break
		var card := _make_unit_card(info)
		_unit_list.add_child(card)
		shown += 1

func _make_unit_card(info: UnitDisplayInfo) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(120.0, 100.0)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.text = info.unit_name
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_lbl)

	var hp_text := "%d/%d" % [info.hp_current, info.hp_max]
	var hp_lbl := Label.new()
	hp_lbl.text = hp_text
	hp_lbl.add_theme_font_size_override("font_size", 12)
	hp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hp_lbl)

	var bar_bg := ColorRect.new()
	bar_bg.custom_minimum_size = Vector2(100.0, 8.0)
	bar_bg.color = Color(0.2, 0.2, 0.2)
	vbox.add_child(bar_bg)

	var bar_fg := ColorRect.new()
	bar_fg.custom_minimum_size = Vector2(maxf(0.0, 100.0 * info.hp_current / maxi(1, info.hp_max)), 8.0)
	bar_fg.color = _get_hp_color(info.hp_current, info.hp_max)
	vbox.add_child(bar_fg)

	var pos_lbl := Label.new()
	pos_lbl.text = "(%.0f, %.0f)" % [info.position.x, info.position.z]
	pos_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	pos_lbl.add_theme_font_size_override("font_size", 10)
	pos_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(pos_lbl)

	if not info.statusEffects.is_empty():
		var effects_lbl := Label.new()
		effects_lbl.text = " ".join(info.statusEffects)
		effects_lbl.add_theme_color_override("font_color", Color(0.8, 0.6, 0.0))
		effects_lbl.add_theme_font_size_override("font_size", 10)
		effects_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(effects_lbl)

	var follow_btn := Button.new()
	follow_btn.text = "FOLLOW" if _followed_unit_id != info.unit_id else "UNFOLLOW"
	follow_btn.pressed.connect(func() -> void:
		if _followed_unit_id == info.unit_id:
			_followed_unit_id = ""
		else:
			_followed_unit_id = info.unit_id
		follow_unit_toggled.emit(info.unit_id)
		_refresh_unit_display()
	)
	vbox.add_child(follow_btn)

	return panel

func _get_hp_color(current: int, maximum: int) -> Color:
	var ratio := float(current) / float(maxi(1, maximum))
	if ratio > 0.6:
		return Color(0.2, 0.8, 0.2)
	elif ratio > 0.3:
		return Color(0.9, 0.7, 0.1)
	else:
		return Color(0.9, 0.2, 0.1)

func update_commentary(text: String) -> void:
	if _commentary_label != null:
		_commentary_label.text = text

func get_followed_unit_id() -> String:
	return _followed_unit_id

func get_observed_unit_count() -> int:
	return _observed_units.size()
