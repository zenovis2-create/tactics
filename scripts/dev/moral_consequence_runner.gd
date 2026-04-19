extends SceneTree

const PASS := "✅ PASS"
const FAIL := "❌ FAIL"

const EthicsTrackerRef = preload("res://scripts/battle/ethics_tracker.gd")
const MoralConsequenceServiceRef = preload("res://scripts/battle/moral_consequence_service.gd")
const ProgressionDataRef = preload("res://scripts/data/progression_data.gd")
const UnitDataRef = preload("res://scripts/data/unit_data.gd")

var tests_run: int = 0
var tests_passed: int = 0
var tests_failed: int = 0
var _owned_nodes: Array[Node] = []


class MockEthics:
	extends EthicsTrackerRef

	func _ready() -> void:
		pass


class MockMoralService:
	extends MoralConsequenceServiceRef

	var injected_ethics: EthicsTrackerRef = null

	func _ready() -> void:
		pass

	func set_ethics(ethics: EthicsTrackerRef) -> void:
		injected_ethics = ethics

	func _get_ethics() -> EthicsTrackerRef:
		return injected_ethics

	func get_ethics_bracket_for_test() -> String:
		return _get_ethics_bracket()

	func get_ethics_descriptor_for_test() -> String:
		return _get_ethics_descriptor()


class MockDecisionPoint:
	extends Node

	signal decision_made(chapter_id: String, choice_key: String, choice_value: Variant)

	func emit_decision(chapter_id: String, choice_key: String, choice_value: Variant) -> void:
		decision_made.emit(chapter_id, choice_key, choice_value)


func _initialize() -> void:
	print("\n=== Moral Consequence Runner ===\n")
	call_deferred("_run")


func _run() -> void:
	test_ethics_tracker()
	test_moral_consequence_service()
	test_decision_point_integration()
	_cleanup_owned_nodes()
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


