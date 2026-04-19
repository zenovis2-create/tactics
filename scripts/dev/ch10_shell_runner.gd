extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH09B_FINAL_STAGE = preload("res://data/stages/ch09b_05_stage.tres")
const CutsceneCatalog = preload("res://data/cutscenes/cutscene_catalog.gd")
const EXPECTED_CH10_ORDER := [&"CH10_01", &"CH10_02", &"CH10_03", &"CH10_04", &"CH10_05"]

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)

    await process_frame
    await process_frame

    var campaign = main.campaign_controller
    if campaign == null:
        push_error("CH10 shell runner could not resolve campaign controller.")
        quit(1)
        return

    campaign._active_chapter_id = &"CH09B"
    campaign._active_stage_index = 4
    campaign._current_stage = CH09B_FINAL_STAGE
    campaign._enter_chapter_nine_b_camp()
    await process_frame
    await process_frame

    var camp_snapshot: Dictionary = main.get_campaign_state_snapshot()
    if String(camp_snapshot.get("mode", "")) != "camp":
        push_error("Expected CH09B camp before CH10 intro, got %s." % [camp_snapshot.get("mode", "")])
        quit(1)
        return

    main.advance_campaign_step()
    await process_frame
    await process_frame

    var intro_snapshot: Dictionary = main.get_campaign_state_snapshot()
    if String(intro_snapshot.get("mode", "")) != "chapter_intro":
        push_error("Expected CH10 chapter intro, got %s." % [intro_snapshot.get("mode", "")])
        quit(1)
        return

    if String(intro_snapshot.get("panel_title", "")).find("CH10") == -1:
        push_error("CH10 intro title did not surface.")
        quit(1)
        return

    if String(intro_snapshot.get("panel_body", "")).find("tower") == -1 and String(intro_snapshot.get("panel_body", "")).find("Tower") == -1:
        push_error("CH10 intro body did not mention the final tower.")
        quit(1)
        return

    for stage_id in EXPECTED_CH10_ORDER:
        main.advance_campaign_step()
        await process_frame
        await process_frame

        var stage_snapshot: Dictionary = main.get_campaign_state_snapshot()
        if String(stage_snapshot.get("mode", "")) != "battle":
            push_error("Expected battle mode for %s, got %s." % [stage_id, stage_snapshot.get("mode", "")])
            quit(1)
            return

        if StringName(stage_snapshot.get("chapter_id", &"")) != &"CH10":
            push_error("Expected CH10 chapter id, got %s." % [stage_snapshot.get("chapter_id", &"")])
            quit(1)
            return

        if StringName(stage_snapshot.get("current_stage_id", &"")) != stage_id:
            push_error("Expected %s stage id, got %s." % [stage_id, stage_snapshot.get("current_stage_id", &"")])
            quit(1)
            return

        var battle = main.battle_controller
        if battle == null or battle.stage_data == null or StringName(battle.stage_data.stage_id) != stage_id:
            push_error("CH10 battle shell did not load %s stage data." % [stage_id])
            quit(1)
            return

        if StringName(battle.stage_data.start_cutscene_id) != _get_stage_intro_cutscene_id(stage_id):
            push_error("CH10 stage %s intro cutscene id mismatch: expected %s, got %s." % [stage_id, _get_stage_intro_cutscene_id(stage_id), battle.stage_data.start_cutscene_id])
            quit(1)
            return

        if StringName(battle.stage_data.clear_cutscene_id) != _get_stage_outro_cutscene_id(stage_id):
            push_error("CH10 stage %s clear cutscene id mismatch: expected %s, got %s." % [stage_id, _get_stage_outro_cutscene_id(stage_id), battle.stage_data.clear_cutscene_id])
            quit(1)
            return

        if CutsceneCatalog.get_cutscene(battle.stage_data.start_cutscene_id) == null:
            push_error("CH10 intro cutscene %s is not registered in the catalog." % [battle.stage_data.start_cutscene_id])
            quit(1)
            return

        if CutsceneCatalog.get_cutscene(battle.stage_data.clear_cutscene_id) == null:
            push_error("CH10 clear cutscene %s is not registered in the catalog." % [battle.stage_data.clear_cutscene_id])
            quit(1)
            return

        if not _has_cutscene_start(battle.cutscene_player.get_event_log(), _get_stage_intro_cutscene_id(stage_id)):
            push_error("CH10 shell did not start CH10 intro cutscene %s." % [_get_stage_intro_cutscene_id(stage_id)])
            quit(1)
            return

        var cutscene_log_before_victory: int = battle.cutscene_player.get_event_log().size()

        await _play_battle_to_victory(battle, stage_id)
        await process_frame
        await process_frame

        if stage_id == &"CH10_05":
            var finale_summary: Dictionary = battle.get_last_result_summary()
            if not finale_summary.has("finale_result"):
                push_error("CH10_05 result summary did not expose finale_result payload.")
                quit(1)
                return
            var finale_result: Dictionary = finale_summary.get("finale_result", {})
            for key in [
                "name_anchor_total",
                "name_anchors_remaining",
                "name_call_moments_fired",
                "required_name_call_count",
                "minimum_anchor_condition_met"
            ]:
                if not finale_result.has(key):
                    push_error("CH10_05 finale result payload missing key: %s." % key)
                    quit(1)
                    return

            if int(finale_result.get("name_anchor_total", 0)) != 4:
                push_error("CH10_05 finale result should report four total name anchors, got %s." % [finale_result.get("name_anchor_total", 0)])
                quit(1)
                return

            if int(finale_result.get("name_anchors_remaining", -1)) != 2:
                push_error("CH10_05 shell runner expected two anchors remaining after Karon's phase shifts, got %s." % [finale_result.get("name_anchors_remaining", -1)])
                quit(1)
                return

            if int(finale_result.get("required_name_call_count", 0)) != 6:
                push_error("CH10_05 finale result should require six name-call moments for the true route, got %s." % [finale_result.get("required_name_call_count", 0)])
                quit(1)
                return

            if int(finale_result.get("name_call_moments_fired", -1)) != 1:
                push_error("CH10_05 shell runner expected exactly one live name-call moment in the current authored clear flow, got %s." % [finale_result.get("name_call_moments_fired", -1)])
                quit(1)
                return

            if not bool(finale_result.get("minimum_anchor_condition_met", false)):
                push_error("CH10_05 finale result should satisfy the current minimum anchor condition with two anchors remaining.")
                quit(1)
                return

        var victory_cutscene_entries: Array[Dictionary] = battle.cutscene_player.get_event_log().slice(cutscene_log_before_victory)
        if not _has_cutscene_start(victory_cutscene_entries, _get_stage_outro_cutscene_id(stage_id)):
            push_error("CH10 shell did not start CH10 clear cutscene %s." % [_get_stage_outro_cutscene_id(stage_id)])
            quit(1)
            return

        var post_battle_snapshot: Dictionary = main.get_campaign_state_snapshot()
        if stage_id != EXPECTED_CH10_ORDER[-1]:
            if String(post_battle_snapshot.get("mode", "")) != "cutscene":
                push_error("Expected cutscene after %s, got %s." % [stage_id, post_battle_snapshot.get("mode", "")])
                quit(1)
                return
        elif String(post_battle_snapshot.get("mode", "")) != "complete":
            push_error("Expected complete after %s, got %s." % [stage_id, post_battle_snapshot.get("mode", "")])
            quit(1)
            return

    var final_snapshot: Dictionary = main.get_campaign_state_snapshot()
    if String(final_snapshot.get("mode", "")) != "complete":
        push_error("Expected complete after CH10 final stage, got %s." % [final_snapshot.get("mode", "")])
        quit(1)
        return

    var final_title: String = String(final_snapshot.get("panel_title", ""))
    if final_title.find("CH10") == -1:
        push_error("CH10 final title did not surface.")
        quit(1)
        return

    if final_title.find("Final Resolution") == -1:
        push_error("CH10 final title should surface the normal-resolution branch for the current authored clear flow.")
        quit(1)
        return

    var panel_body: String = String(final_snapshot.get("panel_body", ""))
    if panel_body.find("bell") == -1 and panel_body.find("Bell") == -1:
        push_error("CH10 final body did not mention the bell resolution.")
        quit(1)
        return

    if panel_body.find("names") == -1 and panel_body.find("Names") == -1:
        push_error("CH10 final body did not mention the survival of names.")
        quit(1)
        return

    var presentation_cards: Array = main.campaign_panel.get_snapshot().get("presentation_cards", [])
    if presentation_cards.is_empty():
        push_error("CH10 final snapshot did not expose resolution presentation cards.")
        quit(1)
        return

    if String(presentation_cards[0].get("title", "")).find("Bell") == -1:
        push_error("CH10 final presentation cards did not expose the bell resolution.")
        quit(1)
        return

    if presentation_cards.size() < 2 or String(presentation_cards[1].get("title", "")).find("One Name Bears The Weight") == -1:
        push_error("CH10 final presentation cards did not expose the normal-resolution burden card.")
        quit(1)
        return

    if not main.advance_campaign_step():
        push_error("CH10 shell runner expected a post-clear epilogue step after the resolution panel.")
        quit(1)
        return

    await process_frame
    await process_frame

    var epilogue_snapshot: Dictionary = main.get_campaign_state_snapshot()
    if String(epilogue_snapshot.get("mode", "")) != "complete":
        push_error("Expected CH10 epilogue shell to remain in complete mode, got %s." % [epilogue_snapshot.get("mode", "")])
        quit(1)
        return

    var epilogue_title: String = String(epilogue_snapshot.get("panel_title", ""))
    if epilogue_title.find("CH10") == -1 or epilogue_title.find("Epilogue") == -1:
        push_error("CH10 post-clear epilogue title did not surface.")
        quit(1)
        return

    var epilogue_body: String = String(epilogue_snapshot.get("panel_body", ""))
    if epilogue_body.find("remember") == -1 and epilogue_body.find("Remember") == -1:
        push_error("CH10 epilogue body did not mention remembering what survives.")
        quit(1)
        return

    if epilogue_body.find("name") == -1 and epilogue_body.find("Name") == -1:
        push_error("CH10 epilogue body did not mention names surviving the tower.")
        quit(1)
        return

    var epilogue_cards: Array = main.campaign_panel.get_snapshot().get("presentation_cards", [])
    if epilogue_cards.size() < 2:
        push_error("CH10 epilogue snapshot did not expose dedicated presentation cards.")
        quit(1)
        return

    if String(epilogue_cards[0].get("title", "")).find("What Was Left") == -1:
        push_error("CH10 epilogue presentation cards did not expose the immediate aftermath card.")
        quit(1)
        return

    if String(epilogue_cards[1].get("title", "")).find("Neri") == -1:
        push_error("CH10 epilogue presentation cards did not expose the surviving-name card.")
        quit(1)
        return

    if main.advance_campaign_step():
        push_error("CH10 shell runner should stop advancing after the dedicated epilogue shell.")
        quit(1)
        return

    await _cleanup_root_children()
    print("[PASS] CH10 shell runner reached CH10 intro, CH10_01~05 flow, final resolution, and post-clear epilogue shell.")
    quit(0)

