class_name BattleHUD
extends Control

const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const CommanderProfile = preload("res://scripts/battle/commander_profile.gd")
const EvolutionEvent = preload("res://scripts/battle/evolution_event.gd")
const TelegraphTextureLibrary = preload("res://scripts/battle/telegraph_texture_library.gd")

signal wait_requested
signal cancel_requested
signal end_turn_requested
signal menu_visibility_changed(is_open: bool)
signal ui_cue_requested(cue_id: String)
signal encyclopedia_requested
signal namecall_choice_selected(choice_id: String)

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
const STATUS_ICON_MAP := {
    &"fear": "😱",
    &"混乱": "💭",
    &"눈不适应": "👁️‍🗨️"
}
const MEMORIAL_MARKER_ICONS := {
    "flower": "🌸",
    "medal": "🏅",
    "candle": "🕯️"
}
const COMMANDER_FLAW_BADGE_TEXT := "완고"
const COMMANDER_FLAW_WARNING_TEXT := "당신의 指官官 결함이 드러난다!"

@onready var top_bar: PanelContainer = $TopBar
@onready var bottom_panel: PanelContainer = $BottomPanel
@onready var meta_row: HBoxContainer = $TopBar/Margin/TopRow/MetaRow
@onready var round_label: Label = $TopBar/Margin/TopRow/MetaRow/RoundLabel
@onready var phase_label: Label = $TopBar/Margin/TopRow/MetaRow/PhaseLabel
@onready var objective_label: Label = $TopBar/Margin/TopRow/ObjectiveLabel
@onready var stage_chip: PanelContainer = $TopBar/Margin/TopRow/StageChip
@onready var stage_label: Label = $TopBar/Margin/TopRow/StageChip/Padding/StageLabel
@onready var selection_card: PanelContainer = $BottomPanel/Margin/Content/SelectionCard
@onready var selection_stack: VBoxContainer = $BottomPanel/Margin/Content/SelectionCard/Padding/Stack
@onready var selection_label: Label = $BottomPanel/Margin/Content/SelectionCard/Padding/Stack/SelectionLabel
@onready var detail_label: Label = $BottomPanel/Margin/Content/SelectionCard/Padding/Stack/DetailLabel
@onready var quote_label: RichTextLabel = $BottomPanel/Margin/Content/SelectionCard/Padding/Stack/QuoteLabel
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
var result_screen: Node  ## BattleResultScreen — 전투 결과 전용 화면 (동적 로드)
var _party_list_container_compat: VBoxContainer
var party_list_container: VBoxContainer:
    get:
        return _party_list_container_compat

var _compact_layout: bool = false
var _current_round: int = 1
var _last_focus_owner: Control
var _board_origin: Vector2 = Vector2.ZERO
var _board_size: Vector2 = Vector2.ZERO
var _board_cell_size: Vector2 = Vector2.ZERO
var _last_result_title: String = "Battle Result"
var _last_result_body: String = ""
var _flood_margin_overlay: Control
var _flood_margin_cells: Array[Vector2i] = []
var _stage_memorial_overlay: Control
var _stage_memorial_slot: Vector2i = Vector2i(-1, -1)
var _stage_memorial_data: Dictionary = {}
var _namecall_choice_overlay: Control
var _namecall_choice_panel: PanelContainer
var _namecall_choice_prompt_label: Label
var _namecall_choice_timer_bar: ProgressBar
var _namecall_choice_confirm_button: Button
var _namecall_choice_defer_button: Button
var _namecall_choice_duration: float = 0.0
var _namecall_choice_time_left: float = 0.0
var _commander_flaw_detector: Node
var _commander_flaw_chip: PanelContainer
var _commander_flaw_chip_label: Label
var _commander_flaw_selection_row: HBoxContainer
var _commander_flaw_badge: PanelContainer
var _commander_flaw_badge_label: Label
var _commander_flaw_warning_label: Label
var _commander_flaw_warning_tween: Tween
var _evolution_warning_label: Label
var _evolution_border_overlay: Control
var _evolution_border_tween: Tween
var _tactical_note_bonus_chip: PanelContainer
var _tactical_note_bonus_label: Label

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    _ensure_party_list_container_compat()
    cancel_button.pressed.connect(_on_cancel_pressed)
    wait_button.pressed.connect(_on_wait_pressed)
    end_turn_button.pressed.connect(_on_end_turn_pressed)
    inventory_button.pressed.connect(open_inventory_panel)
    close_inventory_button.pressed.connect(close_inventory_panel)
    overlay_scrim.gui_input.connect(_on_overlay_scrim_gui_input)
    overlay_scrim.hide()
    inventory_panel.hide()
    # BattleResultScreen 동적 로드
    var ResultScreenScene = load("res://scenes/battle/BattleResultScreen.tscn")
    if ResultScreenScene != null:
        result_screen = ResultScreenScene.instantiate()
        add_child(result_screen)
        result_screen.result_confirmed.connect(_on_result_screen_confirmed)
        if result_screen.has_signal("encyclopedia_requested"):
            result_screen.encyclopedia_requested.connect(_on_result_screen_encyclopedia_requested)
    clear_selection()
    set_action_hint("Tap a ready ally to act.")
    set_buttons_state(false, false, true)
    set_objective("Defeat all enemies.")
    set_stage_title("Tutorial Skirmish")
    _clear_telegraph_surface()
    get_viewport().size_changed.connect(_update_responsive_layout)
    _build_flood_margin_overlay()
    _build_stage_memorial_overlay()
    _build_namecall_choice_overlay()
    _build_commander_flaw_ui()
    _build_evolution_warning_ui()
    _build_tactical_note_bonus_ui()
    _connect_commander_flaw_detector()
    _update_responsive_layout()
    _apply_runtime_button_icons()
    _apply_visual_theme()
    _refresh_action_button_emphasis()
    _refresh_inventory_dismiss_hint()
    _update_commander_flaws()
    set_process(false)

