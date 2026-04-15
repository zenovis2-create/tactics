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
const REGULAR_PANEL_HALF_WIDTH := 312.0
const REGULAR_PANEL_HALF_HEIGHT := 220.0
const COMPACT_ACTION_BUTTON_HEIGHT := 72.0
const REGULAR_ACTION_BUTTON_HEIGHT := 28.0
const REGULAR_TOPBAR_PADDING := 4.0
const REGULAR_BOTTOMBAR_PADDING := 8.0
const REGULAR_TOPBAR_MAX_WIDTH := 440.0

@onready var top_bar: PanelContainer = $TopBar
@onready var bottom_panel: PanelContainer = $BottomPanel
@onready var round_label: Label = $TopBar/Margin/TopRow/MetaRow/RoundLabel
@onready var phase_label: Label = $TopBar/Margin/TopRow/MetaRow/PhaseLabel
@onready var objective_label: Label = $TopBar/Margin/TopRow/ObjectiveLabel
@onready var stage_chip: PanelContainer = $TopBar/Margin/TopRow/StageChip
@onready var stage_label: Label = $TopBar/Margin/TopRow/StageChip/Padding/StageLabel
@onready var selection_card: PanelContainer = $BottomPanel/Margin/Content/SelectionCard
@onready var selection_label: Label = $BottomPanel/Margin/Content/SelectionCard/Padding/Stack/SelectionLabel
@onready var detail_label: Label = $BottomPanel/Margin/Content/SelectionCard/Padding/Stack/DetailLabel
@onready var hint_label: Label = $BottomPanel/Margin/Content/HintLabel
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

var _compact_layout: bool = false
var _last_focus_owner: Control
var _board_origin: Vector2 = Vector2.ZERO
var _board_size: Vector2 = Vector2.ZERO
var _last_result_title: String = "Battle Result"
var _last_result_body: String = ""

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
    clear_selection()
    set_action_hint("Tap a ready ally to act.")
    set_buttons_state(false, false, true)
    set_objective("Defeat all enemies.")
    set_stage_title("Tutorial Skirmish")
    _clear_telegraph_surface()
    get_viewport().size_changed.connect(_update_responsive_layout)
    _update_responsive_layout()
    _apply_runtime_button_icons()
    _apply_visual_theme()
    _refresh_action_button_emphasis()
    _refresh_inventory_dismiss_hint()

func set_phase(phase_text: String) -> void:
    phase_label.text = "Phase: %s" % phase_text

func set_round(round_number: int) -> void:
    round_label.text = "Round %d" % round_number

func set_objective(objective_text: String) -> void:
    objective_label.text = "Objective: %s" % objective_text

func set_stage_title(title_text: String) -> void:
    stage_label.text = title_text
    stage_chip.visible = not title_text.strip_edges().is_empty()

func set_transition_reason(reason: String, payload: Dictionary = {}) -> void:
    var formatted_reason: String = _format_reason(reason, payload)
    transition_reason_label.text = formatted_reason
    transition_reason_label.visible = not _should_hide_reason(reason)
    _update_telegraph_surface(reason)
    _emit_battle_cue_for_reason(reason)

func set_selection_summary(unit_name: String, hp_text: String, movement: int, attack_range: int, reachable_count: int, attackable_count: int, interactable_count: int, terrain_text: String = "", oblivion_stack: int = 0) -> void:
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

func clear_selection() -> void:
    selection_card.visible = false
    selection_label.text = "No unit selected."
    detail_label.text = "Select a ready ally to inspect movement, attack range, and nearby objectives."

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
        "oblivion_badge_visible": selection_label.text.contains("[망각")
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
    result_popup.popup_centered()

func get_result_snapshot() -> Dictionary:
    return {
        "title": _last_result_title,
        "body": _last_result_body,
        "visible": result_popup.visible,
    }

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
    var normalized_reason := _to_title_words(reason)
    if payload.is_empty():
        return normalized_reason

    var entries: Array[String] = []
    var keys: Array = payload.keys()
    keys.sort()
    for key in keys:
        entries.append("%s %s" % [_to_title_words(str(key)), str(payload[key])])

    return "%s (%s)" % [normalized_reason, ", ".join(entries)]

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

