class_name BattleHUD
extends Control

const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const TelegraphTextureLibrary = preload("res://scripts/battle/telegraph_texture_library.gd")

signal wait_requested
signal cancel_requested
signal end_turn_requested
signal menu_visibility_changed(is_open: bool)
signal ui_cue_requested(cue_id: String)

const COMPACT_WIDTH_THRESHOLD := 720.0
const COMPACT_PANEL_MARGIN := 16.0
const COMPACT_PANEL_TOP_MARGIN := 72.0
const COMPACT_PANEL_BOTTOM_MARGIN := 16.0
const COMPACT_TOPBAR_HEIGHT := 96.0
const COMPACT_BOTTOMBAR_TOP := -172.0
const REGULAR_PANEL_HALF_WIDTH := 312.0
const REGULAR_PANEL_HALF_HEIGHT := 220.0
const COMPACT_ACTION_BUTTON_HEIGHT := 72.0
const REGULAR_ACTION_BUTTON_HEIGHT := 28.0
const REGULAR_TOPBAR_PADDING := 4.0
const REGULAR_TOPBAR_HEIGHT := 62.0
const REGULAR_BOTTOMBAR_PADDING := 8.0
const REGULAR_BOTTOMBAR_HEIGHT := 88.0
const REGULAR_TOPBAR_MAX_WIDTH := 760.0

@onready var top_bar: PanelContainer = $TopBar
@onready var bottom_panel: PanelContainer = $BottomPanel
@onready var round_label: Label = $TopBar/Margin/TopRow/MetaRow/RoundLabel
@onready var phase_label: Label = $TopBar/Margin/TopRow/MetaRow/PhaseLabel
@onready var _status_weather_label: Label = $TopBar/Margin/TopRow/MetaRow/WeatherIcon
@onready var objective_label: Label = $TopBar/Margin/TopRow/ObjectiveLabel
@onready var landmark_label: Label = $TopBar/Margin/TopRow/LandmarkLabel
@onready var stage_chip: PanelContainer = $TopBar/Margin/TopRow/StageChip
@onready var stage_label: Label = $TopBar/Margin/TopRow/StageChip/Padding/StageLabel
@onready var selection_card: PanelContainer = $BottomPanel/Margin/Content/SelectionCard
@onready var selection_label: Label = $BottomPanel/Margin/Content/SelectionCard/Padding/Stack/SelectionLabel
@onready var detail_label: Label = $BottomPanel/Margin/Content/SelectionCard/Padding/Stack/DetailLabel
@onready var resource_cost_label: Label = $BottomPanel/Margin/Content/SelectionCard/Padding/Stack/ResourceCostLabel
@onready var hint_label: Label = $BottomPanel/Margin/Content/HintLabel
@onready var objective_hint_label: Label = $BottomPanel/Margin/Content/ObjectiveHintLabel
@onready var transition_reason_label: Label = $BottomPanel/Margin/Content/TransitionReasonLabel
@onready var telegraph_card: PanelContainer = $BottomPanel/Margin/Content/TelegraphCard
@onready var telegraph_preview: TextureRect = $BottomPanel/Margin/Content/TelegraphCard/Padding/Stack/Preview
@onready var telegraph_label: Label = $BottomPanel/Margin/Content/TelegraphCard/Padding/Stack/Copy/Label
@onready var telegraph_detail_label: Label = $BottomPanel/Margin/Content/TelegraphCard/Padding/Stack/Copy/Detail
@onready var actions_grid: GridContainer = $BottomPanel/Margin/Content/Actions
@onready var inventory_button: Button = $BottomPanel/Margin/Content/Actions/InventoryButton
@onready var cancel_button: Button = $BottomPanel/Margin/Content/Actions/CancelButton
@onready var wait_button: Button = $BottomPanel/Margin/Content/Actions/WaitButton
@onready var end_turn_button: Button = $BottomPanel/Margin/Content/Actions/EndTurnButton
@onready var overlay_scrim: ColorRect = $OverlayScrim
@onready var inventory_panel: PanelContainer = $InventoryPanel
@onready var inventory_title_label: Label = $InventoryPanel/Margin/Content/Header/Title
@onready var inventory_objective_label: Label = $InventoryPanel/Margin/Content/Header/Objective
@onready var inventory_body: BoxContainer = $InventoryPanel/Margin/Content/Body
@onready var party_heading_label: Label = $InventoryPanel/Margin/Content/Body/PartyColumn/PartyHeading
@onready var party_list: RichTextLabel = $InventoryPanel/Margin/Content/Body/PartyColumn/PartyList
@onready var inventory_heading_label: Label = $InventoryPanel/Margin/Content/Body/InventoryColumn/InventoryHeading
@onready var inventory_list: RichTextLabel = $InventoryPanel/Margin/Content/Body/InventoryColumn/InventoryList
@onready var dismiss_hint_label: Label = $InventoryPanel/Margin/Content/Footer/DismissHintLabel
@onready var close_inventory_button: Button = $InventoryPanel/Margin/Content/Footer/CloseButton
@onready var result_popup: AcceptDialog = $ResultPopup
var result_screen: Node  ## BattleResultScreen — 전투 결과 전용 화면 (동적 로드)

