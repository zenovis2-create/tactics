class_name TitleScreen
extends Control

## 타이틀 화면
## - 새 게임 시작
## - 불러오기 → SaveLoadPanel (로드 모드)

const SaveLoadPanel = preload("res://scripts/ui/save_load_panel.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")

signal new_game_requested
signal load_game_requested(slot: int)

var save_service: SaveService = null
var _save_panel: SaveLoadPanel = null
var _load_available: bool = false

@onready var new_game_button: Button = $Panel/Content/NewGameButton if has_node("Panel/Content/NewGameButton") else null
@onready var load_button: Button = $Panel/Content/LoadButton if has_node("Panel/Content/LoadButton") else null
@onready var title_label: Label = $Panel/Content/TitleLabel if has_node("Panel/Content/TitleLabel") else null

func _ready() -> void:
    if new_game_button != null:
        new_game_button.pressed.connect(_on_new_game_pressed)
    if load_button != null:
        load_button.pressed.connect(_on_load_pressed)
    _check_load_available()

func setup_save_service(svc: SaveService) -> void:
    save_service = svc
    _check_load_available()

func get_layout_snapshot() -> Dictionary:
    return {
        "visible": visible,
        "load_button_enabled": _load_available,
        "save_service_connected": save_service != null
    }

# --- Private ---

func _check_load_available() -> void:
    _load_available = false
    if save_service != null:
        for i in 3:
            if save_service.slot_exists(i):
                _load_available = true
                break
    if load_button != null:
        load_button.disabled = not _load_available

func _on_new_game_pressed() -> void:
    new_game_requested.emit()

func _on_load_pressed() -> void:
    # 가장 최근 슬롯 자동 선택 (슬롯 0 = 자동저장 우선)
    if save_service != null:
        for i in 3:
            if save_service.slot_exists(i):
                load_game_requested.emit(i)
                return
    load_game_requested.emit(0)
