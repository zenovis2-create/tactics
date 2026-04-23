class_name CampaignController
extends Node

signal mode_changed(mode: String)
signal return_to_title_requested(show_credits: bool)

const BattleController = preload("res://scripts/battle/battle_controller.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const CampaignPanel = preload("res://scripts/campaign/campaign_panel.gd")
const CampaignState = preload("res://scripts/campaign/campaign_state.gd")
const CampaignShellDialogueCatalog = preload("res://scripts/campaign/campaign_shell_dialogue_catalog.gd")
const CampaignCatalog = preload("res://scripts/campaign/campaign_catalog.gd")
const CampaignChapterRegistry = preload("res://scripts/campaign/campaign_chapter_registry.gd")
const CampaignContentRegistry = preload("res://scripts/campaign/campaign_content_registry.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const AccessoryData = preload("res://scripts/data/accessory_data.gd")
const WeaponData = preload("res://scripts/data/weapon_data.gd")
const ArmorData = preload("res://scripts/data/armor_data.gd")
const CampController = preload("res://scripts/camp/camp_controller.gd")
const ForgeService = preload("res://scripts/battle/forge_service.gd")
const ReforgeService = preload("res://scripts/battle/reforge_service.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")
const HuntStageRegistry = preload("res://scripts/battle/hunt_stage_registry.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const EndingResolver = preload("res://scripts/battle/ending_resolver.gd")
const SupportConversations = preload("res://data/support_conversations.gd")
const StageResolutionService = preload("res://scripts/battle/stage_resolution_service.gd")
const CutsceneCatalog = preload("res://data/cutscenes/cutscene_catalog.gd")

const CHAPTER_CH01: StringName = CampaignChapterRegistry.CHAPTER_CH01
const CHAPTER_CH02: StringName = CampaignChapterRegistry.CHAPTER_CH02
const CHAPTER_CH03: StringName = CampaignChapterRegistry.CHAPTER_CH03
const CHAPTER_CH04: StringName = CampaignChapterRegistry.CHAPTER_CH04
const CHAPTER_CH05: StringName = CampaignChapterRegistry.CHAPTER_CH05
const CHAPTER_CH06: StringName = CampaignChapterRegistry.CHAPTER_CH06
const CHAPTER_CH07: StringName = CampaignChapterRegistry.CHAPTER_CH07
const CHAPTER_CH08: StringName = CampaignChapterRegistry.CHAPTER_CH08
const CHAPTER_CH09A: StringName = CampaignChapterRegistry.CHAPTER_CH09A
const CHAPTER_CH09B: StringName = CampaignChapterRegistry.CHAPTER_CH09B
const CHAPTER_CH10: StringName = CampaignChapterRegistry.CHAPTER_CH10

var _battle_controller: BattleController
var _campaign_panel: CampaignPanel
var _camp_controller: CampController
var _forge_service: ForgeService
var _save_service: SaveService
var _active_mode: String = CampaignState.MODE_BATTLE
var _active_chapter_id: StringName = CHAPTER_CH01
var _active_stage_index: int = 0
var _current_stage: StageData
var _current_panel_title: String = ""
var _current_panel_body: String = ""
var _chapter_reward_entries: Array[String] = []
var _unlocked_memory_entries: Array[String] = []
var _unlocked_evidence_entries: Array[String] = []
var _unlocked_letter_entries: Array[String] = []
const PALADIN_SHIELD_SUPPORT_IMAGE := "res://assets/props/paladin_shield/runtime/paladin_shield_integration_v01.png"
const PALADIN_SHIELD_SUPPORT_TITLE := "방패 실루엣 기준"
const PALADIN_SHIELD_SUPPORT_BODY := "기사와 중장갑 전열은 이 방패 기준 이미지를 통해 방어 장비의 읽기 우선순위를 공유한다. 두꺼운 외곽, 단일 문장, 절제된 남청 포인트가 핵심이다."
const FIELD_SWORD_SUPPORT_IMAGE := "res://assets/props/field_sword_01/runtime/field_sword_01_integration_v01.png"
const FIELD_SWORD_SUPPORT_TITLE := "검 실루엣 기준"
const FIELD_SWORD_SUPPORT_BODY := "리안의 전열 언어는 이 검 기준 이미지를 따른다. 곧은 칼날, 짧은 가드, 절제된 남청 포인트가 frontline sword lane의 기준이다."
var _deployed_party_unit_ids: Array[StringName] = [&"ally_rian", &"ally_serin"]
var _unlocked_accessory_ids: Array[StringName] = []
var _unlocked_weapon_ids: Array[StringName] = []
var _unlocked_armor_ids: Array[StringName] = []
var _equipped_weapon_by_unit_id: Dictionary = {}
var _equipped_armor_by_unit_id: Dictionary = {}
var _equipped_accessory_by_unit_id: Dictionary = {}
var _ng_plus_enabled: bool = false
var _support_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _debug_support_rolls: Array[float] = []
var _recent_support_dialogue_entries: Array[String] = []
var _recent_support_presentation_cards: Array[Dictionary] = []
var _briefing_abort_active: bool = false
var _stage_resolution_service: StageResolutionService

func setup(battle_controller: BattleController, campaign_panel: CampaignPanel) -> void:
    _battle_controller = battle_controller
    _campaign_panel = campaign_panel
    _support_rng.randomize()
    _camp_controller = CampController.new()
    add_child(_camp_controller)
    _forge_service = ForgeService.new()
    add_child(_forge_service)
    _save_service = SaveService.new()
    add_child(_save_service)
    _stage_resolution_service = StageResolutionService.new()

    if _battle_controller != null and not _battle_controller.battle_finished.is_connected(_on_battle_finished):
        _battle_controller.battle_finished.connect(_on_battle_finished)

    if _campaign_panel != null and not _campaign_panel.advance_requested.is_connected(_on_advance_requested):
        _campaign_panel.advance_requested.connect(_on_advance_requested)
    if _campaign_panel != null and not _campaign_panel.briefing_abort_requested.is_connected(_on_briefing_abort_requested):
        _campaign_panel.briefing_abort_requested.connect(_on_briefing_abort_requested)
    if _campaign_panel != null and not _campaign_panel.deployment_assignment_requested.is_connected(_on_deployment_assignment_requested):
        _campaign_panel.deployment_assignment_requested.connect(_on_deployment_assignment_requested)
    if _campaign_panel != null and not _campaign_panel.weapon_cycle_requested.is_connected(_on_weapon_cycle_requested):
        _campaign_panel.weapon_cycle_requested.connect(_on_weapon_cycle_requested)
    if _campaign_panel != null and not _campaign_panel.weapon_selected_requested.is_connected(_on_weapon_selected_requested):
        _campaign_panel.weapon_selected_requested.connect(_on_weapon_selected_requested)
    if _campaign_panel != null and not _campaign_panel.weapon_unequip_requested.is_connected(_on_weapon_unequip_requested):
        _campaign_panel.weapon_unequip_requested.connect(_on_weapon_unequip_requested)
    if _campaign_panel != null and not _campaign_panel.weapon_sell_requested.is_connected(_on_weapon_sell_requested):
        _campaign_panel.weapon_sell_requested.connect(_on_weapon_sell_requested)
    if _campaign_panel != null and not _campaign_panel.inventory_weapon_sell_requested.is_connected(_on_inventory_weapon_sell_requested):
        _campaign_panel.inventory_weapon_sell_requested.connect(_on_inventory_weapon_sell_requested)
    if _campaign_panel != null and not _campaign_panel.armor_cycle_requested.is_connected(_on_armor_cycle_requested):
        _campaign_panel.armor_cycle_requested.connect(_on_armor_cycle_requested)
    if _campaign_panel != null and not _campaign_panel.armor_selected_requested.is_connected(_on_armor_selected_requested):
        _campaign_panel.armor_selected_requested.connect(_on_armor_selected_requested)
    if _campaign_panel != null and not _campaign_panel.armor_unequip_requested.is_connected(_on_armor_unequip_requested):
        _campaign_panel.armor_unequip_requested.connect(_on_armor_unequip_requested)
    if _campaign_panel != null and not _campaign_panel.armor_sell_requested.is_connected(_on_armor_sell_requested):
        _campaign_panel.armor_sell_requested.connect(_on_armor_sell_requested)
    if _campaign_panel != null and not _campaign_panel.inventory_armor_sell_requested.is_connected(_on_inventory_armor_sell_requested):
        _campaign_panel.inventory_armor_sell_requested.connect(_on_inventory_armor_sell_requested)
    if _campaign_panel != null and not _campaign_panel.accessory_cycle_requested.is_connected(_on_accessory_cycle_requested):
        _campaign_panel.accessory_cycle_requested.connect(_on_accessory_cycle_requested)
    if _campaign_panel != null and not _campaign_panel.accessory_selected_requested.is_connected(_on_accessory_selected_requested):
        _campaign_panel.accessory_selected_requested.connect(_on_accessory_selected_requested)
    if _campaign_panel != null and not _campaign_panel.accessory_unequip_requested.is_connected(_on_accessory_unequip_requested):
        _campaign_panel.accessory_unequip_requested.connect(_on_accessory_unequip_requested)
    if _campaign_panel != null and not _campaign_panel.accessory_sell_requested.is_connected(_on_accessory_sell_requested):
        _campaign_panel.accessory_sell_requested.connect(_on_accessory_sell_requested)
    if _campaign_panel != null and not _campaign_panel.inventory_accessory_sell_requested.is_connected(_on_inventory_accessory_sell_requested):
        _campaign_panel.inventory_accessory_sell_requested.connect(_on_inventory_accessory_sell_requested)
    if _campaign_panel != null and not _campaign_panel.accessory_reforge_requested.is_connected(_on_accessory_reforge_requested):
        _campaign_panel.accessory_reforge_requested.connect(_on_accessory_reforge_requested)
    if _campaign_panel != null and not _campaign_panel.forge_craft_requested.is_connected(_on_forge_craft_requested):
        _campaign_panel.forge_craft_requested.connect(_on_forge_craft_requested)

func start_chapter_one_flow() -> void:
    _active_chapter_id = CHAPTER_CH01
    _active_stage_index = 0
    _deployed_party_unit_ids = [&"ally_rian", &"ally_serin"]
    _unlocked_accessory_ids.clear()
    _unlocked_weapon_ids.clear()
    _unlocked_armor_ids.clear()
    _equipped_weapon_by_unit_id.clear()
    _equipped_armor_by_unit_id.clear()
    _recent_support_dialogue_entries.clear()
    _recent_support_presentation_cards.clear()
    _equipped_accessory_by_unit_id.clear()
    _chapter_reward_entries.clear()
    _unlocked_memory_entries.clear()
    _unlocked_evidence_entries.clear()
    _unlocked_letter_entries.clear()
    _enter_stage(_active_stage_index)

func set_ng_plus_mode(enabled: bool) -> void:
    _ng_plus_enabled = enabled

func advance_step() -> bool:
    if _active_mode == CampaignState.MODE_CUTSCENE:
        _active_stage_index += 1
        var active_flow: Array[StageData] = _get_active_stage_flow()
        if _active_stage_index >= active_flow.size():
            if _active_chapter_id == CHAPTER_CH01:
                _enter_camp_state()
            elif _active_chapter_id == CHAPTER_CH02:
                _enter_chapter_two_camp()
            elif _active_chapter_id == CHAPTER_CH03:
                _enter_chapter_three_camp()
            elif _active_chapter_id == CHAPTER_CH04:
                _enter_chapter_four_camp()
            elif _active_chapter_id == CHAPTER_CH05:
                _enter_chapter_five_camp()
            elif _active_chapter_id == CHAPTER_CH06:
                _enter_chapter_six_camp()
            elif _active_chapter_id == CHAPTER_CH07:
                _enter_chapter_seven_camp()
            elif _active_chapter_id == CHAPTER_CH08:
                _enter_chapter_eight_camp()
            elif _active_chapter_id == CHAPTER_CH09A:
                _enter_chapter_nine_a_camp()
            elif _active_chapter_id == CHAPTER_CH09B:
                _enter_chapter_nine_b_camp()
            elif _active_chapter_id == CHAPTER_CH10:
                _enter_chapter_ten_resolution()
            else:
                _enter_chapter_complete_state()
            return true
        _enter_stage(_active_stage_index)
        return true

    if _active_mode == CampaignState.MODE_BRIEFING:
        _on_briefing_deploy_pressed()
        return true

    if _active_mode == CampaignState.MODE_CAMP:
        if _briefing_abort_active and _current_stage != null:
            _briefing_abort_active = false
            _enter_briefing_state(_current_stage.stage_id)
            return true
        if _active_chapter_id == CHAPTER_CH01:
            _enter_chapter_two_intro()
        elif _active_chapter_id == CHAPTER_CH02:
            _enter_chapter_three_intro()
        elif _active_chapter_id == CHAPTER_CH03:
            _enter_chapter_four_intro()
        elif _active_chapter_id == CHAPTER_CH04:
            _enter_chapter_five_intro()
        elif _active_chapter_id == CHAPTER_CH05:
            _enter_chapter_six_intro()
        elif _active_chapter_id == CHAPTER_CH06:
            _enter_chapter_seven_intro()
        elif _active_chapter_id == CHAPTER_CH07:
            _enter_chapter_eight_intro()
        elif _active_chapter_id == CHAPTER_CH08:
            _enter_chapter_nine_a_intro()
        elif _active_chapter_id == CHAPTER_CH09A:
            _enter_chapter_nine_b_intro()
        elif _active_chapter_id == CHAPTER_CH09B:
            _enter_chapter_ten_intro()
        else:
            _enter_chapter_complete_state()
        return true

    if _active_mode == CampaignState.MODE_CHAPTER_INTRO:
        if _active_chapter_id == CHAPTER_CH01:
            _start_chapter_two_flow()
        elif _active_chapter_id == CHAPTER_CH02:
            _start_chapter_three_flow()
        elif _active_chapter_id == CHAPTER_CH03:
            _start_chapter_four_flow()
        elif _active_chapter_id == CHAPTER_CH04:
            _start_chapter_five_flow()
        elif _active_chapter_id == CHAPTER_CH05:
            _start_chapter_six_flow()
        elif _active_chapter_id == CHAPTER_CH06:
            _start_chapter_seven_flow()
        elif _active_chapter_id == CHAPTER_CH07:
            _start_chapter_eight_flow()
        elif _active_chapter_id == CHAPTER_CH08:
            _start_chapter_nine_a_flow()
        elif _active_chapter_id == CHAPTER_CH09A:
            _start_chapter_nine_b_flow()
        elif _active_chapter_id == CHAPTER_CH09B:
            _start_chapter_ten_flow()
        return true

    return false

func get_state_snapshot() -> Dictionary:
    var panel_snapshot: Dictionary = {}
    if _campaign_panel != null:
        panel_snapshot = _campaign_panel.get_snapshot()

    var snapshot := {
        "mode": _active_mode,
        "chapter_id": _active_chapter_id,
        "flow_index": _active_stage_index,
        "flow_total": _get_active_stage_flow().size(),
        "current_stage_id": _current_stage.stage_id if _current_stage != null else StringName(),
        "current_stage_title": _current_stage.get_display_title() if _current_stage != null else "",
        "panel_title": panel_snapshot.get("title", _current_panel_title),
        "panel_body": panel_snapshot.get("body", _current_panel_body),
        "panel_visible": panel_snapshot.get("visible", false)
    }
    for key in panel_snapshot.keys():
        snapshot[key] = panel_snapshot[key]
    snapshot["mode"] = _active_mode
    return snapshot

func _enter_stage(stage_index: int) -> void:
    var active_flow: Array[StageData] = _get_active_stage_flow()
    if stage_index < 0 or stage_index >= active_flow.size():
        push_warning("Stage index %d is out of bounds for active chapter flow." % stage_index)
        return

    _current_stage = active_flow[stage_index].duplicate(true)
    _current_stage.ally_units = _build_runtime_deployed_party()
    _current_stage.ally_spawns = _build_runtime_ally_spawns(_current_stage)

    if _should_show_briefing(_current_stage.stage_id) and _active_mode != CampaignState.MODE_BRIEFING:
        _enter_briefing_state(_current_stage.stage_id)
        return

    _briefing_abort_active = false
    _active_mode = CampaignState.MODE_BATTLE
    _clear_panel_state()

    if _battle_controller != null:
        _battle_controller.set_equipped_weapon_map(_build_runtime_weapon_map())
        _battle_controller.set_equipped_armor_map(_build_runtime_armor_map())
        _battle_controller.set_equipped_accessory_map(_build_runtime_accessory_map())
        _battle_controller.visible = true
        _battle_controller.set_stage(_current_stage)
    mode_changed.emit(_active_mode)

func _should_show_briefing(stage_id: StringName) -> bool:
    return stage_id == &"CH04_03" or stage_id == &"CH06_02" \
        or stage_id == &"CH01_05" or stage_id == &"CH02_05" or stage_id == &"CH03_05" \
        or stage_id == &"CH04_05" or stage_id == &"CH05_05" or stage_id == &"CH06_05" \
        or stage_id == &"CH07_05" or stage_id == &"CH08_05" or stage_id == &"CH09A_05" \
        or stage_id == &"CH09B_05" or stage_id == &"CH10_05"

func _get_briefing_data(stage_id: StringName) -> Dictionary:
    return CampaignShellDialogueCatalog.get_briefing(stage_id)

func _enter_briefing_state(stage_id: StringName) -> void:
    var briefing: Dictionary = _get_briefing_data(stage_id)
    if briefing.is_empty():
        _briefing_abort_active = false
        _active_mode = CampaignState.MODE_BATTLE
        _clear_panel_state()
        if _battle_controller != null:
            _battle_controller.set_equipped_weapon_map(_build_runtime_weapon_map())
            _battle_controller.set_equipped_armor_map(_build_runtime_armor_map())
            _battle_controller.set_equipped_accessory_map(_build_runtime_accessory_map())
            _battle_controller.visible = true
            _battle_controller.set_stage(_current_stage)
        mode_changed.emit(_active_mode)
        return

    _briefing_abort_active = false
    _active_mode = CampaignState.MODE_BRIEFING
    _set_panel_state(
        CampaignState.MODE_BRIEFING,
        String(briefing.get("chapter", "작전 브리핑")),
        _build_briefing_body(briefing),
        "출격"
    )

func _build_briefing_body(briefing: Dictionary) -> String:
    var lines: Array[String] = []
    var brief_text: String = String(briefing.get("brief_text", "")).strip_edges()
    if not brief_text.is_empty():
        lines.append(brief_text)
    lines.append("턴 제한: %d" % int(briefing.get("turn_limit", 20)))
    return "\n".join(lines)

func _build_briefing_payload(briefing: Dictionary) -> Dictionary:
    return {
        "enemy_intel": _variant_to_string_array(briefing.get("enemy_intel", [])),
        "terrain_summary": _variant_to_string_array(briefing.get("terrain_summary", [])),
        "optional_objectives": _variant_to_string_array(briefing.get("optional_objectives", [])),
        "turn_limit": int(briefing.get("turn_limit", 20))
    }

func _build_briefing_abort_body(briefing: Dictionary) -> String:
    var chapter_label: String = String(briefing.get("chapter", "작전 지역")).strip_edges()
    return "출격을 취소했다. 부대는 %s 외곽 야전 캠프로 물러난다. 로스터, 장비, 확인된 정보를 다시 점검한 뒤 작전 브리핑으로 돌아간다." % chapter_label

func _on_briefing_deploy_pressed() -> void:
    _enter_stage(_active_stage_index)

func _on_briefing_abort_requested() -> void:
    if _current_stage == null:
        return
    var briefing: Dictionary = _get_briefing_data(_current_stage.stage_id)
    _briefing_abort_active = true
    _active_mode = CampaignState.MODE_CAMP
    _set_panel_state(
        CampaignState.MODE_CAMP,
        "%s 야전 캠프" % String(briefing.get("chapter", "작전 브리핑")),
        _build_briefing_abort_body(briefing),
        "브리핑으로 복귀"
    )

func _on_battle_finished(result: StringName, stage_id: StringName) -> void:
    if result != &"victory":
        # 패배 처리는 main.gd의 DefeatScreen이 담당 (이중 표시 방지)
        _active_mode = CampaignState.MODE_BATTLE
        mode_changed.emit(_active_mode)
        return

    if _current_stage == null or stage_id != _current_stage.stage_id:
        return

    _commit_stage_rewards(_current_stage)
    _process_post_battle_supports(_current_stage)

    var active_flow: Array[StageData] = _get_active_stage_flow()
    if _active_stage_index >= active_flow.size() - 1:
        if _active_chapter_id == CHAPTER_CH01:
            _enter_camp_state()
        elif _active_chapter_id == CHAPTER_CH02:
            _enter_chapter_two_camp()
        elif _active_chapter_id == CHAPTER_CH03:
            _enter_chapter_three_camp()
        elif _active_chapter_id == CHAPTER_CH04:
            _enter_chapter_four_camp()
        elif _active_chapter_id == CHAPTER_CH05:
            _enter_chapter_five_camp()
        elif _active_chapter_id == CHAPTER_CH06:
            _enter_chapter_six_camp()
        elif _active_chapter_id == CHAPTER_CH07:
            _enter_chapter_seven_camp()
        elif _active_chapter_id == CHAPTER_CH08:
            _enter_chapter_eight_camp()
        elif _active_chapter_id == CHAPTER_CH09A:
            _enter_chapter_nine_a_camp()
        elif _active_chapter_id == CHAPTER_CH09B:
            _enter_chapter_nine_b_camp()
        elif _active_chapter_id == CHAPTER_CH10:
            _enter_chapter_ten_resolution()
        else:
            _enter_chapter_complete_state()
        return

    _active_mode = CampaignState.MODE_CUTSCENE
    _set_panel_state(
        CampaignState.MODE_CUTSCENE,
        _current_stage.get_display_title(),
        _build_cutscene_summary(_current_stage, active_flow[_active_stage_index + 1]),
        "다음 스테이지 진행"
    )

func _enter_camp_state() -> void:
    _active_mode = CampaignState.MODE_CAMP
    if _camp_controller != null:
        var stage_result: Dictionary = {}
        if _current_stage != null:
            stage_result = {
                "memory_entries": _variant_to_string_array(CampaignContentRegistry.CH01_STAGE_MEMORY_LOG.get(_current_stage.stage_id, [])),
                "evidence_entries": _variant_to_string_array(CampaignContentRegistry.CH01_STAGE_EVIDENCE_LOG.get(_current_stage.stage_id, [])),
                "letter_entries": _variant_to_string_array(CampaignContentRegistry.CH01_STAGE_LETTER_LOG.get(_current_stage.stage_id, []))
            }
        var progression_data: ProgressionData = null
        if _battle_controller != null and _battle_controller.progression_service != null:
            progression_data = _battle_controller.progression_service.get_data()
        _camp_controller.enter_camp(&"ch01", stage_result, progression_data)
    _autosave_progression("CH01 교대 캠프")
    _set_panel_state(
        CampaignState.MODE_CAMP,
        "CH01 교대 캠프",
        _build_camp_summary(),
        "다음 전투"
    )

func _autosave_progression(reason: String = "") -> void:
    if _save_service == null or _battle_controller == null:
        return
    var prog_svc = _battle_controller.progression_service
    if prog_svc == null:
        return
    var data: ProgressionData = prog_svc.get_data()
    if data != null:
        if _battle_controller.bond_service != null:
            _battle_controller.bond_service.export_to_progression(data)
        var metadata := {}
        if not reason.is_empty():
            metadata["autosave_reason"] = reason
        _save_service.save_progression(data, SaveService.AUTOSAVE_SLOT, metadata)

func _build_cutscene_summary(stage: StageData, next_stage: StageData) -> String:
    var lines: Array[String] = []
    if stage.clear_cutscene_id != StringName():
        lines.append("클리어 컷신: %s" % String(stage.clear_cutscene_id))
    lines.append("스테이지 완료: %s" % stage.get_display_title())
    _append_unique_lines(lines, _variant_to_string_array(CampaignContentRegistry.CH01_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CampaignContentRegistry.CH02_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CampaignContentRegistry.CH03_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CampaignContentRegistry.CH04_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CampaignContentRegistry.CH05_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CampaignContentRegistry.CH06_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CampaignContentRegistry.CH07_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CampaignContentRegistry.CH08_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CampaignContentRegistry.CH09A_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CampaignContentRegistry.CH09B_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    _append_unique_lines(lines, _variant_to_string_array(CampaignContentRegistry.CH10_STAGE_CUTSCENE_NOTES.get(stage.stage_id, [])))
    lines.append("다음 전투: %s" % next_stage.get_display_title())
    if not stage.next_destination_summary.is_empty():
        lines.append(stage.next_destination_summary)
    return "\n".join(lines)

func _build_camp_summary() -> String:
    var lines: Array[String] = [
        "교대 컷신: ch01_interlude_camp",
        "Serin is now locked in as an ally.",
        "세린이 1장 인계 구간의 고정 동료로 확정되었다.",
        "첫 기억 조각을 회수했다: mem_frag_ch01_first_order.",
        "Hardren seal evidence points north.",
        "하드렌 인장 단서가 첫 국경 추적 경로를 북쪽으로 확정한다.",
        "다음 목적지: 첫 캠페인 단서 추적선을 따라 북쪽으로 이동한다."
    ]

    var progression_data: ProgressionData = null
    if _battle_controller != null and _battle_controller.progression_service != null:
        progression_data = _battle_controller.progression_service.get_data()
    if progression_data != null:
        lines.append("부담 / 신뢰: %d / %d" % [progression_data.burden, progression_data.trust])
        lines.append("엔딩 성향: %s" % String(progression_data.ending_tendency))
        lines.append("회수한 기억 조각: %d" % progression_data.recovered_fragments.size())
        lines.append("회수한 기억 조각 ID: %s" % ", ".join(progression_data.get_recovered_fragment_ids()))
        lines.append("해금된 커맨드: %d" % progression_data.unlocked_commands.size())
        lines.append("해금된 커맨드 ID: %s" % ", ".join(progression_data.get_unlocked_command_ids()))

    if _current_stage != null and not _current_stage.next_destination_summary.is_empty():
        lines.append(_current_stage.next_destination_summary)

    return "\n".join(lines)

func _build_ch02_intro_summary() -> String:
    var lines: Array[String] = [
        "챕터 도입: ch02_부서진_국경요새",
        "하드렌은 아직도 연기와 부서진 봉화 아래 버티고 있다.",
        "브란의 잔존 기사단은 외곽 관문 뒤에 갇혀 있다.",
        "장신구와 보물 루프는 이후 2장 확장 과제로 남아 있고, 현재 빌드는 다음 전장만 연다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH02_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch02_camp_summary() -> String:
    var lines: Array[String] = [
        "챕터 교대: ch02_하드렌_캠프",
        "브란은 의심을 거두지 않은 채 현역 전열에 합류한다.",
        "하드렌 설계 기억을 회수했다.",
        "추적 명령은 이제 행군 방향을 그린우드로 가리킨다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH02_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch03_intro_summary() -> String:
    var lines: Array[String] = [
        "챕터 도입: ch03_속삭이는_그린우드",
        "그린우드 숲길은 함정과 연기, 엄폐 속에 움직이는 사람들로 가득하다.",
        "티아의 전열은 부대를 지켜보며 도울지 사냥할지 저울질한다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH03_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch03_camp_summary() -> String:
    var lines: Array[String] = [
        "챕터 교대: ch03_그린우드_캠프",
        "티아는 불안한 휴전 위에서 현역 전열에 합류한다.",
        "숲 화재 명령 기억을 회수했다.",
        "수도원 장부는 다음 경로를 침수 회랑 쪽으로 가리킨다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH03_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch04_intro_summary() -> String:
    var lines: Array[String] = [
        "챕터 도입: ch04_침수_수도원",
        "수도원은 절반이 잠겼고, 앞으로 나아갈 유일한 길은 제어된 수로와 봉인 기록뿐이다.",
        "세린은 이곳을 기도의 장소로 기억하지만, 남은 기계는 실험 장부처럼 읽힌다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH04_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch04_camp_summary() -> String:
    var lines: Array[String] = [
        "챕터 교대: ch04_침수_수도원_캠프",
        "아크 연구 기억을 회수했다.",
        "기록 이송 증거를 확보했다.",
        "다음 경로는 잿빛 기록보관소를 향한다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH04_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch05_intro_summary() -> String:
    var lines: Array[String] = [
        "챕터 도입: ch05_잿빛_기록보관소",
        "잿빛 기록보관소는 이미 불타고 있지만, 남은 장부는 여전히 핵심 진실을 가리킨다.",
        "에녹은 봉인 서고 어딘가에 있고, 추적은 더 기다릴 수 없다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH05_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch05_camp_summary() -> String:
    var lines: Array[String] = [
        "챕터 교대: ch05_잿빛_기록보관소_캠프",
        "에녹이 현역 전열에 합류한다.",
        "기록이 덧칠된 채 남은 제로의 기억을 회수했다.",
        "발토르 공성 장부는 이제 행군 방향을 철성 요새로 이끈다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH05_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch06_intro_summary() -> String:
    var lines: Array[String] = [
        "챕터 도입: ch06_발토르_철성요새",
        "발토르는 여전히 공성의 계산, 죄책감, 살아남은 이름들 위에 선 기계처럼 버티고 있다.",
        "브란의 옛 요새는 이 전쟁이 층층이 설계되었다는 다음 증거가 된다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH06_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch06_camp_summary() -> String:
    var lines: Array[String] = [
        "챕터 교대: ch06_발토르_캠프",
        "발토르 돌파의 맥락이 복원되며, 원래의 경로가 어떻게 사후에 학살용 함정으로 조여졌는지가 드러난다.",
        "엘리오르 구호 칙령과 민간인 이송 명부를 확보하며 부대는 마침내 분명한 다음 목표를 얻는다.",
        "행군은 이제 엘리오르와 그곳의 정화 의식으로 향한다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH06_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch07_intro_summary() -> String:
    var lines: Array[String] = [
        "챕터 도입: ch07_이름_없는_도시",
        "엘리오르는 대기열과 찬가, 잊기를 청하는 지친 시민들을 통해 슬픔을 질서로 바꾸고 있다.",
        "미라와 네리는 그 체계 어딘가에 있고, 다음 숲길은 이미 그 뒤편에서 이어지고 있다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH07_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch07_camp_summary() -> String:
    var lines: Array[String] = [
        "챕터 교대: ch07_엘리오르_캠프",
        "카르온이 제로에게 이름을 준 기억이 복원되며, 엘리오르 교리의 개인적 기원이 드러난다.",
        "흑견 명령서와 숨은 폐허 좌표를 확보하면서 부대는 다음 추적의 시작점을 끝내 짚어낼 수 있게 된다.",
        "경로는 이제 엘리오르를 뒤로하고 레테의 숲 폐허로 향한다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH07_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch08_intro_summary() -> String:
    var lines: Array[String] = [
        "챕터 도입: ch08_흑견의_밤",
        "흑견의 흔적은 다시 숲으로 향하지만, 이제 모든 발걸음은 숨은 폐허와 개인적인 상실로 이어진다.",
        "티아는 이제 복수만을 좇지 않는다. 그녀는 여기서 무슨 일이 있었는지에 대한 마지막 선명한 진실을 쫓고 있다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH08_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch08_camp_summary() -> String:
    var lines: Array[String] = [
        "챕터 교대: ch08_흑견_캠프",
        "북쪽 회랑의 맥락이 복원되며, 원래의 경로가 어떻게 포획과 숙청의 길로 좁혀졌는지가 드러난다.",
        "카일의 외곽선 명령서와 이송 전표를 확보하면서 숲길은 더는 소문 속에서 끝나지 않는다.",
        "추적은 이제 레테의 폐허에서 수도 외곽 카일의 방어선으로 곧장 이어진다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH08_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch09a_intro_summary() -> String:
    var lines: Array[String] = [
        "챕터 도입: ch09a_부서진_군기",
        "수도 외곽선은 이제 증언과 생존자, 그리고 이름을 지닌 채 도시로 들어오려는 이들을 걸러내는 필터가 되었다.",
        "카일은 아직 그 선의 반대편에 서 있지만, 오래가지는 않을 것이다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH09A_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch09a_camp_summary() -> String:
    var lines: Array[String] = [
        "Part I 교대: ch09a_부서진_군기_캠프",
        "돌아오는 이름의 기억이 복원되었고, 카일의 증언은 부대가 조각조각 확인해 온 내용과 맞물리기 시작한다.",
        "카일의 증언과 근원 기록보관소 통행증을 확보하면서, 수도는 더 이상 그들을 완전히 막지 못한다.",
        "다음 경로는 마지막 보관인이 기다리는 근원 기록보관소 안쪽으로 이어진다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH09A_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch09b_intro_summary() -> String:
    var lines: Array[String] = [
        "챕터 도입: ch09b_기록의_심연",
        "근원 기록보관소는 더 이상 군사 전선이 아니다. 그것은 무엇이 역사로 남을 수 있는지를 결정하는 기계다.",
        "노아는 그 경계에서 기다리고 있고, 멜키온은 이미 전장 자체를 고쳐 쓰기 시작했다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH09B_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch09b_camp_summary() -> String:
    var lines: Array[String] = [
        "Part II 교대: ch09b_기록의_심연_캠프",
        "마지막으로 복원된 기억은 리안의 공모와 그가 남겨둔 탈출 경로를 동시에 드러낸다.",
        "식경 좌표와 탑의 격자 정보가 이제 손에 들어왔다.",
        "경로는 이제 최종 탑으로 곧장 상승한다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH09B_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch10_intro_summary() -> String:
    var lines: Array[String] = [
        "챕터 도입: ch10_무명의_탑",
        "최종 탑은 더 이상 진실을 찾는 장소가 아니다. 진실이 드러난 뒤 무엇을 남길지 선택하는 장소다.",
        "식경 좌표, 탑 격자, 마지막 칙령이 모두 하나의 최종 상승로로 합쳐진다."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH10_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch10_resolution_summary(ending_type: StringName) -> String:
    var lines: Array[String] = [
        "최종 결말: ch10_마지막_이름",
        "카르온이 쓰러지고 종이 멈춘 뒤, 이야기는 지워진 기억이 아니라 함께 남긴 기억을 중심으로 마무리된다.",
        "무엇이 남을지를 이제 탑이 아니라 생존자들이 결정한다."
    ]
    if ending_type == EndingResolver.ENDING_TRUE:
        lines.append("진엔딩 도달: 모든 인연이 끝까지 버텨 마지막 기억을 함께 붙들어 두었고, 누구도 결말 밖으로 밀려나지 않았다.")
        lines.append("마지막 기억은 봉인이 아니라 인계가 되었고, 생존자들은 같은 이름 아래서 다음 시대를 시작한다.")
    else:
        lines.append("일반 엔딩 도달: 종은 멈췄지만 마지막 공명은 리안이 홀로 받아냈고, 그는 동료들의 얼굴과 이름부터 먼저 잊기 시작한다.")
        lines.append("생존자들은 리안의 희생으로 남겨진 빈자리를 끌어안은 채, 그가 잃어 가는 이름들을 대신 증언하며 미래를 이어 간다.")
    if _battle_controller != null and _battle_controller.progression_service != null:
        var criteria_data: ProgressionData = _battle_controller.progression_service.get_data()
        if criteria_data != null:
            _append_unique_lines(lines, EndingResolver.get_criteria_summary_lines(criteria_data))
    _append_unique_lines(lines, _get_ch10_resolution_dialogue(ending_type))
    return "\n".join(lines)

func _get_ch10_resolution_dialogue(ending_type: StringName) -> Array[String]:
    if ending_type == EndingResolver.ENDING_TRUE:
        return CampaignContentRegistry.CH10_TRUE_RESOLUTION_DIALOGUE.duplicate()
    return CampaignContentRegistry.CH10_RESOLUTION_DIALOGUE.duplicate()

func _set_panel_state(mode: String, title_text: String, body_text: String, button_text: String) -> void:
    _current_panel_title = title_text
    _current_panel_body = body_text
    mode_changed.emit(mode)
    if _campaign_panel != null:
        _campaign_panel.show_state(mode, title_text, body_text, button_text, _build_panel_payload(mode))
    if _battle_controller != null:
        _battle_controller.visible = mode == CampaignState.MODE_BATTLE

func _clear_panel_state() -> void:
    _current_panel_title = ""
    _current_panel_body = ""
    if _campaign_panel != null:
        _campaign_panel.hide_panel()

func _on_advance_requested() -> void:
    if _active_mode == CampaignState.MODE_COMPLETE and _active_chapter_id == CHAPTER_CH10:
        _return_to_title()
        return
    advance_step()

func _enter_chapter_two_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH02 부서진 국경요새",
        _build_ch02_intro_summary(),
        "국경 연무지 진입"
    )

func _start_chapter_two_flow() -> void:
    _active_chapter_id = CHAPTER_CH02
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_three_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH03 속삭이는 그린우드",
        _build_ch03_intro_summary(),
        "잃어버린 숲 진입"
    )

func _start_chapter_three_flow() -> void:
    _active_chapter_id = CHAPTER_CH03
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_four_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH04 침수 수도원",
        _build_ch04_intro_summary(),
        "침수 회랑 진입"
    )

func _start_chapter_four_flow() -> void:
    _active_chapter_id = CHAPTER_CH04
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_five_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH05 잿빛 기록보관소",
        _build_ch05_intro_summary(),
        "재의 관문 진입"
    )

func _start_chapter_five_flow() -> void:
    _active_chapter_id = CHAPTER_CH05
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_six_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH06 발토르 철성요새",
        _build_ch06_intro_summary(),
        "연무 너머 진입"
    )

func _start_chapter_six_flow() -> void:
    _active_chapter_id = CHAPTER_CH06
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_seven_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH07 이름 없는 도시",
        _build_ch07_intro_summary(),
        "공백 시장 진입"
    )

func _start_chapter_seven_flow() -> void:
    _active_chapter_id = CHAPTER_CH07
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_eight_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH08 흑견의 밤",
        _build_ch08_intro_summary(),
        "사라진 숲길 진입"
    )

func _start_chapter_eight_flow() -> void:
    _active_chapter_id = CHAPTER_CH08
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_nine_a_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH09A 부서진 군기",
        _build_ch09a_intro_summary(),
        "외곽 방어선 진입"
    )

func _start_chapter_nine_a_flow() -> void:
    _active_chapter_id = CHAPTER_CH09A
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_nine_b_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH09B 기록의 심연",
        _build_ch09b_intro_summary(),
        "근원 관문 진입"
    )

func _start_chapter_nine_b_flow() -> void:
    _active_chapter_id = CHAPTER_CH09B
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_ten_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH10 무명의 탑",
        _build_ch10_intro_summary(),
        "식경 전야 진입"
    )

func _start_chapter_ten_flow() -> void:
    _active_chapter_id = CHAPTER_CH10
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_two_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression("CH02 하드렌 교대")
    _set_panel_state(CampaignState.MODE_CAMP, "CH02 하드렌 교대", _build_ch02_camp_summary(), "다음 전투")

func _enter_chapter_three_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression("CH03 그린우드 교대")
    _set_panel_state(CampaignState.MODE_CAMP, "CH03 그린우드 교대", _build_ch03_camp_summary(), "다음 전투")

func _enter_chapter_four_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression("CH04 수도원 교대")
    _set_panel_state(CampaignState.MODE_CAMP, "CH04 수도원 교대", _build_ch04_camp_summary(), "다음 전투")

func _enter_chapter_five_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression("CH05 기록보관소 교대")
    _set_panel_state(CampaignState.MODE_CAMP, "CH05 기록보관소 교대", _build_ch05_camp_summary(), "다음 전투")

func _enter_chapter_six_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression("CH06 발토르 교대")
    _set_panel_state(CampaignState.MODE_CAMP, "CH06 발토르 교대", _build_ch06_camp_summary(), "다음 전투")

func _enter_chapter_seven_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression("CH07 엘리오르 교대")
    _set_panel_state(CampaignState.MODE_CAMP, "CH07 엘리오르 교대", _build_ch07_camp_summary(), "다음 전투")

func _enter_chapter_eight_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression("CH08 흑견 교대")
    _set_panel_state(CampaignState.MODE_CAMP, "CH08 흑견 교대", _build_ch08_camp_summary(), "다음 전투")

func _enter_chapter_nine_a_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression("CH09A 부서진 군기 교대")
    _set_panel_state(CampaignState.MODE_CAMP, "CH09A 부서진 군기 교대", _build_ch09a_camp_summary(), "다음 전투")

func _enter_chapter_nine_b_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression("CH09B 기록의 심연 교대")
    _set_panel_state(CampaignState.MODE_CAMP, "CH09B 기록의 심연 교대", _build_ch09b_camp_summary(), "다음 전투")

func _enter_chapter_ten_resolution() -> void:
    var ending_type: StringName = _resolve_current_ending()
    _mark_postgame_available(ending_type)
    _active_mode = CampaignState.MODE_COMPLETE
    _set_panel_state(
        CampaignState.MODE_COMPLETE,
        "CH10 최종 결말",
        _build_ch10_resolution_summary(ending_type),
        "타이틀로 복귀"
    )

func _return_to_title() -> void:
    return_to_title_requested.emit(_resolve_current_ending() == EndingResolver.ENDING_TRUE)

func _resolve_current_ending() -> StringName:
    if _battle_controller == null or _battle_controller.progression_service == null:
        return EndingResolver.ENDING_NORMAL
    return EndingResolver.resolve_ending(_battle_controller.progression_service.get_data())

func _mark_postgame_available(ending_type: StringName) -> void:
    if _battle_controller == null or _battle_controller.progression_service == null:
        return
    var progression_data: ProgressionData = _battle_controller.progression_service.get_data()
    if progression_data == null:
        return
    if _battle_controller.bond_service != null:
        _battle_controller.bond_service.export_to_progression(progression_data)
    progression_data.ng_plus_available = true
    progression_data.last_completed_ending = ending_type
    progression_data.ng_plus_run = false
    _autosave_progression("CH10 최종 결말")

func _enter_chapter_complete_state() -> void:
    _active_mode = CampaignState.MODE_COMPLETE
    var title_text: String = "챕터 진행 완료"
    var body_text: String = "현재 챕터 쉘이 완료되었고 다음 목적지로 진행할 준비가 되었다."
    if _active_chapter_id == CHAPTER_CH02:
        title_text = "2장 쉘 완료"
        body_text = "하드렌 쉘이 완료되었고 그린우드로 갈 준비가 되었다."
    elif _active_chapter_id == CHAPTER_CH03:
        title_text = "3장 쉘 완료"
        body_text = "그린우드 쉘이 완료되었고 침수 수도원으로 갈 준비가 되었다."
    elif _active_chapter_id == CHAPTER_CH04:
        title_text = "4장 쉘 완료"
        body_text = "침수 수도원 쉘이 완료되었고 잿빛 기록보관소로 갈 준비가 되었다."
    elif _active_chapter_id == CHAPTER_CH05:
        title_text = "5장 쉘 완료"
        body_text = "잿빛 기록보관소 쉘이 완료되었고 발토르로 갈 준비가 되었다."
    elif _active_chapter_id == CHAPTER_CH06:
        title_text = "6장 쉘 완료"
        body_text = "발토르 쉘이 완료되었고 엘리오르로 갈 준비가 되었다."
    elif _active_chapter_id == CHAPTER_CH07:
        title_text = "7장 쉘 완료"
        body_text = "엘리오르 쉘이 완료되었고 흑견 추적으로 갈 준비가 되었다."
    elif _active_chapter_id == CHAPTER_CH08:
        title_text = "8장 쉘 완료"
        body_text = "흑견 쉘이 완료되었고 카일의 외곽선으로 갈 준비가 되었다."
    elif _active_chapter_id == CHAPTER_CH09A:
        title_text = "9A 쉘 완료"
        body_text = "외곽선 쉘이 완료되었고 근원 기록보관소로 갈 준비가 되었다."
    elif _active_chapter_id == CHAPTER_CH09B:
        title_text = "9B 쉘 완료"
        body_text = "근원 기록보관소 쉘이 완료되었고 최종 탑으로 갈 준비가 되었다."
    elif _active_chapter_id == CHAPTER_CH10:
        title_text = "10장 쉘 완료"
        body_text = "최종 탑 쉘이 완료되었고 캠페인이 결말에 도달했다."
    _set_panel_state(CampaignState.MODE_COMPLETE, title_text, body_text, "완료")

func _get_active_stage_flow() -> Array[StageData]:
    return CampaignChapterRegistry.get_stage_flow(_active_chapter_id)

func _build_panel_payload(mode: String) -> Dictionary:
    var party_entries: Array[String] = []
    var party_details: Array[Dictionary] = []
    var inventory_entries: Array[String] = []
    var memory_entries: Array[String] = []
    var evidence_entries: Array[String] = []
    var letter_entries: Array[String] = []
    var dialogue_entries: Array[String] = []
    var presentation_cards: Array[Dictionary] = []
    var camp_progression_alerts: Array[String] = []
    var camp_reward_entries: Array[String] = []
    var recall_hunt_entries: Array[Dictionary] = []
    var selected_hunt_id: StringName = &""
    var last_hunt_result: Dictionary = {}
    if _battle_controller != null:
        party_entries = _battle_controller.get_party_summary_lines()
        party_details = _battle_controller.get_party_detail_entries()
        inventory_entries = _battle_controller.get_inventory_entries()
    if mode != CampaignState.MODE_BATTLE:
        party_entries = _build_campaign_party_summary_lines()
        party_details = _build_campaign_party_detail_entries()
    inventory_entries = _merge_unique_lines(_chapter_reward_entries, inventory_entries)
    inventory_entries = _merge_unique_lines(inventory_entries, _build_weapon_inventory_lines())
    inventory_entries = _merge_unique_lines(inventory_entries, _build_armor_inventory_lines())
    inventory_entries = _merge_unique_lines(inventory_entries, _build_accessory_inventory_lines())
    memory_entries = _unlocked_memory_entries.duplicate()
    evidence_entries = _unlocked_evidence_entries.duplicate()
    letter_entries = _unlocked_letter_entries.duplicate()
    if mode == CampaignState.MODE_BRIEFING and _current_stage != null:
        var briefing_payload := _build_briefing_payload(_get_briefing_data(_current_stage.stage_id))
        dialogue_entries = []
        presentation_cards = []
        memory_entries = []
        evidence_entries = []
        letter_entries = []
        var alerts: Array[String] = ["보스 스테이지 진입 직전", "출격 준비 완료"]
        var recommendation: String = "출격 전에 확인된 적 유형, 지형, 선택 목표를 점검한다."
        var active_section: String = CampaignPanel.SECTION_SUMMARY
        var selected_party_unit_id: String = ""
        var selected_forge_recipe_id: String = ""
        if _campaign_panel != null:
            var briefing_snapshot: Dictionary = _campaign_panel.get_snapshot()
            if String(briefing_snapshot.get("mode", "")) == mode:
                active_section = String(briefing_snapshot.get("active_section", active_section))
                selected_party_unit_id = String(briefing_snapshot.get("selected_party_unit_id", ""))
                selected_forge_recipe_id = String(briefing_snapshot.get("selected_forge_recipe_id", ""))
        return {
            "flow_label": _build_panel_flow_label(mode),
            "recommendation": recommendation,
            "party_entries": party_entries,
            "party_details": party_details,
            "inventory_entries": inventory_entries,
            "memory_entries": memory_entries,
            "evidence_entries": evidence_entries,
            "letter_entries": letter_entries,
            "alerts": alerts,
            "dialogue_entries": dialogue_entries,
            "presentation_cards": presentation_cards,
            "active_section": active_section,
            "selected_party_unit_id": selected_party_unit_id,
            "selected_forge_recipe_id": selected_forge_recipe_id,
            "gold_amount": _get_gold_amount(),
            "section_badges": {},
            "deployment_limit": _get_deployment_limit(),
            "deployed_party_unit_ids": _stringify_unit_ids(_deployed_party_unit_ids),
            "locked_party_unit_ids": ["ally_rian"],
            "available_weapon_entries": _build_weapon_inventory_lines(),
            "available_armor_entries": _build_armor_inventory_lines(),
            "available_accessory_entries": _build_accessory_inventory_lines(),
            "inventory_weapon_sell_options": _build_inventory_sell_options("weapon"),
            "inventory_armor_sell_options": _build_inventory_sell_options("armor"),
            "inventory_accessory_sell_options": _build_inventory_sell_options("accessory"),
            "inventory_weapon_sell_option": _build_inventory_sell_option("weapon"),
            "inventory_armor_sell_option": _build_inventory_sell_option("armor"),
            "inventory_accessory_sell_option": _build_inventory_sell_option("accessory"),
            "material_entries": _build_material_entries(),
            "forge_recipe_entries": _build_forge_recipe_entries(),
            "enemy_intel": briefing_payload.get("enemy_intel", []),
            "terrain_summary": briefing_payload.get("terrain_summary", []),
            "optional_objectives": briefing_payload.get("optional_objectives", []),
            "turn_limit": briefing_payload.get("turn_limit", 20)
        }
    if mode == CampaignState.MODE_CAMP:
        if _briefing_abort_active:
            dialogue_entries = []
            presentation_cards = []
            memory_entries = []
            evidence_entries = []
            letter_entries = []
        else:
            if _active_chapter_id == CHAPTER_CH01:
                dialogue_entries = CampaignContentRegistry.CH01_INTERLUDE_DIALOGUE.duplicate()
            elif _active_chapter_id == CHAPTER_CH02:
                dialogue_entries = CampaignContentRegistry.CH02_INTERLUDE_DIALOGUE.duplicate()
            elif _active_chapter_id == CHAPTER_CH03:
                dialogue_entries = CampaignContentRegistry.CH03_INTERLUDE_DIALOGUE.duplicate()
            elif _active_chapter_id == CHAPTER_CH04:
                dialogue_entries = CampaignContentRegistry.CH04_INTERLUDE_DIALOGUE.duplicate()
            elif _active_chapter_id == CHAPTER_CH05:
                dialogue_entries = CampaignContentRegistry.CH05_INTERLUDE_DIALOGUE.duplicate()
            elif _active_chapter_id == CHAPTER_CH06:
                dialogue_entries = CampaignContentRegistry.CH06_INTERLUDE_DIALOGUE.duplicate()
            elif _active_chapter_id == CHAPTER_CH07:
                dialogue_entries = CampaignContentRegistry.CH07_INTERLUDE_DIALOGUE.duplicate()
            elif _active_chapter_id == CHAPTER_CH08:
                dialogue_entries = CampaignContentRegistry.CH08_INTERLUDE_DIALOGUE.duplicate()
            elif _active_chapter_id == CHAPTER_CH09A:
                dialogue_entries = CampaignContentRegistry.CH09A_INTERLUDE_DIALOGUE.duplicate()
            elif _active_chapter_id == CHAPTER_CH09B:
                dialogue_entries = CampaignContentRegistry.CH09B_INTERLUDE_DIALOGUE.duplicate()
            else:
                dialogue_entries = _get_ch10_resolution_dialogue(_resolve_current_ending())
            dialogue_entries = _merge_unique_lines(dialogue_entries, _recent_support_dialogue_entries)
            presentation_cards = _merge_presentation_cards(_build_camp_presentation_cards(), _build_passive_translation_presentation_cards())
            presentation_cards = _merge_presentation_cards(presentation_cards, _recent_support_presentation_cards)
            if _camp_controller != null:
                var camp_summary := _camp_controller.get_camp_summary()
                if not camp_summary.is_empty():
                    camp_progression_alerts = _merge_unique_lines(camp_progression_alerts, [
                        "부담 %d / 신뢰 %d" % [int(camp_summary.get("burden", 0)), int(camp_summary.get("trust", 0))],
                        "기억 조각 %d / 커맨드 %d" % [int(camp_summary.get("recovered_fragments", 0)), int(camp_summary.get("unlocked_commands", 0))]
                    ])
                    camp_reward_entries = _variant_to_string_array(camp_summary.get("reward_entries", []))
                    recall_hunt_entries = _variant_to_dictionary_array(camp_summary.get("recall_hunt_entries", []))
                    selected_hunt_id = StringName(camp_summary.get("selected_hunt_id", &""))
                    last_hunt_result = Dictionary(camp_summary.get("last_hunt_result", {}))
                    inventory_entries = _merge_unique_lines(inventory_entries, camp_reward_entries)
                    presentation_cards = _merge_presentation_cards(presentation_cards, _build_recall_presentation_cards(recall_hunt_entries, selected_hunt_id, last_hunt_result))
                    presentation_cards = _merge_presentation_cards(presentation_cards, _build_hunt_return_presentation_cards(last_hunt_result))
    elif mode == CampaignState.MODE_COMPLETE and _active_chapter_id == CHAPTER_CH10:
        dialogue_entries = _get_ch10_resolution_dialogue(_resolve_current_ending())
        presentation_cards = _build_resolution_presentation_cards()

    var alerts: Array[String] = []
    var recommendation: String = "현재 상태를 검토한 뒤 준비가 되면 계속 진행한다."
    var active_section: String = CampaignPanel.SECTION_SUMMARY
    var selected_party_unit_id: String = ""
    var selected_forge_recipe_id: String = ""
    var section_badges: Dictionary = {}

    match mode:
        CampaignState.MODE_CUTSCENE:
            alerts = ["전투 완료", "다음 스테이지 해금"]
            recommendation = "인계 내용을 읽고 부대 상태를 점검한 뒤 다음 스테이지로 진행한다."
        CampaignState.MODE_CAMP:
            if _briefing_abort_active:
                alerts = ["출격 취소", "야전 캠프 대기 중"]
                recommendation = "필요하면 부대와 장비를 조정한 뒤 작전 브리핑으로 돌아간다."
                active_section = CampaignPanel.SECTION_PARTY
            else:
                alerts = _build_camp_alerts(memory_entries, evidence_entries, letter_entries, inventory_entries)
                alerts = _merge_unique_lines(alerts, camp_reward_entries)
                alerts = _merge_unique_lines(alerts, camp_progression_alerts)
                recommendation = _build_camp_recommendation(memory_entries, evidence_entries, letter_entries, inventory_entries, recall_hunt_entries, selected_hunt_id, last_hunt_result)
                active_section = CampaignPanel.SECTION_DIALOGUE_HISTORY
                section_badges = _build_camp_section_badges(party_entries, inventory_entries, dialogue_entries, memory_entries, evidence_entries, letter_entries)
        CampaignState.MODE_COMPLETE:
            alerts = ["챕터 인계 완료"]
            recommendation = "1장 쉘이 완료되었고 다음 목적지로 갈 준비가 되었다."
        _:
            alerts = ["전투 상태 진행 중"]
            recommendation = "전투 목표를 완료해 다음 캠프 또는 스토리 단계를 해금한다."

    if _campaign_panel != null:
        var panel_snapshot: Dictionary = _campaign_panel.get_snapshot()
        if String(panel_snapshot.get("mode", "")) == mode:
            active_section = String(panel_snapshot.get("active_section", active_section))
            selected_party_unit_id = String(panel_snapshot.get("selected_party_unit_id", ""))
            selected_forge_recipe_id = String(panel_snapshot.get("selected_forge_recipe_id", ""))

    return {
        "flow_label": _build_panel_flow_label(mode),
        "recommendation": recommendation,
        "party_entries": party_entries,
        "party_details": party_details,
        "inventory_entries": inventory_entries,
        "memory_entries": memory_entries,
        "evidence_entries": evidence_entries,
        "letter_entries": letter_entries,
        "alerts": alerts,
        "dialogue_entries": dialogue_entries,
        "presentation_cards": presentation_cards,
        "active_section": active_section,
        "selected_party_unit_id": selected_party_unit_id,
        "selected_forge_recipe_id": selected_forge_recipe_id,
        "gold_amount": _get_gold_amount(),
        "section_badges": section_badges,
        "deployment_limit": _get_deployment_limit(),
        "deployed_party_unit_ids": _stringify_unit_ids(_deployed_party_unit_ids),
        "locked_party_unit_ids": ["ally_rian"],
        "available_weapon_entries": _build_weapon_inventory_lines(),
        "available_armor_entries": _build_armor_inventory_lines(),
        "available_accessory_entries": _build_accessory_inventory_lines(),
        "inventory_weapon_sell_options": _build_inventory_sell_options("weapon"),
        "inventory_armor_sell_options": _build_inventory_sell_options("armor"),
        "inventory_accessory_sell_options": _build_inventory_sell_options("accessory"),
        "inventory_weapon_sell_option": _build_inventory_sell_option("weapon"),
        "inventory_armor_sell_option": _build_inventory_sell_option("armor"),
        "inventory_accessory_sell_option": _build_inventory_sell_option("accessory"),
        "material_entries": _build_material_entries(),
        "forge_recipe_entries": _build_forge_recipe_entries()
    }

func _build_panel_flow_label(mode: String) -> String:
    match mode:
        CampaignState.MODE_BATTLE:
            return "전투 진행 중 -> 목표 미완료 -> 캠프"
        CampaignState.MODE_CUTSCENE:
            return "전투 완료 -> 스토리 인계 -> 다음 스테이지"
        CampaignState.MODE_CAMP:
            if _briefing_abort_active:
                return "작전 브리핑 -> 야전 캠프 -> 브리핑 복귀"
            return "전투 완료 -> Camp review -> Next battle"
        CampaignState.MODE_BRIEFING:
            return "Mission briefing -> 출격"
        CampaignState.MODE_CHAPTER_INTRO:
            return "Camp exit -> Mission brief -> 출격"
        CampaignState.MODE_COMPLETE:
            return "챕터 완료 -> 다음 목적지 대기"
        _:
            return "반복 상태 진행 중"

func _build_camp_presentation_cards() -> Array[Dictionary]:
    var cards: Array[Dictionary] = []

    if _active_chapter_id == CHAPTER_CH01:
        cards.append({
            "eyebrow": "동료",
            "title": "세린, 전열에 서다",
            "body": "세린은 더 이상 임시 호위자가 아니다. 캠프 인계는 이제 그녀를 다음 경로와 직결된 정식 동료로 다룬다."
        })
        cards.append({
            "eyebrow": "기억",
            "title": "첫 명령이 떠오르다",
            "body": "처음 복구된 지휘 파편은 리안의 전장 감각이 단순한 본능이 아니라 실제 명령 체계와 연결되어 있음을 보여 준다."
        })
        cards.append({
            "eyebrow": "증거",
            "title": "하드렌 인장이 북쪽을 가리키다",
            "body": "회수된 인장과 경로 증거가 이제 국경 추적의 기반이 된다. 다음 인계는 추측이 아니라 증거가 이끈다."
        })
        cards.append(_build_field_sword_support_card())
        cards.append(_build_paladin_shield_support_card())
        cards = _merge_presentation_cards(cards, _build_narrative_axis_presentation_cards())
        return cards

    if _active_chapter_id == CHAPTER_CH02:
        cards.append({
            "eyebrow": "동료",
            "title": "브란, 전선을 붙들다",
            "body": "브란의 불신은 남아 있지만, 요새 인계는 그를 현역 전열에 묶어 두고 부대를 더 거친 군사 리듬으로 밀어 넣는다."
        })
        cards.append({
            "eyebrow": "기억",
            "title": "하드렌 경로가 낯설지 않다",
            "body": "리안은 이방인치고는 요새 경로를 너무 빨리 읽어 낸다. 캠페인은 이제 그 지식을 명확한 경고 신호로 다룬다."
        })
        cards.append(_build_paladin_shield_support_card())
        cards = _merge_presentation_cards(cards, _build_narrative_axis_presentation_cards())
        return cards

    if _active_chapter_id == CHAPTER_CH03:
        cards.append({
            "eyebrow": "동료",
            "title": "티아, 부대를 시험하다",
            "body": "그린우드 인계는 티아를 경계 어린 숲의 접촉자에서, 앞길에 대한 자신의 판단을 지닌 정식 동료로 바꾼다."
        })
        cards.append({
            "eyebrow": "증거",
            "title": "불은 계획된 것이었다",
            "body": "분지 경로는 더 이상 단순한 야생 이동로가 아니다. 이번 인계는 산불 잔재를 계획된 명령의 증거로 드러낸다."
        })
        cards.append(_build_paladin_shield_support_card())
        cards = _merge_presentation_cards(cards, _build_narrative_axis_presentation_cards())
        return cards

    if _active_chapter_id == CHAPTER_CH04:
        cards.append({
            "eyebrow": "기억",
            "title": "아크의 연구가 다시 떠오르다",
            "body": "수도원 인계는 회수한 연구를 명시적인 전환 카드로 바꿔, 실험의 흔적이 배경 설명이 아니라 증거로 느껴지게 만든다."
        })
        cards.append({
            "eyebrow": "증거",
            "title": "잿빛 기록보관소 경로 확정",
            "body": "Transfer ledgers and seals now point cleanly toward the Gray 기록보관소, so the next chapter handoff reads like a deliberate chase of records."
        })
        cards.append(_build_paladin_shield_support_card())
        cards = _merge_presentation_cards(cards, _build_narrative_axis_presentation_cards())
        return cards

    if _active_chapter_id == CHAPTER_CH05:
        cards.append({
            "eyebrow": "동료",
            "title": "에녹이 제로의 이름을 말하다",
            "body": "기록보관소 인계는 이제 에녹의 등장과 제로의 첫 명시를 단순 요약이 아니라 실제 런타임 반전으로 다룬다."
        })
        cards.append({
            "eyebrow": "증거",
            "title": "발토르 장부가 다음 길을 가리키다",
            "body": "공성 장부와 생존 기사 명단은 행군을 철성 요새로 곧장 이끄는 구체적인 인계 카드로 드러난다."
        })
        cards.append(_build_paladin_shield_support_card())
        cards = _merge_presentation_cards(cards, _build_narrative_axis_presentation_cards())
        return cards

    if _active_chapter_id == CHAPTER_CH06:
        cards.append({
            "eyebrow": "기억",
            "title": "발토르 돌파가 복원되다",
            "body": "요새 돌파의 기억은 이제 의도된 인계 카드로 제시되어, 다음 챕터가 단순 요약이 아니라 군사적 격상으로 읽히게 한다."
        })
        cards.append({
            "eyebrow": "증거",
            "title": "엘리오르 구호 경로 개방",
            "body": "구호 칙령과 민간인 이송 기록은 이제 엘리오르를 분명하게 가리키며, 캠프에서 도시 전환을 명시적으로 보여 준다."
        })
        cards.append(_build_paladin_shield_support_card())
        cards = _merge_presentation_cards(cards, _build_narrative_axis_presentation_cards())
        return cards

    if _active_chapter_id == CHAPTER_CH07:
        cards.append({
            "eyebrow": "증거",
            "title": "흑견 명령서가 떠오르다",
            "body": "무명의 도시 인계는 회수한 흑견 명령서를 더 이상 요약문 속에 묻지 않고, 챕터의 핵심 증거물로 전면에 세운다."
        })
        cards.append({
            "eyebrow": "경로",
            "title": "숲길이 다시 꺾이다",
            "body": "수도 경로는 이제 숲 폐허 쪽으로 다시 꺾이는 것이 분명해져, 다음 추적이 막연한 연장이 아니라 급격한 전술 전환으로 읽힌다."
        })
        cards.append(_build_paladin_shield_support_card())
        cards = _merge_presentation_cards(cards, _build_narrative_axis_presentation_cards())
        return cards

    if _active_chapter_id == CHAPTER_CH08:
        cards.append({
            "eyebrow": "방어선",
            "title": "카일의 외곽선이 특정되다",
            "body": "흑견 추적은 이제 전용 프레젠테이션 카드를 통해 카일의 외곽선으로 인계되어, 전략 축의 전환을 한눈에 보여 준다."
        })
        cards.append({
            "eyebrow": "추적",
            "title": "레테의 경로 확정",
            "body": "숲과 폐허의 증거는 이제 이름 붙은 추적 경로로 정리되어, 챕터의 끝을 다음 방어 전선과 매끄럽게 이어 준다."
        })
        cards.append(_build_paladin_shield_support_card())
        cards = _merge_presentation_cards(cards, _build_narrative_axis_presentation_cards())
        return cards

    if _active_chapter_id == CHAPTER_CH09A:
        cards.append({
            "eyebrow": "동료",
            "title": "카일이 근원 경로를 열다",
            "body": "카일의 증언과 부서진 군기 인계는 이제 전용 전환 카드로 제시되어, 그의 합류가 캠페인 구조 자체를 바꾸는 사건처럼 느껴진다."
        })
        cards.append({
            "eyebrow": "기록보관소",
            "title": "버려진 장교들의 이름이 드러나다",
            "body": "근원 기록보관소로 향하는 길은 이제 버려진 장교 기록의 무게를 명시적인 인계 오브젝트로 함께 지닌다."
        })
        cards.append(_build_paladin_shield_support_card())
        cards = _merge_presentation_cards(cards, _build_narrative_axis_presentation_cards())
        return cards

    if _active_chapter_id == CHAPTER_CH09B:
        cards.append({
            "eyebrow": "동료",
            "title": "노아가 기록보관소 경로를 바로잡다",
            "body": "심연 인계는 이제 노아의 존재와 마지막 기록 경로 정렬을 단순 요약이 아니라 실질적인 도착으로 느끼게 만든다."
        })
        cards.append({
            "eyebrow": "목적지",
            "title": "최종 탑이 확정되다",
            "body": "식경 좌표와 탑 격자는 이제 CH10으로 이어지는 최종 전환 오브젝트로 제시되어, 인계 흐름을 단단히 조인다."
        })
        cards.append(_build_paladin_shield_support_card())
        cards = _merge_presentation_cards(cards, _build_narrative_axis_presentation_cards())
        return cards

    return cards

func _build_paladin_shield_support_card() -> Dictionary:
    return {
        "eyebrow": "장비",
        "title": "방패 실루엣 기준",
        "body": "현재 캠프 인계는 기사와 중장갑 전열의 장비 언어를 이 방패 기준으로 정리한다. 두꺼운 외곽, 단일 문장, 절제된 남청 포인트가 핵심이다.",
        "image_path": PALADIN_SHIELD_SUPPORT_IMAGE
    }

func _build_field_sword_support_card() -> Dictionary:
    return {
        "eyebrow": "장비",
        "title": FIELD_SWORD_SUPPORT_TITLE,
        "body": FIELD_SWORD_SUPPORT_BODY,
        "image_path": FIELD_SWORD_SUPPORT_IMAGE
    }

func _build_narrative_axis_presentation_cards() -> Array[Dictionary]:
    var cards: Array[Dictionary] = []
    if _battle_controller == null or _battle_controller.progression_service == null:
        return cards
    var progression_data: ProgressionData = _battle_controller.progression_service.get_data()
    if progression_data == null:
        return cards
    var axis_specs: Array[Dictionary] = [
        {"axis_id": "memory", "label": "기억"},
        {"axis_id": "sacrifice", "label": "희생"},
        {"axis_id": "truth", "label": "진실"},
        {"axis_id": "trust", "label": "신뢰"},
    ]
    for spec in axis_specs:
        var axis_id: String = String(spec.get("axis_id", ""))
        var label: String = String(spec.get("label", axis_id))
        var value: int = _resolve_narrative_axis_value(progression_data, axis_id)
        cards.append({
            "eyebrow": "서사 축",
            "title": "%s 축 / %s" % [label, _get_narrative_axis_band(value)],
            "body": "%s 흐름이 현재 %s 구간에 있다. 캠프에서는 절대값보다 방향과 체감 강도로 읽는다." % [label, _get_narrative_axis_band(value)],
            "callout": "%s %d/9" % [label, value]
        })
    return cards

func _build_passive_translation_presentation_cards() -> Array[Dictionary]:
    var cards: Array[Dictionary] = []
    if _battle_controller == null or _battle_controller.progression_service == null:
        return cards
    for definition_variant in _battle_controller.progression_service.get_unlocked_passive_card_definitions():
        var definition: Dictionary = Dictionary(definition_variant)
        if definition.is_empty():
            continue
        cards.append({
            "eyebrow": String(definition.get("eyebrow", "전투 번역 카드")),
            "title": String(definition.get("title", "Passive Card")),
            "body": String(definition.get("body", "")),
            "callout": String(definition.get("callout", "")),
            "source_label": String(definition.get("source_label", "")),
            "outcome_line": "해금된 전투 번역 카드가 다음 전투 규칙에 바로 반영된다.",
            "badges": [
                {"label": "효과", "value": String(definition.get("effect_summary", ""))}
            ],
            "progress_rows": [
                {"label": "해금 상태", "value": "활성", "complete": true},
                {"label": "출처", "value": String(definition.get("source_id", "")), "complete": true}
            ]
        })
    return cards

func _resolve_narrative_axis_value(progression_data: ProgressionData, axis_id: String) -> int:
    if progression_data == null:
        return 0
    if progression_data.narrative_axis_values.has(axis_id):
        return clampi(int(progression_data.narrative_axis_values.get(axis_id, 0)), 0, 9)
    match axis_id:
        "memory":
            return clampi(progression_data.recovered_fragments.size(), 0, 9)
        "sacrifice":
            return clampi(progression_data.burden, 0, 9)
        "truth":
            return clampi(progression_data.recovered_fragments.size(), 0, 9)
        "trust":
            return clampi(progression_data.trust, 0, 9)
        _:
            return 0

func _get_narrative_axis_band(value: int) -> String:
    if value >= 8:
        return "peak"
    if value >= 6:
        return "strong"
    if value >= 3:
        return "rising"
    return "faint"

func _build_resolution_presentation_cards() -> Array[Dictionary]:
    var cards: Array[Dictionary] = []
    if _active_chapter_id == CHAPTER_CH10:
        var ending_type: StringName = _resolve_current_ending()
        var criteria_body: String = ""
        var criteria_badges: Array[Dictionary] = []
        var criteria_progress_rows: Array[Dictionary] = []
        if _battle_controller != null and _battle_controller.progression_service != null:
            var criteria_data: ProgressionData = _battle_controller.progression_service.get_data()
            if criteria_data != null:
                var criteria_status: Dictionary = EndingResolver.get_ending_conditions_status(criteria_data)
                criteria_body = _build_ending_criteria_body(criteria_status)
                criteria_badges = _build_ending_criteria_badges(criteria_status)
                criteria_progress_rows = _build_ending_criteria_progress_rows(criteria_status)
        if ending_type == EndingResolver.ENDING_TRUE:
            cards.append({
                "eyebrow": "진엔딩",
                "title": "종이 멈추고 모두의 이름이 남다",
                "body": "카르온이 쓰러진 뒤 탑은 침묵하고, 마지막 기억은 특정 개인의 구원이 아니라 함께 살아남은 이름들의 인계로 남는다."
            })
            cards.append({
                "eyebrow": "인계",
                "title": "마지막 기억이 다음 시대를 연다",
                "body": "진엔딩에서는 봉인된 기억이 더 이상 사람을 죄로 묶지 않는다. 부대가 끝까지 붙든 인연이 다음 질서의 기준으로 넘어간다."
            })
            cards.append({
                "eyebrow": "후일담",
                "title": "무너진 탑 밖에서 다시 시작하다",
                "body": "리안과 동료들은 탑 바깥으로 돌아와 각자의 이름으로 살아남고, 그 이름들이 다시 공동의 미래를 세우는 기초가 된다."
            })
        else:
            cards.append({
                "eyebrow": "결말",
                "title": "종이 침묵하다",
                "body": "최종 결말은 이제 명확한 런타임 인계로 읽힌다. 카르온은 쓰러지고 종은 멈추며, 탑은 더 이상 무엇을 남길지 결정할 권리를 잃는다."
            })
            cards.append({
                "eyebrow": "기억",
                "title": "이름은 함께 남는다",
                "body": "엔딩 상태는 이제 지워진 권위가 아니라 함께 붙든 기억을 통한 생존으로 정리되며, 결말을 단순 요약이 아닌 읽히는 종결로 바꾼다."
            })
        if _battle_controller != null:
            var name_call_snapshot: Dictionary = _battle_controller.get_last_name_call_snapshot()
            var name_call_line: String = String(name_call_snapshot.get("line", "")).strip_edges()
            var speaker_id: StringName = StringName(name_call_snapshot.get("speaker_id", &""))
            if not name_call_line.is_empty() and speaker_id != &"":
                cards.append({
                    "eyebrow": "이름 부름",
                    "title": "%s의 이름 부름" % _format_support_speaker_name(speaker_id),
                    "body": name_call_line,
                    "callout": "마지막 이름 / %s" % _format_support_speaker_name(speaker_id),
                    "eyebrow_label": "Name-Call Memory",
                    "source_label": "Resolution Surface",
                    "memory_rail": "name_call",
                    "outcome_line": "결말 presentation card에 마지막 이름 기억이 고정되었다.",
                    "memory_stamp": "CH10 Final / 마지막 이름",
                    "memory_stack": [
                        "rail:name_call",
                        "eyebrow:name_call_memory",
                        "progress:name_call_memory",
                        "source:resolution_surface",
                        "outcome:name_call_memory"
                    ],
                    "memory_signature": "name_call|resolution_surface|name_call_memory",
                    "style": "name_call_memory",
                    "badges": [
                        {"label": "발화자", "value": _format_support_speaker_name(speaker_id), "complete": true},
                        {"label": "이름 부름", "value": "완료", "complete": true}
                    ],
                    "progress_rows": [
                        {"label": "이름 부름", "value": "1/1", "complete": true},
                        {"label": "발화자", "value": _format_support_speaker_name(speaker_id), "complete": true}
                    ]
                })
        if not criteria_body.is_empty():
            cards.append({
                "eyebrow": "기준선",
                "title": "최종 진엔딩 기준",
                "body": criteria_body,
                "style": "ending_criteria",
                "badges": criteria_badges,
                "progress_rows": criteria_progress_rows
            })
    return cards

func _build_ending_criteria_badges(status: Dictionary) -> Array[Dictionary]:
    return [
        {
            "label": "공명 인장",
            "value": "%d/%d" % [int(status.get("resonance_count", 0)), int(status.get("required_resonance_count", 0))],
            "complete": bool(status.get("all_resonance_flags", false))
        },
        {
            "label": "이름 앵커",
            "value": "유지" if bool(status.get("name_anchors_ok", false)) else "미달",
            "complete": bool(status.get("name_anchors_ok", false))
        },
        {
            "label": "이름 부름",
            "value": "완료" if bool(status.get("all_name_calls", false)) else "미완",
            "complete": bool(status.get("all_name_calls", false))
        }
    ]

func _build_ending_criteria_body(status: Dictionary) -> String:
    var lines: Array[String] = []
    if bool(status.get("all_resonance_flags", false)):
        lines.append("모든 동료 공명 인장이 완성되어 마지막 결말의 공명 축이 닫혔다.")
    else:
        var missing_labels: Array[String] = []
        for raw_flag in status.get("missing_resonance_flags", []):
            missing_labels.append(_format_resonance_flag_label(String(raw_flag)))
        if not missing_labels.is_empty():
            lines.append("미완 공명 인장: %s" % ", ".join(missing_labels))
    if bool(status.get("name_anchors_ok", false)):
        lines.append("최종전에서 이름 앵커 유지 조건이 충족되었다.")
    else:
        lines.append("최종전 이름 앵커 유지 조건이 아직 부족하다.")
    if bool(status.get("all_name_calls", false)):
        lines.append("6인의 이름 부름이 모두 회수되었다.")
    else:
        lines.append("6인의 이름 부름이 아직 모두 회수되지 않았다.")
    return "\n".join(lines)

func _build_ending_criteria_progress_rows(status: Dictionary) -> Array[Dictionary]:
    var rows: Array[Dictionary] = []
    var resonance_count: int = int(status.get("resonance_count", 0))
    var resonance_required: int = max(1, int(status.get("required_resonance_count", 1)))
    rows.append({
        "icon": "◈",
        "label": "공명 인장",
        "value": "%d/%d" % [resonance_count, resonance_required],
        "ratio": float(resonance_count) / float(resonance_required),
        "complete": bool(status.get("all_resonance_flags", false)),
        "hint": "6인의 공명이 모두 닫혀야 진엔딩 기준선이 열린다.",
        "pip_total": resonance_required,
        "pip_filled": resonance_count
    })
    rows.append({
        "icon": "⛨",
        "label": "이름 앵커",
        "value": "유지" if bool(status.get("name_anchors_ok", false)) else "미달",
        "ratio": 1.0 if bool(status.get("name_anchors_ok", false)) else 0.0,
        "complete": bool(status.get("name_anchors_ok", false)),
        "hint": "최종전에서 앵커가 무너지지 않아야 이름축이 유지된다."
    })
    rows.append({
        "icon": "✦",
        "label": "이름 부름",
        "value": "완료" if bool(status.get("all_name_calls", false)) else "미완",
        "ratio": 1.0 if bool(status.get("all_name_calls", false)) else 0.0,
        "complete": bool(status.get("all_name_calls", false)),
        "hint": "마지막 종길에서 6인의 이름 부름이 모두 회수되어야 한다."
    })
    return rows

func _format_resonance_flag_label(flag_name: String) -> String:
    match flag_name:
        "flag_resonance_serin":
            return "세린"
        "flag_resonance_bran":
            return "브란"
        "flag_resonance_tia":
            return "티아"
        "flag_resonance_enoch":
            return "에녹"
        "flag_resonance_karl":
            return "카일"
        "flag_resonance_noah":
            return "노아"
        _:
            return flag_name

func _format_support_speaker_name(unit_id: StringName) -> String:
    match unit_id:
        &"ally_serin":
            return "세린"
        &"ally_bran":
            return "브란"
        &"ally_tia":
            return "티아"
        &"ally_enoch":
            return "에녹"
        &"ally_kyle", &"ally_karl":
            return "카일"
        &"ally_noah":
            return "노아"
        &"ally_rian":
            return "리안"
        _:
            return String(unit_id)

func _commit_stage_rewards(stage: StageData) -> void:
    _commit_stage_resolution(stage)
    _unlock_hidden_recruits_for_stage(stage)
    _append_unique_lines(_chapter_reward_entries, _battle_controller.get_inventory_entries())
    _grant_material_rewards_for_stage(stage.stage_id)
    _commit_stage_star_rewards(stage)
    _unlock_weapons_for_stage(stage.stage_id)
    _unlock_armors_for_stage(stage.stage_id)
    _unlock_accessories_for_stage(stage.stage_id)
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CampaignContentRegistry.CH01_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CampaignContentRegistry.CH02_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CampaignContentRegistry.CH03_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CampaignContentRegistry.CH04_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CampaignContentRegistry.CH05_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CampaignContentRegistry.CH06_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CampaignContentRegistry.CH07_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CampaignContentRegistry.CH08_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CampaignContentRegistry.CH09A_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CampaignContentRegistry.CH09B_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(CampaignContentRegistry.CH10_STAGE_REWARD_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CampaignContentRegistry.CH01_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CampaignContentRegistry.CH02_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CampaignContentRegistry.CH03_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CampaignContentRegistry.CH04_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CampaignContentRegistry.CH05_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CampaignContentRegistry.CH06_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CampaignContentRegistry.CH07_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CampaignContentRegistry.CH08_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CampaignContentRegistry.CH09A_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CampaignContentRegistry.CH09B_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_memory_entries, _format_record_entries(CampaignContentRegistry.CH10_STAGE_MEMORY_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CampaignContentRegistry.CH01_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CampaignContentRegistry.CH02_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CampaignContentRegistry.CH03_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CampaignContentRegistry.CH04_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CampaignContentRegistry.CH05_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CampaignContentRegistry.CH06_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CampaignContentRegistry.CH07_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CampaignContentRegistry.CH08_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CampaignContentRegistry.CH09A_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CampaignContentRegistry.CH09B_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_evidence_entries, _format_record_entries(CampaignContentRegistry.CH10_STAGE_EVIDENCE_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CampaignContentRegistry.CH01_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CampaignContentRegistry.CH02_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CampaignContentRegistry.CH03_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CampaignContentRegistry.CH04_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CampaignContentRegistry.CH05_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CampaignContentRegistry.CH06_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CampaignContentRegistry.CH07_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CampaignContentRegistry.CH08_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CampaignContentRegistry.CH09A_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CampaignContentRegistry.CH09B_STAGE_LETTER_LOG.get(stage.stage_id, [])))
    _append_unique_lines(_unlocked_letter_entries, _format_record_entries(CampaignContentRegistry.CH10_STAGE_LETTER_LOG.get(stage.stage_id, [])))

func _unlock_hidden_recruits_for_stage(stage: StageData) -> void:
    if stage == null:
        return
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null:
        return
    var battle_flags: Dictionary = {}
    if _battle_controller != null:
        battle_flags = _battle_controller.battle_objective_flags.duplicate(true)
    var reward_lines: Array[String] = []
    match stage.stage_id:
        &"CH07_05":
            if bool(battle_flags.get("recruit_mira", false)) and progression_data.unlock_hidden_recruit(&"ally_mira"):
                reward_lines.append(_build_hidden_recruit_reward_line(&"ally_mira"))
        &"CH08_05":
            if bool(battle_flags.get("lete_defects_alive", false)) and progression_data.unlock_hidden_recruit(&"ally_lete"):
                reward_lines.append(_build_hidden_recruit_reward_line(&"ally_lete"))
        &"CH09B_05":
            if bool(battle_flags.get("melkion_truth_revealed", false)) and bool(battle_flags.get("noah_survives", false)) and _get_support_rank_for_unlock(&"ally_rian", &"ally_noah") >= 4 and progression_data.unlock_hidden_recruit(&"ally_melkion_ally"):
                reward_lines.append(_build_hidden_recruit_reward_line(&"ally_melkion_ally"))
        &"CH10_01":
            if progression_data.consume_hidden_recruit(&"ally_melkion_ally"):
                reward_lines.append("동료 이탈: 멜키온")
        _:
            pass
    _append_unique_lines(_chapter_reward_entries, reward_lines)

func _build_hidden_recruit_reward_line(unit_id: StringName) -> String:
    var unit_data: UnitData = _get_unit_data_by_id(unit_id)
    if unit_data == null:
        return "동료 합류: %s" % String(unit_id)
    return "동료 합류: %s" % unit_data.display_name

func _get_support_rank_for_unlock(unit_a: StringName, unit_b: StringName) -> int:
    if _battle_controller != null and _battle_controller.bond_service != null:
        return _battle_controller.bond_service.get_support_rank(unit_a, unit_b)
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null:
        return 0
    var pair_id := SupportConversations.get_pair_id(String(unit_a), String(unit_b))
    if pair_id.is_empty():
        return 0
    return progression_data.get_support_rank(pair_id)

func _commit_stage_resolution(stage: StageData) -> void:
    if stage == null or _battle_controller == null or _battle_controller.progression_service == null or _stage_resolution_service == null:
        return
    var progression_data: ProgressionData = _battle_controller.progression_service.get_data()
    if progression_data == null:
        return
    var result_summary: Dictionary = _battle_controller.get_last_result_summary()
    var report := {
        "stage_id": stage.stage_id,
        "cleared": true,
        "optional_objective_ids_completed": result_summary.get("optional_objectives_completed", []).duplicate(),
        "obtained_memory_fragment_id": String(result_summary.get("fragment_id", "")).strip_edges(),
        "opened_treasure_ids": _battle_controller.get_inventory_entries().duplicate(),
        "battle_temp_flags": _battle_controller.battle_objective_flags.duplicate(true),
        "telemetry": Dictionary(result_summary.get("telemetry", {})).duplicate(true),
    }
    _stage_resolution_service.resolve(report, progression_data)

func _process_post_battle_supports(_stage: StageData) -> void:
    if _battle_controller == null or _battle_controller.bond_service == null:
        return
    var surviving_units: Array = []
    for unit in _battle_controller.ally_units:
        if not is_instance_valid(unit) or unit.unit_data == null or unit.is_defeated():
            continue
        surviving_units.append(unit)
    for left_index in range(surviving_units.size()):
        for right_index in range(left_index + 1, surviving_units.size()):
            var left_unit = surviving_units[left_index]
            var right_unit = surviving_units[right_index]
            var unit_a: StringName = left_unit.unit_data.unit_id
            var unit_b: StringName = right_unit.unit_data.unit_id
            var pair_id := SupportConversations.get_pair_id(String(unit_a), String(unit_b))
            if pair_id.is_empty():
                continue
            var previous_rank: int = _battle_controller.bond_service.get_support_rank(unit_a, unit_b)
            _battle_controller.bond_service.register_shared_battle(unit_a, unit_b)
            var current_rank: int = _battle_controller.bond_service.get_support_rank(unit_a, unit_b)
            var shared_battle_count: int = _battle_controller.bond_service.get_shared_battle_count(unit_a, unit_b)
            if current_rank < 1 or current_rank > 3:
                continue
            if current_rank <= previous_rank or shared_battle_count < 3:
                continue
            if _roll_support_trigger_chance() >= 0.4:
                continue
            _show_support_conversation(pair_id, current_rank)

func _show_support_conversation(pair_id: String, rank: int) -> void:
    if _battle_controller == null or _battle_controller.hud == null:
        return
    var text := CampaignShellDialogueCatalog.get_support_dialogue(pair_id, rank)
    if text.is_empty():
        return
    var camp_line := "Support %s Rank — %s" % [SupportConversations.get_rank_label(rank), text]
    _recent_support_dialogue_entries = _merge_unique_lines(_recent_support_dialogue_entries, [camp_line])
    var result_summary: Dictionary = _battle_controller.last_result_summary.duplicate(true)
    var conversations: Array = result_summary.get("support_conversations", []).duplicate(true)
    var pair_label := _build_support_pair_label(pair_id)
    var rank_label := "%s 랭크" % SupportConversations.get_rank_label(rank)
    var stage_stamp := "CH00_00"
    if _battle_controller != null and _battle_controller.stage_data != null:
        stage_stamp = String(_battle_controller.stage_data.stage_id)
    _recent_support_presentation_cards = _merge_presentation_cards(_recent_support_presentation_cards, [{
        "eyebrow": "지원 랭크 상승",
        "title": pair_label,
        "body": "%s / %s" % [rank_label, text],
        "quote": text,
        "eyebrow_label": "Support Memory",
        "source_label": "Camp Handoff",
        "memory_rail": "support",
        "outcome_line": "캠프 대화와 presentation card에 최신 support 기억이 남았다.",
        "memory_stamp": "%s / Support %s" % [stage_stamp, SupportConversations.get_rank_label(rank)],
        "memory_stack": [
            "rail:support",
            "eyebrow:support_memory",
            "progress:support_memory",
            "source:camp_handoff",
            "outcome:support_memory"
        ],
        "memory_signature": "support|camp_handoff|support_memory",
        "style": "support_memory",
        "badges": [
            {"label": "지원 랭크", "value": rank_label, "complete": true},
            {"label": "페어", "value": pair_label, "complete": true}
        ],
        "progress_rows": [
            {"label": "지원 단계", "value": "%d/3" % rank, "complete": rank >= 3},
            {"label": "현재", "value": rank_label, "complete": true}
        ]
    }])
    conversations.append({
        "pair_id": pair_id,
        "pair_label": pair_label,
        "rank": rank,
        "rank_label": rank_label,
        "text": text
    })
    result_summary["support_conversations"] = conversations
    _battle_controller.last_result_summary = result_summary
    _battle_controller.hud.set_transition_reason("support_rank_up", {
        "pair": pair_label,
        "rank": rank_label
    })
    _battle_controller.hud.cache_result_text(_battle_controller._build_result_summary_text(result_summary))
    _battle_controller.hud.show_result_screen(result_summary)

func _roll_support_trigger_chance() -> float:
    if not _debug_support_rolls.is_empty():
        return float(_debug_support_rolls.pop_front())
    return _support_rng.randf()

func _build_support_pair_label(pair_id: String) -> String:
    var labels: Array[String] = []
    for token in pair_id.split("_", false):
        labels.append(String(token).capitalize())
    return " + ".join(labels)

func debug_queue_support_rolls(rolls: Array[float]) -> void:
    _debug_support_rolls = rolls.duplicate()

func _unlock_accessories_for_stage(stage_id: StringName) -> void:
    var unlocks: Variant = []
    if CampaignContentRegistry.CH02_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH02_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH03_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH03_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH04_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH04_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH05_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH05_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH06_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH06_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH07_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH07_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH08_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH08_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH09A_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH09A_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH09B_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH09B_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH10_STAGE_ACCESSORY_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH10_STAGE_ACCESSORY_UNLOCKS.get(stage_id, [])
    if typeof(unlocks) != TYPE_ARRAY:
        return
    for accessory_id in unlocks:
        var typed_id: StringName = accessory_id
        _add_owned_item("accessory", typed_id)

func _unlock_weapons_for_stage(stage_id: StringName) -> void:
    var unlocks: Variant = []
    if CampaignContentRegistry.CH05_STAGE_WEAPON_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH05_STAGE_WEAPON_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH06_STAGE_WEAPON_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH06_STAGE_WEAPON_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH07_STAGE_WEAPON_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH07_STAGE_WEAPON_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH08_STAGE_WEAPON_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH08_STAGE_WEAPON_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH09A_STAGE_WEAPON_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH09A_STAGE_WEAPON_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH09B_STAGE_WEAPON_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH09B_STAGE_WEAPON_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH10_STAGE_WEAPON_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH10_STAGE_WEAPON_UNLOCKS.get(stage_id, [])
    if typeof(unlocks) != TYPE_ARRAY:
        return
    for weapon_id in unlocks:
        var typed_id: StringName = weapon_id
        _add_owned_item("weapon", typed_id)

func _unlock_armors_for_stage(stage_id: StringName) -> void:
    var unlocks: Variant = []
    if CampaignContentRegistry.CH03_STAGE_ARMOR_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH03_STAGE_ARMOR_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH04_STAGE_ARMOR_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH04_STAGE_ARMOR_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH05_STAGE_ARMOR_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH05_STAGE_ARMOR_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH07_STAGE_ARMOR_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH07_STAGE_ARMOR_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH08_STAGE_ARMOR_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH08_STAGE_ARMOR_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH09A_STAGE_ARMOR_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH09A_STAGE_ARMOR_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH09B_STAGE_ARMOR_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH09B_STAGE_ARMOR_UNLOCKS.get(stage_id, [])
    elif CampaignContentRegistry.CH10_STAGE_ARMOR_UNLOCKS.has(stage_id):
        unlocks = CampaignContentRegistry.CH10_STAGE_ARMOR_UNLOCKS.get(stage_id, [])
    if typeof(unlocks) != TYPE_ARRAY:
        return
    for armor_id in unlocks:
        var typed_id: StringName = armor_id
        _add_owned_item("armor", typed_id)

func _variant_to_string_array(value: Variant) -> Array[String]:
    var lines: Array[String] = []
    if typeof(value) != TYPE_ARRAY:
        return lines
    for entry in value:
        lines.append(str(entry))
    return lines

func _format_record_entries(entries: Variant) -> Array[String]:
    var lines: Array[String] = []
    if typeof(entries) != TYPE_ARRAY:
        return lines

    for entry in entries:
        if typeof(entry) != TYPE_DICTIONARY:
            continue
        lines.append("%s — %s" % [
            String(entry.get("title", "Record")),
            String(entry.get("summary", ""))
        ])
    return lines

func _append_unique_lines(target: Array[String], lines: Array[String]) -> void:
    for line in lines:
        var normalized: String = line.strip_edges()
        if normalized.is_empty():
            continue
        if not target.has(normalized):
            target.append(normalized)

func _merge_unique_lines(base: Array[String], extra: Array[String]) -> Array[String]:
    var merged: Array[String] = base.duplicate()
    _append_unique_lines(merged, extra)
    return merged

func _variant_to_dictionary_array(value: Variant) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    if value is Array[Dictionary]:
        return (value as Array[Dictionary]).duplicate(true)
    if value is Array:
        for entry in value:
            if typeof(entry) == TYPE_DICTIONARY:
                result.append(Dictionary(entry))
    return result

func _get_progression_data() -> ProgressionData:
    if _battle_controller == null or _battle_controller.progression_service == null:
        return null
    return _battle_controller.progression_service.get_data()

func _build_material_entries() -> Array[Dictionary]:
    return ForgeService.get_material_entries(_get_progression_data())

func _get_gold_amount() -> int:
    var progression_data: ProgressionData = _get_progression_data()
    return progression_data.gold if progression_data != null else 0

func _build_forge_recipe_entries() -> Array[Dictionary]:
    return ForgeService.build_recipe_entries(_get_progression_data(), _get_all_owned_item_ids())

func _get_all_owned_item_ids() -> Array[StringName]:
    var owned: Array[StringName] = []
    for weapon_id in _get_owned_item_ids("weapon"):
        if not owned.has(weapon_id):
            owned.append(weapon_id)
    for armor_id in _get_owned_item_ids("armor"):
        if not owned.has(armor_id):
            owned.append(armor_id)
    for accessory_id in _get_owned_item_ids("accessory"):
        if not owned.has(accessory_id):
            owned.append(accessory_id)
    return owned

func _is_item_owned(output_type: StringName, output_id: StringName) -> bool:
    match output_type:
        ForgeService.OUTPUT_WEAPON:
            return _get_owned_item_count("weapon", output_id) > 0
        ForgeService.OUTPUT_ARMOR:
            return _get_owned_item_count("armor", output_id) > 0
        ForgeService.OUTPUT_ACCESSORY:
            return _get_owned_item_count("accessory", output_id) > 0
        _:
            return false

func _unlock_crafted_item(output_type: StringName, output_id: StringName) -> void:
    match output_type:
        ForgeService.OUTPUT_WEAPON:
            _add_owned_item("weapon", output_id)
        ForgeService.OUTPUT_ARMOR:
            _add_owned_item("armor", output_id)
        ForgeService.OUTPUT_ACCESSORY:
            _add_owned_item("accessory", output_id)

func _grant_material_rewards_for_stage(stage_id: StringName) -> void:
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null:
        return
    var chapter_key: StringName = _extract_chapter_material_key(stage_id)
    if not CampaignContentRegistry.CHAPTER_MATERIAL_REWARDS.has(chapter_key):
        return
    var interaction_bonus: int = max(0, _battle_controller.get_inventory_entries().size() - 1) if _battle_controller != null else 0
    var reward_lines: Array[String] = []
    var rewards: Array = CampaignContentRegistry.CHAPTER_MATERIAL_REWARDS.get(chapter_key, [])
    for reward in rewards:
        if typeof(reward) != TYPE_DICTIONARY:
            continue
        var material_id: StringName = StringName(reward.get("material_id", &""))
        var count: int = max(1, int(reward.get("count", 0)))
        if material_id == &"":
            continue
        var total_count: int = count + interaction_bonus
        progression_data.add_material(material_id, total_count)
        reward_lines.append("재료: %s x%d" % [ForgeService.get_material_label(material_id), total_count])
    _append_unique_lines(_chapter_reward_entries, reward_lines)

func _commit_stage_star_rewards(stage: StageData) -> void:
    if stage == null or _battle_controller == null:
        return
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null:
        return
    var battle_result: Dictionary = _battle_controller.get_last_result_summary()
    if not battle_result.has("stars_earned"):
        return
    var stars: int = clampi(int(battle_result.get("stars_earned", 1)), 1, 3)
    var previous_best: int = clampi(int(progression_data.stage_star_ratings.get(stage.stage_id, 0)), 0, 3)
    if stars > previous_best:
        progression_data.stage_star_ratings[stage.stage_id] = stars
        progression_data.total_stars = max(0, progression_data.total_stars - previous_best + stars)
    elif previous_best <= 0:
        progression_data.stage_star_ratings[stage.stage_id] = stars
        progression_data.total_stars += stars
    if stars >= 3:
        _grant_bonus_material_rewards(stage.stage_id, 2)
    elif stars >= 2:
        _grant_bonus_material_rewards(stage.stage_id, 1)

func _grant_bonus_material_rewards(stage_id: StringName, bonus_count: int) -> void:
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null or bonus_count <= 0:
        return
    var chapter_key: StringName = _extract_chapter_material_key(stage_id)
    if not CampaignContentRegistry.CHAPTER_MATERIAL_REWARDS.has(chapter_key):
        return
    var rewards: Array = CampaignContentRegistry.CHAPTER_MATERIAL_REWARDS.get(chapter_key, [])
    if rewards.is_empty():
        return
    var reward_lines: Array[String] = []
    for index in range(bonus_count):
        var reward: Variant = rewards[index % rewards.size()]
        if typeof(reward) != TYPE_DICTIONARY:
            continue
        var material_id: StringName = StringName(reward.get("material_id", &""))
        if material_id == &"":
            continue
        progression_data.add_material(material_id, 1)
        reward_lines.append("보너스 재료: %s x1" % ForgeService.get_material_label(material_id))
    _append_unique_lines(_chapter_reward_entries, reward_lines)

func _extract_chapter_material_key(stage_id: StringName) -> StringName:
    var stage_text: String = String(stage_id).to_lower()
    if stage_text.begins_with("ch09a"):
        return &"ch09a"
    if stage_text.begins_with("ch09b"):
        return &"ch09b"
    if stage_text.length() >= 4:
        return StringName(stage_text.left(4))
    return StringName(stage_text)

func _build_crafted_inventory_line(recipe_id: StringName) -> String:
    var recipe: Dictionary = ForgeService.get_recipe(recipe_id)
    if recipe.is_empty():
        return ""
    var output_type: String = String(recipe.get("output_type", "item")).capitalize()
    return "%s 제작 완료: %s" % [output_type, String(recipe.get("label", String(recipe_id)))]

func _refresh_camp_panel_state() -> void:
    if _active_mode != CampaignState.MODE_CAMP:
        return
    _set_panel_state(CampaignState.MODE_CAMP, _current_panel_title, _current_panel_body, _campaign_panel.advance_button.text if _campaign_panel != null else "다음 전투")

func _build_camp_alerts(memory_entries: Array[String], evidence_entries: Array[String], letter_entries: Array[String], inventory_entries: Array[String]) -> Array[String]:
    var alerts: Array[String] = ["캠프 준비 완료", "부대 갱신 가능"]
    if _get_craftable_recipe_count() > 0:
        alerts.append("제작 레시피 사용 가능")
    if not memory_entries.is_empty():
        alerts.append("기억 기록 갱신")
    if not evidence_entries.is_empty():
        alerts.append("증거 경로 갱신")
    if not letter_entries.is_empty():
        alerts.append("편지 도착")
    if not inventory_entries.is_empty():
        alerts.append("회수한 보급 기록 반영")
    return alerts

func _build_camp_recommendation(memory_entries: Array[String], evidence_entries: Array[String], letter_entries: Array[String], inventory_entries: Array[String], recall_hunt_entries: Array[Dictionary] = [], selected_hunt_id: StringName = &"", last_hunt_result: Dictionary = {}) -> String:
    if not memory_entries.is_empty() or not evidence_entries.is_empty() or not letter_entries.is_empty():
        return "기록 탭에서 최신 기억, 증거, 세린 인계 내용을 먼저 확인한 뒤 부대 상태를 점검한다."
    if not last_hunt_result.is_empty():
        var hunt_label: String = String(last_hunt_result.get("hunt_display_name", "회상 토벌전")).strip_edges()
        var flavor_line: String = _get_hunt_flavor_line(StringName(last_hunt_result.get("hunt_id", &"")), "return")
        if not flavor_line.is_empty():
            return "%s `%s` 귀환 결과를 확인하고 보상 정산 뒤 다음 출격 또는 다음 추억 토벌로 이어 간다." % [flavor_line, hunt_label]
        return "회상 토벌전 `%s` 귀환 결과를 확인하고 보상 정산 뒤 다음 출격 또는 다음 추억 토벌로 이어 간다." % hunt_label
    if not recall_hunt_entries.is_empty():
        var selected_label: String = ""
        var selected_hunt: StringName = &""
        for entry in recall_hunt_entries:
            if StringName(entry.get("hunt_id", &"")) == selected_hunt_id:
                selected_label = String(entry.get("display_name", "")).strip_edges()
                selected_hunt = StringName(entry.get("hunt_id", &""))
                break
        if not selected_label.is_empty():
            var selected_flavor: String = _get_hunt_flavor_line(selected_hunt, "launch")
            if not selected_flavor.is_empty():
                return "%s `%s` 준비 상태를 확인하고 보상 정산 뒤 다음 전투 또는 추억 토벌로 넘어간다." % [selected_flavor, selected_label]
            return "회상 토벌전 `%s` 준비 상태를 확인하고 보상 정산 뒤 다음 전투 또는 추억 토벌로 넘어간다." % selected_label
        return "회상 토벌전 해금 상태와 보상 정산을 확인한 뒤 다음 전투를 준비한다."
    if _get_craftable_recipe_count() > 0:
        return "제작 탭에서 회수한 재료를 사용한 뒤 부대 탭으로 돌아와 다음 장비 구성을 확정한다."
    if not inventory_entries.is_empty():
        return "인벤토리 탭에서 회수한 보급을 확인한 뒤 북쪽 경로를 위한 부대를 확정한다."
    return "현재 부대 상태를 점검하고 준비가 끝나면 진행한다."

func _build_camp_section_badges(party_entries: Array[String], inventory_entries: Array[String], dialogue_entries: Array[String], memory_entries: Array[String], evidence_entries: Array[String], letter_entries: Array[String]) -> Dictionary:
    var badges: Dictionary = {}
    if not party_entries.is_empty():
        badges[CampaignPanel.SECTION_PARTY] = "준비"

    var inventory_count: int = inventory_entries.size()
    if inventory_count > 0:
        badges[CampaignPanel.SECTION_INVENTORY] = str(inventory_count)

    var craftable_count: int = _get_craftable_recipe_count()
    if craftable_count > 0:
        badges[CampaignPanel.SECTION_FORGE] = "준비 %d" % craftable_count

    var dialogue_count: int = dialogue_entries.size()
    if dialogue_count > 0:
        badges[CampaignPanel.SECTION_DIALOGUE_HISTORY] = "신규 %d" % dialogue_count

    var record_count: int = memory_entries.size() + evidence_entries.size() + letter_entries.size()
    if record_count > 0:
        badges[CampaignPanel.SECTION_RECORDS] = "신규 %d" % record_count

    return badges

func _build_recall_presentation_cards(recall_hunt_entries: Array[Dictionary], selected_hunt_id: StringName, last_hunt_result: Dictionary = {}) -> Array[Dictionary]:
    var cards: Array[Dictionary] = []
    var unlocked_count: int = 0
    var selected_entry: Dictionary = {}
    for entry in recall_hunt_entries:
        if bool(entry.get("unlocked", false)):
            unlocked_count += 1
        if StringName(entry.get("hunt_id", &"")) == selected_hunt_id:
            selected_entry = entry
    if unlocked_count <= 0:
        return cards
    cards.append({
        "eyebrow": "회상 토벌전",
        "title": "해금된 회상 %d개" % unlocked_count,
        "body": "캠프 메인 루프에서도 해금된 회상 토벌전과 보상을 바로 확인할 수 있다."
    })
    if not selected_entry.is_empty():
        var selected_hunt_id_text: StringName = StringName(selected_entry.get("hunt_id", &""))
        var selected_flavor: String = _get_hunt_flavor_line(selected_hunt_id_text, "launch")
        var launch_snippet: String = _get_hunt_cutscene_snippet(selected_hunt_id_text, "launch")
        var latest_branch_summary: String = ""
        var latest_control_summary: String = ""
        if not last_hunt_result.is_empty() and StringName(last_hunt_result.get("hunt_id", &"")) == selected_hunt_id_text:
            latest_branch_summary = String(last_hunt_result.get("branch_summary", "")).strip_edges()
            var override_text: String = String(last_hunt_result.get("return_cutscene_override", "")).strip_edges()
            if not override_text.is_empty():
                latest_control_summary = "최근 제어: %s" % override_text
        cards.append({
            "eyebrow": "선택된 토벌전",
            "title": String(selected_entry.get("display_name", "회상 토벌전")),
            "body": "%s%s / 난이도 %d / 권장 레벨 %d%s" % [
                "%s / " % selected_flavor if not selected_flavor.is_empty() else "",
                String(selected_entry.get("description", "")),
                int(selected_entry.get("difficulty", 1)),
                int(selected_entry.get("recommended_level", 1)),
                " / 최근 귀환: %s" % latest_branch_summary if not latest_branch_summary.is_empty() else ""
            ]
        })
        var stage_brief_card: Dictionary = _build_hunt_stage_brief_card(selected_entry, latest_control_summary)
        if not stage_brief_card.is_empty():
            cards.append(stage_brief_card)
        if not launch_snippet.is_empty():
            cards.append({
                "eyebrow": "출정 장면",
                "title": "%s 출정" % String(selected_entry.get("display_name", "회상 토벌전")),
                "body": launch_snippet
            })
    return cards

func _build_hunt_return_presentation_cards(last_hunt_result: Dictionary) -> Array[Dictionary]:
    var cards: Array[Dictionary] = []
    if last_hunt_result.is_empty():
        return cards
    var hunt_label: String = String(last_hunt_result.get("hunt_display_name", "회상 토벌전")).strip_edges()
    var hunt_desc: String = String(last_hunt_result.get("hunt_description", "")).strip_edges()
    var summary: String = String(last_hunt_result.get("return_summary", "")).strip_edges()
    var branch_summary: String = String(last_hunt_result.get("branch_summary", "")).strip_edges()
    var branch_memory_stamp: String = String(last_hunt_result.get("branch_card", {}).get("memory_stamp", "")).strip_edges()
    var control_memory_stamp: String = String(last_hunt_result.get("return_control_stamp", "")).strip_edges()
    var hunt_id: StringName = StringName(last_hunt_result.get("hunt_id", &""))
    var return_flavor: String = _get_hunt_flavor_line(hunt_id, "return")
    var return_snippet: String = String(last_hunt_result.get("return_cutscene_override", "")).strip_edges()
    if return_snippet.is_empty():
        return_snippet = _get_hunt_cutscene_snippet(hunt_id, "return")
    cards.append({
        "eyebrow": "분기 귀환" if not branch_summary.is_empty() else "귀환 보고",
        "title": "%s 분기 귀환" % hunt_label if not branch_summary.is_empty() else "%s 귀환" % hunt_label,
        "body": "%s%s" % ["%s / " % return_flavor if not return_flavor.is_empty() else "", summary if not summary.is_empty() else hunt_desc],
        "eyebrow_label": "Branch Return" if not branch_summary.is_empty() else "",
        "source_label": "Return Surface" if not branch_summary.is_empty() else "",
        "memory_rail": "branch_return" if not branch_summary.is_empty() else "",
        "memory_stamp": branch_memory_stamp,
        "memory_stack": [
            "rail:branch_return",
            "eyebrow:branch_return",
            "progress:branch_return",
            "source:return_surface",
            "outcome:branch_return"
        ] if not branch_summary.is_empty() else [],
        "memory_signature": "branch_return|return_surface|branch_return" if not branch_summary.is_empty() else "",
        "outcome_line": "보너스 정산과 귀환 기록이 강화되었다." if not branch_summary.is_empty() else "",
        "progress_rows": [
            {"label": "선택 목표", "value": "완료" if not branch_summary.is_empty() else "미달", "complete": not branch_summary.is_empty()},
            {"label": "귀환 상태", "value": "분기 귀환" if not branch_summary.is_empty() else "일반 귀환", "complete": true}
        ]
    })
    var branch_card: Dictionary = Dictionary(last_hunt_result.get("branch_card", {}))
    if not branch_card.is_empty():
        cards.append(branch_card)
    var reward_lines: Array[String] = _variant_to_string_array(last_hunt_result.get("reward_entries", []))
    var reward_body: String = ", ".join(reward_lines)
    if reward_body.is_empty():
        reward_body = "기억과 증거 회수 결과가 캠프 기록에 반영되었다."
    cards.append({
        "eyebrow": "회수 결과",
        "title": "%s 보상 정산" % hunt_label,
        "body": reward_body
    })
    if not return_snippet.is_empty():
        cards.append({
            "eyebrow": "제어 후일담" if not branch_summary.is_empty() else "귀환 장면",
            "title": "%s 제어 후일담" % hunt_label if not branch_summary.is_empty() else "%s 후일담" % hunt_label,
            "body": return_snippet,
            "eyebrow_label": "Control Aftermath" if not control_memory_stamp.is_empty() else "",
            "source_label": "Control Surface" if not control_memory_stamp.is_empty() else "",
            "memory_rail": "control_aftermath" if not control_memory_stamp.is_empty() else "",
            "memory_stamp": control_memory_stamp,
            "memory_stack": [
                "rail:control_aftermath",
                "eyebrow:control_aftermath",
                "progress:control_aftermath",
                "source:control_surface",
                "outcome:control_aftermath"
            ] if not control_memory_stamp.is_empty() else [],
            "memory_signature": "control_aftermath|control_surface|control_aftermath" if not control_memory_stamp.is_empty() else "",
            "outcome_line": "다음 출정 준비 화면에도 제어 결과가 남는다." if not control_memory_stamp.is_empty() else "",
            "progress_rows": [
                {"label": "제어 결과", "value": "확보" if not control_memory_stamp.is_empty() else "미확보", "complete": not control_memory_stamp.is_empty()},
                {"label": "후일담", "value": "갱신", "complete": true}
            ]
        })
    return cards

func _build_hunt_stage_brief_card(selected_entry: Dictionary, branch_control_summary: String = "") -> Dictionary:
    var hunt_stage_id: StringName = StringName(selected_entry.get("stage_id", &""))
    var stage: StageData = HuntStageRegistry.get_stage(hunt_stage_id)
    if stage == null:
        return {}
    var lines: Array[String] = []
    var hint: String = String(stage.stage_objective_hint).strip_edges()
    if not hint.is_empty():
        lines.append(hint)
    if not stage.optional_objectives.is_empty():
        var first_objective: Dictionary = stage.optional_objectives[0]
        var objective_text: String = String(first_objective.get("description", "")).strip_edges()
        if not objective_text.is_empty():
            lines.append("선택 목표: %s" % objective_text)
    if not stage.landmark_labels.is_empty():
        lines.append("랜드마크: %s" % ", ".join(_packed_array_to_string_array(stage.landmark_labels)))
    if not branch_control_summary.is_empty():
        lines.append(branch_control_summary)
    if lines.is_empty():
        return {}
    return {
        "eyebrow": "전장 요점",
        "title": "%s 전개" % String(selected_entry.get("display_name", "회상 토벌전")),
        "body": " / ".join(lines)
    }

func _get_hunt_cutscene_snippet(hunt_id: StringName, phase: String) -> String:
    var cutscene_id: StringName = &""
    match String(hunt_id):
        "hunt_basil":
            cutscene_id = &"hunt_basil_launch" if phase == "launch" else &"hunt_basil_return"
        "hunt_saria":
            cutscene_id = &"hunt_saria_launch" if phase == "launch" else &"hunt_saria_return"
        "hunt_lete":
            cutscene_id = &"hunt_lete_launch" if phase == "launch" else &"hunt_lete_return"
    if cutscene_id == &"":
        return ""
    var cutscene = CutsceneCatalog.get_cutscene(cutscene_id)
    if cutscene == null or cutscene.get_beat_count() <= 0:
        return ""
    var beat: Dictionary = cutscene.get_beat(mini(1, cutscene.get_beat_count() - 1))
    return String(beat.get("text", "")).strip_edges()

func _get_hunt_flavor_line(hunt_id: StringName, phase: String) -> String:
    match String(hunt_id):
        "hunt_basil":
            return "침수 성소가 다시 닫히기 전에" if phase == "launch" else "가라앉던 제단의 기록을 붙든 채"
        "hunt_saria":
            return "무너지는 기도 행렬이 완전히 흐트러지기 전에" if phase == "launch" else "기도실의 마지막 합창을 끊어 낸 채"
        "hunt_lete":
            return "흑견 추격대가 사라지기 전에" if phase == "launch" else "사냥의 마지막 흔적을 회수한 채"
        _:
            return ""

func _merge_presentation_cards(base: Array[Dictionary], extra: Array[Dictionary]) -> Array[Dictionary]:
    var merged: Array[Dictionary] = base.duplicate(true)
    for candidate in extra:
        if typeof(candidate) != TYPE_DICTIONARY:
            continue
        var candidate_title: String = String(candidate.get("title", "")).strip_edges()
        var exists: bool = false
        for current in merged:
            if typeof(current) != TYPE_DICTIONARY:
                continue
            if String(current.get("title", "")).strip_edges() == candidate_title:
                exists = true
                break
        if not exists:
            merged.append(candidate)
    return merged

func _get_craftable_recipe_count() -> int:
    var count: int = 0
    for entry in _build_forge_recipe_entries():
        if bool(entry.get("can_craft", false)):
            count += 1
    return count

func _get_deployment_limit() -> int:
    var chapter_rank: int = CampaignChapterRegistry.get_rank(_active_chapter_id)
    if chapter_rank >= 9:
        return 5
    if chapter_rank >= 5:
        return 4
    if chapter_rank >= 3:
        return 3
    return 2

func _build_runtime_deployed_party() -> Array[UnitData]:
    var deployed: Array[UnitData] = []
    _normalize_deployed_party_ids()
    for unit_id in _deployed_party_unit_ids:
        var unit_data: UnitData = _get_unit_data_by_id(unit_id)
        if unit_data != null and _is_recruit_unlocked(unit_id):
            deployed.append(unit_data)

    if deployed.is_empty():
        var default_rian: UnitData = CampaignCatalog.get_unit_data(&"ally_rian")
        var default_serin: UnitData = CampaignCatalog.get_unit_data(&"ally_serin")
        if default_rian != null:
            deployed.append(default_rian)
        if default_serin != null:
            deployed.append(default_serin)
        return deployed

    while deployed.size() < min(2, _get_deployment_limit()):
        var fallback_serin: UnitData = CampaignCatalog.get_unit_data(&"ally_serin")
        if fallback_serin == null:
            break
        deployed.append(fallback_serin)

    return deployed

func _normalize_deployed_party_ids() -> void:
    var normalized: Array[StringName] = [&"ally_rian"]
    for unit_id in _deployed_party_unit_ids:
        if unit_id == &"ally_rian":
            continue
        if not _is_recruit_unlocked(unit_id):
            continue
        if normalized.has(unit_id):
            continue
        normalized.append(unit_id)
        if normalized.size() >= _get_deployment_limit():
            break

    if normalized.size() == 1:
        normalized.append(&"ally_serin")
    _deployed_party_unit_ids = normalized

func _build_campaign_party_summary_lines() -> Array[String]:
    var lines: Array[String] = []
    for unit_data in _get_campaign_party_roster():
        var role_label: String = "대기"
        if unit_data.unit_id == &"ally_rian":
            role_label = "고정"
        elif _deployed_party_unit_ids.has(unit_data.unit_id):
            role_label = "출전 중"
        lines.append("%s  HP %d/%d  공격 %d  방어 %d  %s" % [
            unit_data.display_name,
            unit_data.max_hp,
            unit_data.max_hp,
            unit_data.attack,
            unit_data.defense,
            role_label
        ])
    return lines

func _build_campaign_party_detail_entries() -> Array[Dictionary]:
    var details: Array[Dictionary] = []
    for unit_data in _get_campaign_party_roster():
        var default_skill_name: String = unit_data.default_skill.display_name if unit_data.default_skill != null else "스킬 없음"
        var deploy_status: String = "대기"
        if unit_data.unit_id == &"ally_rian":
            deploy_status = "고정"
        elif _deployed_party_unit_ids.has(unit_data.unit_id):
            deploy_status = "출전 중"
        var weapon_name: String = "없음"
        var armor_name: String = "없음"
        var accessory_name: String = "없음"
        var equipped_weapon_id: StringName = StringName(_equipped_weapon_by_unit_id.get(String(unit_data.unit_id), ""))
        var equipped_armor_id: StringName = StringName(_equipped_armor_by_unit_id.get(String(unit_data.unit_id), ""))
        var equipped_accessory_id: StringName = StringName(_equipped_accessory_by_unit_id.get(String(unit_data.unit_id), ""))
        var equipped_weapon: WeaponData = _get_weapon_data_by_id(equipped_weapon_id)
        var equipped_armor: ArmorData = _get_armor_data_by_id(equipped_armor_id)
        var equipped_accessory: AccessoryData = _get_accessory_data_by_id(equipped_accessory_id)
        if equipped_weapon != null:
            weapon_name = equipped_weapon.display_name
        if equipped_armor != null:
            armor_name = equipped_armor.display_name
        if equipped_accessory != null:
            accessory_name = equipped_accessory.display_name
        var accessory_summary: String = equipped_accessory.summary if equipped_accessory != null else ""
        var accessory_flavor_text: String = _get_accessory_flavor_text(equipped_accessory)
        var allowed_weapon_types: PackedStringArray = unit_data.get_allowed_weapon_types()
        var allowed_armor_types: PackedStringArray = unit_data.get_allowed_armor_types()
        var eligible_weapon_ids: Array[StringName] = _get_available_weapon_ids_for_unit(unit_data.unit_id)
        var eligible_armor_ids: Array[StringName] = _get_available_armor_ids_for_unit(unit_data.unit_id)
        var eligible_accessory_ids: Array[StringName] = _get_available_accessory_ids()
        var progression_data: ProgressionData = _get_progression_data()
        var can_reforge: bool = eligible_accessory_ids.size() > 1 and ReforgeService.can_afford_accessory_reforge(progression_data)
        var reforge_tooltip: String = ReforgeService.format_accessory_reforge_cost(progression_data)
        var support_preview_path := ""
        var support_preview_title := ""
        var support_preview_body := ""
        var skill_entries: Array[Dictionary] = _build_skill_detail_entries(unit_data.get_all_skills())
        var resolved_class_name: String = ""
        var resolved_class_data = unit_data.get_class_data()
        if resolved_class_data != null:
            resolved_class_name = resolved_class_data.display_name.to_lower()
        if unit_data.unit_id == &"ally_rian":
            support_preview_path = FIELD_SWORD_SUPPORT_IMAGE
            support_preview_title = FIELD_SWORD_SUPPORT_TITLE
            support_preview_body = FIELD_SWORD_SUPPORT_BODY
        elif resolved_class_name.contains("knight") or resolved_class_name.contains("vanguard"):
            support_preview_path = PALADIN_SHIELD_SUPPORT_IMAGE
            support_preview_title = PALADIN_SHIELD_SUPPORT_TITLE
            support_preview_body = PALADIN_SHIELD_SUPPORT_BODY
        details.append({
            "unit_id": String(unit_data.unit_id),
            "name": unit_data.display_name,
            "hp_text": "%d/%d" % [unit_data.max_hp, unit_data.max_hp],
            "status": deploy_status,
            "attack": unit_data.attack,
            "defense": unit_data.defense,
            "move": unit_data.movement,
            "range": unit_data.attack_range,
            "skill": default_skill_name,
            "skill_entries": skill_entries,
            "weapon_slot": weapon_name,
            "armor_slot": armor_name,
            "accessory_slot": accessory_name,
            "weapon_sell_tooltip": _build_sell_tooltip("weapon", equipped_weapon),
            "armor_sell_tooltip": _build_sell_tooltip("armor", equipped_armor),
            "accessory_sell_tooltip": _build_sell_tooltip("accessory", equipped_accessory),
            "accessory_summary": accessory_summary,
            "accessory_flavor_text": accessory_flavor_text,
            "weapon_preview_path": _get_weapon_preview_path(equipped_weapon_id),
            "armor_preview_path": _get_armor_preview_path(equipped_armor_id),
            "accessory_preview_path": _get_accessory_preview_path(equipped_accessory_id),
            "support_preview_path": support_preview_path,
            "support_preview_title": support_preview_title,
            "support_preview_body": support_preview_body,
            "allowed_weapon_types": _packed_array_to_string_array(allowed_weapon_types),
            "allowed_armor_types": _packed_array_to_string_array(allowed_armor_types),
            "eligible_weapon_options": _build_weapon_option_entries(eligible_weapon_ids),
            "eligible_armor_options": _build_armor_option_entries(eligible_armor_ids),
            "eligible_accessory_options": _build_accessory_option_entries(eligible_accessory_ids),
            "eligible_weapon_count": eligible_weapon_ids.size(),
            "eligible_armor_count": eligible_armor_ids.size(),
            "eligible_accessory_count": eligible_accessory_ids.size(),
            "can_accessory_reforge": can_reforge,
            "accessory_reforge_tooltip": reforge_tooltip,
            "total_weapon_count": _get_available_weapon_ids().size(),
            "total_armor_count": _get_available_armor_ids().size(),
            "total_accessory_count": eligible_accessory_ids.size()
        })
    return details

func _build_skill_detail_entries(skills: Array) -> Array[Dictionary]:
    var entries: Array[Dictionary] = []
    for skill in skills:
        if skill == null:
            continue
        var cost_text: String = skill.get_resource_cost_text() if skill.has_method("get_resource_cost_text") else ""
        var current_level: int = int(skill.skill_level)
        var current_exp: int = int(skill.skill_exp)
        var exp_to_next: int = skill.exp_to_next_level(current_level) if skill.has_method("exp_to_next_level") else 0
        var exp_remaining: int = skill.exp_remaining() if skill.has_method("exp_remaining") else maxi(exp_to_next - current_exp, 0)
        var is_max_level: bool = skill.is_max_level() if skill.has_method("is_max_level") else exp_to_next <= 0
        entries.append({
            "skill_id": String(skill.skill_id),
            "name": String(skill.display_name),
            "description": String(skill.description),
            "cost_text": cost_text,
            "level": current_level,
            "exp": current_exp,
            "exp_to_next": exp_to_next,
            "exp_remaining": exp_remaining,
            "is_max": is_max_level,
        })
    return entries

func _get_campaign_party_roster() -> Array[UnitData]:
    var roster: Array[UnitData] = []
    for unit_id in CampaignCatalog.get_party_roster_order():
        if _ng_plus_enabled and unit_id != &"ally_rian":
            var ng_plus_unit: UnitData = CampaignCatalog.get_unit_data(unit_id)
            if ng_plus_unit != null:
                roster.append(ng_plus_unit)
            continue
        if not _is_recruit_unlocked(unit_id):
            continue
        var unit_data: UnitData = CampaignCatalog.get_unit_data(unit_id)
        if unit_data != null:
            roster.append(unit_data)
    return roster

func _get_unit_data_by_id(unit_id: StringName) -> UnitData:
    return CampaignCatalog.get_unit_data(unit_id)

func _get_accessory_data_by_id(accessory_id: StringName) -> AccessoryData:
    return CampaignCatalog.get_accessory_data(accessory_id)

func _get_weapon_data_by_id(weapon_id: StringName) -> WeaponData:
    return CampaignCatalog.get_weapon_data(weapon_id)

func _get_armor_data_by_id(armor_id: StringName) -> ArmorData:
    return CampaignCatalog.get_armor_data(armor_id)

func _is_recruit_unlocked(unit_id: StringName) -> bool:
    if _ng_plus_enabled:
        return true
    if CampaignCatalog.is_hidden_recruit(unit_id):
        var progression_data: ProgressionData = _get_progression_data()
        if progression_data == null or not progression_data.has_hidden_recruit(unit_id):
            return false
        if unit_id == &"ally_melkion_ally":
            return _is_melkion_temporary_ally_available()
        return true
    match unit_id:
        &"ally_bran":
            return _active_chapter_id == CHAPTER_CH02 and _active_mode == CampaignState.MODE_CAMP \
                or _chapter_rank(_active_chapter_id) > 2
        &"ally_tia":
            return _active_chapter_id == CHAPTER_CH03 and _active_mode == CampaignState.MODE_CAMP \
                or _chapter_rank(_active_chapter_id) > 3
        &"ally_enoch":
            return _active_chapter_id == CHAPTER_CH05 and _active_mode == CampaignState.MODE_CAMP \
                or _chapter_rank(_active_chapter_id) > 5
        &"ally_kyle":
            return _active_chapter_id == CHAPTER_CH09A and _active_mode == CampaignState.MODE_CAMP \
                or _chapter_rank(_active_chapter_id) > 9
        &"ally_noah":
            return _active_chapter_id == CHAPTER_CH09B and _active_mode == CampaignState.MODE_CAMP \
                or _chapter_rank(_active_chapter_id) > 10
        _:
            return true

func _is_melkion_temporary_ally_available() -> bool:
    if _active_chapter_id == CHAPTER_CH09B:
        return true
    if _active_chapter_id != CHAPTER_CH10:
        return false
    return _active_stage_index <= 0

func _chapter_rank(chapter_id: StringName) -> int:
    return CampaignChapterRegistry.get_rank(chapter_id)

func debug_seed_chapter_camp(chapter_id: StringName, stage_index: int, stage: StageData) -> void:
    _active_chapter_id = chapter_id
    _active_stage_index = stage_index
    _current_stage = stage

    match chapter_id:
        CHAPTER_CH01:
            _enter_camp_state()
        CHAPTER_CH02:
            _enter_chapter_two_camp()
        CHAPTER_CH03:
            _enter_chapter_three_camp()
        CHAPTER_CH04:
            _enter_chapter_four_camp()
        CHAPTER_CH05:
            _enter_chapter_five_camp()
        CHAPTER_CH06:
            _enter_chapter_six_camp()
        CHAPTER_CH07:
            _enter_chapter_seven_camp()
        CHAPTER_CH08:
            _enter_chapter_eight_camp()
        CHAPTER_CH09A:
            _enter_chapter_nine_a_camp()
        CHAPTER_CH09B:
            _enter_chapter_nine_b_camp()
        CHAPTER_CH10:
            _enter_chapter_ten_resolution()
        _:
            _enter_chapter_complete_state()

func debug_unlock_accessory_ids(ids: Array) -> void:
    for accessory_id in ids:
        var typed_id: StringName = accessory_id
        _add_owned_item("accessory", typed_id)

func debug_unlock_weapon_ids(ids: Array) -> void:
    for weapon_id in ids:
        var typed_id: StringName = weapon_id
        _add_owned_item("weapon", typed_id)

func debug_unlock_armor_ids(ids: Array) -> void:
    for armor_id in ids:
        var typed_id: StringName = armor_id
        _add_owned_item("armor", typed_id)

func _build_runtime_ally_spawns(stage: StageData) -> Array[Vector2i]:
    var spawns: Array[Vector2i] = stage.ally_spawns.duplicate()
    var required_count: int = stage.ally_units.size()
    if spawns.size() >= required_count:
        return spawns

    var taken: Dictionary = {}
    for cell in spawns:
        taken[cell] = true
    for cell in stage.enemy_spawns:
        taken[cell] = true
    for cell in stage.blocked_cells:
        taken[cell] = true

    var anchor: Vector2i = spawns[spawns.size() - 1] if not spawns.is_empty() else Vector2i.ZERO
    var offsets: Array[Vector2i] = [
        Vector2i(1, 0),
        Vector2i(-1, 0),
        Vector2i(0, -1),
        Vector2i(1, -1),
        Vector2i(-1, -1),
        Vector2i(0, 1),
        Vector2i(1, 1),
        Vector2i(-1, 1)
    ]

    for offset in offsets:
        if spawns.size() >= required_count:
            break
        var candidate: Vector2i = anchor + offset
        if candidate.x < 0 or candidate.y < 0 or candidate.x >= stage.grid_size.x or candidate.y >= stage.grid_size.y:
            continue
        if taken.has(candidate):
            continue
        taken[candidate] = true
        spawns.append(candidate)

    return spawns

func _stringify_unit_ids(unit_ids: Array[StringName]) -> Array[String]:
    var values: Array[String] = []
    for unit_id in unit_ids:
        values.append(String(unit_id))
    return values

func assign_unit_to_sortie(unit_id: StringName) -> void:
    if unit_id == &"ally_rian":
        return
    if not _is_recruit_unlocked(unit_id):
        return

    _normalize_deployed_party_ids()
    if _deployed_party_unit_ids.has(unit_id):
        return

    if _deployed_party_unit_ids.size() < _get_deployment_limit():
        _deployed_party_unit_ids.append(unit_id)
    else:
        var replace_index: int = _find_replaceable_deployed_index()
        _deployed_party_unit_ids[replace_index] = unit_id

    _normalize_deployed_party_ids()
    if _campaign_panel != null:
        _campaign_panel.show_state(
            _active_mode,
            _current_panel_title,
            _current_panel_body,
            _campaign_panel.advance_button.text,
            _build_panel_payload(_active_mode)
        )

func cycle_accessory_for_unit(unit_id: StringName) -> void:
    if not _is_recruit_unlocked(unit_id):
        return

    var available_ids: Array[StringName] = _get_available_accessory_ids()
    if available_ids.is_empty():
        return

    var current_id: StringName = StringName(_equipped_accessory_by_unit_id.get(String(unit_id), ""))
    var next_index: int = 0
    if current_id != StringName() and available_ids.has(current_id):
        next_index = (available_ids.find(current_id) + 1) % available_ids.size()
    var next_id: StringName = StringName(available_ids[next_index])
    _equipped_accessory_by_unit_id[String(unit_id)] = String(next_id)

    if _campaign_panel != null:
        _campaign_panel.show_state(
            _active_mode,
            _current_panel_title,
            _current_panel_body,
            _campaign_panel.advance_button.text,
            _build_panel_payload(_active_mode)
        )

func set_accessory_for_unit(unit_id: StringName, accessory_id: StringName) -> void:
    if not _is_recruit_unlocked(unit_id):
        return
    var available_ids: Array[StringName] = _get_available_accessory_ids()
    if not available_ids.has(accessory_id) or _get_assignable_owned_count("accessory", accessory_id, unit_id) <= 0:
        return
    _equipped_accessory_by_unit_id[String(unit_id)] = String(accessory_id)
    _refresh_camp_panel_state()

func _correct_accessory_choice_for_unit(unit_id: StringName) -> void:
    if not _is_recruit_unlocked(unit_id):
        return
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null or not ReforgeService.can_afford_accessory_reforge(progression_data):
        return
    var available_ids: Array[StringName] = _get_available_accessory_ids()
    var current_id: StringName = StringName(_equipped_accessory_by_unit_id.get(String(unit_id), ""))
    if not ReforgeService.can_correct_accessory_choice(current_id, available_ids):
        return
    var next_id: StringName = ReforgeService.get_corrected_accessory_choice(current_id, available_ids)
    if next_id == StringName() or next_id == current_id:
        return
    if not ReforgeService.consume_accessory_reforge_cost(progression_data):
        return
    _equipped_accessory_by_unit_id[String(unit_id)] = String(next_id)
    var before_name: String = current_id
    if current_id != StringName():
        var current_data: AccessoryData = _get_accessory_data_by_id(current_id)
        if current_data != null:
            before_name = current_data.display_name
    var next_data: AccessoryData = _get_accessory_data_by_id(next_id)
    var next_name: String = next_data.display_name if next_data != null else String(next_id)
    _append_unique_lines(_chapter_reward_entries, ["장신구 보정: %s -> %s" % [before_name if not before_name.is_empty() else "없음", next_name]])
    _refresh_camp_panel_state()

func _craft_recipe(recipe_id: StringName) -> bool:
    var progression_data: ProgressionData = _get_progression_data()
    if _forge_service == null or progression_data == null:
        return false
    _forge_service.configure(
        progression_data,
        Callable(self, "_is_item_owned"),
        Callable(self, "_unlock_crafted_item")
    )
    var crafted: bool = _forge_service.craft(recipe_id)
    if crafted:
        _append_unique_lines(_chapter_reward_entries, [_build_crafted_inventory_line(recipe_id)])
    return crafted

func cycle_weapon_for_unit(unit_id: StringName) -> void:
    if not _is_recruit_unlocked(unit_id):
        return
    var available_ids: Array[StringName] = _get_available_weapon_ids_for_unit(unit_id)
    if available_ids.is_empty():
        return
    var current_id: StringName = StringName(_equipped_weapon_by_unit_id.get(String(unit_id), ""))
    var next_index: int = 0
    if current_id != StringName() and available_ids.has(current_id):
        next_index = (available_ids.find(current_id) + 1) % available_ids.size()
    var next_id: StringName = available_ids[next_index]
    _equipped_weapon_by_unit_id[String(unit_id)] = String(next_id)
    if _campaign_panel != null:
        _campaign_panel.show_state(_active_mode, _current_panel_title, _current_panel_body, _campaign_panel.advance_button.text, _build_panel_payload(_active_mode))

func set_weapon_for_unit(unit_id: StringName, weapon_id: StringName) -> void:
    if not _is_recruit_unlocked(unit_id):
        return
    var available_ids: Array[StringName] = _get_available_weapon_ids_for_unit(unit_id)
    if not available_ids.has(weapon_id):
        return
    _equipped_weapon_by_unit_id[String(unit_id)] = String(weapon_id)
    _refresh_camp_panel_state()

func cycle_armor_for_unit(unit_id: StringName) -> void:
    if not _is_recruit_unlocked(unit_id):
        return
    var available_ids: Array[StringName] = _get_available_armor_ids_for_unit(unit_id)
    if available_ids.is_empty():
        return
    var current_id: StringName = StringName(_equipped_armor_by_unit_id.get(String(unit_id), ""))
    var next_index: int = 0
    if current_id != StringName() and available_ids.has(current_id):
        next_index = (available_ids.find(current_id) + 1) % available_ids.size()
    var next_id: StringName = available_ids[next_index]
    _equipped_armor_by_unit_id[String(unit_id)] = String(next_id)
    if _campaign_panel != null:
        _campaign_panel.show_state(_active_mode, _current_panel_title, _current_panel_body, _campaign_panel.advance_button.text, _build_panel_payload(_active_mode))

func set_armor_for_unit(unit_id: StringName, armor_id: StringName) -> void:
    if not _is_recruit_unlocked(unit_id):
        return
    var available_ids: Array[StringName] = _get_available_armor_ids_for_unit(unit_id)
    if not available_ids.has(armor_id):
        return
    _equipped_armor_by_unit_id[String(unit_id)] = String(armor_id)
    _refresh_camp_panel_state()

func _on_deployment_assignment_requested(unit_id: StringName) -> void:
    assign_unit_to_sortie(unit_id)

func _on_weapon_cycle_requested(unit_id: StringName) -> void:
    cycle_weapon_for_unit(unit_id)

func _on_weapon_selected_requested(unit_id: StringName, weapon_id: StringName) -> void:
    set_weapon_for_unit(unit_id, weapon_id)

func _on_weapon_unequip_requested(unit_id: StringName) -> void:
    _equipped_weapon_by_unit_id.erase(String(unit_id))
    _refresh_camp_panel_state()

func _on_weapon_sell_requested(unit_id: StringName) -> void:
    _sell_equipped_item(unit_id, "weapon")

func _on_inventory_weapon_sell_requested(weapon_id: StringName) -> void:
    _sell_owned_item_by_id("weapon", weapon_id)

func _on_armor_cycle_requested(unit_id: StringName) -> void:
    cycle_armor_for_unit(unit_id)

func _on_armor_selected_requested(unit_id: StringName, armor_id: StringName) -> void:
    set_armor_for_unit(unit_id, armor_id)

func _on_armor_unequip_requested(unit_id: StringName) -> void:
    _equipped_armor_by_unit_id.erase(String(unit_id))
    _refresh_camp_panel_state()

func _on_armor_sell_requested(unit_id: StringName) -> void:
    _sell_equipped_item(unit_id, "armor")

func _on_inventory_armor_sell_requested(armor_id: StringName) -> void:
    _sell_owned_item_by_id("armor", armor_id)

func _on_accessory_cycle_requested(unit_id: StringName) -> void:
    cycle_accessory_for_unit(unit_id)

func _on_accessory_selected_requested(unit_id: StringName, accessory_id: StringName) -> void:
    set_accessory_for_unit(unit_id, accessory_id)

func _on_accessory_unequip_requested(unit_id: StringName) -> void:
    _equipped_accessory_by_unit_id.erase(String(unit_id))
    _refresh_camp_panel_state()

func _on_accessory_sell_requested(unit_id: StringName) -> void:
    _sell_equipped_item(unit_id, "accessory")

func _on_inventory_accessory_sell_requested(accessory_id: StringName) -> void:
    _sell_owned_item_by_id("accessory", accessory_id)

func _on_accessory_reforge_requested(unit_id: StringName) -> void:
    _correct_accessory_choice_for_unit(unit_id)

func _on_forge_craft_requested(recipe_id: StringName) -> void:
    if _craft_recipe(recipe_id):
        _refresh_camp_panel_state()

func apply_hunt_victory_to_current_camp(hunt_id: StringName) -> bool:
    if _camp_controller == null:
        return false
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null:
        return false
    var hunt_battle_result: Dictionary = _battle_controller.get_last_result_summary() if _battle_controller != null else {}
    var hunt_result: Dictionary = _camp_controller.resolve_hunt_victory(hunt_id, progression_data, hunt_battle_result)
    if hunt_result.is_empty():
        return false
    if _current_stage != null:
        _append_unique_lines(_chapter_reward_entries, _variant_to_string_array(hunt_result.get("reward_entries", [])))
    if _active_mode == CampaignState.MODE_CAMP:
        _camp_controller.enter_camp(StringName(String(_active_chapter_id).to_lower()), hunt_result, progression_data)
        _camp_controller.select_hunt(hunt_id)
        _refresh_camp_panel_state()
    return true

func _get_available_weapon_ids() -> Array[StringName]:
    var available: Array[StringName] = []
    for weapon_id in _get_owned_item_ids("weapon"):
        if _get_weapon_data_by_id(weapon_id) != null:
            available.append(weapon_id)
    return available

func _get_available_armor_ids() -> Array[StringName]:
    var available: Array[StringName] = []
    for armor_id in _get_owned_item_ids("armor"):
        if _get_armor_data_by_id(armor_id) != null:
            available.append(armor_id)
    return available

func _get_available_weapon_ids_for_unit(unit_id: StringName) -> Array[StringName]:
    var available: Array[StringName] = []
    var unit_data: UnitData = _get_unit_data_by_id(unit_id)
    if unit_data == null:
        return available
    for weapon_id in _get_available_weapon_ids():
        var weapon: WeaponData = _get_weapon_data_by_id(weapon_id)
        if weapon != null and String(weapon.weapon_type) in unit_data.get_allowed_weapon_types() and _get_assignable_owned_count("weapon", weapon_id, unit_id) > 0:
            available.append(weapon_id)
    return available

func _get_available_armor_ids_for_unit(unit_id: StringName) -> Array[StringName]:
    var available: Array[StringName] = []
    var unit_data: UnitData = _get_unit_data_by_id(unit_id)
    if unit_data == null:
        return available
    for armor_id in _get_available_armor_ids():
        var armor: ArmorData = _get_armor_data_by_id(armor_id)
        if armor != null and String(armor.armor_type) in unit_data.get_allowed_armor_types() and _get_assignable_owned_count("armor", armor_id, unit_id) > 0:
            available.append(armor_id)
    return available

func _get_available_accessory_ids() -> Array[StringName]:
    var available: Array[StringName] = []
    for accessory_id in _get_owned_item_ids("accessory"):
        if _get_accessory_data_by_id(accessory_id) != null:
            available.append(accessory_id)
    return available

func _packed_array_to_string_array(values: PackedStringArray) -> Array[String]:
    var result: Array[String] = []
    for value in values:
        result.append(String(value))
    return result

func _get_weapon_preview_path(weapon_id: StringName) -> String:
    return CampaignCatalog.get_weapon_preview_path(weapon_id)

func _get_armor_preview_path(armor_id: StringName) -> String:
    return CampaignCatalog.get_armor_preview_path(armor_id)

func _get_accessory_preview_path(_accessory_id: StringName) -> String:
    return CampaignCatalog.get_accessory_preview_path(_accessory_id)

func _build_weapon_inventory_lines() -> Array[String]:
    var lines: Array[String] = []
    for weapon_id in _get_available_weapon_ids():
        var weapon: WeaponData = _get_weapon_data_by_id(weapon_id)
        if weapon == null:
            continue
        var count: int = _get_owned_item_count("weapon", weapon.weapon_id)
        var equipped_units: Array[String] = _find_equipped_weapon_unit_names(weapon.weapon_id)
        var suffix: String = _build_owned_item_suffix(count, equipped_units)
        lines.append("Weapon: %s x%d — %s%s" % [weapon.display_name, count, weapon.summary, suffix])
    return lines

func _build_armor_inventory_lines() -> Array[String]:
    var lines: Array[String] = []
    for armor_id in _get_available_armor_ids():
        var armor: ArmorData = _get_armor_data_by_id(armor_id)
        if armor == null:
            continue
        var count: int = _get_owned_item_count("armor", armor.armor_id)
        var equipped_units: Array[String] = _find_equipped_armor_unit_names(armor.armor_id)
        var suffix: String = _build_owned_item_suffix(count, equipped_units)
        lines.append("Armor: %s x%d — %s%s" % [armor.display_name, count, armor.summary, suffix])
    return lines

func _build_accessory_inventory_lines() -> Array[String]:
    var lines: Array[String] = []
    for accessory_id in _get_available_accessory_ids():
        var accessory: AccessoryData = _get_accessory_data_by_id(accessory_id)
        if accessory == null:
            continue
        var count: int = _get_owned_item_count("accessory", accessory.accessory_id)
        var equipped_units: Array[String] = _find_equipped_accessory_unit_names(accessory.accessory_id)
        var suffix: String = _build_owned_item_suffix(count, equipped_units)
        var detail_parts: Array[String] = []
        var summary_text := String(accessory.summary).strip_edges()
        var flavor_text := _get_accessory_flavor_text(accessory)
        if not summary_text.is_empty():
            detail_parts.append(summary_text)
        if not flavor_text.is_empty() and flavor_text != summary_text:
            detail_parts.append(flavor_text)
        var detail_text := " / ".join(detail_parts)
        if detail_text.is_empty():
            detail_text = accessory.display_name
        lines.append("%s x%d — %s%s" % [accessory.display_name, count, detail_text, suffix])
    return lines

func _get_accessory_flavor_text(accessory: AccessoryData) -> String:
    if accessory == null:
        return ""
    var flavor_text := String(accessory.flavor_text).strip_edges()
    if not flavor_text.is_empty():
        return flavor_text
    return String(accessory.summary).strip_edges()

func _build_weapon_option_entries(weapon_ids: Array[StringName]) -> Array[Dictionary]:
    var entries: Array[Dictionary] = []
    for weapon_id in weapon_ids:
        var weapon: WeaponData = _get_weapon_data_by_id(weapon_id)
        if weapon == null:
            continue
        entries.append({
            "item_id": String(weapon_id),
            "label": weapon.display_name
        })
    return entries

func _build_armor_option_entries(armor_ids: Array[StringName]) -> Array[Dictionary]:
    var entries: Array[Dictionary] = []
    for armor_id in armor_ids:
        var armor: ArmorData = _get_armor_data_by_id(armor_id)
        if armor == null:
            continue
        entries.append({
            "item_id": String(armor_id),
            "label": armor.display_name
        })
    return entries

func _build_accessory_option_entries(accessory_ids: Array[StringName]) -> Array[Dictionary]:
    var entries: Array[Dictionary] = []
    for accessory_id in accessory_ids:
        var accessory: AccessoryData = _get_accessory_data_by_id(accessory_id)
        if accessory == null:
            continue
        entries.append({
            "item_id": String(accessory_id),
            "label": accessory.display_name
        })
    return entries

func _build_sell_tooltip(slot_kind: String, item) -> String:
    if item == null:
        return "판매할 장비가 없다."
    return "%s 판매: +%dG" % [String(item.display_name), _get_sell_price(slot_kind, item)]

func _build_inventory_sell_option(slot_kind: String) -> Dictionary:
    var options := _build_inventory_sell_options(slot_kind)
    return options[0] if not options.is_empty() else {}

func _build_inventory_sell_options(slot_kind: String) -> Array[Dictionary]:
    var options: Array[Dictionary] = []
    match slot_kind:
        "weapon":
            for weapon_id in _get_available_weapon_ids():
                if _get_unequipped_owned_count("weapon", weapon_id) <= 0:
                    continue
                var weapon: WeaponData = _get_weapon_data_by_id(weapon_id)
                if weapon == null:
                    continue
                options.append({
                    "item_id": String(weapon_id),
                    "label": _build_inventory_stack_label("weapon", weapon.display_name, weapon_id),
                    "tooltip": _build_sell_tooltip(slot_kind, weapon)
                })
        "armor":
            for armor_id in _get_available_armor_ids():
                if _get_unequipped_owned_count("armor", armor_id) <= 0:
                    continue
                var armor: ArmorData = _get_armor_data_by_id(armor_id)
                if armor == null:
                    continue
                options.append({
                    "item_id": String(armor_id),
                    "label": _build_inventory_stack_label("armor", armor.display_name, armor_id),
                    "tooltip": _build_sell_tooltip(slot_kind, armor)
                })
        "accessory":
            for accessory_id in _get_available_accessory_ids():
                if _get_unequipped_owned_count("accessory", accessory_id) <= 0:
                    continue
                var accessory: AccessoryData = _get_accessory_data_by_id(accessory_id)
                if accessory == null:
                    continue
                options.append({
                    "item_id": String(accessory_id),
                    "label": _build_inventory_stack_label("accessory", accessory.display_name, accessory_id),
                    "tooltip": _build_sell_tooltip(slot_kind, accessory)
                })
    return options

func _build_inventory_stack_label(slot_kind: String, display_name: String, item_id: StringName) -> String:
    var total_count: int = _get_owned_item_count(slot_kind, item_id)
    var equipped_count: int = _get_equipped_item_count(slot_kind, item_id)
    var unequipped_count: int = max(0, total_count - equipped_count)
    return "%s x%d (미장착 %d / 장착 %d)" % [display_name, total_count, unequipped_count, equipped_count]

func _get_sell_price(slot_kind: String, item) -> int:
    if item == null:
        return 0
    match slot_kind:
        "weapon":
            return 120 + int(item.attack_bonus) * 40 + int(item.defense_bonus) * 20 + int(item.movement_bonus) * 30
        "armor":
            return 100 + int(item.defense_bonus) * 45 + int(item.attack_bonus) * 15 + int(item.movement_bonus) * 25
        "accessory":
            return 80 + int(item.attack_bonus) * 35 + int(item.defense_bonus) * 35 + int(item.movement_bonus) * 40
        _:
            return 0

func _remove_unlocked_item(output_type: String, item_id: StringName) -> void:
    if item_id == &"":
        return
    _consume_owned_item(output_type, item_id)

func _sell_equipped_item(unit_id: StringName, slot_kind: String) -> bool:
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null:
        return false
    match slot_kind:
        "weapon":
            var equipped_weapon_id: StringName = StringName(_equipped_weapon_by_unit_id.get(String(unit_id), ""))
            var weapon: WeaponData = _get_weapon_data_by_id(equipped_weapon_id)
            if weapon == null:
                return false
            var weapon_price: int = _get_sell_price(slot_kind, weapon)
            progression_data.add_gold(weapon_price)
            _append_unique_lines(_chapter_reward_entries, ["판매: %s +%dG" % [weapon.display_name, weapon_price]])
            _consume_owned_item("weapon", equipped_weapon_id)
            _equipped_weapon_by_unit_id.erase(String(unit_id))
            _refresh_camp_panel_state()
            return true
        "armor":
            var equipped_armor_id: StringName = StringName(_equipped_armor_by_unit_id.get(String(unit_id), ""))
            var armor: ArmorData = _get_armor_data_by_id(equipped_armor_id)
            if armor == null:
                return false
            var armor_price: int = _get_sell_price(slot_kind, armor)
            progression_data.add_gold(armor_price)
            _append_unique_lines(_chapter_reward_entries, ["판매: %s +%dG" % [armor.display_name, armor_price]])
            _consume_owned_item("armor", equipped_armor_id)
            _equipped_armor_by_unit_id.erase(String(unit_id))
            _refresh_camp_panel_state()
            return true
        "accessory":
            var equipped_accessory_id: StringName = StringName(_equipped_accessory_by_unit_id.get(String(unit_id), ""))
            var accessory: AccessoryData = _get_accessory_data_by_id(equipped_accessory_id)
            if accessory == null:
                return false
            var accessory_price: int = _get_sell_price(slot_kind, accessory)
            progression_data.add_gold(accessory_price)
            _append_unique_lines(_chapter_reward_entries, ["판매: %s +%dG" % [accessory.display_name, accessory_price]])
            _consume_owned_item("accessory", equipped_accessory_id)
            _equipped_accessory_by_unit_id.erase(String(unit_id))
            _refresh_camp_panel_state()
            return true
    return false

func _sell_owned_item_by_id(slot_kind: String, item_id: StringName) -> bool:
    if item_id == &"":
        return false
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data == null:
        return false
    match slot_kind:
        "weapon":
            if _get_unequipped_owned_count("weapon", item_id) <= 0:
                return false
            var weapon: WeaponData = _get_weapon_data_by_id(item_id)
            if weapon == null:
                return false
            var weapon_price: int = _get_sell_price(slot_kind, weapon)
            progression_data.add_gold(weapon_price)
            _append_unique_lines(_chapter_reward_entries, ["판매: %s +%dG" % [weapon.display_name, weapon_price]])
            _consume_owned_item("weapon", item_id)
            _refresh_camp_panel_state()
            return true
        "armor":
            if _get_unequipped_owned_count("armor", item_id) <= 0:
                return false
            var armor: ArmorData = _get_armor_data_by_id(item_id)
            if armor == null:
                return false
            var armor_price: int = _get_sell_price(slot_kind, armor)
            progression_data.add_gold(armor_price)
            _append_unique_lines(_chapter_reward_entries, ["판매: %s +%dG" % [armor.display_name, armor_price]])
            _consume_owned_item("armor", item_id)
            _refresh_camp_panel_state()
            return true
        "accessory":
            if _get_unequipped_owned_count("accessory", item_id) <= 0:
                return false
            var accessory: AccessoryData = _get_accessory_data_by_id(item_id)
            if accessory == null:
                return false
            var accessory_price: int = _get_sell_price(slot_kind, accessory)
            progression_data.add_gold(accessory_price)
            _append_unique_lines(_chapter_reward_entries, ["판매: %s +%dG" % [accessory.display_name, accessory_price]])
            _consume_owned_item("accessory", item_id)
            _refresh_camp_panel_state()
            return true
    return false

func _get_owned_item_ids(slot_kind: String) -> Array[StringName]:
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data != null:
        var owned_ids: Array[StringName] = progression_data.get_owned_item_ids(StringName(slot_kind))
        if not owned_ids.is_empty():
            return owned_ids
    match slot_kind:
        "weapon":
            return _unlocked_weapon_ids.duplicate()
        "armor":
            return _unlocked_armor_ids.duplicate()
        "accessory":
            return _unlocked_accessory_ids.duplicate()
        _:
            return []

func _get_owned_item_count(slot_kind: String, item_id: StringName) -> int:
    var progression_data: ProgressionData = _get_progression_data()
    if progression_data != null:
        return progression_data.get_owned_item_count(StringName(slot_kind), item_id)
    match slot_kind:
        "weapon":
            return 1 if _unlocked_weapon_ids.has(item_id) else 0
        "armor":
            return 1 if _unlocked_armor_ids.has(item_id) else 0
        "accessory":
            return 1 if _unlocked_accessory_ids.has(item_id) else 0
        _:
            return 0

func _add_owned_item(slot_kind: String, item_id: StringName, count: int = 1) -> int:
    if item_id == &"" or count <= 0:
        return _get_owned_item_count(slot_kind, item_id)
    var progression_data: ProgressionData = _get_progression_data()
    var next_count: int = 0
    if progression_data != null:
        next_count = progression_data.add_owned_item(StringName(slot_kind), item_id, count)
    else:
        next_count = _get_owned_item_count(slot_kind, item_id) + count
    _ensure_owned_item_cache(slot_kind, item_id, next_count > 0)
    return next_count

func _consume_owned_item(slot_kind: String, item_id: StringName, count: int = 1) -> bool:
    if item_id == &"" or count <= 0:
        return false
    var progression_data: ProgressionData = _get_progression_data()
    var ok: bool = false
    if progression_data != null:
        ok = progression_data.consume_owned_item(StringName(slot_kind), item_id, count)
    else:
        ok = _get_owned_item_count(slot_kind, item_id) >= count
    if not ok:
        return false
    _ensure_owned_item_cache(slot_kind, item_id, _get_owned_item_count(slot_kind, item_id) > 0)
    return true

func _ensure_owned_item_cache(slot_kind: String, item_id: StringName, owned: bool) -> void:
    match slot_kind:
        "weapon":
            if owned and not _unlocked_weapon_ids.has(item_id):
                _unlocked_weapon_ids.append(item_id)
            elif not owned:
                _unlocked_weapon_ids.erase(item_id)
        "armor":
            if owned and not _unlocked_armor_ids.has(item_id):
                _unlocked_armor_ids.append(item_id)
            elif not owned:
                _unlocked_armor_ids.erase(item_id)
        "accessory":
            if owned and not _unlocked_accessory_ids.has(item_id):
                _unlocked_accessory_ids.append(item_id)
            elif not owned:
                _unlocked_accessory_ids.erase(item_id)

func _get_equipped_item_count(slot_kind: String, item_id: StringName) -> int:
    if item_id == &"":
        return 0
    var total: int = 0
    match slot_kind:
        "weapon":
            for unit_id in _equipped_weapon_by_unit_id.keys():
                if StringName(_equipped_weapon_by_unit_id[unit_id]) == item_id:
                    total += 1
        "armor":
            for unit_id in _equipped_armor_by_unit_id.keys():
                if StringName(_equipped_armor_by_unit_id[unit_id]) == item_id:
                    total += 1
        "accessory":
            for unit_id in _equipped_accessory_by_unit_id.keys():
                if StringName(_equipped_accessory_by_unit_id[unit_id]) == item_id:
                    total += 1
    return total

func _get_assignable_owned_count(slot_kind: String, item_id: StringName, unit_id: StringName) -> int:
    var owned_count: int = _get_owned_item_count(slot_kind, item_id)
    var equipped_count: int = _get_equipped_item_count(slot_kind, item_id)
    var currently_equipped: StringName = &""
    match slot_kind:
        "weapon":
            currently_equipped = StringName(_equipped_weapon_by_unit_id.get(String(unit_id), ""))
        "armor":
            currently_equipped = StringName(_equipped_armor_by_unit_id.get(String(unit_id), ""))
        "accessory":
            currently_equipped = StringName(_equipped_accessory_by_unit_id.get(String(unit_id), ""))
    if currently_equipped == item_id:
        return owned_count - equipped_count + 1
    return owned_count - equipped_count

func _get_unequipped_owned_count(slot_kind: String, item_id: StringName) -> int:
    return max(0, _get_owned_item_count(slot_kind, item_id) - _get_equipped_item_count(slot_kind, item_id))

func _build_owned_item_suffix(total_count: int, equipped_units: Array[String]) -> String:
    var suffix_parts: Array[String] = []
    if not equipped_units.is_empty():
        suffix_parts.append("Equipped: %s" % ", ".join(equipped_units))
    if total_count > equipped_units.size():
        suffix_parts.append("Unequipped: %d" % max(0, total_count - equipped_units.size()))
    if suffix_parts.is_empty():
        return ""
    return " [%s]" % " / ".join(suffix_parts)

func _build_runtime_accessory_map() -> Dictionary:
    var result: Dictionary = {}
    for unit_id in _equipped_accessory_by_unit_id.keys():
        var accessory_id: StringName = StringName(_equipped_accessory_by_unit_id[unit_id])
        var accessory: AccessoryData = _get_accessory_data_by_id(accessory_id)
        if accessory != null:
            result[unit_id] = accessory
    return result

func _build_runtime_weapon_map() -> Dictionary:
    var result: Dictionary = {}
    for unit_id in _equipped_weapon_by_unit_id.keys():
        var weapon_id: StringName = StringName(_equipped_weapon_by_unit_id[unit_id])
        var weapon: WeaponData = _get_weapon_data_by_id(weapon_id)
        if weapon != null:
            result[unit_id] = weapon
    return result

func _build_runtime_armor_map() -> Dictionary:
    var result: Dictionary = {}
    for unit_id in _equipped_armor_by_unit_id.keys():
        var armor_id: StringName = StringName(_equipped_armor_by_unit_id[unit_id])
        var armor: ArmorData = _get_armor_data_by_id(armor_id)
        if armor != null:
            result[unit_id] = armor
    return result

func _find_equipped_unit_name(accessory_id: StringName) -> String:
    var names := _find_equipped_accessory_unit_names(accessory_id)
    return names[0] if not names.is_empty() else ""

func _find_equipped_accessory_unit_names(accessory_id: StringName) -> Array[String]:
    var names: Array[String] = []
    for unit_id in _equipped_accessory_by_unit_id.keys():
        if StringName(_equipped_accessory_by_unit_id[unit_id]) == accessory_id:
            var unit_data: UnitData = _get_unit_data_by_id(StringName(unit_id))
            if unit_data != null:
                names.append(unit_data.display_name)
    names.sort()
    return names

func _find_equipped_weapon_unit_name(weapon_id: StringName) -> String:
    var names := _find_equipped_weapon_unit_names(weapon_id)
    return names[0] if not names.is_empty() else ""

func _find_equipped_weapon_unit_names(weapon_id: StringName) -> Array[String]:
    var names: Array[String] = []
    for unit_id in _equipped_weapon_by_unit_id.keys():
        if StringName(_equipped_weapon_by_unit_id[unit_id]) == weapon_id:
            var unit_data: UnitData = _get_unit_data_by_id(StringName(unit_id))
            if unit_data != null:
                names.append(unit_data.display_name)
    names.sort()
    return names

func _find_equipped_armor_unit_name(armor_id: StringName) -> String:
    var names := _find_equipped_armor_unit_names(armor_id)
    return names[0] if not names.is_empty() else ""

func _find_equipped_armor_unit_names(armor_id: StringName) -> Array[String]:
    var names: Array[String] = []
    for unit_id in _equipped_armor_by_unit_id.keys():
        if StringName(_equipped_armor_by_unit_id[unit_id]) == armor_id:
            var unit_data: UnitData = _get_unit_data_by_id(StringName(unit_id))
            if unit_data != null:
                names.append(unit_data.display_name)
    names.sort()
    return names

func _find_replaceable_deployed_index() -> int:
    for index in range(_deployed_party_unit_ids.size()):
        if _deployed_party_unit_ids[index] != &"ally_rian":
            return index
    return max(0, _deployed_party_unit_ids.size() - 1)
