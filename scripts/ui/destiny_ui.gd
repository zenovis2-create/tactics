class_name DestinyUI
extends Control

signal destiny_change_requested(chapter_id: String, choice_key: String, new_value)

const TITLE_TEXT := "역사의 기록자"
const SUBTITLE_TEXT := "NG+ 3에서解锁 — 과거의 결정을 다시 고르기"
const UNLOCK_WARNING_TEXT := "이 패널은 NG+ 3에서 해제됩니다."
const EMPTY_STATE_TEXT := "아직 되돌릴 결정이 없습니다."
const REQUEST_BUTTON_TEXT := "Request Change"

var _destiny_manager: Node = null
var _root_stack: VBoxContainer
var _status_row: HBoxContainer
var _warning_label: Label
var _count_label: Label
var _scroll_container: ScrollContainer
var _decision_list: VBoxContainer
var _empty_state_label: Label
var _manager_signal_names: Array[String] = ["decisions_changed", "decision_changed", "destiny_changed", "state_changed", "refresh_requested"]

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_interface()
	var parent_manager := _get_node_or_null("../DestinyManager")
	if parent_manager != null:
		bind_destiny_manager(parent_manager)
	else:
		_refresh_unlock_state()
		_rebuild_decision_list()

func bind_destiny_manager(destiny_manager: Node) -> void:
	if _destiny_manager == destiny_manager:
		refresh()
		return
	_unbind_manager_signals()
	_destiny_manager = destiny_manager
	_bind_manager_signals()
	refresh()

func refresh() -> void:
	_refresh_unlock_state()
	_rebuild_decision_list()

func request_change(chapter_id: String, choice_key: String, new_value) -> void:
	var normalized_chapter_id := chapter_id.strip_edges()
	var normalized_choice_key := choice_key.strip_edges()
	if normalized_chapter_id.is_empty() or normalized_choice_key.is_empty():
		push_warning("DestinyUI rejected an empty change request.")
		return
	if _destiny_manager != null:
		if _destiny_manager.has_method("request_change"):
			_destiny_manager.call("request_change", normalized_chapter_id, normalized_choice_key, new_value)
		elif _destiny_manager.has_method("request_destiny_change"):
			_destiny_manager.call("request_destiny_change", normalized_chapter_id, normalized_choice_key, new_value)
		emit_signal("destiny_change_requested", normalized_chapter_id, normalized_choice_key, new_value)
	else:
		emit_signal("destiny_change_requested", normalized_chapter_id, normalized_choice_key, new_value)

func _build_interface() -> void:
	var root_margin := MarginContainer.new()
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 28)
	root_margin.add_theme_constant_override("margin_top", 24)
	root_margin.add_theme_constant_override("margin_right", 28)
	root_margin.add_theme_constant_override("margin_bottom", 24)
	add_child(root_margin)

	_root_stack = VBoxContainer.new()
	_root_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_root_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_root_stack.add_theme_constant_override("separation", 12)
	root_margin.add_child(_root_stack)

	var title_label := Label.new()
	title_label.text = TITLE_TEXT
	title_label.add_theme_font_size_override("font_size", 30)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_root_stack.add_child(title_label)

	var subtitle_label := Label.new()
	subtitle_label.text = SUBTITLE_TEXT
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.modulate = Color(0.82, 0.8, 0.72)
	_root_stack.add_child(subtitle_label)

	_status_row = HBoxContainer.new()
	_status_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status_row.add_theme_constant_override("separation", 18)
	_root_stack.add_child(_status_row)

	_count_label = _make_status_label("Changes Applied: 0")
	_count_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status_row.add_child(_count_label)

	_warning_label = _make_status_label(UNLOCK_WARNING_TEXT)
	_warning_label.modulate = Color(0.96, 0.68, 0.34)
	_warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_warning_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status_row.add_child(_warning_label)

	_scroll_container = ScrollContainer.new()
	_scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll_container.custom_minimum_size = Vector2(0.0, 220.0)
	_root_stack.add_child(_scroll_container)

	_decision_list = VBoxContainer.new()
	_decision_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_decision_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_decision_list.add_theme_constant_override("separation", 10)
	_scroll_container.add_child(_decision_list)

	_empty_state_label = Label.new()
	_empty_state_label.text = EMPTY_STATE_TEXT
	_empty_state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_empty_state_label.modulate = Color(0.78, 0.76, 0.7)
	_empty_state_label.visible = false
	_decision_list.add_child(_empty_state_label)

func _rebuild_decision_list() -> void:
	_clear_children(_decision_list)
	if _decision_list == null:
		return
	var decisions := _get_decision_records()
	var applied_count := 0
	for decision in decisions:
		var decision_card := _make_decision_card(decision)
		if decision_card == null:
			continue
		_decision_list.add_child(decision_card)
		applied_count += 1
	_count_label.text = "Changes Applied: %d" % applied_count
	var unlocked := _is_ng_plus_three_unlocked()
	_warning_label.visible = not unlocked
	if not unlocked:
		_warning_label.text = UNLOCK_WARNING_TEXT
	_empty_state_label.visible = applied_count == 0
	if applied_count == 0:
		_empty_state_label.text = "아직 기록된 변경이 없습니다."

