extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CampaignState = preload("res://scripts/campaign/campaign_state.gd")
const CampaignCatalog = preload("res://scripts/campaign/campaign_catalog.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const ENEMY_SKIRMISHER = preload("res://data/units/enemy_skirmisher.tres")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var full_retreat_passed := await _run_full_retreat_path()
    var sacrifice_passed := await _run_sacrifice_path()
    var desperate_passed := await _run_desperate_stand_path()
    var memorial_passed := await _run_memorial_path()

    print("[RESULT] Full Retreat: %s" % ("PASS" if full_retreat_passed else "FAIL"))
    print("[RESULT] Sacrifice Protocol: %s" % ("PASS" if sacrifice_passed else "FAIL"))
    print("[RESULT] Desperate Stand: %s" % ("PASS" if desperate_passed else "FAIL"))
    print("[RESULT] S-rank Memorial: %s" % ("PASS" if memorial_passed else "FAIL"))

    if full_retreat_passed and sacrifice_passed and desperate_passed and memorial_passed:
        print("[PASS] retreat_runner: all retreat-path assertions passed.")
        quit(0)
        return

    quit(1)

func _boot_main() -> Node:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)
    await process_frame
    await process_frame
    main.start_game_direct()
    await process_frame
    await process_frame
    if main.battle_controller != null and main.battle_controller.progression_service != null:
        main.battle_controller.progression_service.load_data(ProgressionData.new())
    return main

func _teardown_main(main: Node) -> void:
    if main == null:
        return
    main.queue_free()
    await process_frame
    await process_frame

func _run_full_retreat_path() -> bool:
    var main := await _boot_main()
    var battle = main.battle_controller
    var panel = main.campaign_panel
    var campaign = main.campaign_controller
    var stage := _build_test_stage(&"RETREAT_TEST_FULL", [&"ally_rian", &"ally_serin"])
    campaign._current_stage = stage
    campaign._active_mode = CampaignState.MODE_BATTLE
    battle.set_stage(stage)
    await process_frame
    await process_frame
    if not await _force_current_battle_defeat(battle):
        await _teardown_main(main)
        return false
    await process_frame
    await process_frame

    var defeat_snapshot: Dictionary = panel.get_snapshot()
    if String(defeat_snapshot.get("mode", "")) != CampaignState.MODE_DEFEAT:
        push_error("Full Retreat path did not enter defeat mode.")
        await _teardown_main(main)
        return false
    if not _has_choice_option(defeat_snapshot, "defeat_full_retreat"):
        push_error("Retreat panel did not expose Full Retreat.")
        await _teardown_main(main)
        return false

    panel.choice_selected.emit("defeat_full_retreat")
    await process_frame
    await process_frame

    var progression = battle.progression_service.get_data()
    if progression.recovering_units.is_empty():
        push_error("Full Retreat should populate recovering_units.")
        await _teardown_main(main)
        return false
    if int(progression.recover_chapter_count) != 2:
        push_error("Full Retreat should set recover_chapter_count = 2.")
        await _teardown_main(main)
        return false

    var camp_snapshot: Dictionary = panel.get_snapshot()
    if String(camp_snapshot.get("mode", "")) != CampaignState.MODE_CAMP:
        push_error("Full Retreat should route back to camp mode.")
        await _teardown_main(main)
        return false
    if not _party_detail_has_recovering_label(camp_snapshot, "ally_serin"):
        push_error("Recovering camp roster should gray-label Serin after Full Retreat.")
        await _teardown_main(main)
        return false

    await _teardown_main(main)
    return true

func _run_sacrifice_path() -> bool:
    var main := await _boot_main()
    var battle = main.battle_controller
    var campaign = main.campaign_controller
    var panel = main.campaign_panel
    var stage := _build_test_stage(&"RETREAT_TEST_SACRIFICE", [&"ally_rian", &"ally_serin"])
    campaign._current_stage = stage
    campaign._active_mode = CampaignState.MODE_BATTLE
    battle.set_stage(stage)
    await process_frame
    await process_frame
    if not await _force_current_battle_defeat(battle):
        await _teardown_main(main)
        return false
    await process_frame
    await process_frame

    panel.choice_selected.emit("defeat_sacrifice_protocol")
    await process_frame
    await process_frame

    var sacrifice_snapshot: Dictionary = panel.get_snapshot()
    if not _has_choice_option(sacrifice_snapshot, "defeat_sacrifice_unit:ally_serin"):
        push_error("Sacrifice Protocol should allow selecting Serin.")
        await _teardown_main(main)
        return false

    panel.choice_selected.emit("defeat_sacrifice_unit:ally_serin")
    await process_frame
    await process_frame

    var progression = battle.progression_service.get_data()
    if not progression.has_sacrificed_unit("ally_serin"):
        push_error("Sacrifice Protocol should populate sacrificed_units with ally_serin.")
        await _teardown_main(main)
        return false
    var memorial_snapshot: Dictionary = panel.get_snapshot()
    if String(memorial_snapshot.get("mode", "")) != CampaignState.MODE_DEFEAT or not bool(memorial_snapshot.get("memorial_visible", false)):
        push_error("Sacrifice Protocol should open the memorial scene before returning to camp.")
        await _teardown_main(main)
        return false
    panel.skip_memorial_scene()
    await process_frame
    await process_frame
    var camp_snapshot: Dictionary = panel.get_snapshot()
    if String(camp_snapshot.get("mode", "")) != CampaignState.MODE_CAMP:
        push_error("Sacrifice Protocol should route back to camp mode after the memorial scene completes.")
        await _teardown_main(main)
        return false
    if _party_detail_exists(camp_snapshot, "ally_serin"):
        push_error("Serin should be removed from the camp roster after Sacrifice Protocol.")
        await _teardown_main(main)
        return false

    await _teardown_main(main)
    return true

