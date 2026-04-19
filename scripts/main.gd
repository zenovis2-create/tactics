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
const EncyclopediaPanel = preload("res://scripts/ui/encyclopedia_panel.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

const ng_plus_shop_items: Array[Dictionary] = [
    {
        "id": "bond_anchor",
        "name": "Bond Anchor",
        "cost": 15,
        "description": "All allies start with S-rank support with Rian."
    },
    {
        "id": "veteran_squad",
        "name": "Veteran Squad",
        "cost": 10,
        "description": "All allies start at level 5."
    },
    {
        "id": "iron_memory",
        "name": "Iron Memory",
        "cost": 8,
        "description": "Recovered memory fragments carry into the next run."
    },
    {
        "id": "lete_bow",
        "name": "Lete's Bow",
        "cost": 12,
        "description": "Unlock Lete's bow from the start of a new campaign."
    },
    {
        "id": "mira_archive",
        "name": "Mira's Archive",
        "cost": 10,
        "description": "All intel and briefing records start unlocked."
    },
    {
        "id": "divine_blessing",
        "name": "Divine Blessing",
        "cost": 20,
        "description": "Grants one free Name Call in the CH10 finale."
    }
]

@onready var battle_controller: BattleController = $BattleScene
@onready var campaign_controller: CampaignController = $CampaignController
@onready var audio_event_router: AudioEventRouter = $AudioEventRouter
@onready var bgm_router: BgmRouter = $BgmRouter
@onready var campaign_panel: CampaignPanel = $CanvasLayer/CampaignPanel
@onready var title_screen: TitleScreen = $UILayer/TitleScreen
@onready var defeat_screen: DefeatScreen = $UILayer/DefeatScreen
@onready var save_load_panel: SaveLoadPanel = $UILayer/SaveLoadPanel
@onready var encyclopedia_panel: EncyclopediaPanel = $UILayer/EncyclopediaPanel

var _save_service: SaveService

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

    # CampaignController 셋업
    campaign_controller.setup(battle_controller, campaign_panel)
    if not campaign_controller.mode_changed.is_connected(_on_campaign_mode_changed):
        campaign_controller.mode_changed.connect(_on_campaign_mode_changed)

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
        title_screen.load_game_requested.connect(_on_load_game_requested)
        title_screen.ng_plus_purchase_requested.connect(_on_ng_plus_purchase_requested)

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
        campaign_panel.encyclopedia_requested.connect(_open_encyclopedia)
    if battle_controller != null and battle_controller.hud != null:
        battle_controller.hud.encyclopedia_requested.connect(_open_encyclopedia)

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

func open_save_panel() -> void:
    if save_load_panel != null:
        save_load_panel.open_save_mode()

func open_load_panel() -> void:
    if save_load_panel != null:
        save_load_panel.open_load_mode()

func _open_encyclopedia() -> void:
    if encyclopedia_panel == null or campaign_controller == null:
        return
    var context: Dictionary = campaign_controller.get_encyclopedia_context()
    if context.is_empty():
        return
    encyclopedia_panel.show_context(context)

# --- 흐름 제어 ---

func _show_title() -> void:
    _restore_title_progression_from_autosave_if_needed()
    if title_screen != null:
        title_screen.setup_save_service(_save_service)
        title_screen.setup_load_panel(save_load_panel)
        title_screen.setup_ng_plus_shop(_get_progression_data(), ng_plus_shop_items)
        title_screen.visible = true
    if battle_controller != null:
        battle_controller.visible = false
    if bgm_router != null:
        bgm_router.play_cue("bgm_title")

func _start_new_game() -> void:
    if title_screen != null:
        title_screen.visible = false
    if battle_controller != null:
        battle_controller.visible = true
    campaign_controller.start_chapter_one_flow()

func _start_loaded_game(data: ProgressionData) -> void:
    if data == null:
        _start_new_game()
        return
    if title_screen != null:
        title_screen.visible = false
    if battle_controller != null:
        battle_controller.visible = true
    # ProgressionService에 로드 데이터 적용
    if battle_controller.progression_service != null:
        battle_controller.progression_service.load_data(data)
    campaign_controller.start_chapter_one_flow(false)

func purchase_ng_plus_item(item_id: String) -> bool:
    _restore_title_progression_from_autosave_if_needed()
    var progression: ProgressionData = _get_progression_data()
    if progression == null:
        return false
    var shop_item: Dictionary = _find_ng_plus_shop_item(item_id)
    if shop_item.is_empty() or progression.has_ng_plus_purchase(item_id):
        return false
    var cost: int = int(shop_item.get("cost", 0))
    if cost <= 0 or progression.badges_of_heroism < cost:
        return false
    progression.badges_of_heroism -= cost
    if not progression.add_ng_plus_purchase(item_id):
        progression.badges_of_heroism += cost
        return false
    if item_id == "iron_memory" and progression.ng_plus_saved_fragments.is_empty():
        progression.set_ng_plus_saved_fragments(progression.get_recovered_fragment_ids())
    if _save_service != null:
        _save_service.save_progression(progression, 0)
    _refresh_title_ng_plus()
    return true

func _get_progression_data() -> ProgressionData:
    if battle_controller == null or battle_controller.progression_service == null:
        return null
    return battle_controller.progression_service.get_data()

func _restore_title_progression_from_autosave_if_needed() -> void:
    if _save_service == null or battle_controller == null or battle_controller.progression_service == null:
        return
    var progression: ProgressionData = battle_controller.progression_service.get_data()
    if progression != null and (progression.badges_of_heroism > 0 or not progression.ng_plus_purchases.is_empty() or not progression.earned_badges.is_empty()):
        return
    if not _save_service.slot_exists(0):
        return
    var loaded: ProgressionData = _save_service.load_progression(0)
    if loaded != null:
        battle_controller.progression_service.load_data(loaded)

func _find_ng_plus_shop_item(item_id: String) -> Dictionary:
    for item: Dictionary in ng_plus_shop_items:
        if String(item.get("id", "")) == item_id:
            return item.duplicate(true)
    return {}

func _refresh_title_ng_plus() -> void:
    if title_screen != null:
        title_screen.setup_ng_plus_shop(_get_progression_data(), ng_plus_shop_items)

# --- 시그널 핸들러 ---

func _on_battle_finished_main(result: StringName, _stage_id: StringName) -> void:
    if result != &"victory" and defeat_screen != null:
        if campaign_controller != null and String(campaign_controller.get_state_snapshot().get("mode", "")) == "defeat":
            return
        if bgm_router != null:
            bgm_router.play_cue("bgm_cutscene_ch01", true)
        var rounds: int = battle_controller.round_index if battle_controller != null else 0
        defeat_screen.show_defeat(rounds)

func _on_new_game_requested() -> void:
    _start_new_game()

func _on_load_game_requested(slot: int) -> void:
    var data: ProgressionData = _save_service.load_progression(slot) if _save_service != null else null
    _start_loaded_game(data)

func _on_ng_plus_purchase_requested(item_id: String) -> void:
    purchase_ng_plus_item(item_id)

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

func _on_campaign_mode_changed(mode: String) -> void:
    if bgm_router == null:
        return
    match mode:
        "battle":
            _play_battle_bgm()
        "camp":
            bgm_router.play_cue("bgm_camp")
        "defeat":
            bgm_router.play_cue("bgm_cutscene_ch01")
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
        _save_service.save_progression(prog_data, slot)
    if save_load_panel != null:
        save_load_panel.refresh_slots()

func _on_save_load_requested(slot: int, data: ProgressionData) -> void:
    if save_load_panel != null:
        save_load_panel.close()
    _start_loaded_game(data)
