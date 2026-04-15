extends Node

## 게임 메인 씬 — 타이틀 → 배틀 → 캠프 → 배틀 흐름 오케스트레이션

const BattleController = preload("res://scripts/battle/battle_controller.gd")
const CampaignController = preload("res://scripts/campaign/campaign_controller.gd")
const CampaignPanel = preload("res://scripts/campaign/campaign_panel.gd")
const AudioEventRouter = preload("res://scripts/audio/audio_event_router.gd")
const TitleScreen = preload("res://scripts/ui/title_screen.gd")
const DefeatScreen = preload("res://scripts/ui/defeat_screen.gd")
const SaveLoadPanel = preload("res://scripts/ui/save_load_panel.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

@onready var battle_controller: BattleController = $BattleScene
@onready var campaign_controller: CampaignController = $CampaignController
@onready var audio_event_router: AudioEventRouter = $AudioEventRouter
@onready var campaign_panel: CampaignPanel = $CanvasLayer/CampaignPanel
@onready var title_screen: TitleScreen = $UILayer/TitleScreen
@onready var defeat_screen: DefeatScreen = $UILayer/DefeatScreen
@onready var save_load_panel: SaveLoadPanel = $UILayer/SaveLoadPanel

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
    if defeat_screen != null:
        defeat_screen.setup_save_service(_save_service)

    # CampaignController 셋업
    campaign_controller.setup(battle_controller, campaign_panel)

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

    # DefeatScreen 시그널
    if defeat_screen != null:
        defeat_screen.retry_requested.connect(_on_retry_requested)
        defeat_screen.load_last_save_requested.connect(_on_load_last_save_requested)
        defeat_screen.title_requested.connect(_on_title_requested)

    # SaveLoadPanel 시그널
    if save_load_panel != null:
        save_load_panel.save_requested.connect(_on_save_requested)
        save_load_panel.load_requested.connect(_on_save_load_requested)

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

# --- 흐름 제어 ---

func _show_title() -> void:
    if title_screen != null:
        title_screen.setup_save_service(_save_service)
        title_screen.visible = true
    if battle_controller != null:
        battle_controller.visible = false

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
    campaign_controller.start_chapter_one_flow()

# --- 시그널 핸들러 ---

func _on_battle_finished_main(result: StringName, _stage_id: StringName) -> void:
    if result != &"victory" and defeat_screen != null:
        var rounds: int = battle_controller.round_index if battle_controller != null else 0
        defeat_screen.show_defeat(rounds)

func _on_new_game_requested() -> void:
    _start_new_game()

func _on_load_game_requested(slot: int) -> void:
    var data: ProgressionData = _save_service.load_progression(slot) if _save_service != null else null
    _start_loaded_game(data)

func _on_retry_requested() -> void:
    # 현재 스테이지 재시작
    if battle_controller != null:
        battle_controller.bootstrap_battle()
    if battle_controller != null:
        battle_controller.visible = true

func _on_load_last_save_requested(data: ProgressionData) -> void:
    _start_loaded_game(data)

func _on_title_requested() -> void:
    _show_title()

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
