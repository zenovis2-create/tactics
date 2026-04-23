extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const SupportConversations = preload("res://data/support_conversations.gd")
const CH07_FINAL_STAGE = preload("res://data/stages/ch07_05_stage.tres")
const CH08_FIRST_STAGE = preload("res://data/stages/ch08_01_stage.tres")
const CH08_FINAL_STAGE = preload("res://data/stages/ch08_05_stage.tres")
const CH09A_FIRST_STAGE = preload("res://data/stages/ch09a_01_stage.tres")
const CH09B_FINAL_STAGE = preload("res://data/stages/ch09b_05_stage.tres")
const CH10_FIRST_STAGE = preload("res://data/stages/ch10_01_stage.tres")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)
    await process_frame
    await process_frame

    var campaign = main.campaign_controller
    var battle = main.battle_controller
    var panel = main.campaign_panel
    if campaign == null or battle == null or panel == null:
        push_error("Hidden recruit runner could not resolve main campaign dependencies.")
        quit(1)
        return

    if not await _assert_mira_and_lete_unlocks(campaign, battle, panel):
        quit(1)
        return
    if not await _assert_melkion_temporary_unlock(campaign, battle):
        quit(1)
        return

    print("[PASS] hidden_recruit_runner verified Mira/Lete permanent unlocks and Melkion's temporary CH10_01 contract.")
    quit(0)

func _assert_mira_and_lete_unlocks(campaign, battle, panel) -> bool:
    campaign.debug_seed_chapter_camp(&"CH07", 4, CH07_FINAL_STAGE)
    await process_frame
    await process_frame
    var ch07_snapshot: Dictionary = panel.get_snapshot()
    if _has_party_member(ch07_snapshot.get("party_details", []), "Mira"):
        return _fail("Hidden recruit runner expected Mira to stay hidden before CH07 reward resolution.")
    if _has_party_member(ch07_snapshot.get("party_details", []), "Lete"):
        return _fail("Hidden recruit runner expected Lete to stay hidden before CH08 reward resolution.")

    if not await _resolve_ch07_mira_runtime_flag(battle):
        return false
    campaign._commit_stage_rewards(CH07_FINAL_STAGE)
    campaign.debug_seed_chapter_camp(&"CH08", 0, CH08_FIRST_STAGE)
    await process_frame
    await process_frame
    var ch08_snapshot: Dictionary = panel.get_snapshot()
    if not _has_party_member(ch08_snapshot.get("party_details", []), "Mira"):
        return _fail("Hidden recruit runner expected Mira in the CH08 camp roster after CH07 reward resolution.")

    if not await _resolve_ch08_lete_runtime_flag(battle):
        return false
    campaign._commit_stage_rewards(CH08_FINAL_STAGE)
    campaign.debug_seed_chapter_camp(&"CH09A", 0, CH09A_FIRST_STAGE)
    await process_frame
    await process_frame
    var ch09a_snapshot: Dictionary = panel.get_snapshot()
    if not _has_party_member(ch09a_snapshot.get("party_details", []), "Lete"):
        return _fail("Hidden recruit runner expected Lete in the CH09A camp roster after CH08 reward resolution.")
    return true