var _compact_layout: bool = false
var _last_focus_owner: Control
var _board_origin: Vector2 = Vector2.ZERO
var _board_size: Vector2 = Vector2.ZERO
var _last_result_title: String = "Battle Result"
var _last_result_body: String = ""
var _current_phase_text: String = "PLAYER SELECT"
var _current_round_number: int = 1
var _current_weather_type: String = "clear"
var _risk_forecast_cards: Array[Dictionary] = []
var _preview_labels: Array[String] = []
var _boss_lock_intent_snapshot: Dictionary = {}
var _risk_forecast_root: VBoxContainer
var _last_transition_payload: Dictionary = {}

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    cancel_button.pressed.connect(_on_cancel_pressed)
    wait_button.pressed.connect(_on_wait_pressed)
    end_turn_button.pressed.connect(_on_end_turn_pressed)
    inventory_button.pressed.connect(open_inventory_panel)
    close_inventory_button.pressed.connect(close_inventory_panel)
    overlay_scrim.gui_input.connect(_on_overlay_scrim_gui_input)
    overlay_scrim.hide()
    inventory_panel.hide()
    _ensure_risk_forecast_surface()
    # BattleResultScreen 동적 로드
    var ResultScreenScene = load("res://scenes/battle/BattleResultScreen.tscn")
    if ResultScreenScene != null:
        result_screen = ResultScreenScene.instantiate()
        add_child(result_screen)
        result_screen.result_confirmed.connect(_on_result_screen_confirmed)
    clear_selection()
    set_action_hint("Tap a ready ally to act.")
    set_buttons_state(false, false, true)
    set_objective("Defeat all enemies.")
    set_stage_title("Tutorial Skirmish")
    set_weather_type("clear")
    set_landmarks(PackedStringArray())
    set_objective_hint("")
    _clear_telegraph_surface()
    get_viewport().size_changed.connect(_update_responsive_layout)
    _update_responsive_layout()
    _apply_runtime_button_icons()
    _apply_visual_theme()
    _refresh_action_button_emphasis()
    _refresh_inventory_dismiss_hint()

func set_phase(phase_text: String) -> void:
    _current_phase_text = phase_text
    _update_status_display()

func set_round(round_number: int) -> void:
    _current_round_number = round_number
    _update_status_display()

func set_weather_type(weather_type: String) -> void:
    _current_weather_type = weather_type.strip_edges().to_lower()
    if _current_weather_type.is_empty():
        _current_weather_type = "clear"
    _update_status_display()

func set_objective(objective_text: String) -> void:
    objective_label.text = "Objective: %s" % objective_text

func set_stage_title(title_text: String) -> void:
    stage_label.text = title_text
    stage_chip.visible = not title_text.strip_edges().is_empty()

func set_landmarks(landmarks: PackedStringArray) -> void:
    var visible_landmarks: Array[String] = []
    for raw_label in landmarks:
        var normalized_label := String(raw_label).strip_edges()
        if not normalized_label.is_empty():
            visible_landmarks.append(normalized_label)

    landmark_label.visible = not visible_landmarks.is_empty()
    landmark_label.text = "Landmarks: %s" % " • ".join(visible_landmarks) if landmark_label.visible else ""

func set_objective_hint(hint_text: String) -> void:
    var normalized_hint := hint_text.strip_edges()
    objective_hint_label.visible = not normalized_hint.is_empty()
    objective_hint_label.text = "Hint: %s" % normalized_hint if objective_hint_label.visible else ""

func set_boss_lock_intent(lock_state: Dictionary) -> void:
    if lock_state.is_empty():
        clear_boss_lock_intent()
        return
    var action_name: String = String(lock_state.get("display_name", lock_state.get("action_id", "Boss Intent"))).strip_edges()
    if action_name.is_empty():
        action_name = "Boss Intent"
    var countdown: int = int(lock_state.get("countdown", 0))
    var progress_text: String = _format_boss_lock_progress(lock_state)
    var failure_text: String = String(lock_state.get("failure_text", "")).strip_edges()
    var break_text: String = String(lock_state.get("break_text", "")).strip_edges()
    var detail_parts: Array[String] = []
    if countdown > 0:
        detail_parts.append("Countdown %d" % countdown)
    if not progress_text.is_empty():
        detail_parts.append(progress_text)
    if not failure_text.is_empty():
        detail_parts.append("Fail: %s" % failure_text)
    if not break_text.is_empty():
        detail_parts.append("Break: %s" % break_text)
    var detail_text := " | ".join(detail_parts)
    _boss_lock_intent_snapshot = {
        "visible": true,
        "action": action_name,
        "countdown": countdown,
        "progress_text": progress_text,
        "failure_text": failure_text,
        "break_text": break_text,
        "detail": detail_text
    }
    _show_telegraph_surface("danger", "Boss Lock: %s" % action_name, detail_text)

func clear_boss_lock_intent() -> void:
    _boss_lock_intent_snapshot = {"visible": false}

func _format_boss_lock_progress(lock_state: Dictionary) -> String:
    var required: Dictionary = lock_state.get("locks_required", {})
    var progress: Dictionary = lock_state.get("locks_progress", {})
    if required.is_empty():
        return ""
    var keys: Array = required.keys()
    keys.sort()
    var chunks: Array[String] = []
    for lock_type in keys:
        var type_key := String(lock_type)
        chunks.append("%s %d/%d" % [type_key, int(progress.get(type_key, 0)), int(required.get(type_key, 0))])
    return "Locks: %s" % ", ".join(chunks)

func set_transition_reason(reason: String, payload: Dictionary = {}) -> void:
    _last_transition_payload = payload.duplicate(true)
    var formatted_reason: String = _format_reason(reason, payload)
    transition_reason_label.text = formatted_reason
    transition_reason_label.visible = not _should_hide_reason(reason)
    _update_telegraph_surface(reason, payload)
    _emit_battle_cue_for_reason(reason)

func get_transition_surface_snapshot() -> Dictionary:
    return {
        "reason_text": transition_reason_label.text,
        "reason_visible": transition_reason_label.visible,
        "telegraph_visible": telegraph_card.visible,
        "telegraph_label": telegraph_label.text,
        "telegraph_detail": telegraph_detail_label.text,
        "boss_lock_intent": _boss_lock_intent_snapshot.duplicate(true)
    }

func get_risk_forecast_snapshot() -> Dictionary:
    return {
        "visible": _risk_forecast_root != null and _risk_forecast_root.visible,
        "cards": _risk_forecast_cards.duplicate(true)
    }

func get_selection_snapshot() -> Dictionary:
    return {
        "visible": selection_card.visible,
        "unit_name": selection_label.text,
        "detail": detail_label.text,
        "preview_labels": _preview_labels.duplicate()
    }

