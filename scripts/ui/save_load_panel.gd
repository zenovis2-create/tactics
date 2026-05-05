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
var _recommended_load_slot: int = -1
var _recommended_load_is_autosave: bool = false

@onready var slot_cards: VBoxContainer = $Panel/Margin/Content/SlotScroll/SlotCards if has_node("Panel/Margin/Content/SlotScroll/SlotCards") else null
@onready var subtitle_label: Label = $Panel/Margin/Content/SubtitleLabel if has_node("Panel/Margin/Content/SubtitleLabel") else null
@onready var slot_scroll: ScrollContainer = $Panel/Margin/Content/SlotScroll if has_node("Panel/Margin/Content/SlotScroll") else null
@onready var close_button: Button = $Panel/Margin/Content/CloseButton if has_node("Panel/Margin/Content/CloseButton") else null
@onready var title_label: Label = $Panel/Margin/Content/TitleLabel if has_node("Panel/Margin/Content/TitleLabel") else null

## 패널 열기
func open_save_mode() -> void:
    _mode = "save"
    _pending_delete_slot = -1
    _recommended_load_slot = -1
    _recommended_load_is_autosave = false
    if title_label != null:
        title_label.text = "저장"
    if subtitle_label != null:
        subtitle_label.text = "현재 진행 상태를 수동 슬롯에 보관한다. 자동저장은 별도 슬롯에서 유지되며, 여기서는 덮어쓰지 않는다."
    refresh_slots()
    visible = true

func open_load_mode() -> void:
    _mode = "load"
    _pending_delete_slot = -1
    _recommended_load_slot = -1
    _recommended_load_is_autosave = false
    if title_label != null:
        title_label.text = "불러오기"
    if subtitle_label != null:
        subtitle_label.text = "자동저장이 먼저 표시된다. 최근 챕터, 자원, 엔딩 진행도를 비교한 뒤 이어할 저장을 선택한다."
    refresh_slots()
    visible = true

func close() -> void:
    _pending_delete_slot = -1
    visible = false
    panel_closed.emit()

## 슬롯 카드 새로고침
func refresh_slots() -> void:
    if slot_cards == null:
        return
    for child in slot_cards.get_children():
        child.queue_free()
    if save_service == null:
        return
    var latest_target := _get_latest_load_target()
    _recommended_load_slot = int(latest_target.get("slot", -1))
    _recommended_load_is_autosave = bool(latest_target.get("is_autosave", false))
    if _mode == "load":
        slot_cards.add_child(_build_slot_card_with_info(
            SaveService.AUTOSAVE_SLOT,
            save_service.peek_slot(SaveService.AUTOSAVE_SLOT),
            true,
            _recommended_load_is_autosave and _recommended_load_slot == SaveService.AUTOSAVE_SLOT
        ))
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
        "pending_delete_slot": _pending_delete_slot,
        "autosave_available": save_service != null and save_service.slot_exists(SaveService.AUTOSAVE_SLOT),
        "recommended_load_slot": _recommended_load_slot,
        "recommended_load_is_autosave": _recommended_load_is_autosave
    }

# --- Private ---

func _ready() -> void:
    if close_button != null:
        close_button.pressed.connect(close)
    _apply_visual_theme()
    hide()

func _build_slot_card(slot: int) -> Control:
    return _build_slot_card_with_info(slot, get_slot_info(slot), false, _mode == "load" and not _recommended_load_is_autosave and _recommended_load_slot == slot)