func _process(delta: float) -> void:
    if _namecall_choice_overlay == null or not _namecall_choice_overlay.visible:
        return
    _namecall_choice_time_left = maxf(0.0, _namecall_choice_time_left - delta)
    _update_namecall_choice_timer_bar()
    if _namecall_choice_time_left <= 0.0:
        select_namecall_choice("accept")

func set_phase(phase_text: String) -> void:
    phase_label.text = "Phase: %s" % phase_text

func set_round(round_number: int) -> void:
    _current_round = round_number
    round_label.text = "Round %d" % round_number

func set_objective(objective_text: String) -> void:
    objective_label.text = "Objective: %s" % objective_text

func set_stage_title(title_text: String) -> void:
    stage_label.text = title_text
    stage_chip.visible = not title_text.strip_edges().is_empty()

func set_tactical_note_bonus(multiplier: float) -> void:
    if _tactical_note_bonus_chip == null:
        _build_tactical_note_bonus_ui()
    var bonus_percent := maxi(0, int(round((maxf(multiplier, 1.0) - 1.0) * 100.0)))
    _tactical_note_bonus_chip.visible = bonus_percent > 0
    if _tactical_note_bonus_label != null:
        _tactical_note_bonus_label.text = "전술 보정: +%d%%" % bonus_percent
    _tactical_note_bonus_chip.tooltip_text = "전술 노트로 인한 전투 보정" if bonus_percent > 0 else ""

func set_transition_reason(reason: String, payload: Dictionary = {}) -> void:
    var formatted_reason: String = _format_reason(reason, payload)
    transition_reason_label.text = formatted_reason
    transition_reason_label.visible = not _should_hide_reason(reason)
    _update_telegraph_surface(reason)
    _emit_battle_cue_for_reason(reason)

func set_selection_summary(unit_name: String, hp_text: String, movement: int, attack_range: int, reachable_count: int, attackable_count: int, interactable_count: int, terrain_text: String = "", oblivion_stack: int = 0, combat_quote: String = "", statuses: Array[StringName] = []) -> void:
    selection_card.visible = true
    var display_name: String = unit_name
    var status_tokens: Array[String] = []
    if oblivion_stack > 0:
        status_tokens.append("망각 ×%d" % oblivion_stack)
    for status_name in statuses:
        if STATUS_ICON_MAP.has(status_name):
            status_tokens.append(String(STATUS_ICON_MAP[status_name]))
    if not status_tokens.is_empty():
        display_name += "  [%s]" % " ".join(status_tokens)
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
    var normalized_quote := combat_quote.strip_edges()
    quote_label.visible = not normalized_quote.is_empty()
    quote_label.text = "[i]Combat Quote: \"%s\"[/i]" % normalized_quote
    _update_commander_flaws()

func clear_selection() -> void:
    selection_card.visible = false
    selection_label.text = "No unit selected."
    detail_label.text = "Select a ready ally to inspect movement, attack range, and nearby objectives."
    quote_label.visible = false
    quote_label.text = ""
    _update_commander_flaws()

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
    _sync_party_list_container_compat(party_lines)
    inventory_list.text = _format_lines_for_panel(inventory_lines, "No recovered supplies yet.")

func _ensure_party_list_container_compat() -> void:
    if _party_list_container_compat != null:
        return
    _party_list_container_compat = VBoxContainer.new()
    _party_list_container_compat.name = "PartyListContainerCompat"
    _party_list_container_compat.visible = false
    add_child(_party_list_container_compat)

