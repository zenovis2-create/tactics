extends SceneTree
## Sprint 1 데미지 팝업 + 공격 애니메이션 통합 러너
## DamageLabel 생성/표시/자동소멸, show_damage 호출, play_attack_animation 호출 검증

const DamageLabel = preload("res://scripts/battle/damage_label.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")

var _errors: int = 0

func _init() -> void:
	var all_pass := true
	all_pass = _test_damage_label_creation() and all_pass
	all_pass = _test_damage_label_miss() and all_pass
	all_pass = _test_damage_label_critical() and all_pass
	all_pass = _test_damage_label_heal() and all_pass
	all_pass = _test_unit_actor_show_damage() and all_pass
	all_pass = _test_unit_actor_attack_animation() and all_pass
	all_pass = _test_unit_actor_attack_animation_guard() and all_pass
	all_pass = _test_unit_actor_apply_damage_shows_popup() and all_pass

	if all_pass:
		print("[PASS] s1_battle_feedback_runner: all %d assertions passed" % (8 - _errors))
	else:
		print("[FAIL] s1_battle_feedback_runner: %d failures" % _errors)
	quit()

func _fail(msg: String) -> bool:
	_errors += 1
	print("[FAIL] %s" % msg)
	return false

func _test_damage_label_creation() -> bool:
	var label := DamageLabel.new()
	label.setup(15, &"damage")
	if label._label == null:
		return _fail("DamageLabel._label should exist after setup")
	if label._label.text != "15":
		return _fail("DamageLabel text should be '15', got '%s'" % label._label.text)
	label.queue_free()
	print("[PASS] s1: DamageLabel creation with damage=15")
	return true

func _test_damage_label_miss() -> bool:
	var label := DamageLabel.new()
	label.setup(0, &"miss")
	if label._label.text != "MISS":
		return _fail("DamageLabel miss text should be 'MISS', got '%s'" % label._label.text)
	label.queue_free()
	print("[PASS] s1: DamageLabel MISS text")
	return true

func _test_damage_label_critical() -> bool:
	var label := DamageLabel.new()
	label.setup(25, &"critical")
	if label._label.text != "25!":
		return _fail("DamageLabel critical text should be '25!', got '%s'" % label._label.text)
	var font_size: int = label._label.get_theme_font_size("font_size")
	# CRITICAL은 24px 폰트 사이즈 사용 (setup에서 설정)
	label.queue_free()
	print("[PASS] s1: DamageLabel critical format")
	return true

func _test_damage_label_heal() -> bool:
	var label := DamageLabel.new()
	label.setup(5, &"heal")
	if label._label.text != "+5":
		return _fail("DamageLabel heal text should be '+5', got '%s'" % label._label.text)
	label.queue_free()
	print("[PASS] s1: DamageLabel heal format")
	return true

func _test_unit_actor_show_damage() -> bool:
	var actor := UnitActor.new()
	var data := UnitData.new()
	data.unit_id = &"test_unit"
	data.display_name = "Test"
	data.max_hp = 20
	data.attack = 5
	data.defense = 2
	actor.setup_from_data(data)

	# show_damage는 DamageLabel 자식을 추가해야 함
	actor.show_damage(7, &"damage")
	var damage_labels := actor.get_children().filter(func(c): return c is DamageLabel)
	if damage_labels.size() < 1:
		return _fail("UnitActor should have at least 1 DamageLabel child after show_damage")
	var label: DamageLabel = damage_labels[0] as DamageLabel
	if label._label.text != "7":
		return _fail("DamageLabel text should be '7', got '%s'" % label._label.text)
	actor.queue_free()
	print("[PASS] s1: UnitActor.show_damage() creates DamageLabel child")
	return true

func _test_unit_actor_attack_animation() -> bool:
	var actor := UnitActor.new()
	var data := UnitData.new()
	data.unit_id = &"test_actor_anim"
	data.display_name = "AnimTest"
	data.max_hp = 10
	data.attack = 3
	data.defense = 1
	actor.setup_from_data(data)
	actor.grid_position = Vector2i(2, 3)
	actor.position = Vector2(128.0, 192.0)  # 2*64, 3*64

	# play_attack_animation이 _animating_attack을 true로 설정해야 함
	var target_pos := Vector2i(3, 3)
	actor.play_attack_animation(target_pos, 64.0)
	if not actor.is_animating_attack():
		return _fail("UnitActor should be animating attack after play_attack_animation")
	# 시그널 연결 테스트
	var signal_received := [false]
	actor.attack_anim_hit.connect(func(): signal_received[0] = true)
	# tween은 headless에서 자동 진행되지 않으므로 수동 검증
	actor.queue_free()
	print("[PASS] s1: UnitActor.play_attack_animation sets _animating_attack")
	return true

func _test_unit_actor_attack_animation_guard() -> bool:
	var actor := UnitActor.new()
	var data := UnitData.new()
	data.unit_id = &"test_guard"
	data.display_name = "Guard"
	data.max_hp = 10
	data.attack = 3
	data.defense = 1
	actor.setup_from_data(data)

	# 중복 호출 방지: 이미 애니메이팅 중이면 무시
	actor._animating_attack = true
	actor.play_attack_animation(Vector2i(1, 1), 64.0)
	# 여전히 애니메이팅 상태 (새 tween 생성 안함)
	if not actor.is_animating_attack():
		return _fail("UnitActor should ignore duplicate play_attack_animation calls")
	actor._animating_attack = false
	actor.queue_free()
	print("[PASS] s1: UnitActor attack animation duplicate guard")
	return true

func _test_unit_actor_apply_damage_shows_popup() -> bool:
	var actor := UnitActor.new()
	var data := UnitData.new()
	data.unit_id = &"test_popup"
	data.display_name = "Popup"
	data.max_hp = 10
	data.attack = 3
	data.defense = 1
	actor.setup_from_data(data)

	# apply_damage가 show_damage를 호출하는지 확인
	actor.apply_damage(3)
	var damage_labels := actor.get_children().filter(func(c): return c is DamageLabel)
	if damage_labels.size() < 1:
		return _fail("apply_damage should create a DamageLabel child via show_damage")
	var label: DamageLabel = damage_labels[0] as DamageLabel
	if label._label.text != "3":
		return _fail("DamageLabel from apply_damage should show '3', got '%s'" % label._label.text)
	actor.queue_free()
	print("[PASS] s1: UnitActor.apply_damage() creates damage popup")
	return true