func _get_global_rect_for(control: Control) -> Rect2:
    return Rect2(control.global_position, control.size)

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
        top_bar.offset_bottom = 72.0

        bottom_panel.anchor_left = 0.0
        bottom_panel.anchor_right = 1.0
        bottom_panel.offset_left = 18.0
        bottom_panel.offset_right = -18.0
        bottom_panel.offset_bottom = -18.0
        bottom_panel.offset_top = -154.0

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
        var top_left: float = frame_left
        var top_right: float = top_left + top_width

        top_bar.anchor_left = 0.0
        top_bar.anchor_right = 0.0
        top_bar.offset_left = top_left
        top_bar.offset_right = top_right
        top_bar.offset_top = 6.0
        top_bar.offset_bottom = 30.0

        bottom_panel.anchor_left = 0.0
        bottom_panel.anchor_right = 0.0
        bottom_panel.offset_left = frame_left - REGULAR_BOTTOMBAR_PADDING
        bottom_panel.offset_right = frame_right + REGULAR_BOTTOMBAR_PADDING
        bottom_panel.offset_bottom = -14.0
        bottom_panel.offset_top = -46.0

func _apply_visual_theme() -> void:
    top_bar.add_theme_stylebox_override("panel", _make_panel_style(Color(0.063, 0.086, 0.114, 0.82), Color(0.224, 0.302, 0.396, 0.9), 18))
    bottom_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.055, 0.067, 0.094, 0.86), Color(0.251, 0.318, 0.424, 0.9), 20))
    inventory_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.071, 0.082, 0.11, 0.97), Color(0.329, 0.408, 0.529, 0.95), 22))
    telegraph_card.add_theme_stylebox_override("panel", _make_panel_style(Color(0.114, 0.094, 0.149, 0.94), Color(0.808, 0.565, 0.98, 0.72), 16))
    var selection_style := _make_panel_style(Color(0.102, 0.11, 0.137, 0.95), Color(0.365, 0.451, 0.608, 0.85), 18)
    ($BottomPanel/Margin/Content/SelectionCard as PanelContainer).add_theme_stylebox_override("panel", selection_style)
    stage_chip.add_theme_stylebox_override("panel", _make_panel_style(Color(0.102, 0.11, 0.153, 0.9), Color(0.482, 0.596, 0.761, 0.85), 14))

    for label in [round_label, phase_label, objective_label, selection_label, detail_label, hint_label, transition_reason_label, telegraph_label, telegraph_detail_label]:
        label.add_theme_color_override("font_color", Color(0.949, 0.965, 0.984, 1.0))

    stage_label.add_theme_color_override("font_color", Color(0.858824, 0.905882, 0.964706, 1.0))
    objective_label.add_theme_color_override("font_color", Color(0.784, 0.843, 0.918, 1.0))
    hint_label.add_theme_color_override("font_color", Color(0.929, 0.824, 0.553, 1.0))
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

func _update_telegraph_surface(reason: String) -> void:
    match reason:
        "boss_mark_telegraphed":
            _show_telegraph_surface("mark", "Mark", "Marked unit will be charged next enemy turn.")
        "boss_charge_resolve":
            _show_telegraph_surface("charge", "Charge", "The marked lane is collapsing into a direct strike.")
        "boss_command_buff":
            _show_telegraph_surface("command", "Command", "Nearby hostiles gain pressure from the boss order.")
        "enemy_phase_open", "enemy_decide":
            _show_telegraph_surface("danger", "Danger", "Enemy pressure is active. Recheck exposed lanes.")
        "interaction_resolved":
            _show_telegraph_surface("heal", "Support", "Objective progress is secured. Use the opening to reset formation.")
        "support_attack_resolved":
            _show_telegraph_surface("danger", "Support Follow-Up", "An allied bond trigger added a follow-up strike.")
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
        "boss_mark_telegraphed":
            ui_cue_requested.emit("battle_boss_mark_warn_01")
        "boss_command_buff":
            ui_cue_requested.emit("battle_boss_command_warn_01")
        "boss_charge_resolve":
            ui_cue_requested.emit("battle_boss_charge_impact_01")
        "attack_resolved_deterministic":
            ui_cue_requested.emit("battle_hit_confirm_01")
        "attack_missed":
            ui_cue_requested.emit("battle_miss_01")
        "attack_missed_counter_resolved", "counterattack_resolved":
            ui_cue_requested.emit("battle_counter_hit_01")
        "enemy_phase_open":
            ui_cue_requested.emit("battle_state_enemy_phase_01")
        "player_units_ready":
            ui_cue_requested.emit("battle_state_player_phase_01")
        "interaction_resolved":
            ui_cue_requested.emit("camp_recommend_focus_01")
        "support_attack_resolved":
            ui_cue_requested.emit("battle_hit_confirm_01")
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
