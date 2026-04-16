extends SceneTree

## 5-E: 저장/불러오기 UI 흐름 검증 러너
## - SaveLoadPanel 필드/메서드 확인
## - get_layout_snapshot() 키 검증
## - save_service null 처리 확인
## - save → load → burden/trust/fragment 일치 확인
## - delete_slot() 후 slot_exists() = false
## - peek_slot() 슬롯 메타데이터 계약 확인

const SaveLoadPanel = preload("res://scripts/ui/save_load_panel.gd")
const SAVE_LOAD_PANEL_SCENE: PackedScene = preload("res://scenes/ui/SaveLoadPanel.tscn")
const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

const REQUIRED_SLOT_METADATA_KEYS := [
    "exists",
    "chapter",
    "burden",
    "trust",
    "ending_tendency",
    "saved_at"
]

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var panel: SaveLoadPanel = SAVE_LOAD_PANEL_SCENE.instantiate() as SaveLoadPanel
    root.add_child(panel)
    var svc: SaveService = SaveService.new()
    root.add_child(svc)
    await process_frame

    for slot: int in SaveLoadPanel.SLOT_COUNT:
        svc.delete_slot(slot)

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
    for key: String in ["mode", "visible", "slot_count", "save_service_connected", "pending_delete_slot"]:
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
    data.unlocked_commands[&"tactical_shift"] = true
    data.ending_tendency = &"undetermined"
    data.unit_progression["ally_rian"] = {"level": 2, "exp": 4}
    data.snapshot_unlock_state()

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
    var rian_progress: Dictionary = loaded.get_unit_progress(&"ally_rian")
    if int(rian_progress.get("level", 0)) != 2 or int(rian_progress.get("exp", -1)) != 4:
        return _fail("unit progression should survive save/load")
    if not loaded.get_recently_recovered_fragments().is_empty():
        return _fail("saved unlock snapshots should prevent loaded fragments from appearing newly recovered")
    if not loaded.get_newly_unlocked_commands().is_empty():
        return _fail("saved unlock snapshots should prevent loaded commands from appearing newly unlocked")
    return true

func _assert_delete(svc: SaveService) -> bool:
    var panel: SaveLoadPanel = SAVE_LOAD_PANEL_SCENE.instantiate() as SaveLoadPanel
    root.add_child(panel)
    panel.save_service = svc
    var data: ProgressionData = ProgressionData.new()
    data.burden = 4
    data.trust = 6
    data.ending_tendency = &"true_ending"
    svc.save_progression(data, 1)
    panel.open_save_mode()
    panel._on_delete_pressed(1)
    if not svc.slot_exists(1):
        return _fail("slot 1 should survive the first delete press until confirmation")
    if int(panel.get_layout_snapshot().get("pending_delete_slot", -1)) != 1:
        return _fail("first delete press should arm the pending delete slot")
    var slot_card: Control = panel.slot_cards.get_node_or_null("SlotCard1") if panel.slot_cards != null else null
    var card_label: Label = slot_card.get_child(0) as Label if slot_card != null and slot_card.get_child_count() > 0 else null
    if card_label == null or card_label.text.find("true_ending") == -1:
        return _fail("slot card summary should expose ending_tendency for saved slots")
    panel._on_delete_pressed(1)
    if svc.slot_exists(1):
        return _fail("slot 1 should not exist after delete")
    panel.queue_free()
    return true

func _assert_peek_structure(svc: SaveService) -> bool:
    # 없는 슬롯도 UI가 소비하는 메타데이터 계약을 유지해야 함
    var info: Dictionary = svc.peek_slot(2)
    if not _assert_slot_metadata(info, false, "", 0, 0, "undetermined", false):
        return false

    # 저장 후 peek
    var data: ProgressionData = ProgressionData.new()
    data.burden = 1
    data.trust = 2
    data.ending_tendency = &"bad_ending"
    svc.save_progression(data, 2)
    info = svc.peek_slot(2)
    if not _assert_slot_metadata(info, true, "", 1, 2, "bad_ending", true):
        return false
    var info_again: Dictionary = svc.peek_slot(2)
    if String(info_again.get("saved_at", "")) != String(info.get("saved_at", "")):
        return _fail("peek_slot should return deterministic saved_at between reads")
    svc.delete_slot(2)
    return true

func _assert_panel_with_service(panel: SaveLoadPanel, svc: SaveService) -> bool:
    panel.save_service = svc
    var snap: Dictionary = panel.get_layout_snapshot()
    if not bool(snap.get("save_service_connected", false)):
        return _fail("save_service_connected should be true when service is set")
    panel.open_save_mode()
    panel.refresh_slots()
    var slot_info: Dictionary = panel.get_slot_info(0)
    if not _assert_slot_metadata(slot_info, false, "", 0, 0, "undetermined", false):
        return false
    panel.close()
    return true

func _assert_slot_metadata(
	info: Dictionary,
	exists: bool,
	chapter: String,
	burden: int,
	trust: int,
	ending_tendency: String,
	require_saved_at: bool
) -> bool:
    for key: String in REQUIRED_SLOT_METADATA_KEYS:
        if not info.has(key):
            return _fail("slot metadata missing key: %s" % key)
    if bool(info.get("exists", not exists)) != exists:
        return _fail("slot metadata exists should be %s" % String.num_int64(int(exists)))
    if String(info.get("chapter", "")) != chapter:
        return _fail("slot metadata chapter should be '%s', got '%s'" % [chapter, String(info.get("chapter", ""))])
    if int(info.get("burden", -1)) != burden:
        return _fail("slot metadata burden should be %d, got %d" % [burden, int(info.get("burden", -1))])
    if int(info.get("trust", -1)) != trust:
        return _fail("slot metadata trust should be %d, got %d" % [trust, int(info.get("trust", -1))])
    if String(info.get("ending_tendency", "")) != ending_tendency:
        return _fail("slot metadata ending_tendency should be '%s', got '%s'" % [ending_tendency, String(info.get("ending_tendency", ""))])
    var saved_at := String(info.get("saved_at", ""))
    if require_saved_at and saved_at.is_empty():
        return _fail("slot metadata saved_at should be non-empty for existing saves")
    if not require_saved_at and not saved_at.is_empty():
        return _fail("slot metadata saved_at should be empty for missing saves")
    return true

func _fail(msg: String) -> bool:
    print("[FAIL] ", msg)
    _failed = true
    quit(1)
    return false
