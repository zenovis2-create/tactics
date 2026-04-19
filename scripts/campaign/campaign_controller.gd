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
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const EndingResolver = preload("res://scripts/battle/ending_resolver.gd")
const SupportConversations = preload("res://data/support_conversations.gd")

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
var _briefing_abort_active: bool = false

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
    if _campaign_panel != null and not _campaign_panel.armor_cycle_requested.is_connected(_on_armor_cycle_requested):
        _campaign_panel.armor_cycle_requested.connect(_on_armor_cycle_requested)
    if _campaign_panel != null and not _campaign_panel.accessory_cycle_requested.is_connected(_on_accessory_cycle_requested):
        _campaign_panel.accessory_cycle_requested.connect(_on_accessory_cycle_requested)
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

    return {
        "mode": _active_mode,
        "chapter_id": _active_chapter_id,
        "flow_index": _active_stage_index,
        "flow_total": _get_active_stage_flow().size(),
        "current_stage_id": _current_stage.stage_id if _current_stage != null else StringName(),
        "current_stage_title": _current_stage.get_display_title() if _current_stage != null else "",
        "panel_title": panel_snapshot.get("title", _current_panel_title),
        "panel_body": panel_snapshot.get("body", _current_panel_body)
    }

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
    return stage_id == &"CH01_05" or stage_id == &"CH02_05" or stage_id == &"CH03_05" \
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
        String(briefing.get("chapter", "Mission Briefing")),
        _build_briefing_body(briefing),
        "Deploy"
    )

func _build_briefing_body(briefing: Dictionary) -> String:
    var lines: Array[String] = []
    var brief_text: String = String(briefing.get("brief_text", "")).strip_edges()
    if not brief_text.is_empty():
        lines.append(brief_text)
    lines.append("Turn Limit: %d" % int(briefing.get("turn_limit", 20)))
    return "\n".join(lines)

func _build_briefing_payload(briefing: Dictionary) -> Dictionary:
    return {
        "enemy_intel": _variant_to_string_array(briefing.get("enemy_intel", [])),
        "terrain_summary": _variant_to_string_array(briefing.get("terrain_summary", [])),
        "optional_objectives": _variant_to_string_array(briefing.get("optional_objectives", [])),
        "turn_limit": int(briefing.get("turn_limit", 20))
    }

func _build_briefing_abort_body(briefing: Dictionary) -> String:
    var chapter_label: String = String(briefing.get("chapter", "the target")).strip_edges()
    return "Deployment aborted. The squad falls back to field camp outside %s. Re-check the roster, gear, and known intel before returning to the mission briefing." % chapter_label

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
        "%s Field Camp" % String(briefing.get("chapter", "Mission Briefing")),
        _build_briefing_abort_body(briefing),
        "Return to Briefing"
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
        "Continue to Next Stage"
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
    _autosave_progression()
    _set_panel_state(
        CampaignState.MODE_CAMP,
        "CH01 Interlude Camp",
        _build_camp_summary(),
        "Next Battle"
    )

func _autosave_progression() -> void:
    if _save_service == null or _battle_controller == null:
        return
    var prog_svc = _battle_controller.progression_service
    if prog_svc == null:
        return
    var data: ProgressionData = prog_svc.get_data()
    if data != null:
        if _battle_controller.bond_service != null:
            _battle_controller.bond_service.export_to_progression(data)
        _save_service.save_progression(data, 0)  # 슬롯 0 = 자동저장

func _build_cutscene_summary(stage: StageData, next_stage: StageData) -> String:
    var lines: Array[String] = []
    if stage.clear_cutscene_id != StringName():
        lines.append("Clear cutscene: %s" % String(stage.clear_cutscene_id))
    lines.append("Stage clear: %s" % stage.get_display_title())
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
    lines.append("Next battle: %s" % next_stage.get_display_title())
    if not stage.next_destination_summary.is_empty():
        lines.append(stage.next_destination_summary)
    return "\n".join(lines)

func _build_camp_summary() -> String:
    var lines: Array[String] = [
        "Interlude cutscene: ch01_interlude_camp",
        "Serin is now locked in as an ally for the Chapter 1 handoff.",
        "First memory fragment recovered: mem_frag_ch01_first_order.",
        "Hardren seal evidence confirms the first border trail north.",
        "Next destination: move north toward the first campaign evidence trail."
    ]

    var progression_data: ProgressionData = null
    if _battle_controller != null and _battle_controller.progression_service != null:
        progression_data = _battle_controller.progression_service.get_data()
    if progression_data != null:
        lines.append("Burden / Trust: %d / %d" % [progression_data.burden, progression_data.trust])
        lines.append("Ending tendency: %s" % String(progression_data.ending_tendency))
        lines.append("Recovered fragments: %d" % progression_data.recovered_fragments.size())
        lines.append("Recovered fragment ids: %s" % ", ".join(progression_data.get_recovered_fragment_ids()))
        lines.append("Unlocked commands: %d" % progression_data.unlocked_commands.size())
        lines.append("Unlocked command ids: %s" % ", ".join(progression_data.get_unlocked_command_ids()))

    if _current_stage != null and not _current_stage.next_destination_summary.is_empty():
        lines.append(_current_stage.next_destination_summary)

    return "\n".join(lines)

