class_name ScenarioEditor
extends Control

signal scenario_saved(ScenarioData)
signal scenario_loaded(ScenarioData)
signal edit_cancelled()
signal start_test_battle(ScenarioData)

const ScenarioData = preload("res://scripts/data/scenario.gd")
const ScenarioStagePickerRef = preload("res://scripts/editor/scenario_stage_picker.gd")
const ScenarioDialogueEditorRef = preload("res://scripts/editor/scenario_dialogue_editor.gd")
const ScenarioSpawnEditorRef = preload("res://scripts/editor/scenario_spawn_editor.gd")

@export var current_scenario: ScenarioData

var _current_stage_index: int = 0
var _is_dirty: bool = false
var _edit_mode: String = "overview"  # overview | stage | dialogue | spawn

@onready var panel: PanelContainer = get_node_or_null("Panel")
@onready var title_edit: LineEdit = get_node_or_null("Panel/Margin/Content/Form/TitleSection/TitleEdit")
@onready var desc_edit: TextEdit = get_node_or_null("Panel/Margin/Content/Form/DescSection/DescEdit")
@onready var author_edit: LineEdit = get_node_or_null("Panel/Margin/Content/Form/AuthorSection/AuthorEdit")
@onready var difficulty_slider: HSlider = get_node_or_null("Panel/Margin/Content/Form/DifficultySection/DifficultySlider")
@onready var difficulty_label: Label = get_node_or_null("Panel/Margin/Content/Form/DifficultySection/DifficultyLabel")
@onready var tags_edit: LineEdit = get_node_or_null("Panel/Margin/Content/Form/TagsSection/TagsEdit")
@onready var stage_list: ItemList = get_node_or_null("Panel/Margin/Content/StageSection/StageList")
@onready var stage_detail_container: Control = get_node_or_null("Panel/Margin/Content/StageDetail")
@onready var briefing_edit: TextEdit = get_node_or_null("Panel/Margin/Content/StageDetail/BriefingSection/BriefingEdit")
@onready var turn_limit_spin: SpinBox = get_node_or_null("Panel/Margin/Content/StageDetail/TurnLimitSection/TurnLimitSpin")
@onready var map_size_spin: SpinBox = get_node_or_null("Panel/Margin/Content/StageDetail/MapSizeSection/MapSizeSpin")
@onready var dialogue_list: ItemList = get_node_or_null("Panel/Margin/Content/DialogueSection/DialogueList")
@onready var dialogue_edit: TextEdit = get_node_or_null("Panel/Margin/Content/DialogueSection/DialogueEdit")
@onready var save_button: Button = get_node_or_null("Panel/Margin/Content/ButtonRow/SaveButton")
@onready var test_button: Button = get_node_or_null("Panel/Margin/Content/ButtonRow/TestButton")
@onready var close_button: Button = get_node_or_null("Panel/Margin/Content/ButtonRow/CloseButton")
@onready var add_stage_button: Button = get_node_or_null("Panel/Margin/Content/StageSection/AddStageButton")
@onready var remove_stage_button: Button = get_node_or_null("Panel/Margin/Content/StageSection/RemoveStageButton")
@onready var stage_picker: Control = get_node_or_null("ScenarioStagePicker")
@onready var dialogue_editor: Control = get_node_or_null("ScenarioDialogueEditor")
@onready var spawn_editor: Control = get_node_or_null("ScenarioSpawnEditor")

var _pick_stage_button: Button
var _edit_dialogue_button: Button
var _edit_spawns_button: Button

func _ready() -> void:
	visible = false
	if difficulty_slider != null:
		difficulty_slider.min_value = 1
		difficulty_slider.max_value = 5
		difficulty_slider.step = 1
		difficulty_slider.value_changed.connect(_on_difficulty_changed)
	if save_button != null:
		save_button.pressed.connect(_on_save_pressed)
	if test_button != null:
		test_button.pressed.connect(_on_test_pressed)
	if close_button != null:
		close_button.pressed.connect(_on_close_pressed)
	if add_stage_button != null:
		add_stage_button.pressed.connect(_on_add_stage_pressed)
	if remove_stage_button != null:
		remove_stage_button.pressed.connect(_on_remove_stage_pressed)
	if stage_list != null:
		stage_list.item_selected.connect(_on_stage_selected)
	if title_edit != null:
		title_edit.text_submitted.connect(_on_title_changed)
	if desc_edit != null:
		desc_edit.text_changed.connect(_on_desc_changed)
	if author_edit != null:
		author_edit.text_changed.connect(_on_author_changed)
	if tags_edit != null:
		tags_edit.text_submitted.connect(_on_tags_changed)
	if briefing_edit != null:
		briefing_edit.text_changed.connect(_on_briefing_changed)
	if turn_limit_spin != null:
		turn_limit_spin.value_changed.connect(_on_turn_limit_changed)
	if map_size_spin != null:
		map_size_spin.value_changed.connect(_on_map_size_changed)
	_ensure_auxiliary_editors()
	_ensure_editor_buttons()
	_refresh_editor_buttons()

