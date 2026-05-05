class_name AIService
extends Node

const UnitActor = preload("res://scripts/battle/unit_actor.gd")
const PathService = preload("res://scripts/battle/path_service.gd")
const RangeService = preload("res://scripts/battle/range_service.gd")
const THREAT_ATTACK_WEIGHT := 18
const THREAT_RANGE_WEIGHT := 4

func pick_action(enemy: UnitActor, opponents: Array, path_service: PathService, range_service: RangeService, dynamic_blocked: Dictionary = {}, runtime_context: Dictionary = {}) -> Dictionary:
    if _should_sleep_wait(enemy):
        return {"type": "wait"}
    if _should_hold_objective(enemy, runtime_context):
        return {"type": "wait"}

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
            if _should_force_safety_wait(enemy):
                return {
                    "type": "move_wait",
                    "move_to": enemy.grid_position
                }
            if _should_reduce_forward_aggression(enemy):
                return {
                    "type": "move_wait",
                    "move_to": _truncate_path_to_movement(best_plan.get("path", []), max(path_cost - 1, 1), path_service)
                }
            return {
                "type": "move_attack",
                "move_to": move_to,
                "target": target
            }

        return {
            "type": "move_wait",
            "move_to": _truncate_path_to_movement(best_plan.get("path", []), enemy.get_movement(), path_service)
        }

    var objective_approach_plan: Dictionary = _find_objective_approach_plan(enemy, path_service, dynamic_blocked, runtime_context)
    if not objective_approach_plan.is_empty():
        return {
            "type": "move_wait",
            "move_to": _truncate_path_to_movement(objective_approach_plan.get("path", []), enemy.get_movement(), path_service)
        }

    var nearest_target: UnitActor = _find_nearest_target(enemy, opponents)
    if nearest_target == null:
        var last_seen_plan: Dictionary = _find_best_last_seen_plan(enemy, opponents, path_service, range_service, dynamic_blocked, runtime_context)
        if not last_seen_plan.is_empty():
            var move_path: Array = last_seen_plan.get("path", [])
            var move_cost: int = int(last_seen_plan.get("path_cost", 0))
            var move_to: Vector2i = last_seen_plan.get("move_to", enemy.grid_position)
            return {
                "type": "move_wait",
                "move_to": move_to if move_cost <= enemy.get_movement() else _truncate_path_to_movement(move_path, enemy.get_movement(), path_service)
            }
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
        if _is_hidden_from_actor(actor, unit):
            continue

        var distance: int = abs(unit.grid_position.x - actor.grid_position.x) + abs(unit.grid_position.y - actor.grid_position.y)
        var score: int = _score_attack_target(actor, unit, candidates)
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
        if _is_hidden_from_actor(actor, target):
            continue

        var candidate_cells: Array = range_service.get_attack_cells(target.grid_position, actor.get_attack_range())
        for cell in candidate_cells:
            if not path_service.is_walkable(cell, dynamic_blocked):
                continue

            var path: Array = path_service.find_path(actor.grid_position, cell, dynamic_blocked)
            if path.is_empty():
                continue

            var path_cost: int = path_service.get_path_cost(path)
            var score: int = _score_attack_target(actor, target, candidates)
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

func _find_best_last_seen_plan(actor: UnitActor, candidates: Array, path_service: PathService, range_service: RangeService, dynamic_blocked: Dictionary, runtime_context: Dictionary) -> Dictionary:
    var best_plan: Dictionary = {}
    var best_score: int = -2147483648
    var best_cost: int = 2147483647

    for target in candidates:
        if not is_instance_valid(target) or target.is_defeated():
            continue
        if not _is_hidden_from_actor(actor, target):
            continue

        var last_seen_cell: Variant = _get_last_seen_cell_for_target(target, runtime_context)
        if typeof(last_seen_cell) != TYPE_VECTOR2I:
            continue

        var candidate_cells: Array = range_service.get_attack_cells(last_seen_cell, actor.get_attack_range())
        for cell in candidate_cells:
            if not path_service.is_walkable(cell, dynamic_blocked):
                continue

            var path: Array = path_service.find_path(actor.grid_position, cell, dynamic_blocked)
            if path.is_empty():
                continue

            var path_cost: int = path_service.get_path_cost(path)
            var score: int = _score_attack_target(actor, target, candidates)
            if score > best_score or (score == best_score and path_cost < best_cost):
                best_score = score
                best_cost = path_cost
                best_plan = {
                    "target": target,
                    "move_to": cell,
                    "path": path,
                    "path_cost": path_cost
                }

    return best_plan

