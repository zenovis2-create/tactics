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
    "is_autosave",
    "slot_label",
    "chapter",
    "burden",
    "trust",
    "gold",
    "ending_tendency",
    "ng_plus_available",
    "last_completed_ending",
    "ending_resonance_count",
    "ending_name_anchors_ok",
    "ending_all_name_calls",
    "saved_at",
    "unit_progression_summary"
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
    svc.delete_slot(SaveService.AUTOSAVE_SLOT)

    if not _assert_panel_snapshot(panel): return
    if not _assert_null_service_safe(panel): return
    if not _assert_save_and_load(svc): return
    if not _assert_delete(svc): return
    if not _assert_peek_structure(svc): return
    if not _assert_panel_with_service(panel, svc): return
    if not _assert_autosave_surface(panel, svc): return

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
    data.gold = 777
    data.recovered_fragments[&"ch01_fragment"] = true
    data.unlocked_commands[&"tactical_shift"] = true
    data.ending_tendency = &"undetermined"
    data.ng_plus_available = true
    data.last_completed_ending = &"true_ending"
    data.cleared_stage_ids = [&"CH07_05"]
    data.flags["flag_resonance_serin"] = true
    data.flags["flag_resonance_bran"] = true
    data.flags["flag_name_anchors_held_2plus"] = true
    data.unit_progression["ally_rian"] = {"level": 2, "exp": 4}
    data.bond_levels["ally_karl"] = 5
    data.support_ranks["rian_karl"] = 3
    data.shared_battles["rian_karl"] = 10
    data.unit_progression["ally_serin"] = {"level": 3, "exp": 1}
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
    if int(loaded.gold) != 777:
        return _fail("Loaded gold should be 777, got %d" % int(loaded.gold))
    if not bool(loaded.recovered_fragments.get(&"ch01_fragment", false)):
        return _fail("ch01_fragment should be in loaded data")
    var rian_progress: Dictionary = loaded.get_unit_progress(&"ally_rian")
    if int(rian_progress.get("level", 0)) != 2 or int(rian_progress.get("exp", -1)) != 4:
        return _fail("unit progression should survive save/load")
    if loaded.get_bond_level(&"ally_kyle") != 5:
        return _fail("legacy ally_karl bond should migrate to ally_kyle")
    if loaded.get_support_rank("rian_kyle") != 3:
        return _fail("legacy rian_karl support rank should migrate to rian_kyle")
    if loaded.get_shared_battle_count("rian_kyle") != 10:
        return _fail("legacy rian_karl shared battles should migrate to rian_kyle")
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
    if int(panel.get_layout_snapshot().get("pending_delete_slot", -1)) != 1:
        return _fail("first delete press should arm the pending delete slot")
    var slot_card: Control = panel.slot_cards.get_node_or_null("SlotCard1") if panel.slot_cards != null else null
    var rendered_text := ""
    if slot_card != null:
        for node in slot_card.find_children("*", "Label", true, false):
            rendered_text += " " + String((node as Label).text)
    if rendered_text.find("true_ending") == -1:
        return _fail("slot card summary should expose ending_tendency for saved slots")
    panel._on_delete_pressed(1)
    if svc.slot_exists(1):
        return _fail("slot 1 should not exist after delete")
    panel.queue_free()
    return true

func _assert_peek_structure(svc: SaveService) -> bool:
    # 없는 슬롯도 UI가 소비하는 메타데이터 계약을 유지해야 함
    var info: Dictionary = svc.peek_slot(2)
    if not _assert_slot_metadata(info, false, "", 0, 0, 0, "undetermined", false, "", false):
        return false

    # 저장 후 peek
    var data: ProgressionData = ProgressionData.new()
    data.burden = 1
    data.trust = 2
    data.gold = 345
    data.ending_tendency = &"bad_ending"
    data.ng_plus_available = true
    data.last_completed_ending = &"true_ending"
    data.cleared_stage_ids = [&"CH09B_05"]
    data.flags["flag_resonance_serin"] = true
    data.flags["flag_resonance_bran"] = true
    data.flags["flag_name_anchors_held_2plus"] = true
    svc.save_progression(data, 2)
    info = svc.peek_slot(2)
    if not _assert_slot_metadata(info, true, "CH09B", 1, 2, 345, "bad_ending", true, "true_ending", true):
        return false
    if String(info.get("unit_progression_summary", "")) != "":
        return _fail("slot metadata without unit progression should keep progression summary empty")
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
    var data: ProgressionData = ProgressionData.new()
    data.burden = 2
    data.trust = 4
    data.gold = 555
    data.cleared_stage_ids = [&"CH10_05"]
    data.last_completed_ending = &"true_ending"
    data.ng_plus_available = true
    data.flags["flag_resonance_serin"] = true
    data.flags["flag_resonance_bran"] = true
    data.flags["flag_name_anchors_held_2plus"] = true
    svc.save_progression(data, 0)
    panel.open_save_mode()
    panel.refresh_slots()
    var slot_info: Dictionary = svc.peek_slot(0)
    if not _assert_slot_metadata(slot_info, true, "CH10", 2, 4, 555, "undetermined", true, "true_ending", true):
        return false
    var slot_card: Control = panel.slot_cards.get_node_or_null("SlotCard0") if panel.slot_cards != null else null
    var rendered_text := ""
    if slot_card != null:
        for node in slot_card.find_children("*", "Label", true, false):
            rendered_text += " " + String((node as Label).text)
    if rendered_text.find("CH10") == -1 or rendered_text.find("공명") == -1:
        return _fail("slot thumbnail should surface chapter and resonance state for populated saves.")
    panel.close()
    svc.delete_slot(0)
    return true