func _sync_party_list_container_compat(party_lines: Array[String]) -> void:
    _ensure_party_list_container_compat()
    for child in _party_list_container_compat.get_children():
        _party_list_container_compat.remove_child(child)
        child.queue_free()
    var lines_to_render := party_lines if not party_lines.is_empty() else ["No allies deployed."]
    for line in lines_to_render:
        var row := Label.new()
        row.text = line
        _party_list_container_compat.add_child(row)

func _build_commander_flaw_ui() -> void:
    if _commander_flaw_chip != null:
        return

    _commander_flaw_chip = PanelContainer.new()
    _commander_flaw_chip.name = "CommanderFlawChip"
    _commander_flaw_chip.visible = false
    meta_row.add_child(_commander_flaw_chip)

    var chip_padding := MarginContainer.new()
    chip_padding.add_theme_constant_override("margin_left", 8)
    chip_padding.add_theme_constant_override("margin_top", 2)
    chip_padding.add_theme_constant_override("margin_right", 8)
    chip_padding.add_theme_constant_override("margin_bottom", 2)
    _commander_flaw_chip.add_child(chip_padding)

    _commander_flaw_chip_label = Label.new()
    _commander_flaw_chip_label.text = COMMANDER_FLAW_BADGE_TEXT
    _commander_flaw_chip_label.add_theme_font_size_override("font_size", 10)
    chip_padding.add_child(_commander_flaw_chip_label)

    var selection_index := selection_label.get_index()
    _commander_flaw_selection_row = HBoxContainer.new()
    _commander_flaw_selection_row.name = "CommanderFlawSelectionRow"
    _commander_flaw_selection_row.add_theme_constant_override("separation", 6)
    selection_stack.add_child(_commander_flaw_selection_row)
    selection_stack.move_child(_commander_flaw_selection_row, selection_index)
    selection_stack.remove_child(selection_label)
    _commander_flaw_selection_row.add_child(selection_label)
    selection_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    _commander_flaw_badge = PanelContainer.new()
    _commander_flaw_badge.name = "CommanderFlawBadge"
    _commander_flaw_badge.visible = false
    _commander_flaw_selection_row.add_child(_commander_flaw_badge)

    var badge_padding := MarginContainer.new()
    badge_padding.add_theme_constant_override("margin_left", 6)
    badge_padding.add_theme_constant_override("margin_top", 1)
    badge_padding.add_theme_constant_override("margin_right", 6)
    badge_padding.add_theme_constant_override("margin_bottom", 1)
    _commander_flaw_badge.add_child(badge_padding)

    _commander_flaw_badge_label = Label.new()
    _commander_flaw_badge_label.text = COMMANDER_FLAW_BADGE_TEXT
    _commander_flaw_badge_label.add_theme_font_size_override("font_size", 10)
    badge_padding.add_child(_commander_flaw_badge_label)

    _commander_flaw_warning_label = Label.new()
    _commander_flaw_warning_label.name = "CommanderFlawWarningLabel"
    _commander_flaw_warning_label.visible = false
    _commander_flaw_warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _commander_flaw_warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _commander_flaw_warning_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
    var content: VBoxContainer = $BottomPanel/Margin/Content
    content.add_child(_commander_flaw_warning_label)
    content.move_child(_commander_flaw_warning_label, selection_card.get_index() + 1)

func _build_tactical_note_bonus_ui() -> void:
    if _tactical_note_bonus_chip != null:
        return

    _tactical_note_bonus_chip = PanelContainer.new()
    _tactical_note_bonus_chip.name = "TacticalNoteBonusChip"
    _tactical_note_bonus_chip.visible = false
    meta_row.add_child(_tactical_note_bonus_chip)

    var padding := MarginContainer.new()
    padding.add_theme_constant_override("margin_left", 8)
    padding.add_theme_constant_override("margin_top", 2)
    padding.add_theme_constant_override("margin_right", 8)
    padding.add_theme_constant_override("margin_bottom", 2)
    _tactical_note_bonus_chip.add_child(padding)

    _tactical_note_bonus_label = Label.new()
    _tactical_note_bonus_label.add_theme_font_size_override("font_size", 10)
    padding.add_child(_tactical_note_bonus_label)

