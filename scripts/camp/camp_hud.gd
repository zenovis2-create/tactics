class_name CampHud
extends Control

## 캠프 허브 HUD — 8개 축 탭 전환 + 활성 패널 표시/숨김
## CampaignPanel의 Records/Party/Inventory 섹션과 연동
## 보관(save) 탭은 SaveLoadPanel과 연동

const CampData = preload("res://scripts/data/camp_data.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")
const HuntBoardPanel = preload("res://scripts/ui/hunt_board_panel.gd")

const TAB_SORTIE: StringName = &"sortie"
const TAB_EQUIPMENT: StringName = &"equipment"
const TAB_RECORDS: StringName = &"records"
const TAB_STORAGE: StringName = &"storage"
const TAB_DISMANTLE: StringName = &"dismantle"
const TAB_FORGE: StringName = &"forge"
const TAB_RECALL: StringName = &"recall"
const TAB_SAVE: StringName = &"save"

const TAB_LABELS: Dictionary = {
    TAB_SORTIE: "편성",
    TAB_EQUIPMENT: "장비",
    TAB_RECORDS: "기록",
    TAB_STORAGE: "창고",
    TAB_DISMANTLE: "분해",
    TAB_FORGE: "대장간",
    TAB_RECALL: "회상토벌",
    TAB_SAVE: "보관"
}

signal tab_changed(tab_id: StringName)
signal next_battle_requested

var _active_tab: StringName = TAB_SORTIE
var _unlocked_tabs: Array[StringName] = []
var _camp_data: CampData = null
var _save_service: SaveService = null

@onready var tab_bar: HBoxContainer = $VBox/TabBar if has_node("VBox/TabBar") else null
@onready var panel_area: Control = $VBox/PanelArea if has_node("VBox/PanelArea") else null
@onready var next_battle_button: Button = $VBox/NextBattleButton if has_node("VBox/NextBattleButton") else null
@onready var _records_panel = $VBox/PanelArea/records if has_node("VBox/PanelArea/records") else null
@onready var _forge_panel: Control = $VBox/PanelArea/forge if has_node("VBox/PanelArea/forge") else null
@onready var _forge_materials_label: RichTextLabel = $VBox/PanelArea/forge/Stack/MaterialsList if has_node("VBox/PanelArea/forge/Stack/MaterialsList") else null
@onready var _forge_recipes_label: RichTextLabel = $VBox/PanelArea/forge/Stack/RecipeList if has_node("VBox/PanelArea/forge/Stack/RecipeList") else null
@onready var _recall_panel: HuntBoardPanel = $VBox/PanelArea/recall if has_node("VBox/PanelArea/recall") else null
@onready var _save_load_panel = $VBox/PanelArea/save if has_node("VBox/PanelArea/save") else null

func _ready() -> void:
    if next_battle_button != null:
        next_battle_button.pressed.connect(_on_next_battle_pressed)

func load_camp(data: CampData) -> void:
    _camp_data = data
    _unlocked_tabs = data.unlocked_axes.duplicate()
    _active_tab = data.active_axis if data.active_axis != StringName() else TAB_SORTIE
    _rebuild_tabs()
    _populate_forge_panel()
    _populate_recall_panel()
    _select_tab(_active_tab)
    _wire_save_panel()

func set_save_service(service: SaveService) -> void:
    _save_service = service
    _wire_save_panel()

func get_save_service() -> SaveService:
    return _save_service

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
        "has_next_battle_button": next_battle_button != null and next_battle_button.visible,
        "save_service_connected": _save_service != null,
        "recall_entry_count": _camp_data.recall_hunt_entries.size() if _camp_data != null else 0,
        "selected_hunt_id": _camp_data.selected_hunt_id if _camp_data != null else StringName()
    }

# --- Private ---

func _select_tab(tab_id: StringName) -> void:
    # Close save panel when switching away
    if _active_tab == TAB_SAVE and tab_id != TAB_SAVE and _save_load_panel != null:
        _save_load_panel.close()
    _active_tab = tab_id
    if _camp_data != null:
        _camp_data.active_axis = tab_id
    _sync_panel_visibility()
    if tab_id == TAB_RECORDS and _records_panel != null and _camp_data != null:
        _records_panel.load_records(_camp_data)
    if tab_id == TAB_FORGE:
        _populate_forge_panel()
    if tab_id == TAB_RECALL:
        _populate_recall_panel()
    if tab_id == TAB_SAVE and _save_load_panel != null:
        _save_load_panel.open_save_mode()
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

func _wire_save_panel() -> void:
    if _save_load_panel == null:
        return
    if _save_service == null:
        return
    _save_load_panel.save_service = _save_service

func _populate_forge_panel() -> void:
    if _forge_panel == null or _camp_data == null:
        return
    if _forge_materials_label != null:
        var material_lines: Array[String] = []
        for entry in _camp_data.material_entries:
            material_lines.append("%s x%d" % [
                String(entry.get("label", entry.get("material_id", "Material"))),
                int(entry.get("count", 0))
            ])
        _forge_materials_label.text = _format_lines(material_lines, "No forging materials recovered yet.")
    if _forge_recipes_label != null:
        var recipe_lines: Array[String] = []
        for entry in _camp_data.forge_recipe_entries:
            var suffix: String = " [Ready]" if bool(entry.get("can_craft", false)) else ""
            if bool(entry.get("owned", false)):
                suffix = " [Owned]"
            var material_lines: Array = entry.get("materials", [])
            recipe_lines.append("%s — %s%s" % [
                String(entry.get("label", "Recipe")),
                ", ".join(_stringify_array(material_lines)),
                suffix
            ])
        _forge_recipes_label.text = _format_lines(recipe_lines, "No forge recipes available in this camp.")

func _populate_recall_panel() -> void:
    if _recall_panel == null or _camp_data == null:
        return
    _recall_panel.setup_entries(_camp_data.recall_hunt_entries, _camp_data.selected_hunt_id)

func _format_lines(lines: Array[String], fallback: String) -> String:
    if lines.is_empty():
        return "- %s" % fallback
    var rendered: String = ""
    for line in lines:
        if not rendered.is_empty():
            rendered += "\n"
        rendered += "- %s" % line
    return rendered

func _stringify_array(values: Array) -> Array[String]:
    var result: Array[String] = []
    for value in values:
        result.append(String(value))
    return result
