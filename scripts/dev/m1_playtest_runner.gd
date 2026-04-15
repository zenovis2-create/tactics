extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")

var _cancel_tested: bool = false
var _wait_tested: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)

    await process_frame
    await process_frame

    if battle == null:
        push_error("BattleScene could not be instantiated.")
        quit(1)
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

    await process_frame
    await process_frame

    if not _cancel_tested:
        push_error("Cancel flow was never exercised.")
        quit(1)
        return

    if not _wait_tested:
        push_error("Wait flow was never exercised.")
        quit(1)
        return

    if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
        push_error("Battle did not finish in victory during automated playtest.")
        quit(1)
        return

    print("[PASS] M1 playtest runner completed battle to victory.")
    quit(0)

func _wait_for_player_phase(battle) -> void:
    var safety: int = 0
    while not _is_battle_finished(battle):
        var phase: int = int(battle.current_phase)
        if phase == int(battle.BattlePhase.PLAYER_SELECT) or phase == int(battle.BattlePhase.PLAYER_ACTION_PREVIEW):
            return
        await process_frame
        safety += 1
        if safety > 180:
            push_error("Timed out waiting for player phase.")
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

        _assert_hud_state_on_selection(battle)

        if not _cancel_tested:
            var cancel_destination: Vector2i = _pick_move_destination(battle, unit)
            if cancel_destination != unit.grid_position:
                var origin: Vector2i = unit.grid_position
                battle._on_world_cell_pressed(cancel_destination)
                await process_frame
                battle._on_cancel_requested()
                await process_frame
                if unit.grid_position != origin:
                    push_error("Cancel did not restore the unit to its original tile.")
                    quit(1)
                    return
                _cancel_tested = true
                continue

        var acted: bool = await _take_action_for_unit(battle, unit)
        if not acted:
            push_error("Automated player phase could not find a valid action.")
            quit(1)
            return

        await process_frame
        safety += 1
        if safety > 20:
            push_error("Player phase loop exceeded safety limit.")
            quit(1)
            return

func _take_action_for_unit(battle, unit) -> bool:
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
            _assert_hud_state_after_move(battle)

        var target = plan.get("target", null)
        if target != null:
            _assert_attackable_target_present(target)
            battle._on_world_cell_pressed(target.grid_position)
            await process_frame
            return true

    if action_type == "move_wait":
        var wait_destination: Vector2i = plan.get("move_to", unit.grid_position)
        if wait_destination != unit.grid_position:
            battle._on_world_cell_pressed(wait_destination)
            await process_frame
            _assert_hud_state_after_move(battle)

        battle._on_wait_requested()
        _wait_tested = true
        await process_frame
        return true

    battle._on_wait_requested()
    _wait_tested = true
    await process_frame
    return true

func _pick_move_destination(battle, unit) -> Vector2i:
    var opponents: Array = battle.enemy_units
    var dynamic_blocked: Dictionary = battle._get_dynamic_blocked_cells(unit)
    var plan: Dictionary = battle.ai_service.pick_action(unit, opponents, battle.path_service, battle.range_service, dynamic_blocked)
    return plan.get("move_to", unit.grid_position)

func _get_ready_ally_units(battle) -> Array:
    var ready_units: Array = []
    for unit in battle.ally_units:
        if is_instance_valid(unit) and not unit.is_defeated() and battle.turn_manager.can_unit_act(unit):
            ready_units.append(unit)
    return ready_units

func _assert_hud_state_on_selection(battle) -> void:
    if battle.selected_unit == null:
        push_error("Selected unit was not set after clicking an ally.")
        quit(1)
        return

    if battle.hud.wait_button.disabled:
        push_error("Wait button should be enabled after selecting a ready unit.")
        quit(1)
        return

    if battle.hud.cancel_button.disabled:
        push_error("Cancel button should be enabled after selecting a ready unit.")
        quit(1)
        return

    var reachable_visuals: int = battle.grid_cursor.get_child_count()
    if reachable_visuals <= 1:
        push_error("Reachable tile overlay did not render any cells.")
        quit(1)
        return

func _assert_hud_state_after_move(battle) -> void:
    if battle.hud.wait_button.disabled:
        push_error("Wait button should remain enabled after moving.")
        quit(1)
        return

    if battle.hud.cancel_button.disabled:
        push_error("Cancel button should remain enabled after moving.")
        quit(1)
        return

func _assert_attackable_target_present(unit) -> void:
    if unit == null or not is_instance_valid(unit):
        push_error("Expected a valid attack target after move.")
        quit(1)
        return

    var marker = unit.get_node("Marker")
    if marker == null:
        push_error("Attack target marker node was not found.")
        quit(1)
        return

    var marker_color: Color = marker.color
    var expected_color := Color(1.0, 0.52549, 0.301961, 0.9)
    if not marker_color.is_equal_approx(expected_color):
        push_error("Expected attackable target highlight after moving into attack range.")
        quit(1)
        return

func _is_battle_finished(battle) -> bool:
    var phase: int = int(battle.current_phase)
    return phase == int(battle.BattlePhase.VICTORY) or phase == int(battle.BattlePhase.DEFEAT)
