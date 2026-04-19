class_name ScenarioSpawnEditor
extends Control

signal spawns_saved(ally_spawns: Array, enemy_spawns: Array, blocked_cells: Array)
signal edit_cancelled()

const KIND_ALLY := "ally"
const KIND_ENEMY := "enemy"
const KIND_BLOCKED := "blocked"

var _ally_spawns: Array[Vector2i] = []
var _enemy_spawns: Array[Vector2i] = []
var _blocked_cells: Array[Vector2i] = []
var _map_width: int = 0
var _map_height: int = 0
var _pending_kind: String = KIND_ALLY

var _panel: PanelContainer
var _map_info_label: Label
var _ally_items: VBoxContainer
var _enemy_items: VBoxContainer
var _blocked_items: VBoxContainer
var _save_button: Button
var _cancel_button: Button
var _position_dialog: ConfirmationDialog
var _dialog_title_label: Label
var _x_spin: SpinBox
var _y_spin: SpinBox

func _ready() -> void:
	_ensure_ui()
	visible = false
	_rebuild_lists()

func open(ally_spawns: Array[Vector2i], enemy_spawns: Array[Vector2i], blocked_cells: Array[Vector2i], map_width: int, map_height: int) -> void:
	_ally_spawns = _copy_positions(ally_spawns)
	_enemy_spawns = _copy_positions(enemy_spawns)
	_blocked_cells = _copy_positions(blocked_cells)
	_map_width = map_width
	_map_height = map_height
	_ensure_ui()
	_map_info_label.text = "%d x %d" % [_map_width, _map_height]
	_configure_spin_ranges()
	_rebuild_lists()
	visible = true

func get_ally_spawns() -> Array[Vector2i]:
	return _copy_positions(_ally_spawns)

func get_enemy_spawns() -> Array[Vector2i]:
	return _copy_positions(_enemy_spawns)

func get_blocked_cells() -> Array[Vector2i]:
	return _copy_positions(_blocked_cells)

func _try_add_entry(kind: String, position: Vector2i) -> bool:
	if not _is_in_bounds(position):
		return false
	var target := _get_array_for_kind(kind)
	if target == null:
		return false
	target.append(position)
	_rebuild_lists()
	return true

func _ensure_ui() -> void:
	if _panel != null:
		return

	name = "ScenarioSpawnEditor"
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
	stack.add_theme_constant_override("separation", 10)
	content.add_child(stack)

	var header_row := HBoxContainer.new()
	header_row.name = "HeaderRow"
	stack.add_child(header_row)

	var header := Label.new()
	header.name = "HeaderLabel"
	header.text = "Edit Spawns"
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(header)

	_map_info_label = Label.new()
	_map_info_label.name = "MapInfoLabel"
	header_row.add_child(_map_info_label)

	stack.add_child(_build_section("Ally Spawns", "AllySpawnList", "AllySpawnItems", "+ Add Ally Spawn", KIND_ALLY))
	stack.add_child(_build_section("Enemy Spawns", "EnemySpawnList", "EnemySpawnItems", "+ Add Enemy Spawn", KIND_ENEMY))
	stack.add_child(_build_section("Blocked Cells", "BlockedList", "BlockedItems", "+ Add Blocked Cell", KIND_BLOCKED))

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

	_position_dialog = ConfirmationDialog.new()
	_position_dialog.name = "PositionDialog"
	_position_dialog.title = "Add Position"
	_position_dialog.confirmed.connect(_on_position_confirmed)
	add_child(_position_dialog)

	var dialog_stack := VBoxContainer.new()
	dialog_stack.name = "DialogStack"
	dialog_stack.add_theme_constant_override("separation", 6)
	_position_dialog.add_child(dialog_stack)

	_dialog_title_label = Label.new()
	_dialog_title_label.name = "DialogTitleLabel"
	dialog_stack.add_child(_dialog_title_label)

	_x_spin = SpinBox.new()
	_x_spin.name = "XSpin"
	_x_spin.step = 1
	dialog_stack.add_child(_x_spin)

	_y_spin = SpinBox.new()
	_y_spin.name = "YSpin"
	_y_spin.step = 1
	dialog_stack.add_child(_y_spin)

	_configure_spin_ranges()

