class_name ScenarioDialogueEditor
extends Control

signal dialogue_saved(dialogue_catalog: Dictionary)
signal edit_cancelled()

var _stage_id: StringName = StringName()
var _catalog: Dictionary = {}
var _expanded_key: String = ""

var _panel: PanelContainer
var _stage_label: Label
var _dialogue_items: VBoxContainer
var _add_key_button: Button
var _save_button: Button
var _cancel_button: Button
var _add_key_dialog: ConfirmationDialog
var _key_name_input: LineEdit

func _ready() -> void:
	_ensure_ui()
	visible = false
	_rebuild_dialogue_list()

func open(stage_id: StringName, catalog: Dictionary) -> void:
	_stage_id = stage_id
	_catalog = catalog.duplicate(true)
	_expanded_key = ""
	_ensure_ui()
	_stage_label.text = "Stage: %s" % String(stage_id)
	_rebuild_dialogue_list()
	visible = true

func get_catalog() -> Dictionary:
	return _catalog.duplicate(true)

func _set_entry_text(key: String, text: String) -> void:
	if not _catalog.has(key):
		return
	_catalog[key] = text
	_rebuild_dialogue_list()

func _ensure_ui() -> void:
	if _panel != null:
		return

	name = "ScenarioDialogueEditor"
	anchors_preset = PRESET_FULL_RECT
	mouse_filter = Control.MOUSE_FILTER_STOP

	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.anchors_preset = PRESET_FULL_RECT
	add_child(_panel)

	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	_panel.add_child(margin)

	var content := VBoxContainer.new()
	content.name = "Content"
	margin.add_child(content)

	var stack := VBoxContainer.new()
	stack.name = "VBox"
	stack.add_theme_constant_override("separation", 8)
	content.add_child(stack)

	var header_row := HBoxContainer.new()
	header_row.name = "HeaderRow"
	stack.add_child(header_row)

	var header := Label.new()
	header.name = "HeaderLabel"
	header.text = "Edit Dialogue"
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(header)

	_stage_label = Label.new()
	_stage_label.name = "StageLabel"
	header_row.add_child(_stage_label)

	var scroll := ScrollContainer.new()
	scroll.name = "DialogueList"
	scroll.custom_minimum_size = Vector2(0.0, 240.0)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(scroll)

	_dialogue_items = VBoxContainer.new()
	_dialogue_items.name = "DialogueItems"
	_dialogue_items.add_theme_constant_override("separation", 8)
	scroll.add_child(_dialogue_items)

	_add_key_button = Button.new()
	_add_key_button.name = "AddKeyButton"
	_add_key_button.text = "+ Add Dialogue Key"
	_add_key_button.pressed.connect(_on_add_key_pressed)
	stack.add_child(_add_key_button)

	var button_row := HBoxContainer.new()
	button_row.name = "ButtonRow"
	stack.add_child(button_row)

	_save_button = Button.new()
	_save_button.name = "SaveButton"
	_save_button.text = "Save"
	_save_button.pressed.connect(_on_save_pressed)
	button_row.add_child(_save_button)

	_cancel_button = Button.new()
	_cancel_button.name = "CancelButton"
	_cancel_button.text = "Cancel"
	_cancel_button.pressed.connect(_on_cancel_pressed)
	button_row.add_child(_cancel_button)

	_add_key_dialog = ConfirmationDialog.new()
	_add_key_dialog.name = "AddKeyDialog"
	_add_key_dialog.title = "Add Dialogue Key"
	_add_key_dialog.confirmed.connect(_on_add_key_confirmed)
	add_child(_add_key_dialog)

	var prompt_stack := VBoxContainer.new()
	prompt_stack.name = "PromptStack"
	prompt_stack.add_theme_constant_override("separation", 6)
	_add_key_dialog.add_child(prompt_stack)

	var prompt_label := Label.new()
	prompt_label.name = "PromptLabel"
	prompt_label.text = "Dialogue key name"
	prompt_stack.add_child(prompt_label)

	_key_name_input = LineEdit.new()
	_key_name_input.name = "KeyNameInput"
	_key_name_input.placeholder_text = "briefing"
	prompt_stack.add_child(_key_name_input)

func _rebuild_dialogue_list() -> void:
	if _dialogue_items == null:
		return
	_clear_children(_dialogue_items)

	var keys: Array[String] = []
	for key in _catalog.keys():
		keys.append(String(key))
	keys.sort()

	if keys.is_empty():
		var empty_label := Label.new()
		empty_label.name = "EmptyLabel"
		empty_label.text = "No dialogue keys for this stage yet."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_dialogue_items.add_child(empty_label)
		return

	for key in keys:
		_dialogue_items.add_child(_build_entry(key))

func _build_entry(key: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = "Entry_%s" % key

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 6)
	margin.add_child(stack)

	var button := Button.new()
	button.name = "KeyButton"
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text = "%s: %s" % [key, _summarize_text(String(_catalog.get(key, "")))]
	button.pressed.connect(func() -> void:
		_toggle_key(key)
	)
	stack.add_child(button)

	if _expanded_key == key:
		var editor := TextEdit.new()
		editor.name = "TextEdit"
		editor.custom_minimum_size = Vector2(0.0, 120.0)
		editor.text = String(_catalog.get(key, ""))
		editor.text_changed.connect(func() -> void:
			_catalog[key] = editor.text
		)
		stack.add_child(editor)

	return card

func _summarize_text(text: String) -> String:
	var stripped := text.strip_edges()
	if stripped.length() <= 50:
		return stripped
	return "%s..." % stripped.left(50)

func _toggle_key(key: String) -> void:
	_expanded_key = "" if _expanded_key == key else key
	_rebuild_dialogue_list()

func _on_add_key_pressed() -> void:
	if _add_key_dialog == null:
		return
	_key_name_input.text = ""
	_add_key_dialog.popup_centered(Vector2i(320, 120))

func _on_add_key_confirmed() -> void:
	var key := _key_name_input.text.strip_edges()
	if key.is_empty() or _catalog.has(key):
		return
	_catalog[key] = ""
	_expanded_key = key
	_rebuild_dialogue_list()

func _on_save_pressed() -> void:
	dialogue_saved.emit(get_catalog())

func _on_cancel_pressed() -> void:
	visible = false
	edit_cancelled.emit()

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
