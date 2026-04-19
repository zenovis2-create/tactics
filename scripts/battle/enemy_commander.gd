class_name EnemyCommander
extends RefCounted

const AIService = preload("res://scripts/battle/ai_service.gd")
const PathService = preload("res://scripts/battle/path_service.gd")
const RangeService = preload("res://scripts/battle/range_service.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")

const CARDINAL_DIRECTIONS := [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]
const LOW_HP_FOCUS_FIRE_PENALTY := 500

class ActionData extends RefCounted:
    var type: String = "wait"
    var move_to: Vector2i = Vector2i.ZERO
    var target = null
    var rationale: String = "hold_position"

    func to_dictionary() -> Dictionary:
        var action := {"type": type}
        if type == "move_attack" or type == "move_wait":
            action["move_to"] = move_to
        if target != null:
            action["target"] = target
        return action

var perspective_decisions: Array[Dictionary] = []

var _fallback_ai := AIService.new()

func reset() -> void:
    perspective_decisions.clear()

func make_mirror_decision(ally_units: Array, enemy_units: Array, terrain) -> ActionData:
    var active_unit: UnitActor = terrain.get("active_unit", null)
    var path_service: PathService = terrain.get("path_service", null)
    var range_service: RangeService = terrain.get("range_service", null)
    var dynamic_blocked: Dictionary = terrain.get("dynamic_blocked", {})

    if active_unit == null or path_service == null or range_service == null:
        return _log_decision(active_unit, ActionData.new(), enemy_units.size(), false)

    var live_targets := _get_live_units(ally_units)
    if live_targets.is_empty():
        return _log_decision(active_unit, ActionData.new(), enemy_units.size(), false)

    var ranked_targets := _rank_targets(live_targets)
    var immediate_targets := _get_immediate_targets(active_unit, ranked_targets, range_service)
    for target in immediate_targets:
        if _leaves_escape_route(target, active_unit.grid_position, active_unit, terrain):
            var attack_action := ActionData.new()
            attack_action.type = "attack"
            attack_action.target = target
            attack_action.rationale = "avoid_low_hp_focus_fire"
            return _log_decision(active_unit, attack_action, enemy_units.size(), true)

    for target in ranked_targets:
        var safe_plan := _find_safe_attack_plan(active_unit, target, path_service, range_service, dynamic_blocked, terrain)
        if safe_plan.is_empty():
            continue
        var move_attack := ActionData.new()
        move_attack.type = "move_attack"
        move_attack.move_to = safe_plan.get("move_to", active_unit.grid_position)
        move_attack.target = target
        move_attack.rationale = "pressure_without_cornering"
        return _log_decision(active_unit, move_attack, enemy_units.size(), true)

    var preferred_target: UnitActor = ranked_targets[0]
    var approach_plan: Dictionary = _fallback_ai._find_best_approach_plan(active_unit, preferred_target, path_service, range_service, dynamic_blocked)
    if not approach_plan.is_empty():
        var move_wait := ActionData.new()
        move_wait.type = "move_wait"
        move_wait.move_to = _fallback_ai._truncate_path_to_movement(approach_plan.get("path", []), active_unit.get_movement(), path_service)
        move_wait.move_to = _soften_approach_destination(move_wait.move_to, active_unit, preferred_target, terrain, approach_plan.get("path", []))
        move_wait.rationale = "advance_but_leave_space"
        return _log_decision(active_unit, move_wait, enemy_units.size(), _distance_to_target(move_wait.move_to, preferred_target) > 1 or _leaves_escape_route(preferred_target, move_wait.move_to, active_unit, terrain))

    return _log_decision(active_unit, ActionData.new(), enemy_units.size(), false)

func _get_live_units(units: Array) -> Array[UnitActor]:
    var live_units: Array[UnitActor] = []
    for unit_variant in units:
        var unit := unit_variant as UnitActor
        if unit == null or not is_instance_valid(unit) or unit.is_defeated():
            continue
        live_units.append(unit)
    return live_units

func _rank_targets(targets: Array[UnitActor]) -> Array[UnitActor]:
    var ranked := targets.duplicate()
    var lowest_hp_target := _find_lowest_hp_target(targets)
    ranked.sort_custom(func(a: UnitActor, b: UnitActor) -> bool:
        var a_score := _target_score(a, lowest_hp_target)
        var b_score := _target_score(b, lowest_hp_target)
        if a_score == b_score:
            return a.current_hp > b.current_hp
        return a_score > b_score
    )
    return ranked

