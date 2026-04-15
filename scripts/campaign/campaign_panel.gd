class_name CampaignPanel
extends Control

const CampaignState = preload("res://scripts/campaign/campaign_state.gd")

signal advance_requested
signal save_panel_requested
signal deployment_assignment_requested(unit_id: StringName)
signal weapon_cycle_requested(unit_id: StringName)
signal armor_cycle_requested(unit_id: StringName)
signal accessory_cycle_requested(unit_id: StringName)
signal ui_cue_requested(cue_id: String)

const COMPACT_WIDTH_THRESHOLD := 760.0
const COMPACT_PANEL_MARGIN := 16.0
const COMPACT_PANEL_TOP_MARGIN := 16.0
const COMPACT_PANEL_BOTTOM_MARGIN := 16.0
const REGULAR_PANEL_HALF_WIDTH := 340.0
const REGULAR_PANEL_HALF_HEIGHT := 240.0
const COMPACT_TAB_BUTTON_HEIGHT := 56.0
const REGULAR_TAB_BUTTON_HEIGHT := 0.0
const COMPACT_PARTY_BUTTON_HEIGHT := 56.0
const REGULAR_PARTY_BUTTON_HEIGHT := 48.0
const PRIMARY_CTA_HEIGHT := 64.0
const SECTION_SUMMARY := "summary"
const SECTION_PARTY := "party"
const SECTION_INVENTORY := "inventory"
const SECTION_RECORDS := "records"
const SECTION_ORDER := [
    SECTION_SUMMARY,
    SECTION_PARTY,
    SECTION_INVENTORY,
    SECTION_RECORDS
]
const SECTION_HINTS := {
    SECTION_SUMMARY: "Start here. This section answers what changed and what to do next.",
    SECTION_PARTY: "Adjust lineup and loadout without losing the chapter context.",
    SECTION_INVENTORY: "Scan only the latest gear and supply changes from the last battle.",
    SECTION_RECORDS: "Review memories, evidence, and letters before leaving camp."
}
const BUTTON_LABELS := {
    SECTION_SUMMARY: "Summary",
    SECTION_PARTY: "Party",
    SECTION_INVENTORY: "Inventory",
    SECTION_RECORDS: "Records"
}
const WEAPON_FALLBACK_PREVIEW := "res://artifacts/ash36/ash36_weapon_sword_cutout_v1.png"
const ARMOR_FALLBACK_PREVIEW := "res://artifacts/ash36/ash36_armor_heavy_cutout_v1.png"
const ACCESSORY_FALLBACK_PREVIEW := "res://artifacts/ash37/ash37_accessory_memory_seal_variants_v1.png"

