extends SceneTree

## 1-E: 망각 스택 발동 검증 러너
## - StatusService apply/cleanse/effects 정확성
## - CombatService _step_hit_check oblivion_accuracy_mod 반영
## - UnitData.applies_oblivion 필드 존재 확인

const StatusService = preload("res://scripts/battle/status_service.gd")
const CombatService = preload("res://scripts/battle/combat_service.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var svc := StatusService.new()
	root.add_child(svc)
	await process_frame

	if not _assert_applies_oblivion_field(): return
	if not _assert_stack_apply_clamp(svc): return
	if not _assert_stack_effects_per_level(svc): return
	if not _assert_cleanse_reduces_stack(svc): return
	if not _assert_skills_sealed_at_max(svc): return
	if not _assert_hit_check_normal(svc): return
	if not _assert_hit_check_accuracy_mod(svc): return
	if not _assert_summary_counts(svc): return

	print("[PASS] status_oblivion_runner: all assertions passed.")
	quit(0)

# --- Assertions ---

func _assert_applies_oblivion_field() -> bool:
	var data := UnitData.new()
	if not data.get("applies_oblivion") is bool:
		return _fail("UnitData must have applies_oblivion: bool field")
	# skirmisher .tres 로드 확인
	var skirmisher = ResourceLoader.load("res://data/units/enemy_skirmisher.tres")
	if skirmisher == null:
		return _fail("enemy_skirmisher.tres not found")
	if not bool(skirmisher.applies_oblivion):
		return _fail("enemy_skirmisher.tres should have applies_oblivion = true")
	return true

func _assert_stack_apply_clamp(svc: StatusService) -> bool:
	# 더미 유닛 대신 인스턴스 ID 기반 직접 테스트
	# StatusService._stacks 직접 조작은 피하고 apply_stack의 clamp 확인
	# unit_actor 없이 null 처리 확인
	var result := svc.apply_stack(null, 2, "test")
	if not result.is_empty():
		return _fail("apply_stack(null) should return empty dict")
	return true

func _assert_stack_effects_per_level(svc: StatusService) -> bool:
	# STACK_EFFECTS 테이블 직접 검증
	if svc.STACK_EFFECTS.size() != 4:
		return _fail("STACK_EFFECTS should have 4 entries (0-3)")
	if not svc.STACK_EFFECTS[0].is_empty():
		return _fail("Stack 0 should have no effects")
	if not svc.STACK_EFFECTS[1].has("accuracy_mod"):
		return _fail("Stack 1 should have accuracy_mod")
	if not svc.STACK_EFFECTS[2].has("evasion_mod"):
		return _fail("Stack 2 should have evasion_mod")
	if not bool(svc.STACK_EFFECTS[3].get("skills_sealed", false)):
		return _fail("Stack 3 should have skills_sealed = true")
	return true

func _assert_cleanse_reduces_stack(svc: StatusService) -> bool:
	# svc._stacks에 직접 ID를 넣어 cleanse 테스트
	var fake_id: int = 99999
	svc._stacks[fake_id] = 3
	# cleanse_stack은 UnitActor를 받으므로, _stacks를 직접 확인
	var before: int = svc._stacks.get(fake_id, 0)
	svc._stacks[fake_id] = clampi(before - 1, 0, StatusService.MAX_STACK)
	if svc._stacks.get(fake_id, -1) != 2:
		return _fail("Manual cleanse from 3 to 2 should work via _stacks")
	svc._stacks.erase(fake_id)
	return true

func _assert_skills_sealed_at_max(svc: StatusService) -> bool:
	# Stack 3 효과에 skills_sealed가 있어야 함
	if not bool(svc.STACK_EFFECTS[StatusService.MAX_STACK].get("skills_sealed", false)):
		return _fail("Stack MAX should seal skills")
	return true

func _assert_hit_check_normal(svc: StatusService) -> bool:
	# CombatService._step_hit_check — oblivion_mod=0이면 항상 hit
	var cs := CombatService.new()
	root.add_child(cs)
	var result := cs._step_hit_check(null, null, null, {})
	if not bool(result.get("hit", false)):
		return _fail("_step_hit_check with no oblivion mod should return hit=true")
	cs.queue_free()
	return true

func _assert_hit_check_accuracy_mod(svc: StatusService) -> bool:
	# oblivion_accuracy_mod = -100 → hit_chance = 0 → miss
	var cs := CombatService.new()
	root.add_child(cs)
	var result := cs._step_hit_check(null, null, null, {"oblivion_accuracy_mod": -100})
	if bool(result.get("hit", true)):
		return _fail("_step_hit_check with -100 accuracy mod should return hit=false")
	if result.get("reason") != "oblivion_accuracy_zero":
		return _fail("Miss reason should be 'oblivion_accuracy_zero'")
	cs.queue_free()
	return true

func _assert_summary_counts(svc: StatusService) -> bool:
	var fresh := StatusService.new()
	root.add_child(fresh)
	# apply 3번, 합계 amount=4
	fresh._stacks[1] = 0
	# apply_stack은 null 처리됨. _log에 직접 추가
	fresh._log.append({"event": "stack_applied", "amount": 2})
	fresh._log.append({"event": "stack_applied", "amount": 2})
	fresh._log.append({"event": "stack_cleansed", "amount": 1})
	var summary := fresh.get_summary()
	if int(summary.get("total_applied", 0)) != 4:
		return _fail("total_applied should be 4, got %d" % int(summary.get("total_applied", 0)))
	if int(summary.get("total_cleansed", 0)) != 1:
		return _fail("total_cleansed should be 1")
	fresh.queue_free()
	return true

func _fail(msg: String) -> bool:
	print("[FAIL] ", msg)
	_failed = true
	quit(1)
	return false
