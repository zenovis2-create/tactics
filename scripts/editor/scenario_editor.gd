class_name ScenarioEditor
extends Control

signal scenario_saved(ScenarioData)
signal scenario_loaded(ScenarioData)
signal edit_cancelled()
signal start_test_battle(ScenarioData)

const ScenarioData = preload("res://scripts/data/scenario.gd")

@export var current_scenario: ScenarioData

var _current_stage_index: int = 0
var _is_dirty: bool = false
var _edit_mode: String = "overview"  # overview | stage | dialogue | spawn

@onready var panel: PanelContainer = $Panel
@onready var title_edit: LineEdit = $Panel/Margin/Content/Form/TitleSection/TitleEdit
@onready var desc_edit: TextEdit = $Panel/Margin/Content/Form/DescSection/DescEdit
@onready var author_edit: LineEdit = $Panel/Margin/Content/Form/AuthorSection/AuthorEdit
@onready var difficulty_slider: HSlider = $Panel/Margin/Content/Form/DifficultySection/DifficultySlider
@onready var difficulty_label: Label = $Panel/Margin/Content/Form/DifficultySection/DifficultyLabel
@onready var tags_edit: LineEdit = $Panel/Margin/Content/Form/TagsSection/TagsEdit
@onready var stage_list: ItemList = $Panel/Margin/Content/StageSection/StageList
@onready var stage_detail_container: Control = $Panel/Margin/Content/StageDetail
@onready var briefing_edit: TextEdit = $Panel/Margin/Content/StageDetail/BriefingSection/BriefingEdit
@onready var turn_limit_spin: SpinBox = $Panel/Margin/Content/StageDetail/TurnLimitSection/TurnLimitSpin
@onready var map_size_spin: SpinBox = $Panel/Margin/Content/StageDetail/MapSizeSection/MapSizeSpin
@onready var dialogue_list: ItemList = $Panel/Margin/Content/DialogueSection/DialogueList
@onready var dialogue_edit: TextEdit = $Panel/Margin/Content/DialogueSection/DialogueEdit
@onready var save_button: Button = $Panel/Margin/Content/ButtonRow/SaveButton
@onready var test_button: Button = $Panel/Margin/Content/ButtonRow/TestButton
@onready var close_button: Button = $Panel/Margin/Content/ButtonRow/CloseButton
@onready var add_stage_button: Button = $Panel/Margin/Content/StageSection/AddStageButton
@onready var remove_stage_button: Button = $Panel/Margin/Content/StageSection/RemoveStageButton

func _ready() -> void:
	visible = false
	difficulty_slider.min_value = 1
	difficulty_slider.max_value = 5
	difficulty_slider.step = 1
	difficulty_slider.value_changed.connect(_on_difficulty_changed)
	save_button.pressed.connect(_on_save_pressed)
	test_button.pressed.connect(_on_test_pressed)
	close_button.pressed.connect(_on_close_pressed)
	add_stage_button.pressed.connect(_on_add_stage_pressed)
	remove_stage_button.pressed.connect(_on_remove_stage_pressed)
	stage_list.item_selected.connect(_on_stage_selected)
	title_edit.text_submitted.connect(_on_title_changed)
	desc_edit.text_changed.connect(_on_desc_changed)
	author_edit.text_changed.connect(_on_author_changed)
	tags_edit.text_submitted.connect(_on_tags_changed)
	briefing_edit.text_changed.connect(_on_briefing_changed)
	turn_limit_spin.value_changed.connect(_on_turn_limit_changed)
	map_size_spin.value_changed.connect(_on_map_size_changed)

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

func _refresh_stage_list() -> void:
	if current_scenario == null:
		return
	if stage_list != null:
		stage_list.clear()
		for i in range(current_scenario.stages.size()):
			var stage: ScenarioData.ScenarioStage = current_scenario.stages[i]
			stage_list.add_item(stage.get_display_title())
		stage_list.select(_current_stage_index)
	_update_stage_detail()

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
	var new_stage := ScenarioData.ScenarioStage.new()
	new_stage.stage_id = &"stage_%03d" % current_scenario.stages.size()
	new_stage.stage_title = "Stage %d" % (current_scenario.stages.size() + 1)
	current_scenario.stages.append(new_stage)
	_current_stage_index = current_scenario.stages.size() - 1
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
