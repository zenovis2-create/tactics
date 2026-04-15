extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CHECK_STAGES: Array = [
    {
        "label": "CH04_05",
        "stage": preload("res://data/stages/ch04_05_stage.tres")
    },
    {
        "label": "CH07_05",
        "stage": preload("res://data/stages/ch07_05_stage.tres")
    },
    {
        "label": "CH10_05",
        "stage": preload("res://data/stages/ch10_05_stage.tres")
    }
]

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    for stage_entry in CHECK_STAGES:
        var label: String = String(stage_entry.get("label", "boss_stage"))
        var stage = stage_entry.get("stage", null)
        if stage == null:
            push_error("Extended boss pattern runner missing stage for %s." % label)
            quit(1)
            return

        await _run_stage(label, stage)

    print("[PASS] Extended boss pattern runner observed mark, command buff, charge, and victory on CH04/CH07/CH10 bosses.")
    quit(0)

func _run_stage(label: String, stage) -> void:
    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)

    await process_frame
    await process_frame

    battle.set_stage(stage)
    await process_frame
    await process_frame

    var saw_mark: bool = false
    var saw_command_buff: bool = false
    var saw_charge: bool = false

    var max_round_loops: int = 24
    for _round_loop in range(max_round_loops):
        await _wait_for_player_phase(battle, label)
        if _is_battle_finished(battle):
            break

        await _play_player_phase(battle, label)
        await process_frame
        await process_frame

        if battle.boss_event_history.has("boss_mark"):
            saw_mark = true
        if battle.boss_event_history.has("boss_command_buff"):
            saw_command_buff = true
        if battle.boss_event_history.has("boss_charge"):
            saw_charge = true

        if _is_battle_finished(battle):
            break

    if not saw_mark:
        push_error("%s boss runner never observed the mark telegraph." % label)
        quit(1)
        return

    if not saw_command_buff:
        push_error("%s boss runner never observed the command buff telegraph." % label)
        quit(1)
        return

    if not saw_charge:
        push_error("%s boss runner never observed the charge resolve telegraph." % label)
        quit(1)
        return

    if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
        push_error("%s boss battle did not finish in victory." % label)
        quit(1)
        return

    battle.queue_free()
    await process_frame

func _wait_for_player_phase(battle, label: String) -> void:
    var safety: int = 0
    while not _is_battle_finished(battle):
        var phase: int = int(battle.current_phase)
        if phase == int(battle.BattlePhase.PLAYER_SELECT) or phase == int(battle.BattlePhase.PLAYER_ACTION_PREVIEW):
            return
        await process_frame
        safety += 1
        if safety > 260:
            push_error("Timed out waiting for player phase in %s boss runner." % label)
            quit(1)
            return

func _play_player_phase(battle, label: String) -> void:
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

        push_error("%s boss runner could not find a valid player action." % label)
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
