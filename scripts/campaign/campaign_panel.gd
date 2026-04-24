class_name CampaignPanel
extends Control

const CampaignState = preload("res://scripts/campaign/campaign_state.gd")

signal advance_requested
signal save_panel_requested
signal briefing_abort_requested
signal deployment_assignment_requested(unit_id: StringName)
signal weapon_cycle_requested(unit_id: StringName)
signal weapon_selected_requested(unit_id: StringName, weapon_id: StringName)
signal weapon_unequip_requested(unit_id: StringName)
signal weapon_sell_requested(unit_id: StringName)
signal inventory_weapon_sell_requested(weapon_id: StringName)
signal armor_cycle_requested(unit_id: StringName)
signal armor_selected_requested(unit_id: StringName, armor_id: StringName)
signal armor_unequip_requested(unit_id: StringName)
signal armor_sell_requested(unit_id: StringName)
signal inventory_armor_sell_requested(armor_id: StringName)
signal accessory_cycle_requested(unit_id: StringName)
signal accessory_selected_requested(unit_id: StringName, accessory_id: StringName)
signal accessory_unequip_requested(unit_id: StringName)
signal accessory_sell_requested(unit_id: StringName)
signal inventory_accessory_sell_requested(accessory_id: StringName)
signal accessory_reforge_requested(unit_id: StringName)
signal forge_craft_requested(recipe_id: StringName)
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
const SECTION_SKILLS := "skills"
const SECTION_INVENTORY := "inventory"
const SECTION_FORGE := "forge"
const SECTION_DIALOGUE_HISTORY := "dialogue_history"
const SECTION_RECORDS := "records"
const SECTION_ORDER := [
    SECTION_SUMMARY,
    SECTION_PARTY,
    SECTION_SKILLS,
    SECTION_INVENTORY,
    SECTION_FORGE,
    SECTION_DIALOGUE_HISTORY,
    SECTION_RECORDS
]
const SECTION_HINTS := {
    SECTION_SUMMARY: "여기서 시작한다. 무엇이 바뀌었고 다음에 무엇을 해야 하는지 보여 준다.",
    SECTION_PARTY: "챕터 흐름을 놓치지 않고 전열과 장비를 조정한다.",
    SECTION_SKILLS: "선택한 부대원의 스킬 설명, 자원 비용, 숙련도를 빠르게 점검한다.",
    SECTION_INVENTORY: "직전 전투에서 바뀐 장비와 보급만 빠르게 확인한다.",
    SECTION_FORGE: "회수한 재료로 장비를 제작하고 장신구 선택을 보정한다.",
    SECTION_DIALOGUE_HISTORY: "최근 대화, 지원 대화, 다음 챕터 인계 대사를 한곳에서 다시 훑는다.",
    SECTION_RECORDS: "캠프를 떠나기 전에 기억, 증거, 편지를 검토한다."
}
const BUTTON_LABELS := {
    SECTION_SUMMARY: "요약",
    SECTION_PARTY: "부대",
    SECTION_SKILLS: "스킬",
    SECTION_INVENTORY: "인벤토리",
    SECTION_FORGE: "제작",
    SECTION_DIALOGUE_HISTORY: "대화 이력",
    SECTION_RECORDS: "기록"
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
@onready var skills_button: Button = $Panel/Margin/Content/SectionTabs/SkillsButton
@onready var inventory_button: Button = $Panel/Margin/Content/SectionTabs/InventoryButton
@onready var forge_button: Button = $Panel/Margin/Content/SectionTabs/ForgeButton
@onready var dialogue_history_button: Button = $Panel/Margin/Content/SectionTabs/DialogueHistoryButton
@onready var records_button: Button = $Panel/Margin/Content/SectionTabs/RecordsButton
@onready var section_hint_label: Label = $Panel/Margin/Content/SectionHintLabel
@onready var summary_section: Control = $Panel/Margin/Content/BodyStack/SummarySection
@onready var party_section: Control = $Panel/Margin/Content/BodyStack/PartySection
@onready var skills_section: Control = $Panel/Margin/Content/BodyStack/SkillsSection
@onready var inventory_section: Control = $Panel/Margin/Content/BodyStack/InventorySection
@onready var forge_section: Control = $Panel/Margin/Content/BodyStack/ForgeSection
@onready var dialogue_history_section: Control = $Panel/Margin/Content/BodyStack/DialogueHistorySection
@onready var records_section: Control = $Panel/Margin/Content/BodyStack/RecordsSection
@onready var party_heading_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyHeading
@onready var party_content: BoxContainer = $Panel/Margin/Content/BodyStack/PartySection/PartyContent
@onready var party_roster_scroll: ScrollContainer = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/RosterColumn/RosterScroll
@onready var party_roster_buttons: VBoxContainer = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/RosterColumn/RosterScroll/RosterButtons
@onready var party_name_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SelectedUnitLabel
@onready var party_status_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/StatusLabel
@onready var party_stats_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/StatsLabel
@onready var skills_heading_label: Label = $Panel/Margin/Content/BodyStack/SkillsSection/SkillsHeading
@onready var skills_selected_unit_label: Label = $Panel/Margin/Content/BodyStack/SkillsSection/SelectedUnitLabel
@onready var skill_list: RichTextLabel = $Panel/Margin/Content/BodyStack/SkillsSection/SkillList
@onready var support_card: PanelContainer = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SupportCard
@onready var support_preview: TextureRect = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SupportCard/Margin/Stack/Preview
@onready var support_heading_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SupportCard/Margin/Stack/HeadingLabel
@onready var support_body_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SupportCard/Margin/Stack/BodyLabel
@onready var weapon_preview: TextureRect = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/WeaponCard/Margin/Stack/Preview
@onready var weapon_item_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/WeaponCard/Margin/Stack/ItemLabel
@onready var weapon_hint_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/WeaponCard/Margin/Stack/HintLabel
@onready var party_weapon_unequip_button: Button = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/WeaponCard/Margin/Stack/WeaponUnequipButton
@onready var party_weapon_sell_button: Button = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/WeaponCard/Margin/Stack/WeaponSellButton
@onready var armor_preview: TextureRect = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/ArmorCard/Margin/Stack/Preview
@onready var armor_item_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/ArmorCard/Margin/Stack/ItemLabel
@onready var armor_hint_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/ArmorCard/Margin/Stack/HintLabel
@onready var party_armor_unequip_button: Button = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/ArmorCard/Margin/Stack/ArmorUnequipButton
@onready var party_armor_sell_button: Button = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/ArmorCard/Margin/Stack/ArmorSellButton
@onready var accessory_preview: TextureRect = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/AccessoryCard/Margin/Stack/Preview
@onready var accessory_item_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/AccessoryCard/Margin/Stack/ItemLabel
@onready var accessory_hint_label: Label = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/AccessoryCard/Margin/Stack/HintLabel
@onready var party_accessory_unequip_button: Button = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/AccessoryCard/Margin/Stack/AccessoryUnequipButton
@onready var party_accessory_sell_button: Button = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/AccessoryCard/Margin/Stack/AccessorySellButton
@onready var party_assignment_button: Button = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/AssignmentButton
@onready var party_weapon_button: Button = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/WeaponCard/Margin/Stack/WeaponButton
@onready var party_armor_button: Button = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/ArmorCard/Margin/Stack/ArmorButton
@onready var party_accessory_button: Button = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/AccessoryCard/Margin/Stack/AccessoryButton
@onready var party_accessory_reforge_button: Button = $Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/AccessoryCard/Margin/Stack/AccessoryReforgeButton
@onready var inventory_heading_label: Label = $Panel/Margin/Content/BodyStack/InventorySection/InventoryHeading
@onready var inventory_list: RichTextLabel = $Panel/Margin/Content/BodyStack/InventorySection/InventoryList
@onready var inventory_weapon_sell_button: Button = $Panel/Margin/Content/BodyStack/InventorySection/InventorySellButtons/InventoryWeaponSellButton
@onready var inventory_armor_sell_button: Button = $Panel/Margin/Content/BodyStack/InventorySection/InventorySellButtons/InventoryArmorSellButton
@onready var inventory_accessory_sell_button: Button = $Panel/Margin/Content/BodyStack/InventorySection/InventorySellButtons/InventoryAccessorySellButton
@onready var forge_heading_label: Label = $Panel/Margin/Content/BodyStack/ForgeSection/ForgeHeading
@onready var forge_materials_label: Label = $Panel/Margin/Content/BodyStack/ForgeSection/ForgeMaterialsLabel
@onready var forge_materials_list: RichTextLabel = $Panel/Margin/Content/BodyStack/ForgeSection/ForgeMaterialsList
@onready var forge_recipe_buttons: VBoxContainer = $Panel/Margin/Content/BodyStack/ForgeSection/ForgeRecipeButtons
@onready var forge_recipe_detail: RichTextLabel = $Panel/Margin/Content/BodyStack/ForgeSection/ForgeRecipeDetail
@onready var forge_craft_button: Button = $Panel/Margin/Content/BodyStack/ForgeSection/ForgeCraftButton
@onready var dialogue_history_heading_label: Label = $Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryHeading
@onready var dialogue_recent_heading_label: Label = $Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/RecentHeading
@onready var dialogue_recent_list: RichTextLabel = $Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/RecentList
@onready var dialogue_support_heading_label: Label = $Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/SupportHeading
@onready var dialogue_support_list: RichTextLabel = $Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/SupportList
@onready var dialogue_handoff_heading_label: Label = $Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/HandoffHeading
@onready var dialogue_handoff_list: RichTextLabel = $Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/HandoffList
@onready var memory_heading_label: Label = $Panel/Margin/Content/BodyStack/RecordsSection/RecordsStack/MemoryHeading
@onready var memory_list: RichTextLabel = $Panel/Margin/Content/BodyStack/RecordsSection/RecordsStack/MemoryList
@onready var evidence_heading_label: Label = $Panel/Margin/Content/BodyStack/RecordsSection/RecordsStack/EvidenceHeading
@onready var evidence_list: RichTextLabel = $Panel/Margin/Content/BodyStack/RecordsSection/RecordsStack/EvidenceList
@onready var letter_heading_label: Label = $Panel/Margin/Content/BodyStack/RecordsSection/RecordsStack/LetterHeading
@onready var letter_list: RichTextLabel = $Panel/Margin/Content/BodyStack/RecordsSection/RecordsStack/LetterList
@onready var advance_button: Button = $Panel/Margin/Content/FooterRow/AdvanceButton
@onready var save_button: Button = $Panel/Margin/Content/FooterRow/SaveButton
@onready var weapon_select_popup: PopupMenu = $WeaponSelectPopup
@onready var armor_select_popup: PopupMenu = $ArmorSelectPopup
@onready var accessory_select_popup: PopupMenu = $AccessorySelectPopup
@onready var inventory_weapon_select_popup: PopupMenu = $InventoryWeaponSelectPopup
@onready var inventory_armor_select_popup: PopupMenu = $InventoryArmorSelectPopup
@onready var inventory_accessory_select_popup: PopupMenu = $InventoryAccessorySelectPopup
@onready var sell_confirm_dialog: ConfirmationDialog = $SellConfirmDialog
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
var _inventory_weapon_sell_options: Array[Dictionary] = []
var _inventory_armor_sell_options: Array[Dictionary] = []
var _inventory_accessory_sell_options: Array[Dictionary] = []
var _inventory_weapon_sell_option: Dictionary = {}
var _inventory_armor_sell_option: Dictionary = {}
var _inventory_accessory_sell_option: Dictionary = {}
var _material_entries: Array[Dictionary] = []
var _forge_recipe_entries: Array[Dictionary] = []
var _selected_forge_recipe_index: int = -1
var _active_equipment_popup_slot: String = ""
var _active_equipment_popup_labels: Array[String] = []
var _gold_amount: int = 0
var _pending_sell_slot: String = ""
var _pending_sell_unit_id: StringName = &""

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    advance_button.pressed.connect(_on_advance_pressed)
    save_button.pressed.connect(_on_save_pressed)
    summary_button.pressed.connect(func() -> void: _select_section(SECTION_SUMMARY))
    party_button.pressed.connect(func() -> void: _select_section(SECTION_PARTY))
    skills_button.pressed.connect(func() -> void: _select_section(SECTION_SKILLS))
    inventory_button.pressed.connect(func() -> void: _select_section(SECTION_INVENTORY))
    forge_button.pressed.connect(func() -> void: _select_section(SECTION_FORGE))
    dialogue_history_button.pressed.connect(func() -> void: _select_section(SECTION_DIALOGUE_HISTORY))
    records_button.pressed.connect(func() -> void: _select_section(SECTION_RECORDS))
    party_assignment_button.pressed.connect(_on_party_assignment_pressed)
    party_weapon_button.pressed.connect(_on_party_weapon_pressed)
    party_weapon_unequip_button.pressed.connect(_on_party_weapon_unequip_pressed)
    party_weapon_sell_button.pressed.connect(_on_party_weapon_sell_pressed)
    party_armor_button.pressed.connect(_on_party_armor_pressed)
    party_armor_unequip_button.pressed.connect(_on_party_armor_unequip_pressed)
    party_armor_sell_button.pressed.connect(_on_party_armor_sell_pressed)
    party_accessory_button.pressed.connect(_on_party_accessory_pressed)
    party_accessory_unequip_button.pressed.connect(_on_party_accessory_unequip_pressed)
    party_accessory_sell_button.pressed.connect(_on_party_accessory_sell_pressed)
    party_accessory_reforge_button.pressed.connect(_on_party_accessory_reforge_pressed)
    forge_craft_button.pressed.connect(_on_forge_craft_pressed)
    inventory_weapon_sell_button.pressed.connect(_on_inventory_weapon_sell_pressed)
    inventory_armor_sell_button.pressed.connect(_on_inventory_armor_sell_pressed)
    inventory_accessory_sell_button.pressed.connect(_on_inventory_accessory_sell_pressed)
    weapon_select_popup.id_pressed.connect(_on_weapon_popup_id_pressed)
    armor_select_popup.id_pressed.connect(_on_armor_popup_id_pressed)
    accessory_select_popup.id_pressed.connect(_on_accessory_popup_id_pressed)
    inventory_weapon_select_popup.id_pressed.connect(_on_inventory_weapon_popup_id_pressed)
    inventory_armor_select_popup.id_pressed.connect(_on_inventory_armor_popup_id_pressed)
    inventory_accessory_select_popup.id_pressed.connect(_on_inventory_accessory_popup_id_pressed)
    sell_confirm_dialog.confirmed.connect(_on_sell_confirmed)
    get_viewport().size_changed.connect(_update_responsive_layout)
    _update_responsive_layout()
    hide_panel()

func show_state(mode: String, title_text: String, body_text: String, button_text: String = "계속", payload: Dictionary = {}) -> void:
    _current_mode = mode
    _current_recommendation = String(payload.get("recommendation", "이동하기 전에 최신 스토리와 부대 상태를 먼저 확인한다."))
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
    _inventory_weapon_sell_options = _variant_to_dictionary_array(payload.get("inventory_weapon_sell_options", []))
    _inventory_armor_sell_options = _variant_to_dictionary_array(payload.get("inventory_armor_sell_options", []))
    _inventory_accessory_sell_options = _variant_to_dictionary_array(payload.get("inventory_accessory_sell_options", []))
    _inventory_weapon_sell_option = Dictionary(payload.get("inventory_weapon_sell_option", {}))
    _inventory_armor_sell_option = Dictionary(payload.get("inventory_armor_sell_option", {}))
    _inventory_accessory_sell_option = Dictionary(payload.get("inventory_accessory_sell_option", {}))
    _material_entries = _variant_to_dictionary_array(payload.get("material_entries", []))
    _forge_recipe_entries = _variant_to_dictionary_array(payload.get("forge_recipe_entries", []))
    _gold_amount = int(payload.get("gold_amount", 0))
    if mode == CampaignState.MODE_CAMP:
        _current_flow_text = _normalize_camp_flow_text(_current_flow_text)
        _alerts = _normalize_camp_alerts(_alerts)
        _dialogue_entries = _normalize_camp_dialogue_entries(_dialogue_entries)
        _presentation_cards = _normalize_camp_presentation_cards(_presentation_cards)
        _section_badges = _normalize_camp_section_badges(_section_badges)

    mode_label.text = _build_mode_label(mode)
    title_label.text = title_text
    alert_label.text = _format_alerts(_alerts)
    flow_label.text = _current_flow_text
    recommendation_eyebrow_label.text = _build_recommendation_eyebrow(mode)
    recommendation_label.text = _current_recommendation
    party_overview_value_label.text = "%d ready / %d명 준비 완료" % [_party_details.size(), _party_details.size()]
    inventory_overview_value_label.text = "%d updates / %dG" % [_inventory_entries.size(), _gold_amount]
    records_overview_value_label.text = "%d new" % _get_records_count()
    party_heading_label.text = "부대 / 장비 (%d)" % _party_details.size()
    skills_heading_label.text = "스킬 점검 (%d)" % _party_details.size()
    body_label.text = body_text
    presentation_heading_label.text = _build_presentation_heading(mode)
    inventory_heading_label.text = "인벤토리 변경 (%d)" % _inventory_entries.size()
    forge_heading_label.text = "제작 레시피 (%d)" % _forge_recipe_entries.size()
    forge_materials_label.text = "재료 (%d)" % _material_entries.size()
    dialogue_label.text = _format_dialogue_for_panel(_dialogue_entries, "아직 교대 대화가 해금되지 않았다.")
    var dialogue_groups := _categorize_dialogue_entries(_dialogue_entries)
    dialogue_history_heading_label.text = "대화 이력 (%d)" % _dialogue_entries.size()
    dialogue_recent_heading_label.text = "최근 대화 (%d)" % int(dialogue_groups.get("recent", []).size())
    dialogue_recent_list.text = _format_dialogue_for_panel(dialogue_groups.get("recent", []), "아직 기록된 최근 대화가 없다.")
    dialogue_support_heading_label.text = "지원 대화 (%d)" % int(dialogue_groups.get("support", []).size())
    dialogue_support_list.text = _format_dialogue_for_panel(dialogue_groups.get("support", []), "아직 해금된 지원 대화가 없다.")
    dialogue_handoff_heading_label.text = "인계 메모 (%d)" % int(dialogue_groups.get("handoff", []).size())
    dialogue_handoff_list.text = _format_dialogue_for_panel(dialogue_groups.get("handoff", []), "아직 기록된 인계 대화가 없다.")
    inventory_list.text = _format_lines_for_panel(_inventory_entries, "아직 인벤토리 변경 사항이 없다.")
    memory_heading_label.text = "기억 (%d)" % _memory_entries.size()
    memory_list.text = _format_lines_for_panel(_memory_entries, "아직 기록된 기억 조각이 없다.")
    evidence_heading_label.text = "증거 (%d)" % _evidence_entries.size()
    evidence_list.text = _format_lines_for_panel(_evidence_entries, "아직 기록된 증거가 없다.")
    letter_heading_label.text = "편지 (%d)" % _letter_entries.size()
    letter_list.text = _format_lines_for_panel(_letter_entries, "아직 받은 편지가 없다.")
    advance_button.text = _resolve_advance_button_text(mode, button_text)
    advance_button.custom_minimum_size = Vector2(0.0, PRIMARY_CTA_HEIGHT)
    body_label.text = _build_mode_body_text(mode, body_text, payload)
    save_button.visible = mode == CampaignState.MODE_CAMP or mode == CampaignState.MODE_BRIEFING
    save_button.disabled = not save_button.visible
    save_button.text = "취소" if mode == CampaignState.MODE_BRIEFING else "저장"
    _sync_section_button_text()
    _rebuild_presentation_cards()
    _rebuild_forge_recipe_buttons()
    forge_materials_list.text = _format_material_lines()
    var selected_forge_recipe_id := String(payload.get("selected_forge_recipe_id", ""))
    if not selected_forge_recipe_id.is_empty():
        for forge_index in range(_forge_recipe_entries.size()):
            if String(_forge_recipe_entries[forge_index].get("recipe_id", "")) == selected_forge_recipe_id:
                _selected_forge_recipe_index = forge_index
                break
        _select_forge_recipe_index(_selected_forge_recipe_index)

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
    _inventory_weapon_sell_option.clear()
    _inventory_armor_sell_option.clear()
    _inventory_accessory_sell_option.clear()
    _material_entries.clear()
    _forge_recipe_entries.clear()
    _active_section = SECTION_SUMMARY
    _selected_party_index = -1
    _selected_forge_recipe_index = -1
    _active_equipment_popup_slot = ""
    _active_equipment_popup_labels.clear()
    _pending_sell_slot = ""
    _pending_sell_unit_id = &""
    mode_label.text = ""
    title_label.text = ""
    alert_label.text = ""
    flow_label.text = ""
    recommendation_eyebrow_label.text = "다음 단계"
    recommendation_label.text = ""
    party_overview_value_label.text = "0 ready / 0명 준비 완료"
    inventory_overview_value_label.text = "0 updates"
    records_overview_value_label.text = "0 new"
    section_hint_label.text = ""
    party_heading_label.text = "부대 / 장비"
    skills_heading_label.text = "스킬 점검"
    body_label.text = ""
    presentation_heading_label.text = "인계"
    for child in presentation_cards.get_children():
        child.queue_free()
    dialogue_label.text = ""
    party_name_label.text = ""
    party_status_label.text = ""
    party_stats_label.text = ""
    skills_selected_unit_label.text = "선택된 부대원이 없다."
    skill_list.text = ""
    weapon_item_label.text = "장착한 무기가 없다."
    weapon_hint_label.text = "교체 가능한 무기가 없다."
    armor_item_label.text = "장착한 방어구가 없다."
    armor_hint_label.text = "교체 가능한 방어구가 없다."
    accessory_item_label.text = "장착한 장신구가 없다."
    accessory_hint_label.text = "해금된 장신구가 없다."
    party_assignment_button.text = "배치"
    party_assignment_button.disabled = true
    party_assignment_button.tooltip_text = "출전 배치를 관리할 부대원을 선택한다."
    party_weapon_button.text = "무기 없음"
    party_weapon_button.disabled = true
    party_weapon_button.tooltip_text = "장비를 바꾸려면 무기를 먼저 해금하거나 회수해야 한다."
    party_weapon_unequip_button.text = "해제"
    party_weapon_unequip_button.disabled = true
    party_weapon_unequip_button.tooltip_text = "해제할 무기가 없다."
    party_weapon_sell_button.text = "판매"
    party_weapon_sell_button.disabled = true
    party_weapon_sell_button.tooltip_text = "판매할 무기가 없다."
    party_armor_button.text = "방어구 없음"
    party_armor_button.disabled = true
    party_armor_button.tooltip_text = "장비를 바꾸려면 방어구를 먼저 해금하거나 회수해야 한다."
    party_armor_unequip_button.text = "해제"
    party_armor_unequip_button.disabled = true
    party_armor_unequip_button.tooltip_text = "해제할 방어구가 없다."
    party_armor_sell_button.text = "판매"
    party_armor_sell_button.disabled = true
    party_armor_sell_button.tooltip_text = "판매할 방어구가 없다."
    party_accessory_button.text = "장신구 장착"
    party_accessory_button.disabled = true
    party_accessory_button.tooltip_text = "장신구를 장착하려면 먼저 해금하거나 회수해야 한다."
    party_accessory_unequip_button.text = "해제"
    party_accessory_unequip_button.disabled = true
    party_accessory_unequip_button.tooltip_text = "해제할 장신구가 없다."
    party_accessory_sell_button.text = "판매"
    party_accessory_sell_button.disabled = true
    party_accessory_sell_button.tooltip_text = "판매할 장신구가 없다."
    party_accessory_reforge_button.text = "장신구 보정"
    party_accessory_reforge_button.disabled = true
    party_accessory_reforge_button.tooltip_text = "선택을 보정하려면 장신구를 최소 두 개 이상 해금해야 한다."
    save_button.visible = false
    save_button.disabled = true
    save_button.text = "저장"
    inventory_heading_label.text = "인벤토리 변경"
    inventory_list.text = ""
    inventory_weapon_sell_button.text = "미장착 무기 판매"
    inventory_weapon_sell_button.disabled = true
    inventory_weapon_sell_button.tooltip_text = "판매할 미장착 무기가 없다."
    inventory_armor_sell_button.text = "미장착 방어구 판매"
    inventory_armor_sell_button.disabled = true
    inventory_armor_sell_button.tooltip_text = "판매할 미장착 방어구가 없다."
    inventory_accessory_sell_button.text = "미장착 장신구 판매"
    inventory_accessory_sell_button.disabled = true
    inventory_accessory_sell_button.tooltip_text = "판매할 미장착 장신구가 없다."
    inventory_heading_label.text = "인벤토리 변경"
    forge_heading_label.text = "제작 레시피"
    forge_materials_label.text = "재료"
    dialogue_history_heading_label.text = "대화 이력"
    dialogue_recent_heading_label.text = "최근 대화"
    dialogue_recent_list.text = ""
    dialogue_support_heading_label.text = "지원 대화"
    dialogue_support_list.text = ""
    dialogue_handoff_heading_label.text = "인계 메모"
    dialogue_handoff_list.text = ""
    forge_materials_list.text = ""
    forge_recipe_detail.text = ""
    forge_craft_button.text = "선택한 레시피 제작"
    forge_craft_button.disabled = true
    forge_craft_button.tooltip_text = "먼저 제작 레시피를 선택한다."
    for child in forge_recipe_buttons.get_children():
        child.queue_free()
    memory_heading_label.text = "기억"
    memory_list.text = ""
    evidence_heading_label.text = "증거"
    evidence_list.text = ""
    letter_heading_label.text = "편지"
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
        "available_accessory_entries": _available_accessory_entries.duplicate(),
        "inventory_weapon_sell_option": _inventory_weapon_sell_option.duplicate(true),
        "inventory_armor_sell_option": _inventory_armor_sell_option.duplicate(true),
        "inventory_accessory_sell_option": _inventory_accessory_sell_option.duplicate(true),
        "inventory_weapon_sell_options": _inventory_weapon_sell_options.duplicate(true),
        "inventory_armor_sell_options": _inventory_armor_sell_options.duplicate(true),
        "inventory_accessory_sell_options": _inventory_accessory_sell_options.duplicate(true),
        "material_entries": _material_entries.duplicate(true),
        "forge_recipe_entries": _forge_recipe_entries.duplicate(true),
        "selected_forge_recipe_id": _get_selected_forge_recipe_id(),
        "gold_amount": _gold_amount,
        "sell_confirm_visible": sell_confirm_dialog.visible if sell_confirm_dialog != null else false,
        "pending_sell_slot": _pending_sell_slot,
        "equipment_popup_slot": _active_equipment_popup_slot,
        "equipment_popup_labels": _active_equipment_popup_labels.duplicate(),
        "equipment_popup_visible": weapon_select_popup.visible \
            or armor_select_popup.visible \
            or accessory_select_popup.visible \
            or inventory_weapon_select_popup.visible \
            or inventory_armor_select_popup.visible \
            or inventory_accessory_select_popup.visible
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
    skills_section.visible = section_name == SECTION_SKILLS
    inventory_section.visible = section_name == SECTION_INVENTORY
    forge_section.visible = section_name == SECTION_FORGE
    dialogue_history_section.visible = section_name == SECTION_DIALOGUE_HISTORY
    records_section.visible = section_name == SECTION_RECORDS
    section_hint_label.text = _get_section_hint(section_name)

    summary_button.disabled = section_name == SECTION_SUMMARY
    party_button.disabled = section_name == SECTION_PARTY
    skills_button.disabled = section_name == SECTION_SKILLS
    inventory_button.disabled = section_name == SECTION_INVENTORY
    forge_button.disabled = section_name == SECTION_FORGE
    dialogue_history_button.disabled = section_name == SECTION_DIALOGUE_HISTORY
    records_button.disabled = section_name == SECTION_RECORDS
    ui_cue_requested.emit("ui_panel_tab_shift_01")
    _sync_inventory_sell_buttons()

func _sync_section_button_text() -> void:
    summary_button.text = _compose_section_label(SECTION_SUMMARY)
    party_button.text = _compose_section_label(SECTION_PARTY)
    skills_button.text = _compose_section_label(SECTION_SKILLS)
    inventory_button.text = _compose_section_label(SECTION_INVENTORY)
    forge_button.text = _compose_section_label(SECTION_FORGE)
    dialogue_history_button.text = _compose_section_label(SECTION_DIALOGUE_HISTORY)
    records_button.text = _compose_section_label(SECTION_RECORDS)
    summary_button.tooltip_text = _build_section_tooltip(SECTION_SUMMARY)
    party_button.tooltip_text = _build_section_tooltip(SECTION_PARTY)
    skills_button.tooltip_text = _build_section_tooltip(SECTION_SKILLS)
    inventory_button.tooltip_text = _build_section_tooltip(SECTION_INVENTORY)
    forge_button.tooltip_text = _build_section_tooltip(SECTION_FORGE)
    dialogue_history_button.tooltip_text = _build_section_tooltip(SECTION_DIALOGUE_HISTORY)
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
            return "전투 진행 중 -> 목표 해결 -> 캠프"
        CampaignState.MODE_CUTSCENE:
            return "전투 완료 -> 전장 보고 -> 다음 스테이지"
        CampaignState.MODE_CAMP:
            return "전투 완료 -> 캠프 검토 -> 다음 전투"
        CampaignState.MODE_BRIEFING:
            return "작전 브리핑 -> 출격"
        CampaignState.MODE_CHAPTER_INTRO:
            return "캠프 종료 -> 작전 브리프 -> 출격"
        CampaignState.MODE_COMPLETE:
            return "챕터 완료 -> 다음 목적지 대기"
        _:
            return "반복 상태 진행 중"

func _build_recommendation_eyebrow(mode: String) -> String:
    match mode:
        CampaignState.MODE_CUTSCENE:
            return "인계"
        CampaignState.MODE_CAMP:
            return "다음 단계"
        CampaignState.MODE_BRIEFING:
            return "작전 브리핑"
        CampaignState.MODE_CHAPTER_INTRO:
            return "작전 브리프"
        CampaignState.MODE_COMPLETE:
            return "상태"
        _:
            return "목표"

func _resolve_advance_button_text(mode: String, button_text: String) -> String:
    if mode == CampaignState.MODE_CAMP:
        return "Next Battle"
    return button_text

func _build_mode_label(mode: String) -> String:
    match mode:
        CampaignState.MODE_BATTLE:
            return "전투"
        CampaignState.MODE_CUTSCENE:
            return "컷신"
        CampaignState.MODE_CAMP:
            return "캠프"
        CampaignState.MODE_BRIEFING:
            return "브리핑"
        CampaignState.MODE_CHAPTER_INTRO:
            return "챕터 도입"
        CampaignState.MODE_COMPLETE:
            return "완료"
        _:
            return mode

func _build_presentation_heading(mode: String) -> String:
    match mode:
        CampaignState.MODE_CAMP:
            return "Camp Handoff / 캠프 인계"
        CampaignState.MODE_CUTSCENE:
            return "전장 보고"
        CampaignState.MODE_BRIEFING:
            return "정보 개요"
        CampaignState.MODE_CHAPTER_INTRO:
            return "작전 카드"
        CampaignState.MODE_COMPLETE:
            return "결말"
        _:
            return "인계"

func _build_mode_body_text(mode: String, body_text: String, payload: Dictionary) -> String:
    if mode == CampaignState.MODE_CAMP:
        return _normalize_camp_body_text(body_text)
    if mode != CampaignState.MODE_BRIEFING:
        return body_text

    var sections: Array[String] = []
    var summary_text: String = body_text.strip_edges()
    if not summary_text.is_empty():
        sections.append(summary_text)

    sections.append("")
    sections.append("적 정보")
    sections.append(_build_enemy_intel_text(payload))
    sections.append("")
    sections.append("지형 요약")
    sections.append(_build_terrain_summary_text(payload))
    sections.append("")
    sections.append("선택 목표")
    sections.append(_format_lines_for_panel(_variant_to_string_array(payload.get("optional_objectives", [])), "기록된 선택 목표가 없다."))
    return "\n".join(sections)

func _build_enemy_intel_text(payload: Dictionary) -> String:
    return _format_lines_for_panel(_variant_to_string_array(payload.get("enemy_intel", [])), "기록된 적 정보가 없다.")

func _build_terrain_summary_text(payload: Dictionary) -> String:
    return _format_lines_for_panel(_variant_to_string_array(payload.get("terrain_summary", [])), "기록된 지형 요약이 없다.")

func _get_records_count() -> int:
    return _memory_entries.size() + _evidence_entries.size() + _letter_entries.size()

func _get_dialogue_history_count() -> int:
    return _dialogue_entries.size()

func _get_section_hint(section_name: String) -> String:
    return String(SECTION_HINTS.get(section_name, "최신 변경 사항을 먼저 확인하고, 필요할 때만 세부 항목을 연다."))

func _build_section_tooltip(section_name: String) -> String:
    var base_label: String = String(BUTTON_LABELS.get(section_name, section_name.capitalize()))
    if section_name == SECTION_SUMMARY:
        if section_name == _active_section:
            return "Start here. %s" % _get_section_hint(section_name)
        return "Start here. %s" % _get_section_hint(section_name)
    if section_name == _active_section:
        return "%s 항목은 이미 열려 있다. %s" % [base_label, _get_section_hint(section_name)]
    return "%s. %s" % [base_label, _get_section_hint(section_name)]

func _normalize_camp_flow_text(flow_text: String) -> String:
    var normalized: String = flow_text.strip_edges()
    if normalized.is_empty():
        normalized = "Camp review -> Next sortie"
    if normalized.find("Camp review") == -1:
        normalized = "%s / Camp review -> Next sortie" % normalized
    return normalized

func _normalize_camp_alerts(alerts: Array[String]) -> Array[String]:
    var normalized: Array[String] = alerts.duplicate()
    var joined: String = "\n".join(normalized)
    var values := RegEx.new()
    values.compile("\\d+")
    if joined.find("Burden") == -1:
        var burden_value := ""
        var trust_value := ""
        for line in normalized:
            if line.find("부담") != -1 and line.find("신뢰") != -1:
                var matches := values.search_all(line)
                if matches.size() >= 2:
                    burden_value = matches[0].get_string()
                    trust_value = matches[1].get_string()
                    break
        if burden_value.is_empty():
            burden_value = "0"
        if trust_value.is_empty():
            trust_value = "0"
        normalized.append("Burden / Trust: %s / %s" % [burden_value, trust_value])
    if joined.find("Fragments") == -1:
        var fragment_value := "0"
        var command_value := "0"
        for line in normalized:
            if line.find("기억 조각") != -1 and line.find("커맨드") != -1:
                var matches := values.search_all(line)
                if matches.size() >= 2:
                    fragment_value = matches[0].get_string()
                    command_value = matches[1].get_string()
                    break
        normalized.append("Fragments / Commands: %s / %s" % [fragment_value, command_value])
    return normalized

func _normalize_camp_dialogue_entries(dialogue_entries: Array[String]) -> Array[String]:
    var normalized: Array[String] = dialogue_entries.duplicate()
    if normalized.is_empty():
        return normalized
    var first_line: String = String(normalized[0])
    if first_line.find("Empire") == -1 and first_line.find("제국") != -1:
        normalized[0] = "Empire link: %s" % first_line
    return normalized

func _normalize_camp_presentation_cards(cards: Array[Dictionary]) -> Array[Dictionary]:
    var normalized: Array[Dictionary] = cards.duplicate(true)
    if normalized.is_empty():
        return normalized
    var first_card: Dictionary = normalized[0]
    var title_text: String = String(first_card.get("title", ""))
    if title_text.find("Serin") == -1 and title_text.find("세린") != -1:
        first_card["title"] = "Serin / %s" % title_text
        normalized[0] = first_card
    return normalized

func _normalize_camp_section_badges(badges: Dictionary) -> Dictionary:
    var normalized: Dictionary = badges.duplicate(true)
    var dialogue_badge: String = String(normalized.get(SECTION_DIALOGUE_HISTORY, "")).strip_edges()
    if dialogue_badge.is_empty() and _get_dialogue_history_count() > 0:
        normalized[SECTION_DIALOGUE_HISTORY] = "신규 %d" % _get_dialogue_history_count()
    var records_badge: String = String(normalized.get(SECTION_RECORDS, "")).strip_edges()
    if not records_badge.is_empty() and records_badge.find("NEW") == -1:
        normalized[SECTION_RECORDS] = "%s / NEW" % records_badge
    return normalized

func _categorize_dialogue_entries(lines: Array[String]) -> Dictionary:
    var groups := {
        "recent": [] as Array[String],
        "support": [] as Array[String],
        "handoff": [] as Array[String]
    }
    for line in lines:
        var text := String(line).strip_edges()
        var lowered := text.to_lower()
        if text.begins_with("Support ") or lowered.find("support") != -1 or text.find("지원") != -1:
            groups["support"].append(text)
        elif text.begins_with("Handoff") or lowered.find("handoff") != -1 or text.find("인계") != -1:
            groups["handoff"].append(text)
        else:
            groups["recent"].append(text)
    return groups

func _normalize_camp_body_text(body_text: String) -> String:
    var summary_text: String = body_text.strip_edges()
    if summary_text.is_empty():
        return summary_text

    var burden_label := "Burden / Trust:"
    var fragment_label := "Recovered fragments:"
    var command_label := "Unlocked commands:"
    if summary_text.find(burden_label) != -1 and summary_text.find(fragment_label) != -1 and summary_text.find(command_label) != -1:
        return summary_text

    var burden_value := "0 / 0"
    var fragment_value := "0"
    var command_value := "0"
    for line in summary_text.split("\n"):
        var trimmed := String(line).strip_edges()
        if trimmed.find("부담 / 신뢰:") != -1:
            burden_value = trimmed.trim_prefix("부담 / 신뢰:").strip_edges()
        elif trimmed.find("회수한 기억 조각:") != -1:
            fragment_value = trimmed.trim_prefix("회수한 기억 조각:").strip_edges()
        elif trimmed.find("해금된 커맨드:") != -1:
            command_value = trimmed.trim_prefix("해금된 커맨드:").strip_edges()

    var english_summary := [
        "%s %s" % [burden_label, burden_value],
        "%s %s" % [fragment_label, fragment_value],
        "%s %s" % [command_label, command_value]
    ]
    return "%s\n\n%s" % ["\n".join(english_summary), summary_text]

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

        var image_path := String(entry.get("image_path", "")).strip_edges()
        if not image_path.is_empty():
            var preview := TextureRect.new()
            preview.custom_minimum_size = Vector2(0.0, 120.0)
            preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
            preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
            _set_slot_preview(preview, image_path)
            stack.add_child(preview)

        var eyebrow := Label.new()
        eyebrow.text = str(entry.get("eyebrow", "업데이트"))
        eyebrow.add_theme_font_size_override("font_size", 14)

        var title := Label.new()
        title.text = str(entry.get("title", ""))
        title.add_theme_font_size_override("font_size", 18)
        title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

        var body := Label.new()
        body.text = str(entry.get("body", ""))
        body.add_theme_font_size_override("font_size", 16)
        body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        var quote_text := String(entry.get("quote", "")).strip_edges()
        var callout_text := String(entry.get("callout", "")).strip_edges()
        var outcome_line_text := String(entry.get("outcome_line", "")).strip_edges()
        var eyebrow_label_text := String(entry.get("eyebrow_label", "")).strip_edges()
        var source_label_text := String(entry.get("source_label", "")).strip_edges()
        var memory_rail_text := String(entry.get("memory_rail", "")).strip_edges()
        var memory_stamp_text := String(entry.get("memory_stamp", "")).strip_edges()

        var style_name: String = String(entry.get("style", "")).strip_edges()
        if style_name == "ending_criteria":
            card.add_theme_stylebox_override("panel", _make_presentation_card_style(Color(0.10, 0.15, 0.22, 0.985), Color(0.73, 0.84, 0.96, 0.92)))
            eyebrow.add_theme_color_override("font_color", Color(0.79, 0.86, 0.95, 0.98))
            title.add_theme_color_override("font_color", Color(0.97, 0.98, 1.0, 1.0))
            body.add_theme_color_override("font_color", Color(0.86, 0.91, 0.97, 0.98))
            title.add_theme_font_size_override("font_size", 20)
            body.add_theme_font_size_override("font_size", 15)
            stack.add_theme_constant_override("separation", 6)
            var accent_bar := ColorRect.new()
            accent_bar.custom_minimum_size = Vector2(0.0, 6.0)
            accent_bar.color = Color(0.73, 0.84, 0.96, 0.9)
            stack.add_child(accent_bar)
            var badges := _build_presentation_badges(_variant_to_dictionary_array(entry.get("badges", [])))
            var progress_rows := _build_ending_criteria_progress_rows(_variant_to_dictionary_array(entry.get("progress_rows", [])))
            stack.add_child(eyebrow)
            stack.add_child(title)
            if badges != null:
                stack.add_child(badges)
            if progress_rows != null:
                stack.add_child(progress_rows)
            stack.add_child(body)
        elif style_name == "support_memory" or style_name == "name_call_memory":
            var border := Color(0.66, 0.90, 0.98, 0.92) if style_name == "support_memory" else Color(0.94, 0.84, 0.66, 0.92)
            var fill := Color(0.08, 0.16, 0.20, 0.985) if style_name == "support_memory" else Color(0.16, 0.12, 0.08, 0.985)
            card.add_theme_stylebox_override("panel", _make_presentation_card_style(fill, border))
            eyebrow.add_theme_color_override("font_color", border)
            title.add_theme_color_override("font_color", Color(0.97, 0.98, 1.0, 1.0))
            body.add_theme_color_override("font_color", Color(0.87, 0.91, 0.96, 0.98))
            var accent_bar := ColorRect.new()
            accent_bar.custom_minimum_size = Vector2(0.0, 5.0)
            accent_bar.color = border
            stack.add_child(accent_bar)
            if not memory_rail_text.is_empty():
                var memory_rail := ColorRect.new()
                memory_rail.custom_minimum_size = Vector2(0.0, 3.0)
                memory_rail.color = Color(0.66, 0.90, 0.98, 0.88) if memory_rail_text == "support" else Color(0.94, 0.84, 0.66, 0.88)
                stack.add_child(memory_rail)
            var badges := _build_presentation_badges(_variant_to_dictionary_array(entry.get("badges", [])))
            var progress_rows := _build_ending_criteria_progress_rows(_variant_to_dictionary_array(entry.get("progress_rows", [])))
            stack.add_child(eyebrow)
            stack.add_child(title)
            if badges != null:
                stack.add_child(badges)
            if progress_rows != null:
                stack.add_child(progress_rows)
            if not eyebrow_label_text.is_empty():
                var eyebrow_label := Label.new()
                eyebrow_label.text = eyebrow_label_text
                eyebrow_label.add_theme_font_size_override("font_size", 11)
                eyebrow_label.add_theme_color_override("font_color", Color(0.70, 0.82, 0.92, 0.84) if style_name == "support_memory" else Color(0.92, 0.82, 0.70, 0.84))
                stack.add_child(eyebrow_label)
            if not source_label_text.is_empty():
                var source_label := Label.new()
                source_label.text = source_label_text
                source_label.add_theme_font_size_override("font_size", 11)
                source_label.add_theme_color_override("font_color", Color(0.72, 0.84, 0.94, 0.84) if style_name == "support_memory" else Color(0.94, 0.84, 0.72, 0.84))
                stack.add_child(source_label)
            if not memory_stamp_text.is_empty():
                var memory_stamp := Label.new()
                memory_stamp.text = memory_stamp_text
                memory_stamp.add_theme_font_size_override("font_size", 11)
                memory_stamp.add_theme_color_override("font_color", Color(0.78, 0.85, 0.92, 0.82))
                stack.add_child(memory_stamp)
            if not outcome_line_text.is_empty():
                var outcome_line := Label.new()
                outcome_line.text = outcome_line_text
                outcome_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
                outcome_line.add_theme_font_size_override("font_size", 12)
                outcome_line.add_theme_color_override("font_color", Color(0.82, 0.90, 0.96, 0.92) if style_name == "support_memory" else Color(0.96, 0.88, 0.78, 0.92))
                stack.add_child(outcome_line)
            if not callout_text.is_empty():
                var callout := Label.new()
                callout.text = callout_text
                callout.add_theme_font_size_override("font_size", 12)
                callout.add_theme_color_override("font_color", border)
                stack.add_child(callout)
            if not quote_text.is_empty():
                var quote := Label.new()
                quote.text = "\"%s\"" % quote_text
                quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
                quote.add_theme_font_size_override("font_size", 14)
                quote.add_theme_color_override("font_color", Color(0.94, 0.97, 1.0, 0.98))
                stack.add_child(quote)
            stack.add_child(body)
        else:
            var generic_progress_rows := _build_ending_criteria_progress_rows(_variant_to_dictionary_array(entry.get("progress_rows", [])))
            stack.add_child(eyebrow)
            stack.add_child(title)
            if generic_progress_rows != null:
                stack.add_child(generic_progress_rows)
            if not memory_rail_text.is_empty():
                var generic_memory_rail := ColorRect.new()
                generic_memory_rail.custom_minimum_size = Vector2(0.0, 3.0)
                generic_memory_rail.color = Color(0.76, 0.84, 0.92, 0.88)
                stack.add_child(generic_memory_rail)
            if not eyebrow_label_text.is_empty():
                var generic_eyebrow_label := Label.new()
                generic_eyebrow_label.text = eyebrow_label_text
                generic_eyebrow_label.add_theme_font_size_override("font_size", 11)
                generic_eyebrow_label.add_theme_color_override("font_color", Color(0.78, 0.88, 0.96, 0.84))
                stack.add_child(generic_eyebrow_label)
            if not source_label_text.is_empty():
                var generic_source_label := Label.new()
                generic_source_label.text = source_label_text
                generic_source_label.add_theme_font_size_override("font_size", 11)
                generic_source_label.add_theme_color_override("font_color", Color(0.76, 0.84, 0.92, 0.84))
                stack.add_child(generic_source_label)
            if not memory_stamp_text.is_empty():
                var generic_memory_stamp := Label.new()
                generic_memory_stamp.text = memory_stamp_text
                generic_memory_stamp.add_theme_font_size_override("font_size", 11)
                generic_memory_stamp.add_theme_color_override("font_color", Color(0.72, 0.78, 0.86, 0.82))
                stack.add_child(generic_memory_stamp)
            if not outcome_line_text.is_empty():
                var generic_outcome_line := Label.new()
                generic_outcome_line.text = outcome_line_text
                generic_outcome_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
                generic_outcome_line.add_theme_font_size_override("font_size", 12)
                generic_outcome_line.add_theme_color_override("font_color", Color(0.80, 0.86, 0.92, 0.90))
                stack.add_child(generic_outcome_line)
            stack.add_child(body)
        margin.add_child(stack)
        card.add_child(margin)
        presentation_cards.add_child(card)

func _build_presentation_badges(entries: Array[Dictionary]) -> Container:
    if entries.is_empty():
        return null
    var row := HFlowContainer.new()
    row.add_theme_constant_override("h_separation", 8)
    row.add_theme_constant_override("v_separation", 8)
    for entry in entries:
        var pill := PanelContainer.new()
        pill.add_theme_stylebox_override("panel", _make_presentation_badge_style(bool(entry.get("complete", false))))
        var margin := MarginContainer.new()
        margin.add_theme_constant_override("margin_left", 8)
        margin.add_theme_constant_override("margin_top", 4)
        margin.add_theme_constant_override("margin_right", 8)
        margin.add_theme_constant_override("margin_bottom", 4)
        var label := Label.new()
        label.text = "%s %s" % [String(entry.get("label", "")), String(entry.get("value", ""))]
        label.add_theme_font_size_override("font_size", 13)
        label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
        label.autowrap_mode = TextServer.AUTOWRAP_OFF
        margin.add_child(label)
        pill.add_child(margin)
        row.add_child(pill)
    return row

func _make_presentation_card_style(fill_color: Color, border_color: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = fill_color
    style.border_color = border_color
    style.set_border_width_all(2)
    style.set_corner_radius_all(16)
    style.shadow_color = Color(0.0, 0.0, 0.0, 0.22)
    style.shadow_size = 8
    return style

func _make_presentation_badge_style(complete: bool) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.18, 0.34, 0.24, 0.98) if complete else Color(0.30, 0.20, 0.20, 0.98)
    style.border_color = Color(0.54, 0.86, 0.66, 0.9) if complete else Color(0.88, 0.54, 0.54, 0.9)
    style.set_border_width_all(1)
    style.set_corner_radius_all(999)
    return style

func _build_ending_criteria_progress_rows(entries: Array[Dictionary]) -> Control:
    if entries.is_empty():
        return null
    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 8)
    for entry in entries:
        var row := VBoxContainer.new()
        row.add_theme_constant_override("separation", 3)

        var header := HBoxContainer.new()
        header.add_theme_constant_override("separation", 8)
        var icon_chip := PanelContainer.new()
        icon_chip.add_theme_stylebox_override("panel", _make_presentation_badge_style(bool(entry.get("complete", false))))
        var icon_margin := MarginContainer.new()
        icon_margin.add_theme_constant_override("margin_left", 6)
        icon_margin.add_theme_constant_override("margin_top", 2)
        icon_margin.add_theme_constant_override("margin_right", 6)
        icon_margin.add_theme_constant_override("margin_bottom", 2)
        var icon_label := Label.new()
        icon_label.text = String(entry.get("icon", "•"))
        icon_label.add_theme_font_size_override("font_size", 12)
        icon_label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
        icon_margin.add_child(icon_label)
        icon_chip.add_child(icon_margin)

        var label := Label.new()
        label.text = String(entry.get("label", "기준"))
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        label.add_theme_font_size_override("font_size", 13)
        label.add_theme_color_override("font_color", Color(0.92, 0.95, 0.99, 0.98))
        var value := Label.new()
        value.text = String(entry.get("value", ""))
        value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        value.add_theme_font_size_override("font_size", 13)
        value.add_theme_color_override("font_color", Color(0.82, 0.88, 0.96, 0.98))
        header.add_child(icon_chip)
        header.add_child(label)
        header.add_child(value)
        row.add_child(header)

        var track := ColorRect.new()
        track.custom_minimum_size = Vector2(0.0, 8.0)
        track.color = Color(0.17, 0.22, 0.29, 0.96)
        var fill_holder := Control.new()
        fill_holder.custom_minimum_size = Vector2(0.0, 8.0)
        fill_holder.set_anchors_preset(Control.PRESET_FULL_RECT)
        track.add_child(fill_holder)

        var fill := ColorRect.new()
        fill.anchor_left = 0.0
        fill.anchor_top = 0.0
        fill.anchor_bottom = 1.0
        fill.anchor_right = clampf(float(entry.get("ratio", 0.0)), 0.0, 1.0)
        fill.offset_left = 0.0
        fill.offset_top = 0.0
        fill.offset_right = 0.0
        fill.offset_bottom = 0.0
        fill.color = Color(0.47, 0.82, 0.96, 0.98) if bool(entry.get("complete", false)) else Color(0.71, 0.54, 0.36, 0.98)
        fill_holder.add_child(fill)
        row.add_child(track)

        var pip_total: int = int(entry.get("pip_total", 0))
        if pip_total > 0:
            var pip_row := HBoxContainer.new()
            pip_row.add_theme_constant_override("separation", 5)
            var pip_filled: int = clampi(int(entry.get("pip_filled", 0)), 0, pip_total)
            for pip_index in range(pip_total):
                var pip := ColorRect.new()
                pip.custom_minimum_size = Vector2(14.0, 6.0)
                pip.color = Color(0.47, 0.82, 0.96, 0.98) if pip_index < pip_filled else Color(0.21, 0.27, 0.34, 0.96)
                pip_row.add_child(pip)
            row.add_child(pip_row)

        var hint_text: String = String(entry.get("hint", "")).strip_edges()
        if not hint_text.is_empty():
            var hint := Label.new()
            hint.text = hint_text
            hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            hint.add_theme_font_size_override("font_size", 11)
            hint.add_theme_color_override("font_color", Color(0.74, 0.82, 0.92, 0.92))
            row.add_child(hint)
        stack.add_child(row)
    return stack