func open_editor(scenario: ScenarioData = null) -> void:
	if scenario == null:
		current_scenario = ScenarioData.new()
		current_scenario.scenario_id = &"custom_%03d" % Time.get_unix_time_from_system()
		current_scenario.scenario_title = "New Scenario"
		current_scenario.author_name = "Anonymous"
	else:
		current_scenario = scenario
	_is_dirty = false
	_populate_form()
	_refresh_editor_buttons()
	visible = true

func _populate_form() -> void:
	if current_scenario == null:
		return
	if title_edit != null:
		title_edit.text = current_scenario.scenario_title
	if desc_edit != null:
		desc_edit.text = current_scenario.scenario_description
	if author_edit != null:
		author_edit.text = current_scenario.author_name
	if difficulty_slider != null:
		difficulty_slider.value = current_scenario.difficulty_rating
	if difficulty_label != null:
		difficulty_label.text = str(current_scenario.difficulty_rating)
	if tags_edit != null:
		tags_edit.text = ",".join(Array(current_scenario.tags))
	_refresh_stage_list()
	_refresh_dialogue_list()
	_refresh_editor_buttons()

func _refresh_stage_list() -> void:
	if current_scenario == null:
		return
	if stage_list != null:
		stage_list.clear()
		for i in range(current_scenario.stages.size()):
			var stage: ScenarioData.ScenarioStage = current_scenario.stages[i]
			stage_list.add_item(stage.get_display_title())
		if _current_stage_index >= 0 and _current_stage_index < current_scenario.stages.size():
			stage_list.select(_current_stage_index)
	_update_stage_detail()
	_refresh_stage_picker_state()
	_refresh_editor_buttons()

func _refresh_dialogue_list() -> void:
	if current_scenario == null:
		return
	if dialogue_list != null:
		dialogue_list.clear()
	var stage_id: StringName = ""
	if _current_stage_index < current_scenario.stages.size():
		stage_id = current_scenario.stages[_current_stage_index].stage_id
	if current_scenario.dialogue_catalog.has(stage_id):
		var dialogues: Dictionary = current_scenario.dialogue_catalog[stage_id]
		for key in dialogues.keys():
			dialogue_list.add_item(String(key))
	_refresh_dialogue_editor_state()
	_refresh_editor_buttons()

func _update_stage_detail() -> void:
	if current_scenario == null or _current_stage_index >= current_scenario.stages.size():
		if stage_detail_container != null:
			stage_detail_container.visible = false
		return
	if stage_detail_container == null:
		return
	stage_detail_container.visible = true
	var stage: ScenarioData.ScenarioStage = current_scenario.stages[_current_stage_index]
	if briefing_edit != null:
		briefing_edit.text = stage.briefing_text
	if turn_limit_spin != null:
		turn_limit_spin.value = stage.turn_limit
	if map_size_spin != null:
		map_size_spin.value = stage.map_width
	_refresh_spawn_editor_state()
	_refresh_editor_buttons()

func _mark_dirty() -> void:
	_is_dirty = true

func _on_difficulty_changed(value: float) -> void:
	if current_scenario == null:
		return
	current_scenario.difficulty_rating = int(value)
	difficulty_label.text = str(int(value))
	_mark_dirty()

func _on_title_changed(value: String) -> void:
	if current_scenario == null:
		return
	current_scenario.scenario_title = value
	_mark_dirty()

func _on_desc_changed() -> void:
	if current_scenario == null:
		return
	current_scenario.scenario_description = desc_edit.text
	_mark_dirty()

func _on_author_changed(value: String) -> void:
	if current_scenario == null:
		return
	current_scenario.author_name = value
	_mark_dirty()

func _on_tags_changed(value: String) -> void:
	if current_scenario == null:
		return
	current_scenario.tags = PackedStringArray(value.split(",", false))
	_mark_dirty()

func _on_add_stage_pressed() -> void:
	if current_scenario == null:
		return
	_current_stage_index = _append_new_stage()
	_refresh_stage_list()
	_mark_dirty()

func _on_remove_stage_pressed() -> void:
	if current_scenario == null or _current_stage_index >= current_scenario.stages.size():
		return
	current_scenario.stages.remove_at(_current_stage_index)
	_current_stage_index = mini(_current_stage_index, maxi(0, current_scenario.stages.size() - 1))
	_refresh_stage_list()
	_mark_dirty()

func _on_stage_selected(index: int) -> void:
	_current_stage_index = index
	_update_stage_detail()
	_refresh_dialogue_list()
	_refresh_editor_buttons()