@onready var mode_label: Label = $Panel/Margin/Content/Header/ModeLabel
@onready var title_label: Label = $Panel/Margin/Content/Header/TitleLabel
@onready var alert_label: Label = $Panel/Margin/Content/Header/AlertLabel
@onready var flow_label: Label = $Panel/Margin/Content/Header/FlowLabel
@onready var recommendation_eyebrow_label: Label = $Panel/Margin/Content/RecommendationCard/Padding/RecommendationStack/RecommendationEyebrow
@onready var recommendation_label: Label = $Panel/Margin/Content/RecommendationCard/Padding/RecommendationStack/RecommendationLabel
@onready var party_overview_value_label: Label = $Panel/Margin/Content/OverviewStrip/PartyOverviewCard/Padding/Stack/Value
@onready var inventory_overview_value_label: Label = $Panel/Margin/Content/OverviewStrip/InventoryOverviewCard/Padding/Stack/Value
@onready var records_overview_value_label: Label = $Panel/Margin/Content/OverviewStrip/RecordsOverviewCard/Padding/Stack/Value
@onready var body_label: Label = $Panel/Margin/Content/BodyStack/SummarySection/BodyLabel
@onready var presentation_heading_label: Label = $Panel/Margin/Content/BodyStack/SummarySection/PresentationHeading
@onready var presentation_cards: VBoxContainer = $Panel/Margin/Content/BodyStack/SummarySection/PresentationCards
@onready var dialogue_label: RichTextLabel = $Panel/Margin/Content/BodyStack/SummarySection/DialogueList
@onready var section_tabs: GridContainer = $Panel/Margin/Content/SectionTabs
@onready var summary_button: Button = $Panel/Margin/Content/SectionTabs/SummaryButton
@onready var party_button: Button = $Panel/Margin/Content/SectionTabs/PartyButton
@onready var inventory_button: Button = $Panel/Margin/Content/SectionTabs/InventoryButton
@onready var records_button: Button = $Panel/Margin/Content/SectionTabs/RecordsButton
@onready var section_hint_label: Label = $Panel/Margin/Content/SectionHintLabel
@onready var summary_section: Control = $Panel/Margin/Content/BodyStack/SummarySection
@onready var party_section: Control = $Panel/Margin/Content/BodyStack/PartySection
@onready var inventory_section: Control = $Panel/Margin/Content/BodyStack/InventorySection
@onready var records_section: Control = $Panel/Margin/Content/BodyStack/RecordsSection
@onready var party_heading_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyHeading
@onready var party_content: BoxContainer = $Panel/Margin/Content/BodyStack/PartySection/PartyContent
@onready var party_roster_scroll: ScrollContainer = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/RosterColumn/RosterScroll
@onready var party_roster_buttons: VBoxContainer = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/RosterColumn/RosterScroll/RosterButtons
@onready var party_name_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SelectedUnitLabel
@onready var party_status_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/StatusLabel
@onready var party_stats_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/StatsLabel
@onready var weapon_preview: TextureRect = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/WeaponCard/Margin/Stack/Preview
@onready var weapon_item_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/WeaponCard/Margin/Stack/ItemLabel
@onready var weapon_hint_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/WeaponCard/Margin/Stack/HintLabel
@onready var armor_preview: TextureRect = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/ArmorCard/Margin/Stack/Preview
@onready var armor_item_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/ArmorCard/Margin/Stack/ItemLabel
@onready var armor_hint_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/ArmorCard/Margin/Stack/HintLabel
@onready var accessory_preview: TextureRect = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/AccessoryCard/Margin/Stack/Preview
@onready var accessory_item_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/AccessoryCard/Margin/Stack/ItemLabel
@onready var accessory_hint_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/AccessoryCard/Margin/Stack/HintLabel
@onready var party_assignment_button: Button = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/AssignmentButton
@onready var party_weapon_button: Button = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/WeaponCard/Margin/Stack/WeaponButton
@onready var party_armor_button: Button = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/ArmorCard/Margin/Stack/ArmorButton
@onready var party_accessory_button: Button = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/AccessoryCard/Margin/Stack/AccessoryButton
@onready var inventory_heading_label: Label = $Panel/Margin/Content/BodyStack/InventorySection/InventoryHeading
@onready var inventory_list: RichTextLabel = $Panel/Margin/Content/BodyStack/InventorySection/InventoryList
@onready var memory_heading_label: Label = $Panel/Margin/Content/BodyStack/RecordsSection/RecordsStack/MemoryHeading
@onready var memory_list: RichTextLabel = $Panel/Margin/Content/BodyStack/RecordsSection/RecordsStack/MemoryList
@onready var evidence_heading_label: Label = $Panel/Margin/Content/BodyStack/RecordsSection/RecordsStack/EvidenceHeading
@onready var evidence_list: RichTextLabel = $Panel/Margin/Content/BodyStack/RecordsSection/RecordsStack/EvidenceList
@onready var letter_heading_label: Label = $Panel/Margin/Content/BodyStack/RecordsSection/RecordsStack/LetterHeading
@onready var letter_list: RichTextLabel = $Panel/Margin/Content/BodyStack/RecordsSection/RecordsStack/LetterList
@onready var advance_button: Button = $Panel/Margin/Content/FooterRow/AdvanceButton
@onready var save_button: Button = $Panel/Margin/Content/FooterRow/SaveButton
@onready var panel: PanelContainer = $Panel

var _compact_layout: bool = false

var _current_mode: String = ""
var _current_recommendation: String = ""
var _current_flow_text: String = ""
var _party_entries: Array[String] = []
var _party_details: Array[Dictionary] = []
var _inventory_entries: Array[String] = []
var _memory_entries: Array[String] = []
var _evidence_entries: Array[String] = []
var _letter_entries: Array[String] = []
var _alerts: Array[String] = []
var _dialogue_entries: Array[String] = []
var _presentation_cards: Array[Dictionary] = []
var _active_section: String = SECTION_SUMMARY
var _selected_party_index: int = -1
var _section_badges: Dictionary = {}
var _deployment_limit: int = 2
var _deployed_party_unit_ids: Array[String] = []
var _locked_party_unit_ids: Array[String] = []
var _available_weapon_entries: Array[String] = []
var _available_armor_entries: Array[String] = []
var _available_accessory_entries: Array[String] = []

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    advance_button.pressed.connect(_on_advance_pressed)
    save_button.pressed.connect(_on_save_pressed)
    summary_button.pressed.connect(func() -> void: _select_section(SECTION_SUMMARY))
    party_button.pressed.connect(func() -> void: _select_section(SECTION_PARTY))
    inventory_button.pressed.connect(func() -> void: _select_section(SECTION_INVENTORY))
    records_button.pressed.connect(func() -> void: _select_section(SECTION_RECORDS))
    party_assignment_button.pressed.connect(_on_party_assignment_pressed)
    party_weapon_button.pressed.connect(_on_party_weapon_pressed)
    party_armor_button.pressed.connect(_on_party_armor_pressed)
    party_accessory_button.pressed.connect(_on_party_accessory_pressed)
    get_viewport().size_changed.connect(_update_responsive_layout)
    _update_responsive_layout()
    hide_panel()

