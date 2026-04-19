extends SceneTree

# Scenario Creator Runner — Headless verification
# Verifies: ScenarioData resource, ScenarioEditor, ScenarioLoader, and Steam Workshop stub
# Run: godot --headless --path . --script scripts/dev/scenario_creator_runner.gd

const PASS := "✅ PASS"
const FAIL := "❌ FAIL"

const ScenarioDataRef = preload("res://scripts/data/scenario.gd")
const ScenarioEditorRef = preload("res://scripts/editor/scenario_editor.gd")
const ScenarioLoaderRef = preload("res://scripts/dev/scenario_loader.gd")
const STAGE_PICKER_PATH := "res://scripts/editor/scenario_stage_picker.gd"
const DIALOGUE_EDITOR_PATH := "res://scripts/editor/scenario_dialogue_editor.gd"
const SPAWN_EDITOR_PATH := "res://scripts/editor/scenario_spawn_editor.gd"

var tests_run: int = 0
var tests_passed: int = 0
var tests_failed: int = 0

func _initialize() -> void:
	print("\n=== Scenario Creator Runner ===\n")
	run_tests()
	print_results()
	quit(0 if tests_failed == 0 else 1)

func run_tests() -> void:
	test_scenario_data_resource()
	test_scenario_stage_resource()
	test_scenario_editor_exists()
	test_scenario_loader_exists()
	test_scenario_loader_list()
	test_scenario_loader_import_export()
	test_steam_workshop_stub()
	test_stage_picker_creation()
	test_stage_picker_signals()
	test_dialogue_editor_signals()
	test_spawn_editor_validation()

func verify(condition: bool, test_name: String, detail: String = "") -> void:
	tests_run += 1
	if condition:
		tests_passed += 1
		print("[%s] %s" % [PASS, test_name])
		if not detail.is_empty():
			print("       └─ %s" % detail)
	else:
		tests_failed += 1
		print("[%s] %s" % [FAIL, test_name])
		if not detail.is_empty():
			print("       └─ %s" % detail)

func test_scenario_data_resource() -> void:
	if ScenarioDataRef == null:
		tests_failed += 1
		print("[%s] ScenarioData class failed to load" % FAIL)
		return
	verify(true, "ScenarioData class loads")

	var scenario: ScenarioDataRef = ScenarioDataRef.new()
	verify(scenario != null, "ScenarioData instantiates")
	verify(scenario.scenario_id == &"custom_001", "Default scenario_id is set")
	verify(scenario.stages != null, "stages array initialized")
	verify(scenario.dialogue_catalog != null, "dialogue_catalog dict initialized")
	verify(scenario.tags is PackedStringArray, "tags is PackedStringArray")

	scenario.scenario_id = &"test_001"
	scenario.scenario_title = "Test Scenario"
	scenario.scenario_description = "A test scenario for verification"
	scenario.author_name = "Test Author"
	scenario.difficulty_rating = 3
	scenario.tags = PackedStringArray(["test", "verification"])

	verify(scenario.get_display_title() == "Test Scenario", "get_display_title() returns title")
	verify(scenario.get_stage_count() == 0, "get_stage_count() on empty scenario = 0")

	scenario.stages.clear()
	var stage_inst: ScenarioDataRef.ScenarioStage = ScenarioDataRef.ScenarioStage.new()
	stage_inst.stage_id = &"stage_001"
	stage_inst.stage_title = "Test Stage"
	stage_inst.map_width = 8
	stage_inst.map_height = 8
	stage_inst.turn_limit = 15
	stage_inst.briefing_text = "Test briefing text"
	scenario.stages.append(stage_inst)
	verify(scenario.get_stage_count() == 1, "get_stage_count() after adding stage = 1")
	verify(stage_inst.get_display_title() == "Test Stage", "ScenarioStage get_display_title()")

	stage_inst.blocked_cells.append(Vector2i(3, 3))
	verify(stage_inst.is_cell_blocked(Vector2i(3, 3)) == true, "is_cell_blocked() returns true for blocked cell")
	verify(stage_inst.is_cell_blocked(Vector2i(0, 0)) == false, "is_cell_blocked() returns false for open cell")

	scenario.dialogue_catalog[&"stage_001"] = {
		"briefing": "Custom briefing text",
		"victory": "Victory message"
	}
	var dialogue_text: String = scenario.get_dialogue(&"stage_001", "briefing")
	verify(dialogue_text == "Custom briefing text", "get_dialogue() retrieves dialogue")
	var missing_text: String = scenario.get_dialogue(&"nonexistent", "briefing")
	verify(missing_text == "", "get_dialogue() returns empty for missing stage/key")

	print("  └─ ScenarioData resource structure: OK")

