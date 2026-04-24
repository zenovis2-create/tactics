extends Node

## 게임 메인 씬 — 타이틀 → 배틀 → 캠프 → 배틀 흐름 오케스트레이션

const BattleController = preload("res://scripts/battle/battle_controller.gd")
const CampaignController = preload("res://scripts/campaign/campaign_controller.gd")
const CampaignPanel = preload("res://scripts/campaign/campaign_panel.gd")
const AudioEventRouter = preload("res://scripts/audio/audio_event_router.gd")
const BgmRouter = preload("res://scripts/audio/bgm_router.gd")
const TitleScreen = preload("res://scripts/ui/title_screen.gd")
const DefeatScreen = preload("res://scripts/ui/defeat_screen.gd")
const SaveLoadPanel = preload("res://scripts/ui/save_load_panel.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const EndingResolver = preload("res://scripts/battle/ending_resolver.gd")
const CutsceneCatalog = preload("res://data/cutscenes/cutscene_catalog.gd")
const CutsceneOverlay = preload("res://scripts/cutscene/cutscene_overlay.gd")
const CUTSCENE_OVERLAY_SCENE: PackedScene = preload("res://scenes/cutscene/CutsceneOverlay.tscn")

@onready var battle_controller: BattleController = $BattleScene
@onready var campaign_controller: CampaignController = $CampaignController
@onready var audio_event_router: AudioEventRouter = $AudioEventRouter
@onready var bgm_router: BgmRouter = $BgmRouter
@onready var campaign_panel: CampaignPanel = $CanvasLayer/CampaignPanel
@onready var title_screen: TitleScreen = $UILayer/TitleScreen
@onready var ending_overlay: Control = $UILayer/EndingOverlay
@onready var ending_fade: ColorRect = $UILayer/EndingOverlay/Fade
@onready var ending_afterglow: ColorRect = $UILayer/EndingOverlay/EndingAfterglow
@onready var ending_accent: ColorRect = $UILayer/EndingOverlay/Center/EndingStack/EndingAccent
@onready var ending_eyebrow_label: Label = $UILayer/EndingOverlay/Center/EndingStack/EndingEyebrowLabel
@onready var ending_label: Label = $UILayer/EndingOverlay/Center/EndingStack/TheEndLabel
@onready var ending_sigil_label: Label = $UILayer/EndingOverlay/Center/EndingStack/EndingSigilLabel
@onready var ending_pip_row: HBoxContainer = $UILayer/EndingOverlay/Center/EndingStack/EndingPipRow
@onready var ending_memory_rail: ColorRect = $UILayer/EndingOverlay/Center/EndingStack/EndingMemoryRail
@onready var ending_phase_label: Label = $UILayer/EndingOverlay/Center/EndingStack/EndingPhaseLabel
@onready var ending_source_stamp_label: Label = $UILayer/EndingOverlay/Center/EndingStack/EndingSourceStampLabel
@onready var ending_progress_label: Label = $UILayer/EndingOverlay/Center/EndingStack/EndingProgressLabel
@onready var ending_outcome_label: Label = $UILayer/EndingOverlay/Center/EndingStack/EndingOutcomeLabel
@onready var ending_subtitle_label: Label = $UILayer/EndingOverlay/Center/EndingStack/EndingSubtitleLabel
@onready var credits_overlay: Control = $UILayer/CreditsOverlay
@onready var credits_fade: ColorRect = $UILayer/CreditsOverlay/Fade
@onready var credits_afterglow: ColorRect = $UILayer/CreditsOverlay/CreditsAfterglow
@onready var credits_accent: ColorRect = $UILayer/CreditsOverlay/Center/CreditsStack/CreditsAccent
@onready var credits_tier_label: Label = $UILayer/CreditsOverlay/Center/CreditsStack/CreditsTierLabel
@onready var credits_eyebrow: Label = $UILayer/CreditsOverlay/Center/CreditsStack/CreditsEyebrow
@onready var credits_progress_label: Label = $UILayer/CreditsOverlay/Center/CreditsStack/CreditsProgressLabel
@onready var credits_pip_row: HBoxContainer = $UILayer/CreditsOverlay/Center/CreditsStack/CreditsPipRow
@onready var credits_memory_rail: ColorRect = $UILayer/CreditsOverlay/Center/CreditsStack/CreditsMemoryRail
@onready var credits_phase_label: Label = $UILayer/CreditsOverlay/Center/CreditsStack/CreditsPhaseLabel
@onready var credits_source_stamp_label: Label = $UILayer/CreditsOverlay/Center/CreditsStack/CreditsSourceStampLabel
@onready var credits_row_label: Label = $UILayer/CreditsOverlay/Center/CreditsStack/CreditsRowLabel
@onready var credits_outcome_label: Label = $UILayer/CreditsOverlay/Center/CreditsStack/CreditsOutcomeLabel
@onready var credits_label: RichTextLabel = $UILayer/CreditsOverlay/Center/CreditsStack/CreditsLabel
@onready var defeat_screen: DefeatScreen = $UILayer/DefeatScreen
@onready var save_load_panel: SaveLoadPanel = $UILayer/SaveLoadPanel

var _save_service: SaveService
var ng_plus_enabled: bool = false
var ending_cutscene_overlay: CutsceneOverlay

func _ready() -> void:
    if battle_controller == null or campaign_controller == null or campaign_panel == null:
        push_warning("Main scene is missing required nodes.")
        return

    _save_service = SaveService.new()
    add_child(_save_service)

    # SaveLoadPanel 서비스 주입
    if save_load_panel != null:
        save_load_panel.save_service = _save_service
    if title_screen != null:
        title_screen.setup_save_service(_save_service)
        title_screen.setup_load_panel(save_load_panel)
    if defeat_screen != null:
        defeat_screen.setup_save_service(_save_service)

    if CUTSCENE_OVERLAY_SCENE != null:
        ending_cutscene_overlay = CUTSCENE_OVERLAY_SCENE.instantiate() as CutsceneOverlay
        if ending_cutscene_overlay != null:
            $UILayer.add_child(ending_cutscene_overlay)

    # CampaignController 셋업
    campaign_controller.setup(battle_controller, campaign_panel)
    if not campaign_controller.mode_changed.is_connected(_on_campaign_mode_changed):
        campaign_controller.mode_changed.connect(_on_campaign_mode_changed)
    if not campaign_controller.return_to_title_requested.is_connected(_on_campaign_return_to_title_requested):
        campaign_controller.return_to_title_requested.connect(_on_campaign_return_to_title_requested)

    # 오디오 연결
    if audio_event_router != null:
        audio_event_router.attach_battle_hud(battle_controller.hud)
        audio_event_router.attach_campaign_panel(campaign_panel)

    # 배틀 패배 시그널 연결 (CampaignController와 독립적으로 DefeatScreen 트리거)
    if battle_controller != null:
        battle_controller.battle_finished.connect(_on_battle_finished_main)

    # TitleScreen 시그널
    if title_screen != null:
        title_screen.new_game_requested.connect(_on_new_game_requested)
        title_screen.new_game_plus_requested.connect(_on_new_game_plus_requested)
        title_screen.load_game_requested.connect(_on_load_game_requested)

    # DefeatScreen 시그널
    if defeat_screen != null:
        defeat_screen.retry_requested.connect(_on_retry_requested)
        defeat_screen.load_last_save_requested.connect(_on_load_last_save_requested)
        defeat_screen.title_requested.connect(_on_title_requested)

    # SaveLoadPanel 시그널
    if save_load_panel != null:
        save_load_panel.save_requested.connect(_on_save_requested)
        save_load_panel.load_requested.connect(_on_save_load_requested)
    if campaign_panel != null:
        campaign_panel.save_panel_requested.connect(open_save_panel)

    # 타이틀 화면으로 시작
    _show_title()

# --- 공개 API ---

func get_campaign_state_snapshot() -> Dictionary:
    if campaign_controller == null:
        return {}
    return campaign_controller.get_state_snapshot()

func advance_campaign_step() -> bool:
    if campaign_controller == null:
        return false
    return campaign_controller.advance_step()

## 테스트/디버그용: 타이틀 화면 생략하고 즉시 새 게임 시작
func start_game_direct() -> void:
    _start_new_game()

func start_new_game_plus() -> void:
    ng_plus_enabled = true
    var source_data: ProgressionData = _get_ng_plus_source_data()
    var ng_plus_data: ProgressionData = _build_ng_plus_progression_data(source_data)
    _start_campaign(ng_plus_data)

func is_ng_plus() -> bool:
    return ng_plus_enabled

func open_save_panel() -> void:
    if save_load_panel != null:
        save_load_panel.open_save_mode()

func open_load_panel() -> void:
    if save_load_panel != null:
        save_load_panel.open_load_mode()

# --- 흐름 제어 ---

func _show_title() -> void:
    ng_plus_enabled = false
    if title_screen != null:
        title_screen.setup_save_service(_save_service)
        title_screen.setup_load_panel(save_load_panel)
        title_screen.visible = true
    if battle_controller != null:
        battle_controller.visible = false
    if campaign_panel != null:
        campaign_panel.hide_panel()
    if defeat_screen != null:
        defeat_screen.hide()
    if ending_overlay != null:
        ending_overlay.visible = false
    if credits_overlay != null:
        credits_overlay.visible = false
    _hide_save_load_panel()
    if bgm_router != null:
        bgm_router.play_cue("bgm_title")

func _start_new_game() -> void:
    ng_plus_enabled = false
    _start_campaign(_build_fresh_progression_data())

func _start_loaded_game(data: ProgressionData) -> void:
    if data == null:
        _start_new_game()
        return
    ng_plus_enabled = data.ng_plus_run
    _start_campaign(data)

func _start_campaign(data: ProgressionData) -> void:
    if data == null:
        data = _build_fresh_progression_data()
    if title_screen != null:
        title_screen.visible = false
    if ending_overlay != null:
        ending_overlay.visible = false
    if defeat_screen != null:
        defeat_screen.hide()
    _hide_save_load_panel()
    if battle_controller != null:
        battle_controller.visible = true
        if battle_controller.progression_service != null:
            battle_controller.progression_service.load_data(data)
        if battle_controller.bond_service != null:
            battle_controller.bond_service.load_from_progression(data)
    if campaign_controller != null:
        campaign_controller.set_ng_plus_mode(ng_plus_enabled)
        campaign_controller.start_chapter_one_flow()

func _build_fresh_progression_data() -> ProgressionData:
    var data := ProgressionData.new()
    data.ng_plus_available = _has_ng_plus_save_available()
    return data

func _build_ng_plus_progression_data(source: ProgressionData) -> ProgressionData:
    var data := ProgressionData.new()
    data.ng_plus_available = true
    data.ng_plus_run = true
    if source != null:
        data.last_completed_ending = source.last_completed_ending
        data.bond_levels = source.get_bond_levels_snapshot()
    return data

func _get_ng_plus_source_data() -> ProgressionData:
    if battle_controller != null and battle_controller.progression_service != null:
        var live_data: ProgressionData = battle_controller.progression_service.get_data()
        if live_data != null and live_data.ng_plus_available:
            return live_data
    if _save_service == null:
        return ProgressionData.new()
    for i in SaveService.MANUAL_SLOT_COUNT:
        if not _save_service.slot_exists(i):
            continue
        var slot_metadata: Dictionary = _save_service.peek_slot(i)
        if bool(slot_metadata.get("ng_plus_available", false)):
            return _save_service.load_progression(i)
    if _save_service.slot_exists(SaveService.AUTOSAVE_SLOT):
        var autosave_metadata: Dictionary = _save_service.peek_slot(SaveService.AUTOSAVE_SLOT)
        if bool(autosave_metadata.get("ng_plus_available", false)):
            return _save_service.load_progression(SaveService.AUTOSAVE_SLOT)
    return ProgressionData.new()

func _has_ng_plus_save_available() -> bool:
    if _save_service == null:
        return false
    for i in SaveService.MANUAL_SLOT_COUNT:
        if not _save_service.slot_exists(i):
            continue
        var slot_metadata: Dictionary = _save_service.peek_slot(i)
        if bool(slot_metadata.get("ng_plus_available", false)):
            return true
    if _save_service.slot_exists(SaveService.AUTOSAVE_SLOT):
        var autosave_metadata: Dictionary = _save_service.peek_slot(SaveService.AUTOSAVE_SLOT)
        if bool(autosave_metadata.get("ng_plus_available", false)):
            return true
    return false

func _hide_save_load_panel() -> void:
    if save_load_panel != null and save_load_panel.has_method("close"):
        save_load_panel.close()

# --- 시그널 핸들러 ---

func _on_battle_finished_main(result: StringName, _stage_id: StringName) -> void:
    if result != &"victory" and defeat_screen != null:
        if bgm_router != null:
            bgm_router.play_cue("bgm_cutscene_ch01", true)
        var rounds: int = battle_controller.round_index if battle_controller != null else 0
        defeat_screen.show_defeat(rounds)

func _on_new_game_requested() -> void:
    _start_new_game()

func _on_new_game_plus_requested() -> void:
    start_new_game_plus()

func _on_load_game_requested(slot: int) -> void:
    var data: ProgressionData = _save_service.load_progression(slot) if _save_service != null else null
    _start_loaded_game(data)

func _on_retry_requested() -> void:
    # 현재 스테이지 재시작
    if battle_controller != null:
        battle_controller.bootstrap_battle()
    if battle_controller != null:
        battle_controller.visible = true
    if bgm_router != null:
        _play_battle_bgm(true)

func _on_load_last_save_requested(data: ProgressionData) -> void:
    _start_loaded_game(data)

func _on_title_requested() -> void:
    _show_title()

func _on_campaign_return_to_title_requested(show_credits: bool) -> void:
    if show_credits or campaign_controller != null:
        await _show_the_end_and_return_to_title(_get_current_ending_type())
        return
    _show_title()

func _get_current_ending_type() -> StringName:
    if campaign_controller == null:
        return EndingResolver.ENDING_NORMAL
    return campaign_controller._resolve_current_ending()

func _show_the_end_and_return_to_title(ending_type: StringName = &"normal_ending") -> void:
    if campaign_panel != null:
        campaign_panel.hide_panel()
    if battle_controller != null:
        battle_controller.visible = false
    _show_title()
    _hide_save_load_panel()
    if ending_overlay != null:
        if ending_fade != null:
            ending_fade.color = _get_ending_fade_color(ending_type)
        if ending_afterglow != null:
            ending_afterglow.color = _get_ending_afterglow_color(ending_type)
        if ending_accent != null:
            ending_accent.color = _get_ending_accent_color(ending_type)
        if ending_memory_rail != null:
            ending_memory_rail.color = _get_ending_memory_rail_color(ending_type)
        _apply_ending_pips(ending_type)
        if ending_eyebrow_label != null:
            ending_eyebrow_label.text = _get_ending_overlay_eyebrow(ending_type)
        if ending_label != null:
            ending_label.text = _get_ending_overlay_text(ending_type)
        if ending_sigil_label != null:
            ending_sigil_label.text = _get_ending_overlay_sigil(ending_type)
        if ending_phase_label != null:
            ending_phase_label.text = _get_ending_overlay_phase_text(ending_type)
        if ending_source_stamp_label != null:
            ending_source_stamp_label.text = _get_ending_overlay_source_stamp(ending_type)
        if ending_progress_label != null:
            ending_progress_label.text = _get_ending_overlay_progress_text(ending_type)
        if ending_outcome_label != null:
            ending_outcome_label.text = _get_ending_overlay_outcome_text(ending_type)
        if ending_subtitle_label != null:
            ending_subtitle_label.text = _get_ending_overlay_subtitle(ending_type)
        await _play_ending_cutscene_sequence(ending_type)
        ending_overlay.visible = true
        await get_tree().create_timer(3.0).timeout
        ending_overlay.visible = false
    if ending_type == EndingResolver.ENDING_TRUE:
        await _play_true_ending_companion_scene()
    await _show_end_credits(ending_type)

func _get_ending_overlay_text(ending_type: StringName) -> String:
    if ending_type == EndingResolver.ENDING_TRUE:
        return "True End\n모든 이름이 남다"
    return "The End"

func _get_ending_overlay_eyebrow(ending_type: StringName) -> String:
    if ending_type == EndingResolver.ENDING_TRUE:
        return "True Ending"
    return "Normal Ending"

func _get_ending_overlay_subtitle(ending_type: StringName) -> String:
    if ending_type == EndingResolver.ENDING_TRUE:
        return "모든 이름이 남았다. 마지막 기억은 다음 사람에게 건네진다."
    return "리안은 마지막 공명을 혼자 받아내고, 동료들은 잊혀 가는 그의 이름을 대신 붙든다."

func _get_ending_overlay_sigil(ending_type: StringName) -> String:
    if ending_type == EndingResolver.ENDING_TRUE:
        return "ALL NAMES REMAIN"
    return "RIAN BEARS THE LAST BELL"

func _get_ending_overlay_phase_text(ending_type: StringName) -> String:
    if ending_type == EndingResolver.ENDING_TRUE:
        return "PHASE 02  NAME HANDOFF  /  이름 인계"
    return "PHASE 01  RIAN SACRIFICE  /  리안 희생"

func _get_ending_overlay_source_stamp(ending_type: StringName) -> String:
    if ending_type == EndingResolver.ENDING_TRUE:
        return "TRUE / CH10 Resolution"
    return "NORMAL / CH10 Resolution"

func _get_ending_overlay_progress_text(ending_type: StringName) -> String:
    return "ENDING TRACK 2/2" if ending_type == EndingResolver.ENDING_TRUE else "ENDING TRACK 1/2"

func _get_ending_overlay_outcome_text(ending_type: StringName) -> String:
    if ending_type == EndingResolver.ENDING_TRUE:
        return "공동의 미래가 살아남은 이름들 위에 남는다."
    return "리안이 마지막 공명을 홀로 짊어지고, 생존자들은 그의 빈자리를 기억으로 메운다."

func _get_ending_accent_color(ending_type: StringName) -> Color:
    if ending_type == EndingResolver.ENDING_TRUE:
        return Color(0.72, 0.84, 0.98, 0.96)
    return Color(0.92, 0.78, 0.58, 0.94)

func _get_ending_memory_rail_color(ending_type: StringName) -> Color:
    if ending_type == EndingResolver.ENDING_TRUE:
        return Color(0.72, 0.84, 0.98, 0.9)
    return Color(0.92, 0.78, 0.58, 0.9)

func _get_ending_fade_color(ending_type: StringName) -> Color:
    if ending_type == EndingResolver.ENDING_TRUE:
        return Color(0.03, 0.08, 0.14, 0.9)
    return Color(0.08, 0.05, 0.03, 0.9)

func _get_ending_afterglow_color(ending_type: StringName) -> Color:
    if ending_type == EndingResolver.ENDING_TRUE:
        return Color(0.10, 0.18, 0.26, 0.18)
    return Color(0.20, 0.12, 0.06, 0.18)

func _show_end_credits(ending_type: StringName) -> void:
    if credits_overlay == null or credits_label == null:
        return
    var sections: Array[String] = _build_end_credits_sections(ending_type)
    credits_overlay.visible = true
    for index in range(sections.size()):
        if credits_fade != null:
            credits_fade.color = _get_credits_fade_color(index, ending_type)
        if credits_afterglow != null:
            credits_afterglow.color = _get_credits_afterglow_color(index, ending_type)
        if credits_accent != null:
            credits_accent.color = _get_credits_accent_color(index, ending_type)
        if credits_memory_rail != null:
            credits_memory_rail.color = _get_credits_memory_rail_color(index, ending_type)
        _apply_credits_pips(index, sections.size(), ending_type)
        if credits_tier_label != null:
            credits_tier_label.text = _get_credits_tier_label(ending_type)
        if credits_eyebrow != null:
            credits_eyebrow.text = _get_credits_section_heading(index, ending_type)
        if credits_progress_label != null:
            credits_progress_label.text = "%d/%d" % [index + 1, sections.size()]
        if credits_phase_label != null:
            credits_phase_label.text = _get_credits_phase_text(index, ending_type)
        if credits_source_stamp_label != null:
            credits_source_stamp_label.text = _get_credits_source_stamp(index, ending_type)
        if credits_row_label != null:
            credits_row_label.text = "ROW %d/%d" % [index + 1, sections.size()]
        if credits_outcome_label != null:
            credits_outcome_label.text = _get_credits_outcome_text(index, ending_type)
        credits_label.text = sections[index]
        var duration: float = 1.15 if index < sections.size() - 1 else 1.5
        await get_tree().create_timer(duration).timeout
    credits_overlay.visible = false

func _build_end_credits_text(ending_type: StringName) -> String:
    var ending_header := "진엔딩 후일담" if ending_type == EndingResolver.ENDING_TRUE else "결말 후일담"
    return "[center][b]%s[/b]\n\n리안 / 세린 / 브란 / 티아 / 에녹 / 카일 / 노아\n\n기억을 남긴 사람들\n탑 밖으로 돌아온 생존자들\n다음 이름을 써 내려갈 증언자들[/center]" % ending_header

func _build_end_credits_sections(ending_type: StringName) -> Array[String]:
    var header := "진엔딩 후일담" if ending_type == EndingResolver.ENDING_TRUE else "결말 후일담"
    var sections: Array[String] = []
    sections.append("[center][b]%s[/b]\n\n잿빛의 기억\nFarland Tactics[/center]" % header)
    sections.append("[center][b]남은 이름들[/b]\n\n리안 / 세린 / 브란 / 티아 / 에녹 / 카일 / 노아\n\n종 이후에도 서로를 증언할 사람들[/center]")
    if ending_type == EndingResolver.ENDING_TRUE:
        sections.append("[center][b]다음 시대[/b]\n\n모든 이름이 남았다.\n마지막 기억은 봉인이 아니라 인계가 되었다.\n남겨진 이름들은 다음 사람에게 그대로 건네진다.[/center]")
    else:
        sections.append("[center][b]남겨진 세계[/b]\n\n리안은 마지막 공명을 혼자 받아낸다.\n살아남은 사람들은 그 희생과 결손을 안은 채 다음 시대를 시작한다.\n그래도 무엇을 남길지는 이제 그들 스스로 정한다.[/center]")
    sections.append("[center][b]기억을 남긴 사람들[/b]\n\n탑 밖으로 돌아온 생존자들\n다음 이름을 써 내려갈 증언자들\n종이 멈춘 뒤에도 기록을 포기하지 않은 사람들[/center]")
    return sections

func _get_credits_section_heading(index: int, ending_type: StringName) -> String:
    match index:
        0:
            return "결말 장면"
        1:
            return "남은 이름들"
        2:
            return "다음 시대" if ending_type == EndingResolver.ENDING_TRUE else "남겨진 세계"
        3:
            return "기억을 남긴 사람들"
        _:
            return "Credits"

func _get_credits_tier_label(ending_type: StringName) -> String:
    if ending_type == EndingResolver.ENDING_TRUE:
        return "True Ending Roll"
    return "Normal Ending Roll"

func _get_credits_phase_text(index: int, ending_type: StringName) -> String:
    match index:
        0:
            return "PHASE 01  RESOLUTION LOCK  /  결말 고정"
        1:
            return "PHASE 02  NAME ROLL  /  남은 이름"
        2:
            return "PHASE 03  FUTURE CARRY  /  다음 시대" if ending_type == EndingResolver.ENDING_TRUE else "PHASE 03  WORLD AFTER BELL  /  남겨진 세계"
        3:
            return "PHASE 04  WITNESS KEEP  /  증언 보존"
        _:
            return "PHASE 00  CREDITS"

func _get_credits_source_stamp(index: int, ending_type: StringName) -> String:
    var ending_tag := "TRUE" if ending_type == EndingResolver.ENDING_TRUE else "NORMAL"
    match index:
        0:
            return "%s / Resolution Roll" % ending_tag
        1:
            return "%s / Name Roll" % ending_tag
        2:
            return "%s / Future Roll" % ending_tag if ending_type == EndingResolver.ENDING_TRUE else "%s / Aftermath Roll" % ending_tag
        3:
            return "%s / Witness Roll" % ending_tag
        _:
            return "%s / Credits" % ending_tag

func _get_credits_outcome_text(index: int, ending_type: StringName) -> String:
    match index:
        0:
            return "결말 장면이 이번 회차의 최종 상태로 고정된다."
        1:
            return "남은 이름들이 이후 기록의 기준으로 정리된다."
        2:
            return "다음 시대의 방향이 이 결말 위에서 정리된다." if ending_type == EndingResolver.ENDING_TRUE else "남겨진 세계의 생존 조건이 이 결말 위에서 정리된다."
        3:
            return "증언이 다음 기록으로 남는다."
        _:
            return ""

func get_ending_visual_stack() -> Array[String]:
    var stack: Array[String] = []
    var tier_text: String = String(ending_eyebrow_label.text) if ending_eyebrow_label != null else ""
    var source_text: String = String(ending_source_stamp_label.text) if ending_source_stamp_label != null else ""
    var progress_text: String = String(ending_progress_label.text) if ending_progress_label != null else ""
    var outcome_text: String = String(ending_outcome_label.text) if ending_outcome_label != null else ""
    var ending_key := "true_ending" if tier_text.find("True") != -1 or source_text.find("TRUE") != -1 else "normal_ending"
    if ending_memory_rail != null:
        stack.append("rail:%s" % ending_key)
    if ending_afterglow != null:
        stack.append("afterglow:%s" % ending_key)
    if not tier_text.is_empty():
        stack.append("tier:%s" % ending_key)
    if not source_text.is_empty():
        stack.append("source:%s" % ending_key)
    if not progress_text.is_empty():
        stack.append("progress:%s" % ending_key)
    if not outcome_text.is_empty():
        stack.append("outcome:%s" % ending_key)
    return stack

func get_credits_visual_stack() -> Array[String]:
    var stack: Array[String] = []
    var row_index := _get_active_credits_row_index()
    var row_key := str(row_index)
    if credits_memory_rail != null:
        stack.append("rail:%s" % row_key)
    if credits_afterglow != null:
        stack.append("afterglow:%s" % row_key)
    if credits_tier_label != null and not String(credits_tier_label.text).is_empty():
        stack.append("tier:%s" % row_key)
    if credits_source_stamp_label != null and not String(credits_source_stamp_label.text).is_empty():
        stack.append("source:%s" % row_key)
    if credits_row_label != null and not String(credits_row_label.text).is_empty():
        stack.append("row:%s" % row_key)
    if credits_outcome_label != null and not String(credits_outcome_label.text).is_empty():
        stack.append("outcome:%s" % row_key)
    return stack

func _get_active_credits_row_index() -> int:
    if credits_row_label == null:
        return 0
    var text := String(credits_row_label.text)
    var marker := "ROW "
    var marker_index := text.find(marker)
    if marker_index == -1:
        return 0
    var rest := text.substr(marker_index + marker.length())
    var slash_index := rest.find("/")
    if slash_index == -1:
        return 0
    return maxi(int(rest.substr(0, slash_index)) - 1, 0)

func _get_credits_accent_color(index: int, ending_type: StringName) -> Color:
    match index:
        0:
            return Color(0.78, 0.72, 0.96, 0.94) if ending_type == EndingResolver.ENDING_TRUE else Color(0.86, 0.72, 0.58, 0.94)
        1:
            return Color(0.72, 0.86, 0.98, 0.94)
        2:
            return Color(0.86, 0.94, 1.0, 0.96) if ending_type == EndingResolver.ENDING_TRUE else Color(0.92, 0.82, 0.66, 0.94)
        3:
            return Color(0.94, 0.9, 0.78, 0.96)
        _:
            return Color(0.72, 0.78, 0.96, 0.94)

func _get_credits_memory_rail_color(index: int, ending_type: StringName) -> Color:
    return _get_credits_accent_color(index, ending_type)

func _get_credits_fade_color(index: int, ending_type: StringName) -> Color:
    match index:
        0:
            return Color(0.04, 0.03, 0.06, 0.92) if ending_type == EndingResolver.ENDING_TRUE else Color(0.06, 0.04, 0.03, 0.92)
        1:
            return Color(0.04, 0.06, 0.09, 0.92)
        2:
            return Color(0.08, 0.1, 0.13, 0.94) if ending_type == EndingResolver.ENDING_TRUE else Color(0.09, 0.07, 0.05, 0.92)
        3:
            return Color(0.1, 0.09, 0.07, 0.94)
        _:
            return Color(0, 0, 0, 0.92)

func _get_credits_afterglow_color(index: int, ending_type: StringName) -> Color:
    match index:
        0:
            return Color(0.12, 0.10, 0.18, 0.16) if ending_type == EndingResolver.ENDING_TRUE else Color(0.18, 0.12, 0.08, 0.16)
        1:
            return Color(0.10, 0.16, 0.20, 0.16)
        2:
            return Color(0.14, 0.18, 0.22, 0.18) if ending_type == EndingResolver.ENDING_TRUE else Color(0.18, 0.14, 0.10, 0.16)
        3:
            return Color(0.18, 0.16, 0.12, 0.18)
        _:
            return Color(0.10, 0.10, 0.10, 0.14)

func _apply_ending_pips(ending_type: StringName) -> void:
    if ending_pip_row == null:
        return
    var active_count := 2 if ending_type == EndingResolver.ENDING_TRUE else 1
    for index in range(ending_pip_row.get_child_count()):
        var pip := ending_pip_row.get_child(index) as ColorRect
        if pip == null:
            continue
        pip.color = Color(0.72, 0.84, 0.98, 0.96) if index < active_count else Color(0.25, 0.28, 0.34, 0.92)

func _apply_credits_pips(active_index: int, total: int, ending_type: StringName) -> void:
    if credits_pip_row == null:
        return
    var active_color := Color(0.86, 0.94, 1.0, 0.96) if ending_type == EndingResolver.ENDING_TRUE else Color(0.94, 0.84, 0.66, 0.96)
    for index in range(credits_pip_row.get_child_count()):
        var pip := credits_pip_row.get_child(index) as ColorRect
        if pip == null:
            continue
        pip.color = active_color if index <= active_index and index < total else Color(0.25, 0.28, 0.34, 0.92)

func _play_ending_cutscene_sequence(ending_type: StringName) -> void:
    if ending_cutscene_overlay == null:
        return
    var cutscene_id: StringName = &"ch10_true_resolution_cinematic" if ending_type == EndingResolver.ENDING_TRUE else &"ch10_normal_resolution_cinematic"
    var data = CutsceneCatalog.get_cutscene(cutscene_id)
    if data == null:
        return
    ending_cutscene_overlay.play_cutscene(data)
    while ending_cutscene_overlay.is_playing():
        await get_tree().create_timer(0.35).timeout
        ending_cutscene_overlay.advance_immediate()

func _play_true_ending_companion_scene() -> void:
    if ending_cutscene_overlay == null:
        return
    var data = CutsceneCatalog.get_cutscene(&"ch10_true_companion_scene")
    if data == null:
        return
    ending_cutscene_overlay.play_cutscene(data)
    while ending_cutscene_overlay.is_playing():
        await get_tree().create_timer(0.35).timeout
        ending_cutscene_overlay.advance_immediate()

func _on_campaign_mode_changed(mode: String) -> void:
    if bgm_router == null:
        return
    match mode:
        "battle":
            _play_battle_bgm()
        "camp":
            bgm_router.play_cue("bgm_camp")
        "cutscene":
            bgm_router.play_cue("bgm_cutscene_ch01")
        "chapter_intro":
            bgm_router.play_cue("bgm_title")
        _:
            pass

func _play_battle_bgm(restart: bool = false) -> void:
    if bgm_router == null:
        return
    var cue_id := "bgm_battle_default"
    if _current_stage_has_boss():
        cue_id = "bgm_battle_boss"
    bgm_router.play_cue(cue_id, restart)

func _current_stage_has_boss() -> bool:
    if battle_controller == null or battle_controller.stage_data == null:
        return false
    for enemy_variant in battle_controller.stage_data.enemy_units:
        var enemy_data := enemy_variant as UnitData
        if enemy_data != null and enemy_data.is_boss:
            return true
    return false

func _on_save_requested(slot: int) -> void:
    if _save_service == null or battle_controller == null:
        return
    var prog_data: ProgressionData = null
    if battle_controller.progression_service != null:
        prog_data = battle_controller.progression_service.get_data()
    if prog_data != null:
        if battle_controller.bond_service != null:
            battle_controller.bond_service.export_to_progression(prog_data)
        _save_service.save_progression(prog_data, slot)
    if save_load_panel != null:
        save_load_panel.refresh_slots()

func _on_save_load_requested(slot: int, data: ProgressionData) -> void:
    if save_load_panel != null:
        save_load_panel.close()
    _start_loaded_game(data)
