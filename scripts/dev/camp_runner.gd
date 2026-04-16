extends SceneTree

## 2-F: 캠프 허브 검증 러너
## - CampData 필드 존재 확인
## - CampController.enter_camp() → CampData 반환
## - get_camp_summary() 키 검증
## - 알림 카운트 계산
## - 축 해금 로직 (기본 3개, ch04+ 확장)
## - exit_camp() 후 data 클리어
## - 이벤트 로그 기록

const CampData = preload("res://scripts/data/camp_data.gd")
const CampController = preload("res://scripts/camp/camp_controller.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var ctrl: CampController = CampController.new()
    root.add_child(ctrl)
    await process_frame

    if not _assert_camp_data_fields(): return
    if not _assert_enter_camp_returns_data(ctrl): return
    if not _assert_summary_keys(ctrl): return
    if not _assert_unit_progression_summary(ctrl): return
    if not _assert_notification_count(ctrl): return
    if not _assert_base_axes(ctrl): return
    if not _assert_extended_axes(ctrl): return
    if not _assert_exit_clears_data(ctrl): return
    if not _assert_event_log(ctrl): return

    print("[PASS] camp_runner: all assertions passed.")
    quit(0)

# --- Assertions ---

func _assert_camp_data_fields() -> bool:
    var d: CampData = CampData.new()
    if not d.get("current_chapter") is StringName:
        return _fail("CampData.current_chapter must be StringName")
    if not d.get("unlocked_axes") is Array:
        return _fail("CampData.unlocked_axes must be Array")
    if not d.get("pending_memory_entries") is Array:
        return _fail("CampData.pending_memory_entries must be Array")
    if not d.get("burden") is int:
        return _fail("CampData.burden must be int")
    if not d.get("trust") is int:
        return _fail("CampData.trust must be int")
    return true

func _assert_enter_camp_returns_data(ctrl: CampController) -> bool:
    var result: CampData = ctrl.enter_camp(&"ch01", {})
    if result == null:
        return _fail("enter_camp() must return a non-null CampData")
    if result.current_chapter != &"ch01":
        return _fail("CampData.current_chapter should be ch01")
    return true

func _assert_summary_keys(ctrl: CampController) -> bool:
    var summary: Dictionary = ctrl.get_camp_summary()
    for key: String in ["chapter", "burden", "trust", "ending_tendency", "recovered_fragments", "unlocked_commands", "unlocked_axes", "pending_notifications", "has_new_records", "memory_entries", "evidence_entries", "letter_entries", "unit_progression_summary"]:
        if not summary.has(key):
            return _fail("get_camp_summary() missing key: %s" % key)
    return true

func _assert_unit_progression_summary(ctrl: CampController) -> bool:
    var progression: ProgressionData = ProgressionData.new()
    progression.set_unit_progress(&"ally_rian", 2, 4)
    progression.set_unit_progress(&"ally_serin", 3, 1)
    ctrl.enter_camp(&"ch01", {}, progression)
    var summary: Dictionary = ctrl.get_camp_summary()
    var progression_summary: Array = summary.get("unit_progression_summary", [])
    if progression_summary.size() != 2:
        return _fail("unit_progression_summary should expose two compact unit entries")
    if String(progression_summary[0]).find("Lv") == -1 or String(progression_summary[0]).find("EXP") == -1:
        return _fail("unit_progression_summary entries should expose compact level/exp text")
    return true

func _assert_notification_count(ctrl: CampController) -> bool:
    var result: CampData = ctrl.enter_camp(&"ch01", {
        "memory_entries": ["mem_frag_ch01_first_order"],
        "evidence_entries": ["flag_evidence_hardren_seal"],
        "letter_entries": []
    })
    if result.get_notification_count() != 2:
        return _fail("Notification count should be 2, got %d" % result.get_notification_count())
    if not result.has_pending_notifications():
        return _fail("has_pending_notifications() should be true")
    return true

func _assert_base_axes(ctrl: CampController) -> bool:
    var result: CampData = ctrl.enter_camp(&"ch01", {})
    # ch01: sortie + equipment + records + save = 4
    if result.unlocked_axes.size() != 4:
        return _fail("ch01 should have 4 base axes, got %d" % result.unlocked_axes.size())
    if not result.unlocked_axes.has(&"sortie"):
        return _fail("sortie must be in base axes")
    if not result.unlocked_axes.has(&"equipment"):
        return _fail("equipment must be in base axes")
    if not result.unlocked_axes.has(&"records"):
        return _fail("records must be in base axes")
    if not result.unlocked_axes.has(&"save"):
        return _fail("save must be in base axes")
    return true

func _assert_extended_axes(ctrl: CampController) -> bool:
    var result: CampData = ctrl.enter_camp(&"ch06", {})
    # ch06: base(4) + storage + dismantle + forge = 7
    if result.unlocked_axes.size() != 7:
        return _fail("ch06 should have 7 axes, got %d" % result.unlocked_axes.size())
    if not result.unlocked_axes.has(&"forge"):
        return _fail("forge must be unlocked at ch06")
    # recall unlocks at ch08
    if result.unlocked_axes.has(&"recall"):
        return _fail("recall should not be unlocked at ch06")
    return true

func _assert_exit_clears_data(ctrl: CampController) -> bool:
    ctrl.enter_camp(&"ch02", {})
    ctrl.exit_camp()
    var summary: Dictionary = ctrl.get_camp_summary()
    if not summary.is_empty():
        return _fail("get_camp_summary() should return empty dict after exit_camp()")
    return true

func _assert_event_log(ctrl: CampController) -> bool:
    ctrl.enter_camp(&"ch03", {})
    ctrl.exit_camp()
    var log: Array[Dictionary] = ctrl.get_event_log()
    var entered: bool = false
    var exited: bool = false
    for entry: Dictionary in log:
        if entry.get("event") == "camp_entered":
            entered = true
        if entry.get("event") == "camp_exited":
            exited = true
    if not entered:
        return _fail("event log must contain camp_entered")
    if not exited:
        return _fail("event log must contain camp_exited")
    return true

func _fail(msg: String) -> bool:
    print("[FAIL] ", msg)
    _failed = true
    quit(1)
    return false