func _on_briefing_changed() -> void:
	if current_scenario == null or _current_stage_index >= current_scenario.stages.size():
		return
	current_scenario.stages[_current_stage_index].briefing_text = briefing_edit.text
	_mark_dirty()

func _on_turn_limit_changed(value: float) -> void:
	if current_scenario == null or _current_stage_index >= current_scenario.stages.size():
		return
	current_scenario.stages[_current_stage_index].turn_limit = int(value)
	_mark_dirty()

func _on_map_size_changed(value: float) -> void:
	if current_scenario == null or _current_stage_index >= current_scenario.stages.size():
		return
	var size: int = int(value)
	current_scenario.stages[_current_stage_index].map_width = size
	current_scenario.stages[_current_stage_index].map_height = size
	_mark_dirty()

func _on_save_pressed() -> void:
	if current_scenario == null:
		return
	_save_to_file()
	scenario_saved.emit(current_scenario)
	_is_dirty = false

func _on_test_pressed() -> void:
	if current_scenario == null or current_scenario.stages.is_empty():
		return
	start_test_battle.emit(current_scenario)

func _on_close_pressed() -> void:
	if _is_dirty:
		# TODO: confirm discard dialog
		pass
	edit_cancelled.emit()
	visible = false
	if stage_picker != null:
		stage_picker.visible = false
	if dialogue_editor != null:
		dialogue_editor.visible = false
	if spawn_editor != null:
		spawn_editor.visible = false

func _save_to_file() -> void:
	if current_scenario == null:
		return
	var scenario_dir := DirAccess.open("user://scenarios/")
	if scenario_dir == null:
		DirAccess.make_dir_recursive_absolute("user://scenarios")
	var file_path := "user://scenarios/%s.tres" % current_scenario.scenario_id
	var result := ResourceSaver.save(current_scenario, file_path)
	if result == OK:
		print("[ScenarioEditor] Saved to ", file_path)
	else:
		push_error("[ScenarioEditor] Failed to save: ", result)

static func load_from_file(scenario_id: StringName) -> ScenarioData:
	var file_path := "user://scenarios/%s.tres" % scenario_id
	if ResourceLoader.exists(file_path):
		var loaded: ScenarioData = ResourceLoader.load(file_path, "", ResourceLoader.CACHE_MODE_IGNORE)
		return loaded
	return null

func _append_new_stage() -> int:
	if current_scenario == null:
		return -1
	var new_stage := ScenarioData.ScenarioStage.new()
	var stage_number := current_scenario.stages.size() + 1
	new_stage.stage_id = StringName("stage_%03d" % stage_number)
	new_stage.stage_title = "Stage %d" % stage_number
	current_scenario.stages.append(new_stage)
	return current_scenario.stages.size() - 1

func _get_current_stage() -> ScenarioData.ScenarioStage:
	if current_scenario == null:
		return null
	if _current_stage_index < 0 or _current_stage_index >= current_scenario.stages.size():
		return null
	return current_scenario.stages[_current_stage_index]

func _ensure_auxiliary_editors() -> void:
	if stage_picker == null:
		stage_picker = ScenarioStagePickerRef.new()
		stage_picker.visible = false
		add_child(stage_picker)
		stage_picker.stage_selected.connect(_on_stage_picker_selected)
		stage_picker.stage_added.connect(_on_stage_picker_added)
		stage_picker.cancelled.connect(_on_auxiliary_editor_cancelled)
	if dialogue_editor == null:
		dialogue_editor = ScenarioDialogueEditorRef.new()
		dialogue_editor.visible = false
		add_child(dialogue_editor)
		dialogue_editor.dialogue_saved.connect(_on_dialogue_saved)
		dialogue_editor.edit_cancelled.connect(_on_auxiliary_editor_cancelled)
	if spawn_editor == null:
		spawn_editor = ScenarioSpawnEditorRef.new()
		spawn_editor.visible = false
		add_child(spawn_editor)
		spawn_editor.spawns_saved.connect(_on_spawns_saved)
		spawn_editor.edit_cancelled.connect(_on_auxiliary_editor_cancelled)

func _ensure_editor_buttons() -> void:
	if stage_list != null and _pick_stage_button == null:
		_pick_stage_button = Button.new()
		_pick_stage_button.name = "PickStageButton"
		_pick_stage_button.text = "Pick Stage"
		_pick_stage_button.pressed.connect(_on_pick_stage_pressed)
		stage_list.get_parent().add_child(_pick_stage_button)
	if dialogue_list != null and _edit_dialogue_button == null:
		_edit_dialogue_button = Button.new()
		_edit_dialogue_button.name = "EditDialogueButton"
		_edit_dialogue_button.text = "Edit Dialogue"
		_edit_dialogue_button.pressed.connect(_on_edit_dialogue_pressed)
		dialogue_list.get_parent().add_child(_edit_dialogue_button)
	if stage_detail_container != null and _edit_spawns_button == null:
		_edit_spawns_button = Button.new()
		_edit_spawns_button.name = "EditSpawnsButton"
		_edit_spawns_button.text = "Edit Spawns"
		_edit_spawns_button.pressed.connect(_on_edit_spawns_pressed)
		stage_detail_container.add_child(_edit_spawns_button)

