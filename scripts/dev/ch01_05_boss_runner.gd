extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH01_05_STAGE = preload("res://data/stages/ch01_05_stage.tres")

var _saw_mark: bool = false
var _saw_command_buff: bool = false
var _saw_charge: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)

    await process_frame
    await process_frame

    battle.set_stage(CH01_05_STAGE)
    await process_frame
    await process_frame

    var max_round_loops: int = 20
    for _round_loop in range(max_round_loops):
        await _wait_for_player_phase(battle)
        if _is_battle_finished(battle):
            break

        await _play_player_phase(battle)
        await process_frame
        await process_frame

        _record_boss_signals(battle)
        if _is_battle_finished(battle):
            break

    if not _saw_mark:
        push_error("CH01_05 boss runner never observed the mark telegraph.")
        quit(1)
        return

    if not _saw_command_buff:
        push_error("CH01_05 boss runner never observed the command buff telegraph.")
        quit(1)
        return

    if not _saw_charge:
        push_error("CH01_05 boss runner never observed the charge resolve telegraph.")
        quit(1)
        return

    if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
        push_error("CH01_05 boss battle did not finish in victory.")
        quit(1)
        return

    print("[PASS] CH01_05 boss runner observed mark, command buff, charge, and victory.")
    quit(0)

func _record_boss_signals(battle) -> void:
    if battle.boss_event_history.has("boss_mark"):
        _saw_mark = true
    if battle.boss_event_history.has("boss_command_buff"):
        _saw_command_buff = true
    if battle.boss_event_history.has("boss_charge"):
        _saw_charge = true

    if _saw_mark:
        var marked_found: bool = false
        for ally in battle.ally_units:
            if not is_instance_valid(ally):
                continue
            var telegraph_label: Label = ally.get_node_or_null("TelegraphLabel")
            if telegraph_label != null and telegraph_label.text == "MARK":
                marked_found = true
                break
        if not marked_found and not _saw_charge:
            push_error("Boss mark telegraph did not surface a visible MARK label on any ally.")
            quit(1)

func _wait_for_player_phase(battle) -> void:
    var safety: int = 0
    while not _is_battle_finished(battle):
        _record_boss_signals(battle)
        var phase: int = int(battle.current_phase)
        if phase == int(battle.BattlePhase.PLAYER_SELECT) or phase == int(battle.BattlePhase.PLAYER_ACTION_PREVIEW):
            return
        await process_frame
        safety += 1
        if safety > 240:
            push_error("Timed out waiting for player phase in CH01_05 boss runner.")
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

        push_error("CH01_05 boss runner could not find a valid player action.")
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

func _get_ready_ally_units(battle) -> Array:
    var ready_units: Array = []
    for unit in battle.ally_units:
        if is_instance_valid(unit) and not unit.is_defeated() and battle.turn_manager.can_unit_act(unit):
            ready_units.append(unit)
    return ready_units

func _is_battle_finished(battle) -> bool:
    var phase: int = int(battle.current_phase)
    return phase == int(battle.BattlePhase.VICTORY) or phase == int(battle.BattlePhase.DEFEAT)
