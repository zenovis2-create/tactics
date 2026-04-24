class_name TitleScreen
extends Control

## 타이틀 화면
## - 새 게임 시작
## - 불러오기 → SaveLoadPanel (로드 모드)

const SaveLoadPanel = preload("res://scripts/ui/save_load_panel.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")

signal new_game_requested
signal new_game_plus_requested
signal load_game_requested(slot: int)
signal load_panel_requested

var save_service: SaveService = null
var _save_panel: SaveLoadPanel = null
var _load_available: bool = false
var _ng_plus_available: bool = false
var _ending_resonance_count: int = 0
var _ending_name_anchors_ok: bool = false
var _ending_all_name_calls: bool = false
var _postgame_source_label: String = ""
var _postgame_source_reason: String = ""

@onready var new_game_button: Button = $Panel/Content/NewGameButton if has_node("Panel/Content/NewGameButton") else null
@onready var new_game_plus_button: Button = $Panel/Content/NewGamePlusButton if has_node("Panel/Content/NewGamePlusButton") else null
@onready var load_button: Button = $Panel/Content/LoadButton if has_node("Panel/Content/LoadButton") else null
@onready var title_label: Label = $Panel/Content/TitleLabel if has_node("Panel/Content/TitleLabel") else null
@onready var postgame_badge_label: Label = $Panel/Content/PostgameBadgeLabel if has_node("Panel/Content/PostgameBadgeLabel") else null
@onready var postgame_summary_label: Label = $Panel/Content/PostgameSummaryLabel if has_node("Panel/Content/PostgameSummaryLabel") else null
@onready var ng_plus_summary_dialog: ConfirmationDialog = $NGPlusSummaryDialog if has_node("NGPlusSummaryDialog") else null

var _last_completed_ending: StringName = &""

func _ready() -> void:
    if new_game_button != null:
        new_game_button.pressed.connect(_on_new_game_pressed)
    if new_game_plus_button != null:
        new_game_plus_button.pressed.connect(_on_new_game_plus_pressed)
    if load_button != null:
        load_button.pressed.connect(_on_load_pressed)
    if ng_plus_summary_dialog != null:
        ng_plus_summary_dialog.confirmed.connect(_on_new_game_plus_confirmed)
    _check_load_available()
    _check_ng_plus_available()

func setup_save_service(svc: SaveService) -> void:
    save_service = svc
    _check_load_available()
    _check_ng_plus_available()

func setup_load_panel(panel: SaveLoadPanel) -> void:
    _save_panel = panel

func get_layout_snapshot() -> Dictionary:
    return {
        "visible": visible,
        "load_button_enabled": _load_available,
        "ng_plus_available": _ng_plus_available,
        "ng_plus_button_visible": new_game_plus_button.visible if new_game_plus_button != null else _ng_plus_available,
        "save_service_connected": save_service != null,
        "last_completed_ending": String(_last_completed_ending),
        "postgame_summary_visible": postgame_summary_label.visible if postgame_summary_label != null else false,
        "ending_resonance_count": _ending_resonance_count,
        "ending_name_anchors_ok": _ending_name_anchors_ok,
        "ending_all_name_calls": _ending_all_name_calls,
        "postgame_source_label": _postgame_source_label,
        "postgame_source_reason": _postgame_source_reason
    }

# --- Private ---

func _check_load_available() -> void:
    _load_available = false
    if save_service != null:
        for i in SaveService.MANUAL_SLOT_COUNT:
            if save_service.slot_exists(i):
                _load_available = true
                break
        if not _load_available and save_service.slot_exists(SaveService.AUTOSAVE_SLOT):
            _load_available = true
    if load_button != null:
        load_button.disabled = not _load_available

