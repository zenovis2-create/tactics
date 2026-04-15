extends SceneTree

## 5-E: 저장/불러오기 UI 흐름 검증 러너
## - SaveLoadPanel 필드/메서드 확인
## - get_layout_snapshot() 키 검증
## - save_service null 처리 확인
## - save → load → burden/trust/fragment 일치 확인
## - delete_slot() 후 slot_exists() = false
## - peek_slot() 슬롯 정보 구조 확인

const SaveLoadPanel = preload("res://scripts/ui/save_load_panel.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var panel: SaveLoadPanel = SaveLoadPanel.new()
    root.add_child(panel)
    var svc: SaveService = SaveService.new()
    root.add_child(svc)
    await process_frame

    if not _assert_panel_snapshot(panel): return
    if not _assert_null_service_safe(panel): return
    if not _assert_save_and_load(svc): return
    if not _assert_delete(svc): return
    if not _assert_peek_structure(svc): return
    if not _assert_panel_with_service(panel, svc): return

    print("[PASS] save_load_runner: all assertions passed.")
    quit(0)

# --- Assertions ---

func _assert_panel_snapshot(panel: SaveLoadPanel) -> bool:
    var snap: Dictionary = panel.get_layout_snapshot()
    for key: String in ["mode", "visible", "slot_count", "save_service_connected"]:
        if not snap.has(key):
            return _fail("snapshot missing key: %s" % key)
    if int(snap.get("slot_count", 0)) != 3:
        return _fail("slot_count should be 3")
    return true

func _assert_null_service_safe(panel: SaveLoadPanel) -> bool:
    panel.save_service = null
    panel.open_save_mode()
    # null 서비스면 슬롯 카드가 안 만들어지지만 크래시 없어야 함
    panel.refresh_slots()  # 크래시 없으면 통과
    panel.close()
    return true

func _assert_save_and_load(svc: SaveService) -> bool:
    var data: ProgressionData = ProgressionData.new()
    data.burden = 3
    data.trust = 5
    data.recovered_fragments[&"ch01_fragment"] = true
    data.ending_tendency = &"undetermined"

    var err: Error = svc.save_progression(data, 1)
    if err != OK:
        return _fail("save_progression should return OK")

    if not svc.slot_exists(1):
        return _fail("slot 1 should exist after save")

    var loaded: ProgressionData = svc.load_progression(1)
    if loaded == null:
        return _fail("load_progression should return ProgressionData")
    if int(loaded.burden) != 3:
        return _fail("Loaded burden should be 3, got %d" % int(loaded.burden))
    if int(loaded.trust) != 5:
        return _fail("Loaded trust should be 5, got %d" % int(loaded.trust))
    if not bool(loaded.recovered_fragments.get(&"ch01_fragment", false)):
        return _fail("ch01_fragment should be in loaded data")
    return true

func _assert_delete(svc: SaveService) -> bool:
    svc.delete_slot(1)
    if svc.slot_exists(1):
        return _fail("slot 1 should not exist after delete")
    return true

func _assert_peek_structure(svc: SaveService) -> bool:
    # 없는 슬롯은 빈 dict 반환
    var info: Dictionary = svc.peek_slot(2)
    if not info.is_empty() and not info.has("exists"):
        return _fail("peek_slot for non-existent slot should return empty or dict with 'exists'")

    # 저장 후 peek
    var data: ProgressionData = ProgressionData.new()
    data.burden = 1
    data.trust = 2
    svc.save_progression(data, 2)
    info = svc.peek_slot(2)
    if info.is_empty():
        return _fail("peek_slot should return non-empty dict after save")
    svc.delete_slot(2)
    return true

func _assert_panel_with_service(panel: SaveLoadPanel, svc: SaveService) -> bool:
    panel.save_service = svc
    var snap: Dictionary = panel.get_layout_snapshot()
    if not bool(snap.get("save_service_connected", false)):
        return _fail("save_service_connected should be true when service is set")
    panel.open_save_mode()
    panel.refresh_slots()
    panel.close()
    return true

func _fail(msg: String) -> bool:
    print("[FAIL] ", msg)
    _failed = true
    quit(1)
    return false