func show_state(mode: String, title_text: String, body_text: String, button_text: String = "Continue", payload: Dictionary = {}) -> void:
    _current_mode = mode
    _current_recommendation = String(payload.get("recommendation", "Review the latest story and party state before moving on."))
    _current_flow_text = String(payload.get("flow_label", _build_default_flow_label(mode)))
    _party_entries = _variant_to_string_array(payload.get("party_entries", []))
    _party_details = _variant_to_dictionary_array(payload.get("party_details", []))
    _inventory_entries = _variant_to_string_array(payload.get("inventory_entries", []))
    _memory_entries = _variant_to_string_array(payload.get("memory_entries", []))
    _evidence_entries = _variant_to_string_array(payload.get("evidence_entries", []))
    _letter_entries = _variant_to_string_array(payload.get("letter_entries", []))
    _alerts = _variant_to_string_array(payload.get("alerts", []))
    _dialogue_entries = _variant_to_string_array(payload.get("dialogue_entries", []))
    _presentation_cards = _variant_to_dictionary_array(payload.get("presentation_cards", []))
    _section_badges = payload.get("section_badges", {})
    _deployment_limit = int(payload.get("deployment_limit", 2))
    _deployed_party_unit_ids = _variant_to_string_array(payload.get("deployed_party_unit_ids", []))
    _locked_party_unit_ids = _variant_to_string_array(payload.get("locked_party_unit_ids", []))
    _available_weapon_entries = _variant_to_string_array(payload.get("available_weapon_entries", []))
    _available_armor_entries = _variant_to_string_array(payload.get("available_armor_entries", []))
    _available_accessory_entries = _variant_to_string_array(payload.get("available_accessory_entries", []))

    mode_label.text = mode.capitalize()
    title_label.text = title_text
    alert_label.text = _format_alerts(_alerts)
    flow_label.text = _current_flow_text
    recommendation_eyebrow_label.text = _build_recommendation_eyebrow(mode)
    recommendation_label.text = _current_recommendation
    party_overview_value_label.text = "%d ready" % _party_details.size()
    inventory_overview_value_label.text = "%d updates" % _inventory_entries.size()
    records_overview_value_label.text = "%d new" % _get_records_count()
    party_heading_label.text = "Party / Loadout (%d)" % _party_details.size()
    body_label.text = body_text
    presentation_heading_label.text = _build_presentation_heading(mode)
    inventory_heading_label.text = "Inventory Updates (%d)" % _inventory_entries.size()
    dialogue_label.text = _format_dialogue_for_panel(_dialogue_entries, "No interlude dialogue unlocked yet.")
    inventory_list.text = _format_lines_for_panel(_inventory_entries, "No inventory updates yet.")
    memory_heading_label.text = "Memory (%d)" % _memory_entries.size()
    memory_list.text = _format_lines_for_panel(_memory_entries, "No memory fragments logged yet.")
    evidence_heading_label.text = "Evidence (%d)" % _evidence_entries.size()
    evidence_list.text = _format_lines_for_panel(_evidence_entries, "No evidence logged yet.")
    letter_heading_label.text = "Letters (%d)" % _letter_entries.size()
    letter_list.text = _format_lines_for_panel(_letter_entries, "No letters received yet.")
    advance_button.text = button_text
    advance_button.custom_minimum_size = Vector2(0.0, PRIMARY_CTA_HEIGHT)
    save_button.visible = mode == CampaignState.MODE_CAMP
    save_button.disabled = mode != CampaignState.MODE_CAMP
    _sync_section_button_text()
    _rebuild_presentation_cards()

    _rebuild_party_roster()
    _select_section(String(payload.get("active_section", SECTION_SUMMARY)))
    var selected_party_unit_id := String(payload.get("selected_party_unit_id", ""))
    if not selected_party_unit_id.is_empty() and _select_party_by_unit_id(selected_party_unit_id):
        pass
    else:
        _select_party_index(int(payload.get("selected_party_index", 0)))
    visible = true

func hide_panel() -> void:
    _current_mode = ""
    _current_recommendation = ""
    _current_flow_text = ""
    _party_entries.clear()
    _party_details.clear()
    _inventory_entries.clear()
    _memory_entries.clear()
    _evidence_entries.clear()
    _letter_entries.clear()
    _alerts.clear()
    _dialogue_entries.clear()
    _presentation_cards.clear()
    _section_badges.clear()
    _deployment_limit = 2
    _deployed_party_unit_ids.clear()
    _locked_party_unit_ids.clear()
    _available_weapon_entries.clear()
    _available_armor_entries.clear()
    _available_accessory_entries.clear()
    _active_section = SECTION_SUMMARY
    _selected_party_index = -1
    mode_label.text = ""
    title_label.text = ""
    alert_label.text = ""
    flow_label.text = ""
    recommendation_eyebrow_label.text = "Next Step"
    recommendation_label.text = ""
    party_overview_value_label.text = "0 ready"
    inventory_overview_value_label.text = "0 updates"
    records_overview_value_label.text = "0 new"
    section_hint_label.text = ""
    party_heading_label.text = "Party / Loadout"
    body_label.text = ""
    presentation_heading_label.text = "Handoff"
    for child in presentation_cards.get_children():
        child.queue_free()
    dialogue_label.text = ""
    party_name_label.text = ""
    party_status_label.text = ""
    party_stats_label.text = ""
    weapon_item_label.text = "No weapon equipped."
    weapon_hint_label.text = "No alternate weapons unlocked."
    armor_item_label.text = "No armor equipped."
    armor_hint_label.text = "No alternate armor unlocked."
    accessory_item_label.text = "No accessory equipped."
    accessory_hint_label.text = "No accessories unlocked."
    party_assignment_button.text = "Assign"
    party_assignment_button.disabled = true
    party_assignment_button.tooltip_text = "Select a party member to manage sortie assignment."
    party_weapon_button.text = "No Weapons"
    party_weapon_button.disabled = true
    party_weapon_button.tooltip_text = "Unlock or recover weapons before cycling a loadout."
    party_armor_button.text = "No Armor"
    party_armor_button.disabled = true
    party_armor_button.tooltip_text = "Unlock or recover armor before cycling a loadout."
    party_accessory_button.text = "Equip Accessory"
    party_accessory_button.disabled = true
    party_accessory_button.tooltip_text = "Unlock or recover accessories before equipping one."
    save_button.visible = false
    save_button.disabled = true
    inventory_heading_label.text = "Inventory Updates"
    inventory_list.text = ""
    memory_heading_label.text = "Memory"
    memory_list.text = ""
    evidence_heading_label.text = "Evidence"
    evidence_list.text = ""
    letter_heading_label.text = "Letters"
    letter_list.text = ""
    for child in party_roster_buttons.get_children():
        child.queue_free()
    visible = false