func _play_battle_to_victory(battle, stage_id: StringName) -> void:
    var stage_id_text: String = String(stage_id)
    var win_condition: String = String(battle.stage_data.win_condition) if battle != null and battle.stage_data != null else ""
    if win_condition == "resolve_all_interactions" or win_condition == "resolve_all_interactions_and_defeat_all_enemies":
        _force_resolve_all_interactions(battle)
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
        push_error("CH10 shell runner battle did not finish in victory for %s. %s" % [stage_id_text, _describe_battle_state(battle)])
        quit(1)
        return

func _force_resolve_all_interactions(battle) -> void:
    if battle.ally_units.is_empty():
        return

    var ally = battle.ally_units[0]
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
            push_error("Timed out waiting for player phase in CH10 shell runner.")
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

        push_error("CH10 shell runner could not find a valid player action.")
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
    if win_condition != "resolve_all_interactions" and win_condition != "resolve_all_interactions_and_defeat_all_enemies":
        return Vector2i(-1, -1)

    var best_destination := Vector2i(-1, -1)
    var best_cost: int = 2147483647
    var dynamic_blocked: Dictionary = battle._get_dynamic_blocked_cells(unit)

    for object_actor in battle.interactive_objects:
        if object_actor == null or not is_instance_valid(object_actor) or object_actor.is_resolved:
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
        if object_actor == null or not is_instance_valid(object_actor) or object_actor.is_resolved:
            continue
        if battle._can_selected_unit_interact(object_actor):
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

func _describe_battle_state(battle) -> String:
    return "stage=%s phase=%s enemies=%d" % [
        str(battle.stage_data.stage_id),
        str(battle.current_phase),
        battle.enemy_units.size()
    ]

func _cleanup_root_children() -> void:
    for child in root.get_children():
        if child == null or not is_instance_valid(child):
            continue
        if child == current_scene:
            continue
        child.queue_free()
    await process_frame
    await process_frame
