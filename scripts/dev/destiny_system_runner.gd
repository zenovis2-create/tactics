extends SceneTree

# Destiny System Runner — Headless verification
# Verifies: DestinyManager, DestinyUI, EncyclopediaPanel destiny tab contract
# Run: godot --headless --path . --script scripts/dev/destiny_system_runner.gd

const PASS := "✅ PASS"
const FAIL := "❌ FAIL"

const DestinyManagerRef = preload("res://scripts/battle/destiny_manager.gd")
const DestinyUIRef = preload("res://scripts/ui/destiny_ui.gd")
const ProgressionDataRef = preload("res://scripts/data/progression_data.gd")

var tests_run: int = 0
var tests_passed: int = 0
var tests_failed: int = 0


class DestinyManagerStub:
	extends Node

	signal decisions_changed

	var decisions: Array = []
	var unlocked: bool = false

	func get_past_decisions() -> Array:
		return decisions.duplicate(true)

	func is_destiny_unlocked() -> bool:
		return unlocked


func _initialize() -> void:
	print("\n=== Destiny System Runner ===\n")
	call_deferred("_run")


func _run() -> void:
	await test_destiny_manager()
	await test_destiny_ui()
	test_encyclopedia_extension()
	print_results()
	quit(0 if tests_failed == 0 else 1)


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


func test_destiny_manager() -> void:
	if DestinyManagerRef == null:
		tests_failed += 1
		print("[%s] DestinyManager class failed to load" % FAIL)
		return
	verify(true, "DestinyManager class loads")

	var manager: DestinyManagerRef = DestinyManagerRef.new()
	root.add_child(manager)
	await process_frame

	verify(manager.is_destiny_unlocked() == false, "is_destiny_unlocked() is false without progression", "No SaveService/ProgressionService loaded")

	var save_service: Node = _find_node_with_methods(root, ["load_progression", "save_progression"])
	verify(save_service != null, "SaveService autoload exists for NG+3 gate test")
	var progression := ProgressionDataRef.new()
	progression.ng_plus_purchases = ["ng_plus_1", "ng_plus_2", "ng_plus_3"]
	var previous_progression: Variant = null
	if save_service != null:
		previous_progression = save_service.call("load_progression", 0)
		save_service.call("save_progression", progression, 0)
		# Capture the reloaded progression and pass it to manager explicitly
		var reloaded: Variant = save_service.call("load_progression", 0)
		var reloaded_progression = reloaded as ProgressionDataRef if reloaded is ProgressionDataRef else null
		manager.refresh_from_progression(reloaded_progression)
	await process_frame

	verify(manager.is_destiny_unlocked() == true, "is_destiny_unlocked() is true at NG+3", "ng_plus_purchases count satisfies the gate")

	verify(manager.record_decision("CH01", "branch_choice", "stay") == true, "record_decision() returns true")
	var decisions_after_record: Array = manager.get_past_decisions()
	verify(not decisions_after_record.is_empty(), "get_past_decisions() returns non-empty after recording")
	verify(decisions_after_record[0] is Dictionary and String((decisions_after_record[0] as Dictionary).get("choice_key", "")) == "branch_choice", "record_decision() adds a past decision record")

	var before_change_count := decisions_after_record.size()
	verify(manager.change_past_decision("CH01", "branch_choice", "leave") == true, "change_past_decision() returns true")
	var decisions_after_change: Array = manager.get_past_decisions()
	verify(decisions_after_change.size() == before_change_count + 1, "change_past_decision() appends a changed decision record")
	verify(String((decisions_after_change[decisions_after_change.size() - 1] as Dictionary).get("new_value", "")) == "leave", "change_past_decision() modifies the latest decision")
	verify(manager.is_history_changer() == true, "is_history_changer() returns true after a change")

	var universe_state: Dictionary = manager.get_destiny_universe_state()
	verify(universe_state.has("current_world") and universe_state["current_world"] is Dictionary, "get_destiny_universe_state() includes current_world")
	verify(universe_state.has("past_world") and universe_state["past_world"] is Dictionary, "get_destiny_universe_state() includes past_world")
	verify(universe_state.has("past_decisions") and universe_state["past_decisions"] is Array, "get_destiny_universe_state() includes past_decisions")
	verify(universe_state.has("history_changer") and universe_state["history_changer"] is bool, "get_destiny_universe_state() includes history_changer")
	verify(universe_state.has("destiny_unlocked") and universe_state["destiny_unlocked"] is bool, "get_destiny_universe_state() includes destiny_unlocked")

	manager.queue_free()
	if save_service != null:
		save_service.call("save_progression", previous_progression, 0)
	await process_frame


func test_destiny_ui() -> void:
	if DestinyUIRef == null:
		tests_failed += 1
		print("[%s] DestinyUI class failed to load" % FAIL)
		return
	verify(true, "DestinyUI class loads")

	var ui: DestinyUIRef = DestinyUIRef.new()
	root.add_child(ui)
	await process_frame
	verify(ui != null and ui.get_child_count() > 0, "DestinyUI node creates its interface")

	var manager_stub := DestinyManagerStub.new()
	manager_stub.name = "DestinyManagerStub"
	manager_stub.decisions = [
		{"chapter_id": "CH01", "choice_key": "branch_choice", "old_value": "stay", "new_value": "leave"}
	]
	root.add_child(manager_stub)
	await process_frame

	ui.bind_destiny_manager(manager_stub)
	await process_frame

	verify(_find_label_text(ui, "Changes Applied: 1") != null, "DestinyUI binds to manager and refreshes decision count")

	manager_stub.decisions.append({"chapter_id": "CH02", "choice_key": "path_choice", "old_value": "left", "new_value": "right"})
	manager_stub.emit_signal("decisions_changed")
	await process_frame
	verify(_find_label_text(ui, "Changes Applied: 2") != null, "DestinyUI responds to bound manager signal")

	ui.queue_free()
	manager_stub.queue_free()
	await process_frame


func test_encyclopedia_extension() -> void:
	var file: FileAccess = FileAccess.open("res://scripts/ui/encyclopedia_panel.gd", FileAccess.READ)
	if file == null:
		tests_failed += 1
		print("[%s] encyclopedia_panel.gd could not be opened" % FAIL)
		return

	var source_text := file.get_as_text()
	file.close()
	verify(source_text.find("const TAB_DESTINY") != -1, "EncyclopediaPanel has TAB_DESTINY constant")


func _find_label_text(node: Node, expected_text: String) -> Label:
	if node is Label and String((node as Label).text) == expected_text:
		return node as Label
	for child in node.get_children():
		var found := _find_label_text(child, expected_text)
		if found != null:
			return found
	return null


func _find_node_with_methods(node: Node, method_names: Array[String]) -> Node:
	var matches_all := true
	for method_name in method_names:
		if not node.has_method(method_name):
			matches_all = false
			break
	if matches_all:
		return node
	for child in node.get_children():
		var found := _find_node_with_methods(child, method_names)
		if found != null:
			return found
	return null


func print_results() -> void:
	print("\n=== Results ===")
	print("Tests run:    %d" % tests_run)
	print("Tests passed: %d" % tests_passed)
	print("Tests failed: %d" % tests_failed)
	if tests_failed == 0:
		print("\n✅ All Destiny System tests PASSED")
	else:
		print("\n❌ %d test(s) FAILED" % tests_failed)