func get_snapshot() -> Dictionary:
    return {
        "mode": _current_mode,
        "title": title_label.text,
        "body": body_label.text,
        "visible": visible,
        "recommendation": _current_recommendation,
        "flow_text": _current_flow_text,
        "section_hint": section_hint_label.text,
        "party_entries": _party_entries.duplicate(),
        "party_details": _party_details.duplicate(true),
        "inventory_entries": _inventory_entries.duplicate(),
        "memory_entries": _memory_entries.duplicate(),
        "evidence_entries": _evidence_entries.duplicate(),
        "letter_entries": _letter_entries.duplicate(),
        "alerts": _alerts.duplicate(),
        "dialogue_entries": _dialogue_entries.duplicate(),
        "presentation_cards": _presentation_cards.duplicate(true),
        "active_section": _active_section,
        "selected_party_name": _get_selected_party_name(),
        "selected_party_unit_id": _get_selected_party_unit_id(),
        "section_badges": _section_badges.duplicate(true),
        "deployed_party_unit_ids": _deployed_party_unit_ids.duplicate(),
        "locked_party_unit_ids": _locked_party_unit_ids.duplicate(),
        "available_weapon_entries": _available_weapon_entries.duplicate(),
        "available_armor_entries": _available_armor_entries.duplicate(),
        "available_accessory_entries": _available_accessory_entries.duplicate()
    }

func get_layout_snapshot() -> Dictionary:
    return {
        "compact": _compact_layout,
        "tab_columns": section_tabs.columns,
        "tab_button_min_height": summary_button.custom_minimum_size.y,
        "party_content_orientation": "vertical" if party_content.vertical else "horizontal",
        "panel_size": panel.size
    }

func apply_layout_for_viewport_size(viewport_size: Vector2) -> void:
    _apply_layout_for_viewport_size(viewport_size)

func select_party_index(index: int) -> void:
    _select_party_index(index)

func select_party_by_unit_id(unit_id: String) -> bool:
    return _select_party_by_unit_id(unit_id)

func _select_section(section_name: String) -> void:
    if not SECTION_ORDER.has(section_name):
        section_name = SECTION_SUMMARY

    _active_section = section_name
    summary_section.visible = section_name == SECTION_SUMMARY
    party_section.visible = section_name == SECTION_PARTY
    inventory_section.visible = section_name == SECTION_INVENTORY
    records_section.visible = section_name == SECTION_RECORDS
    section_hint_label.text = _get_section_hint(section_name)

    summary_button.disabled = section_name == SECTION_SUMMARY
    party_button.disabled = section_name == SECTION_PARTY
    inventory_button.disabled = section_name == SECTION_INVENTORY
    records_button.disabled = section_name == SECTION_RECORDS
    ui_cue_requested.emit("ui_panel_tab_shift_01")

func _sync_section_button_text() -> void:
    summary_button.text = _compose_section_label(SECTION_SUMMARY)
    party_button.text = _compose_section_label(SECTION_PARTY)
    inventory_button.text = _compose_section_label(SECTION_INVENTORY)
    records_button.text = _compose_section_label(SECTION_RECORDS)
    summary_button.tooltip_text = _build_section_tooltip(SECTION_SUMMARY)
    party_button.tooltip_text = _build_section_tooltip(SECTION_PARTY)
    inventory_button.tooltip_text = _build_section_tooltip(SECTION_INVENTORY)
    records_button.tooltip_text = _build_section_tooltip(SECTION_RECORDS)

func _compose_section_label(section_name: String) -> String:
    var base_label: String = String(BUTTON_LABELS.get(section_name, section_name.capitalize()))
    var badge_text: String = String(_section_badges.get(section_name, "")).strip_edges()
    if badge_text.is_empty():
        return base_label
    return "%s [%s]" % [base_label, badge_text]

func _build_default_flow_label(mode: String) -> String:
    match mode:
        CampaignState.MODE_BATTLE:
            return "Battle active -> Resolve objective -> Camp"
        CampaignState.MODE_CUTSCENE:
            return "Battle clear -> Field report -> Next stage"
        CampaignState.MODE_CAMP:
            return "Battle clear -> Camp review -> Next battle"
        CampaignState.MODE_CHAPTER_INTRO:
            return "Camp exit -> Mission brief -> Deploy"
        CampaignState.MODE_COMPLETE:
            return "Chapter complete -> Await next destination"
        _:
            return "Loop state active"

