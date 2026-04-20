extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CutsceneCatalog = preload("res://data/cutscenes/cutscene_catalog.gd")
const CH08_FINAL_STAGE = preload("res://data/stages/ch08_05_stage.tres")
const EXPECTED_CH09A_ORDER := [&"CH09A_01", &"CH09A_02", &"CH09A_03", &"CH09A_04", &"CH09A_05"]
const EXPECTED_CH09B_ORDER := [&"CH09B_01", &"CH09B_02", &"CH09B_03", &"CH09B_04", &"CH09B_05"]

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)

    await process_frame
    await process_frame

    var campaign = main.campaign_controller
    if campaign == null:
        push_error("CH09 shell runner could not resolve campaign controller.")
        quit(1)
        return

    campaign._active_chapter_id = &"CH08"
    campaign._active_stage_index = 4
    campaign._current_stage = CH08_FINAL_STAGE
    campaign._enter_chapter_eight_camp()
    await process_frame
    await process_frame

    var camp_snapshot: Dictionary = main.get_campaign_state_snapshot()
    if String(camp_snapshot.get("mode", "")) != "camp":
        push_error("Expected CH08 camp before CH09A intro, got %s." % [camp_snapshot.get("mode", "")])
        quit(1)
        return

    main.advance_campaign_step()
    await process_frame
    await process_frame

    var intro_snapshot: Dictionary = main.get_campaign_state_snapshot()
    if String(intro_snapshot.get("mode", "")) != "chapter_intro":
        push_error("Expected CH09A chapter intro, got %s." % [intro_snapshot.get("mode", "")])
        quit(1)
        return

    if String(intro_snapshot.get("panel_title", "")).find("CH09A") == -1:
        push_error("CH09A intro title did not surface.")
        quit(1)
        return

    for stage_id in EXPECTED_CH09A_ORDER:
        main.advance_campaign_step()
        await process_frame
        await process_frame

        var stage_snapshot: Dictionary = main.get_campaign_state_snapshot()
        if stage_id == &"CH09A_05" and String(stage_snapshot.get("mode", "")) == "choice":
            main.campaign_controller._make_choice("ch09a_public_testimony")
            await process_frame
            await process_frame
            stage_snapshot = main.get_campaign_state_snapshot()

        if String(stage_snapshot.get("mode", "")) != "battle":
            push_error("Expected battle mode for %s, got %s." % [stage_id, stage_snapshot.get("mode", "")])
            quit(1)
            return

        if StringName(stage_snapshot.get("chapter_id", &"")) != &"CH09A":
            push_error("Expected CH09A chapter id, got %s." % [stage_snapshot.get("chapter_id", &"")])
            quit(1)
            return

        if StringName(stage_snapshot.get("current_stage_id", &"")) != stage_id:
            push_error("Expected %s stage id, got %s." % [stage_id, stage_snapshot.get("current_stage_id", &"")])
            quit(1)
            return

        var battle = main.battle_controller
        if battle == null or battle.stage_data == null or StringName(battle.stage_data.stage_id) != stage_id:
            push_error("CH09A battle shell did not load %s stage data." % [stage_id])
            quit(1)
            return

        if StringName(battle.stage_data.start_cutscene_id) != _get_stage_intro_cutscene_id(stage_id):
            push_error("CH09A stage %s intro cutscene id mismatch: expected %s, got %s." % [stage_id, _get_stage_intro_cutscene_id(stage_id), battle.stage_data.start_cutscene_id])
            quit(1)
            return

        if StringName(battle.stage_data.clear_cutscene_id) != _get_stage_outro_cutscene_id(stage_id):
            push_error("CH09A stage %s clear cutscene id mismatch: expected %s, got %s." % [stage_id, _get_stage_outro_cutscene_id(stage_id), battle.stage_data.clear_cutscene_id])
            quit(1)
            return

        if CutsceneCatalog.get_cutscene(battle.stage_data.start_cutscene_id) == null:
            push_error("CH09A intro cutscene %s is not registered in the catalog." % [battle.stage_data.start_cutscene_id])
            quit(1)
            return

        if CutsceneCatalog.get_cutscene(battle.stage_data.clear_cutscene_id) == null:
            push_error("CH09A clear cutscene %s is not registered in the catalog." % [battle.stage_data.clear_cutscene_id])
            quit(1)
            return

        if stage_id == &"CH09A_04":
            if StringName(battle.stage_data.win_condition) != &"rescue_quota":
                push_error("CH09A_04 should use the rescue quota win condition.")
                quit(1)
                return

            if battle.stage_data.interactive_objects.size() != 1:
                push_error("CH09A_04 should expose exactly one central-lift anchor in this reduced slice.")
                quit(1)
                return

            if int(battle.stage_data.rescue_objective_required_count) != 1:
                push_error("CH09A_04 should require securing exactly one central-lift anchor.")
                quit(1)
                return

            var expected_object_ids: Array[StringName] = [&"ch09a_04_central_officer_release_point"]
            if battle.stage_data.rescue_objective_object_ids != expected_object_ids:
                push_error("CH09A_04 rescue objective ids drifted from the authored central-lift anchor.")
                quit(1)
                return

            for expected_object_id in expected_object_ids:
                var found: bool = false
                for object_data in battle.stage_data.interactive_objects:
                    if StringName(object_data.object_id) == expected_object_id:
                        found = true
                        if object_data.grid_position.x < 0 or object_data.grid_position.x >= battle.stage_data.grid_size.x or object_data.grid_position.y < 0 or object_data.grid_position.y >= battle.stage_data.grid_size.y:
                            push_error("CH09A_04 authored anchor %s must stay on-board." % [expected_object_id])
                            quit(1)
                            return
                        break
                if not found:
                    push_error("CH09A_04 is missing authored anchor %s." % [expected_object_id])
                    quit(1)
                    return

        if not _has_cutscene_start(battle.cutscene_player.get_event_log(), _get_stage_intro_cutscene_id(stage_id)):
            push_error("CH09 shell did not start CH09A intro cutscene %s." % [_get_stage_intro_cutscene_id(stage_id)])
            quit(1)
            return

        var cutscene_log_before_victory: int = battle.cutscene_player.get_event_log().size()

        await _play_battle_to_victory(battle, stage_id)
        await process_frame
        await process_frame

        var victory_cutscene_entries: Array[Dictionary] = battle.cutscene_player.get_event_log().slice(cutscene_log_before_victory)
        if not _has_cutscene_start(victory_cutscene_entries, _get_stage_outro_cutscene_id(stage_id)):
            push_error("CH09 shell did not start CH09A clear cutscene %s." % [_get_stage_outro_cutscene_id(stage_id)])
            quit(1)
            return

        var post_battle_snapshot: Dictionary = main.get_campaign_state_snapshot()
        if stage_id != EXPECTED_CH09A_ORDER[-1]:
            if String(post_battle_snapshot.get("mode", "")) != "cutscene":
                push_error("Expected cutscene after %s, got %s." % [stage_id, post_battle_snapshot.get("mode", "")])
                quit(1)
                return
        elif String(post_battle_snapshot.get("mode", "")) != "camp":
            push_error("Expected camp after %s, got %s." % [stage_id, post_battle_snapshot.get("mode", "")])
            quit(1)
            return
    var part_a_snapshot: Dictionary = main.get_campaign_state_snapshot()
    if String(part_a_snapshot.get("mode", "")) != "camp":
        push_error("Expected CH09A camp after Part I, got %s." % [part_a_snapshot.get("mode", "")])
        quit(1)
        return

    if String(part_a_snapshot.get("panel_title", "")).find("CH09A") == -1:
        push_error("CH09A camp title did not surface.")
        quit(1)
        return

    if String(part_a_snapshot.get("panel_body", "")).find("root archive") == -1 and String(part_a_snapshot.get("panel_body", "")).find("Root archive") == -1:
        push_error("CH09A camp body did not point toward the root archive.")
        quit(1)
        return

    var part_a_body: String = String(part_a_snapshot.get("panel_body", ""))
    if part_a_body.find("root-archive pass") == -1 or part_a_body.find("movement ledger") == -1:
        push_error("CH09A camp body did not surface the CH09A_05 handoff proof text.")
        quit(1)
        return

    var part_a_roster: Array = main.campaign_panel.get_snapshot().get("party_details", [])
    if not _party_contains_name(part_a_roster, "Karl"):
        push_error("CH09A camp roster did not include Karl.")
        quit(1)
        return

    var part_a_cards: Array = main.campaign_panel.get_snapshot().get("presentation_cards", [])
    if part_a_cards.is_empty():
        push_error("CH09A camp snapshot did not expose presentation cards.")
        quit(1)
        return

    if String(part_a_cards[0].get("title", "")).find("Karl") == -1:
        push_error("CH09A camp presentation cards did not expose Karl's handoff.")
        quit(1)
        return

    if String(part_a_cards[0].get("body", "")).find("root-archive pass") == -1 or String(part_a_cards[0].get("body", "")).find("movement ledger") == -1:
        push_error("CH09A camp presentation cards did not align with the CH09A_05 archive handoff text.")
        quit(1)
        return

    main.advance_campaign_step()
    await process_frame
    await process_frame

    var intro_b_snapshot: Dictionary = main.get_campaign_state_snapshot()
    if String(intro_b_snapshot.get("mode", "")) != "chapter_intro":
        push_error("Expected CH09B chapter intro, got %s." % [intro_b_snapshot.get("mode", "")])
        quit(1)
        return

    if String(intro_b_snapshot.get("panel_title", "")).find("CH09B") == -1:
        push_error("CH09B intro title did not surface.")
        quit(1)
        return

    for stage_id in EXPECTED_CH09B_ORDER:
        main.advance_campaign_step()
        await process_frame
        await process_frame

        var stage_snapshot_b: Dictionary = main.get_campaign_state_snapshot()
        if String(stage_snapshot_b.get("mode", "")) != "battle":
            push_error("Expected battle mode for %s, got %s." % [stage_id, stage_snapshot_b.get("mode", "")])
            quit(1)
            return

        if StringName(stage_snapshot_b.get("chapter_id", &"")) != &"CH09B":
            push_error("Expected CH09B chapter id, got %s." % [stage_snapshot_b.get("chapter_id", &"")])
            quit(1)
            return

        if StringName(stage_snapshot_b.get("current_stage_id", &"")) != stage_id:
            push_error("Expected %s stage id, got %s." % [stage_id, stage_snapshot_b.get("current_stage_id", &"")])
            quit(1)
            return

        var battle_b = main.battle_controller
        if battle_b == null or battle_b.stage_data == null or StringName(battle_b.stage_data.stage_id) != stage_id:
            push_error("CH09B battle shell did not load %s stage data." % [stage_id])
            quit(1)
            return

        if StringName(battle_b.stage_data.start_cutscene_id) != _get_stage_intro_cutscene_id(stage_id):
            push_error("CH09B stage %s intro cutscene id mismatch: expected %s, got %s." % [stage_id, _get_stage_intro_cutscene_id(stage_id), battle_b.stage_data.start_cutscene_id])
            quit(1)
            return

        if StringName(battle_b.stage_data.clear_cutscene_id) != _get_stage_outro_cutscene_id(stage_id):
            push_error("CH09B stage %s clear cutscene id mismatch: expected %s, got %s." % [stage_id, _get_stage_outro_cutscene_id(stage_id), battle_b.stage_data.clear_cutscene_id])
            quit(1)
            return

        if CutsceneCatalog.get_cutscene(battle_b.stage_data.start_cutscene_id) == null:
            push_error("CH09B intro cutscene %s is not registered in the catalog." % [battle_b.stage_data.start_cutscene_id])
            quit(1)
            return

        if CutsceneCatalog.get_cutscene(battle_b.stage_data.clear_cutscene_id) == null:
            push_error("CH09B clear cutscene %s is not registered in the catalog." % [battle_b.stage_data.clear_cutscene_id])
            quit(1)
            return

        if not _has_cutscene_start(battle_b.cutscene_player.get_event_log(), _get_stage_intro_cutscene_id(stage_id)):
            push_error("CH09 shell did not start CH09B intro cutscene %s." % [_get_stage_intro_cutscene_id(stage_id)])
            quit(1)
            return

        var cutscene_log_before_victory_b: int = battle_b.cutscene_player.get_event_log().size()

        await _play_battle_to_victory(battle_b, stage_id)
        await process_frame
        await process_frame

        var victory_cutscene_entries_b: Array[Dictionary] = battle_b.cutscene_player.get_event_log().slice(cutscene_log_before_victory_b)
        if not _has_cutscene_start(victory_cutscene_entries_b, _get_stage_outro_cutscene_id(stage_id)):
            push_error("CH09 shell did not start CH09B clear cutscene %s." % [_get_stage_outro_cutscene_id(stage_id)])
            quit(1)
            return

        var post_battle_snapshot_b: Dictionary = main.get_campaign_state_snapshot()
        if stage_id != EXPECTED_CH09B_ORDER[-1]:
            if String(post_battle_snapshot_b.get("mode", "")) != "cutscene":
                push_error("Expected cutscene after %s, got %s." % [stage_id, post_battle_snapshot_b.get("mode", "")])
                quit(1)
                return
        elif String(post_battle_snapshot_b.get("mode", "")) != "camp":
            push_error("Expected camp after %s, got %s." % [stage_id, post_battle_snapshot_b.get("mode", "")])
            quit(1)
            return

    var final_snapshot: Dictionary = main.get_campaign_state_snapshot()
    if String(final_snapshot.get("mode", "")) != "camp":
        push_error("Expected CH09B camp after Part II, got %s." % [final_snapshot.get("mode", "")])
        quit(1)
        return

    if String(final_snapshot.get("panel_title", "")).find("CH09B") == -1:
        push_error("CH09B camp title did not surface.")
        quit(1)
        return

    var panel_body: String = String(final_snapshot.get("panel_body", ""))
    if panel_body.find("burden") == -1 or panel_body.find("not absolution") == -1:
        push_error("CH09B camp body did not surface the sharpened burden-not-absolution payoff.")
        quit(1)
        return

    if panel_body.find("last decree") == -1 or panel_body.find("march") == -1 or panel_body.find("final tower") == -1:
        push_error("CH09B camp body did not surface the proof-and-march handoff language.")
        quit(1)
        return

    var final_roster: Array = main.campaign_panel.get_snapshot().get("party_details", [])
    if not _party_contains_name(final_roster, "Noah"):
        push_error("CH09B camp roster did not include Noah.")
        quit(1)
        return

    var final_cards: Array = main.campaign_panel.get_snapshot().get("presentation_cards", [])
    if final_cards.is_empty():
        push_error("CH09B camp snapshot did not expose presentation cards.")
        quit(1)
        return

    if String(final_cards[0].get("title", "")).find("Noah") == -1:
        push_error("CH09B camp presentation cards did not expose Noah's handoff.")
        quit(1)
        return

    var final_card_one_body: String = String(final_cards[0].get("body", ""))
    if final_card_one_body.find("burden") == -1 or final_card_one_body.find("not absolution") == -1:
        push_error("CH09B Noah card did not preserve the burden-not-absolution payoff language.")
        quit(1)
        return

    if final_cards.size() < 2:
        push_error("CH09B camp snapshot did not expose the destination payoff card.")
        quit(1)
        return

    var final_card_two_title: String = String(final_cards[1].get("title", ""))
    var final_card_two_body: String = String(final_cards[1].get("body", ""))
    if final_card_two_title.find("March") == -1 or final_card_two_body.find("last decree") == -1 or final_card_two_body.find("committed march") == -1:
        push_error("CH09B destination card did not assert the strengthened proof-and-march wording.")
        quit(1)
        return

    print("[PASS] CH09 shell runner reached CH09A and CH09B shell flows with both handoffs.")
    quit(0)