func _build_ch02_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch02_broken_border_fortress",
        "Hardren still stands under smoke and broken watchfires.",
        "Bran's remaining knights are boxed in behind the outer gate.",
        "Accessory and treasure loops stay locked as future Chapter 2 work; this shell only opens the next battlefield."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH02_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch02_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch02_hardren_camp",
        "Bran joins the active roster under open suspicion.",
        "Hardren blueprint memory recovered.",
        "Tracking orders now point the march toward Greenwood."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH02_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch03_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch03_whispering_greenwood",
        "The Greenwood trail is alive with traps, smoke, and people moving under cover.",
        "Tia's line watches the squad before choosing whether to help or hunt them."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH03_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch03_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch03_greenwood_camp",
        "Tia joins the active roster under an uneasy truce.",
        "The forest fire order memory is now recovered.",
        "Monastery manifests point the next route toward the drowned cloister."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH03_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch04_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch04_sunken_monastery",
        "The monastery is half drowned, and the only way forward is through controlled water and sealed records.",
        "Serin knows the place by prayer, but the surviving machinery reads like an experiment ledger."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH04_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch04_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch04_sunken_monastery_camp",
        "Ark research memory recovered.",
        "Archive transfer evidence secured.",
        "The next route points toward the Gray Archive."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH04_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch05_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch05_gray_archive",
        "The Gray Archive is already burning, but the surviving ledgers still point toward the core truth.",
        "Enoch is somewhere inside the sealed stacks, and the trail cannot wait."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH05_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch05_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch05_gray_archive_camp",
        "Enoch joins the active roster.",
        "Zero memory recovered with visible record edits.",
        "Valtor siege ledgers now point the march toward the iron fortress."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH05_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch06_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch06_valtor_iron_keep",
        "Valtor still stands as a machine of siege math, guilt, and surviving names.",
        "Bran's old fortress is now the next proof that the war was engineered in layers."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH06_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch06_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch06_valtor_camp",
        "The Valtor breach context is recovered, revealing how the original route was tightened into slaughter after it was drawn.",
        "With Ellyor relief edicts and civilian transfer rolls secured, the squad finally has a clear next target.",
        "The march now turns toward Ellyor and the purification rite waiting there."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH06_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch07_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch07_city_without_names",
        "Ellyor is turning grief into order through queues, hymns, and exhausted citizens asking to forget.",
        "Mira and Neri are somewhere inside that system, and the next forest trail already moves behind it."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH07_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch07_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch07_ellyor_camp",
        "The memory of Karuon naming Zero is recovered, giving Ellyor's doctrine a personal origin.",
        "With black-hound orders and hidden-ruin coordinates secured, the squad can finally trace where the next pursuit begins.",
        "The trail now leaves Ellyor behind and turns toward Lete's forest ruins."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH07_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch08_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch08_black_hound_night",
        "The black-hound trail runs back into the forest, but now every step points toward a hidden ruin and a personal loss.",
        "Tia is no longer chasing only vengeance; she is chasing the last clear truth about what happened here."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH08_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch08_camp_summary() -> String:
    var lines: Array[String] = [
        "Chapter interlude: ch08_black_hound_camp",
        "The north-corridor context is recovered, revealing how the original route narrowed into capture and purge.",
        "Kyle's outer-line orders and transfer slips are secured, so the forest trail no longer ends in rumor.",
        "The pursuit now runs straight from Lete's ruins to Kyle's defense line around the capital."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH08_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch09a_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch09a_broken_standard",
        "The capital outer line has become a filter for testimony, survivors, and anyone still carrying names into the city.",
        "Kyle stands on the wrong side of that line, but not for much longer."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH09A_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch09a_camp_summary() -> String:
    var lines: Array[String] = [
        "Part I interlude: ch09a_broken_standard_camp",
        "The returning-names memory is recovered, and Kyle's testimony now matches what the squad has been uncovering in fragments.",
        "With Kyle's testimony and root-archive pass secured, the capital is no longer sealed against them.",
        "The next route leads inward to the root archive, where the last keeper is waiting."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH09A_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch09b_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch09b_abyss_of_record",
        "The root archive is no longer a military front. It is a machine for deciding what history is allowed to remain.",
        "Noah waits at its edge, and Melkion has already begun editing the battlefield itself."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH09B_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch09b_camp_summary() -> String:
    var lines: Array[String] = [
        "Part II interlude: ch09b_record_abyss_camp",
        "The final restored memory is recovered, revealing both Rian's complicity and the path he left behind.",
        "Eclipse coordinates and the tower lattice are now in hand.",
        "The route now rises straight to the final tower."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH09B_INTERLUDE_DIALOGUE)
    return "\n".join(lines)

func _build_ch10_intro_summary() -> String:
    var lines: Array[String] = [
        "Chapter intro: ch10_nameless_tower",
        "The final tower is no longer about finding truth. It is about choosing what survives once the truth is known.",
        "The eclipse coordinates, tower lattice, and last decree all converge into a final ascent."
    ]
    _append_unique_lines(lines, CampaignContentRegistry.CH10_INTRO_DIALOGUE)
    return "\n".join(lines)

func _build_ch10_resolution_summary(ending_type: StringName) -> String:
    var lines: Array[String] = [
        "Final resolution: ch10_last_name",
        "Karuon falls, the bell stops, and the campaign resolves around memory kept shared instead of erased.",
        "The tower no longer decides what counts; the survivors do."
    ]
    if ending_type == EndingResolver.ENDING_TRUE:
        lines.append("True ending reached: every bond held long enough for the final memory to stay shared.")
    else:
        lines.append("Normal ending reached: the bell is gone, and the survivors carry the future forward from here.")
    _append_unique_lines(lines, CampaignContentRegistry.CH10_RESOLUTION_DIALOGUE)
    return "\n".join(lines)

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
        "CH02 Broken Border Fortress",
        _build_ch02_intro_summary(),
        "Enter Border Smoke"
    )

func _start_chapter_two_flow() -> void:
    _active_chapter_id = CHAPTER_CH02
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_three_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH03 Whispering Greenwood",
        _build_ch03_intro_summary(),
        "Enter Lost Forest"
    )