func set_selection_summary(unit_name: String, hp_text: String, movement: int, attack_range: int, reachable_count: int, attackable_count: int, interactable_count: int, terrain_text: String = "", oblivion_stack: int = 0, skill_cost_lines: Array[String] = [], resource_pool_text: String = "", preview_labels: Array[String] = []) -> void:
    selection_card.visible = true
    var display_name: String = unit_name
    if oblivion_stack > 0:
        display_name += "  [망각 ×%d]" % oblivion_stack
    selection_label.text = display_name
    detail_label.text = "HP:%s  Move:%d  Range:%d  Re:%d  T:%d  I:%d" % [
        hp_text,
        movement,
        attack_range,
        reachable_count,
        attackable_count,
        interactable_count
    ]
    if not terrain_text.is_empty():
        detail_label.text += "  Tile:%s" % terrain_text
    var resource_chunks: Array[String] = []
    if not resource_pool_text.is_empty():
        resource_chunks.append(resource_pool_text)
    if not skill_cost_lines.is_empty():
        resource_chunks.append("Skills: %s" % "  •  ".join(skill_cost_lines))
    _preview_labels.clear()
    for label in preview_labels:
        var normalized_label := String(label).strip_edges()
        if normalized_label.is_empty():
            continue
        _preview_labels.append(normalized_label)
    if not _preview_labels.is_empty():
        resource_chunks.append("Preview: %s" % "  •  ".join(_preview_labels))
    resource_cost_label.visible = not resource_chunks.is_empty()
    resource_cost_label.text = " | ".join(resource_chunks) if resource_cost_label.visible else ""

func clear_selection() -> void:
    selection_card.visible = false
    selection_label.text = "No unit selected."
    detail_label.text = "Select a ready ally to inspect movement, attack range, and nearby objectives."
    _preview_labels.clear()
    resource_cost_label.visible = false
    resource_cost_label.text = ""

func set_action_hint(hint_text: String) -> void:
    hint_label.text = hint_text

func set_buttons_state(wait_enabled: bool, cancel_enabled: bool, end_turn_enabled: bool) -> void:
    inventory_button.disabled = false
    wait_button.disabled = not wait_enabled
    cancel_button.disabled = not cancel_enabled
    end_turn_button.disabled = not end_turn_enabled
    inventory_button.tooltip_text = "Review the deployed party and recovered supplies."
    wait_button.tooltip_text = "Finish this unit's action package with Wait." if wait_enabled else "Move or select a ready ally first."
    cancel_button.tooltip_text = "Undo the current movement preview." if cancel_enabled else "Move a ready ally before cancel becomes available."
    end_turn_button.tooltip_text = "Hand control to the enemy phase." if end_turn_enabled else "Finish or forfeit the current unit actions first."
    _refresh_action_button_emphasis()

func set_inventory_snapshot(title_text: String, objective_text: String, party_lines: Array[String], inventory_lines: Array[String]) -> void:
    inventory_title_label.text = title_text
    inventory_objective_label.text = "Objective: %s" % objective_text
    party_heading_label.text = "Party (%d)" % party_lines.size()
    inventory_heading_label.text = "Recovered Supplies (%d)" % inventory_lines.size()
    party_list.text = _format_lines_for_panel(party_lines, "No allies deployed.")
    inventory_list.text = _format_lines_for_panel(inventory_lines, "No recovered supplies yet.")

func set_risk_forecast_cards(cards: Array[Dictionary]) -> void:
    _risk_forecast_cards.clear()
    _ensure_risk_forecast_surface()
    if _risk_forecast_root == null:
        return
    for child in _risk_forecast_root.get_children():
        child.queue_free()
    for raw_card in cards:
        var title := String(raw_card.get("title", "")).strip_edges()
        var detail := String(raw_card.get("detail", "")).strip_edges()
        if title.is_empty() and detail.is_empty():
            continue
        var normalized := {
            "title": title,
            "detail": detail,
        }
        _risk_forecast_cards.append(normalized)
        _risk_forecast_root.add_child(_make_risk_card(normalized))
    _risk_forecast_root.visible = not _risk_forecast_cards.is_empty()

func open_inventory_panel() -> void:
    if inventory_panel.visible:
        return

    _last_focus_owner = get_viewport().gui_get_focus_owner()
    overlay_scrim.show()
    inventory_panel.show()
    ui_cue_requested.emit("ui_inventory_open_01")
    menu_visibility_changed.emit(true)
    close_inventory_button.grab_focus()

func close_inventory_panel() -> void:
    if not inventory_panel.visible:
        return

    overlay_scrim.hide()
    inventory_panel.hide()
    ui_cue_requested.emit("ui_inventory_close_01")
    menu_visibility_changed.emit(false)
    if is_instance_valid(_last_focus_owner):
        _last_focus_owner.grab_focus()
    else:
        inventory_button.grab_focus()
    _last_focus_owner = null

func is_menu_open() -> bool:
    return inventory_panel.visible

func get_layout_snapshot() -> Dictionary:
    return {
        "compact": _compact_layout,
        "action_columns": actions_grid.columns,
        "action_button_min_height": inventory_button.custom_minimum_size.y,
        "inventory_body_orientation": "vertical" if inventory_body.vertical else "horizontal",
        "inventory_panel_size": inventory_panel.size,
        "oblivion_badge_visible": selection_label.text.contains("[망각"),
        "resource_cost_visible": resource_cost_label.visible,
        "top_bar_width": top_bar.size.x,
        "bottom_panel_width": bottom_panel.size.x,
        "top_bar_y": top_bar.position.y,
        "bottom_panel_y": bottom_panel.position.y,
        "frame_origin_x": _board_origin.x,
        "frame_width": _board_size.x
    }

func apply_layout_for_viewport_size(viewport_size: Vector2) -> void:
    _apply_layout_for_viewport_size(viewport_size)

func set_battle_frame_metrics(board_origin: Vector2, board_size: Vector2) -> void:
    _board_origin = board_origin
    _board_size = board_size
    _apply_layout_for_viewport_size(get_viewport_rect().size)

func dismiss_overlay_at_position(screen_position: Vector2) -> bool:
    if not inventory_panel.visible:
        return false

    var inventory_rect := _get_global_rect_for(inventory_panel)
    if inventory_rect.has_point(screen_position):
        return false

    close_inventory_panel()
    return true

