class_name CampHud
extends Control

## 캠프 허브 HUD — 7개 축 탭 전환 + 활성 패널 표시/숨김
## CampaignPanel의 Records/Party/Inventory 섹션과 연동

const CampData = preload("res://scripts/data/camp_data.gd")

const TAB_SORTIE: StringName = &"sortie"
const TAB_EQUIPMENT: StringName = &"equipment"
const TAB_RECORDS: StringName = &"records"
const TAB_STORAGE: StringName = &"storage"
const TAB_DISMANTLE: StringName = &"dismantle"
const TAB_FORGE: StringName = &"forge"
const TAB_RECALL: StringName = &"recall"

const TAB_LABELS: Dictionary = {
    TAB_SORTIE: "편성",
    TAB_EQUIPMENT: "장비",
    TAB_RECORDS: "기록",
    TAB_STORAGE: "창고",
    TAB_DISMANTLE: "분해",
    TAB_FORGE: "대장간",
    TAB_RECALL: "회상토벌"
}

signal tab_changed(tab_id: StringName)
signal next_battle_requested

var _active_tab: StringName = TAB_SORTIE
var _unlocked_tabs: Array[StringName] = []
var _camp_data: CampData = null

@onready var tab_bar: HBoxContainer = $TabBar if has_node("TabBar") else null
@onready var panel_area: Control = $PanelArea if has_node("PanelArea") else null
@onready var next_battle_button: Button = $NextBattleButton if has_node("NextBattleButton") else null
@onready var _records_panel = $PanelArea/records if has_node("PanelArea/records") else null

func _ready() -> void:
    if next_battle_button != null:
        next_battle_button.pressed.connect(_on_next_battle_pressed)

func load_camp(data: CampData) -> void:
    _camp_data = data
    _unlocked_tabs = data.unlocked_axes.duplicate()
    _active_tab = TAB_SORTIE
    _rebuild_tabs()
    _select_tab(TAB_SORTIE)

func select_tab(tab_id: StringName) -> void:
    if not _unlocked_tabs.has(tab_id):
        return
    _select_tab(tab_id)

func get_active_tab() -> StringName:
    return _active_tab

func get_layout_snapshot() -> Dictionary:
    return {
        "active_tab": _active_tab,
        "unlocked_tabs": _unlocked_tabs.duplicate(),
        "tab_count": _unlocked_tabs.size(),
        "has_next_battle_button": next_battle_button != null and next_battle_button.visible
    }

# --- Private ---

func _select_tab(tab_id: StringName) -> void:
    _active_tab = tab_id
    _sync_panel_visibility()
    if tab_id == TAB_RECORDS and _records_panel != null and _camp_data != null:
        _records_panel.load_records(_camp_data)
    tab_changed.emit(tab_id)

func _rebuild_tabs() -> void:
    if tab_bar == null:
        return
    for child in tab_bar.get_children():
        child.queue_free()
    for tab_id: StringName in _unlocked_tabs:
        var btn: Button = Button.new()
        btn.text = String(TAB_LABELS.get(tab_id, String(tab_id)))
        btn.pressed.connect(func() -> void: _select_tab(tab_id))
        tab_bar.add_child(btn)

func _sync_panel_visibility() -> void:
    if panel_area == null:
        return
    for child in panel_area.get_children():
        child.visible = (child.name == String(_active_tab))

func _on_next_battle_pressed() -> void:
    next_battle_requested.emit()