func test_scenario_stage_resource() -> void:
	var stage: ScenarioDataRef.ScenarioStage = ScenarioDataRef.ScenarioStage.new()
	verify(stage != null, "ScenarioStage instantiates")
	verify(stage.stage_id == &"stage_001", "Default stage_id")
	verify(stage.map_width == 8, "Default map_width = 8")
	verify(stage.map_height == 8, "Default map_height = 8")
	verify(stage.turn_limit == 20, "Default turn_limit = 20")
	verify(stage.ally_units != null, "ally_units array initialized")
	verify(stage.enemy_units != null, "enemy_units array initialized")
	verify(stage.ally_spawns != null, "ally_spawns array initialized")
	verify(stage.enemy_spawns != null, "enemy_spawns array initialized")
	verify(stage.blocked_cells != null, "blocked_cells array initialized")
	print("  └─ ScenarioStage resource structure: OK")

func test_scenario_editor_exists() -> void:
	if ScenarioEditorRef == null:
		tests_failed += 1
		print("[%s] ScenarioEditor class failed to load" % FAIL)
		return
	verify(true, "ScenarioEditor class loads")

	var editor: ScenarioEditorRef = ScenarioEditorRef.new()
	verify(editor != null, "ScenarioEditor instantiates")
	verify(editor.current_scenario == null, "current_scenario starts as null")

	editor.open_editor()
	verify(editor.current_scenario != null, "current_scenario set after open_editor()")
	verify(editor.current_scenario.scenario_title == "New Scenario", "Default scenario title is 'New Scenario'")
	verify(editor.current_scenario.author_name == "Anonymous", "Default author is 'Anonymous'")

	var test_scenario: ScenarioDataRef = ScenarioDataRef.new()
	test_scenario.scenario_title = "Loaded Scenario"
	editor.open_editor(test_scenario)
	verify(editor.current_scenario.scenario_title == "Loaded Scenario", "open_editor(scenario) loads provided scenario")

	editor._mark_dirty()
	verify(editor._is_dirty == true, "_is_dirty flag set by _mark_dirty()")

	var initial_count: int = editor.current_scenario.stages.size()
	editor._on_add_stage_pressed()
	verify(editor.current_scenario.stages.size() == initial_count + 1, "add_stage increases stage count")

	var remove_idx: int = editor.current_scenario.stages.size() - 1
	editor._current_stage_index = remove_idx
	editor._on_remove_stage_pressed()
	verify(editor.current_scenario.stages.size() == initial_count, "remove_stage decreases stage count")

	print("  └─ ScenarioEditor basic logic: OK")
	editor.free()

func test_scenario_loader_exists() -> void:
	if ScenarioLoaderRef == null:
		tests_failed += 1
		print("[%s] ScenarioLoader class failed to load" % FAIL)
		return
	verify(true, "ScenarioLoader class loads")
	print("  └─ ScenarioLoader exists: OK")

func test_scenario_loader_list() -> void:
	var list: Array[Dictionary] = ScenarioLoaderRef.list_all_scenarios()
	verify(list is Array, "list_all_scenarios() returns Array")
	print("  └─ ScenarioLoader.list_all_scenarios() callable: OK")

func test_scenario_loader_import_export() -> void:
	var test_scenario: ScenarioDataRef = ScenarioDataRef.new()
	test_scenario.scenario_id = &"import_export_test"
	test_scenario.scenario_title = "Import/Export Test"
	test_scenario.scenario_description = "Testing JSON import/export roundtrip"
	test_scenario.author_name = "QA"
	test_scenario.difficulty_rating = 2
	test_scenario.tags = PackedStringArray(["qa", "test"])

	var stage_inst: ScenarioDataRef.ScenarioStage = ScenarioDataRef.ScenarioStage.new()
	stage_inst.stage_id = &"stage_test"
	stage_inst.stage_title = "Test Stage"
	stage_inst.map_width = 10
	stage_inst.map_height = 10
	stage_inst.turn_limit = 25
	stage_inst.briefing_text = "Test briefing"
	stage_inst.ally_spawns.append(Vector2i(1, 1))
	stage_inst.enemy_spawns.append(Vector2i(8, 8))
	stage_inst.blocked_cells.append(Vector2i(4, 4))
	test_scenario.stages.append(stage_inst)

	test_scenario.dialogue_catalog[&"stage_test"] = {
		"briefing": "JSON roundtrip test"
	}

	var temp_json: String = "user://test_scenario_export.json"
	var exported: bool = ScenarioLoaderRef.export_to_json(test_scenario, temp_json)
	verify(exported == true, "export_to_json() returns true")

	var imported: ScenarioDataRef = ScenarioLoaderRef.import_from_json(temp_json)
	verify(imported != null, "import_from_json() returns ScenarioData")
	verify(imported.scenario_id == &"import_export_test", "Roundtrip scenario_id preserved")
	verify(imported.scenario_title == "Import/Export Test", "Roundtrip title preserved")
	verify(imported.author_name == "QA", "Roundtrip author preserved")
	verify(imported.difficulty_rating == 2, "Roundtrip difficulty preserved")
	verify(imported.tags.size() == 2, "Roundtrip tags count preserved")
	verify(imported.stages.size() == 1, "Roundtrip stage count preserved")
	verify(imported.stages[0].map_width == 10, "Roundtrip map_width preserved")
	verify(imported.stages[0].turn_limit == 25, "Roundtrip turn_limit preserved")
	verify(imported.stages[0].ally_spawns[0] == Vector2i(1, 1), "Roundtrip ally_spawn preserved")
	verify(imported.stages[0].enemy_spawns[0] == Vector2i(8, 8), "Roundtrip enemy_spawn preserved")
	verify(imported.stages[0].blocked_cells[0] == Vector2i(4, 4), "Roundtrip blocked cell preserved")

	var dialogue_text: String = imported.get_dialogue(&"stage_test", "briefing")
	verify(dialogue_text == "JSON roundtrip test", "Roundtrip dialogue preserved")

	DirAccess.remove_absolute(temp_json)
	print("  └─ ScenarioLoader import/export roundtrip: OK")

