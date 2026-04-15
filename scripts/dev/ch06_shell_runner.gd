extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH05_FINAL_STAGE = preload("res://data/stages/ch05_05_stage.tres")
const EXPECTED_CH06_ORDER := [&"CH06_01", &"CH06_02", &"CH06_03", &"CH06_04", &"CH06_05"]

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)

    await process_frame
    await process_frame

    var campaign = main.campaign_controller
    if campaign == null:
        push_error("CH06 shell runner could not resolve campaign controller.")
        quit(1)
        return

    campaign._active_chapter_id = &"CH05"
    campaign._active_stage_index = 4
    campaign._current_stage = CH05_FINAL_STAGE
    campaign._enter_chapter_five_camp()
    await process_frame
    await process_frame

    var camp_snapshot: Dictionary = main.get_campaign_state_snapshot()
    if String(camp_snapshot.get("mode", "")) != "camp":
        push_error("Expected CH05 camp before CH06 intro, got %s." % [camp_snapshot.get("mode", "")])
        quit(1)
        return

    main.advance_campaign_step()
    await process_frame
    await process_frame

    var intro_snapshot: Dictionary = main.get_campaign_state_snapshot()
    if String(intro_snapshot.get("mode", "")) != "chapter_intro":
        push_error("Expected CH06 chapter intro, got %s." % [intro_snapshot.get("mode", "")])
        quit(1)
        return

    if String(intro_snapshot.get("panel_title", "")).find("CH06") == -1:
        push_error("CH06 intro title did not surface.")
        quit(1)
        return

    if String(intro_snapshot.get("panel_body", "")).find("Valtor") == -1:
        push_error("CH06 intro body did not mention Valtor.")
        quit(1)
        return

    for stage_id in EXPECTED_CH06_ORDER:
        main.advance_campaign_step()
        await process_frame
        await process_frame

        var stage_snapshot: Dictionary = main.get_campaign_state_snapshot()
        if String(stage_snapshot.get("mode", "")) != "battle":
            push_error("Expected battle mode for %s, got %s." % [stage_id, stage_snapshot.get("mode", "")])
            quit(1)
            return

        if StringName(stage_snapshot.get("chapter_id", &"")) != &"CH06":
            push_error("Expected CH06 chapter id, got %s." % [stage_snapshot.get("chapter_id", &"")])
            quit(1)
            return

        if StringName(stage_snapshot.get("current_stage_id", &"")) != stage_id:
            push_error("Expected %s stage id, got %s." % [stage_id, stage_snapshot.get("current_stage_id", &"")])
            quit(1)
            return

        var battle = main.battle_controller
        if battle == null or battle.stage_data == null or StringName(battle.stage_data.stage_id) != stage_id:
            push_error("CH06 battle shell did not load %s stage data." % [stage_id])
            quit(1)
            return

        await _play_battle_to_victory(battle)
        await process_frame
        await process_frame

        var post_battle_snapshot: Dictionary = main.get_campaign_state_snapshot()
        if stage_id != EXPECTED_CH06_ORDER[-1]:
            if String(post_battle_snapshot.get("mode", "")) != "cutscene":
                push_error("Expected cutscene after %s, got %s." % [stage_id, post_battle_snapshot.get("mode", "")])
                quit(1)
                return
        else:
            if String(post_battle_snapshot.get("mode", "")) != "camp":
                push_error("Expected camp after %s, got %s." % [stage_id, post_battle_snapshot.get("mode", "")])
                quit(1)
                return

    var final_snapshot: Dictionary = main.get_campaign_state_snapshot()
    if String(final_snapshot.get("panel_title", "")).find("CH06") == -1:
        push_error("CH06 camp title did not surface.")
        quit(1)
        return

    var panel_body: String = String(final_snapshot.get("panel_body", ""))
    if panel_body.find("Valtor breach context memory") == -1:
        push_error("CH06 camp body did not mention the fortress breach memory.")
        quit(1)
        return

    if panel_body.find("Ellyor") == -1:
        push_error("CH06 camp body did not point toward Ellyor.")
        quit(1)
        return

    var presentation_cards: Array = main.campaign_panel.get_snapshot().get("presentation_cards", [])
    if presentation_cards.is_empty():
        push_error("CH06 camp snapshot did not expose presentation cards.")
        quit(1)
        return

    if String(presentation_cards[0].get("title", "")).find("Valtor") == -1:
        push_error("CH06 camp presentation cards did not expose the breach handoff.")
        quit(1)
        return

    await _cleanup_root_children()
    print("[PASS] CH06 shell runner reached CH06 intro, CH06_01~05 flow, and CH06 camp handoff.")
    quit(0)