func _start_chapter_three_flow() -> void:
    _active_chapter_id = CHAPTER_CH03
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_four_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH04 Sunken Monastery",
        _build_ch04_intro_summary(),
        "Enter Flooded Cloister"
    )

func _start_chapter_four_flow() -> void:
    _active_chapter_id = CHAPTER_CH04
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_five_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH05 Gray Archive",
        _build_ch05_intro_summary(),
        "Enter Ash Gate"
    )

func _start_chapter_five_flow() -> void:
    _active_chapter_id = CHAPTER_CH05
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_six_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH06 Iron Keep of Valtor",
        _build_ch06_intro_summary(),
        "Enter Beyond the Smoke"
    )

func _start_chapter_six_flow() -> void:
    _active_chapter_id = CHAPTER_CH06
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_seven_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH07 City Without Names",
        _build_ch07_intro_summary(),
        "Enter Blank Market"
    )

func _start_chapter_seven_flow() -> void:
    _active_chapter_id = CHAPTER_CH07
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_eight_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH08 Night of the Black Hounds",
        _build_ch08_intro_summary(),
        "Enter Vanished Trail"
    )

func _start_chapter_eight_flow() -> void:
    _active_chapter_id = CHAPTER_CH08
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_nine_a_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH09A Broken Standard",
        _build_ch09a_intro_summary(),
        "Enter Outer Defense Line"
    )

func _start_chapter_nine_a_flow() -> void:
    _active_chapter_id = CHAPTER_CH09A
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_nine_b_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH09B Abyss of Record",
        _build_ch09b_intro_summary(),
        "Enter Root Gate"
    )

func _start_chapter_nine_b_flow() -> void:
    _active_chapter_id = CHAPTER_CH09B
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_ten_intro() -> void:
    _active_mode = CampaignState.MODE_CHAPTER_INTRO
    _set_panel_state(
        CampaignState.MODE_CHAPTER_INTRO,
        "CH10 Nameless Tower",
        _build_ch10_intro_summary(),
        "Enter Eclipse Eve"
    )

func _start_chapter_ten_flow() -> void:
    _active_chapter_id = CHAPTER_CH10
    _active_stage_index = 0
    _enter_stage(_active_stage_index)

func _enter_chapter_two_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH02 Hardren Interlude", _build_ch02_camp_summary(), "Next Battle")

func _enter_chapter_three_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH03 Greenwood Interlude", _build_ch03_camp_summary(), "Next Battle")

func _enter_chapter_four_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH04 Monastery Interlude", _build_ch04_camp_summary(), "Next Battle")

func _enter_chapter_five_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH05 Archive Interlude", _build_ch05_camp_summary(), "Next Battle")

func _enter_chapter_six_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH06 Valtor Interlude", _build_ch06_camp_summary(), "Next Battle")

func _enter_chapter_seven_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH07 Ellyor Interlude", _build_ch07_camp_summary(), "Next Battle")

func _enter_chapter_eight_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH08 Black Hound Interlude", _build_ch08_camp_summary(), "Next Battle")

func _enter_chapter_nine_a_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH09A Broken Standard Interlude", _build_ch09a_camp_summary(), "Next Battle")

func _enter_chapter_nine_b_camp() -> void:
    _active_mode = CampaignState.MODE_CAMP
    _autosave_progression()
    _set_panel_state(CampaignState.MODE_CAMP, "CH09B Record Abyss Interlude", _build_ch09b_camp_summary(), "Next Battle")

