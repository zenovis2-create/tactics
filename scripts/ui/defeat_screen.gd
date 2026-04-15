class_name DefeatScreen
extends Control

## 패배 화면
## - 재시도 (현재 스테이지 재시작)
## - 마지막 저장으로 (슬롯 0 자동로드)
## - 타이틀로 돌아가기

const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

signal retry_requested
signal load_last_save_requested(data: ProgressionData)
signal title_requested

var save_service: SaveService = null
var _autosave_available: bool = false

@onready var retry_button: Button = $Panel/Content/RetryButton if has_node("Panel/Content/RetryButton") else null
@onready var load_save_button: Button = $Panel/Content/LoadSaveButton if has_node("Panel/Content/LoadSaveButton") else null
@onready var title_button: Button = $Panel/Content/TitleButton if has_node("Panel/Content/TitleButton") else null
@onready var round_label: Label = $Panel/Content/RoundLabel if has_node("Panel/Content/RoundLabel") else null

func _ready() -> void:
    if retry_button != null:
        retry_button.pressed.connect(_on_retry_pressed)
    if load_save_button != null:
        load_save_button.pressed.connect(_on_load_save_pressed)
    if title_button != null:
        title_button.pressed.connect(_on_title_pressed)
    hide()

func show_defeat(round_count: int = 0) -> void:
    if round_label != null:
        round_label.text = "%d 라운드 후 패배" % round_count
    _update_load_button()
    visible = true

func setup_save_service(svc: SaveService) -> void:
    save_service = svc
    _update_load_button()

func get_layout_snapshot() -> Dictionary:
    return {
        "visible": visible,
        "load_save_button_enabled": _autosave_available,
        "save_service_connected": save_service != null
    }

# --- Private ---

func _update_load_button() -> void:
    _autosave_available = false
    if save_service != null:
        _autosave_available = save_service.slot_exists(0)
    if load_save_button != null:
        load_save_button.disabled = not _autosave_available

func _on_retry_pressed() -> void:
    visible = false
    retry_requested.emit()

func _on_load_save_pressed() -> void:
    if save_service == null:
        return
    var data: ProgressionData = save_service.load_progression(0)
    visible = false
    load_last_save_requested.emit(data)

func _on_title_pressed() -> void:
    visible = false
    title_requested.emit()