func _build_recommendation_eyebrow(mode: String) -> String:
    match mode:
        CampaignState.MODE_CUTSCENE:
            return "Handoff"
        CampaignState.MODE_CAMP:
            return "Next Step"
        CampaignState.MODE_CHAPTER_INTRO:
            return "Mission Brief"
        CampaignState.MODE_COMPLETE:
            return "Status"
        _:
            return "Objective"

func _build_presentation_heading(mode: String) -> String:
    match mode:
        CampaignState.MODE_CAMP:
            return "Camp Handoff"
        CampaignState.MODE_CUTSCENE:
            return "Field Report"
        CampaignState.MODE_CHAPTER_INTRO:
            return "Mission Cards"
        CampaignState.MODE_COMPLETE:
            return "Resolution"
        _:
            return "Handoff"

func _get_records_count() -> int:
    return _memory_entries.size() + _evidence_entries.size() + _letter_entries.size()

func _get_section_hint(section_name: String) -> String:
    return String(SECTION_HINTS.get(section_name, "Review the latest changes first, then open details only if needed."))

func _build_section_tooltip(section_name: String) -> String:
    var base_label: String = String(BUTTON_LABELS.get(section_name, section_name.capitalize()))
    if section_name == _active_section:
        return "%s is already open. %s" % [base_label, _get_section_hint(section_name)]
    return "%s. %s" % [base_label, _get_section_hint(section_name)]

func _variant_to_string_array(value: Variant) -> Array[String]:
    var lines: Array[String] = []
    match typeof(value):
        TYPE_ARRAY, TYPE_PACKED_STRING_ARRAY:
            for entry in value:
                lines.append(String(entry))
        _:
            return lines
    return lines

func _variant_to_dictionary_array(value: Variant) -> Array[Dictionary]:
    var details: Array[Dictionary] = []
    if typeof(value) != TYPE_ARRAY:
        return details

    for entry in value:
        if typeof(entry) == TYPE_DICTIONARY:
            details.append(entry)
    return details

func _format_lines_for_panel(lines: Array[String], fallback: String) -> String:
    if lines.is_empty():
        return "- %s" % fallback

    var rendered_text := ""
    for line in lines:
        if not rendered_text.is_empty():
            rendered_text += "\n"
        rendered_text += "- %s" % line
    return rendered_text

func _format_dialogue_for_panel(lines: Array[String], fallback: String) -> String:
    if lines.is_empty():
        return "- %s" % fallback

    var rendered_text := ""
    for line in lines:
        if not rendered_text.is_empty():
            rendered_text += "\n\n"
        var separator_index: int = line.find(":")
        if separator_index > 0:
            var speaker: String = line.substr(0, separator_index).strip_edges()
            var dialogue: String = line.substr(separator_index + 1).strip_edges()
            rendered_text += "[b]%s[/b]\n%s" % [speaker, dialogue]
        else:
            rendered_text += line
    return rendered_text

func _format_alerts(lines: Array[String]) -> String:
    var rendered_text := ""
    for line in lines:
        if not rendered_text.is_empty():
            rendered_text += "   |   "
        rendered_text += line
    return rendered_text

func _rebuild_presentation_cards() -> void:
    for child in presentation_cards.get_children():
        child.queue_free()

    if _presentation_cards.is_empty():
        presentation_heading_label.visible = false
        presentation_cards.visible = false
        return

    presentation_heading_label.visible = true
    presentation_cards.visible = true

    for entry in _presentation_cards:
        var card := PanelContainer.new()
        var margin := MarginContainer.new()
        margin.add_theme_constant_override("margin_left", 12)
        margin.add_theme_constant_override("margin_top", 10)
        margin.add_theme_constant_override("margin_right", 12)
        margin.add_theme_constant_override("margin_bottom", 10)

        var stack := VBoxContainer.new()
        stack.add_theme_constant_override("separation", 4)

        var eyebrow := Label.new()
        eyebrow.text = str(entry.get("eyebrow", "Update"))
        eyebrow.add_theme_font_size_override("font_size", 14)

        var title := Label.new()
        title.text = str(entry.get("title", ""))
        title.add_theme_font_size_override("font_size", 18)
        title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

        var body := Label.new()
        body.text = str(entry.get("body", ""))
        body.add_theme_font_size_override("font_size", 16)
        body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

        stack.add_child(eyebrow)
        stack.add_child(title)
        stack.add_child(body)
        margin.add_child(stack)
        card.add_child(margin)
        presentation_cards.add_child(card)

func _rebuild_party_roster() -> void:
    for child in party_roster_buttons.get_children():
        child.queue_free()

    if _party_details.is_empty():
        var empty_label := Label.new()
        empty_label.text = "No party members available."
        empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        party_roster_buttons.add_child(empty_label)
        return

    for index in _party_details.size():
        var entry: Dictionary = _party_details[index]
        var button := Button.new()
        button.custom_minimum_size = Vector2(0.0, _get_party_button_height())
        button.text = String(entry.get("name", "Unit"))
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        var button_index := index
        button.pressed.connect(func() -> void: _select_party_index(button_index))
        party_roster_buttons.add_child(button)