func test_ethics_tracker() -> void:
	var bind_progression := ProgressionDataRef.new()
	bind_progression.ethics_score = 18.0
	bind_progression.ethics_decision_log = [
		{
			"chapter_id": "CH00",
			"decision_key": "spared_enemy",
			"weight": 5.0,
		}
	]
	var ethics := _own(MockEthics.new()) as MockEthics
	ethics.bind_progression(bind_progression)

	verify(is_equal_approx(ethics.ethics_score, 18.0), "EthicsTracker.bind_progression hydrates ethics_score")
	verify(ethics.decision_log.size() == 1, "EthicsTracker.bind_progression hydrates decision_log size")
	verify(String(ethics.decision_log[0].get("decision_key", "")) == "spared_enemy", "EthicsTracker.bind_progression preserves decision payload")

	ethics.reset_tracking()
	verify(is_equal_approx(ethics.ethics_score, 0.0), "EthicsTracker.reset_tracking resets ethics_score")
	verify(ethics.decision_log.is_empty(), "EthicsTracker.reset_tracking clears decision_log")
	verify(is_equal_approx(bind_progression.ethics_score, 0.0), "EthicsTracker.reset_tracking syncs progression ethics_score")
	verify(bind_progression.ethics_decision_log.is_empty(), "EthicsTracker.reset_tracking syncs progression decision_log")

	var weighted_progression := ProgressionDataRef.new()
	var weighted_ethics := _own(MockEthics.new()) as MockEthics
	weighted_ethics.bind_progression(weighted_progression)
	weighted_ethics.record_decision("CH01", "spared_enemy", 0.0)
	verify(is_equal_approx(weighted_ethics.ethics_score, 5.0), "EthicsTracker.record_decision uses DECISION_WEIGHTS when weight is zero")
	verify(String(weighted_ethics.decision_log[0].get("chapter_id", "")) == "CH01", "EthicsTracker.record_decision normalizes chapter_id to uppercase")

	var clamp_positive_progression := ProgressionDataRef.new()
	var clamp_positive_ethics := _own(MockEthics.new()) as MockEthics
	clamp_positive_ethics.bind_progression(clamp_positive_progression)
	clamp_positive_ethics.record_decision("CH98", "mythic_mercy", 250.0)
	verify(is_equal_approx(clamp_positive_ethics.ethics_score, 100.0), "EthicsTracker clamps ethics_score to +100")
	verify(is_equal_approx(clamp_positive_progression.ethics_score, 100.0), "EthicsTracker syncs +100 clamp to progression")
	verify(float(clamp_positive_ethics.decision_log[0].get("weight", 0.0)) == 250.0, "EthicsTracker preserves original positive decision weight in log")

	var clamp_negative_progression := ProgressionDataRef.new()
	var clamp_negative_ethics := _own(MockEthics.new()) as MockEthics
	clamp_negative_ethics.bind_progression(clamp_negative_progression)
	clamp_negative_ethics.record_decision("CH99", "catastrophe", -500.0)
	verify(is_equal_approx(clamp_negative_ethics.ethics_score, -100.0), "EthicsTracker clamps ethics_score to -100")
	verify(is_equal_approx(clamp_negative_progression.ethics_score, -100.0), "EthicsTracker syncs -100 clamp to progression")
	verify(float(clamp_negative_ethics.decision_log[0].get("weight", 0.0)) == -500.0, "EthicsTracker preserves original negative decision weight in log")

	var ruthless_progression := ProgressionDataRef.new()
	ruthless_progression.ethics_score = -20.0
	var ruthless_ethics := _own(MockEthics.new()) as MockEthics
	ruthless_ethics.bind_progression(ruthless_progression)
	ruthless_ethics.record_decision("CH02", "burned_bridge", 0.0)
	verify(is_equal_approx(ruthless_ethics.ethics_score, -30.0), "EthicsTracker reaches the ruthless boundary at -30")
	verify(ruthless_ethics.get_ethics_bracket() == "ruthless", "EthicsTracker classifies -30 as ruthless")

	var pragmatic_negative_progression := ProgressionDataRef.new()
	pragmatic_negative_progression.ethics_score = -29.0
	var pragmatic_negative_ethics := _own(MockEthics.new()) as MockEthics
	pragmatic_negative_ethics.bind_progression(pragmatic_negative_progression)
	verify(pragmatic_negative_ethics.get_ethics_bracket() == "pragmatic", "EthicsTracker keeps scores above -30 in the pragmatic bracket")

	var compassionate_progression := ProgressionDataRef.new()
	compassionate_progression.ethics_score = 25.0
	var compassionate_ethics := _own(MockEthics.new()) as MockEthics
	compassionate_ethics.bind_progression(compassionate_progression)
	compassionate_ethics.record_decision("CH03", "spared_enemy", 0.0)
	verify(is_equal_approx(compassionate_ethics.ethics_score, 30.0), "EthicsTracker can reach +30 exactly")
	verify(compassionate_ethics.get_ethics_bracket() == "pragmatic", "EthicsTracker keeps +30 in the pragmatic bracket")
	compassionate_ethics.record_decision("CH03", "spared_enemy", 0.0)
	verify(is_equal_approx(compassionate_ethics.ethics_score, 35.0), "EthicsTracker crosses above +30 after another compassionate decision")
	verify(compassionate_ethics.get_ethics_bracket() == "compassionate", "EthicsTracker classifies scores above +30 as compassionate")