func _build_slot_card_with_info(slot: int, info: Dictionary, is_autosave: bool, is_recommended: bool = false) -> Control:
    var card: PanelContainer = PanelContainer.new()
    card.name = "AutosaveCard" if is_autosave else "SlotCard%d" % slot
    var frame := StyleBoxFlat.new()
    frame.bg_color = Color(0.082, 0.098, 0.129, 0.96)
    frame.border_color = Color(0.286, 0.365, 0.486, 0.9)
    if is_autosave:
        frame.bg_color = Color(0.133, 0.118, 0.082, 0.97)
        frame.border_color = Color(0.875, 0.792, 0.537, 0.84)
    if is_recommended:
        frame.border_color = Color(0.58, 0.92, 0.74, 0.95)
        frame.shadow_color = Color(0.18, 0.42, 0.29, 0.28)
    frame.set_border_width_all(2)
    frame.set_corner_radius_all(14)
    frame.shadow_color = Color(0, 0, 0, 0.22)
    frame.shadow_size = 8
    card.add_theme_stylebox_override("panel", frame)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 12)
    margin.add_theme_constant_override("margin_top", 12)
    margin.add_theme_constant_override("margin_right", 12)
    margin.add_theme_constant_override("margin_bottom", 12)
    card.add_child(margin)

    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 8)
    margin.add_child(stack)

    var header_row := HBoxContainer.new()
    header_row.add_theme_constant_override("separation", 12)
    stack.add_child(header_row)

    var thumbnail := _build_slot_thumbnail(info)
    header_row.add_child(thumbnail)

    var text_stack := VBoxContainer.new()
    text_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    text_stack.add_theme_constant_override("separation", 6)
    header_row.add_child(text_stack)

    var title_label := Label.new()
    title_label.add_theme_font_size_override("font_size", 15)
    title_label.add_theme_color_override("font_color", Color(0.96, 0.97, 0.99, 1.0))
    var meta_label := Label.new()
    meta_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    meta_label.add_theme_font_size_override("font_size", 11)
    meta_label.add_theme_color_override("font_color", Color(0.77, 0.83, 0.9, 0.98))
    var status_label := Label.new()
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.add_theme_font_size_override("font_size", 10)
    status_label.add_theme_color_override("font_color", Color(0.88, 0.91, 0.95, 0.94))

    if info.is_empty() or not bool(info.get("exists", false)):
        title_label.text = "자동저장" if is_autosave else "슬롯 %d" % slot
        meta_label.text = "비어 있음"
        status_label.text = "안전 지점에 도달하면 자동으로 갱신된다." if is_autosave else "새 진행 또는 수동 저장 슬롯으로 사용할 수 있다."
    else:
        var ng_plus_text := "NG+" if bool(info.get("ng_plus_available", false)) else "기본 회차"
        var last_ending := String(info.get("last_completed_ending", "")).strip_edges()
        var autosave_reason := String(info.get("autosave_reason", "")).strip_edges()
        var progression_summary := String(info.get("unit_progression_summary", "")).strip_edges()
        title_label.text = "%s  ·  %s" % [String(info.get("slot_label", "슬롯 %d" % slot)), String(info.get("chapter", "미상"))]
        meta_label.text = "부담 %d / 신뢰 %d / 골드 %d / %s" % [
            int(info.get("burden", 0)),
            int(info.get("trust", 0)),
            int(info.get("gold", 0)),
            String(info.get("saved_at", ""))
        ]
        if is_autosave and not autosave_reason.is_empty():
            meta_label.text += "\n체크포인트: %s" % autosave_reason
        status_label.text = "엔딩 %s / 최근 %s / %s / 공명 %d / 앵커 %s / 이름부름 %s" % [
            String(info.get("ending_tendency", "undetermined")),
            last_ending if not last_ending.is_empty() else "없음",
            ng_plus_text,
            int(info.get("ending_resonance_count", 0)),
            "완료" if bool(info.get("ending_name_anchors_ok", false)) else "미완",
            "완료" if bool(info.get("ending_all_name_calls", false)) else "미완"
        ]
        if is_autosave:
            status_label.text += " / 안전지점 갱신"
        if not progression_summary.is_empty():
            status_label.text += "\n진행도: %s" % progression_summary
    text_stack.add_child(title_label)
    text_stack.add_child(meta_label)
    text_stack.add_child(status_label)
    var badge_info: Dictionary = info.duplicate(true)
    badge_info["is_recommended"] = is_recommended
    badge_info["is_autosave"] = is_autosave
    var badges := _build_slot_badges(badge_info)
    if badges != null:
        stack.add_child(badges)

    var btn_row: HBoxContainer = HBoxContainer.new()
    btn_row.add_theme_constant_override("separation", 8)
    stack.add_child(btn_row)

    if _mode == "save" and not is_autosave:
        var save_btn: Button = Button.new()
        save_btn.text = "저장"
        _style_action_button(save_btn, Color(0.176, 0.396, 0.659, 0.98), Color(0.278, 0.498, 0.761, 1.0))
        save_btn.pressed.connect(func() -> void: _on_save_pressed(slot))
        btn_row.add_child(save_btn)

    if _mode == "load" and bool(info.get("exists", false)):
        var load_btn: Button = Button.new()
        load_btn.text = "이어하기 추천" if is_recommended else "불러오기"
        _style_action_button(load_btn, Color(0.188, 0.486, 0.365, 0.98), Color(0.274, 0.576, 0.447, 1.0))
        load_btn.pressed.connect(func() -> void: _on_load_pressed(slot))
        btn_row.add_child(load_btn)

    if bool(info.get("exists", false)) and not is_autosave:
        var del_btn: Button = Button.new()
        del_btn.text = "삭제 확인" if _pending_delete_slot == slot else "삭제"
        _style_action_button(del_btn, Color(0.486, 0.176, 0.176, 0.98), Color(0.608, 0.231, 0.231, 1.0))
        del_btn.pressed.connect(func() -> void: _on_delete_pressed(slot))
        btn_row.add_child(del_btn)

    return card