func _play_battle_to_victory(battle) -> void:
    var max_round_loops: int = 40
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
        push_error("CH06 shell runner battle did not finish in victory. %s" % _describe_battle_state(battle))
        quit(1)
        return

func _wait_for_player_phase(battle) -> void:
    var safety: int = 0
    while not _is_battle_finished(battle):
        var phase: int = int(battle.current_phase)
        if phase == int(battle.BattlePhase.PLAYER_SELECT) or phase == int(battle.BattlePhase.PLAYER_ACTION_PREVIEW):
            return
        await process_frame
        safety += 1
        if safety > 180:
            push_error("Timed out waiting for player phase in CH06 shell runner.")
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

        var interaction_assignment: Dictionary = _pick_best_interaction_assignment(battle, ready_units)
        var unit = interaction_assignment.get("unit", ready_units[0])
        battle._on_world_cell_pressed(unit.grid_position)
        await process_frame

        var acted: bool = await _take_action_for_unit(
            battle,
            unit,
            interaction_assignment.get("destination", Vector2i(-1, -1))
        )
        if acted:
            return

        push_error("CH06 shell runner could not find a valid player action.")
        quit(1)
        return

func _take_action_for_unit(battle, unit, preferred_interaction_destination: Vector2i = Vector2i(-1, -1)) -> bool:
    var interaction_destination: Vector2i = preferred_interaction_destination
    if interaction_destination == Vector2i(-1, -1):
        interaction_destination = _pick_interaction_destination(battle, unit)
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

func _pick_best_interaction_assignment(battle, ready_units: Array) -> Dictionary:
    var best_assignment: Dictionary = {}
    var best_cost: int = 2147483647

    for unit in ready_units:
        var candidate: Dictionary = _pick_interaction_destination_with_cost(battle, unit)
        var destination: Vector2i = candidate.get("destination", Vector2i(-1, -1))
        if destination == Vector2i(-1, -1):
            continue

        var path_cost: int = int(candidate.get("path_cost", 0))
        if path_cost < best_cost:
            best_cost = path_cost
            best_assignment = {
                "unit": unit,
                "destination": destination
            }

    return best_assignment

func _pick_interaction_destination(battle, unit) -> Vector2i:
    return _pick_interaction_destination_with_cost(battle, unit).get("destination", Vector2i(-1, -1))

func _pick_interaction_destination_with_cost(battle, unit) -> Dictionary:
    var win_condition: String = String(battle.stage_data.win_condition)
    if win_condition != "resolve_all_interactions" and win_condition != "resolve_all_interactions_and_defeat_all_enemies":
        return {"destination": Vector2i(-1, -1), "path_cost": 2147483647}

    var unit_state: StringName = battle.turn_manager.get_unit_state(unit)
    if unit_state != battle.turn_manager.STATE_READY and unit_state != battle.turn_manager.STATE_MOVED:
        return {"destination": Vector2i(-1, -1), "path_cost": 2147483647}

    var best_destination := Vector2i(-1, -1)
    var best_cost: int = 2147483647
    var dynamic_blocked: Dictionary = battle._get_dynamic_blocked_cells(unit)

    for object_actor in battle.interactive_objects:
        if object_actor == null or not is_instance_valid(object_actor) or object_actor.is_resolved:
            continue

        if object_actor.can_interact(unit):
            return {"destination": unit.grid_position, "path_cost": 0}

        if unit_state != battle.turn_manager.STATE_READY:
            continue

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

    return {
        "destination": best_destination,
        "path_cost": best_cost
    }

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

func _is_battle_finished(battle) -> bool:
    var phase: int = int(battle.current_phase)
    return phase == int(battle.BattlePhase.VICTORY) or phase == int(battle.BattlePhase.DEFEAT)

func _describe_battle_state(battle) -> String:
    var object_states: Array[String] = []
    for object_actor in battle.interactive_objects:
        if object_actor == null or not is_instance_valid(object_actor):
            continue
        object_states.append("%s=%s" % [str(object_actor.object_data.object_id), str(object_actor.is_resolved)])

    return "stage=%s phase=%s enemies=%d objects=%s" % [
        str(battle.stage_data.stage_id),
        str(battle.current_phase),
        battle.enemy_units.size(),
        str(object_states)
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