func _select_party_index(index: int) -> void:
    if _party_details.is_empty():
        _selected_party_index = -1
        _render_selected_party({})
        return

    _selected_party_index = clampi(index, 0, _party_details.size() - 1)
    _render_selected_party(_party_details[_selected_party_index])
    _sync_party_button_state()
    ui_cue_requested.emit("camp_party_select_01")
    if _selected_party_index < party_roster_buttons.get_child_count():
        var roster_entry := party_roster_buttons.get_child(_selected_party_index)
        if roster_entry is Control:
            party_roster_scroll.ensure_control_visible(roster_entry)

func _select_party_by_unit_id(unit_id: String) -> bool:
    var normalized_unit_id := unit_id.strip_edges()
    if normalized_unit_id.is_empty():
        return false

    for index in range(_party_details.size()):
        if String(_party_details[index].get("unit_id", "")) == normalized_unit_id:
            _select_party_index(index)
            return true
    return false

func _render_selected_party(entry: Dictionary) -> void:
    if entry.is_empty():
        party_name_label.text = "No party member selected."
        party_status_label.text = ""
        party_stats_label.text = ""
        _set_slot_preview(weapon_preview, WEAPON_FALLBACK_PREVIEW)
        weapon_item_label.text = "No weapon equipped."
        weapon_hint_label.text = "Select a party member to review weapon options."
        _set_slot_preview(armor_preview, ARMOR_FALLBACK_PREVIEW)
        armor_item_label.text = "No armor equipped."
        armor_hint_label.text = "Select a party member to review armor options."
        _set_slot_preview(accessory_preview, ACCESSORY_FALLBACK_PREVIEW)
        accessory_item_label.text = "No accessory equipped."
        accessory_hint_label.text = "Select a party member to review accessory options."
        party_assignment_button.text = "Assign"
        party_assignment_button.disabled = true
        party_assignment_button.tooltip_text = "Select a party member to manage sortie assignment."
        party_weapon_button.text = "No Weapons"
        party_weapon_button.disabled = true
        party_weapon_button.tooltip_text = "Unlock or recover weapons before cycling a loadout."
        party_armor_button.text = "No Armor"
        party_armor_button.disabled = true
        party_armor_button.tooltip_text = "Unlock or recover armor before cycling a loadout."
        party_accessory_button.text = "Equip Accessory"
        party_accessory_button.disabled = true
        party_accessory_button.tooltip_text = "Unlock or recover accessories before equipping one."
        return

    var unit_id: String = String(entry.get("unit_id", ""))
    var deployed: bool = _deployed_party_unit_ids.has(unit_id)
    var locked: bool = _locked_party_unit_ids.has(unit_id)
    var role_text: String = "Deployed" if deployed else "Reserve"
    if locked:
        role_text = "Core"

    party_name_label.text = str(entry.get("name", "Unit"))
    party_status_label.text = "HP %s   Status %s" % [
        str(entry.get("hp_text", "0/0")),
        role_text
    ]
    party_stats_label.text = "ATK %s   DEF %s   MOVE %s   RNG %s\nSkill %s" % [
        str(entry.get("attack", 0)),
        str(entry.get("defense", 0)),
        str(entry.get("move", 0)),
        str(entry.get("range", 0)),
        str(entry.get("skill", "No skill"))
    ]
    _set_slot_preview(weapon_preview, str(entry.get("weapon_preview_path", WEAPON_FALLBACK_PREVIEW)))
    weapon_item_label.text = _format_slot_item_text("weapon", str(entry.get("weapon_slot", "None")))
    _set_slot_preview(armor_preview, str(entry.get("armor_preview_path", ARMOR_FALLBACK_PREVIEW)))
    armor_item_label.text = _format_slot_item_text("armor", str(entry.get("armor_slot", "None")))
    _set_slot_preview(accessory_preview, str(entry.get("accessory_preview_path", ACCESSORY_FALLBACK_PREVIEW)))
    accessory_item_label.text = _format_slot_item_text("accessory", str(entry.get("accessory_slot", "None")))
    if locked:
        party_assignment_button.text = "Rian Locked"
        party_assignment_button.disabled = true
        party_assignment_button.tooltip_text = "Rian is locked into the Chapter handoff and cannot be reassigned."
    elif deployed:
        party_assignment_button.text = "Assigned to Sortie"
        party_assignment_button.disabled = true
        party_assignment_button.tooltip_text = "This unit is already committed to the current sortie."
    else:
        party_assignment_button.text = "Assign to Sortie"
        party_assignment_button.disabled = false
        party_assignment_button.tooltip_text = "Assign this unit to the next battle lineup."

    if _available_weapon_entries.is_empty():
        party_weapon_button.text = "No Weapons"
        party_weapon_button.disabled = true
        party_weapon_button.tooltip_text = "No alternate weapons are unlocked for this camp state."
        weapon_hint_label.text = _build_equipment_eligibility_text(
            "weapon",
            _variant_to_string_array(entry.get("allowed_weapon_types", [])),
            int(entry.get("eligible_weapon_count", 0)),
            int(entry.get("total_weapon_count", 0))
        )
    else:
        party_weapon_button.text = "Cycle Weapon"
        party_weapon_button.disabled = false
        party_weapon_button.tooltip_text = "Swap to the next unlocked weapon for this unit."
        weapon_hint_label.text = _build_equipment_eligibility_text(
            "weapon",
            _variant_to_string_array(entry.get("allowed_weapon_types", [])),
            int(entry.get("eligible_weapon_count", 0)),
            int(entry.get("total_weapon_count", _available_weapon_entries.size()))
        )

    if _available_armor_entries.is_empty():
        party_armor_button.text = "No Armor"
        party_armor_button.disabled = true
        party_armor_button.tooltip_text = "No alternate armor is unlocked for this camp state."
        armor_hint_label.text = _build_equipment_eligibility_text(
            "armor",
            _variant_to_string_array(entry.get("allowed_armor_types", [])),
            int(entry.get("eligible_armor_count", 0)),
            int(entry.get("total_armor_count", 0))
        )
    else:
        party_armor_button.text = "Cycle Armor"
        party_armor_button.disabled = false
        party_armor_button.tooltip_text = "Swap to the next unlocked armor for this unit."
        armor_hint_label.text = _build_equipment_eligibility_text(
            "armor",
            _variant_to_string_array(entry.get("allowed_armor_types", [])),
            int(entry.get("eligible_armor_count", 0)),
            int(entry.get("total_armor_count", _available_armor_entries.size()))
        )

    if _available_accessory_entries.is_empty():
        party_accessory_button.text = "No Accessories"
        party_accessory_button.disabled = true
        party_accessory_button.tooltip_text = "No accessories are unlocked for this camp state."
        accessory_hint_label.text = _build_accessory_hint_text("", 0)
    else:
        party_accessory_button.text = "Cycle Accessory"
        party_accessory_button.disabled = false
        party_accessory_button.tooltip_text = "Swap to the next unlocked accessory for this unit."
        accessory_hint_label.text = _build_accessory_hint_text(
            str(entry.get("accessory_summary", "")),
            int(entry.get("eligible_accessory_count", _available_accessory_entries.size()))
        )