func test_steam_workshop_stub() -> void:
	var stub_scenario: ScenarioDataRef = ScenarioDataRef.new()
	stub_scenario.scenario_id = &"workshop_stub_test"

	var publish_result: bool = ScenarioLoaderRef.publish_to_workshop(stub_scenario)
	verify(publish_result == false, "publish_to_workshop() stub returns false (not implemented)")

	var downloaded: ScenarioDataRef = ScenarioLoaderRef.download_from_workshop("workshop_123")
	verify(downloaded == null, "download_from_workshop() stub returns null")

	var workshop_list: Array[Dictionary] = ScenarioLoaderRef.list_workshop_scenarios()
	verify(workshop_list is Array, "list_workshop_scenarios() returns Array")
	verify(workshop_list.is_empty() == true, "list_workshop_senarios() stub returns empty list")
	print("  └─ Steam Workshop stub methods: OK")

func test_stage_picker_creation() -> void:
	var picker_script: Script = load(STAGE_PICKER_PATH)
	verify(picker_script != null, "ScenarioStagePicker script loads")
	if picker_script == null:
		return

	var picker = picker_script.new()
	root.add_child(picker)
	var stages: Array[ScenarioDataRef.ScenarioStage] = [
		_make_stage(&"stage_alpha", "Alpha Entry", 12),
		_make_stage(&"stage_beta", "Beta Clash", 18)
	]
	picker.open(stages, 1)

	var stage_items: VBoxContainer = picker.get_node_or_null("Panel/Margin/Content/VBox/StageList/StageItems")
	var add_button: Button = picker.get_node_or_null("Panel/Margin/Content/VBox/ButtonRow/AddButton")
	var cancel_button: Button = picker.get_node_or_null("Panel/Margin/Content/VBox/CancelButton")
	verify(stage_items != null, "ScenarioStagePicker builds stage list container")
	verify(stage_items.get_child_count() == 2, "ScenarioStagePicker creates one button per stage")
	verify(add_button != null and add_button.text == "+ Add Stage", "ScenarioStagePicker add button is present")
	verify(cancel_button != null and cancel_button.text == "Cancel", "ScenarioStagePicker cancel button is present")
	verify(picker.get_selected_index() == 1, "ScenarioStagePicker tracks selected index")
	if stage_items != null and stage_items.get_child_count() > 0:
		var first_button: Button = stage_items.get_child(0)
		verify(first_button.text.contains("Alpha Entry"), "ScenarioStagePicker button shows stage title")
		verify(first_button.text.contains("12"), "ScenarioStagePicker button shows turn limit preview")
	picker.queue_free()

func test_stage_picker_signals() -> void:
	var picker_script: Script = load(STAGE_PICKER_PATH)
	verify(picker_script != null, "ScenarioStagePicker script available for signal test")
	if picker_script == null:
		return

	var picker = picker_script.new()
	root.add_child(picker)
	var stages: Array[ScenarioDataRef.ScenarioStage] = [_make_stage(&"stage_signal", "Signal Stage", 9)]
	picker.open(stages, -1)
	var signal_state := {
		"selected_index": -1,
		"added_index": -1,
		"cancelled": false
	}
	picker.stage_selected.connect(func(index: int) -> void:
		signal_state["selected_index"] = index
	)
	picker.stage_added.connect(func(index: int) -> void:
		signal_state["added_index"] = index
	)
	picker.cancelled.connect(func() -> void:
		signal_state["cancelled"] = true
	)
	picker._on_stage_pressed(0)
	picker._on_add_pressed()
	picker._on_cancel_pressed()

	verify(signal_state["selected_index"] == 0, "ScenarioStagePicker emits stage_selected when a stage is chosen")
	verify(signal_state["added_index"] == 1, "ScenarioStagePicker emits stage_added with the new stage index")
	verify(signal_state["cancelled"] == true, "ScenarioStagePicker emits cancelled when cancel is pressed")
	picker.queue_free()