func test_moral_consequence_service() -> void:
	var ruthless_service := _make_service_with_score(-40.0)
	var ruthless_modifier = ruthless_service.apply_consequences_to_boss("leonika")
	verify(is_equal_approx(float(ruthless_modifier.boss_damage_multiplier), 1.15), "Ruthless boss modifier raises damage to 1.15")
	verify(is_equal_approx(float(ruthless_modifier.boss_health_multiplier), 1.10), "Ruthless boss modifier raises health to 1.10")
	verify(String(ruthless_modifier.boss_attitude) == "hostile", "Ruthless boss modifier sets hostile attitude")
	verify(String(ruthless_modifier.boss_resolve_dialogue) == "당신은 나보다 더한 학살자였다", "Ruthless Leonika uses the ruthless resolve dialogue")

	var compassionate_service := _make_service_with_score(40.0)
	var compassionate_modifier = compassionate_service.apply_consequences_to_boss("leonika")
	verify(is_equal_approx(float(compassionate_modifier.boss_damage_multiplier), 1.0), "Compassionate boss modifier keeps damage at baseline")
	verify(is_equal_approx(float(compassionate_modifier.boss_health_multiplier), 1.0), "Compassionate boss modifier keeps health at baseline")
	verify(String(compassionate_modifier.boss_attitude) == "judgmental", "Compassionate boss modifier sets judgmental attitude")
	verify(String(compassionate_modifier.boss_resolve_dialogue) == "당신의 손에 희망이 있었다", "Compassionate Leonika uses the hopeful resolve dialogue")

	var pragmatic_service := _make_service_with_score(0.0)
	var pragmatic_modifier = pragmatic_service.apply_consequences_to_boss("shadow_knight")
	verify(is_equal_approx(float(pragmatic_modifier.boss_damage_multiplier), 1.0), "Pragmatic boss modifier keeps damage at baseline")
	verify(is_equal_approx(float(pragmatic_modifier.boss_health_multiplier), 1.0), "Pragmatic boss modifier keeps health at baseline")
	verify(String(pragmatic_modifier.boss_attitude) == "neutral", "Pragmatic boss modifier sets neutral attitude")
	verify(String(pragmatic_modifier.boss_resolve_dialogue) == "생존만으로는 누구도 구원할 수 없다", "Pragmatic fallback boss dialogue matches the survivor line")

	verify(ruthless_service.get_boss_dialogue_variant("leonika") == "당신은 나보다 더한 학살자였다", "Ruthless Leonika dialogue variant resolves correctly")
	verify(ruthless_service.get_boss_dialogue_variant("shadow_knight") == "전장은 당신의 잔혹함을 이미 기억하고 있다", "Ruthless Shadow Knight dialogue falls back to ruthless generic line")
	verify(ruthless_service.get_boss_dialogue_variant("dark_mage") == "전장은 당신의 잔혹함을 이미 기억하고 있다", "Ruthless Dark Mage dialogue falls back to ruthless generic line")

	verify(compassionate_service.get_boss_dialogue_variant("leonika") == "당신의 손에 희망이 있었다", "Compassionate Leonika dialogue variant resolves correctly")
	verify(compassionate_service.get_boss_dialogue_variant("shadow_knight") == "자비는 칼끝 앞에서 가장 먼저 흔들린다", "Compassionate Shadow Knight dialogue falls back to compassionate generic line")
	verify(compassionate_service.get_boss_dialogue_variant("dark_mage") == "자비는 칼끝 앞에서 가장 먼저 흔들린다", "Compassionate Dark Mage dialogue falls back to compassionate generic line")

	verify(pragmatic_service.get_boss_dialogue_variant("leonika") == "우리는 서로를 이해할 수 없다", "Pragmatic Leonika dialogue variant resolves correctly")
	verify(pragmatic_service.get_boss_dialogue_variant("shadow_knight") == "생존만으로는 누구도 구원할 수 없다", "Pragmatic Shadow Knight dialogue falls back to pragmatic generic line")
	verify(pragmatic_service.get_boss_dialogue_variant("dark_mage") == "생존만으로는 누구도 구원할 수 없다", "Pragmatic Dark Mage dialogue falls back to pragmatic generic line")

	var ruthless_ending: Dictionary = ruthless_service.apply_consequences_to_ending()
	verify(String(ruthless_ending.get("ending_variant", "")) == "Conqueror's Ending", "Ruthless ending uses Conqueror's Ending")
	verify(String(ruthless_ending.get("world_state_description", "")).find("불타는 관문") != -1, "Ruthless ending world state reflects devastation")

	var compassionate_ending: Dictionary = compassionate_service.apply_consequences_to_ending()
	verify(String(compassionate_ending.get("ending_variant", "")) == "Guardian's Ending", "Compassionate ending uses Guardian's Ending")
	verify(String(compassionate_ending.get("ending_text", "")).find("자비") != -1, "Compassionate ending text reflects mercy")

	var pragmatic_ending: Dictionary = pragmatic_service.apply_consequences_to_ending()
	verify(String(pragmatic_ending.get("ending_variant", "")) == "Survivor's Ending", "Pragmatic ending uses Survivor's Ending")
	verify(String(pragmatic_ending.get("world_state_description", "")).find("폐허") != -1, "Pragmatic ending world state reflects cold stability")

	var null_ethics_service := _own(MockMoralService.new()) as MockMoralService
	verify(null_ethics_service.get_ethics_bracket_for_test() == "pragmatic", "Null ethics falls back to the pragmatic bracket")
	verify(null_ethics_service.get_ethics_descriptor_for_test().find("윤리적 색") != -1, "Null ethics falls back to the default descriptor")

	var empty_boss_modifier = pragmatic_service.apply_consequences_to_boss("")
	verify(empty_boss_modifier != null, "Empty boss_id still returns a BossModifier")
	verify(String(empty_boss_modifier.boss_resolve_dialogue) == "생존만으로는 누구도 구원할 수 없다", "Empty boss_id uses the generic dialogue fallback")
	verify(String(empty_boss_modifier.boss_attitude) == "neutral", "Empty boss_id still preserves the bracket attitude")

	var leonika_unit := UnitDataRef.new()
	leonika_unit.unit_id = &"enemy_basil"
	verify(pragmatic_service.resolve_boss_id(leonika_unit) == "leonika", "resolve_boss_id maps enemy_basil to leonika")

	var shadow_knight_unit := UnitDataRef.new()
	shadow_knight_unit.unit_id = &"enemy_lete"
	verify(pragmatic_service.resolve_boss_id(shadow_knight_unit) == "shadow_knight", "resolve_boss_id maps enemy_lete to shadow_knight")

	var dark_mage_unit := UnitDataRef.new()
	dark_mage_unit.unit_id = &"enemy_varten"
	verify(pragmatic_service.resolve_boss_id(dark_mage_unit) == "dark_mage", "resolve_boss_id maps enemy_varten to dark_mage")

	var unknown_unit := UnitDataRef.new()
	unknown_unit.unit_id = &"enemy_unknown"
	verify(pragmatic_service.resolve_boss_id(unknown_unit).is_empty(), "resolve_boss_id returns empty for unknown bosses")


