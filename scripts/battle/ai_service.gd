class_name AIService
extends Node

const UnitActor = preload("res://scripts/battle/unit_actor.gd")
const PathService = preload("res://scripts/battle/path_service.gd")
const RangeService = preload("res://scripts/battle/range_service.gd")
const THREAT_ATTACK_WEIGHT := 18
const THREAT_RANGE_WEIGHT := 4

func pick_action(enemy: UnitActor, opponents: Array, path_service: PathService, range_service: RangeService, dynamic_blocked: Dictionary = {}) -> Dictionary:
    var immediate_target: UnitActor = _find_attack_target_in_range(enemy, opponents, range_service)
    if immediate_target != null:
        return {
            "type": "attack",
            "target": immediate_target
        }

    var best_plan: Dictionary = _find_best_attack_plan(enemy, opponents, path_service, range_service, dynamic_blocked)
    if not best_plan.is_empty():
        var path_cost: int = int(best_plan.get("path_cost", 0))
        var move_to: Vector2i = best_plan.get("move_to", enemy.grid_position)
        var target: UnitActor = best_plan.get("target", null)

        if path_cost <= enemy.get_movement():
            return {
                "type": "move_attack",
                "move_to": move_to,
                "target": target
            }

        return {
            "type": "move_wait",
            "move_to": _truncate_path_to_movement(best_plan.get("path", []), enemy.get_movement(), path_service)
        }

    var nearest_target: UnitActor = _find_nearest_target(enemy, opponents)
    if nearest_target == null:
        return {"type": "wait"}

    var approach_plan: Dictionary = _find_best_approach_plan(enemy, nearest_target, path_service, range_service, dynamic_blocked)
    if approach_plan.is_empty():
        return {"type": "wait"}

    return {
        "type": "move_wait",
        "move_to": _truncate_path_to_movement(approach_plan.get("path", []), enemy.get_movement(), path_service)
    }

func _find_attack_target_in_range(actor: UnitActor, candidates: Array, range_service: RangeService) -> UnitActor:
    var best_target: UnitActor = null
    var best_score: int = -2147483648
    var best_distance: int = 2147483647
    var attack_cells: Array = range_service.get_attack_cells(actor.grid_position, actor.get_attack_range())

    for unit in candidates:
        if not is_instance_valid(unit) or unit.is_defeated() or not (unit.grid_position in attack_cells):
            continue

        var distance: int = abs(unit.grid_position.x - actor.grid_position.x) + abs(unit.grid_position.y - actor.grid_position.y)
        var score: int = _score_attack_target(actor, unit)
        if score > best_score or (score == best_score and distance < best_distance):
            best_score = score
            best_distance = distance
            best_target = unit

    return best_target

func _find_best_attack_plan(actor: UnitActor, candidates: Array, path_service: PathService, range_service: RangeService, dynamic_blocked: Dictionary) -> Dictionary:
    var best_plan: Dictionary = {}
    var best_score: int = -2147483648
    var best_cost: int = 2147483647

    for target in candidates:
        if not is_instance_valid(target) or target.is_defeated():
            continue

        var candidate_cells: Array = range_service.get_attack_cells(target.grid_position, actor.get_attack_range())
        for cell in candidate_cells:
            if not path_service.is_walkable(cell, dynamic_blocked):
                continue

            var path: Array = path_service.find_path(actor.grid_position, cell, dynamic_blocked)
            if path.is_empty():
                continue

            var path_cost: int = path_service.get_path_cost(path)
            var score: int = _score_attack_target(actor, target)
            if score > best_score or (score == best_score and path_cost < best_cost):
                best_score = score
                best_cost = path_cost
                best_plan = {
                    "target": target,
                    "move_to": cell,
                    "path": path,
                    "path_cost": path_cost
                }
            elif score == best_score and path_cost == best_cost and not best_plan.is_empty():
                var current_target: UnitActor = best_plan.get("target", null)
                if current_target == null or _distance(actor.grid_position, target.grid_position) < _distance(actor.grid_position, current_target.grid_position):
                    best_plan = {
                        "target": target,
                        "move_to": cell,
                        "path": path,
                        "path_cost": path_cost
                }

    return best_plan

func _find_best_approach_plan(actor: UnitActor, target: UnitActor, path_service: PathService, range_service: RangeService, dynamic_blocked: Dictionary) -> Dictionary:
    var best_plan: Dictionary = {}
    var best_cost: int = 2147483647

    for cell in range_service.get_attack_cells(target.grid_position, actor.get_attack_range()):
        if not path_service.is_walkable(cell, dynamic_blocked):
            continue

        var path: Array = path_service.find_path(actor.grid_position, cell, dynamic_blocked)
        if path.is_empty():
            continue

        var path_cost: int = path_service.get_path_cost(path)
        if path_cost < best_cost:
            best_cost = path_cost
            best_plan = {
                "path": path,
                "path_cost": path_cost,
                "move_to": cell
            }

    return best_plan

func _truncate_path_to_movement(path: Array, movement: int, path_service: PathService) -> Vector2i:
    if path.is_empty():
        return Vector2i.ZERO

    var remaining: int = movement
    var destination: Vector2i = path[0]
    for index in range(1, path.size()):
        var next_cell: Vector2i = path[index]
        var move_cost: int = path_service.get_move_cost(next_cell)
        if move_cost > remaining:
            break

        remaining -= move_cost
        destination = next_cell

    return destination

func _find_nearest_target(actor: UnitActor, candidates: Array) -> UnitActor:
    var best_target: UnitActor = null
    var best_score: int = -2147483648
    var best_distance: int = 2147483647

    for unit in candidates:
        if not is_instance_valid(unit) or unit.is_defeated():
            continue

        var distance: int = _distance(actor.grid_position, unit.grid_position)
        var score: int = _score_attack_target(actor, unit)
        if score > best_score or (score == best_score and distance < best_distance):
            best_score = score
            best_distance = distance
            best_target = unit

    return best_target

func _distance(from_cell: Vector2i, to_cell: Vector2i) -> int:
    return abs(to_cell.x - from_cell.x) + abs(to_cell.y - from_cell.y)

func _score_attack_target(actor: UnitActor, target: UnitActor) -> int:
    var estimated_damage: int = max(1, actor.get_attack() - target.get_defense())
    var lethal_bonus: int = 1000 if estimated_damage >= target.current_hp else 0
    var low_hp_bonus: int = max(0, 100 - target.current_hp)
    var threat_bonus: int = (target.get_attack() * THREAT_ATTACK_WEIGHT) + (target.get_attack_range() * THREAT_RANGE_WEIGHT)
    return lethal_bonus + (estimated_damage * 10) + low_hp_bonus + threat_bonus
