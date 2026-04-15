extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const EXPECTED_STAGE_ORDER := [&"CH01_02", &"CH01_03", &"CH01_04", &"CH01_05"]
const CUTSCENE_KEYWORDS := {
    &"CH01_02": ["retreat officer", "Ruined Well"],
    &"CH01_03": ["cold command voice", "North Gate"],
    &"CH01_04": ["weak point of the gate", "Dawn Oath"]
}

var _wait_tested: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)

    await process_frame
    await process_frame

    if not main.has_method("get_campaign_state_snapshot"):
        push_error("Main is missing campaign shell snapshot API.")
        quit(1)
        return

    if not main.has_method("advance_campaign_step"):
        push_error("Main is missing campaign shell advance API.")
        quit(1)
        return

    for stage_id in EXPECTED_STAGE_ORDER:
        var snapshot: Dictionary = main.get_campaign_state_snapshot()
        if String(snapshot.get("mode", "")) != "battle":
            push_error("Expected battle mode before stage %s, got %s." % [stage_id, snapshot.get("mode", "")])
            quit(1)
            return

        if StringName(snapshot.get("current_stage_id", &"")) != stage_id:
            push_error("Expected stage %s, got %s." % [stage_id, snapshot.get("current_stage_id", &"")])
            quit(1)
            return

        var battle = main.battle_controller
        if battle == null:
            push_error("Main is missing battle_controller reference.")
            quit(1)
            return

        await _play_battle_to_victory(battle)
        await process_frame
        await process_frame

        snapshot = main.get_campaign_state_snapshot()
        if stage_id == EXPECTED_STAGE_ORDER[-1]:
            if String(snapshot.get("mode", "")) != "camp":
                push_error("Expected camp mode after final stage, got %s." % [snapshot.get("mode", "")])
                quit(1)
                return
        else:
            if String(snapshot.get("mode", "")) != "cutscene":
                push_error("Expected cutscene mode after stage %s, got %s." % [stage_id, snapshot.get("mode", "")])
                quit(1)
                return
            _assert_cutscene_snapshot(stage_id, snapshot)
            main.advance_campaign_step()
            await process_frame
            await process_frame

    var final_snapshot: Dictionary = main.get_campaign_state_snapshot()
    _assert_camp_snapshot(final_snapshot)

    if not _wait_tested:
        push_error("Campaign flow runner never exercised Wait during battle.")
        quit(1)
        return

    print("[PASS] M2 campaign flow runner advanced CH01_02 through CH01_05 into camp.")
    quit(0)

func _assert_cutscene_snapshot(stage_id: StringName, snapshot: Dictionary) -> void:
    var body: String = String(snapshot.get("panel_body", ""))
    var keywords: Array = CUTSCENE_KEYWORDS.get(stage_id, [])
    for keyword in keywords:
        if body.find(String(keyword)) == -1:
            push_error("Cutscene body for %s is missing keyword '%s'." % [stage_id, keyword])
            quit(1)
            return

func _assert_camp_snapshot(snapshot: Dictionary) -> void:
    var body: String = String(snapshot.get("panel_body", ""))
    var required_keywords: Array[String] = [
        "Serin is now locked in as an ally",
        "mem_frag_ch01_first_order",
        "Hardren seal evidence"
    ]
    for keyword in required_keywords:
        if body.find(keyword) == -1:
            push_error("Camp snapshot is missing keyword '%s'." % keyword)
            quit(1)
            return

func _play_battle_to_victory(battle) -> void:
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
        push_error("Battle did not finish in victory during campaign flow automation. %s" % _describe_battle_state(battle))
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
            push_error("Timed out waiting for player phase in campaign flow runner.")
            quit(1)
            return

func _play_player_phase(battle) -> void:
    var safety: int = 0
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
        if not acted:
            push_error("Campaign flow runner could not find a valid action.")
            quit(1)
            return

        return

        await process_frame
        safety += 1
        if safety > 20:
            push_error("Campaign flow player phase exceeded safety limit.")
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
        _wait_tested = true
        await process_frame
        return true

    battle._on_wait_requested()
    _wait_tested = true
    await process_frame
    return true

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

    return "stage=%s phase=%s enemies=%d objects=[%s]" % [
        str(battle.stage_data.stage_id),
        str(battle.current_phase),
        battle.enemy_units.size(),
        str(object_states)
    ]

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