func _connect_commander_flaw_detector() -> void:
    _commander_flaw_detector = get_node_or_null("/root/FlawDetector")
    if _commander_flaw_detector == null:
        return
    var profile_changed_callable := Callable(self, "_on_commander_flaw_profile_changed")
    if _commander_flaw_detector.has_signal("profile_changed") and not _commander_flaw_detector.is_connected("profile_changed", profile_changed_callable):
        _commander_flaw_detector.connect("profile_changed", profile_changed_callable)
    var warning_callable := Callable(self, "_on_commander_flaw_warning_requested")
    if _commander_flaw_detector.has_signal("flaw_warning_requested") and not _commander_flaw_detector.is_connected("flaw_warning_requested", warning_callable):
        _commander_flaw_detector.connect("flaw_warning_requested", warning_callable)

func _on_commander_flaw_profile_changed(_profile) -> void:
    _update_commander_flaws()

func _on_commander_flaw_warning_requested(message: String, _flaw_type: int) -> void:
    _flash_commander_flaw_warning(message)

func _update_commander_flaws() -> void:
    if _commander_flaw_chip == null or _commander_flaw_badge == null:
        return
    var is_active := false
    var tooltip := ""
    if _commander_flaw_detector == null:
        _commander_flaw_detector = get_node_or_null("/root/FlawDetector")
    if _commander_flaw_detector != null and _commander_flaw_detector.has_method("has_active_flaw"):
        is_active = bool(_commander_flaw_detector.call("has_active_flaw"))
        var profile: CommanderProfile = _commander_flaw_detector.get("current_profile") as CommanderProfile
        if profile != null:
            var profile_description: String = profile.flaw_description
            var label_text: String = String(CommanderProfile.get_flaw_name(profile.flaw_type))
            if _commander_flaw_detector.has_method("get_active_flaw_label"):
                label_text = String(_commander_flaw_detector.call("get_active_flaw_label"))
            tooltip = "%s\n%s" % [String(label_text), profile_description] if not profile_description.is_empty() else String(label_text)
    _commander_flaw_chip.visible = is_active
    _commander_flaw_badge.visible = is_active and selection_card.visible
    _commander_flaw_chip.tooltip_text = tooltip
    _commander_flaw_badge.tooltip_text = tooltip
    if not is_active and _commander_flaw_warning_label != null and not _commander_flaw_warning_label.visible:
        _commander_flaw_warning_label.text = ""

func _flash_commander_flaw_warning(message: String) -> void:
    if _commander_flaw_warning_label == null:
        return
    if _commander_flaw_warning_tween != null:
        _commander_flaw_warning_tween.kill()
    _commander_flaw_warning_label.text = message if not message.strip_edges().is_empty() else COMMANDER_FLAW_WARNING_TEXT
    _commander_flaw_warning_label.visible = true
    _commander_flaw_warning_label.modulate = Color(1.0, 0.925, 0.741, 0.0)
    _commander_flaw_warning_tween = create_tween()
    _commander_flaw_warning_tween.tween_property(_commander_flaw_warning_label, "modulate:a", 1.0, 0.15)
    _commander_flaw_warning_tween.tween_interval(1.05)
    _commander_flaw_warning_tween.tween_property(_commander_flaw_warning_label, "modulate:a", 0.0, 0.35)
    _commander_flaw_warning_tween.finished.connect(func() -> void:
        if _commander_flaw_warning_label != null:
            _commander_flaw_warning_label.visible = false
    )

func _build_evolution_warning_ui() -> void:
    if _evolution_warning_label != null:
        return

    _evolution_warning_label = Label.new()
    _evolution_warning_label.name = "EvolutionWarningLabel"
    _evolution_warning_label.visible = false
    _evolution_warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _evolution_warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _evolution_warning_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _evolution_warning_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
    _evolution_warning_label.offset_left = 120.0
    _evolution_warning_label.offset_top = 54.0
    _evolution_warning_label.offset_right = -120.0
    _evolution_warning_label.offset_bottom = 84.0
    _evolution_warning_label.add_theme_color_override("font_color", Color(1.0, 0.921569, 0.509804, 1.0))
    _evolution_warning_label.add_theme_font_size_override("font_size", 12)
    add_child(_evolution_warning_label)

    _evolution_border_overlay = Control.new()
    _evolution_border_overlay.name = "EvolutionBorderOverlay"
    _evolution_border_overlay.visible = false
    _evolution_border_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _evolution_border_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(_evolution_border_overlay)

    for border_name in ["Top", "Bottom", "Left", "Right"]:
        var edge := ColorRect.new()
        edge.name = "%sEdge" % border_name
        edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
        edge.color = Color(1.0, 0.886275, 0.352941, 0.92)
        _evolution_border_overlay.add_child(edge)

    var top_edge := _evolution_border_overlay.get_node("TopEdge") as ColorRect
    var bottom_edge := _evolution_border_overlay.get_node("BottomEdge") as ColorRect
    var left_edge := _evolution_border_overlay.get_node("LeftEdge") as ColorRect
    var right_edge := _evolution_border_overlay.get_node("RightEdge") as ColorRect

    top_edge.anchor_right = 1.0
    top_edge.offset_bottom = 6.0
    bottom_edge.anchor_top = 1.0
    bottom_edge.anchor_right = 1.0
    bottom_edge.offset_top = -6.0
    left_edge.anchor_bottom = 1.0
    left_edge.offset_right = 6.0
    right_edge.anchor_left = 1.0
    right_edge.anchor_bottom = 1.0
    right_edge.offset_left = -6.0