func _build_section(title: String, scroll_name: String, items_name: String, button_text: String, kind: String) -> VBoxContainer:
	var section := VBoxContainer.new()
	section.name = "%sSection" % items_name
	section.add_theme_constant_override("separation", 6)

	var label := Label.new()
	label.name = "%sLabel" % items_name
	label.text = title
	section.add_child(label)

	var scroll := ScrollContainer.new()
	scroll.name = scroll_name
	scroll.custom_minimum_size = Vector2(0.0, 120.0)
	section.add_child(scroll)

	var items := VBoxContainer.new()
	items.name = items_name
	items.add_theme_constant_override("separation", 6)
	scroll.add_child(items)
	match kind:
		KIND_ALLY:
			_ally_items = items
		KIND_ENEMY:
			_enemy_items = items
		KIND_BLOCKED:
			_blocked_items = items

	var button := Button.new()
	button.name = "%sButton" % items_name.replace("Items", "Add")
	button.text = button_text
	button.pressed.connect(func() -> void:
		_open_position_dialog(kind)
	)
	section.add_child(button)

	return section

func _rebuild_lists() -> void:
	_rebuild_list(_ally_items, _ally_spawns, KIND_ALLY)
	_rebuild_list(_enemy_items, _enemy_spawns, KIND_ENEMY)
	_rebuild_list(_blocked_items, _blocked_cells, KIND_BLOCKED)

func _rebuild_list(container: VBoxContainer, values: Array[Vector2i], kind: String) -> void:
	if container == null:
		return
	_clear_children(container)
	if values.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No positions added."
		container.add_child(empty_label)
		return
	for index in range(values.size()):
		container.add_child(_build_position_row(kind, values[index], index))

func _build_position_row(kind: String, value: Vector2i, index: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "%sRow%d" % [kind.capitalize(), index]
	row.add_theme_constant_override("separation", 6)

	var label := Label.new()
	label.name = "ValueLabel"
	label.text = "Vector2i(%d, %d)" % [value.x, value.y]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	var delete_button := Button.new()
	delete_button.name = "DeleteButton"
	delete_button.text = "X"
	delete_button.pressed.connect(func() -> void:
		_remove_entry(kind, index)
	)
	row.add_child(delete_button)

	return row

func _remove_entry(kind: String, index: int) -> void:
	var target := _get_array_for_kind(kind)
	if target == null or index < 0 or index >= target.size():
		return
	target.remove_at(index)
	_rebuild_lists()

func _open_position_dialog(kind: String) -> void:
	_pending_kind = kind
	_configure_spin_ranges()
	_dialog_title_label.text = "Enter coordinates for %s" % kind.replace("_", " ")
	_position_dialog.popup_centered(Vector2i(280, 140))

func _configure_spin_ranges() -> void:
	if _x_spin == null or _y_spin == null:
		return
	_x_spin.min_value = 0
	_y_spin.min_value = 0
	_x_spin.max_value = maxi(0, _map_width - 1)
	_y_spin.max_value = maxi(0, _map_height - 1)
	_x_spin.value = _x_spin.min_value
	_y_spin.value = _y_spin.min_value

func _on_position_confirmed() -> void:
	_try_add_entry(_pending_kind, Vector2i(int(_x_spin.value), int(_y_spin.value)))

func _on_save_pressed() -> void:
	if _has_duplicates():
		push_warning("[ScenarioSpawnEditor] Duplicate spawn or blocked positions detected.")
		return
	spawns_saved.emit(get_ally_spawns(), get_enemy_spawns(), get_blocked_cells())

func _on_cancel_pressed() -> void:
	visible = false
	edit_cancelled.emit()

func _is_in_bounds(position: Vector2i) -> bool:
	return position.x >= 0 and position.y >= 0 and position.x < _map_width and position.y < _map_height

func _has_duplicates() -> bool:
	var seen: Dictionary = {}
	for group in [_ally_spawns, _enemy_spawns, _blocked_cells]:
		for value in group:
			if seen.has(value):
				return true
			seen[value] = true
	return false

func _get_array_for_kind(kind: String) -> Array[Vector2i]:
	match kind:
		KIND_ALLY:
			return _ally_spawns
		KIND_ENEMY:
			return _enemy_spawns
		KIND_BLOCKED:
			return _blocked_cells
	return []

func _copy_positions(values: Array) -> Array[Vector2i]:
	var copy: Array[Vector2i] = []
	for value in values:
		copy.append(value)
	return copy

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
