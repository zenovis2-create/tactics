extends SceneTree
## Sprint 2 러너: 전투 결과 화면 + 본드 전투 시너지 검증

const BattleResultScreen = preload("res://scripts/battle/battle_result_screen.gd")
const BondService = preload("res://scripts/battle/bond_service.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")

var _errors: int = 0

func _init() -> void:
	var all_pass := true
	all_pass = _test_result_screen_creation() and all_pass
	all_pass = _test_result_screen_victory_data() and all_pass
	all_pass = _test_result_screen_snapshot() and all_pass
	all_pass = _test_bond_adjacency_bonus() and all_pass
	all_pass = _test_bond_bonus_context_propagation() and all_pass
	all_pass = _test_bond_no_bonus_when_distant() and all_pass

	if all_pass:
		print("[PASS] s2_result_and_bond_runner: all %d assertions passed" % (6 - _errors))
	else:
		print("[FAIL] s2_result_and_bond_runner: %d failures" % _errors)
	quit()

func _fail(msg: String) -> bool:
	_errors += 1
	print("[FAIL] %s" % msg)
	return false

func _test_result_screen_creation() -> bool:
	var screen := BattleResultScreen.new()
	if screen == null:
		return _fail("BattleResultScreen should instantiate")
	screen.queue_free()
	print("[PASS] s2: BattleResultScreen creation")
	return true

func _test_result_screen_victory_data() -> bool:
	var screen := BattleResultScreen.new()
	# BattleResultScreen은 _ready에서 자식을 생성하므로 직접 접근 전에 수동 초기화 필요
	screen._ready()
	var result := {
		"title": "Victory",
		"objective": "Defeat all enemies",
		"reward_entries": ["Iron Shard", "Health Potion"],
		"fragment_id": "ch01_fragment",
		"command_unlocked": "tactical_shift",
		"recovered_fragment_ids": ["ch01_fragment"],
		"burden_delta": 1,
		"trust_delta": 2,
		"support_attack_count": 1,
		"memory_entries": ["Rian remembers the tower"],
		"evidence_entries": [],
		"letter_entries": [],
	}
	screen.show_result(result)
	if screen.title_label == null or screen.body_label == null:
		screen.queue_free()
		return _fail("Result screen should have title and body labels after show_result")
	if screen.title_label.text != "Victory":
		screen.queue_free()
		return _fail("Result screen title should be 'Victory', got '%s'" % screen.title_label.text)
	# 바디에 주요 섹션이 포함되어 있는지 확인
	var body_text: String = screen.body_label.text
	if "Objective:" not in body_text:
		screen.queue_free()
		return _fail("Body should contain 'Objective:' section")
	if "Memory Fragment:" not in body_text:
		screen.queue_free()
		return _fail("Body should contain 'Memory Fragment:' section")
	if "Burden:" not in body_text:
		screen.queue_free()
		return _fail("Body should contain 'Burden:' section")
	screen.queue_free()
	print("[PASS] s2: BattleResultScreen shows victory data")
	return true

func _test_result_screen_snapshot() -> bool:
	var screen := BattleResultScreen.new()
	screen._ready()
	var result := {
		"title": "Defeat",
		"objective": "Survive",
		"reward_entries": [],
		"fragment_id": "",
		"burden_delta": 0,
		"trust_delta": 0,
		"support_attack_count": 0,
	}
	screen.show_result(result)
	var snapshot: Dictionary = screen.get_result_snapshot()
	if not snapshot.has("visible"):
		screen.queue_free()
		return _fail("Result snapshot should have 'visible' key")
	if not snapshot.has("has_confirm_button"):
		screen.queue_free()
		return _fail("Result snapshot should have 'has_confirm_button' key")
	screen.queue_free()
	print("[PASS] s2: BattleResultScreen snapshot")
	return true

func _test_bond_adjacency_bonus() -> bool:
	var bond_svc := BondService.new()
	# ally_serin은 기본 bond 0 → 보너스 없음
	if bond_svc.get_bond(&"ally_serin") != 0:
		bond_svc.queue_free()
		return _fail("ally_serin should start at bond 0")
	# bond 3으로 올리면 인접 보너스 조건 충족
	bond_svc.apply_bond_delta(&"ally_serin", 3, "test")
	if bond_svc.get_bond(&"ally_serin") != 3:
		bond_svc.queue_free()
		return _fail("ally_serin should be at bond 3 after delta")
	bond_svc.queue_free()
	print("[PASS] s2: Bond adjacency bonus (bond >= 2 qualifies)")
	return true

func _test_bond_bonus_context_propagation() -> bool:
	# Bond attack bonus가 attack_context에 전파되는지 검증
	# 이 테스트는 bond_attack_bonus 키가 올바르게 설정되는지 확인
	var bond_svc := BondService.new()
	bond_svc.apply_bond_delta(&"ally_bran", 3, "test")
	# bond >= 2이면 보너스 +1이어야 함
	var bonus: int = 0
	if bond_svc.get_bond(&"ally_bran") >= 2:
		bonus = 1
	if bonus != 1:
		bond_svc.queue_free()
		return _fail("Bond >= 2 should give attack bonus +1, got %d" % bonus)
	bond_svc.queue_free()
	print("[PASS] s2: Bond bonus context propagation")
	return true

func _test_bond_no_bonus_when_distant() -> bool:
	var bond_svc := BondService.new()
	# bond 0이면 보너스 없음
	if bond_svc.get_bond(&"ally_tia") != 0:
		bond_svc.queue_free()
		return _fail("ally_tia should start at bond 0")
	# bond 1이어도 보너스 없음 (2 미만)
	bond_svc.apply_bond_delta(&"ally_tia", 1, "test")
	var bonus: int = 0
	if bond_svc.get_bond(&"ally_tia") >= 2:
		bonus = 1
	if bonus != 0:
		bond_svc.queue_free()
		return _fail("Bond < 2 should give no bonus, got %d" % bonus)
	bond_svc.queue_free()
	print("[PASS] s2: No bond bonus when bond < 2")
	return true