func _enter_chapter_ten_resolution() -> void:
    var ending_type: StringName = _resolve_current_ending()
    _mark_postgame_available(ending_type)
    _active_mode = CampaignState.MODE_COMPLETE
    _set_panel_state(
        CampaignState.MODE_COMPLETE,
        "CH10 Final Resolution",
        _build_ch10_resolution_summary(ending_type),
        "Return to Title"
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
    _autosave_progression()

func _enter_chapter_complete_state() -> void:
    _active_mode = CampaignState.MODE_COMPLETE
    var title_text: String = "Chapter Flow Complete"
    var body_text: String = "The active chapter shell is complete and ready for the next destination."
    if _active_chapter_id == CHAPTER_CH02:
        title_text = "Chapter 2 Shell Complete"
        body_text = "The Hardren shell is complete and ready for Greenwood."
    elif _active_chapter_id == CHAPTER_CH03:
        title_text = "Chapter 3 Shell Complete"
        body_text = "The Greenwood shell is complete and ready for the drowned monastery."
    elif _active_chapter_id == CHAPTER_CH04:
        title_text = "Chapter 4 Shell Complete"
        body_text = "The Sunken Monastery shell is complete and ready for the Gray Archive."
    elif _active_chapter_id == CHAPTER_CH05:
        title_text = "Chapter 5 Shell Complete"
        body_text = "The Gray Archive shell is complete and ready for Valtor."
    elif _active_chapter_id == CHAPTER_CH06:
        title_text = "Chapter 6 Shell Complete"
        body_text = "The Valtor shell is complete and ready for Ellyor."
    elif _active_chapter_id == CHAPTER_CH07:
        title_text = "Chapter 7 Shell Complete"
        body_text = "The Ellyor shell is complete and ready for the black-hound pursuit."
    elif _active_chapter_id == CHAPTER_CH08:
        title_text = "Chapter 8 Shell Complete"
        body_text = "The black-hound shell is complete and ready for Kyle's outer line."
    elif _active_chapter_id == CHAPTER_CH09A:
        title_text = "Chapter 9A Shell Complete"
        body_text = "The outer-line shell is complete and ready for the root archive."
    elif _active_chapter_id == CHAPTER_CH09B:
        title_text = "Chapter 9B Shell Complete"
        body_text = "The root-archive shell is complete and ready for the final tower."
    elif _active_chapter_id == CHAPTER_CH10:
        title_text = "Chapter 10 Shell Complete"
        body_text = "The final tower shell is complete and the campaign has reached resolution."
    _set_panel_state(CampaignState.MODE_COMPLETE, title_text, body_text, "Complete")

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
        var alerts: Array[String] = ["Boss stage ahead", "Deploy when ready"]
        var recommendation: String = "Review known enemy types, terrain, and optional objectives before deploying."
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
            "section_badges": {},
            "deployment_limit": _get_deployment_limit(),
            "deployed_party_unit_ids": _stringify_unit_ids(_deployed_party_unit_ids),
            "locked_party_unit_ids": ["ally_rian"],
            "available_weapon_entries": _build_weapon_inventory_lines(),
            "available_armor_entries": _build_armor_inventory_lines(),
            "available_accessory_entries": _build_accessory_inventory_lines(),
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
                dialogue_entries = CampaignContentRegistry.CH10_RESOLUTION_DIALOGUE.duplicate()
            presentation_cards = _build_camp_presentation_cards()
            if _camp_controller != null:
                var camp_summary := _camp_controller.get_camp_summary()
                if not camp_summary.is_empty():
                    camp_progression_alerts = _merge_unique_lines(camp_progression_alerts, [
                        "Burden %d / Trust %d" % [int(camp_summary.get("burden", 0)), int(camp_summary.get("trust", 0))],
                        "Fragments %d / Commands %d" % [int(camp_summary.get("recovered_fragments", 0)), int(camp_summary.get("unlocked_commands", 0))]
                    ])
    elif mode == CampaignState.MODE_COMPLETE and _active_chapter_id == CHAPTER_CH10:
        dialogue_entries = CampaignContentRegistry.CH10_RESOLUTION_DIALOGUE.duplicate()
        presentation_cards = _build_resolution_presentation_cards()

    var alerts: Array[String] = []
    var recommendation: String = "Review the current state and continue when ready."
    var active_section: String = CampaignPanel.SECTION_SUMMARY
    var selected_party_unit_id: String = ""
    var selected_forge_recipe_id: String = ""
    var section_badges: Dictionary = {}

    match mode:
        CampaignState.MODE_CUTSCENE:
            alerts = ["Battle clear", "Next stage unlocked"]
            recommendation = "Read the handoff, check party readiness, then continue to the next stage."
        CampaignState.MODE_CAMP:
            if _briefing_abort_active:
                alerts = ["Deployment aborted", "Field camp standing by"]
                recommendation = "Adjust party and gear if needed, then return to the mission briefing."
                active_section = CampaignPanel.SECTION_PARTY
            else:
                alerts = _build_camp_alerts(memory_entries, evidence_entries, letter_entries, inventory_entries)
                alerts = _merge_unique_lines(alerts, camp_progression_alerts)
                recommendation = _build_camp_recommendation(memory_entries, evidence_entries, letter_entries, inventory_entries)
                active_section = CampaignPanel.SECTION_RECORDS
                section_badges = _build_camp_section_badges(party_entries, inventory_entries, memory_entries, evidence_entries, letter_entries)
        CampaignState.MODE_COMPLETE:
            alerts = ["Chapter handoff complete"]
            recommendation = "The Chapter 1 shell is complete and ready for the next destination."
        _:
            alerts = ["Battle state active"]
            recommendation = "Complete the battle objective to unlock the next camp or story step."

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
        "section_badges": section_badges,
        "deployment_limit": _get_deployment_limit(),
        "deployed_party_unit_ids": _stringify_unit_ids(_deployed_party_unit_ids),
        "locked_party_unit_ids": ["ally_rian"],
        "available_weapon_entries": _build_weapon_inventory_lines(),
        "available_armor_entries": _build_armor_inventory_lines(),
        "available_accessory_entries": _build_accessory_inventory_lines(),
        "material_entries": _build_material_entries(),
        "forge_recipe_entries": _build_forge_recipe_entries()
    }

