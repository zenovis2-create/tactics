class_name PathService
extends Node

const StageData = preload("res://scripts/data/stage_data.gd")

var astar := AStarGrid2D.new()
var grid_size: Vector2i = Vector2i(8, 8)
var blocked_cells: Dictionary = {}
var terrain_move_costs: Dictionary = {}

func configure_from_stage(stage_data: StageData) -> void:
    if stage_data == null:
        return

    grid_size = stage_data.grid_size
    blocked_cells.clear()
    terrain_move_costs = stage_data.terrain_move_costs.duplicate(true)

    astar.region = Rect2i(Vector2i.ZERO, grid_size)
    astar.cell_size = Vector2(stage_data.cell_size)
    astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
    astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
    astar.update()

    for cell in stage_data.blocked_cells:
        blocked_cells[cell] = true
        astar.set_point_solid(cell, true)

    for x in range(grid_size.x):
        for y in range(grid_size.y):
            var cell := Vector2i(x, y)
            astar.set_point_weight_scale(cell, float(get_move_cost(cell)))

func is_walkable(cell: Vector2i, dynamic_blocked: Dictionary = {}) -> bool:
    return _is_in_bounds(cell) and not blocked_cells.has(cell) and not dynamic_blocked.has(cell)

func get_reachable_cells(origin: Vector2i, max_cost: int, dynamic_blocked: Dictionary = {}) -> Array:
    var result: Array = []
    var frontier: Array = [origin]
    var distance_map: Dictionary = {origin: 0}

    while not frontier.is_empty():
        var current: Vector2i = frontier.pop_front()
        var current_cost: int = distance_map[current]

        if current != origin:
            result.append(current)

        for offset in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
            var next_cell: Vector2i = current + offset
            if not is_walkable(next_cell, dynamic_blocked):
                continue

            var next_cost := current_cost + get_move_cost(next_cell)
            if next_cost > max_cost:
                continue

            var known_cost: int = int(distance_map.get(next_cell, INF))
            if known_cost <= next_cost:
                continue

            distance_map[next_cell] = next_cost
            frontier.append(next_cell)

    return result

func find_path(start: Vector2i, goal: Vector2i, dynamic_blocked: Dictionary = {}) -> Array:
    if not is_walkable(start) or not is_walkable(goal, dynamic_blocked):
        return []

    var applied_dynamic_cells := _set_dynamic_solids(dynamic_blocked, true, start, goal)
    var path: Array = []
    var raw_path := astar.get_id_path(start, goal)

    for point in raw_path:
        path.append(Vector2i(point))

    _restore_dynamic_solids(applied_dynamic_cells)
    return path

func get_move_cost(cell: Vector2i) -> int:
    return int(terrain_move_costs.get(cell, 1))

func get_path_cost(path: Array) -> int:
    var cost := 0
    for index in range(1, path.size()):
        cost += get_move_cost(path[index])
    return cost

func _is_in_bounds(cell: Vector2i) -> bool:
    return cell.x >= 0 and cell.y >= 0 and cell.x < grid_size.x and cell.y < grid_size.y

func _set_dynamic_solids(dynamic_blocked: Dictionary, solid: bool, start: Vector2i, goal: Vector2i) -> Array:
    var changed_cells: Array = []
    for cell in dynamic_blocked.keys():
        var blocked_cell: Vector2i = cell
        if blocked_cell == start or blocked_cell == goal or blocked_cells.has(blocked_cell):
            continue

        astar.set_point_solid(blocked_cell, solid)
        changed_cells.append(blocked_cell)

    return changed_cells

func _restore_dynamic_solids(changed_cells: Array) -> void:
    for cell in changed_cells:
        astar.set_point_solid(cell, false)
