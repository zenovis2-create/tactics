extends SceneTree

const BattleController = preload("res://scripts/battle/battle_controller.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")
const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")

const WARMUP_BOOTSTRAPS := 2
const MEASURE_BOOTSTRAPS := 10
const WARMUP_ROUNDTRIPS := 1
const MEASURE_ROUNDTRIPS := 8
const MAX_SETTLE_FRAMES := 30

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var battle := await _spawn_battle()
    if battle == null:
        quit(1)
        return

    for _warmup_bootstrap in range(WARMUP_BOOTSTRAPS):
        await _measure_bootstrap_us(battle)

    var bootstrap_samples: Array[int] = []
    for _bootstrap_iteration in range(MEASURE_BOOTSTRAPS):
        bootstrap_samples.append(await _measure_bootstrap_us(battle))

    for _warmup_round in range(WARMUP_ROUNDTRIPS):
        await _measure_enemy_roundtrip_us(battle)

    var roundtrip_samples: Array[int] = []
    for _round_iteration in range(MEASURE_ROUNDTRIPS):
        roundtrip_samples.append(await _measure_enemy_roundtrip_us(battle))

    var summary := {
        "benchmark": "core_loop_performance",
        "bootstrap": _build_summary("battle_bootstrap", bootstrap_samples),
        "enemy_roundtrip": _build_summary("player_end_to_next_player_phase", roundtrip_samples),
        "warmup_bootstraps": WARMUP_BOOTSTRAPS,
        "warmup_roundtrips": WARMUP_ROUNDTRIPS,
        "stage_id": String(battle.stage_data.stage_id),
        "ally_count": battle.ally_units.size(),
        "enemy_count": battle.enemy_units.size(),
        "post_round_phase": battle._phase_name(battle.current_phase),
        "post_round_index": battle.round_index
    }
    print("PERF_RESULT=%s" % JSON.stringify(summary))

    await _despawn_battle(battle)
    quit(0)

func _spawn_battle() -> BattleController:
    var battle := BATTLE_SCENE.instantiate() as BattleController
    battle.stage_data = _make_stage()
    root.add_child(battle)
    if not await _wait_for_player_preview(battle):
        push_error("Core loop perf runner failed to reach player preview after spawning the battle.")
        return null
    return battle

func _measure_bootstrap_us(battle: BattleController) -> int:
    var start_us := Time.get_ticks_usec()
    battle.bootstrap_battle()
    if not await _wait_for_player_preview(battle):
        push_error("Core loop perf runner failed to settle after bootstrap.")
        quit(1)
        return 0
    return Time.get_ticks_usec() - start_us

func _measure_enemy_roundtrip_us(battle: BattleController) -> int:
    battle.bootstrap_battle()
    if not await _wait_for_player_preview(battle):
        push_error("Core loop perf runner failed to settle before roundtrip measurement.")
        quit(1)
        return 0

    var start_round := battle.round_index
    var start_us := Time.get_ticks_usec()
    battle._end_player_phase("perf_benchmark_roundtrip")
    if not await _wait_for_player_preview(battle, start_round + 1):
        push_error("Core loop perf runner failed to return to player preview after enemy phase.")
        quit(1)
        return 0
    if battle.round_index != start_round + 1:
        push_error("Core loop perf runner expected round %d after roundtrip, got %d." % [start_round + 1, battle.round_index])
        quit(1)
        return 0
    return Time.get_ticks_usec() - start_us

func _wait_for_player_preview(battle: BattleController, expected_round: int = -1) -> bool:
    for _frame in range(MAX_SETTLE_FRAMES):
        await process_frame
        if battle == null or not is_instance_valid(battle):
            return false
        if battle.current_phase == battle.BattlePhase.VICTORY or battle.current_phase == battle.BattlePhase.DEFEAT:
            return false
        if battle.current_phase == battle.BattlePhase.PLAYER_ACTION_PREVIEW and (expected_round < 0 or battle.round_index == expected_round):
            return true
    return false

func _despawn_battle(battle: BattleController) -> void:
    if battle != null and is_instance_valid(battle):
        battle.queue_free()
        await process_frame

func _make_stage() -> StageData:
    var stage := StageData.new()
    stage.stage_id = &"PERF_CORE_LOOP"
    stage.grid_size = Vector2i(7, 5)
    stage.cell_size = Vector2i(64, 64)
    stage.turn_limit = 12
    stage.ally_units = [
        _make_unit_data(&"ally_vanguard_perf", "ally", 20, 4, 3, 3, 1),
        _make_unit_data(&"ally_scout_perf", "ally", 16, 5, 2, 4, 1)
    ]
    stage.enemy_units = [
        _make_unit_data(&"enemy_raider_perf", "enemy", 18, 4, 2, 3, 1),
        _make_unit_data(&"enemy_archer_perf", "enemy", 14, 4, 1, 3, 2)
    ]
    stage.ally_spawns = [Vector2i(1, 1), Vector2i(1, 3)]
    stage.enemy_spawns = [Vector2i(5, 1), Vector2i(5, 3)]
    stage.blocked_cells = [Vector2i(3, 2)]
    stage.terrain_move_costs = {
        Vector2i(2, 2): 2,
        Vector2i(4, 2): 2
    }
    return stage

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
        "metric": name,
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