func _sync_party_button_state() -> void:
    for index in range(party_roster_buttons.get_child_count()):
        var child = party_roster_buttons.get_child(index)
        if child is Button:
            child.disabled = index == _selected_party_index

func _get_selected_party_name() -> String:
    if _selected_party_index < 0 or _selected_party_index >= _party_details.size():
        return ""
    return str(_party_details[_selected_party_index].get("name", ""))

func _get_selected_party_unit_id() -> String:
    if _selected_party_index < 0 or _selected_party_index >= _party_details.size():
        return ""
    return str(_party_details[_selected_party_index].get("unit_id", ""))

func _format_slot_item_text(slot_kind: String, slot_value: String) -> String:
    var normalized_value := slot_value.strip_edges()
    if normalized_value.is_empty() or normalized_value == "None":
        return "No %s equipped." % slot_kind
    return normalized_value

func _build_slot_hint_text(slot_kind: String, unlocked_count: int) -> String:
    var option_label := "options" if unlocked_count != 1 else "option"
    return "%d unlocked %s %s available." % [unlocked_count, slot_kind, option_label]

func _build_equipment_eligibility_text(slot_kind: String, allowed_types: Array[String], eligible_count: int, total_count: int) -> String:
    var allowed_text: String = ", ".join(allowed_types) if not allowed_types.is_empty() else "No allowed types"
    return "Allowed: %s. Eligible: %d/%d unlocked." % [allowed_text, eligible_count, total_count]

func _build_accessory_eligibility_text(eligible_count: int) -> String:
    return "All recruits may equip accessories. Eligible: %d unlocked." % eligible_count

func _build_accessory_hint_text(summary_text: String, eligible_count: int) -> String:
    var summary := summary_text.strip_edges()
    var eligibility := _build_accessory_eligibility_text(eligible_count)
    if summary.is_empty():
        return eligibility
    return "%s\n%s" % [summary, eligibility]

func _set_slot_preview(texture_rect: TextureRect, resource_path: String) -> void:
    if texture_rect == null:
        return
    var normalized_path: String = resource_path.strip_edges()
    if normalized_path.is_empty():
        texture_rect.texture = _build_placeholder_preview_texture("empty")
        return
    if ResourceLoader.exists(normalized_path):
        var texture := load(normalized_path) as Texture2D
        if texture != null:
            texture_rect.texture = texture
            return

    var absolute_path: String = ProjectSettings.globalize_path(normalized_path)
    if FileAccess.file_exists(absolute_path):
        var image := Image.new()
        if image.load(absolute_path) == OK:
            texture_rect.texture = ImageTexture.create_from_image(image)
            return

    texture_rect.texture = _build_placeholder_preview_texture(normalized_path)

func _build_placeholder_preview_texture(slot_key: String) -> Texture2D:
    var color := Color(0.36, 0.39, 0.45, 1.0)
    if slot_key.find("weapon") != -1:
        color = Color(0.67, 0.45, 0.32, 1.0)
    elif slot_key.find("armor") != -1:
        color = Color(0.42, 0.5, 0.61, 1.0)
    elif slot_key.find("accessory") != -1:
        color = Color(0.54, 0.44, 0.62, 1.0)

    var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
    image.fill(color)
    return ImageTexture.create_from_image(image)