func test_decision_point_integration() -> void:
	var progression := ProgressionDataRef.new()
	var ethics := _own(MockEthics.new()) as MockEthics
	ethics.bind_progression(progression)
	var service := _own(MockMoralService.new()) as MockMoralService
	service.set_ethics(ethics)
	var decision_point := _own(MockDecisionPoint.new()) as MockDecisionPoint

	service.connect_decision_point(decision_point)
	verify(decision_point.is_connected("decision_made", Callable(service, "_on_decision_made")), "connect_decision_point hooks the decision_made signal")

	decision_point.emit_decision("CH01", "spared_enemy", true)
	verify(is_equal_approx(ethics.ethics_score, 5.0), "decision_made signal records known ethical choices")
	verify(ethics.decision_log.size() == 1, "decision_made signal appends a decision log entry")
	verify(String(ethics.decision_log[0].get("decision_key", "")) == "spared_enemy", "decision_made signal stores the emitted choice key")

	decision_point.emit_decision("CH01", "unknown_choice", true)
	verify(is_equal_approx(ethics.ethics_score, 5.0), "Unknown decision_made choices do not alter ethics_score")
	verify(ethics.decision_log.size() == 1, "Unknown decision_made choices do not append to the log")

	service.connect_decision_point(decision_point)
	decision_point.emit_decision("CH02", "burned_bridge", false)
	verify(is_equal_approx(ethics.ethics_score, -5.0), "Repeated connect_decision_point calls do not double-apply a decision")
	verify(ethics.decision_log.size() == 2, "Known follow-up decisions still append exactly once")
	verify(String(ethics.decision_log[1].get("decision_key", "")) == "burned_bridge", "Known follow-up decisions preserve the emitted key")
	verify(is_equal_approx(progression.ethics_score, -5.0), "decision_made integration syncs updated ethics_score into progression")


func _make_service_with_score(score: float) -> MockMoralService:
	var progression := ProgressionDataRef.new()
	progression.ethics_score = score
	var ethics := _own(MockEthics.new()) as MockEthics
	ethics.bind_progression(progression)
	var service := _own(MockMoralService.new()) as MockMoralService
	service.set_ethics(ethics)
	return service


func _own(node: Node) -> Node:
	_owned_nodes.append(node)
	return node


func _cleanup_owned_nodes() -> void:
	for index in range(_owned_nodes.size() - 1, -1, -1):
		var node := _owned_nodes[index]
		if is_instance_valid(node):
			node.free()
	_owned_nodes.clear()


func print_results() -> void:
	print("\n=== Results ===")
	print("Tests run:    %d" % tests_run)
	print("Tests passed: %d" % tests_passed)
	print("Tests failed: %d" % tests_failed)
	if tests_failed == 0:
		print("\n✅ All Moral Consequence tests PASSED")
	else:
		print("\n❌ %d test(s) FAILED" % tests_failed)