func get_input_blocking_rects() -> Array[Rect2]:
    var rects: Array[Rect2] = []
    rects.append(_get_global_rect_for(top_bar))
    rects.append(_get_global_rect_for(bottom_panel))
    if overlay_scrim.visible:
        rects.append(_get_global_rect_for(overlay_scrim))
    if inventory_panel.visible:
        rects.append(_get_global_rect_for(inventory_panel))
    return rects

func show_result(result_text: String) -> void:
    _cache_result_text(result_text)
    result_popup.popup_centered()

func cache_result_text(result_text: String) -> void:
    _cache_result_text(result_text)

func _cache_result_text(result_text: String) -> void:
    var normalized_text := result_text.strip_edges()
    var lines := normalized_text.split("\n", false)
    _last_result_title = "Battle Result"
    _last_result_body = normalized_text
    if not lines.is_empty():
        var heading := String(lines[0]).strip_edges()
        if not heading.is_empty():
            _last_result_title = heading
            if lines.size() > 1:
                _last_result_body = "\n".join(lines.slice(1))
    result_popup.title = _last_result_title
    result_popup.dialog_text = _last_result_body

func get_result_snapshot() -> Dictionary:
    return {
        "title": _last_result_title,
        "body": _last_result_body,
        "visible": result_popup.visible,
    }

func show_result_screen(result: Dictionary) -> void:
    ## 전투 결과 전용 화면 표시 (구조화된 보상/기록/Burden-Trust).
    if result_screen != null:
        result_screen.show_result(result)

func _on_result_screen_confirmed() -> void:
    if result_screen != null:
        result_screen.hide_result()

func _unhandled_input(event: InputEvent) -> void:
    if not inventory_panel.visible:
        return

    if event.is_action_pressed("ui_cancel"):
        close_inventory_panel()
        get_viewport().set_input_as_handled()
        return

    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if dismiss_overlay_at_position(event.position):
            get_viewport().set_input_as_handled()
        return

    if event is InputEventScreenTouch and event.pressed:
        if dismiss_overlay_at_position(event.position):
            get_viewport().set_input_as_handled()

func _on_cancel_pressed() -> void:
    ui_cue_requested.emit("ui_common_cancel_01")
    cancel_requested.emit()

func _on_wait_pressed() -> void:
    ui_cue_requested.emit("ui_common_confirm_01")
    wait_requested.emit()

func _on_end_turn_pressed() -> void:
    ui_cue_requested.emit("battle_state_enemy_phase_01")
    end_turn_requested.emit()

func _on_overlay_scrim_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if dismiss_overlay_at_position(event.position):
            get_viewport().set_input_as_handled()
        return

    if event is InputEventScreenTouch and event.pressed:
        if dismiss_overlay_at_position(event.position):
            get_viewport().set_input_as_handled()

func _format_reason(reason: String, payload: Dictionary) -> String:
    if reason == "karon_phase_two" and not String(payload.get("phase_callout", "")).is_empty():
        var phase_callout := String(payload.get("phase_callout", "")).strip_edges()
        var subtitle := String(payload.get("subtitle", payload.get("effect", ""))).strip_edges()
        var line := String(payload.get("line", "")).strip_edges()
        var stakes := String(payload.get("stakes", "")).strip_edges()
        var segments: Array[String] = [phase_callout]
        if not subtitle.is_empty():
            segments.append(subtitle)
        if not line.is_empty():
            segments.append(line)
        if not stakes.is_empty():
            segments.append(stakes)
        return " | ".join(segments)
    if reason == "skill_targeting_active":
        var skill_name := _get_payload_label(payload, ["skill_name", "skill", "skill_id"], "Skill")
        return "%s | Select a highlighted target." % skill_name
    if reason == "skill_telegraphed":
        var skill_name := _get_payload_label(payload, ["skill_name", "skill", "skill_id"], "Skill")
        var target_name := _get_payload_label(payload, ["target_name", "target", "target_id"], "Target")
        return "%s | %s" % [skill_name, target_name]
    if reason == "skill_insufficient_resource":
        var blocked_skill_name := _get_payload_label(payload, ["skill_name", "skill", "skill_id"], "Skill")
        var cost_text := String(payload.get("cost", "")).strip_edges()
        return "%s unavailable%s" % [blocked_skill_name, ": %s" % cost_text if not cost_text.is_empty() else ""]
    if reason == "support_attack_resolved":
        var bond := int(payload.get("bond", 0))
        var damage := int(payload.get("damage", payload.get("count", 0)))
        var parts: Array[String] = []
        if bond > 0:
            parts.append("Bond %d" % bond)
        if damage > 0:
            parts.append("Damage %d" % damage)
        return "Support Attack Resolved" if parts.is_empty() else "Support Attack Resolved (%s)" % ", ".join(parts)
    if reason == "boss_phase_transition":
        return "Boss Phase: %s (%d%% HP, Round %d)" % [
            _to_title_words(str(payload.get("phase", ""))),
            int(payload.get("hp_percent", 0)),
            int(payload.get("round", 0))
        ]
    var normalized_reason := _to_title_words(reason)
    if payload.is_empty():
        return normalized_reason

    var entries: Array[String] = []
    var keys: Array = payload.keys()
    keys.sort()
    for key in keys:
        entries.append("%s %s" % [_to_title_words(str(key)), str(payload[key])])

    return "%s (%s)" % [normalized_reason, ", ".join(entries)]

func _ensure_risk_forecast_surface() -> void:
    if _risk_forecast_root != null and is_instance_valid(_risk_forecast_root):
        return
    var content: Control = $BottomPanel/Margin/Content
    _risk_forecast_root = VBoxContainer.new()
    _risk_forecast_root.name = "RiskForecastCards"
    _risk_forecast_root.visible = false
    _risk_forecast_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _risk_forecast_root.add_theme_constant_override("separation", 8)
    content.add_child(_risk_forecast_root)
    content.move_child(_risk_forecast_root, 0)