func _assert_melkion_temporary_unlock(campaign, battle) -> bool:
    var progression_data: ProgressionData = battle.progression_service.get_data()
    if progression_data == null:
        return _fail("Hidden recruit runner expected live progression data.")
    var pair_id := SupportConversations.get_pair_id("ally_rian", "ally_noah")
    progression_data.set_support_rank(pair_id, 4)
    if battle.bond_service != null:
        battle.bond_service.load_from_progression(progression_data)

    campaign.debug_seed_chapter_camp(&"CH09B", 4, CH09B_FINAL_STAGE)
    await process_frame
    await process_frame
    battle.last_result_summary = {"stars_earned": 1}
    battle.battle_objective_flags = {"melkion_truth_revealed": true, "noah_survives": true}
    campaign._commit_stage_rewards(CH09B_FINAL_STAGE)

    campaign._active_chapter_id = campaign.CHAPTER_CH09B
    campaign._active_stage_index = 4
    var ch09b_roster: Array = campaign._get_campaign_party_roster()
    if not _has_unit_id(ch09b_roster, &"ally_melkion_ally"):
        return _fail("Hidden recruit runner expected Melkion ally in the CH09B post-clear roster when Noah support rank is 4.")

    campaign._active_chapter_id = campaign.CHAPTER_CH10
    campaign._active_stage_index = 0
    var ch10_stage1_roster: Array = campaign._get_campaign_party_roster()
    if not _has_unit_id(ch10_stage1_roster, &"ally_melkion_ally"):
        return _fail("Hidden recruit runner expected Melkion ally to remain available for CH10_01 only.")

    battle.last_result_summary = {"stars_earned": 1}
    battle.battle_objective_flags = {}
    campaign._commit_stage_rewards(CH10_FIRST_STAGE)
    campaign._active_chapter_id = campaign.CHAPTER_CH10
    campaign._active_stage_index = 1
    var ch10_stage2_roster: Array = campaign._get_campaign_party_roster()
    if _has_unit_id(ch10_stage2_roster, &"ally_melkion_ally"):
        return _fail("Hidden recruit runner expected Melkion ally to disappear after CH10_01 clear.")
    if progression_data.has_hidden_recruit(&"ally_melkion_ally"):
        return _fail("Hidden recruit runner expected Melkion ally hidden recruit flag to be consumed after CH10_01 clear.")
    return true

func _has_party_member(party_details: Array, expected_name: String) -> bool:
    for entry in party_details:
        if typeof(entry) != TYPE_DICTIONARY:
            continue
        if String(entry.get("name", "")) == expected_name:
            return true
    return false

func _resolve_ch07_mira_runtime_flag(battle) -> bool:
    var runtime_stage = CH07_FINAL_STAGE.duplicate(true)
    battle.set_stage(runtime_stage)
    await process_frame
    await process_frame
    battle._handle_stage_interaction_flags("ch07_05_city_seal")
    battle._handle_stage_interaction_flags("ch07_05_prayer_dais")
    battle.last_result_summary = {"stars_earned": 1}
    await process_frame
    if not bool(battle.battle_objective_flags.get("collect_city_seal", false)):
        return _fail("Hidden recruit runner expected CH07 runtime path to set collect_city_seal.")
    if not bool(battle.battle_objective_flags.get("prayer_dais_secured", false)):
        return _fail("Hidden recruit runner expected CH07 runtime path to set prayer_dais_secured.")
    if not bool(battle.battle_objective_flags.get("recruit_mira", false)):
        return _fail("Hidden recruit runner expected CH07 runtime path to set recruit_mira after both interactions.")
    return true

func _resolve_ch08_lete_runtime_flag(battle) -> bool:
    var runtime_stage = CH08_FINAL_STAGE.duplicate(true)
    battle.set_stage(runtime_stage)
    await process_frame
    await process_frame
    if battle.enemy_units.is_empty():
        return _fail("Hidden recruit runner expected CH08 runtime battle to spawn a Lete boss unit.")
    var boss = battle.enemy_units[0]
    battle._apply_boss_phase_effects(boss, &"berserk_rush", &"")
    battle.last_result_summary = {"stars_earned": 1}
    await process_frame
    if not bool(battle.battle_objective_flags.get("lete_defects_alive", false)):
        return _fail("Hidden recruit runner expected CH08 runtime path to set lete_defects_alive when berserk_rush triggers.")
    return true

func _has_unit_id(roster: Array, expected_unit_id: StringName) -> bool:
    for unit_data in roster:
        if unit_data == null:
            continue
        if unit_data.unit_id == expected_unit_id:
            return true
    return false

func _fail(message: String) -> bool:
    push_error(message)
    return false