func _assert_autosave_surface(panel: SaveLoadPanel, svc: SaveService) -> bool:
    var data: ProgressionData = ProgressionData.new()
    data.burden = 6
    data.trust = 8
    data.gold = 999
    data.cleared_stage_ids = [&"CH08_05"]
    svc.save_progression(data, SaveService.AUTOSAVE_SLOT, {"autosave_reason": "CH08 흑견 교대"})
    var info: Dictionary = svc.peek_slot(SaveService.AUTOSAVE_SLOT)
    if not bool(info.get("is_autosave", false)):
        return _fail("autosave metadata should set is_autosave")
    if String(info.get("slot_label", "")) != "자동저장":
        return _fail("autosave metadata should expose slot_label as 자동저장")
    panel.save_service = svc
    panel.open_load_mode()
    panel.refresh_slots()
    var autosave_card: Control = panel.slot_cards.get_node_or_null("AutosaveCard") if panel.slot_cards != null else null
    if autosave_card == null:
        return _fail("load mode should render a dedicated autosave card")
    var rendered_text := ""
    for node in autosave_card.find_children("*", "Label", true, false):
        rendered_text += " " + String((node as Label).text)
    if rendered_text.find("자동저장") == -1 or rendered_text.find("CH08") == -1:
        return _fail("autosave card should surface autosave label and chapter")
    if rendered_text.find("AUTO") == -1:
        return _fail("autosave card should surface an AUTO badge in load mode")
    if rendered_text.find("이어하기") == -1:
        return _fail("autosave card should surface the recommended-continue badge when it is the latest save.")
    if rendered_text.find("CH08 흑견 교대") == -1:
        return _fail("autosave card should surface checkpoint reason in load mode")
    var panel_snapshot: Dictionary = panel.get_layout_snapshot()
    if not bool(panel_snapshot.get("recommended_load_is_autosave", false)):
        return _fail("load panel should mark autosave as the recommended load target when it is freshest.")
    svc.delete_slot(SaveService.AUTOSAVE_SLOT)
    return true

func _assert_slot_metadata(
    info: Dictionary,
    exists: bool,
    chapter: String,
    burden: int,
    trust: int,
    gold: int,
    ending_tendency: String,
    require_saved_at: bool,
    last_completed_ending: String,
    ng_plus_available: bool
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
    if int(info.get("gold", -1)) != gold:
        return _fail("slot metadata gold should be %d, got %d" % [gold, int(info.get("gold", -1))])
    if String(info.get("ending_tendency", "")) != ending_tendency:
        return _fail("slot metadata ending_tendency should be '%s', got '%s'" % [ending_tendency, String(info.get("ending_tendency", ""))])
    if String(info.get("last_completed_ending", "")) != last_completed_ending:
        return _fail("slot metadata last_completed_ending should be '%s', got '%s'" % [last_completed_ending, String(info.get("last_completed_ending", ""))])
    if bool(info.get("ng_plus_available", not ng_plus_available)) != ng_plus_available:
        return _fail("slot metadata ng_plus_available should be %s" % String.num_int64(int(ng_plus_available)))
    if not exists and int(info.get("ending_resonance_count", -1)) != 0:
        return _fail("slot metadata ending_resonance_count should default to 0 for empty slots")
    if exists and int(info.get("ending_resonance_count", -1)) < 2:
        return _fail("slot metadata ending_resonance_count should reflect persisted resonance progress")
    var saved_at := String(info.get("saved_at", ""))
    if not info.has("unit_progression_summary"):
        return _fail("slot metadata missing unit_progression_summary")
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