func _party_contains_name(party_details: Array, expected_name: String) -> bool:
    for entry in party_details:
        if typeof(entry) == TYPE_DICTIONARY and String(entry.get("name", "")) == expected_name:
            return true
    return false

func _play_battle_to_victory(battle, stage_id: StringName) -> void:
    var stage_id_text: String = String(stage_id)
    var win_condition: String = String(battle.stage_data.win_condition) if battle != null and battle.stage_data != null else ""
    if win_condition == "resolve_all_interactions" or win_condition == "resolve_all_interactions_and_defeat_all_enemies" or win_condition == "rescue_quota":
        _force_resolve_stage_objective(battle)
        await process_frame
        await process_frame
        if _is_battle_finished(battle):
            return

    var max_round_loops: int = 20
    for _round_loop in range(max_round_loops):
        await _wait_for_player_phase(battle)
        if _is_battle_finished(battle):
            break

        await _play_player_phase(battle)
        await process_frame
        await process_frame

        if _is_battle_finished(battle):
            break

    if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
        push_error("CH09 shell runner battle did not finish in victory for %s." % [stage_id_text])
        quit(1)
        return

func _force_resolve_stage_objective(battle) -> void:
    if battle.ally_units.is_empty():
        return

    var ally = battle.ally_units[0]
    if String(battle.stage_data.win_condition) == "rescue_quota":
        for object_id in battle.stage_data.rescue_objective_object_ids:
            var object_actor = _find_object_by_id(battle, object_id)
            if object_actor == null or object_actor.is_resolved:
                continue
            battle._resolve_interaction(ally, object_actor)
            if battle._check_battle_end():
                return
    else:
        for object_actor in battle.interactive_objects:
            if object_actor == null or not is_instance_valid(object_actor) or object_actor.is_resolved:
                continue
            battle._resolve_interaction(ally, object_actor)

    battle._check_battle_end()