func _make_risk_card(card: Dictionary) -> PanelContainer:
    var panel := PanelContainer.new()
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.145, 0.114, 0.177, 0.96), Color(0.925, 0.765, 0.404, 0.72), 14))

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 12)
    margin.add_theme_constant_override("margin_top", 10)
    margin.add_theme_constant_override("margin_right", 12)
    margin.add_theme_constant_override("margin_bottom", 10)
    panel.add_child(margin)

    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 4)
    margin.add_child(stack)

    var title_label := Label.new()
    title_label.text = String(card.get("title", ""))
    title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    title_label.add_theme_font_size_override("font_size", 17)
    title_label.add_theme_color_override("font_color", Color(0.988, 0.949, 0.827, 0.98))
    stack.add_child(title_label)

    var detail_label_local := Label.new()
    detail_label_local.text = String(card.get("detail", ""))
    detail_label_local.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_label_local.add_theme_font_size_override("font_size", 14)
    detail_label_local.add_theme_color_override("font_color", Color(0.933, 0.898, 0.996, 0.94))
    stack.add_child(detail_label_local)
    return panel

func _format_lines_for_panel(lines: Array[String], fallback: String) -> String:
    if lines.is_empty():
        return "- %s" % fallback

    var rendered_text := ""
    for line in lines:
        if not rendered_text.is_empty():
            rendered_text += "\n"
        rendered_text += "- %s" % line
    return rendered_text

func _to_title_words(raw_text: String) -> String:
    var words := raw_text.replace("_", " ").split(" ", false)
    for index in range(words.size()):
        words[index] = String(words[index]).capitalize()
    return " ".join(words)

func _get_payload_label(payload: Dictionary, keys: Array[String], fallback: String = "") -> String:
    for key in keys:
        var raw_value := String(payload.get(key, "")).strip_edges()
        if raw_value.is_empty():
            continue
        return _to_title_words(raw_value)
    return fallback

func _get_global_rect_for(control: Control) -> Rect2:
    return Rect2(control.global_position, control.size)

func _update_status_display() -> void:
    round_label.text = "Round %d" % _current_round_number
    phase_label.text = "Phase: %s" % _current_phase_text
    var weather_icon := ""
    match _current_weather_type:
        "rain":
            weather_icon = "🌧️"
        "night":
            weather_icon = "🌙"
        _:
            weather_icon = "☀️"
    _status_weather_label.text = weather_icon

func _update_responsive_layout() -> void:
    _apply_layout_for_viewport_size(get_viewport_rect().size)

func _apply_layout_for_viewport_size(viewport_size: Vector2) -> void:
    _compact_layout = viewport_size.x <= COMPACT_WIDTH_THRESHOLD

    actions_grid.columns = 2 if _compact_layout else 4
    inventory_body.vertical = _compact_layout
    party_list.scroll_active = _compact_layout
    inventory_list.scroll_active = _compact_layout
    party_list.fit_content = not _compact_layout
    inventory_list.fit_content = not _compact_layout
    var action_button_height := COMPACT_ACTION_BUTTON_HEIGHT if _compact_layout else REGULAR_ACTION_BUTTON_HEIGHT
    for button in [inventory_button, cancel_button, wait_button, end_turn_button]:
        button.custom_minimum_size = Vector2(0.0, action_button_height)
    _refresh_inventory_dismiss_hint()

    if _compact_layout:
        top_bar.anchor_left = 0.0
        top_bar.anchor_right = 1.0
        top_bar.offset_left = 18.0
        top_bar.offset_right = -18.0
        top_bar.offset_top = 14.0
        top_bar.offset_bottom = COMPACT_TOPBAR_HEIGHT

        bottom_panel.anchor_left = 0.0
        bottom_panel.anchor_right = 1.0
        bottom_panel.offset_left = 18.0
        bottom_panel.offset_right = -18.0
        bottom_panel.offset_bottom = -18.0
        bottom_panel.offset_top = COMPACT_BOTTOMBAR_TOP

        inventory_panel.anchor_left = 0.0
        inventory_panel.anchor_top = 0.0
        inventory_panel.anchor_right = 1.0
        inventory_panel.anchor_bottom = 1.0
        inventory_panel.offset_left = COMPACT_PANEL_MARGIN
        inventory_panel.offset_top = COMPACT_PANEL_TOP_MARGIN
        inventory_panel.offset_right = -COMPACT_PANEL_MARGIN
        inventory_panel.offset_bottom = -COMPACT_PANEL_BOTTOM_MARGIN
    else:
        inventory_panel.anchor_left = 0.5
        inventory_panel.anchor_top = 0.5
        inventory_panel.anchor_right = 0.5
        inventory_panel.anchor_bottom = 0.5
        inventory_panel.offset_left = -REGULAR_PANEL_HALF_WIDTH
        inventory_panel.offset_top = -REGULAR_PANEL_HALF_HEIGHT
        inventory_panel.offset_right = REGULAR_PANEL_HALF_WIDTH
        inventory_panel.offset_bottom = REGULAR_PANEL_HALF_HEIGHT

        var frame_width: float = _board_size.x if _board_size.x > 0.0 else minf(viewport_size.x - 40.0, 820.0)
        var frame_left: float = _board_origin.x if _board_size.x > 0.0 else floor((viewport_size.x - frame_width) * 0.5)
        var frame_right: float = frame_left + frame_width

        var top_width: float = minf(frame_width + REGULAR_TOPBAR_PADDING * 2.0, REGULAR_TOPBAR_MAX_WIDTH)
        var top_left: float = frame_left + floor((frame_width - top_width) * 0.5)
        var top_right: float = top_left + top_width
        var frame_top: float = _board_origin.y if _board_size.y > 0.0 else 40.0
        var frame_bottom: float = _board_origin.y + _board_size.y if _board_size.y > 0.0 else viewport_size.y - 32.0
        var top_bar_y: float = maxf(6.0, frame_top - REGULAR_TOPBAR_HEIGHT - 8.0)
        var bottom_offset_bottom: float = -(viewport_size.y - frame_bottom + 12.0)

        top_bar.anchor_left = 0.0
        top_bar.anchor_right = 0.0
        top_bar.offset_left = top_left
        top_bar.offset_right = top_right
        top_bar.offset_top = top_bar_y
        top_bar.offset_bottom = top_bar_y + REGULAR_TOPBAR_HEIGHT

        bottom_panel.anchor_left = 0.0
        bottom_panel.anchor_right = 0.0
        bottom_panel.offset_left = frame_left - REGULAR_BOTTOMBAR_PADDING
        bottom_panel.offset_right = frame_right + REGULAR_BOTTOMBAR_PADDING
        bottom_panel.offset_bottom = bottom_offset_bottom
        bottom_panel.offset_top = bottom_offset_bottom - REGULAR_BOTTOMBAR_HEIGHT