func _show_evolution_warning(event: EvolutionEvent) -> void:
    if _evolution_warning_label == null:
        return
    if event == null:
        clear_evolution_warning()
        return
    var turns_until_event := event.trigger_turn - _current_round
    if turns_until_event != 2:
        clear_evolution_warning()
        return
    _evolution_warning_label.text = "⚠ 지형이 불안정합니다 — %d턴 후: %s" % [turns_until_event, event.narrative_text]
    _evolution_warning_label.visible = true

func clear_evolution_warning() -> void:
    if _evolution_warning_label == null:
        return
    _evolution_warning_label.text = ""
    _evolution_warning_label.visible = false

func flash_evolution_occurrence() -> void:
    if _evolution_border_overlay == null:
        return
    if _evolution_border_tween != null:
        _evolution_border_tween.kill()
    _evolution_border_overlay.visible = true
    _evolution_border_overlay.modulate = Color(1.0, 1.0, 1.0, 0.95)
    _evolution_border_tween = create_tween()
    _evolution_border_tween.tween_property(_evolution_border_overlay, "modulate:a", 0.0, 0.4)
    _evolution_border_tween.finished.connect(func() -> void:
        if _evolution_border_overlay != null:
            _evolution_border_overlay.visible = false
    )

func _build_namecall_choice_overlay() -> void:
    if _namecall_choice_overlay != null:
        return
    _namecall_choice_overlay = Control.new()
    _namecall_choice_overlay.name = "NameCallChoiceOverlay"
    _namecall_choice_overlay.visible = false
    _namecall_choice_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    _namecall_choice_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(_namecall_choice_overlay)

    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    center.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _namecall_choice_overlay.add_child(center)

    _namecall_choice_panel = PanelContainer.new()
    _namecall_choice_panel.custom_minimum_size = Vector2(460.0, 0.0)
    _namecall_choice_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    center.add_child(_namecall_choice_panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 24)
    margin.add_theme_constant_override("margin_top", 24)
    margin.add_theme_constant_override("margin_right", 24)
    margin.add_theme_constant_override("margin_bottom", 24)
    _namecall_choice_panel.add_child(margin)

    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 16)
    margin.add_child(stack)

    var eyebrow := Label.new()
    eyebrow.text = "NAME CALL"
    eyebrow.add_theme_font_size_override("font_size", 14)
    stack.add_child(eyebrow)

    _namecall_choice_prompt_label = Label.new()
    _namecall_choice_prompt_label.text = "그 이름... 불러도 될까요?"
    _namecall_choice_prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _namecall_choice_prompt_label.add_theme_font_size_override("font_size", 24)
    stack.add_child(_namecall_choice_prompt_label)

    _namecall_choice_timer_bar = ProgressBar.new()
    _namecall_choice_timer_bar.show_percentage = false
    _namecall_choice_timer_bar.min_value = 0.0
    _namecall_choice_timer_bar.max_value = 100.0
    _namecall_choice_timer_bar.value = 100.0
    _namecall_choice_timer_bar.custom_minimum_size = Vector2(0.0, 18.0)
    stack.add_child(_namecall_choice_timer_bar)

    var button_row := HBoxContainer.new()
    button_row.add_theme_constant_override("separation", 12)
    stack.add_child(button_row)

    _namecall_choice_confirm_button = Button.new()
    _namecall_choice_confirm_button.text = "응"
    _namecall_choice_confirm_button.custom_minimum_size = Vector2(0.0, 58.0)
    _namecall_choice_confirm_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _namecall_choice_confirm_button.pressed.connect(func() -> void: select_namecall_choice("accept"))
    button_row.add_child(_namecall_choice_confirm_button)

    _namecall_choice_defer_button = Button.new()
    _namecall_choice_defer_button.text = "아직이다"
    _namecall_choice_defer_button.custom_minimum_size = Vector2(0.0, 58.0)
    _namecall_choice_defer_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _namecall_choice_defer_button.pressed.connect(func() -> void: select_namecall_choice("defer"))
    button_row.add_child(_namecall_choice_defer_button)