func _rebuild_party_roster() -> void:
    for child in party_roster_buttons.get_children():
        child.queue_free()

    if _party_details.is_empty():
        var empty_label := Label.new()
        empty_label.text = "표시할 부대원이 없다."
        empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        party_roster_buttons.add_child(empty_label)
        return

    for index in _party_details.size():
        var entry: Dictionary = _party_details[index]
        var button := Button.new()
        button.custom_minimum_size = Vector2(0.0, _get_party_button_height())
        button.text = String(entry.get("name", "유닛"))
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
        party_name_label.text = "선택된 부대원이 없다."
        party_status_label.text = ""
        party_stats_label.text = ""
        _render_selected_skills({})
        support_card.visible = false
        support_heading_label.text = "장비 기준"
        support_body_label.text = ""
        _set_slot_preview(weapon_preview, WEAPON_FALLBACK_PREVIEW)
        weapon_item_label.text = "장착한 무기가 없다."
        weapon_hint_label.text = "무기 선택지를 보려면 부대원을 먼저 선택한다."
        _set_slot_preview(armor_preview, ARMOR_FALLBACK_PREVIEW)
        armor_item_label.text = "장착한 방어구가 없다."
        armor_hint_label.text = "방어구 선택지를 보려면 부대원을 먼저 선택한다."
        _set_slot_preview(accessory_preview, ACCESSORY_FALLBACK_PREVIEW)
        accessory_item_label.text = "장착한 장신구가 없다."
        accessory_hint_label.text = "장신구 선택지를 보려면 부대원을 먼저 선택한다."
        party_assignment_button.text = "배치"
        party_assignment_button.disabled = true
        party_assignment_button.tooltip_text = "출전 배치를 관리할 부대원을 선택한다."
        party_weapon_button.text = "무기 없음"
        party_weapon_button.disabled = true
        party_weapon_button.tooltip_text = "장비를 바꾸려면 무기를 먼저 해금하거나 회수해야 한다."
        party_weapon_unequip_button.text = "해제"
        party_weapon_unequip_button.disabled = true
        party_weapon_unequip_button.tooltip_text = "해제할 무기가 없다."
        party_armor_button.text = "방어구 없음"
        party_armor_button.disabled = true
        party_armor_button.tooltip_text = "장비를 바꾸려면 방어구를 먼저 해금하거나 회수해야 한다."
        party_armor_unequip_button.text = "해제"
        party_armor_unequip_button.disabled = true
        party_armor_unequip_button.tooltip_text = "해제할 방어구가 없다."
        party_accessory_button.text = "장신구 장착"
        party_accessory_button.disabled = true
        party_accessory_button.tooltip_text = "장신구를 장착하려면 먼저 해금하거나 회수해야 한다."
        party_accessory_unequip_button.text = "해제"
        party_accessory_unequip_button.disabled = true
        party_accessory_unequip_button.tooltip_text = "해제할 장신구가 없다."
        party_accessory_reforge_button.text = "장신구 보정"
        party_accessory_reforge_button.disabled = true
        party_accessory_reforge_button.tooltip_text = "장신구 선택을 보정할 부대원을 먼저 선택한다."
        return

    var unit_id: String = String(entry.get("unit_id", ""))
    var deployed: bool = _deployed_party_unit_ids.has(unit_id)
    var locked: bool = _locked_party_unit_ids.has(unit_id)
    var role_text: String = "출전 중" if deployed else "대기"
    if locked:
        role_text = "고정"

    party_name_label.text = str(entry.get("name", "유닛"))
    party_status_label.text = "HP %s   상태 %s" % [
        str(entry.get("hp_text", "0/0")),
        role_text
    ]
    party_stats_label.text = "공격 %s   방어 %s   이동 %s   사거리 %s\n스킬 %s" % [
        str(entry.get("attack", 0)),
        str(entry.get("defense", 0)),
        str(entry.get("move", 0)),
        str(entry.get("range", 0)),
        str(entry.get("skill", "스킬 없음"))
    ]
    _render_selected_skills(entry)
    var support_preview_path := str(entry.get("support_preview_path", "")).strip_edges()
    if support_preview_path.is_empty():
        support_card.visible = false
        support_heading_label.text = "장비 기준"
        support_body_label.text = ""
    else:
        support_card.visible = true
        support_heading_label.text = str(entry.get("support_preview_title", "장비 기준"))
        support_body_label.text = str(entry.get("support_preview_body", ""))
        _set_slot_preview(support_preview, support_preview_path)
    _set_slot_preview(weapon_preview, str(entry.get("weapon_preview_path", WEAPON_FALLBACK_PREVIEW)))
    weapon_item_label.text = _format_slot_item_text("weapon", str(entry.get("weapon_slot", "None")))
    var has_weapon_equipped: bool = weapon_item_label.text != "weapon 장착 없음"
    _set_slot_preview(armor_preview, str(entry.get("armor_preview_path", ARMOR_FALLBACK_PREVIEW)))
    armor_item_label.text = _format_slot_item_text("armor", str(entry.get("armor_slot", "None")))
    var has_armor_equipped: bool = armor_item_label.text != "armor 장착 없음"
    _set_slot_preview(accessory_preview, str(entry.get("accessory_preview_path", ACCESSORY_FALLBACK_PREVIEW)))
    accessory_item_label.text = _format_slot_item_text("accessory", str(entry.get("accessory_slot", "None")))
    var has_accessory_equipped: bool = accessory_item_label.text != "accessory 장착 없음"
    if locked:
        party_assignment_button.text = "리안 고정"
        party_assignment_button.disabled = true
        party_assignment_button.tooltip_text = "리안은 챕터 인계에 고정되어 있어 재배치할 수 없다."
    elif deployed:
        party_assignment_button.text = "출전 배정됨"
        party_assignment_button.disabled = true
        party_assignment_button.tooltip_text = "이 유닛은 이미 현재 출전에 배정되어 있다."
    else:
        party_assignment_button.text = "출전에 배치"
        party_assignment_button.disabled = false
        party_assignment_button.tooltip_text = "이 유닛을 다음 전투 편성에 배치한다."

    if _available_weapon_entries.is_empty():
        party_weapon_button.text = "무기 없음"
        party_weapon_button.disabled = true
        party_weapon_button.tooltip_text = "현재 캠프 상태에서는 교체 가능한 무기가 없다."
        party_weapon_unequip_button.text = "해제"
        party_weapon_unequip_button.disabled = not has_weapon_equipped
        party_weapon_unequip_button.tooltip_text = "현재 장착한 무기를 해제한다." if has_weapon_equipped else "해제할 무기가 없다."
        party_weapon_sell_button.text = "판매"
        party_weapon_sell_button.disabled = not has_weapon_equipped
        party_weapon_sell_button.tooltip_text = str(entry.get("weapon_sell_tooltip", "판매할 무기가 없다."))
        weapon_hint_label.text = _build_equipment_eligibility_text(
            "weapon",
            _variant_to_string_array(entry.get("allowed_weapon_types", [])),
            int(entry.get("eligible_weapon_count", 0)),
            int(entry.get("total_weapon_count", 0))
        )
    else:
        party_weapon_button.text = "무기 교체"
        party_weapon_button.disabled = false
        party_weapon_button.tooltip_text = "이 유닛의 다음 해금 무기로 교체한다."
        party_weapon_unequip_button.text = "해제"
        party_weapon_unequip_button.disabled = not has_weapon_equipped
        party_weapon_unequip_button.tooltip_text = "현재 장착한 무기를 해제한다." if has_weapon_equipped else "해제할 무기가 없다."
        party_weapon_sell_button.text = "판매"
        party_weapon_sell_button.disabled = not has_weapon_equipped
        party_weapon_sell_button.tooltip_text = str(entry.get("weapon_sell_tooltip", "판매할 무기가 없다."))
        weapon_hint_label.text = _build_equipment_eligibility_text(
            "weapon",
            _variant_to_string_array(entry.get("allowed_weapon_types", [])),
            int(entry.get("eligible_weapon_count", 0)),
            int(entry.get("total_weapon_count", _available_weapon_entries.size()))
        )

    if _available_armor_entries.is_empty():
        party_armor_button.text = "방어구 없음"
        party_armor_button.disabled = true
        party_armor_button.tooltip_text = "현재 캠프 상태에서는 교체 가능한 방어구가 없다."
        party_armor_unequip_button.text = "해제"
        party_armor_unequip_button.disabled = not has_armor_equipped
        party_armor_unequip_button.tooltip_text = "현재 장착한 방어구를 해제한다." if has_armor_equipped else "해제할 방어구가 없다."
        party_armor_sell_button.text = "판매"
        party_armor_sell_button.disabled = not has_armor_equipped
        party_armor_sell_button.tooltip_text = str(entry.get("armor_sell_tooltip", "판매할 방어구가 없다."))
        armor_hint_label.text = _build_equipment_eligibility_text(
            "armor",
            _variant_to_string_array(entry.get("allowed_armor_types", [])),
            int(entry.get("eligible_armor_count", 0)),
            int(entry.get("total_armor_count", 0))
        )
    else:
        party_armor_button.text = "방어구 교체"
        party_armor_button.disabled = false
        party_armor_button.tooltip_text = "이 유닛의 다음 해금 방어구로 교체한다."
        party_armor_unequip_button.text = "해제"
        party_armor_unequip_button.disabled = not has_armor_equipped
        party_armor_unequip_button.tooltip_text = "현재 장착한 방어구를 해제한다." if has_armor_equipped else "해제할 방어구가 없다."
        party_armor_sell_button.text = "판매"
        party_armor_sell_button.disabled = not has_armor_equipped
        party_armor_sell_button.tooltip_text = str(entry.get("armor_sell_tooltip", "판매할 방어구가 없다."))
        armor_hint_label.text = _build_equipment_eligibility_text(
            "armor",
            _variant_to_string_array(entry.get("allowed_armor_types", [])),
            int(entry.get("eligible_armor_count", 0)),
            int(entry.get("total_armor_count", _available_armor_entries.size()))
        )

    if _available_accessory_entries.is_empty():
        party_accessory_button.text = "장신구 없음"
        party_accessory_button.disabled = true
        party_accessory_button.tooltip_text = "현재 캠프 상태에서는 해금된 장신구가 없다."
        party_accessory_unequip_button.text = "해제"
        party_accessory_unequip_button.disabled = not has_accessory_equipped
        party_accessory_unequip_button.tooltip_text = "현재 장착한 장신구를 해제한다." if has_accessory_equipped else "해제할 장신구가 없다."
        party_accessory_sell_button.text = "판매"
        party_accessory_sell_button.disabled = not has_accessory_equipped
        party_accessory_sell_button.tooltip_text = str(entry.get("accessory_sell_tooltip", "판매할 장신구가 없다."))
        party_accessory_reforge_button.text = "보정 불가"
        party_accessory_reforge_button.disabled = true
        party_accessory_reforge_button.tooltip_text = "선택을 보정하려면 장신구를 최소 두 개 이상 해금해야 한다."
        accessory_hint_label.text = _build_accessory_hint_text("", "", 0)
    else:
        party_accessory_button.text = "장신구 교체"
        party_accessory_button.disabled = false
        party_accessory_button.tooltip_text = "이 유닛의 다음 해금 장신구로 교체한다."
        party_accessory_unequip_button.text = "해제"
        party_accessory_unequip_button.disabled = not has_accessory_equipped
        party_accessory_unequip_button.tooltip_text = "현재 장착한 장신구를 해제한다." if has_accessory_equipped else "해제할 장신구가 없다."
        party_accessory_sell_button.text = "판매"
        party_accessory_sell_button.disabled = not has_accessory_equipped
        party_accessory_sell_button.tooltip_text = str(entry.get("accessory_sell_tooltip", "판매할 장신구가 없다."))
        var can_reforge: bool = bool(entry.get("can_accessory_reforge", false))
        var reforge_tooltip: String = str(entry.get("accessory_reforge_tooltip", ""))
        party_accessory_reforge_button.text = "장신구 보정"
        party_accessory_reforge_button.disabled = not can_reforge
        party_accessory_reforge_button.tooltip_text = "다음 해금 장신구 선택지로 다시 굴린다. %s" % reforge_tooltip if can_reforge else ("장신구를 보정할 재료가 부족하다. %s" % reforge_tooltip)
        accessory_hint_label.text = _build_accessory_hint_text(
            str(entry.get("accessory_summary", "")),
            str(entry.get("accessory_flavor_text", "")),
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

func _render_selected_skills(entry: Dictionary) -> void:
    if entry.is_empty():
        skills_selected_unit_label.text = "선택된 부대원이 없다."
        skill_list.text = "점검할 스킬이 없다."
        return

    var skill_entries := _variant_to_dictionary_array(entry.get("skill_entries", []))
    skills_selected_unit_label.text = "%s 스킬" % str(entry.get("name", "유닛"))
    skill_list.text = _format_skill_entries(skill_entries, str(entry.get("skill", "스킬 없음")))

func _format_skill_entries(skill_entries: Array[Dictionary], fallback_skill_name: String = "") -> String:
    if skill_entries.is_empty():
        if fallback_skill_name.strip_edges().is_empty():
            return "점검할 스킬이 없다."
        return "[b]%s[/b]\n설명 정보가 아직 연결되지 않았다." % fallback_skill_name

    var lines: Array[String] = []
    for entry in skill_entries:
        var name_text: String = str(entry.get("name", entry.get("display_name", "스킬"))).strip_edges()
        if name_text.is_empty():
            name_text = "스킬"
        lines.append("[b]%s[/b]" % name_text)
        var description_text: String = str(entry.get("description", "")).strip_edges()
        lines.append(description_text if not description_text.is_empty() else "설명 정보가 아직 연결되지 않았다.")
        var cost_text: String = str(entry.get("cost_text", entry.get("resource_cost", ""))).strip_edges()
        lines.append("비용: %s" % (cost_text if not cost_text.is_empty() else "없음"))
        var level_value: Variant = entry.get("level", null)
        var exp_to_next: int = int(entry.get("exp_to_next", 0))
        if level_value != null:
            var progress_line := "Lv %d" % int(level_value)
            if exp_to_next > 0:
                progress_line += " / EXP %d/%d" % [int(entry.get("exp", 0)), exp_to_next]
                progress_line += " (다음까지 %d)" % int(entry.get("exp_remaining", maxi(exp_to_next - int(entry.get("exp", 0)), 0)))
            elif bool(entry.get("is_max", false)) or int(level_value) >= 5:
                progress_line += " / MAX"
            lines.append(progress_line)
        lines.append("")
    while not lines.is_empty() and String(lines[lines.size() - 1]).is_empty():
        lines.remove_at(lines.size() - 1)
    return "\n".join(lines)

func _format_slot_item_text(slot_kind: String, slot_value: String) -> String:
    var normalized_value := slot_value.strip_edges()
    if normalized_value.is_empty() or normalized_value == "None":
        return "%s 장착 없음" % slot_kind
    return normalized_value

func _build_slot_hint_text(slot_kind: String, unlocked_count: int) -> String:
    return "해금된 %s 선택지 %d개 사용 가능." % [slot_kind, unlocked_count]

func _build_equipment_eligibility_text(slot_kind: String, allowed_types: Array[String], eligible_count: int, total_count: int) -> String:
    var allowed_text: String = ", ".join(allowed_types) if not allowed_types.is_empty() else "none"
    return "Allowed: %s. Eligible: %d/%d unlocked." % [allowed_text, eligible_count, total_count]

func _build_accessory_eligibility_text(eligible_count: int) -> String:
    return "All recruits may equip accessories. Eligible: %d unlocked." % eligible_count

func _build_accessory_hint_text(summary_text: String, flavor_text: String, eligible_count: int) -> String:
    var summary := summary_text.strip_edges()
    var flavor := flavor_text.strip_edges()
    var eligibility := _build_accessory_eligibility_text(eligible_count)
    var lines: Array[String] = []
    if not summary.is_empty():
        lines.append(summary)
    if not flavor.is_empty() and flavor != summary:
        lines.append(flavor)
    if lines.is_empty():
        return eligibility
    lines.append(eligibility)
    return "\n".join(lines)

func _format_material_lines() -> String:
    var lines: Array[String] = []
    for entry in _material_entries:
        lines.append("%s x%d" % [
            str(entry.get("label", entry.get("material_id", "재료"))),
            int(entry.get("count", 0))
        ])
    return _format_lines_for_panel(lines, "아직 회수한 제작 재료가 없다.")

func _rebuild_forge_recipe_buttons() -> void:
    for child in forge_recipe_buttons.get_children():
        child.queue_free()
    if _forge_recipe_entries.is_empty():
        _selected_forge_recipe_index = -1
        forge_recipe_detail.text = _format_lines_for_panel([], "아직 사용 가능한 제작 레시피가 없다.")
        forge_craft_button.disabled = true
        forge_craft_button.tooltip_text = "현재 캠프 상태에서는 사용 가능한 제작 레시피가 없다."
        return
    for index in range(_forge_recipe_entries.size()):
        var entry: Dictionary = _forge_recipe_entries[index]
        var button := Button.new()
        button.custom_minimum_size = Vector2(0.0, _get_party_button_height())
        button.text = String(entry.get("label", "레시피"))
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        var button_index := index
        button.pressed.connect(func() -> void: _select_forge_recipe_index(button_index))
        forge_recipe_buttons.add_child(button)
    _select_forge_recipe_index(clampi(_selected_forge_recipe_index, 0, _forge_recipe_entries.size() - 1))

func _select_forge_recipe_index(index: int) -> void:
    if _forge_recipe_entries.is_empty():
        _selected_forge_recipe_index = -1
        forge_recipe_detail.text = _format_lines_for_panel([], "아직 사용 가능한 제작 레시피가 없다.")
        forge_craft_button.disabled = true
        forge_craft_button.tooltip_text = "현재 캠프 상태에서는 사용 가능한 제작 레시피가 없다."
        return
    _selected_forge_recipe_index = clampi(index, 0, _forge_recipe_entries.size() - 1)
    var entry: Dictionary = _forge_recipe_entries[_selected_forge_recipe_index]
    var lines: Array[String] = []
    lines.append("제작 결과: %s" % String(entry.get("label", "레시피")))
    for material_line in _variant_to_string_array(entry.get("materials", [])):
        lines.append(material_line)
    if bool(entry.get("owned", false)):
        lines.append("이미 보유 중이다.")
    forge_recipe_detail.text = _format_lines_for_panel(lines, "선택된 제작 레시피가 없다.")
    var can_craft: bool = bool(entry.get("can_craft", false))
    forge_craft_button.text = "%s 제작" % String(entry.get("label", "레시피"))
    forge_craft_button.disabled = not can_craft
    forge_craft_button.tooltip_text = "회수한 재료를 사용해 이 아이템을 제작한다." if can_craft else "재료가 부족하거나 이미 보유한 아이템이다."
    for child_index in range(forge_recipe_buttons.get_child_count()):
        var child = forge_recipe_buttons.get_child(child_index)
        if child is Button:
            child.disabled = child_index == _selected_forge_recipe_index

func _get_selected_forge_recipe_id() -> String:
    if _selected_forge_recipe_index < 0 or _selected_forge_recipe_index >= _forge_recipe_entries.size():
        return ""
    return String(_forge_recipe_entries[_selected_forge_recipe_index].get("recipe_id", ""))

func _set_slot_preview(texture_rect: TextureRect, resource_path: String) -> void:
    if texture_rect == null:
        return
    var normalized_path: String = resource_path.strip_edges()
    if normalized_path.is_empty():
        texture_rect.texture = _build_placeholder_preview_texture("empty")
        return

    var absolute_path: String = ProjectSettings.globalize_path(normalized_path)
    if FileAccess.file_exists(absolute_path):
        var image := Image.new()
        if image.load(absolute_path) == OK:
            texture_rect.texture = ImageTexture.create_from_image(image)
            return

    if ResourceLoader.exists(normalized_path):
        var texture := load(normalized_path) as Texture2D
        if texture != null:
            texture_rect.texture = texture
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
    if _current_mode == CampaignState.MODE_BRIEFING:
        ui_cue_requested.emit("ui_common_confirm_01")
        briefing_abort_requested.emit()
        return
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
    var entry: Dictionary = _get_selected_party_entry()
    _show_equipment_popup("weapon", _variant_to_dictionary_array(entry.get("eligible_weapon_options", [])))

func _on_party_weapon_unequip_pressed() -> void:
    var unit_id: String = _get_selected_party_unit_id()
    if unit_id.is_empty():
        return
    ui_cue_requested.emit("camp_loadout_weapon_cycle_01")
    weapon_unequip_requested.emit(StringName(unit_id))

func _on_party_weapon_sell_pressed() -> void:
    var unit_id: String = _get_selected_party_unit_id()
    if unit_id.is_empty():
        return
    _open_sell_confirm("weapon", StringName(unit_id))

func _on_party_armor_pressed() -> void:
    var unit_id: String = _get_selected_party_unit_id()
    if unit_id.is_empty():
        return
    ui_cue_requested.emit("camp_loadout_armor_cycle_01")
    var entry: Dictionary = _get_selected_party_entry()
    _show_equipment_popup("armor", _variant_to_dictionary_array(entry.get("eligible_armor_options", [])))

func _on_party_armor_unequip_pressed() -> void:
    var unit_id: String = _get_selected_party_unit_id()
    if unit_id.is_empty():
        return
    ui_cue_requested.emit("camp_loadout_armor_cycle_01")
    armor_unequip_requested.emit(StringName(unit_id))

func _on_party_armor_sell_pressed() -> void:
    var unit_id: String = _get_selected_party_unit_id()
    if unit_id.is_empty():
        return
    _open_sell_confirm("armor", StringName(unit_id))

func _on_party_accessory_pressed() -> void:
    var unit_id: String = _get_selected_party_unit_id()
    if unit_id.is_empty():
        return
    ui_cue_requested.emit("camp_loadout_accessory_cycle_01")
    var entry: Dictionary = _get_selected_party_entry()
    _show_equipment_popup("accessory", _variant_to_dictionary_array(entry.get("eligible_accessory_options", [])))

func _on_party_accessory_unequip_pressed() -> void:
    var unit_id: String = _get_selected_party_unit_id()
    if unit_id.is_empty():
        return
    ui_cue_requested.emit("camp_loadout_accessory_cycle_01")
    accessory_unequip_requested.emit(StringName(unit_id))

func _on_party_accessory_sell_pressed() -> void:
    var unit_id: String = _get_selected_party_unit_id()
    if unit_id.is_empty():
        return
    _open_sell_confirm("accessory", StringName(unit_id))

func _on_party_accessory_reforge_pressed() -> void:
    var unit_id: String = _get_selected_party_unit_id()
    if unit_id.is_empty():
        return
    ui_cue_requested.emit("camp_loadout_accessory_cycle_01")
    accessory_reforge_requested.emit(StringName(unit_id))

func _on_forge_craft_pressed() -> void:
    var recipe_id: String = _get_selected_forge_recipe_id()
    if recipe_id.is_empty():
        return
    ui_cue_requested.emit("ui_common_confirm_01")
    forge_craft_requested.emit(StringName(recipe_id))

func _sync_inventory_sell_buttons() -> void:
    _configure_inventory_sell_button(inventory_weapon_sell_button, _inventory_weapon_sell_options, _inventory_weapon_sell_option, "미장착 무기 판매")
    _configure_inventory_sell_button(inventory_armor_sell_button, _inventory_armor_sell_options, _inventory_armor_sell_option, "미장착 방어구 판매")
    _configure_inventory_sell_button(inventory_accessory_sell_button, _inventory_accessory_sell_options, _inventory_accessory_sell_option, "미장착 장신구 판매")

func _configure_inventory_sell_button(button: Button, options: Array[Dictionary], option: Dictionary, fallback_label: String) -> void:
    if button == null:
        return
    var item_id: String = String(option.get("item_id", "")).strip_edges()
    var label: String = String(option.get("label", fallback_label)).strip_edges()
    var tooltip: String = String(option.get("tooltip", "판매할 장비가 없다.")).strip_edges()
    if item_id.is_empty():
        button.text = fallback_label
        button.disabled = true
        button.tooltip_text = tooltip
        return
    if options.size() > 1:
        button.text = "%s (%d종)" % [fallback_label, options.size()]
        button.tooltip_text = "여러 스택 중 판매할 장비를 고른다."
        button.disabled = false
        return
    button.text = "%s: %s" % [fallback_label, label]
    button.disabled = false
    button.tooltip_text = tooltip

func _on_inventory_weapon_sell_pressed() -> void:
    if _inventory_weapon_sell_options.is_empty():
        return
    if _inventory_weapon_sell_options.size() == 1:
        var item_id: String = String(_inventory_weapon_sell_option.get("item_id", "")).strip_edges()
        if item_id.is_empty():
            return
        _open_sell_confirm("inventory_weapon", StringName(item_id))
        return
    ui_cue_requested.emit("camp_loadout_weapon_cycle_01")
    _show_equipment_popup("inventory_weapon", _inventory_weapon_sell_options)

func _on_inventory_armor_sell_pressed() -> void:
    if _inventory_armor_sell_options.is_empty():
        return
    if _inventory_armor_sell_options.size() == 1:
        var item_id: String = String(_inventory_armor_sell_option.get("item_id", "")).strip_edges()
        if item_id.is_empty():
            return
        _open_sell_confirm("inventory_armor", StringName(item_id))
        return
    ui_cue_requested.emit("camp_loadout_armor_cycle_01")
    _show_equipment_popup("inventory_armor", _inventory_armor_sell_options)

func _on_inventory_accessory_sell_pressed() -> void:
    if _inventory_accessory_sell_options.is_empty():
        return
    if _inventory_accessory_sell_options.size() == 1:
        var item_id: String = String(_inventory_accessory_sell_option.get("item_id", "")).strip_edges()
        if item_id.is_empty():
            return
        _open_sell_confirm("inventory_accessory", StringName(item_id))
        return
    ui_cue_requested.emit("camp_loadout_accessory_cycle_01")
    _show_equipment_popup("inventory_accessory", _inventory_accessory_sell_options)

func _get_selected_party_entry() -> Dictionary:
    if _selected_party_index < 0 or _selected_party_index >= _party_details.size():
        return {}
    return _party_details[_selected_party_index]

func _show_equipment_popup(slot_kind: String, options: Array[Dictionary]) -> void:
    var popup: PopupMenu = _get_equipment_popup(slot_kind)
    if popup == null or options.is_empty():
        return
    popup.clear()
    _active_equipment_popup_slot = slot_kind
    _active_equipment_popup_labels.clear()
    for option_index in range(options.size()):
        var option: Dictionary = options[option_index]
        var label: String = String(option.get("label", option.get("item_id", "장비"))).strip_edges()
        popup.add_item(label, option_index)
        popup.set_item_metadata(option_index, String(option.get("item_id", "")))
        _active_equipment_popup_labels.append(label)
    popup.reset_size()
    popup.popup_centered(Vector2i(360, 0))

func _get_equipment_popup(slot_kind: String) -> PopupMenu:
    match slot_kind:
        "weapon":
            return weapon_select_popup
        "armor":
            return armor_select_popup
        "accessory":
            return accessory_select_popup
        "inventory_weapon":
            return inventory_weapon_select_popup
        "inventory_armor":
            return inventory_armor_select_popup
        "inventory_accessory":
            return inventory_accessory_select_popup
        _:
            return null

func _on_weapon_popup_id_pressed(option_index: int) -> void:
    _emit_equipment_selected("weapon", weapon_select_popup, option_index)

func _on_armor_popup_id_pressed(option_index: int) -> void:
    _emit_equipment_selected("armor", armor_select_popup, option_index)

func _on_accessory_popup_id_pressed(option_index: int) -> void:
    _emit_equipment_selected("accessory", accessory_select_popup, option_index)

func _on_inventory_weapon_popup_id_pressed(option_index: int) -> void:
    _emit_equipment_selected("inventory_weapon", inventory_weapon_select_popup, option_index)

func _on_inventory_armor_popup_id_pressed(option_index: int) -> void:
    _emit_equipment_selected("inventory_armor", inventory_armor_select_popup, option_index)

func _on_inventory_accessory_popup_id_pressed(option_index: int) -> void:
    _emit_equipment_selected("inventory_accessory", inventory_accessory_select_popup, option_index)

func _emit_equipment_selected(slot_kind: String, popup: PopupMenu, option_index: int) -> void:
    var unit_id: String = _get_selected_party_unit_id()
    if popup == null:
        return
    var item_id: String = String(popup.get_item_metadata(option_index))
    _active_equipment_popup_slot = ""
    _active_equipment_popup_labels.clear()
    if item_id.is_empty():
        return
    match slot_kind:
        "weapon":
            if unit_id.is_empty():
                return
            weapon_selected_requested.emit(StringName(unit_id), StringName(item_id))
        "armor":
            if unit_id.is_empty():
                return
            armor_selected_requested.emit(StringName(unit_id), StringName(item_id))
        "accessory":
            if unit_id.is_empty():
                return
            accessory_selected_requested.emit(StringName(unit_id), StringName(item_id))
        "inventory_weapon", "inventory_armor", "inventory_accessory":
            _open_sell_confirm(slot_kind, StringName(item_id))

func _open_sell_confirm(slot_kind: String, unit_id: StringName) -> void:
    if sell_confirm_dialog == null:
        return
    var entry: Dictionary = _get_selected_party_entry()
    var item_name: String = "장비"
    var tooltip: String = ""
    match slot_kind:
        "weapon":
            item_name = String(entry.get("weapon_slot", "무기"))
            tooltip = String(entry.get("weapon_sell_tooltip", ""))
        "armor":
            item_name = String(entry.get("armor_slot", "방어구"))
            tooltip = String(entry.get("armor_sell_tooltip", ""))
        "accessory":
            item_name = String(entry.get("accessory_slot", "장신구"))
            tooltip = String(entry.get("accessory_sell_tooltip", ""))
        "inventory_weapon":
            item_name = String(_inventory_weapon_sell_option.get("label", "무기"))
            tooltip = String(_inventory_weapon_sell_option.get("tooltip", ""))
        "inventory_armor":
            item_name = String(_inventory_armor_sell_option.get("label", "방어구"))
            tooltip = String(_inventory_armor_sell_option.get("tooltip", ""))
        "inventory_accessory":
            item_name = String(_inventory_accessory_sell_option.get("label", "장신구"))
            tooltip = String(_inventory_accessory_sell_option.get("tooltip", ""))
    _pending_sell_slot = slot_kind
    _pending_sell_unit_id = unit_id
    sell_confirm_dialog.dialog_text = "정말 `%s`를 판매할까요?\n%s" % [item_name, tooltip]
    sell_confirm_dialog.popup_centered()

func _on_sell_confirmed() -> void:
    if _pending_sell_unit_id == &"" or _pending_sell_slot.is_empty():
        return
    ui_cue_requested.emit("ui_common_confirm_01")
    match _pending_sell_slot:
        "weapon":
            weapon_sell_requested.emit(_pending_sell_unit_id)
        "armor":
            armor_sell_requested.emit(_pending_sell_unit_id)
        "accessory":
            accessory_sell_requested.emit(_pending_sell_unit_id)
        "inventory_weapon":
            inventory_weapon_sell_requested.emit(_pending_sell_unit_id)
        "inventory_armor":
            inventory_armor_sell_requested.emit(_pending_sell_unit_id)
        "inventory_accessory":
            inventory_accessory_sell_requested.emit(_pending_sell_unit_id)
    _pending_sell_slot = ""
    _pending_sell_unit_id = &""

func _update_responsive_layout() -> void:
    _apply_layout_for_viewport_size(get_viewport_rect().size)

func _apply_layout_for_viewport_size(viewport_size: Vector2) -> void:
    _compact_layout = viewport_size.x <= COMPACT_WIDTH_THRESHOLD

    section_tabs.columns = 2 if _compact_layout else SECTION_ORDER.size()
    party_content.vertical = _compact_layout
    var tab_button_height := COMPACT_TAB_BUTTON_HEIGHT if _compact_layout else REGULAR_TAB_BUTTON_HEIGHT
    for button in [summary_button, party_button, skills_button, inventory_button, forge_button, dialogue_history_button, records_button]:
        button.custom_minimum_size = Vector2(0.0, tab_button_height)

    var party_button_height := _get_party_button_height()
    for button in [party_assignment_button, party_weapon_button, party_armor_button, party_accessory_button, party_accessory_reforge_button, forge_craft_button]:
        button.custom_minimum_size = Vector2(0.0, party_button_height)
    advance_button.custom_minimum_size = Vector2(0.0, PRIMARY_CTA_HEIGHT)
    for child in party_roster_buttons.get_children():
        if child is Button:
            child.custom_minimum_size = Vector2(0.0, party_button_height)

    for list in [dialogue_label, skill_list, inventory_list, forge_materials_list, forge_recipe_detail, dialogue_recent_list, dialogue_support_list, dialogue_handoff_list, memory_list, evidence_list, letter_list]:
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
