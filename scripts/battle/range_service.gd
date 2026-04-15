class_name RangeService
extends Node

func get_attack_cells(origin: Vector2i, attack_range: int) -> Array:
    return get_cells_by_manhattan_distance(origin, 1, attack_range)

func get_cells_by_manhattan_distance(origin: Vector2i, min_distance: int, max_distance: int) -> Array:
    var cells: Array = []

    for x in range(origin.x - max_distance, origin.x + max_distance + 1):
        for y in range(origin.y - max_distance, origin.y + max_distance + 1):
            var cell: Vector2i = Vector2i(x, y)
            var distance: int = abs(cell.x - origin.x) + abs(cell.y - origin.y)
            if distance >= min_distance and distance <= max_distance:
                cells.append(cell)

    return cells