func _build_flood_margin_overlay() -> void:
    if _flood_margin_overlay != null:
        return
    _flood_margin_overlay = Control.new()
    _flood_margin_overlay.name = "FloodMarginOverlay"
    _flood_margin_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _flood_margin_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(_flood_margin_overlay)

func _build_stage_memorial_overlay() -> void:
    if _stage_memorial_overlay != null:
        return
    _stage_memorial_overlay = Control.new()
    _stage_memorial_overlay.name = "StageMemorialOverlay"
    _stage_memorial_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _stage_memorial_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(_stage_memorial_overlay)

func set_flood_margin_positions(cells: Array[Vector2i]) -> void:
    _flood_margin_cells = cells.duplicate()
    _refresh_flood_margin_overlay()

func set_stage_memorial(memorial_data: Dictionary, memorial_slot: Vector2i) -> void:
    _stage_memorial_data = memorial_data.duplicate(true)
    _stage_memorial_slot = memorial_slot
    _refresh_stage_memorial_overlay()

func get_stage_memorial_snapshot() -> Dictionary:
    return {
        "visible": _stage_memorial_overlay != null and _stage_memorial_overlay.get_child_count() > 0,
        "icon": _get_stage_memorial_icon(),
        "tooltip": _build_stage_memorial_tooltip(),
        "slot": _stage_memorial_slot
    }

func show_namecall_choice(prompt_text: String, duration: float = 3.0) -> void:
    if _namecall_choice_overlay == null:
        _build_namecall_choice_overlay()
    _last_focus_owner = get_viewport().gui_get_focus_owner()
    _namecall_choice_duration = maxf(duration, 0.1)
    _namecall_choice_time_left = _namecall_choice_duration
    if _namecall_choice_prompt_label != null:
        _namecall_choice_prompt_label.text = prompt_text
    _namecall_choice_overlay.show()
    _sync_modal_state()
    _update_namecall_choice_timer_bar()
    set_process(true)
    if _namecall_choice_confirm_button != null:
        _namecall_choice_confirm_button.grab_focus()

func hide_namecall_choice() -> void:
    if _namecall_choice_overlay == null or not _namecall_choice_overlay.visible:
        return
    _namecall_choice_time_left = 0.0
    _namecall_choice_duration = 0.0
    _namecall_choice_overlay.hide()
    set_process(false)
    _sync_modal_state()
    if not inventory_panel.visible:
        if is_instance_valid(_last_focus_owner):
            _last_focus_owner.grab_focus()
        elif inventory_button != null:
            inventory_button.grab_focus()
    _last_focus_owner = null

func select_namecall_choice(choice_id: String) -> void:
    if _namecall_choice_overlay == null or not _namecall_choice_overlay.visible:
        return
    var normalized_choice := choice_id.strip_edges().to_lower()
    if normalized_choice != "defer":
        normalized_choice = "accept"
    hide_namecall_choice()
    ui_cue_requested.emit("ui_common_confirm_01" if normalized_choice == "accept" else "ui_common_cancel_01")
    namecall_choice_selected.emit(normalized_choice)

func get_namecall_choice_snapshot() -> Dictionary:
    var progress_ratio: float = 0.0
    if _namecall_choice_duration > 0.0:
        progress_ratio = clampf(_namecall_choice_time_left / _namecall_choice_duration, 0.0, 1.0)
    return {
        "visible": _namecall_choice_overlay != null and _namecall_choice_overlay.visible,
        "prompt": _namecall_choice_prompt_label.text if _namecall_choice_prompt_label != null else "",
        "time_left": _namecall_choice_time_left,
        "duration": _namecall_choice_duration,
        "progress_ratio": progress_ratio,
        "accept_label": _namecall_choice_confirm_button.text if _namecall_choice_confirm_button != null else "",
        "defer_label": _namecall_choice_defer_button.text if _namecall_choice_defer_button != null else ""
    }

func _update_namecall_choice_timer_bar() -> void:
    if _namecall_choice_timer_bar == null:
        return
    var progress_ratio: float = 0.0
    if _namecall_choice_duration > 0.0:
        progress_ratio = clampf(_namecall_choice_time_left / _namecall_choice_duration, 0.0, 1.0)
    _namecall_choice_timer_bar.value = progress_ratio * 100.0

func _sync_modal_state() -> void:
    var has_modal := inventory_panel.visible or (_namecall_choice_overlay != null and _namecall_choice_overlay.visible)
    overlay_scrim.visible = has_modal
    menu_visibility_changed.emit(has_modal)

