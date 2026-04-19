class_name ScenarioStagePicker
extends Control

const ScenarioData = preload("res://scripts/data/scenario.gd")

signal stage_selected(stage_index: int)
signal stage_added(stage_index: int)
signal cancelled()

var _stages: Array[ScenarioData.ScenarioStage] = []
var _selected_index: int = -1

var _panel: PanelContainer
var _stage_items: VBoxContainer
var _add_button: Button
var _cancel_button: Button

func _ready() -> void:
	_ensure_ui()
	visible = false
	_rebuild_stage_list()

func open(stages: Array[ScenarioData.ScenarioStage], current_index: int = -1) -> void:
	_stages = stages.duplicate()
	_selected_index = current_index if current_index >= 0 and current_index < _stages.size() else -1
	_ensure_ui()
	_rebuild_stage_list()
	visible = true

func get_selected_index() -> int:
	return _selected_index

func _ensure_ui() -> void:
	if _panel != null:
		return

	name = "ScenarioStagePicker"
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

	var header := Label.new()
	header.name = "Header"
	header.text = "Select Stage"
	stack.add_child(header)

	var scroll := ScrollContainer.new()
	scroll.name = "StageList"
	scroll.custom_minimum_size = Vector2(0.0, 220.0)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(scroll)

	_stage_items = VBoxContainer.new()
	_stage_items.name = "StageItems"
	_stage_items.add_theme_constant_override("separation", 6)
	scroll.add_child(_stage_items)

	var button_row := HBoxContainer.new()
	button_row.name = "ButtonRow"
	stack.add_child(button_row)

	_add_button = Button.new()
	_add_button.name = "AddButton"
	_add_button.text = "+ Add Stage"
	_add_button.pressed.connect(_on_add_pressed)
	button_row.add_child(_add_button)

	_cancel_button = Button.new()
	_cancel_button.name = "CancelButton"
	_cancel_button.text = "Cancel"
	_cancel_button.pressed.connect(_on_cancel_pressed)
	stack.add_child(_cancel_button)

func _rebuild_stage_list() -> void:
	if _stage_items == null:
		return
	_clear_children(_stage_items)
	for index in range(_stages.size()):
		var stage: ScenarioData.ScenarioStage = _stages[index]
		var button := Button.new()
		button.name = "StageButton%d" % index
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.text = _build_stage_preview(index, stage)
		button.disabled = index == _selected_index
		button.pressed.connect(func() -> void:
			_on_stage_pressed(index)
		)
		_stage_items.add_child(button)

	if _stages.is_empty():
		var empty_label := Label.new()
		empty_label.name = "EmptyLabel"
		empty_label.text = "No stages yet. Add one to begin editing."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_stage_items.add_child(empty_label)

func _build_stage_preview(index: int, stage: ScenarioData.ScenarioStage) -> String:
	return "%d. %s — Turn Limit %d" % [
		index + 1,
		stage.get_display_title(),
		stage.turn_limit
	]

func _on_stage_pressed(index: int) -> void:
	_selected_index = index
	_rebuild_stage_list()
	stage_selected.emit(index)

func _on_add_pressed() -> void:
	var new_stage := ScenarioData.ScenarioStage.new()
	var new_index := _stages.size()
	new_stage.stage_id = StringName("stage_%03d" % (new_index + 1))
	new_stage.stage_title = "Stage %d" % (new_index + 1)
	_stages.append(new_stage)
	_selected_index = new_index
	_rebuild_stage_list()
	stage_added.emit(new_index)

func _on_cancel_pressed() -> void:
	visible = false
	cancelled.emit()

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
