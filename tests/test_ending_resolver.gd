extends SceneTree

const EndingResolver = preload("res://scripts/battle/ending_resolver.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

var _pass_count: int = 0
var _fail_count: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_run_tests()
	_print_summary()
	quit(1 if _fail_count > 0 else 0)

func _create_progression_data() -> ProgressionData:
	var data := ProgressionData.new()
	data.flags = {}
	return data

func _set_all_resonance_flags(data: ProgressionData) -> void:
	for flag_id in EndingResolver.REQUIRED_RESONANCE_FLAGS:
		data.flags[String(flag_id)] = true

func _set_final_battle_flags(data: ProgressionData) -> void:
	data.flags[String(EndingResolver.REQUIRED_NAME_ANCHOR_FLAG)] = true
	data.flags[String(EndingResolver.REQUIRED_NAME_CALL_FLAG)] = true

func _assert_eq(label: String, actual, expected) -> void:
	if actual == expected:
		_pass_count += 1
	else:
		_fail_count += 1
		print("[FAIL] %s: expected %s, got %s" % [label, str(expected), str(actual)])

func _assert_true(label: String, value: bool) -> void:
	_assert_eq(label, value, true)

func _assert_false(label: String, value: bool) -> void:
	_assert_eq(label, value, false)

func _test_true_ending_when_all_three_axes_met() -> void:
	var data := _create_progression_data()
	_set_all_resonance_flags(data)
	_set_final_battle_flags(data)
	_assert_eq("resolve_ending: true when resonance + anchors + name calls are all met", EndingResolver.resolve_ending(data), EndingResolver.ENDING_TRUE)

func _test_normal_when_resonance_missing() -> void:
	var data := _create_progression_data()
	_set_all_resonance_flags(data)
	_set_final_battle_flags(data)
	data.flags.erase("flag_resonance_noah")
	_assert_eq("resolve_ending: normal when any resonance flag is missing", EndingResolver.resolve_ending(data), EndingResolver.ENDING_NORMAL)

func _test_normal_when_anchor_requirement_missing() -> void:
	var data := _create_progression_data()
	_set_all_resonance_flags(data)
	data.flags[String(EndingResolver.REQUIRED_NAME_CALL_FLAG)] = true
	_assert_eq("resolve_ending: normal when name-anchor condition is missing", EndingResolver.resolve_ending(data), EndingResolver.ENDING_NORMAL)

func _test_normal_when_name_call_requirement_missing() -> void:
	var data := _create_progression_data()
	_set_all_resonance_flags(data)
	data.flags[String(EndingResolver.REQUIRED_NAME_ANCHOR_FLAG)] = true
	_assert_eq("resolve_ending: normal when full name-call condition is missing", EndingResolver.resolve_ending(data), EndingResolver.ENDING_NORMAL)

func _test_null_defaults_to_normal() -> void:
	_assert_eq("resolve_ending: null progression -> normal", EndingResolver.resolve_ending(null), EndingResolver.ENDING_NORMAL)

func _test_status_snapshot_true_case() -> void:
	var data := _create_progression_data()
	_set_all_resonance_flags(data)
	_set_final_battle_flags(data)
	var status := EndingResolver.get_ending_conditions_status(data)
	_assert_true("status: all_resonance_flags true", bool(status.get("all_resonance_flags", false)))
	_assert_true("status: name_anchors_ok true", bool(status.get("name_anchors_ok", false)))
	_assert_true("status: all_name_calls true", bool(status.get("all_name_calls", false)))
	_assert_true("status: ready_for_true_ending true", bool(status.get("ready_for_true_ending", false)))
	_assert_eq("status: resolved_ending true_ending", status.get("resolved_ending", &""), EndingResolver.ENDING_TRUE)
	_assert_eq("status: no missing resonance flags", status.get("missing_resonance_flags", []).size(), 0)
	_assert_eq("status: no missing resonance labels", status.get("missing_resonance_labels", []).size(), 0)

func _test_status_snapshot_missing_resonance() -> void:
	var data := _create_progression_data()
	data.flags["flag_resonance_serin"] = true
	var status := EndingResolver.get_ending_conditions_status(data)
	_assert_false("status: all_resonance_flags false when partial", bool(status.get("all_resonance_flags", true)))
	_assert_false("status: ready_for_true_ending false when partial", bool(status.get("ready_for_true_ending", true)))
	_assert_eq("status: resolved_ending normal_ending when partial", status.get("resolved_ending", &""), EndingResolver.ENDING_NORMAL)
	_assert_eq("status: missing resonance count tracks remaining", status.get("missing_resonance_flags", []).size(), 5)
	_assert_eq("status: missing resonance labels expose ally names", ", ".join(status.get("missing_resonance_labels", [])), "브란, 티아, 에녹, 카일, 노아")

func _test_status_snapshot_null() -> void:
	var status := EndingResolver.get_ending_conditions_status(null)
	_assert_false("status null: all_resonance_flags false", bool(status.get("all_resonance_flags", true)))
	_assert_false("status null: name_anchors_ok false", bool(status.get("name_anchors_ok", true)))
	_assert_false("status null: all_name_calls false", bool(status.get("all_name_calls", true)))
	_assert_false("status null: ready_for_true_ending false", bool(status.get("ready_for_true_ending", true)))
	_assert_eq("status null: resolved_ending normal_ending", status.get("resolved_ending", &""), EndingResolver.ENDING_NORMAL)

func _test_criteria_summary_lines_surface_named_gaps_and_verdict() -> void:
	var partial := _create_progression_data()
	partial.flags["flag_resonance_serin"] = true
	var partial_summary := "\n".join(EndingResolver.get_criteria_summary_lines(partial))
	_assert_true("criteria summary: uses localized resonance labels", partial_summary.find("브란") != -1)
	_assert_true("criteria summary: surfaces normal-ending verdict when incomplete", partial_summary.find("현재 판정: 일반 엔딩") != -1)
	var complete := _create_progression_data()
	_set_all_resonance_flags(complete)
	_set_final_battle_flags(complete)
	var complete_summary := "\n".join(EndingResolver.get_criteria_summary_lines(complete))
	_assert_true("criteria summary: surfaces true-ending verdict when complete", complete_summary.find("현재 판정: 진엔딩 기준 충족") != -1)

func _run_tests() -> void:
	_test_true_ending_when_all_three_axes_met()
	_test_normal_when_resonance_missing()
	_test_normal_when_anchor_requirement_missing()
	_test_normal_when_name_call_requirement_missing()
	_test_null_defaults_to_normal()
	_test_status_snapshot_true_case()
	_test_status_snapshot_missing_resonance()
	_test_status_snapshot_null()
	_test_criteria_summary_lines_surface_named_gaps_and_verdict()

func _print_summary() -> void:
	var total := _pass_count + _fail_count
	if _fail_count == 0:
		print("[PASS] test_ending_resolver: %d/%d tests passed." % [_pass_count, total])
	else:
		print("[FAIL] test_ending_resolver: %d/%d tests passed, %d failed." % [_pass_count, total, _fail_count])