func _apply_visual_theme() -> void:
    top_bar.add_theme_stylebox_override("panel", _make_panel_style(Color(0.063, 0.086, 0.114, 0.82), Color(0.224, 0.302, 0.396, 0.9), 18))
    bottom_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.055, 0.067, 0.094, 0.86), Color(0.251, 0.318, 0.424, 0.9), 20))
    inventory_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.071, 0.082, 0.11, 0.97), Color(0.329, 0.408, 0.529, 0.95), 22))
    telegraph_card.add_theme_stylebox_override("panel", _make_panel_style(Color(0.114, 0.094, 0.149, 0.94), Color(0.808, 0.565, 0.98, 0.72), 16))
    var selection_style := _make_panel_style(Color(0.102, 0.11, 0.137, 0.95), Color(0.365, 0.451, 0.608, 0.85), 18)
    ($BottomPanel/Margin/Content/SelectionCard as PanelContainer).add_theme_stylebox_override("panel", selection_style)
    stage_chip.add_theme_stylebox_override("panel", _make_panel_style(Color(0.102, 0.11, 0.153, 0.9), Color(0.482, 0.596, 0.761, 0.85), 14))

    for label in [round_label, phase_label, objective_label, landmark_label, selection_label, detail_label, resource_cost_label, hint_label, objective_hint_label, transition_reason_label, telegraph_label, telegraph_detail_label]:
        label.add_theme_color_override("font_color", Color(0.949, 0.965, 0.984, 1.0))

    stage_label.add_theme_color_override("font_color", Color(0.858824, 0.905882, 0.964706, 1.0))
    objective_label.add_theme_color_override("font_color", Color(0.784, 0.843, 0.918, 1.0))
    resource_cost_label.add_theme_color_override("font_color", Color(0.760784, 0.901961, 1.0, 0.98))
    hint_label.add_theme_color_override("font_color", Color(0.929, 0.824, 0.553, 1.0))
    objective_hint_label.add_theme_color_override("font_color", Color(0.941176, 0.882353, 0.682353, 0.98))
    landmark_label.add_theme_color_override("font_color", Color(0.74902, 0.839216, 0.917647, 0.98))
    transition_reason_label.add_theme_color_override("font_color", Color(0.667, 0.753, 0.863, 0.95))
    telegraph_detail_label.add_theme_color_override("font_color", Color(0.914, 0.824, 0.984, 0.98))

    _style_action_button(
        inventory_button,
        Color(0.164706, 0.317647, 0.615686, 0.98),
        Color(0.247059, 0.423529, 0.756863, 1.0),
        Color(0.552941, 0.741176, 1.0, 0.56),
        12,
        3
    )
    _style_action_button(
        cancel_button,
        Color(0.192157, 0.219608, 0.294118, 0.98),
        Color(0.262745, 0.301961, 0.4, 1.0),
        Color(0.592157, 0.647059, 0.792157, 0.38),
        12,
        2
    )
    _style_action_button(
        wait_button,
        Color(0.607843, 0.447059, 0.141176, 1.0),
        Color(0.780392, 0.592157, 0.184314, 1.0),
        Color(1.0, 0.866667, 0.458824, 0.8),
        14,
        4
    )
    _style_action_button(
        end_turn_button,
        Color(0.6, 0.2, 0.176471, 1.0),
        Color(0.764706, 0.278431, 0.247059, 1.0),
        Color(1.0, 0.666667, 0.627451, 0.78),
        14,
        4
    )
    _style_action_button(
        close_inventory_button,
        Color(0.286, 0.365, 0.478, 1.0),
        Color(0.365, 0.459, 0.588, 1.0),
        Color(0.756863, 0.839216, 0.941176, 0.4),
        12,
        2
    )
    wait_button.add_theme_constant_override("outline_size", 1)
    end_turn_button.add_theme_constant_override("outline_size", 1)

func _apply_runtime_button_icons() -> void:
    _assign_runtime_icon(inventory_button, "bag.png")
    _assign_runtime_icon(cancel_button, "back.png")
    _assign_runtime_icon(wait_button, "wait.png")
    _assign_runtime_icon(end_turn_button, "enemy.png")

func _assign_runtime_icon(button: Button, file_name: String) -> void:
    var icon_texture: Texture2D = _load_runtime_icon(file_name)
    if icon_texture == null:
        return
    button.icon = icon_texture
    button.expand_icon = true
    button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT

func _load_runtime_icon(file_name: String) -> Texture2D:
    return BattleArtCatalog.load_button_icon(file_name)

func _style_action_button(button: Button, base_color: Color, hover_color: Color, border_color: Color, radius: int, top_border_width: int) -> void:
    button.add_theme_color_override("font_color", Color(0.97, 0.98, 0.992, 1.0))
    button.add_theme_color_override("font_disabled_color", Color(0.72, 0.76, 0.82, 0.7))
    button.add_theme_stylebox_override("normal", _make_button_style(base_color, border_color, radius, top_border_width))
    button.add_theme_stylebox_override("hover", _make_button_style(hover_color, border_color.lightened(0.15), radius, top_border_width))
    button.add_theme_stylebox_override("pressed", _make_button_style(base_color.darkened(0.12), border_color, radius, max(2, top_border_width - 1)))
    button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.188, 0.2, 0.239, 0.9), Color(0.376471, 0.407843, 0.478431, 0.24), radius, 2))

func _make_panel_style(fill_color: Color, border_color: Color, radius: int) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = fill_color
    style.border_color = border_color
    style.set_border_width_all(2)
    style.set_corner_radius_all(radius)
    style.shadow_color = Color(0, 0, 0, 0.26)
    style.shadow_size = 8
    style.content_margin_left = 0
    style.content_margin_top = 0
    style.content_margin_right = 0
    style.content_margin_bottom = 0
    return style