func open_inventory_panel() -> void:
    if inventory_panel.visible or (_namecall_choice_overlay != null and _namecall_choice_overlay.visible):
        return

    _last_focus_owner = get_viewport().gui_get_focus_owner()
    inventory_panel.show()
    _sync_modal_state()
    ui_cue_requested.emit("ui_inventory_open_01")
    close_inventory_button.grab_focus()

func close_inventory_panel() -> void:
    if not inventory_panel.visible:
        return

    inventory_panel.hide()
    _sync_modal_state()
    ui_cue_requested.emit("ui_inventory_close_01")
    if not (_namecall_choice_overlay != null and _namecall_choice_overlay.visible) and is_instance_valid(_last_focus_owner):
        _last_focus_owner.grab_focus()
    elif not (_namecall_choice_overlay != null and _namecall_choice_overlay.visible):
        inventory_button.grab_focus()
    if not (_namecall_choice_overlay != null and _namecall_choice_overlay.visible):
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
        "oblivion_badge_visible": selection_label.text.contains("망각"),
        "fear_icon_visible": selection_label.text.contains("😱"),
        "confusion_icon_visible": selection_label.text.contains("💭"),
        "night_smoke_icon_visible": selection_label.text.contains("👁️‍🗨️")
    }

func apply_layout_for_viewport_size(viewport_size: Vector2) -> void:
    _apply_layout_for_viewport_size(viewport_size)

func set_battle_frame_metrics(board_origin: Vector2, board_size: Vector2, board_cell_size: Vector2 = Vector2.ZERO) -> void:
    _board_origin = board_origin
    _board_size = board_size
    _board_cell_size = board_cell_size
    _refresh_flood_margin_overlay()
    _refresh_stage_memorial_overlay()
    _apply_layout_for_viewport_size(get_viewport_rect().size)

func _refresh_flood_margin_overlay() -> void:
    if _flood_margin_overlay == null:
        return
    for child in _flood_margin_overlay.get_children():
        child.queue_free()
    if _flood_margin_cells.is_empty() or _board_cell_size == Vector2.ZERO:
        return

    for cell in _flood_margin_cells:
        var icon := Label.new()
        icon.text = "🔴"
        icon.tooltip_text = "침수 구역"
        icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
        icon.add_theme_font_size_override("font_size", 16)
        icon.add_theme_color_override("font_color", Color(1.0, 0.411765, 0.411765, 0.96))
        icon.position = _board_origin + Vector2(
            cell.x * _board_cell_size.x + _board_cell_size.x - 18.0,
            cell.y * _board_cell_size.y + 2.0
        )
        _flood_margin_overlay.add_child(icon)

func _refresh_stage_memorial_overlay() -> void:
    if _stage_memorial_overlay == null:
        return
    for child in _stage_memorial_overlay.get_children():
        child.queue_free()
    if _stage_memorial_data.is_empty() or _board_cell_size == Vector2.ZERO or _stage_memorial_slot.x < 0 or _stage_memorial_slot.y < 0:
        return
    var marker := Label.new()
    marker.text = _get_stage_memorial_icon()
    marker.tooltip_text = _build_stage_memorial_tooltip()
    marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
    marker.add_theme_font_size_override("font_size", 22)
    marker.add_theme_color_override("font_color", Color(1.0, 0.956863, 0.905882, 0.98))
    marker.position = _board_origin + Vector2(
        _stage_memorial_slot.x * _board_cell_size.x + _board_cell_size.x * 0.5 - 12.0,
        _stage_memorial_slot.y * _board_cell_size.y + 4.0
    )
    _stage_memorial_overlay.add_child(marker)

func _get_stage_memorial_icon() -> String:
    var marker_type := String(_stage_memorial_data.get("marker_type", "flower")).strip_edges().to_lower()
    return String(MEMORIAL_MARKER_ICONS.get(marker_type, "🌸"))

func _build_stage_memorial_tooltip() -> String:
    var objective := String(_stage_memorial_data.get("objective", "")).strip_edges()
    if objective.is_empty():
        return ""
    return "이 땅은 당신의 선택을 기억합니다 — %s" % objective

func dismiss_overlay_at_position(screen_position: Vector2) -> bool:
    if _namecall_choice_overlay != null and _namecall_choice_overlay.visible:
        return false
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
    if _namecall_choice_overlay != null and _namecall_choice_overlay.visible:
        rects.append(_get_global_rect_for(_namecall_choice_overlay))
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

func _on_result_screen_encyclopedia_requested() -> void:
    encyclopedia_requested.emit()