func _run_desperate_stand_path() -> bool:
    var main := await _boot_main()
    var battle = main.battle_controller
    var panel = main.campaign_panel
    var campaign = main.campaign_controller
    var stage := _build_test_stage(&"RETREAT_TEST_DESPERATE", [&"ally_rian"])
    campaign._current_stage = stage
    campaign._active_mode = CampaignState.MODE_BATTLE
    battle.set_stage(stage)
    await process_frame
    await process_frame

    if not await _force_current_battle_defeat(battle):
        await _teardown_main(main)
        return false
    await process_frame
    await process_frame

    var defeat_snapshot: Dictionary = panel.get_snapshot()
    if not _has_choice_option(defeat_snapshot, "defeat_desperate_stand"):
        push_error("Retreat panel did not expose Desperate Stand.")
        await _teardown_main(main)
        return false

    panel.choice_selected.emit("defeat_desperate_stand")
    await process_frame
    await process_frame

    var special_snapshot: Dictionary = battle.get_special_battle_snapshot()
    if not bool(special_snapshot.get("desperate_wave_battle_triggered", false)):
        push_error("Desperate Stand should mark desperate_wave_battle_triggered.")
        await _teardown_main(main)
        return false
    var context: Dictionary = special_snapshot.get("desperate_wave_context", {})
    var waves: Array = context.get("waves", [])
    if waves.size() != 3:
        push_error("Desperate Stand should configure exactly 3 waves.")
        await _teardown_main(main)
        return false
    if int(waves[0].get("enemy_count", 0)) != 3 or int(waves[1].get("enemy_count", 0)) != 5 or not bool(waves[2].get("boss_reinforcement", false)):
        push_error("Desperate Stand wave context did not match the 3 / 5 / boss reinforcement spec.")
        await _teardown_main(main)
        return false

    await _teardown_main(main)
    return true

func _run_memorial_path() -> bool:
    var main := await _boot_main()
    var battle = main.battle_controller
    var campaign = main.campaign_controller
    var panel = main.campaign_panel
    campaign.debug_seed_chapter_camp(&"CH01", 0, battle.stage_data)
    await process_frame
    await process_frame

    battle.bond_service.apply_bond_delta(&"ally_serin", 5, "retreat_runner_s_rank")
    battle.bond_service.notify_unit_died(&"ally_serin", "Serin")
    await process_frame
    await process_frame

    var memorial_snapshot: Dictionary = panel.get_snapshot()
    if String(memorial_snapshot.get("mode", "")) != CampaignState.MODE_DEFEAT:
        push_error("S-rank ally death should surface a memorial scene in defeat mode.")
        await _teardown_main(main)
        return false
    if String(memorial_snapshot.get("title", "")).find("Memorial") == -1:
        push_error("Memorial scene title should include 'Memorial'.")
        await _teardown_main(main)
        return false
    if String(memorial_snapshot.get("body", "")).find("Serin") == -1:
        push_error("Memorial scene body should mention the fallen S-rank ally.")
        await _teardown_main(main)
        return false

    await _teardown_main(main)
    return true

func _force_current_battle_defeat(battle) -> bool:
    if battle == null:
        push_error("BattleController was unavailable during retreat runner setup.")
        return false
    var allies: Array = battle.ally_units.duplicate()
    for unit in allies:
        if unit == null or not is_instance_valid(unit):
            continue
        battle._on_unit_defeated(unit)
        await process_frame
    if not battle._check_battle_end():
        push_error("BattleController did not resolve defeat after all allies were removed.")
        return false
    if String(battle.last_result) != "defeat":
        push_error("BattleController should set last_result to 'defeat' when all allies fall.")
        return false
    return true

func _has_choice_option(snapshot: Dictionary, option_id: String) -> bool:
    for option in snapshot.get("choice_options", []):
        if typeof(option) != TYPE_DICTIONARY:
            continue
        if String(option.get("id", "")) == option_id:
            return true
    return false

func _party_detail_exists(snapshot: Dictionary, unit_id: String) -> bool:
    for entry in snapshot.get("party_details", []):
        if typeof(entry) != TYPE_DICTIONARY:
            continue
        if String(entry.get("unit_id", "")) == unit_id:
            return true
    return false

func _party_detail_has_recovering_label(snapshot: Dictionary, unit_id: String) -> bool:
    for entry in snapshot.get("party_details", []):
        if typeof(entry) != TYPE_DICTIONARY:
            continue
        if String(entry.get("unit_id", "")) != unit_id:
            continue
        return bool(entry.get("recovering", false)) and String(entry.get("recovering_label", "")).find("Recovering") != -1
    return false

func _build_test_stage(stage_id: StringName, ally_ids: Array[StringName]) -> StageData:
    var stage := StageData.new()
    stage.stage_id = stage_id
    stage.stage_title = String(stage_id)
    stage.grid_size = Vector2i(6, 6)
    stage.cell_size = Vector2i(64, 64)
    stage.ally_units = []
    stage.enemy_units = [ENEMY_SKIRMISHER]
    stage.ally_spawns = []
    stage.enemy_spawns = [Vector2i(3, 0)]
    stage.blocked_cells = []
    stage.interactive_objects = []
    var x_position := 0
    for ally_id in ally_ids:
        stage.ally_units.append(CampaignCatalog.get_unit_data(ally_id))
        stage.ally_spawns.append(Vector2i(x_position, 5))
        x_position += 1
    return stage