func _check_ng_plus_available() -> void:
    _ng_plus_available = false
    _last_completed_ending = &""
    _ending_resonance_count = 0
    _ending_name_anchors_ok = false
    _ending_all_name_calls = false
    _postgame_source_label = ""
    _postgame_source_reason = ""
    if save_service != null:
        var best_saved_at: String = ""
        for i in SaveService.MANUAL_SLOT_COUNT:
            if not save_service.slot_exists(i):
                continue
            var slot_metadata: Dictionary = save_service.peek_slot(i)
            if not bool(slot_metadata.get("ng_plus_available", false)):
                continue
            var saved_at: String = String(slot_metadata.get("saved_at", ""))
            if _ng_plus_available and saved_at <= best_saved_at:
                continue
            _ng_plus_available = true
            best_saved_at = saved_at
            _last_completed_ending = StringName(String(slot_metadata.get("last_completed_ending", "")))
            _ending_resonance_count = int(slot_metadata.get("ending_resonance_count", 0))
            _ending_name_anchors_ok = bool(slot_metadata.get("ending_name_anchors_ok", false))
            _ending_all_name_calls = bool(slot_metadata.get("ending_all_name_calls", false))
            _postgame_source_label = "수동저장"
            _postgame_source_reason = String(slot_metadata.get("autosave_reason", "")).strip_edges()
        if save_service.slot_exists(SaveService.AUTOSAVE_SLOT):
            var autosave_metadata: Dictionary = save_service.peek_slot(SaveService.AUTOSAVE_SLOT)
            if bool(autosave_metadata.get("ng_plus_available", false)):
                var autosave_saved_at: String = String(autosave_metadata.get("saved_at", ""))
                if not _ng_plus_available or autosave_saved_at > best_saved_at:
                    _ng_plus_available = true
                    _last_completed_ending = StringName(String(autosave_metadata.get("last_completed_ending", "")))
                    _ending_resonance_count = int(autosave_metadata.get("ending_resonance_count", 0))
                    _ending_name_anchors_ok = bool(autosave_metadata.get("ending_name_anchors_ok", false))
                    _ending_all_name_calls = bool(autosave_metadata.get("ending_all_name_calls", false))
                    _postgame_source_label = "자동저장"
                    _postgame_source_reason = String(autosave_metadata.get("autosave_reason", "")).strip_edges()
    if new_game_plus_button != null:
        new_game_plus_button.visible = _ng_plus_available
        new_game_plus_button.disabled = not _ng_plus_available
    _refresh_postgame_surface()

func _on_new_game_pressed() -> void:
    new_game_requested.emit()

func _on_new_game_plus_pressed() -> void:
    if not _ng_plus_available:
        return
    if ng_plus_summary_dialog != null:
        ng_plus_summary_dialog.popup_centered()
        return
    new_game_plus_requested.emit()

func _on_new_game_plus_confirmed() -> void:
    new_game_plus_requested.emit()

func _refresh_postgame_surface() -> void:
    if postgame_badge_label != null:
        postgame_badge_label.visible = _ng_plus_available
    if postgame_summary_label == null:
        return
    postgame_summary_label.visible = _ng_plus_available
    if not _ng_plus_available:
        postgame_summary_label.text = ""
        return
    var ending_label: String = "일반 결말"
    if _last_completed_ending == &"true_ending":
        ending_label = "진엔딩"
    postgame_summary_label.text = "최근 결말: %s\n공명 인장 %d/6 / 이름 앵커 %s / 이름 부름 %s\nNG+가 해금되었고 인연 레벨이 다음 회차로 이어진다." % [
        ending_label,
        _ending_resonance_count,
        "완료" if _ending_name_anchors_ok else "미완",
        "완료" if _ending_all_name_calls else "미완"
    ]
    if not _postgame_source_label.is_empty():
        postgame_summary_label.text += "\n기준 저장: %s" % _postgame_source_label
    if not _postgame_source_reason.is_empty():
        postgame_summary_label.text += " (%s)" % _postgame_source_reason

func _on_load_pressed() -> void:
    if _load_available and _save_panel != null:
        _save_panel.open_load_mode()
        load_panel_requested.emit()
        return

    # fallback: save panel 미연결 시 자동저장을 우선하고, 없으면 수동 슬롯 중 첫 번째를 연다.
    if save_service != null:
        if save_service.slot_exists(SaveService.AUTOSAVE_SLOT):
            load_game_requested.emit(SaveService.AUTOSAVE_SLOT)
            return
        for i in SaveService.MANUAL_SLOT_COUNT:
            if save_service.slot_exists(i):
                load_game_requested.emit(i)
                return
    load_game_requested.emit(SaveService.AUTOSAVE_SLOT)