func _wait_for_player_phase(battle) -> void:
    var safety: int = 0
    while not _is_battle_finished(battle):
        var phase: int = int(battle.current_phase)
        if phase == int(battle.BattlePhase.PLAYER_SELECT) or phase == int(battle.BattlePhase.PLAYER_ACTION_PREVIEW):
            return
        await process_frame
        safety += 1
        if safety > 180:
            push_error("Timed out waiting for player phase in CH09 shell runner.")
            quit(1)
            return

func _play_player_phase(battle) -> void:
    while true:
        if _is_battle_finished(battle):
            return

        var ready_units: Array = _get_ready_ally_units(battle)
        if ready_units.is_empty():
            battle._on_end_turn_requested()
            await process_frame
            return

        var unit = ready_units[0]
        battle._on_world_cell_pressed(unit.grid_position)
        await process_frame

        var acted: bool = await _take_action_for_unit(battle, unit)
        if acted:
            return

        push_error("CH09 shell runner could not find a valid player action.")
        quit(1)
        return

func _take_action_for_unit(battle, unit) -> bool:
    var interaction_destination: Vector2i = _pick_interaction_destination(battle, unit)
    if interaction_destination != Vector2i(-1, -1):
        if interaction_destination != unit.grid_position:
            battle._on_world_cell_pressed(interaction_destination)
            await process_frame

        var interactable = _find_interactable_object_for_selected_unit(battle)
        if interactable != null:
            battle._on_world_cell_pressed(interactable.grid_position)
            await process_frame
            return true

    var opponents: Array = battle.enemy_units
    var dynamic_blocked: Dictionary = battle._get_dynamic_blocked_cells(unit)
    var plan: Dictionary = battle.ai_service.pick_action(unit, opponents, battle.path_service, battle.range_service, dynamic_blocked)
    var action_type: String = String(plan.get("type", "wait"))

    if action_type == "attack":
        var immediate_target = plan.get("target", null)
        if immediate_target != null:
            battle._on_world_cell_pressed(immediate_target.grid_position)
            await process_frame
            return true

    if action_type == "move_attack":
        var move_to: Vector2i = plan.get("move_to", unit.grid_position)
        if move_to != unit.grid_position:
            battle._on_world_cell_pressed(move_to)
            await process_frame

        var target = plan.get("target", null)
        if target != null:
            battle._on_world_cell_pressed(target.grid_position)
            await process_frame
            return true

    if action_type == "move_wait":
        var wait_destination: Vector2i = plan.get("move_to", unit.grid_position)
        if wait_destination != unit.grid_position:
            battle._on_world_cell_pressed(wait_destination)
            await process_frame

        battle._on_wait_requested()
        await process_frame
        return true

    battle._on_wait_requested()
    await process_frame
    return true