func _build_slot_thumbnail(info: Dictionary) -> Control:
    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(112, 92)
    var style := StyleBoxFlat.new()
    style.set_corner_radius_all(12)
    style.set_border_width_all(1)
    style.shadow_color = Color(0, 0, 0, 0.18)
    style.shadow_size = 6

    var chapter_label := String(info.get("chapter", "")).strip_edges()
    var resonance_count: int = int(info.get("ending_resonance_count", 0))
    var last_ending := String(info.get("last_completed_ending", "")).strip_edges()
    if info.is_empty() or not bool(info.get("exists", false)):
        style.bg_color = Color(0.125, 0.141, 0.173, 0.96)
        style.border_color = Color(0.286, 0.365, 0.486, 0.7)
    elif chapter_label.begins_with("CH10"):
        style.bg_color = Color(0.192, 0.133, 0.243, 0.98)
        style.border_color = Color(0.776, 0.655, 0.945, 0.72)
    elif chapter_label.begins_with("CH09"):
        style.bg_color = Color(0.149, 0.188, 0.286, 0.98)
        style.border_color = Color(0.604, 0.733, 0.925, 0.72)
    elif chapter_label.begins_with("CH0"):
        style.bg_color = Color(0.133, 0.216, 0.286, 0.98)
        style.border_color = Color(0.557, 0.800, 0.929, 0.7)
    else:
        style.bg_color = Color(0.188, 0.180, 0.133, 0.98)
        style.border_color = Color(0.875, 0.792, 0.537, 0.7)
    panel.add_theme_stylebox_override("panel", style)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 10)
    margin.add_theme_constant_override("margin_top", 10)
    margin.add_theme_constant_override("margin_right", 10)
    margin.add_theme_constant_override("margin_bottom", 10)
    panel.add_child(margin)

    var stack := VBoxContainer.new()
    stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
    stack.add_theme_constant_override("separation", 4)
    margin.add_child(stack)

    var chapter_badge := Label.new()
    chapter_badge.text = chapter_label if not chapter_label.is_empty() else "EMPTY"
    chapter_badge.add_theme_font_size_override("font_size", 12)
    chapter_badge.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 0.96))
    stack.add_child(chapter_badge)

    var title := Label.new()
    title.text = "결말 %s" % (last_ending if not last_ending.is_empty() else "대기")
    title.add_theme_font_size_override("font_size", 15)
    title.add_theme_color_override("font_color", Color(0.98, 0.98, 1.0, 1.0))
    stack.add_child(title)

    var summary := Label.new()
    summary.text = "공명 %d / NG+ %s" % [resonance_count, "ON" if bool(info.get("ng_plus_available", false)) else "OFF"]
    summary.add_theme_font_size_override("font_size", 11)
    summary.add_theme_color_override("font_color", Color(0.90, 0.94, 0.98, 0.9))
    summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    stack.add_child(summary)
    return panel

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

func _apply_visual_theme() -> void:
    if title_label != null:
        title_label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
    if subtitle_label != null:
        subtitle_label.add_theme_color_override("font_color", Color(0.74, 0.81, 0.9, 0.96))
    if close_button != null:
        _style_action_button(close_button, Color(0.196, 0.231, 0.290, 0.98), Color(0.266, 0.313, 0.384, 1.0))

func _style_action_button(button: Button, base_color: Color, hover_color: Color) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = base_color
    normal.border_color = Color(0.72, 0.8, 0.91, 0.24)
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(10)
    var hover := StyleBoxFlat.new()
    hover.bg_color = hover_color
    hover.border_color = Color(0.82, 0.89, 0.96, 0.38)
    hover.set_border_width_all(1)
    hover.set_corner_radius_all(10)
    var disabled := StyleBoxFlat.new()
    disabled.bg_color = Color(0.16, 0.18, 0.21, 0.9)
    disabled.border_color = Color(0.32, 0.36, 0.42, 0.24)
    disabled.set_border_width_all(1)
    disabled.set_corner_radius_all(10)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", hover)
    button.add_theme_stylebox_override("disabled", disabled)
    button.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
    button.add_theme_color_override("font_disabled_color", Color(0.72, 0.77, 0.83, 0.72))