func _unhandled_input(event: InputEvent) -> void:
    if _namecall_choice_overlay != null and _namecall_choice_overlay.visible:
        get_viewport().set_input_as_handled()
        return
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
    if reason == "damage_shared":
        return "Damage Shared (Bond %d, Share %d, Allies %d)" % [
            int(payload.get("bond", 0)),
            int(payload.get("share", 0)),
            int(payload.get("shared_units", 0))
        ]
    if reason.begins_with("spotlight_"):
        var headline := String(payload.get("headline", "")).strip_edges()
        return "Spotlight — %s" % (headline if not headline.is_empty() else _to_title_words(reason))
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
    if _namecall_choice_panel != null:
        _namecall_choice_panel.custom_minimum_size = Vector2(maxf(280.0, minf(460.0, viewport_size.x - 48.0)), 0.0)

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
    if _commander_flaw_chip != null:
        _commander_flaw_chip.add_theme_stylebox_override("panel", _make_panel_style(Color(0.235, 0.118, 0.114, 0.92), Color(0.925, 0.655, 0.298, 0.94), 14))
    if _commander_flaw_badge != null:
        _commander_flaw_badge.add_theme_stylebox_override("panel", _make_panel_style(Color(0.251, 0.129, 0.118, 0.94), Color(0.949, 0.733, 0.333, 0.94), 12))

    for label in [round_label, phase_label, objective_label, selection_label, detail_label, hint_label, transition_reason_label, telegraph_label, telegraph_detail_label]:
        label.add_theme_color_override("font_color", Color(0.949, 0.965, 0.984, 1.0))

    if _commander_flaw_chip_label != null:
        _commander_flaw_chip_label.add_theme_color_override("font_color", Color(1.0, 0.941, 0.816, 1.0))
    if _commander_flaw_badge_label != null:
        _commander_flaw_badge_label.add_theme_color_override("font_color", Color(1.0, 0.949, 0.847, 1.0))
    if _commander_flaw_warning_label != null:
        _commander_flaw_warning_label.add_theme_color_override("font_color", Color(1.0, 0.874, 0.639, 1.0))
        _commander_flaw_warning_label.add_theme_font_size_override("font_size", 11)

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
    if _namecall_choice_panel != null:
        _namecall_choice_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.09, 0.078, 0.106, 0.98), Color(0.835, 0.62, 0.341, 0.92), 24))
    if _namecall_choice_prompt_label != null:
        _namecall_choice_prompt_label.add_theme_color_override("font_color", Color(0.976, 0.957, 0.925, 1.0))
    if _namecall_choice_timer_bar != null:
        var timer_background := StyleBoxFlat.new()
        timer_background.bg_color = Color(0.173, 0.188, 0.235, 0.92)
        timer_background.set_corner_radius_all(10)
        _namecall_choice_timer_bar.add_theme_stylebox_override("background", timer_background)
        var timer_fill := StyleBoxFlat.new()
        timer_fill.bg_color = Color(0.925, 0.541, 0.176, 0.98)
        timer_fill.set_corner_radius_all(10)
        _namecall_choice_timer_bar.add_theme_stylebox_override("fill", timer_fill)
    if _namecall_choice_confirm_button != null:
        _style_action_button(
            _namecall_choice_confirm_button,
            Color(0.765, 0.388, 0.122, 1.0),
            Color(0.914, 0.49, 0.192, 1.0),
            Color(1.0, 0.816, 0.596, 0.84),
            16,
            4
        )
    if _namecall_choice_defer_button != null:
        _style_action_button(
            _namecall_choice_defer_button,
            Color(0.247, 0.267, 0.322, 1.0),
            Color(0.329, 0.357, 0.431, 1.0),
            Color(0.776, 0.816, 0.886, 0.42),
            16,
            2
        )

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
        "valgar_fortify_telegraphed":
            _show_telegraph_surface("command", "Fortify", "Valgar turns the lane into sustained pressure before the next charge.")
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
            _show_telegraph_surface("danger", "Support Attack", "An adjacent ally with bond 3+ added a follow-up strike.")
        "damage_shared":
            _show_telegraph_surface("support", "Bond Guard", "A bond 5 ally split the hit across the line.")
        "spotlight_triple_kill":
            _show_telegraph_surface("danger", "Carnage", "Three enemies dropped in one turn. The fight just tilted hard.")
        "spotlight_last_stand":
            _show_telegraph_surface("danger", "Stubborn Heart", "A near-fallen unit struck back from the edge of defeat.")
        "spotlight_weather_master":
            _show_telegraph_surface("support", "Harmony with Nature", "Multiple weather reactions chained together in a single turn.")
        "spotlight_sacrifice_play":
            _show_telegraph_surface("charge", "Last Words", "One ally fell to keep another alive through the action.")
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
        "valgar_fortify_telegraphed":
            ui_cue_requested.emit("battle_boss_command_warn_01")
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
