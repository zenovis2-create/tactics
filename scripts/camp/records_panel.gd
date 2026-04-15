class_name RecordsPanel
extends Control

## 기록 패널 — 기억 조각, 증거, 서한 목록 + 바텀시트 상세 보기
## CampHUD의 "records" PanelArea 자식으로 사용

const CampData = preload("res://scripts/data/camp_data.gd")

signal record_selected(entry: Dictionary)

var _entries: Array[Dictionary] = []
var _selected_index: int = -1

# UI refs (안전하게 has_node 체크)
@onready var _list_panel: VBoxContainer = $ListPanel if has_node("ListPanel") else null
@onready var _detail_panel: Control     = $DetailPanel if has_node("DetailPanel") else null
@onready var _detail_title: Label       = $DetailPanel/Title if has_node("DetailPanel/Title") else null
@onready var _detail_body: RichTextLabel = $DetailPanel/Body if has_node("DetailPanel/Body") else null
@onready var _detail_close: Button      = $DetailPanel/CloseButton if has_node("DetailPanel/CloseButton") else null
@onready var _empty_label: Label        = $EmptyLabel if has_node("EmptyLabel") else null

func _ready() -> void:
    if _detail_close != null:
        _detail_close.pressed.connect(_close_detail)
    _hide_detail()

## CampData로 목록 갱신
func load_records(data: CampData) -> void:
    _entries.clear()
    if data == null:
        _refresh_list()
        return

    for mem in data.pending_memory_entries:
        _entries.append({
            "type": "memory",
            "label": "[ 기억 ] " + String(mem.get("title", "")),
            "title": String(mem.get("title", "")),
            "body":  String(mem.get("text", "")),
        })
    for ev in data.pending_evidence_entries:
        _entries.append({
            "type": "evidence",
            "label": "[ 증거 ] " + String(ev.get("title", "")),
            "title": String(ev.get("title", "")),
            "body":  String(ev.get("text", "")),
        })
    for letter in data.pending_letter_entries:
        _entries.append({
            "type": "letter",
            "label": "[ 서한 ] " + String(letter.get("title", "")),
            "title": String(letter.get("title", "")),
            "body":  String(letter.get("text", "")),
        })

    _refresh_list()

## 현재 항목 수
func get_entry_count() -> int:
    return _entries.size()

## 선택된 항목 (-1이면 없음)
func get_selected_index() -> int:
    return _selected_index

## 테스트용: 인덱스로 항목 선택
func select_entry(index: int) -> void:
    if index < 0 or index >= _entries.size():
        return
    _selected_index = index
    _show_detail(_entries[index])

# --- Private ---

func _refresh_list() -> void:
    if _list_panel == null:
        return
    for child in _list_panel.get_children():
        child.queue_free()

    if _entries.is_empty():
        if _empty_label != null:
            _empty_label.visible = true
        return

    if _empty_label != null:
        _empty_label.visible = false

    for i in range(_entries.size()):
        var entry: Dictionary = _entries[i]
        var btn: Button = Button.new()
        btn.text = String(entry.get("label", "항목 %d" % i))
        btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
        btn.custom_minimum_size = Vector2(0, 40)
        var idx_capture: int = i
        btn.pressed.connect(func() -> void: _on_entry_pressed(idx_capture))
        _list_panel.add_child(btn)

func _on_entry_pressed(index: int) -> void:
    if index < 0 or index >= _entries.size():
        return
    _selected_index = index
    var entry: Dictionary = _entries[index]
    _show_detail(entry)
    record_selected.emit(entry)

func _show_detail(entry: Dictionary) -> void:
    if _detail_panel == null:
        return
    _detail_panel.visible = true
    if _detail_title != null:
        _detail_title.text = String(entry.get("title", ""))
    if _detail_body != null:
        _detail_body.text = String(entry.get("body", ""))

func _hide_detail() -> void:
    if _detail_panel != null:
        _detail_panel.visible = false
    _selected_index = -1

func _close_detail() -> void:
    _hide_detail()
