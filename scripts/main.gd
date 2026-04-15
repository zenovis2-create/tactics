extends Node

const BattleController = preload("res://scripts/battle/battle_controller.gd")
const CampaignController = preload("res://scripts/campaign/campaign_controller.gd")
const CampaignPanel = preload("res://scripts/campaign/campaign_panel.gd")
const AudioEventRouter = preload("res://scripts/audio/audio_event_router.gd")

@onready var battle_controller: BattleController = $BattleScene
@onready var campaign_controller: CampaignController = $CampaignController
@onready var audio_event_router: AudioEventRouter = $AudioEventRouter
@onready var campaign_panel: CampaignPanel = $CanvasLayer/CampaignPanel

func _ready() -> void:
    if battle_controller == null:
        push_warning("Main scene is missing BattleScene.")
        return

    if campaign_controller == null:
        push_warning("Main scene is missing CampaignController.")
        return

    if campaign_panel == null:
        push_warning("Main scene is missing CampaignPanel.")
        return

    campaign_controller.setup(battle_controller, campaign_panel)
    if audio_event_router != null:
        audio_event_router.attach_battle_hud(battle_controller.hud)
        audio_event_router.attach_campaign_panel(campaign_panel)
    campaign_controller.start_chapter_one_flow()

func get_campaign_state_snapshot() -> Dictionary:
    if campaign_controller == null:
        return {}
    return campaign_controller.get_state_snapshot()

func advance_campaign_step() -> bool:
    if campaign_controller == null:
        return false
    return campaign_controller.advance_step()
