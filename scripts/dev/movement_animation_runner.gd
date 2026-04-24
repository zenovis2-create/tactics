extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)
    await process_frame
    await process_frame
    await process_frame

    if battle.selected_unit == null:
        return _fail("movement_animation_runner expected an auto-selected ally.")

    var unit = battle.selected_unit
    var reachable: Array = battle.reachable_cells
    if reachable.is_empty():
        return _fail("movement_animation_runner expected at least one reachable cell.")

    var destination: Vector2i = unit.grid_position
    var chosen_path: Array = []
    var best_cost := -1
    for candidate in reachable:
        var candidate_cell := Vector2i(candidate)
        if candidate_cell == unit.grid_position:
            continue
        var path: Array = battle.path_service.find_path(unit.grid_position, candidate_cell, battle._get_dynamic_blocked_cells(unit))
        var cost: int = battle.path_service.get_path_cost(path)
        if path.size() > 2 and cost > best_cost:
            destination = candidate_cell
            chosen_path = path
            best_cost = cost
    if chosen_path.is_empty():
        for candidate in reachable:
            var candidate_cell := Vector2i(candidate)
            if candidate_cell == unit.grid_position:
                continue
            chosen_path = battle.path_service.find_path(unit.grid_position, candidate_cell, battle._get_dynamic_blocked_cells(unit))
            if not chosen_path.is_empty():
                destination = candidate_cell
                break
    if destination == unit.grid_position or chosen_path.is_empty():
        return _fail("movement_animation_runner could not find a non-origin destination.")

    var original_position: Vector2 = unit.position
    var final_position: Vector2 = Vector2(destination.x * battle.stage_data.cell_size.x, destination.y * battle.stage_data.cell_size.y)
    var expected_first_step: Vector2 = final_position
    if chosen_path.size() > 1:
        var step_cell: Vector2i = chosen_path[1]
        expected_first_step = Vector2(step_cell.x * battle.stage_data.cell_size.x, step_cell.y * battle.stage_data.cell_size.y)

    battle._commit_player_move(destination)
    await process_frame

    if unit.position == final_position:
        return _fail("Unit position snapped to destination immediately instead of animating movement.")
    if unit.position == original_position:
        return _fail("Unit position did not begin moving after move commit.")

    await create_timer(0.11).timeout
    if chosen_path.size() > 2:
        var distance_to_first_step: float = unit.position.distance_to(expected_first_step)
        var distance_to_final: float = unit.position.distance_to(final_position)
        if distance_to_first_step >= distance_to_final:
            return _fail("Unit did not appear to prioritize the first path step over the final destination. first_step=%s final=%s actual=%s" % [expected_first_step, final_position, unit.position])

    await create_timer(0.45).timeout
    if unit.position.distance_to(final_position) > 0.1:
        return _fail("Unit did not settle at destination after movement animation. expected=%s actual=%s" % [final_position, unit.position])

    print("[PASS] movement_animation_runner validated visible path-step walk on player move.")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