func test_dialogue_editor_signals() -> void:
	var dialogue_script: Script = load(DIALOGUE_EDITOR_PATH)
	verify(dialogue_script != null, "ScenarioDialogueEditor script loads")
	if dialogue_script == null:
		return

	var editor = dialogue_script.new()
	root.add_child(editor)
	editor.open(&"stage_dialogue", {"briefing": "Initial briefing copy for the stage."})
	var signal_state := {
		"saved_catalog": {},
		"cancelled": false
	}
	editor.dialogue_saved.connect(func(catalog: Dictionary) -> void:
		signal_state["saved_catalog"] = catalog.duplicate(true)
	)
	editor.edit_cancelled.connect(func() -> void:
		signal_state["cancelled"] = true
	)

	var stage_label: Label = editor.get_node_or_null("Panel/Margin/Content/VBox/HeaderRow/StageLabel")
	var entries: VBoxContainer = editor.get_node_or_null("Panel/Margin/Content/VBox/DialogueList/DialogueItems")
	verify(stage_label != null and stage_label.text.contains("stage_dialogue"), "ScenarioDialogueEditor shows the active stage id")
	verify(entries != null and entries.get_child_count() == 1, "ScenarioDialogueEditor creates an entry for each dialogue key")
	editor._set_entry_text("briefing", "Updated dialogue text that should be saved.")
	editor._on_save_pressed()
	editor._on_cancel_pressed()
	verify(signal_state["saved_catalog"].get("briefing", "") == "Updated dialogue text that should be saved.", "ScenarioDialogueEditor emits dialogue_saved with the edited catalog")
	verify(signal_state["cancelled"] == true, "ScenarioDialogueEditor emits edit_cancelled on cancel")
	editor.queue_free()

func test_spawn_editor_validation() -> void:
	var spawn_script: Script = load(SPAWN_EDITOR_PATH)
	verify(spawn_script != null, "ScenarioSpawnEditor script loads")
	if spawn_script == null:
		return

	var editor = spawn_script.new()
	root.add_child(editor)
	var empty_spawns: Array[Vector2i] = []
	editor.open(empty_spawns, empty_spawns, empty_spawns, 4, 4)
	verify(editor.get_ally_spawns().is_empty(), "ScenarioSpawnEditor starts with no ally spawns")
	verify(editor._try_add_entry("ally", Vector2i(5, 1)) == false, "ScenarioSpawnEditor rejects out-of-bounds spawns")
	verify(editor.get_ally_spawns().is_empty(), "Rejected out-of-bounds spawn is not stored")
	verify(editor._try_add_entry("ally", Vector2i(1, 1)) == true, "ScenarioSpawnEditor accepts in-bounds ally spawns")
	verify(editor._try_add_entry("enemy", Vector2i(2, 2)) == true, "ScenarioSpawnEditor accepts in-bounds enemy spawns")
	verify(editor._try_add_entry("blocked", Vector2i(3, 3)) == true, "ScenarioSpawnEditor accepts in-bounds blocked cells")
	var signal_state := {"saved_payload": {}}
	editor.spawns_saved.connect(func(ally_spawns: Array, enemy_spawns: Array, blocked_cells: Array) -> void:
		signal_state["saved_payload"] = {
			"ally": ally_spawns.duplicate(),
			"enemy": enemy_spawns.duplicate(),
			"blocked": blocked_cells.duplicate()
		}
	)
	editor._on_save_pressed()
	verify(signal_state["saved_payload"].get("ally", []).size() == 1, "ScenarioSpawnEditor emits saved ally spawns")
	verify(signal_state["saved_payload"].get("enemy", []).size() == 1, "ScenarioSpawnEditor emits saved enemy spawns")
	verify(signal_state["saved_payload"].get("blocked", []).size() == 1, "ScenarioSpawnEditor emits saved blocked cells")
	editor.queue_free()

func _make_stage(stage_id: StringName, title: String, turn_limit: int) -> ScenarioDataRef.ScenarioStage:
	var stage := ScenarioDataRef.ScenarioStage.new()
	stage.stage_id = stage_id
	stage.stage_title = title
	stage.turn_limit = turn_limit
	return stage

func print_results() -> void:
	print("\n=== Results ===")
	print("Tests run:    %d" % tests_run)
	print("Tests passed: %d" % tests_passed)
	print("Tests failed: %d" % tests_failed)
	if tests_failed == 0:
		print("\n✅ All Scenario Creator tests PASSED")
	else:
		print("\n❌ %d test(s) FAILED" % tests_failed)
