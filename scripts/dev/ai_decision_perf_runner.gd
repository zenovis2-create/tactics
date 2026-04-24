extends SceneTree

const AIService = preload("res://scripts/battle/ai_service.gd")
const PathService = preload("res://scripts/battle/path_service.gd")
const RangeService = preload("res://scripts/battle/range_service.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")
const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")

const WARMUP_ITERATIONS := 25
const MEASURE_ITERATIONS := 250

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var harness := Node.new()
    harness.name = "AIDecisionPerfHarness"
    root.add_child(harness)

    var ai_service := AIService.new()
    var path_service := PathService.new()
    var range_service := RangeService.new()
    harness.add_child(ai_service)
    harness.add_child(path_service)
    harness.add_child(range_service)

    path_service.configure_from_stage(_make_stage())

    var enemy := _make_actor(harness, &"benchmark_enemy", "enemy", 20, 6, 2, 4, 1, Vector2i(1, 4))
    var opponents: Array = [
        _make_actor(harness, &"frontliner", "ally", 18, 5, 3, 3, 1, Vector2i(6, 3)),
        _make_actor(harness, &"support", "ally", 12, 3, 1, 3, 2, Vector2i(7, 4)),
        _make_actor(harness, &"fragile", "ally", 7, 4, 0, 4, 1, Vector2i(8, 5)),
        _make_actor(harness, &"archer", "ally", 10, 5, 1, 3, 3, Vector2i(8, 2)),
        _make_actor(harness, &"healer", "ally", 9, 2, 1, 3, 2, Vector2i(6, 6)),
        _make_actor(harness, &"tank", "ally", 24, 4, 5, 2, 1, Vector2i(9, 4))
    ]
    var dynamic_blocked := {
        Vector2i(2, 4): true,
        Vector2i(3, 4): true,
        Vector2i(3, 3): true,
        Vector2i(4, 5): true,
        Vector2i(5, 5): true
    }

    var sample_action: Dictionary = ai_service.pick_action(enemy, opponents, path_service, range_service, dynamic_blocked)
    if String(sample_action.get("type", "")).is_empty():
        push_error("AI decision perf runner could not produce a sample action.")
        quit(1)
        return

    for _warmup in range(WARMUP_ITERATIONS):
        ai_service.pick_action(enemy, opponents, path_service, range_service, dynamic_blocked)

    var samples_us: Array[int] = []
    for _iteration in range(MEASURE_ITERATIONS):
        var start_us := Time.get_ticks_usec()
        ai_service.pick_action(enemy, opponents, path_service, range_service, dynamic_blocked)
        samples_us.append(Time.get_ticks_usec() - start_us)

    var summary := _build_summary("ai_decision_time", samples_us)
    summary["warmup_iterations"] = WARMUP_ITERATIONS
    summary["sample_action_type"] = String(sample_action.get("type", ""))
    summary["sample_move_to"] = _vec2i_to_array(sample_action.get("move_to", enemy.grid_position))
    summary["sample_target_id"] = _get_target_id(sample_action.get("target", null))
    summary["opponent_count"] = opponents.size()
    summary["dynamic_blocked_count"] = dynamic_blocked.size()

    print("PERF_RESULT=%s" % JSON.stringify(summary))

    harness.queue_free()
    quit(0)

func _make_stage() -> StageData:
    var stage := StageData.new()
    stage.stage_id = &"PERF_AI_DECISION"
    stage.grid_size = Vector2i(12, 9)
    stage.cell_size = Vector2i(64, 64)
    stage.blocked_cells = [
        Vector2i(4, 2),
        Vector2i(4, 3),
        Vector2i(4, 4),
        Vector2i(5, 2),
        Vector2i(5, 6),
        Vector2i(7, 6)
    ]
    stage.terrain_move_costs = {
        Vector2i(6, 4): 2,
        Vector2i(6, 5): 2,
        Vector2i(7, 5): 3,
        Vector2i(8, 4): 2,
        Vector2i(8, 3): 2
    }
    return stage

func _make_actor(parent: Node, unit_id: StringName, faction: String, hp: int, attack: int, defense: int, movement: int, attack_range: int, grid_position: Vector2i) -> UnitActor:
    var actor := UNIT_SCENE.instantiate() as UnitActor
    actor.setup_from_data(_make_unit_data(unit_id, faction, hp, attack, defense, movement, attack_range))
    actor.set_grid_position(grid_position)
    parent.add_child(actor)
    return actor

func _make_unit_data(unit_id: StringName, faction: String, hp: int, attack: int, defense: int, movement: int, attack_range: int) -> UnitData:
    var unit_data := UnitData.new()
    unit_data.unit_id = unit_id
    unit_data.display_name = String(unit_id)
    unit_data.faction = faction
    unit_data.max_hp = hp
    unit_data.attack = attack
    unit_data.defense = defense
    unit_data.movement = movement
    unit_data.attack_range = attack_range
    return unit_data

func _build_summary(name: String, samples_us: Array[int]) -> Dictionary:
    var sorted_samples: Array[int] = samples_us.duplicate()
    sorted_samples.sort()

    var total_us := 0
    for sample_us in samples_us:
        total_us += sample_us

    return {
        "benchmark": name,
        "iterations": samples_us.size(),
        "total_us": total_us,
        "avg_us": snappedf(float(total_us) / max(1, samples_us.size()), 0.01),
        "min_us": sorted_samples[0],
        "p95_us": _percentile(sorted_samples, 0.95),
        "max_us": sorted_samples[sorted_samples.size() - 1]
    }

func _percentile(sorted_samples: Array[int], percentile: float) -> int:
    if sorted_samples.is_empty():
        return 0
    var index := int(ceil((sorted_samples.size() - 1) * percentile))
    index = clamp(index, 0, sorted_samples.size() - 1)
    return sorted_samples[index]

func _vec2i_to_array(value: Variant) -> Array[int]:
    var cell: Vector2i = value if value is Vector2i else Vector2i.ZERO
    return [cell.x, cell.y]

func _get_target_id(target: Variant) -> String:
    if target is UnitActor and is_instance_valid(target) and target.unit_data != null:
        return String(target.unit_data.unit_id)
    return ""
