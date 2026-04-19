class_name TitleScreen
extends Control

## 타이틀 화면
## - 새 게임 시작
## - 불러오기 → SaveLoadPanel (로드 모드)

const SaveLoadPanel = preload("res://scripts/ui/save_load_panel.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

signal new_game_requested
signal load_game_requested(slot: int)
signal load_panel_requested
signal ng_plus_purchase_requested(item_id: String)

var save_service: SaveService = null
var _save_panel: SaveLoadPanel = null
var _load_available: bool = false
var _progression_data: ProgressionData = null
var _ng_plus_shop_items: Array[Dictionary] = []

@onready var new_game_button: Button = $Panel/Content/NewGameButton if has_node("Panel/Content/NewGameButton") else null
@onready var load_button: Button = $Panel/Content/LoadButton if has_node("Panel/Content/LoadButton") else null
@onready var title_label: Label = $Panel/Content/TitleLabel if has_node("Panel/Content/TitleLabel") else null
@onready var ng_plus_shop_button: Button = $Panel/Content/NGPlusShopButton if has_node("Panel/Content/NGPlusShopButton") else null
@onready var ng_plus_shop_panel: PanelContainer = $Panel/Content/NGPlusShopPanel if has_node("Panel/Content/NGPlusShopPanel") else null
@onready var ng_plus_badge_label: Label = $Panel/Content/NGPlusShopPanel/Margin/Stack/BadgeLabel if has_node("Panel/Content/NGPlusShopPanel/Margin/Stack/BadgeLabel") else null
@onready var ng_plus_shop_list: VBoxContainer = $Panel/Content/NGPlusShopPanel/Margin/Stack/ItemList if has_node("Panel/Content/NGPlusShopPanel/Margin/Stack/ItemList") else null
@onready var ng_plus_hint_label: Label = $Panel/Content/NGPlusShopPanel/Margin/Stack/HintLabel if has_node("Panel/Content/NGPlusShopPanel/Margin/Stack/HintLabel") else null

func _ready() -> void:
    if new_game_button != null:
        new_game_button.pressed.connect(_on_new_game_pressed)
    if load_button != null:
        load_button.pressed.connect(_on_load_pressed)
    if ng_plus_shop_button != null:
        ng_plus_shop_button.pressed.connect(_on_ng_plus_shop_pressed)
    _check_load_available()
    _refresh_ng_plus_shop()

func setup_save_service(svc: SaveService) -> void:
    save_service = svc
    _check_load_available()

func setup_load_panel(panel: SaveLoadPanel) -> void:
    _save_panel = panel

func setup_ng_plus_shop(progression: ProgressionData, shop_items: Array[Dictionary]) -> void:
    _progression_data = progression
    _ng_plus_shop_items = shop_items.duplicate(true)
    _refresh_ng_plus_shop()

func get_layout_snapshot() -> Dictionary:
    return {
        "visible": visible,
        "load_button_enabled": _load_available,
        "save_service_connected": save_service != null,
        "ng_plus_button_visible": ng_plus_shop_button != null and ng_plus_shop_button.visible,
        "ng_plus_badges": int(_progression_data.badges_of_heroism) if _progression_data != null else 0
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
    if _load_available and _save_panel != null:
        _save_panel.open_load_mode()
        load_panel_requested.emit()
        return

    # fallback: save panel 미연결 시 가장 최근 슬롯 자동 선택 (슬롯 0 = 자동저장 우선)
    if save_service != null:
        for i in 3:
            if save_service.slot_exists(i):
                load_game_requested.emit(i)
                return
    load_game_requested.emit(0)

func _on_ng_plus_shop_pressed() -> void:
    if ng_plus_shop_panel == null:
        return
    ng_plus_shop_panel.visible = not ng_plus_shop_panel.visible

func _refresh_ng_plus_shop() -> void:
    var badges: int = int(_progression_data.badges_of_heroism) if _progression_data != null else 0
    if ng_plus_shop_button != null:
        ng_plus_shop_button.visible = badges > 0
        ng_plus_shop_button.text = "NG+ Shop (%d)" % badges
    if ng_plus_shop_panel == null:
        return
    if badges <= 0:
        ng_plus_shop_panel.visible = false
    if ng_plus_badge_label != null:
        ng_plus_badge_label.text = "Badges of Heroism: %d" % badges
    if ng_plus_hint_label != null:
        ng_plus_hint_label.text = "Purchase a Divine Currency bonus before starting a new run."
    if ng_plus_shop_list == null:
        return
    for child in ng_plus_shop_list.get_children():
        child.queue_free()
    for item: Dictionary in _ng_plus_shop_items:
        var item_id: String = String(item.get("id", ""))
        var item_name: String = String(item.get("name", item_id))
        var cost: int = int(item.get("cost", 0))
        var description: String = String(item.get("description", ""))
        var purchased: bool = _progression_data != null and _progression_data.has_ng_plus_purchase(item_id)
        var affordable: bool = badges >= cost

        var row := HBoxContainer.new()
        row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

        var button := Button.new()
        button.custom_minimum_size = Vector2(180, 36)
        button.text = "%s (%d)" % [item_name, cost]
        button.disabled = purchased or not affordable
        if purchased:
            button.text = "%s (Purchased)" % item_name
        elif not affordable:
            button.modulate = Color(0.65, 0.65, 0.65, 1.0)
        button.pressed.connect(func() -> void:
            ng_plus_purchase_requested.emit(item_id)
        )

        var label := Label.new()
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        label.text = description
        if purchased:
            label.text += " [Owned]"
        elif not affordable:
            label.modulate = Color(0.7, 0.7, 0.7, 1.0)

        row.add_child(button)
        row.add_child(label)
        ng_plus_shop_list.add_child(row)
