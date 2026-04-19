extends SceneTree

## EndingResolver unit tests — headless standalone runner.
## Converted from GutTest to SceneTree so it can run with:
##   godot4 --headless --path /path/to/project --script res://tests/test_ending_resolver.gd

const EndingResolver = preload("res://scripts/battle/ending_resolver.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

var _pass_count: int = 0
var _fail_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_run_tests()
	_print_summary()
	if _fail_count > 0:
		quit(1)
	else:
		quit(0)


# --- Test helpers ---

func _create_progression_data() -> ProgressionData:
	var data := ProgressionData.new()
	data.recovered_fragments = {}
	data.unit_progression = {}
	data.burden = 0
	data.trust = 5
	return data


func _set_all_companion_bonds(data: ProgressionData) -> void:
	for unit_id in ["ally_serin", "ally_bran", "ally_tia", "ally_enoch", "ally_karl", "ally_noah"]:
		data.unit_progression[unit_id] = {"bond_level": 5, "recruited": true, "level": 1}


func _set_key_fragments(data: ProgressionData) -> void:
	for fragment_id in [
		"ch01_fragment", "ch02_fragment", "ch03_fragment", "ch04_fragment",
		"ch05_fragment", "ch06_fragment", "ch07_fragment", "ch08_fragment",
		"ch09_fragment", "ch10_fragment"
	]:
		data.recovered_fragments[fragment_id] = true


func _assert_eq(label: String, actual, expected) -> void:
	if actual == expected:
		_pass_count += 1
	else:
		_fail_count += 1
		print("[FAIL] %s: expected %s, got %s" % [label, str(expected), str(actual)])


func _assert_true(label: String, value: bool) -> void:
	if value:
		_pass_count += 1
	else:
		_fail_count += 1
		print("[FAIL] %s: expected true, got false" % label)


func _assert_false(label: String, value: bool) -> void:
	if not value:
		_pass_count += 1
	else:
		_fail_count += 1
		print("[FAIL] %s: expected false, got true" % label)


# --- resolve_ending Tests ---

func _test_resolve_ending_true_ending() -> void:
	var data := _create_progression_data()
	data.burden = 3
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	var result: StringName = EndingResolver.resolve_ending(data)
	_assert_eq("resolve_ending: true ending when all conditions met", result, &"true_ending")


func _test_resolve_ending_normal_ending_missing_bond() -> void:
	var data := _create_progression_data()
	data.burden = 3
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	data.unit_progression.erase("ally_noah")
	var result: StringName = EndingResolver.resolve_ending(data)
	_assert_eq("resolve_ending: normal ending when bond incomplete", result, &"normal_ending")


func _test_resolve_ending_normal_ending_burden_too_high() -> void:
	var data := _create_progression_data()
	data.burden = 5
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	var result: StringName = EndingResolver.resolve_ending(data)
	_assert_eq("resolve_ending: normal ending when burden > 4", result, &"normal_ending")


func _test_resolve_ending_true_ending_burden_boundary() -> void:
	var data := _create_progression_data()
	data.burden = 4
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	var result: StringName = EndingResolver.resolve_ending(data)
	_assert_eq("resolve_ending: burden = 4 boundary true ending", result, &"true_ending")


func _test_resolve_ending_normal_ending_trust_too_low() -> void:
	var data := _create_progression_data()
	data.trust = 4
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	var result: StringName = EndingResolver.resolve_ending(data)
	_assert_eq("resolve_ending: normal ending when trust < 5", result, &"normal_ending")


func _test_resolve_ending_true_ending_trust_boundary() -> void:
	var data := _create_progression_data()
	data.trust = 5
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	var result: StringName = EndingResolver.resolve_ending(data)
	_assert_eq("resolve_ending: trust = 5 boundary true ending", result, &"true_ending")


func _test_resolve_ending_normal_ending_missing_fragments() -> void:
	var data := _create_progression_data()
	_set_all_companion_bonds(data)
	for fragment_id in [
		"ch01_fragment", "ch02_fragment", "ch03_fragment", "ch04_fragment",
		"ch05_fragment", "ch06_fragment", "ch07_fragment", "ch08_fragment",
		"ch09_fragment"
	]:
		data.recovered_fragments[fragment_id] = true
	var result: StringName = EndingResolver.resolve_ending(data)
	_assert_eq("resolve_ending: normal ending with missing fragments", result, &"normal_ending")


func _test_resolve_ending_burden_0() -> void:
	var data := _create_progression_data()
	data.burden = 0
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	var result: StringName = EndingResolver.resolve_ending(data)
	_assert_eq("resolve_ending: burden = 0 true ending", result, &"true_ending")


func _test_resolve_ending_burden_9() -> void:
	var data := _create_progression_data()
	data.burden = 9
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	var result: StringName = EndingResolver.resolve_ending(data)
	_assert_eq("resolve_ending: burden = 9 normal ending", result, &"normal_ending")


func _test_resolve_ending_null_data() -> void:
	var result: StringName = EndingResolver.resolve_ending(null)
	_assert_eq("resolve_ending: null data returns normal_ending", result, &"normal_ending")


# --- _check_true_ending_conditions Tests ---

func _test_check_true_ending_conditions_all_met() -> void:
	var data := _create_progression_data()
	data.burden = 2
	data.trust = 7
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	var result: bool = EndingResolver._check_true_ending_conditions(data)
	_assert_true("check_true_ending_conditions: all conditions met", result)


func _test_check_true_ending_conditions_fails_bond() -> void:
	var data := _create_progression_data()
	data.burden = 2
	data.trust = 7
	data.unit_progression["ally_serin"] = {"bond_level": 5}
	data.unit_progression["ally_bran"] = {"bond_level": 5}
	data.unit_progression["ally_tia"] = {"bond_level": 5}
	data.unit_progression["ally_enoch"] = {"bond_level": 5}
	data.unit_progression["ally_karl"] = {"bond_level": 5}
	_set_key_fragments(data)
	var result: bool = EndingResolver._check_true_ending_conditions(data)
	_assert_false("check_true_ending_conditions: fails without ally_noah", result)


func _test_check_true_ending_conditions_fails_burden() -> void:
	var data := _create_progression_data()
	data.burden = 6
	data.trust = 7
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	var result: bool = EndingResolver._check_true_ending_conditions(data)
	_assert_false("check_true_ending_conditions: fails when burden > 4", result)


func _test_check_true_ending_conditions_fails_trust() -> void:
	var data := _create_progression_data()
	data.burden = 2
	data.trust = 2
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	var result: bool = EndingResolver._check_true_ending_conditions(data)
	_assert_false("check_true_ending_conditions: fails with low trust", result)


func _test_check_true_ending_conditions_fails_fragments() -> void:
	var data := _create_progression_data()
	data.burden = 2
	data.trust = 7
	_set_all_companion_bonds(data)
	var result: bool = EndingResolver._check_true_ending_conditions(data)
	_assert_false("check_true_ending_conditions: fails without key fragments", result)


# --- _has_all_companions_bond_5 Tests ---

func _test_has_all_companions_bond_5_true() -> void:
	var data := _create_progression_data()
	_set_all_companion_bonds(data)
	var result: bool = EndingResolver._has_all_companions_bond_5(data)
	_assert_true("has_all_companions_bond_5: all 6 at bond 5", result)


func _test_has_all_companions_bond_5_false_one_missing() -> void:
	var data := _create_progression_data()
	data.unit_progression["ally_serin"] = {"bond_level": 5}
	data.unit_progression["ally_bran"] = {"bond_level": 5}
	data.unit_progression["ally_tia"] = {"bond_level": 5}
	data.unit_progression["ally_enoch"] = {"bond_level": 5}
	data.unit_progression["ally_karl"] = {"bond_level": 5}
	var result: bool = EndingResolver._has_all_companions_bond_5(data)
	_assert_false("has_all_companions_bond_5: false with ally_noah missing", result)


func _test_has_all_companions_bond_5_false_none_set() -> void:
	var data := _create_progression_data()
	var result: bool = EndingResolver._has_all_companions_bond_5(data)
	_assert_false("has_all_companions_bond_5: false when none set", result)


func _test_has_all_companions_bond_5_false_bond_4() -> void:
	var data := _create_progression_data()
	_set_all_companion_bonds(data)
	data.unit_progression["ally_noah"] = {"bond_level": 4}
	var result: bool = EndingResolver._has_all_companions_bond_5(data)
	_assert_false("has_all_companions_bond_5: false when bond_level < 5", result)


# --- get_ending_conditions_status Tests ---

func _test_get_ending_conditions_status_true_ending() -> void:
	var data := _create_progression_data()
	data.burden = 3
	data.trust = 7
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	var status: Dictionary = EndingResolver.get_ending_conditions_status(data)
	_assert_true("status: companions_bond_5 true", bool(status.get("companions_bond_5", false)))
	_assert_true("status: burden_ok true", bool(status.get("burden_ok", false)))
	_assert_true("status: trust_ok true", bool(status.get("trust_ok", false)))
	_assert_true("status: all_key_fragments true", bool(status.get("all_key_fragments", false)))
	_assert_eq("status: no missing fragments", status.get("missing_fragments", []).size(), 0)


func _test_get_ending_conditions_status_normal() -> void:
	var data := _create_progression_data()
	data.burden = 6
	data.trust = 3
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	var status: Dictionary = EndingResolver.get_ending_conditions_status(data)
	_assert_false("status: burden_ok false when burden=6", bool(status.get("burden_ok", true)))
	_assert_false("status: trust_ok false when trust=3", bool(status.get("trust_ok", true)))
	_assert_eq("status: burden value is 6", status.get("burden"), 6)
	_assert_eq("status: trust value is 3", status.get("trust"), 3)


func _test_get_ending_conditions_status_null_data() -> void:
	var status: Dictionary = EndingResolver.get_ending_conditions_status(null)
	_assert_false("status null: companions_bond_5 false", bool(status.get("companions_bond_5", true)))
	_assert_false("status null: burden_ok false", bool(status.get("burden_ok", true)))
	_assert_false("status null: trust_ok false", bool(status.get("trust_ok", true)))
	_assert_false("status null: all_key_fragments false", bool(status.get("all_key_fragments", true)))


# --- Edge Cases ---

func _test_resolve_ending_empty_data() -> void:
	var data := _create_progression_data()
	var result: StringName = EndingResolver.resolve_ending(data)
	_assert_eq("resolve_ending: empty data gives normal_ending", result, &"normal_ending")


func _test_resolve_ending_missing_unit_progress_key() -> void:
	var data := _create_progression_data()
	data.burden = 0
	data.trust = 9
	_set_key_fragments(data)
	data.unit_progression["ally_serin"] = {"bond_level": 5}
	data.unit_progression["ally_bran"] = {"bond_level": 5}
	data.unit_progression["ally_tia"] = {"bond_level": 5}
	data.unit_progression["ally_enoch"] = {"bond_level": 5}
	data.unit_progression["ally_karl"] = {"bond_level": 5}
	var result: StringName = EndingResolver.resolve_ending(data)
	_assert_eq("resolve_ending: missing unit key treated as bond 0", result, &"normal_ending")


func _test_true_ending_burden_boundary_4() -> void:
	var data := _create_progression_data()
	data.burden = 4
	data.trust = 5
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	var result: bool = EndingResolver._check_true_ending_conditions(data)
	_assert_true("check_true_ending_conditions: burden=4 satisfies burden <= 4", result)


func _test_true_ending_burden_boundary_5() -> void:
	var data := _create_progression_data()
	data.burden = 5
	data.trust = 5
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	var result: bool = EndingResolver._check_true_ending_conditions(data)
	_assert_false("check_true_ending_conditions: burden=5 does NOT satisfy burden <= 4", result)


func _test_true_ending_trust_boundary_5() -> void:
	var data := _create_progression_data()
	data.burden = 4
	data.trust = 5
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	var result: bool = EndingResolver._check_true_ending_conditions(data)
	_assert_true("check_true_ending_conditions: trust=5 satisfies trust >= 5", result)


func _test_true_ending_trust_boundary_4() -> void:
	var data := _create_progression_data()
	data.burden = 4
	data.trust = 4
	_set_all_companion_bonds(data)
	_set_key_fragments(data)
	var result: bool = EndingResolver._check_true_ending_conditions(data)
	_assert_false("check_true_ending_conditions: trust=4 does NOT satisfy trust >= 5", result)


# --- Test runner ---

func _run_tests() -> void:
	_test_resolve_ending_true_ending()
	_test_resolve_ending_normal_ending_missing_bond()
	_test_resolve_ending_normal_ending_burden_too_high()
	_test_resolve_ending_true_ending_burden_boundary()
	_test_resolve_ending_normal_ending_trust_too_low()
	_test_resolve_ending_true_ending_trust_boundary()
	_test_resolve_ending_normal_ending_missing_fragments()
	_test_resolve_ending_burden_0()
	_test_resolve_ending_burden_9()
	_test_resolve_ending_null_data()
	_test_check_true_ending_conditions_all_met()
	_test_check_true_ending_conditions_fails_bond()
	_test_check_true_ending_conditions_fails_burden()
	_test_check_true_ending_conditions_fails_trust()
	_test_check_true_ending_conditions_fails_fragments()
	_test_has_all_companions_bond_5_true()
	_test_has_all_companions_bond_5_false_one_missing()
	_test_has_all_companions_bond_5_false_none_set()
	_test_has_all_companions_bond_5_false_bond_4()
	_test_get_ending_conditions_status_true_ending()
	_test_get_ending_conditions_status_normal()
	_test_get_ending_conditions_status_null_data()
	_test_resolve_ending_empty_data()
	_test_resolve_ending_missing_unit_progress_key()
	_test_true_ending_burden_boundary_4()
	_test_true_ending_burden_boundary_5()
	_test_true_ending_trust_boundary_5()
	_test_true_ending_trust_boundary_4()


func _print_summary() -> void:
	var total := _pass_count + _fail_count
	if _fail_count == 0:
		print("[PASS] test_ending_resolver: %d/%d tests passed." % [_pass_count, total])
	else:
		print("[FAIL] test_ending_resolver: %d/%d tests passed, %d failed." % [_pass_count, total, _fail_count])