func _find_lowest_hp_target(targets: Array[UnitActor]) -> UnitActor:
    var lowest: UnitActor = null
    for target in targets:
        if lowest == null or target.current_hp < lowest.current_hp:
            lowest = target
    return lowest

func _target_score(target: UnitActor, lowest_hp_target: UnitActor) -> int:
    var score := (target.get_attack() * 20) + (target.get_attack_range() * 6) + (target.current_hp * 4)
    if lowest_hp_target != null and target == lowest_hp_target:
        score -= LOW_HP_FOCUS_FIRE_PENALTY
    return score

func _get_immediate_targets(actor: UnitActor, ranked_targets: Array[UnitActor], range_service: RangeService) -> Array[UnitActor]:
    var immediate: Array[UnitActor] = []
    var attack_cells: Array = range_service.get_attack_cells(actor.grid_position, actor.get_attack_range())
    for target in ranked_targets:
        if target.grid_position in attack_cells:
            immediate.append(target)
    return immediate

func _find_safe_attack_plan(actor: UnitActor, target: UnitActor, path_service: PathService, range_service: RangeService, dynamic_blocked: Dictionary, terrain) -> Dictionary:
    var best_plan: Dictionary = {}
    var best_cost: int = 2147483647
    var candidate_cells: Array = range_service.get_attack_cells(target.grid_position, actor.get_attack_range())
    for cell_variant in candidate_cells:
        var candidate_cell: Vector2i = cell_variant
        if not path_service.is_walkable(candidate_cell, dynamic_blocked):
            continue
        var path: Array = path_service.find_path(actor.grid_position, candidate_cell, dynamic_blocked)
        if path.is_empty():
            continue
        var path_cost: int = path_service.get_path_cost(path)
        if path_cost > actor.get_movement():
            continue
        if not _leaves_escape_route(target, candidate_cell, actor, terrain):
            continue
        if path_cost < best_cost:
            best_cost = path_cost
            best_plan = {
                "move_to": candidate_cell,
                "path": path
            }
    return best_plan

func _soften_approach_destination(move_to: Vector2i, actor: UnitActor, target: UnitActor, terrain, path: Array) -> Vector2i:
    if _distance_to_target(move_to, target) > 1:
        return move_to
    if _leaves_escape_route(target, move_to, actor, terrain):
        return move_to
    var move_index := path.find(move_to)
    if move_index > 0:
        return path[move_index - 1]
    return actor.grid_position

func _leaves_escape_route(target: UnitActor, attacker_cell: Vector2i, actor: UnitActor, terrain) -> bool:
    var path_service: PathService = terrain.get("path_service", null)
    var stage_data: StageData = terrain.get("stage_data", null)
    var occupied: Dictionary = terrain.get("dynamic_blocked", {}).duplicate(true)
    if path_service == null or stage_data == null:
        return true

    occupied.erase(actor.grid_position)
    occupied[attacker_cell] = true

    for direction in CARDINAL_DIRECTIONS:
        var escape_cell: Vector2i = target.grid_position + direction
        if escape_cell == attacker_cell:
            continue
        if not _is_cell_in_bounds(escape_cell, stage_data):
            continue
        if occupied.has(escape_cell):
            continue
        if not path_service.is_walkable(escape_cell, occupied):
            continue
        return true
    return false

func _is_cell_in_bounds(cell: Vector2i, stage_data: StageData) -> bool:
    return cell.x >= 0 and cell.y >= 0 and cell.x < stage_data.grid_size.x and cell.y < stage_data.grid_size.y

func _distance_to_target(from_cell: Vector2i, target: UnitActor) -> int:
    return abs(target.grid_position.x - from_cell.x) + abs(target.grid_position.y - from_cell.y)

func _log_decision(active_unit: UnitActor, action: ActionData, enemy_count: int, leaves_escape_route: bool) -> ActionData:
    var unit_id := ""
    if active_unit != null and active_unit.unit_data != null:
        unit_id = String(active_unit.unit_data.unit_id)
    var target_id := ""
    if action.target != null and action.target.unit_data != null:
        target_id = String(action.target.unit_data.unit_id)
    perspective_decisions.append({
        "unit_id": unit_id,
        "action_type": action.type,
        "target_id": target_id,
        "move_to": action.move_to,
        "rationale": action.rationale,
        "enemy_count": enemy_count,
        "leaves_escape_route": leaves_escape_route
    })
    return action
