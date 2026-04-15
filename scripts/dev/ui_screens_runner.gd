extends SceneTree

## 타이틀/패배 화면 + 자동저장 검증 러너
## - TitleScreen.get_layout_snapshot() 키 확인
## - TitleScreen: 저장 없으면 load_button disabled
## - TitleScreen: 저장 있으면 load_button enabled
## - DefeatScreen.get_layout_snapshot() 키 확인
## - DefeatScreen: 자동저장(슬롯0) 없으면 load_save_button disabled
## - DefeatScreen: 자동저장 있으면 load_save_button enabled
## - 자동저장 → load_game_requested 시그널 발화 확인 (이벤트 기반)

const TitleScreen = preload("res://scripts/ui/title_screen.gd")
const DefeatScreen = preload("res://scripts/ui/defeat_screen.gd")
const SaveLoadPanel = preload("res://scripts/ui/save_load_panel.gd")
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
    var title: TitleScreen = TitleScreen.new()
    var defeat: DefeatScreen = DefeatScreen.new()
    var panel: SaveLoadPanel = SaveLoadPanel.new()
    var svc: SaveService = SaveService.new()
    root.add_child(title)
    root.add_child(defeat)
    root.add_child(panel)
    root.add_child(svc)
    await process_frame

    panel.save_service = svc
    title.setup_load_panel(panel)

    if not _assert_title_snapshot(title): return
    if not _assert_title_no_save(title, svc): return
    if not _assert_title_with_save(title, svc): return
    if not _assert_defeat_snapshot(defeat): return
    if not _assert_defeat_no_autosave(defeat, svc): return
    if not _assert_defeat_with_autosave(defeat, svc): return
    if not _assert_load_signal_title(title, panel, svc): return

    print("[PASS] ui_screens_runner: all assertions passed.")
    quit(0)

# --- Assertions ---

func _assert_title_snapshot(title: TitleScreen) -> bool:
    var snap: Dictionary = title.get_layout_snapshot()
    for key: String in ["visible", "load_button_enabled", "save_service_connected"]:
        if not snap.has(key):
            return _fail("TitleScreen snapshot missing key: %s" % key)
    return true

func _assert_title_no_save(title: TitleScreen, svc: SaveService) -> bool:
    svc.delete_slot(0)
    svc.delete_slot(1)
    svc.delete_slot(2)
    title.setup_save_service(svc)
    var snap: Dictionary = title.get_layout_snapshot()
    if bool(snap.get("load_button_enabled", true)):
        return _fail("load_button should be disabled when no saves exist")
    return true

func _assert_title_with_save(title: TitleScreen, svc: SaveService) -> bool:
    var data: ProgressionData = ProgressionData.new()
    data.burden = 1
    data.ending_tendency = &"undetermined"
    svc.save_progression(data, 0)
    if not _assert_slot_metadata_contract(svc.peek_slot(0), 1, 0, "undetermined"):
        return false
    title.setup_save_service(svc)
    var snap: Dictionary = title.get_layout_snapshot()
    if not bool(snap.get("load_button_enabled", false)):
        return _fail("load_button should be enabled when a save exists")
    svc.delete_slot(0)
    return true

func _assert_defeat_snapshot(defeat: DefeatScreen) -> bool:
    var snap: Dictionary = defeat.get_layout_snapshot()
    for key: String in ["visible", "load_save_button_enabled", "save_service_connected"]:
        if not snap.has(key):
            return _fail("DefeatScreen snapshot missing key: %s" % key)
    return true

func _assert_defeat_no_autosave(defeat: DefeatScreen, svc: SaveService) -> bool:
    svc.delete_slot(0)
    defeat.setup_save_service(svc)
    defeat.show_defeat(5)
    var snap: Dictionary = defeat.get_layout_snapshot()
    if bool(snap.get("load_save_button_enabled", true)):
        return _fail("load_save_button should be disabled when no autosave exists")
    defeat.hide()
    return true

func _assert_defeat_with_autosave(defeat: DefeatScreen, svc: SaveService) -> bool:
    var data: ProgressionData = ProgressionData.new()
    data.burden = 2
    data.ending_tendency = &"bad_ending"
    svc.save_progression(data, 0)
    if not _assert_slot_metadata_contract(svc.peek_slot(0), 2, 0, "bad_ending"):
        return false
    defeat.setup_save_service(svc)
    defeat.show_defeat(3)
    var snap: Dictionary = defeat.get_layout_snapshot()
    if not bool(snap.get("load_save_button_enabled", false)):
        return _fail("load_save_button should be enabled when autosave exists")
    defeat.hide()
    svc.delete_slot(0)
    return true

func _assert_load_signal_title(title: TitleScreen, panel: SaveLoadPanel, svc: SaveService) -> bool:
    var data: ProgressionData = ProgressionData.new()
    data.trust = 3
    data.ending_tendency = &"true_ending"
    svc.save_progression(data, 0)
    if not _assert_slot_metadata_contract(svc.peek_slot(0), 0, 3, "true_ending"):
        return false
    title.setup_save_service(svc)

    # load_available이 true인 상태에서 _on_load_pressed()가 실제 load panel을 열어야 함
    var snap: Dictionary = title.get_layout_snapshot()
    if not bool(snap.get("load_button_enabled", false)):
        return _fail("load_button should be enabled before calling _on_load_pressed")
    title._on_load_pressed()
    if not panel.visible:
        return _fail("TitleScreen load flow should open the SaveLoadPanel.")
    var panel_snapshot: Dictionary = panel.get_layout_snapshot()
    if String(panel_snapshot.get("mode", "")) != "load":
        return _fail("TitleScreen load flow should open SaveLoadPanel in load mode.")
    panel.close()
    svc.delete_slot(0)
    return true

func _assert_slot_metadata_contract(info: Dictionary, burden: int, trust: int, ending_tendency: String) -> bool:
    for key: String in REQUIRED_SLOT_METADATA_KEYS:
        if not info.has(key):
            return _fail("slot metadata missing key: %s" % key)
    if not bool(info.get("exists", false)):
        return _fail("slot metadata exists should be true for saved slots")
    if String(info.get("chapter", "")) != "":
        return _fail("slot metadata chapter should default to empty string when chapter is unavailable")
    if int(info.get("burden", -1)) != burden:
        return _fail("slot metadata burden should be %d, got %d" % [burden, int(info.get("burden", -1))])
    if int(info.get("trust", -1)) != trust:
        return _fail("slot metadata trust should be %d, got %d" % [trust, int(info.get("trust", -1))])
    if String(info.get("ending_tendency", "")) != ending_tendency:
        return _fail("slot metadata ending_tendency should be '%s', got '%s'" % [ending_tendency, String(info.get("ending_tendency", ""))])
    if String(info.get("saved_at", "")).is_empty():
        return _fail("slot metadata saved_at should be non-empty for saved slots")
    return true

func _fail(msg: String) -> bool:
    print("[FAIL] ", msg)
    _failed = true
    quit(1)
    return false