func _pick_interaction_destination(battle, unit) -> Vector2i:
    var win_condition: String = String(battle.stage_data.win_condition)
    if win_condition != "resolve_all_interactions" and win_condition != "resolve_all_interactions_and_defeat_all_enemies" and win_condition != "rescue_quota":
        return Vector2i(-1, -1)

    var best_destination := Vector2i(-1, -1)
    var best_cost: int = 2147483647
    var dynamic_blocked: Dictionary = battle._get_dynamic_blocked_cells(unit)

    for object_actor in battle.interactive_objects:
        if object_actor == null or not is_instance_valid(object_actor) or object_actor.is_resolved or not _is_objective_interaction_target(battle, object_actor):
            continue

        if object_actor.can_interact(unit):
            return unit.grid_position

        var candidate_cells: Array = battle.range_service.get_attack_cells(object_actor.grid_position, object_actor.object_data.interaction_range)
        for cell in candidate_cells:
            if not battle.path_service.is_walkable(cell, dynamic_blocked):
                continue

            var path: Array = battle.path_service.find_path(unit.grid_position, cell, dynamic_blocked)
            if path.is_empty():
                continue

            var path_cost: int = battle.path_service.get_path_cost(path)
            if path_cost < best_cost:
                best_cost = path_cost
                best_destination = battle.ai_service._truncate_path_to_movement(path, unit.get_movement(), battle.path_service)

    return best_destination