func _make_decision_card(decision: Dictionary) -> HBoxContainer:
	var chapter_id := String(decision.get("chapter_id", "")).strip_edges()
	var choice_key := String(decision.get("choice_key", "")).strip_edges()
	if chapter_id.is_empty() or choice_key.is_empty():
		return null

	var old_value: Variant = _extract_decision_value(decision, ["old_value", "previous_value", "from_value", "before_value"])
	var new_value: Variant = _extract_decision_value(decision, ["new_value", "current_value", "to_value", "after_value"])
	var display_new_value: Variant = new_value
	if display_new_value == null and decision.has("requested_value"):
		display_new_value = decision.get("requested_value")

	var card := HBoxContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_constant_override("separation", 14)

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_theme_constant_override("separation", 6)
	margin.add_child(stack)

	var chapter_label := Label.new()
	chapter_label.text = "Chapter: %s" % chapter_id
	chapter_label.add_theme_font_size_override("font_size", 16)
	stack.add_child(chapter_label)

	var choice_label := Label.new()
	choice_label.text = "Choice: %s" % choice_key
	choice_label.modulate = Color(0.88, 0.86, 0.8)
	stack.add_child(choice_label)

	var old_label := Label.new()
	old_label.text = "Old Value: %s" % _format_value(old_value)
	old_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(old_label)

	var new_label := Label.new()
	new_label.text = "New Value: %s" % _format_value(display_new_value)
	new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	new_label.modulate = Color(0.82, 0.94, 0.84)
	stack.add_child(new_label)

	var action_button := Button.new()
	action_button.text = REQUEST_BUTTON_TEXT
	action_button.disabled = not _is_ng_plus_three_unlocked()
	action_button.pressed.connect(func() -> void:
		request_change(chapter_id, choice_key, display_new_value)
	)
	card.add_child(action_button)

	return card

func _get_node_or_null(path: NodePath) -> Node:
	return get_node_or_null(path)

func _bind_manager_signals() -> void:
	if _destiny_manager == null:
		return
	for signal_name in _manager_signal_names:
		if _destiny_manager.has_signal(signal_name):
			var callable := Callable(self, "_on_manager_state_changed")
			if not _destiny_manager.is_connected(signal_name, callable):
				_destiny_manager.connect(signal_name, callable)

func _unbind_manager_signals() -> void:
	if _destiny_manager == null:
		return
	var callable := Callable(self, "_on_manager_state_changed")
	for signal_name in _manager_signal_names:
		if _destiny_manager.has_signal(signal_name) and _destiny_manager.is_connected(signal_name, callable):
			_destiny_manager.disconnect(signal_name, callable)

func _on_manager_state_changed() -> void:
	refresh()

func _refresh_unlock_state() -> void:
	var unlocked := _is_ng_plus_three_unlocked()
	_warning_label.visible = not unlocked
	_warning_label.text = UNLOCK_WARNING_TEXT if not unlocked else ""

func _get_decision_records() -> Array[Dictionary]:
	if _destiny_manager == null:
		return []
	for method_name in ["get_changed_decisions", "get_past_decisions", "get_decision_history", "get_destiny_changes", "get_decisions"]:
		if _destiny_manager.has_method(method_name):
			var raw_records: Variant = _destiny_manager.call(method_name)
			return _normalize_decision_records(raw_records)
	for property_name in ["changed_decisions", "past_decisions", "decision_history", "destiny_changes", "decisions"]:
		var raw_value: Variant = _destiny_manager.get(property_name)
		if raw_value is Array:
			return _normalize_decision_records(raw_value)
	return []

func _normalize_decision_records(raw_records) -> Array[Dictionary]:
	var normalized: Array[Dictionary] = []
	if raw_records is Array:
		for item in raw_records:
			if item is Dictionary:
				var decision := item as Dictionary
				if _is_changed_decision(decision):
					normalized.append(decision)
	return normalized

func _is_changed_decision(decision: Dictionary) -> bool:
	if decision.is_empty():
		return false
	if decision.has("changed"):
		return bool(decision.get("changed", false))
	if decision.has("applied"):
		return bool(decision.get("applied", false))
	var old_value: Variant = _extract_decision_value(decision, ["old_value", "previous_value", "from_value", "before_value"])
	var new_value: Variant = _extract_decision_value(decision, ["new_value", "current_value", "to_value", "after_value"])
	return str(old_value) != str(new_value)

func _extract_decision_value(decision: Dictionary, keys: Array[String]) -> Variant:
	for key in keys:
		if decision.has(key):
			return decision.get(key)
	return null

func _is_ng_plus_three_unlocked() -> bool:
	if _destiny_manager == null:
		return false
	for method_name in ["is_ng_plus_three_unlocked", "is_ng_plus_3_unlocked", "is_destiny_unlocked"]:
		if _destiny_manager.has_method(method_name):
			return bool(_destiny_manager.call(method_name))
	for property_name in ["ng_plus_level", "current_ng_plus", "new_game_plus_level", "ng_plus_tier"]:
		var level_value: Variant = _destiny_manager.get(property_name)
		if typeof(level_value) == TYPE_INT:
			return int(level_value) >= 3
		if typeof(level_value) == TYPE_STRING and not String(level_value).strip_edges().is_empty():
			return int(String(level_value)) >= 3
	return false

func _format_value(value) -> String:
	if value == null:
		return "(none)"
	if value is String:
		var text := (value as String).strip_edges()
		return text if not text.is_empty() else "(empty)"
	if value is bool:
		return "true" if value else "false"
	if value is Array:
		var parts: Array[String] = []
		for item in value:
			parts.append(_format_value(item))
		return "[%s]" % ", ".join(parts)
	if value is Dictionary:
		return JSON.stringify(value)
	return str(value)

func _make_status_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _clear_children(container: Node) -> void:
	if container == null:
		return
	for child in container.get_children():
		if child == _empty_state_label:
			continue
		child.queue_free()