func _build_panel_flow_label(mode: String) -> String:
    match mode:
        CampaignState.MODE_BATTLE:
            return "Battle active -> Objective unresolved -> Camp"
        CampaignState.MODE_CUTSCENE:
            return "Battle clear -> Story handoff -> Next stage"
        CampaignState.MODE_CAMP:
            if _briefing_abort_active:
                return "Mission briefing -> Field camp -> Return to briefing"
            return "Battle clear -> Camp review -> Next battle"
        CampaignState.MODE_BRIEFING:
            return "Mission briefing -> Deploy"
        CampaignState.MODE_CHAPTER_INTRO:
            return "Camp exit -> Mission brief -> Deploy"
        CampaignState.MODE_COMPLETE:
            return "Chapter complete -> Await next destination"
        _:
            return "Loop state active"

func _build_camp_presentation_cards() -> Array[Dictionary]:
    var cards: Array[Dictionary] = []

    if _active_chapter_id == CHAPTER_CH01:
        cards.append({
            "eyebrow": "Ally",
            "title": "Serin Steps Into The Line",
            "body": "Serin is no longer a temporary escort. The camp handoff now treats her as a full ally tied directly to the next route."
        })
        cards.append({
            "eyebrow": "Memory",
            "title": "First Order Surfaces",
            "body": "The first recovered command fragment confirms that Rian's battlefield instincts are tied to a real chain of orders, not only instinct."
        })
        cards.append({
            "eyebrow": "Evidence",
            "title": "Hardren Seal Points North",
            "body": "The recovered seal and route evidence now anchor the border pursuit. The next handoff is driven by proof, not guesswork."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH02:
        cards.append({
            "eyebrow": "Ally",
            "title": "Bran Holds The Line",
            "body": "Bran's distrust remains, but the fortress handoff locks him into the active roster and shifts the squad into a harder military rhythm."
        })
        cards.append({
            "eyebrow": "Memory",
            "title": "Hardren Routes Feel Familiar",
            "body": "Rian reads fortress lanes too quickly for a stranger, and the campaign now frames that knowledge as a concrete warning sign."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH03:
        cards.append({
            "eyebrow": "Ally",
            "title": "Tia Tests The Party",
            "body": "The Greenwood handoff turns Tia from a wary forest contact into a rostered ally with her own read on the route ahead."
        })
        cards.append({
            "eyebrow": "Evidence",
            "title": "The Fire Was Planned",
            "body": "The basin route is no longer only wilderness travel. The event handoff now frames the wildfire residue as proof of deliberate command."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH04:
        cards.append({
            "eyebrow": "Memory",
            "title": "Ark Research Resurfaces",
            "body": "The monastery handoff turns recovered research into an explicit transition card, making the experiment trail feel like evidence rather than flavor text."
        })
        cards.append({
            "eyebrow": "Evidence",
            "title": "Gray Archive Route Confirmed",
            "body": "Transfer ledgers and seals now point cleanly toward the Gray Archive, so the next chapter handoff reads like a deliberate chase of records."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH05:
        cards.append({
            "eyebrow": "Ally",
            "title": "Enoch Names Zero",
            "body": "The archive handoff now treats Enoch's arrival and the first explicit naming of Zero as a runtime reveal rather than a plain summary bullet."
        })
        cards.append({
            "eyebrow": "Evidence",
            "title": "Valtor Ledgers Point Forward",
            "body": "Siege ledgers and surviving-knight rolls are surfaced as a concrete handoff card that carries the march directly toward the iron fortress."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH06:
        cards.append({
            "eyebrow": "Memory",
            "title": "Valtor Breach Remembered",
            "body": "The fortress breach memory is now framed as a deliberate handoff card so the next chapter reads like a military escalation, not only a text recap."
        })
        cards.append({
            "eyebrow": "Evidence",
            "title": "Ellyor Relief Route Opens",
            "body": "Relief edicts and civilian transfer records now point cleanly toward Ellyor, making the city transition explicit in camp."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH07:
        cards.append({
            "eyebrow": "Evidence",
            "title": "Black-Hound Orders Surface",
            "body": "The nameless-city handoff now frames the recovered black-hound orders as the chapter's main proof object instead of leaving them buried in the summary paragraph."
        })
        cards.append({
            "eyebrow": "Route",
            "title": "The Forest Trail Turns Back",
            "body": "The capital route now explicitly bends back toward the forest ruins, so the next hunt reads as a sharp tactical turn instead of a vague continuation."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH08:
        cards.append({
            "eyebrow": "Defense",
            "title": "Kyle's Outer Line Identified",
            "body": "The black-hound pursuit now hands off into Kyle's outer line through a dedicated presentation card, making the strategic pivot visible at a glance."
        })
        cards.append({
            "eyebrow": "Hunt",
            "title": "Lete's Route Confirmed",
            "body": "The forest and ruin evidence now resolves into a named pursuit path, tying the chapter's end cleanly into the next defense front."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH09A:
        cards.append({
            "eyebrow": "Ally",
            "title": "Kyle Opens The Root Route",
            "body": "Kyle's testimony and broken-standard handoff now land as a dedicated transition card, making his alliance feel like a structural shift in the campaign."
        })
        cards.append({
            "eyebrow": "Archive",
            "title": "Discarded Officers Are Named",
            "body": "The route into the root archive now carries the weight of the discarded-officer records as an explicit handoff object."
        })
        return cards

    if _active_chapter_id == CHAPTER_CH09B:
        cards.append({
            "eyebrow": "Ally",
            "title": "Noah Fixes The Archive Route",
            "body": "The abyss handoff now makes Noah's presence and the final archive-route alignment feel like a concrete arrival, not only a summary line."
        })
        cards.append({
            "eyebrow": "Destination",
            "title": "The Final Tower Is Confirmed",
            "body": "Eclipse coordinates and tower lattice are now framed as the final transition object, tightening the handoff into CH10."
        })
        return cards

    return cards

func _build_resolution_presentation_cards() -> Array[Dictionary]:
    var cards: Array[Dictionary] = []
    if _active_chapter_id == CHAPTER_CH10:
        cards.append({
            "eyebrow": "Resolution",
            "title": "The Bell Falls Silent",
            "body": "The final resolution now reads as a concrete runtime handoff: Karuon falls, the bell stops, and the tower loses its right to decide what survives."
        })
        cards.append({
            "eyebrow": "Memory",
            "title": "Names Remain Shared",
            "body": "The ending state now frames survival through shared memory instead of erased authority, turning the finale into a readable conclusion rather than only a summary paragraph."
        })
    return cards

func _commit_stage_rewards(stage: StageData) -> void:
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
    var result_summary: Dictionary = _battle_controller.last_result_summary.duplicate(true)
    var conversations: Array = result_summary.get("support_conversations", []).duplicate(true)
    conversations.append({
        "pair_id": pair_id,
        "pair_label": _build_support_pair_label(pair_id),
        "rank": rank,
        "rank_label": "%s Rank" % SupportConversations.get_rank_label(rank),
        "text": text
    })
    result_summary["support_conversations"] = conversations
    _battle_controller.last_result_summary = result_summary
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
        if not _unlocked_accessory_ids.has(typed_id):
            _unlocked_accessory_ids.append(typed_id)

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
        if not _unlocked_weapon_ids.has(typed_id):
            _unlocked_weapon_ids.append(typed_id)

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
        if not _unlocked_armor_ids.has(typed_id):
            _unlocked_armor_ids.append(typed_id)

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

func _get_progression_data() -> ProgressionData:
    if _battle_controller == null or _battle_controller.progression_service == null:
        return null
    return _battle_controller.progression_service.get_data()

func _build_material_entries() -> Array[Dictionary]:
    return ForgeService.get_material_entries(_get_progression_data())

func _build_forge_recipe_entries() -> Array[Dictionary]:
    return ForgeService.build_recipe_entries(_get_progression_data(), _get_all_owned_item_ids())

func _get_all_owned_item_ids() -> Array[StringName]:
    var owned: Array[StringName] = []
    for weapon_id in _unlocked_weapon_ids:
        if not owned.has(weapon_id):
            owned.append(weapon_id)
    for armor_id in _unlocked_armor_ids:
        if not owned.has(armor_id):
            owned.append(armor_id)
    for accessory_id in _unlocked_accessory_ids:
        if not owned.has(accessory_id):
            owned.append(accessory_id)
    return owned

func _is_item_owned(output_type: StringName, output_id: StringName) -> bool:
    match output_type:
        ForgeService.OUTPUT_WEAPON:
            return _unlocked_weapon_ids.has(output_id)
        ForgeService.OUTPUT_ARMOR:
            return _unlocked_armor_ids.has(output_id)
        ForgeService.OUTPUT_ACCESSORY:
            return _unlocked_accessory_ids.has(output_id)
        _:
            return false

func _unlock_crafted_item(output_type: StringName, output_id: StringName) -> void:
    match output_type:
        ForgeService.OUTPUT_WEAPON:
            if not _unlocked_weapon_ids.has(output_id):
                _unlocked_weapon_ids.append(output_id)
        ForgeService.OUTPUT_ARMOR:
            if not _unlocked_armor_ids.has(output_id):
                _unlocked_armor_ids.append(output_id)
        ForgeService.OUTPUT_ACCESSORY:
            if not _unlocked_accessory_ids.has(output_id):
                _unlocked_accessory_ids.append(output_id)

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
        reward_lines.append("Material: %s x%d" % [ForgeService.get_material_label(material_id), total_count])
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
        reward_lines.append("Bonus Material: %s x1" % ForgeService.get_material_label(material_id))
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
    return "%s forged: %s" % [output_type, String(recipe.get("label", String(recipe_id)))]

func _refresh_camp_panel_state() -> void:
    if _active_mode != CampaignState.MODE_CAMP:
        return
    _set_panel_state(CampaignState.MODE_CAMP, _current_panel_title, _current_panel_body, _campaign_panel.advance_button.text if _campaign_panel != null else "Next Battle")

func _build_camp_alerts(memory_entries: Array[String], evidence_entries: Array[String], letter_entries: Array[String], inventory_entries: Array[String]) -> Array[String]:
    var alerts: Array[String] = ["Camp ready", "Party update available"]
    if _get_craftable_recipe_count() > 0:
        alerts.append("Forge recipes ready")
    if not memory_entries.is_empty():
        alerts.append("Memory log updated")
    if not evidence_entries.is_empty():
        alerts.append("Evidence trail updated")
    if not letter_entries.is_empty():
        alerts.append("Letter received")
    if not inventory_entries.is_empty():
        alerts.append("Recovered supplies logged")
    return alerts

func _build_camp_recommendation(memory_entries: Array[String], evidence_entries: Array[String], letter_entries: Array[String], inventory_entries: Array[String]) -> String:
    if not memory_entries.is_empty() or not evidence_entries.is_empty() or not letter_entries.is_empty():
        return "Start in Records to review the latest memory, evidence, and Serin handoff before checking party readiness."
    if _get_craftable_recipe_count() > 0:
        return "Open Forge to spend recovered materials, then return to Party to lock in the next loadout."
    if not inventory_entries.is_empty():
        return "Start in Inventory to review recovered supplies, then confirm the party for the northern route."
    return "Review the current party and continue when ready."

func _build_camp_section_badges(party_entries: Array[String], inventory_entries: Array[String], memory_entries: Array[String], evidence_entries: Array[String], letter_entries: Array[String]) -> Dictionary:
    var badges: Dictionary = {}
    if not party_entries.is_empty():
        badges[CampaignPanel.SECTION_PARTY] = "READY"

    var inventory_count: int = inventory_entries.size()
    if inventory_count > 0:
        badges[CampaignPanel.SECTION_INVENTORY] = str(inventory_count)

    var craftable_count: int = _get_craftable_recipe_count()
    if craftable_count > 0:
        badges[CampaignPanel.SECTION_FORGE] = "READY %d" % craftable_count

    var record_count: int = memory_entries.size() + evidence_entries.size() + letter_entries.size()
    if record_count > 0:
        badges[CampaignPanel.SECTION_RECORDS] = "NEW %d" % record_count

    return badges

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
        var role_label: String = "Reserve"
        if unit_data.unit_id == &"ally_rian":
            role_label = "Core"
        elif _deployed_party_unit_ids.has(unit_data.unit_id):
            role_label = "Deployed"
        lines.append("%s  HP %d/%d  ATK %d  DEF %d  %s" % [
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
        var default_skill_name: String = unit_data.default_skill.display_name if unit_data.default_skill != null else "No skill"
        var deploy_status: String = "Reserve"
        if unit_data.unit_id == &"ally_rian":
            deploy_status = "Core"
        elif _deployed_party_unit_ids.has(unit_data.unit_id):
            deploy_status = "Deployed"
        var weapon_name: String = "None"
        var armor_name: String = "None"
        var accessory_name: String = "None"
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
            "weapon_slot": weapon_name,
            "armor_slot": armor_name,
            "accessory_slot": accessory_name,
            "accessory_summary": accessory_summary,
            "accessory_flavor_text": accessory_flavor_text,
            "weapon_preview_path": _get_weapon_preview_path(equipped_weapon_id),
            "armor_preview_path": _get_armor_preview_path(equipped_armor_id),
            "accessory_preview_path": _get_accessory_preview_path(equipped_accessory_id),
            "allowed_weapon_types": _packed_array_to_string_array(allowed_weapon_types),
            "allowed_armor_types": _packed_array_to_string_array(allowed_armor_types),
            "eligible_weapon_count": eligible_weapon_ids.size(),
            "eligible_armor_count": eligible_armor_ids.size(),
            "eligible_accessory_count": _get_available_accessory_ids().size(),
            "total_weapon_count": _get_available_weapon_ids().size(),
            "total_armor_count": _get_available_armor_ids().size(),
            "total_accessory_count": _get_available_accessory_ids().size()
        })
    return details

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
        &"ally_karl":
            return _active_chapter_id == CHAPTER_CH09A and _active_mode == CampaignState.MODE_CAMP \
                or _chapter_rank(_active_chapter_id) > 9
        &"ally_noah":
            return _active_chapter_id == CHAPTER_CH09B and _active_mode == CampaignState.MODE_CAMP \
                or _chapter_rank(_active_chapter_id) > 10
        _:
            return true

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
        if not _unlocked_accessory_ids.has(typed_id):
            _unlocked_accessory_ids.append(typed_id)

func debug_unlock_weapon_ids(ids: Array) -> void:
    for weapon_id in ids:
        var typed_id: StringName = weapon_id
        if not _unlocked_weapon_ids.has(typed_id):
            _unlocked_weapon_ids.append(typed_id)

func debug_unlock_armor_ids(ids: Array) -> void:
    for armor_id in ids:
        var typed_id: StringName = armor_id
        if not _unlocked_armor_ids.has(typed_id):
            _unlocked_armor_ids.append(typed_id)

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

func _correct_accessory_choice_for_unit(unit_id: StringName) -> void:
    if not _is_recruit_unlocked(unit_id):
        return
    var available_ids: Array[StringName] = _get_available_accessory_ids()
    var current_id: StringName = StringName(_equipped_accessory_by_unit_id.get(String(unit_id), ""))
    if not ReforgeService.can_correct_accessory_choice(current_id, available_ids):
        return
    var next_id: StringName = ReforgeService.get_corrected_accessory_choice(current_id, available_ids)
    if next_id == StringName() or next_id == current_id:
        return
    _equipped_accessory_by_unit_id[String(unit_id)] = String(next_id)
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

func _on_deployment_assignment_requested(unit_id: StringName) -> void:
    assign_unit_to_sortie(unit_id)

func _on_weapon_cycle_requested(unit_id: StringName) -> void:
    cycle_weapon_for_unit(unit_id)

func _on_armor_cycle_requested(unit_id: StringName) -> void:
    cycle_armor_for_unit(unit_id)

func _on_accessory_cycle_requested(unit_id: StringName) -> void:
    cycle_accessory_for_unit(unit_id)

func _on_accessory_reforge_requested(unit_id: StringName) -> void:
    _correct_accessory_choice_for_unit(unit_id)

func _on_forge_craft_requested(recipe_id: StringName) -> void:
    if _craft_recipe(recipe_id):
        _refresh_camp_panel_state()

func _get_available_weapon_ids() -> Array[StringName]:
    var available: Array[StringName] = []
    for weapon_id in _unlocked_weapon_ids:
        if _get_weapon_data_by_id(weapon_id) != null:
            available.append(weapon_id)
    return available

func _get_available_armor_ids() -> Array[StringName]:
    var available: Array[StringName] = []
    for armor_id in _unlocked_armor_ids:
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
        if weapon != null and String(weapon.weapon_type) in unit_data.get_allowed_weapon_types():
            available.append(weapon_id)
    return available

func _get_available_armor_ids_for_unit(unit_id: StringName) -> Array[StringName]:
    var available: Array[StringName] = []
    var unit_data: UnitData = _get_unit_data_by_id(unit_id)
    if unit_data == null:
        return available
    for armor_id in _get_available_armor_ids():
        var armor: ArmorData = _get_armor_data_by_id(armor_id)
        if armor != null and String(armor.armor_type) in unit_data.get_allowed_armor_types():
            available.append(armor_id)
    return available

func _get_available_accessory_ids() -> Array[StringName]:
    var available: Array[StringName] = []
    for accessory_id in _unlocked_accessory_ids:
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
        var equipped_unit: String = _find_equipped_weapon_unit_name(weapon.weapon_id)
        var suffix: String = "" if equipped_unit.is_empty() else " [Equipped: %s]" % equipped_unit
        lines.append("Weapon: %s — %s%s" % [weapon.display_name, weapon.summary, suffix])
    return lines

func _build_armor_inventory_lines() -> Array[String]:
    var lines: Array[String] = []
    for armor_id in _get_available_armor_ids():
        var armor: ArmorData = _get_armor_data_by_id(armor_id)
        if armor == null:
            continue
        var equipped_unit: String = _find_equipped_armor_unit_name(armor.armor_id)
        var suffix: String = "" if equipped_unit.is_empty() else " [Equipped: %s]" % equipped_unit
        lines.append("Armor: %s — %s%s" % [armor.display_name, armor.summary, suffix])
    return lines

func _build_accessory_inventory_lines() -> Array[String]:
    var lines: Array[String] = []
    for accessory_id in _get_available_accessory_ids():
        var accessory: AccessoryData = _get_accessory_data_by_id(accessory_id)
        if accessory == null:
            continue
        var equipped_unit: String = _find_equipped_unit_name(accessory.accessory_id)
        var suffix: String = "" if equipped_unit.is_empty() else " [Equipped: %s]" % equipped_unit
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
        lines.append("%s — %s%s" % [accessory.display_name, detail_text, suffix])
    return lines

func _get_accessory_flavor_text(accessory: AccessoryData) -> String:
    if accessory == null:
        return ""
    var flavor_text := String(accessory.flavor_text).strip_edges()
    if not flavor_text.is_empty():
        return flavor_text
    return String(accessory.summary).strip_edges()

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
    for unit_id in _equipped_accessory_by_unit_id.keys():
        if StringName(_equipped_accessory_by_unit_id[unit_id]) == accessory_id:
            var unit_data: UnitData = _get_unit_data_by_id(StringName(unit_id))
            if unit_data != null:
                return unit_data.display_name
    return ""

func _find_equipped_weapon_unit_name(weapon_id: StringName) -> String:
    for unit_id in _equipped_weapon_by_unit_id.keys():
        if StringName(_equipped_weapon_by_unit_id[unit_id]) == weapon_id:
            var unit_data: UnitData = _get_unit_data_by_id(StringName(unit_id))
            if unit_data != null:
                return unit_data.display_name
    return ""

func _find_equipped_armor_unit_name(armor_id: StringName) -> String:
    for unit_id in _equipped_armor_by_unit_id.keys():
        if StringName(_equipped_armor_by_unit_id[unit_id]) == armor_id:
            var unit_data: UnitData = _get_unit_data_by_id(StringName(unit_id))
            if unit_data != null:
                return unit_data.display_name
    return ""

func _find_replaceable_deployed_index() -> int:
    for index in range(_deployed_party_unit_ids.size()):
        if _deployed_party_unit_ids[index] != &"ally_rian":
            return index
    return max(0, _deployed_party_unit_ids.size() - 1)