func _make_button_style(fill_color: Color, border_color: Color, radius: int, top_border_width: int) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = fill_color
    style.border_color = border_color
    style.set_corner_radius_all(radius)
    style.border_width_top = top_border_width
    style.border_width_bottom = 1
    style.border_width_left = 1
    style.border_width_right = 1
    style.shadow_color = Color(0, 0, 0, 0.18)
    style.shadow_size = 3
    style.content_margin_left = 0
    style.content_margin_right = 0
    style.content_margin_top = 1
    style.content_margin_bottom = 0
    return style

func _refresh_action_button_emphasis() -> void:
    inventory_button.add_theme_color_override("font_color", Color(0.901961, 0.941176, 1.0, 0.98))
    cancel_button.add_theme_color_override("font_color", Color(0.909804, 0.92549, 0.968627, 0.98))
    wait_button.add_theme_color_override("font_color", Color(1.0, 0.960784, 0.831373, 1.0) if not wait_button.disabled else Color(0.72, 0.76, 0.82, 0.72))
    end_turn_button.add_theme_color_override("font_color", Color(1.0, 0.905882, 0.890196, 1.0) if not end_turn_button.disabled else Color(0.72, 0.76, 0.82, 0.72))
    inventory_button.text = "[] BAG"
    cancel_button.text = "< BACK"
    wait_button.text = "|| WAIT"
    end_turn_button.text = ">>> ENEMY"

func _refresh_inventory_dismiss_hint() -> void:
    var dismiss_hint := "Tap outside or press Back to close." if _compact_layout else "Click outside or press Esc to close."
    dismiss_hint_label.text = dismiss_hint
    close_inventory_button.tooltip_text = dismiss_hint

func _update_telegraph_surface(reason: String, payload: Dictionary = {}) -> void:
    match reason:
        "boss_mark_telegraphed":
            _show_telegraph_surface("mark", "Mark", "Marked unit will be charged next enemy turn.")
        "boss_charge_resolve":
            _show_telegraph_surface("charge", "Charge", "The marked lane is collapsing into a direct strike.")
        "boss_command_buff":
            _show_telegraph_surface("command", "Command", "Nearby hostiles gain pressure from the boss order.")
        "lete_phase_two":
            _show_telegraph_surface("danger", "Phase Shift", "Lete drops the ranged feint and rushes in berserk lines.")
        "lete_scatter_cover":
            _show_telegraph_surface("command", "Scatter", "The black-hound line slips through terrain and widens the pursuit arc.")
        "lete_smoke_bomb":
            _show_telegraph_surface("danger", "Smoke Bomb", "The squad loses the next turn unless the pressure breaks first.")
        "lete_route_cut":
            _show_telegraph_surface("heal", "Route Cut", "The latch gives way and Lete's deeper pursuit lane can no longer fully reform.")
        "karl_shield_wall":
            _show_telegraph_surface("command", "Shield Wall", "Kyle halves incoming damage for the next two player phases.")
        "karl_formation_call":
            _show_telegraph_surface("command", "Formation", "Kyle's line hardens; a reinforcement vanguard steps in.")
        "melkion_truth_rewrite":
            _show_telegraph_surface("mark", "Rewrite", "Melkion mirrors the last player skill and sends it back.")
        "melkion_revision_field":
            _show_telegraph_surface("mark", "Revision Field", "Melkion marks the whole squad and redraws safe lanes around the archive.")
        "melkion_revision_lock":
            _show_telegraph_surface("command", "Revision Lock", "Marked allies stay readable to the archive for the next exchange.")
        "melkion_memory_wipe":
            _show_telegraph_surface("danger", "Memory Wipe", "Player-side advantages are stripped away for the next exchange.")
        "melkion_archive_mode":
            _show_telegraph_surface("command", "Archive Mode", "Melkion triples his defense and fights only through specials.")
        "melkion_archive_stabilized":
            _show_telegraph_surface("heal", "Archive Stable", "The lectern holds the central archive tile steady and weakens the next rewrite.")
        "karon_name_call_anchor":
            _show_telegraph_surface("danger", "Anchor", "A name-call anchor is on the field, feeding Karuon's pressure.")
        "karon_royal_edict":
            _show_telegraph_surface("command", "Royal Edict", "Karuon suppresses party bonds and narrows the field to his order.")
        "karon_name_severance":
            _show_telegraph_surface("danger", "Name Severance", "Karuon pushes oblivion through the party before the final toll.")
        "karon_bell_line_broken":
            _show_telegraph_surface("heal", "Bell Line", "The anchor chain breaks and Karuon's bell choke no longer seals the central push.")
        "karon_phase_two":
            var telegraph_title := String(payload.get("telegraph_title", "")).strip_edges()
            var telegraph_detail := String(payload.get("telegraph_detail", "")).strip_edges()
            if telegraph_title.is_empty():
                telegraph_title = "Final Bell"
            if telegraph_detail.is_empty():
                telegraph_detail = "Karuon's second phase starts early and the whole field is in range."
            _show_telegraph_surface("charge", telegraph_title, telegraph_detail)
        "basil_flood_rise":
            _show_telegraph_surface("danger", "Flood Rise", "The altar floodline expands and the safe lanes narrow around Basil.")
        "basil_logs_at_risk":
            if bool(payload.get("lost", false)):
                _show_telegraph_surface("danger", "Research Logs Lost", "The flooded sanctuary swallowed the remaining research logs before they could be recovered.")
            else:
                _show_telegraph_surface("danger", "Research Logs At Risk", "The floodline has reached the research logs. Recover them before the sanctuary sinks further.")
        "saria_civilian_pressure":
            _show_telegraph_surface("danger", "Civilians At Risk", "Saria keeps tightening the prayer line. Secure the dais and seal before the queue collapses.")
        "saria_civilian_pressure_delayed":
            _show_telegraph_surface("charge", "Civilian Line Stabilized", "One objective is secured, buying a little more time before the queue collapses.")
        "saria_civilian_loss":
            _show_telegraph_surface("danger", "Civilian Line Lost", "The prayer queue broke before Mira could be pulled free.")
        "skill_targeting_active":
            var targeting_skill_name := _get_payload_label(payload, ["skill_name", "skill", "skill_id"], "Skill")
            _show_telegraph_surface("command", targeting_skill_name, "Select a highlighted target to confirm the skill.")
        "skill_telegraphed":
            var telegraphed_skill_name := _get_payload_label(payload, ["skill_name", "skill", "skill_id"], "Skill")
            var target_name := _get_payload_label(payload, ["target_name", "target", "target_id"], "Target")
            _show_telegraph_surface("charge", telegraphed_skill_name, "%s is about to be hit." % target_name)
        "skill_insufficient_resource":
            var blocked_skill_name := _get_payload_label(payload, ["skill_name", "skill", "skill_id"], "Skill")
            var cost_text := String(payload.get("cost", "")).strip_edges()
            _show_telegraph_surface("danger", "%s Unavailable" % blocked_skill_name, cost_text if not cost_text.is_empty() else "Required resources are missing.")
        "boss_phase_transition":
            _show_telegraph_surface("command", "Boss Phase", "%s phase triggered at %d%% HP." % [_to_title_words(str(payload.get("phase", ""))), int(payload.get("hp_percent", 0))])
        "enemy_phase_open", "enemy_decide":
            _show_telegraph_surface("danger", "Danger", "Enemy pressure is active. Recheck exposed lanes.")
        "interaction_resolved":
            _show_telegraph_surface("heal", "Support", "Objective progress is secured. Use the opening to reset formation.")
        "support_attack_resolved":
            _show_telegraph_surface("danger", "Support Attack", "Bond %d ally follow-up confirmed for %d damage." % [int(payload.get("bond", 0)), int(payload.get("damage", payload.get("count", 0)))])
        "support_rank_up":
            _show_telegraph_surface("heal", "Support Rank Up", "%s reached %s." % [String(payload.get("pair", "Support")), String(payload.get("rank", "새 랭크"))])
        "bond_damage_share":
            _show_telegraph_surface("heal", "Bond Share", "An adjacent ally with bond 5 took part of the damage instead.")
        "charm_forced_attack":
            _show_telegraph_surface("danger", "Charm", "A charmed ally lashed out at the nearest squadmate before orders could be restored.")
        "charm_restrained":
            _show_telegraph_surface("heal", "Charm Restrained", "A bond-5 ally held the charmed unit back before friendly fire could start.")
        "charm_cleansed":
            _show_telegraph_surface("heal", "Charm Cleansed", "The squad restored the charmed ally before the next forced action could start.")
        "charm_rescued":
            _show_telegraph_surface("heal", "Charm Rescue", "The charmed ally was pulled clear of the line before the next break in control.")
        _:
            _clear_telegraph_surface()