func assign_selected_party_member() -> void:
    _on_party_assignment_pressed()

func cycle_selected_party_accessory() -> void:
    _on_party_accessory_pressed()

func cycle_selected_party_weapon() -> void:
    _on_party_weapon_pressed()

func cycle_selected_party_armor() -> void:
    _on_party_armor_pressed()

func _unhandled_input(event: InputEvent) -> void:
    if not visible:
        return

    if event.is_action_pressed("ui_cancel"):
        if _active_section != SECTION_SUMMARY:
            _select_section(SECTION_SUMMARY)
            get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed("ui_left"):
        if _select_relative_section(-1):
            get_viewport().set_input_as_handled()
        return

    if event.is_action_pressed("ui_right"):
        if _select_relative_section(1):
            get_viewport().set_input_as_handled()

func _on_advance_pressed() -> void:
    ui_cue_requested.emit("camp_next_battle_confirm_01" if _current_mode == CampaignState.MODE_CAMP else "ui_common_confirm_01")
    advance_requested.emit()

func _on_save_pressed() -> void:
    ui_cue_requested.emit("ui_inventory_open_01")
    save_panel_requested.emit()

func _select_relative_section(offset: int) -> bool:
    var current_index := SECTION_ORDER.find(_active_section)
    if current_index == -1:
        current_index = 0

    var next_index := clampi(current_index + offset, 0, SECTION_ORDER.size() - 1)
    if next_index == current_index:
        return false

    _select_section(String(SECTION_ORDER[next_index]))
    return true

func _on_party_assignment_pressed() -> void:
    var unit_id: String = _get_selected_party_unit_id()
    if unit_id.is_empty():
        return
    ui_cue_requested.emit("camp_party_assign_01")
    deployment_assignment_requested.emit(StringName(unit_id))

func _on_party_weapon_pressed() -> void:
    var unit_id: String = _get_selected_party_unit_id()
    if unit_id.is_empty():
        return
    ui_cue_requested.emit("camp_loadout_weapon_cycle_01")
    weapon_cycle_requested.emit(StringName(unit_id))

func _on_party_armor_pressed() -> void:
    var unit_id: String = _get_selected_party_unit_id()
    if unit_id.is_empty():
        return
    ui_cue_requested.emit("camp_loadout_armor_cycle_01")
    armor_cycle_requested.emit(StringName(unit_id))

func _on_party_accessory_pressed() -> void:
    var unit_id: String = _get_selected_party_unit_id()
    if unit_id.is_empty():
        return
    ui_cue_requested.emit("camp_loadout_accessory_cycle_01")
    accessory_cycle_requested.emit(StringName(unit_id))

func _update_responsive_layout() -> void:
    _apply_layout_for_viewport_size(get_viewport_rect().size)

func _apply_layout_for_viewport_size(viewport_size: Vector2) -> void:
    _compact_layout = viewport_size.x <= COMPACT_WIDTH_THRESHOLD

    section_tabs.columns = 2 if _compact_layout else 4
    party_content.vertical = _compact_layout
    var tab_button_height := COMPACT_TAB_BUTTON_HEIGHT if _compact_layout else REGULAR_TAB_BUTTON_HEIGHT
    for button in [summary_button, party_button, inventory_button, records_button]:
        button.custom_minimum_size = Vector2(0.0, tab_button_height)

    var party_button_height := _get_party_button_height()
    for button in [party_assignment_button, party_weapon_button, party_armor_button, party_accessory_button]:
        button.custom_minimum_size = Vector2(0.0, party_button_height)
    advance_button.custom_minimum_size = Vector2(0.0, PRIMARY_CTA_HEIGHT)
    for child in party_roster_buttons.get_children():
        if child is Button:
            child.custom_minimum_size = Vector2(0.0, party_button_height)

    for list in [dialogue_label, inventory_list, memory_list, evidence_list, letter_list]:
        list.scroll_active = _compact_layout
        list.fit_content = not _compact_layout

    if _compact_layout:
        panel.anchor_left = 0.0
        panel.anchor_top = 0.0
        panel.anchor_right = 1.0
        panel.anchor_bottom = 1.0
        panel.offset_left = COMPACT_PANEL_MARGIN
        panel.offset_top = COMPACT_PANEL_TOP_MARGIN
        panel.offset_right = -COMPACT_PANEL_MARGIN
        panel.offset_bottom = -COMPACT_PANEL_BOTTOM_MARGIN
    else:
        panel.anchor_left = 0.5
        panel.anchor_top = 0.5
        panel.anchor_right = 0.5
        panel.anchor_bottom = 0.5
        panel.offset_left = -REGULAR_PANEL_HALF_WIDTH
        panel.offset_top = -REGULAR_PANEL_HALF_HEIGHT
        panel.offset_right = REGULAR_PANEL_HALF_WIDTH
        panel.offset_bottom = REGULAR_PANEL_HALF_HEIGHT

func _get_party_button_height() -> float:
    return COMPACT_PARTY_BUTTON_HEIGHT if _compact_layout else REGULAR_PARTY_BUTTON_HEIGHT