func _find_objective_approach_plan(actor: UnitActor, path_service: PathService, dynamic_blocked: Dictionary, runtime_context: Dictionary) -> Dictionary:
    if actor == null or not is_instance_valid(actor):
        return {}
    var actor_role: StringName = _resolve_ai_role(actor)
    if actor_role != &"shield_guard" and actor_role != &"commander_support":
        return {}
    var objective_cell: Variant = runtime_context.get("objective_cell", null)
    if typeof(objective_cell) != TYPE_VECTOR2I:
        return {}
    if actor.grid_position == objective_cell:
        return {}
    if not path_service.is_walkable(objective_cell, dynamic_blocked):
        return {}
    var path: Array = path_service.find_path(actor.grid_position, objective_cell, dynamic_blocked)
    if path.is_empty():
        return {}
    return {
        "path": path,
        "path_cost": path_service.get_path_cost(path),
        "move_to": objective_cell
    }

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
        if _is_hidden_from_actor(actor, unit):
            continue

        var distance: int = _distance(actor.grid_position, unit.grid_position)
        var score: int = _score_attack_target(actor, unit, candidates)
        if score > best_score or (score == best_score and distance < best_distance):
            best_score = score
            best_distance = distance
            best_target = unit

    return best_target

func _distance(from_cell: Vector2i, to_cell: Vector2i) -> int:
    return abs(to_cell.x - from_cell.x) + abs(to_cell.y - from_cell.y)

func _should_reduce_forward_aggression(actor: UnitActor) -> bool:
    if actor == null or not is_instance_valid(actor):
        return false
    var actor_role: StringName = _resolve_ai_role(actor)
    if actor_role != &"lancer_officer" and actor_role != &"melee_grunt":
        return false
    var snapshot: Dictionary = actor.get_status_visual_snapshot()
    return int(snapshot.get("fear_turns", 0)) > 0 or int(snapshot.get("wake_caution_turns", 0)) > 0

func _should_force_safety_wait(actor: UnitActor) -> bool:
    if actor == null or not is_instance_valid(actor):
        return false
    var actor_role: StringName = _resolve_ai_role(actor)
    var snapshot: Dictionary = actor.get_status_visual_snapshot()
    if actor_role == &"healer_chanter" and int(snapshot.get("silence_turns", 0)) > 0:
        return true
    if actor_role == &"commander_support" and int(snapshot.get("seal_turns", 0)) > 0:
        return true
    return false

func _should_sleep_wait(actor: UnitActor) -> bool:
    if actor == null or not is_instance_valid(actor):
        return false
    var snapshot: Dictionary = actor.get_status_visual_snapshot()
    return int(snapshot.get("sleep_turns", 0)) > 0

func _should_hold_objective(actor: UnitActor, runtime_context: Dictionary) -> bool:
    if actor == null or not is_instance_valid(actor):
        return false
    var actor_role: StringName = _resolve_ai_role(actor)
    if actor_role != &"commander_support" and actor_role != &"shield_guard":
        return false
    var objective_cell: Variant = runtime_context.get("objective_cell", null)
    if typeof(objective_cell) != TYPE_VECTOR2I:
        return false
    return actor.grid_position == objective_cell

func _get_last_seen_cell_for_target(target: UnitActor, runtime_context: Dictionary) -> Variant:
    if target == null or not is_instance_valid(target):
        return null
    var last_seen_cells: Variant = runtime_context.get("last_seen_cells", {})
    if typeof(last_seen_cells) == TYPE_DICTIONARY:
        var target_key := str(target.get_instance_id())
        if last_seen_cells.has(target_key):
            return last_seen_cells[target_key]
        if last_seen_cells.has(target.get_instance_id()):
            return last_seen_cells[target.get_instance_id()]
        if target.unit_data != null:
            var unit_id: String = String(target.unit_data.unit_id)
            if last_seen_cells.has(unit_id):
                return last_seen_cells[unit_id]
    var fallback_cell: Variant = runtime_context.get("last_seen_cell", null)
    if typeof(fallback_cell) == TYPE_VECTOR2I:
        return fallback_cell
    return null

func _is_hidden_from_actor(actor: UnitActor, target: UnitActor) -> bool:
    if actor == null or target == null or not is_instance_valid(actor) or not is_instance_valid(target):
        return false
    if _can_detect_stealthed_targets(actor):
        return false
    var snapshot: Dictionary = target.get_status_visual_snapshot()
    return int(snapshot.get("stealth_turns", 0)) > 0

func _can_detect_stealthed_targets(actor: UnitActor) -> bool:
    return _resolve_ai_role(actor) == &"assassin_black_hound"

