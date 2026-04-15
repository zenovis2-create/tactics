class_name SaveLoadPanel
extends Control

## 저장/불러오기 패널 — 슬롯 3개 카드
## save_service를 통해 peek/save/load/delete

const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

const SLOT_COUNT: int = 3

signal save_requested(slot: int)
signal load_requested(slot: int, data: ProgressionData)
signal delete_requested(slot: int)
signal panel_closed

## 외부에서 주입 (main.gd에서 연결)
var save_service: SaveService = null
var _mode: String = "save"  # "save" or "load"
var _pending_delete_slot: int = -1

@onready var slot_cards: VBoxContainer = $Panel/Margin/Content/SlotCards if has_node("Panel/Margin/Content/SlotCards") else null
@onready var close_button: Button = $Panel/Margin/Content/CloseButton if has_node("Panel/Margin/Content/CloseButton") else null
@onready var title_label: Label = $Panel/Margin/Content/TitleLabel if has_node("Panel/Margin/Content/TitleLabel") else null

## 패널 열기
func open_save_mode() -> void:
    _mode = "save"
    _pending_delete_slot = -1
    if title_label != null:
        title_label.text = "저장"
    refresh_slots()
    visible = true

func open_load_mode() -> void:
    _mode = "load"
    _pending_delete_slot = -1
    if title_label != null:
        title_label.text = "불러오기"
    refresh_slots()
    visible = true

func close() -> void:
    _pending_delete_slot = -1
    visible = false
    panel_closed.emit()

## 슬롯 카드 새로고침
func refresh_slots() -> void:
    if slot_cards == null or save_service == null:
        return
    for child in slot_cards.get_children():
        child.queue_free()
    for i in SLOT_COUNT:
        var card: Control = _build_slot_card(i)
        slot_cards.add_child(card)

## 슬롯 정보 읽기 (save_service.peek_slot 활용)
func get_slot_info(slot: int) -> Dictionary:
    if save_service == null:
        return {}
    return save_service.peek_slot(slot)

func get_layout_snapshot() -> Dictionary:
    return {
        "mode": _mode,
        "visible": visible,
        "slot_count": SLOT_COUNT,
        "save_service_connected": save_service != null,
        "pending_delete_slot": _pending_delete_slot
    }

# --- Private ---

func _ready() -> void:
    if close_button != null:
        close_button.pressed.connect(close)
    hide()

func _build_slot_card(slot: int) -> Control:
    var card: VBoxContainer = VBoxContainer.new()
    card.name = "SlotCard%d" % slot

    var info: Dictionary = get_slot_info(slot)
    var lbl: Label = Label.new()
    if info.is_empty() or not bool(info.get("exists", false)):
        lbl.text = "슬롯 %d — 비어 있음" % slot
    else:
        lbl.text = "슬롯 %d | CH: %s | 부담:%d 신뢰:%d | 엔딩:%s | %s" % [
            slot,
            String(info.get("chapter", &"")),
            int(info.get("burden", 0)),
            int(info.get("trust", 0)),
            String(info.get("ending_tendency", "undetermined")),
            String(info.get("saved_at", ""))
        ]
    card.add_child(lbl)

    var btn_row: HBoxContainer = HBoxContainer.new()
    card.add_child(btn_row)

    if _mode == "save":
        var save_btn: Button = Button.new()
        save_btn.text = "저장"
        save_btn.pressed.connect(func() -> void: _on_save_pressed(slot))
        btn_row.add_child(save_btn)

    if _mode == "load" and bool(info.get("exists", false)):
        var load_btn: Button = Button.new()
        load_btn.text = "불러오기"
        load_btn.pressed.connect(func() -> void: _on_load_pressed(slot))
        btn_row.add_child(load_btn)

    if bool(info.get("exists", false)):
        var del_btn: Button = Button.new()
        del_btn.text = "삭제 확인" if _pending_delete_slot == slot else "삭제"
        del_btn.pressed.connect(func() -> void: _on_delete_pressed(slot))
        btn_row.add_child(del_btn)

    return card

func _on_save_pressed(slot: int) -> void:
    _pending_delete_slot = -1
    save_requested.emit(slot)

func _on_load_pressed(slot: int) -> void:
    _pending_delete_slot = -1
    var data: ProgressionData = null
    if save_service != null:
        data = save_service.load_progression(slot)
    load_requested.emit(slot, data)

func _on_delete_pressed(slot: int) -> void:
    if _pending_delete_slot != slot:
        _pending_delete_slot = slot
        refresh_slots()
        return
    if save_service != null:
        save_service.delete_slot(slot)
    _pending_delete_slot = -1
    delete_requested.emit(slot)
    refresh_slots()