func _show_telegraph_surface(kind: String, label_text: String, detail_text: String) -> void:
    telegraph_card.visible = true
    telegraph_label.text = label_text
    telegraph_detail_label.text = detail_text
    telegraph_preview.texture = TelegraphTextureLibrary.get_texture(kind)

func _clear_telegraph_surface() -> void:
    telegraph_card.visible = false
    telegraph_label.text = "Telegraph"
    telegraph_detail_label.text = ""
    telegraph_preview.texture = null

func _emit_battle_cue_for_reason(reason: String) -> void:
    match reason:
        "civilian_rescued":
            ui_cue_requested.emit("civilian_rescued")
        "boss_mark_telegraphed":
            ui_cue_requested.emit("battle_boss_mark_warn_01")
        "boss_command_buff":
            ui_cue_requested.emit("battle_boss_command_warn_01")
        "boss_charge_resolve":
            ui_cue_requested.emit("battle_boss_charge_impact_01")
        "lete_phase_two", "lete_scatter_cover", "lete_smoke_bomb", "karl_shield_wall", "karl_formation_call", "melkion_truth_rewrite", "melkion_revision_field", "melkion_revision_lock", "melkion_memory_wipe", "melkion_archive_mode", "karon_name_call_anchor", "karon_royal_edict", "karon_name_severance", "karon_phase_two", "basil_flood_rise", "basil_logs_at_risk", "saria_civilian_pressure", "saria_civilian_pressure_delayed", "saria_civilian_loss":
            ui_cue_requested.emit("battle_boss_command_warn_01")
        "skill_targeting_active", "skill_telegraphed":
            ui_cue_requested.emit("skill_used")
        "skill_insufficient_resource":
            ui_cue_requested.emit("interaction_rejected")
        "attack_resolved_deterministic":
            ui_cue_requested.emit("battle_hit_confirm_01")
        "attack_missed":
            ui_cue_requested.emit("battle_miss_01")
        "attack_missed_counter_resolved", "counterattack_resolved":
            ui_cue_requested.emit("battle_counter_hit_01")
        "oblivion_stack_applied", "mind_control_applied", "assassin_mark_applied", "fear_applied", "skill_sealed":
            ui_cue_requested.emit("status_applied")
        "enemy_phase_open":
            ui_cue_requested.emit("battle_state_enemy_phase_01")
        "player_units_ready":
            ui_cue_requested.emit("battle_state_player_phase_01")
        "interaction_resolved":
            ui_cue_requested.emit("interaction_resolved")
        "interaction_rejected":
            ui_cue_requested.emit("interaction_rejected")
        "support_attack_resolved":
            ui_cue_requested.emit("support_attack")
        "support_rank_up":
            ui_cue_requested.emit("support_attack")
        "bond_damage_share":
            ui_cue_requested.emit("support_attack")
        "charm_forced_attack":
            ui_cue_requested.emit("status_applied")
        "charm_restrained":
            ui_cue_requested.emit("status_applied")
        "charm_cleansed", "charm_rescued":
            ui_cue_requested.emit("civilian_rescued")
        _:
            pass

func _should_hide_reason(reason: String) -> bool:
    return reason in [
        "controller_ready",
        "battle_initialized",
        "player_units_ready",
        "player_selection_cleared",
        "player_next_selection",
        "player_unit_selected"
    ]