func _build_slot_badges(info: Dictionary) -> Container:
    if info.is_empty() or not bool(info.get("exists", false)):
        return null
    var row := HFlowContainer.new()
    row.add_theme_constant_override("h_separation", 6)
    row.add_theme_constant_override("v_separation", 6)

    var ending_tendency := String(info.get("ending_tendency", "undetermined"))
    var last_ending := String(info.get("last_completed_ending", "")).strip_edges()
    var resonance_count: int = int(info.get("ending_resonance_count", 0))
    var anchors_ok: bool = bool(info.get("ending_name_anchors_ok", false))
    var name_calls_ok: bool = bool(info.get("ending_all_name_calls", false))
    var is_recommended: bool = bool(info.get("is_recommended", false))

    if bool(info.get("is_autosave", false)):
        row.add_child(_make_slot_badge("AUTO", Color(0.365, 0.286, 0.149, 0.98), Color(0.94, 0.82, 0.57, 0.58)))
    if is_recommended:
        row.add_child(_make_slot_badge("이어하기", Color(0.172, 0.349, 0.247, 0.98), Color(0.64, 0.94, 0.78, 0.58)))
    row.add_child(_make_slot_badge("엔딩 %s" % ending_tendency, Color(0.243, 0.278, 0.356, 0.95), Color(0.608, 0.702, 0.835, 0.48)))
    if bool(info.get("ng_plus_available", false)):
        row.add_child(_make_slot_badge("NG+", Color(0.216, 0.329, 0.258, 0.98), Color(0.62, 0.878, 0.706, 0.54)))
    if not last_ending.is_empty():
        row.add_child(_make_slot_badge("최근 %s" % last_ending, Color(0.278, 0.231, 0.149, 0.98), Color(0.91, 0.78, 0.48, 0.5)))
    row.add_child(_make_slot_badge("공명 %d" % resonance_count, Color(0.153, 0.282, 0.392, 0.98), Color(0.58, 0.82, 0.98, 0.5)))
    row.add_child(_make_slot_badge("앵커 %s" % ("완료" if anchors_ok else "미완"), Color(0.188, 0.341, 0.258, 0.98) if anchors_ok else Color(0.388, 0.207, 0.207, 0.98), Color(0.62, 0.88, 0.70, 0.45) if anchors_ok else Color(0.93, 0.58, 0.58, 0.45)))
    row.add_child(_make_slot_badge("이름부름 %s" % ("완료" if name_calls_ok else "미완"), Color(0.188, 0.341, 0.258, 0.98) if name_calls_ok else Color(0.388, 0.207, 0.207, 0.98), Color(0.62, 0.88, 0.70, 0.45) if name_calls_ok else Color(0.93, 0.58, 0.58, 0.45)))
    return row

func _make_slot_badge(text: String, fill_color: Color, border_color: Color) -> PanelContainer:
    var badge := PanelContainer.new()
    var style := StyleBoxFlat.new()
    style.bg_color = fill_color
    style.border_color = border_color
    style.set_border_width_all(1)
    style.set_corner_radius_all(999)
    badge.add_theme_stylebox_override("panel", style)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 8)
    margin.add_theme_constant_override("margin_top", 4)
    margin.add_theme_constant_override("margin_right", 8)
    margin.add_theme_constant_override("margin_bottom", 4)
    badge.add_child(margin)

    var label := Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", 11)
    label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
    margin.add_child(label)
    return badge

func _get_latest_load_target() -> Dictionary:
    if save_service == null:
        return {}
    var best_saved_at: String = ""
    var best_slot: int = -1
    var best_is_autosave: bool = false
    var autosave_info: Dictionary = save_service.peek_slot(SaveService.AUTOSAVE_SLOT)
    if bool(autosave_info.get("exists", false)):
        best_saved_at = String(autosave_info.get("saved_at", ""))
        best_slot = SaveService.AUTOSAVE_SLOT
        best_is_autosave = true
    for slot in SLOT_COUNT:
        var info: Dictionary = save_service.peek_slot(slot)
        if not bool(info.get("exists", false)):
            continue
        var saved_at: String = String(info.get("saved_at", ""))
        if best_slot == -1 or saved_at > best_saved_at:
            best_saved_at = saved_at
            best_slot = slot
            best_is_autosave = false
    return {
        "slot": best_slot,
        "is_autosave": best_is_autosave
    }