func _score_attack_target(actor: UnitActor, target: UnitActor, candidates: Array = []) -> int:
    var estimated_damage: int = max(1, actor.get_attack() - target.get_defense())
    var lethal_bonus: int = 1000 if estimated_damage >= target.current_hp else 0
    var low_hp_bonus: int = max(0, 100 - target.current_hp)
    var threat_bonus: int = (target.get_attack() * THREAT_ATTACK_WEIGHT) + (target.get_attack_range() * THREAT_RANGE_WEIGHT)
    var role_bonus: int = _get_role_targeting_bonus(actor, target, candidates)
    return lethal_bonus + (estimated_damage * 10) + low_hp_bonus + threat_bonus + role_bonus

func _get_role_targeting_bonus(actor: UnitActor, target: UnitActor, candidates: Array = []) -> int:
    var actor_role: StringName = _resolve_ai_role(actor)
    match actor_role:
        &"archer_control":
            var bonus := 0
            if _is_marked_target(target):
                bonus += 180
            if _is_support_core_target(target):
                bonus += 120
            return bonus
        &"lancer_officer":
            var bonus := 0
            if _is_ranged_target(target):
                bonus += 90
            if target.get_defense() <= 0:
                bonus += 30
            return bonus
        &"assassin_black_hound":
            var bonus := 0
            if _is_marked_target(target):
                bonus += 180
            if _is_isolated_target(target, candidates):
                bonus += 110
            return bonus
        &"shield_guard":
            var bonus := 0
            if _is_melee_target(target):
                bonus += 80
            if _distance(actor.grid_position, target.grid_position) <= 1:
                bonus += 20
            return bonus
        &"healer_chanter":
            var bonus := 0
            if _is_backline_target(target):
                bonus += 90
            if _is_melee_target(target):
                bonus -= 40
            return bonus
        &"commander_support":
            var bonus := 0
            bonus += target.get_attack() * 230
            if _is_support_core_target(target):
                bonus -= 260
            return bonus
    return 0

func _resolve_ai_role(actor: UnitActor) -> StringName:
    if actor == null or not is_instance_valid(actor) or actor.unit_data == null:
        return &""
    var unit_id: String = String(actor.unit_data.unit_id)
    if unit_id.find("commander") != -1 or unit_id.find("captain") != -1:
        return &"commander_support"
    if unit_id.find("black_hound") != -1 or unit_id.find("hound") != -1:
        return &"assassin_black_hound"
    if unit_id.find("raider") != -1:
        return &"lancer_officer"
    if unit_id.find("skirmisher") != -1:
        return &"archer_control"
    var class_data = actor.unit_data.get_class_data()
    if class_data != null:
        var class_id: String = String(class_data.class_id)
        if class_id == "cls_ranger":
            return &"archer_control"
        if class_id == "cls_knight":
            return &"shield_guard"
        if class_id == "cls_mystic":
            return &"healer_chanter"
        if class_id == "cls_vanguard":
            return &"melee_grunt"
    return &""

func _is_support_core_target(target: UnitActor) -> bool:
    if target == null or not is_instance_valid(target) or target.unit_data == null:
        return false
    var unit_id: String = String(target.unit_data.unit_id)
    if unit_id.find("support") != -1 or unit_id.find("healer") != -1:
        return true
    var class_data = target.unit_data.get_class_data()
    if class_data == null:
        return false
    var class_id: String = String(class_data.class_id)
    return class_id == "cls_mystic"

func _is_ranged_target(target: UnitActor) -> bool:
    if target == null or not is_instance_valid(target):
        return false
    return target.get_attack_range() > 1

func _is_melee_target(target: UnitActor) -> bool:
    if target == null or not is_instance_valid(target):
        return false
    return target.get_attack_range() <= 1

func _is_backline_target(target: UnitActor) -> bool:
    if target == null or not is_instance_valid(target):
        return false
    return _is_ranged_target(target) or _is_support_core_target(target)

func _is_marked_target(target: UnitActor) -> bool:
    if target == null or not is_instance_valid(target):
        return false
    var snapshot: Dictionary = target.get_status_visual_snapshot()
    return int(snapshot.get("mark_turns", 0)) > 0 or bool(snapshot.get("crosshair_visible", false))

func _is_isolated_target(target: UnitActor, candidates: Array) -> bool:
    if target == null or not is_instance_valid(target):
        return false
    for candidate in candidates:
        if candidate == target or not is_instance_valid(candidate) or candidate.is_defeated():
            continue
        if _distance(target.grid_position, candidate.grid_position) <= 1:
            return false
    return true
