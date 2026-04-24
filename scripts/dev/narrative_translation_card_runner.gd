extends SceneTree

const BattleController = preload("res://scripts/battle/battle_controller.gd")
const CampaignController = preload("res://scripts/campaign/campaign_controller.gd")
const CampaignPanel = preload("res://scripts/campaign/campaign_panel.gd")
const ProgressionService = preload("res://scripts/battle/progression_service.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CAMPAIGN_PANEL_SCENE: PackedScene = preload("res://scenes/campaign/CampaignPanel.tscn")

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if not await _assert_fragment_unlocks_translation_card():
        return
    if not await _assert_guard_share_plus_battle_hook():
        return
    print("[PASS] narrative_translation_card_runner: all assertions passed.")
    quit(0)

func _assert_fragment_unlocks_translation_card() -> bool:
    var battle: BattleController = BATTLE_SCENE.instantiate() as BattleController
    var panel: CampaignPanel = CAMPAIGN_PANEL_SCENE.instantiate() as CampaignPanel
    var campaign := CampaignController.new()
    root.add_child(battle)
    root.add_child(panel)
    root.add_child(campaign)
    campaign.setup(battle, panel)
    await process_frame
    await process_frame

    var unlock_result: Dictionary = battle.progression_service.recover_fragment(&"ch01_fragment")
    if not Array(unlock_result.get("passive_cards_unlocked", [])).has("guard_share_plus"):
        _cleanup_nodes([campaign, panel, battle])
        return _fail("ch01_fragment should unlock guard_share_plus.")
    if not battle.progression_service.get_data().has_passive_card(&"guard_share_plus"):
        _cleanup_nodes([campaign, panel, battle])
        return _fail("ProgressionData should persist guard_share_plus after fragment recovery.")

    campaign._enter_camp_state()
    await process_frame
    await process_frame

    var snapshot: Dictionary = panel.get_snapshot()
    var presentation_cards: Array = snapshot.get("presentation_cards", [])
    var found_translation_card: bool = false
    for card_variant in presentation_cards:
        if typeof(card_variant) != TYPE_DICTIONARY:
            continue
        var card: Dictionary = card_variant
        if String(card.get("title", "")) != "Guard Share+":
            continue
        found_translation_card = true
        if String(card.get("eyebrow", "")) != "전투 번역 카드":
            _cleanup_nodes([campaign, panel, battle])
            return _fail("Narrative translation card should expose the translation eyebrow.")
        if String(card.get("body", "")).find("65%") == -1:
            _cleanup_nodes([campaign, panel, battle])
            return _fail("Narrative translation card should explain the upgraded 65% guard share rule.")
        var badges: Array = card.get("badges", [])
        if badges.is_empty() or String(Dictionary(badges[0]).get("value", "")).find("65%") == -1:
            _cleanup_nodes([campaign, panel, battle])
            return _fail("Narrative translation card should expose an effect badge.")
        var progress_rows: Array = card.get("progress_rows", [])
        if progress_rows.size() < 2:
            _cleanup_nodes([campaign, panel, battle])
            return _fail("Narrative translation card should expose unlock/source progress rows.")
    _cleanup_nodes([campaign, panel, battle])
    if not found_translation_card:
        return _fail("Camp presentation cards should include Guard Share+ after fragment recovery.")
    return true

func _assert_guard_share_plus_battle_hook() -> bool:
    var battle: BattleController = BATTLE_SCENE.instantiate() as BattleController
    root.add_child(battle)
    await process_frame
    await process_frame

    var stage := StageData.new()
    stage.stage_id = &"narrative_translation_guard_share_stage"
    stage.stage_title = "Narrative Translation Guard Share"
    stage.grid_size = Vector2i(4, 4)
    stage.cell_size = Vector2i(64, 64)
    stage.win_condition = &"defeat_all_enemies"
    stage.ally_units = [
        _make_unit_data(&"ally_rian", "Rian", "ally", 10, 2, 0, 3, 1),
        _make_unit_data(&"ally_serin", "Serin", "ally", 10, 2, 0, 3, 1)
    ]
    stage.enemy_units = [
        _make_unit_data(&"enemy_raider", "Raider", "enemy", 10, 6, 0, 3, 1)
    ]
    stage.ally_spawns = [Vector2i(1, 1), Vector2i(1, 2)]
    stage.enemy_spawns = [Vector2i(2, 1)]

    battle.set_stage(stage)
    await process_frame
    await process_frame

    battle.bond_service.reset()
    battle.bond_service.apply_bond_delta(&"ally_serin", 5, "narrative_translation_guard_share")
    battle.progression_service.recover_fragment(&"ch01_fragment")

    var enemy = battle.enemy_units[0]
    var defender = battle.ally_units[0]
    battle._resolve_attack(enemy, defender)
    await process_frame
    await process_frame

    var details: Dictionary = battle.last_damage_share_details
    battle.queue_free()
    if StringName(details.get("passive_card_id", &"")) != &"guard_share_plus":
        return _fail("Damage share details should record guard_share_plus as the active passive card.")
    if absf(float(details.get("shared_ratio", 0.0)) - 0.65) > 0.001:
        return _fail("Damage share should upgrade to a 65% share ratio after guard_share_plus unlock.")
    if int(details.get("shared_damage", 0)) <= 0:
        return _fail("Damage share should still apply positive redirected damage.")
    return true

func _make_unit_data(unit_id: StringName, display_name: String, faction: String, max_hp: int, attack: int, defense: int, movement: int, attack_range: int) -> UnitData:
    var unit_data := UnitData.new()
    unit_data.unit_id = unit_id
    unit_data.display_name = display_name
    unit_data.faction = faction
    unit_data.max_hp = max_hp
    unit_data.attack = attack
    unit_data.defense = defense
    unit_data.movement = movement
    unit_data.attack_range = attack_range
    return unit_data

func _cleanup_nodes(nodes: Array) -> void:
    for node in nodes:
        if node != null and is_instance_valid(node):
            node.queue_free()

func _fail(message: String) -> bool:
    if not _failed:
        _failed = true
        push_error("[FAIL] narrative_translation_card_runner: %s" % message)
    quit(1)
    return false