func _refresh_editor_buttons() -> void:
	var has_stage := _get_current_stage() != null
	if _pick_stage_button != null:
		_pick_stage_button.disabled = current_scenario == null
	if _edit_dialogue_button != null:
		_edit_dialogue_button.disabled = not has_stage
	if _edit_spawns_button != null:
		_edit_spawns_button.disabled = not has_stage

func _refresh_stage_picker_state() -> void:
	if stage_picker == null or current_scenario == null or not stage_picker.visible:
		return
	stage_picker.open(current_scenario.stages, _current_stage_index)

func _refresh_dialogue_editor_state() -> void:
	var stage := _get_current_stage()
	if dialogue_editor == null or stage == null or not dialogue_editor.visible:
		return
	dialogue_editor.open(stage.stage_id, current_scenario.dialogue_catalog.get(stage.stage_id, {}))

func _refresh_spawn_editor_state() -> void:
	var stage := _get_current_stage()
	if spawn_editor == null or stage == null or not spawn_editor.visible:
		return
	spawn_editor.open(stage.ally_spawns, stage.enemy_spawns, stage.blocked_cells, stage.map_width, stage.map_height)

func _on_pick_stage_pressed() -> void:
	if current_scenario == null or current_scenario.stages.is_empty():
		return
	_ensure_auxiliary_editors()
	stage_picker.open(current_scenario.stages, _current_stage_index)

func _on_edit_dialogue_pressed() -> void:
	var stage := _get_current_stage()
	if stage == null:
		return
	_ensure_auxiliary_editors()
	dialogue_editor.open(stage.stage_id, current_scenario.dialogue_catalog.get(stage.stage_id, {}))

func _on_edit_spawns_pressed() -> void:
	var stage := _get_current_stage()
	if stage == null:
		return
	_ensure_auxiliary_editors()
	spawn_editor.open(stage.ally_spawns, stage.enemy_spawns, stage.blocked_cells, stage.map_width, stage.map_height)

func _on_stage_picker_selected(index: int) -> void:
	_current_stage_index = index
	if stage_picker != null:
		stage_picker.visible = false
	_refresh_stage_list()
	_refresh_dialogue_list()

func _on_stage_picker_added(_stage_index: int) -> void:
	if current_scenario == null:
		return
	_current_stage_index = _append_new_stage()
	if stage_picker != null:
		stage_picker.open(current_scenario.stages, _current_stage_index)
	_refresh_stage_list()
	_refresh_dialogue_list()
	_mark_dirty()

func _on_dialogue_saved(dialogue_catalog: Dictionary) -> void:
	var stage := _get_current_stage()
	if stage == null:
		return
	current_scenario.dialogue_catalog[stage.stage_id] = dialogue_catalog.duplicate(true)
	if dialogue_editor != null:
		dialogue_editor.visible = false
	_refresh_dialogue_list()
	_mark_dirty()

func _on_spawns_saved(ally_spawns: Array, enemy_spawns: Array, blocked_cells: Array) -> void:
	var stage := _get_current_stage()
	if stage == null:
		return
	stage.ally_spawns = _copy_positions(ally_spawns)
	stage.enemy_spawns = _copy_positions(enemy_spawns)
	stage.blocked_cells = _copy_positions(blocked_cells)
	if spawn_editor != null:
		spawn_editor.visible = false
	_mark_dirty()

func _on_auxiliary_editor_cancelled() -> void:
	if stage_picker != null:
		stage_picker.visible = false
	if dialogue_editor != null:
		dialogue_editor.visible = false
	if spawn_editor != null:
		spawn_editor.visible = false

func _copy_positions(values: Array) -> Array[Vector2i]:
	var copy: Array[Vector2i] = []
	for value in values:
		copy.append(value)
	return copy

static func list_user_scenarios() -> Array[ScenarioData]:
	var scenarios: Array[ScenarioData] = []
	var scenario_dir := DirAccess.open("user://scenarios/")
	if scenario_dir == null:
		return scenarios
	scenario_dir.list_dir_begin()
	var file_name := scenario_dir.get_next()
	while not file_name.is_empty():
		if file_name.ends_with(".tres"):
			var scenario_id: StringName = StringName(file_name.replace(".tres", ""))
			var loaded: ScenarioData = load_from_file(scenario_id)
			if loaded != null:
				scenarios.append(loaded)
		file_name = scenario_dir.get_next()
	scenario_dir.list_lib_entries_end()
	return scenarios