func _find_interactable_object_for_selected_unit(battle):
    for object_actor in battle.interactive_objects:
        if object_actor == null or not is_instance_valid(object_actor) or object_actor.is_resolved or not _is_objective_interaction_target(battle, object_actor):
            continue
        if battle._can_selected_unit_interact(object_actor):
            return object_actor
    return null

func _is_objective_interaction_target(battle, object_actor) -> bool:
    if object_actor == null or object_actor.object_data == null:
        return false

    if String(battle.stage_data.win_condition) != "rescue_quota":
        return true

    return battle.stage_data.rescue_objective_object_ids.has(StringName(object_actor.object_data.object_id))

func _find_object_by_id(battle, object_id: StringName):
    for object_actor in battle.interactive_objects:
        if object_actor != null and is_instance_valid(object_actor) and object_actor.object_data != null and StringName(object_actor.object_data.object_id) == object_id:
            return object_actor
    return null

func _get_ready_ally_units(battle) -> Array:
    var ready_units: Array = []
    for unit in battle.ally_units:
        if is_instance_valid(unit) and not unit.is_defeated() and battle.turn_manager.can_unit_act(unit):
            ready_units.append(unit)
    return ready_units

func _has_cutscene_start(log: Array[Dictionary], cutscene_id: StringName) -> bool:
    for entry in log:
        if entry.get("event", "") == "cutscene_started" and entry.get("id", &"") == cutscene_id:
            return true
    return false

func _get_stage_intro_cutscene_id(stage_id: StringName) -> StringName:
    return StringName("%s_intro" % String(stage_id).to_lower())

func _get_stage_outro_cutscene_id(stage_id: StringName) -> StringName:
    return StringName("%s_outro" % String(stage_id).to_lower())

func _is_battle_finished(battle) -> bool:
    var phase: int = int(battle.current_phase)
    return phase == int(battle.BattlePhase.VICTORY) or phase == int(battle.BattlePhase.DEFEAT)
