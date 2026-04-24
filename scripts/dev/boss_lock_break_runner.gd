extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH10_05_STAGE = preload("res://data/stages/ch10_05_stage.tres")

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if not await _assert_boss_lock_state_lifecycle():
        return
    if not await _assert_boss_lock_event_hooks():
        return
    print("[PASS] boss_lock_break_runner: boss lock runtime state, progress, and event hooks are covered.")
    quit(0)

func _assert_boss_lock_state_lifecycle() -> bool:
    var battle = await _spawn_battle(CH10_05_STAGE)
    if battle == null:
        return false
    var boss = _find_boss(battle)
    if boss == null:
        return _fail("CH10_05 should spawn a boss for lock lifecycle coverage.")

    var state: Dictionary = battle._start_boss_lock(
        boss,
        &"final_toll",
        "Final Toll",
        3,
        {"object": 2, "name": 1},
        "전원 망각 압박",
        "종소리 약화"
    )
    if state.is_empty():
        return _fail("_start_boss_lock should return a readable state dictionary.")
    if StringName(state.get("action_id", &"")) != &"final_toll":
        return _fail("Boss lock state should preserve action_id.")
    if String(state.get("display_name", "")) != "Final Toll":
        return _fail("Boss lock state should preserve display_name.")
    if int(state.get("countdown", 0)) != 3:
        return _fail("Boss lock state should preserve countdown.")
    var locks_required: Dictionary = state.get("locks_required", {})
    if int(locks_required.get("object", 0)) != 2 or int(locks_required.get("name", 0)) != 1:
        return _fail("Boss lock state should preserve required lock counts.")
    var locks_progress: Dictionary = state.get("locks_progress", {})
    if int(locks_progress.get("object", -1)) != 0 or int(locks_progress.get("name", -1)) != 0:
        return _fail("Boss lock state should initialize progress at zero for each lock type.")
    if bool(state.get("broken", true)):
        return _fail("Boss lock state should start unbroken.")

    var snapshot: Dictionary = battle.get_boss_lock_state_snapshot()
    if not snapshot.has(boss.get_instance_id()):
        return _fail("get_boss_lock_state_snapshot should expose active boss lock by instance id.")
    var snapshot_state: Dictionary = snapshot.get(boss.get_instance_id(), {})
    if String(snapshot_state.get("break_text", "")) != "종소리 약화":
        return _fail("Boss lock snapshot should preserve break_text for HUD/runner consumers.")

    var partial_state: Dictionary = battle._progress_boss_lock(boss, &"object")
    var partial_progress: Dictionary = partial_state.get("locks_progress", {})
    if int(partial_progress.get("object", 0)) != 1:
        return _fail("_progress_boss_lock should increment the requested lock type.")
    if bool(partial_state.get("broken", true)):
        return _fail("Boss lock should not break before all required progress is complete.")
    var ignored_state: Dictionary = battle._progress_boss_lock(boss, &"missing_type")
    var ignored_progress: Dictionary = ignored_state.get("locks_progress", {})
    if int(ignored_progress.get("object", 0)) != 1:
        return _fail("Unknown lock types should not mutate existing lock progress.")
    var capped_state: Dictionary = battle._progress_boss_lock(boss, &"object", 9)
    var capped_progress: Dictionary = capped_state.get("locks_progress", {})
    if int(capped_progress.get("object", 0)) != 2:
        return _fail("_progress_boss_lock should cap progress at the required amount.")
    if bool(capped_state.get("broken", true)):
        return _fail("Boss lock should still wait for the remaining name lock.")
    var broken_state: Dictionary = battle._progress_boss_lock(boss, &"name")
    var broken_progress: Dictionary = broken_state.get("locks_progress", {})
    if int(broken_progress.get("name", 0)) != 1 or not bool(broken_state.get("broken", false)):
        return _fail("Boss lock should become broken when all required lock types are complete.")
    if not battle.boss_event_history.has("boss_lock_broken_final_toll"):
        return _fail("Broken boss lock should record a boss_lock_broken event.")

    battle._clear_boss_lock(boss)
    if battle.get_boss_lock_state_snapshot().has(boss.get_instance_id()):
        return _fail("_clear_boss_lock should remove one boss lock state.")

    battle._start_boss_lock(boss, &"final_toll", "Final Toll", 3, {"object": 2}, "실패", "해제")
    battle.bootstrap_battle()
    await process_frame
    await process_frame
    if not battle.get_boss_lock_state_snapshot().is_empty():
        return _fail("bootstrap_battle should clear all boss lock state.")

    battle.queue_free()
    await process_frame
    return true

func _assert_boss_lock_event_hooks() -> bool:
    var battle = await _spawn_battle(CH10_05_STAGE)
    if battle == null:
        return false
    var boss = _find_boss(battle)
    var ally = _find_ally(battle)
    if boss == null or ally == null:
        return _fail("CH10_05 should spawn both an ally and a boss for lock hook coverage.")

    battle._start_boss_lock(
        boss,
        &"hook_check",
        "Hook Check",
        2,
        {"strike": 1, "skill": 1, "object": 1, "name": 1, "cleanse": 1},
        "압박 유지",
        "압박 약화"
    )

    battle._progress_boss_lock_from_player_attack(ally, boss, ally.get_default_skill(), {"transition_reason": "attack_resolved"})
    var state: Dictionary = battle._get_boss_lock_state(boss)
    if int(Dictionary(state.get("locks_progress", {})).get("strike", 0)) != 1:
        return _fail("Player direct attack hook should progress strike lock.")

    battle._progress_boss_lock_from_player_attack(ally, boss, ally.get_default_skill(), {"transition_reason": "attack_resolved"}, ally.get_default_skill())
    state = battle._get_boss_lock_state(boss)
    if int(Dictionary(state.get("locks_progress", {})).get("skill", 0)) != 1:
        return _fail("Player skill hook should progress skill lock.")

    battle._progress_boss_lock_for_event(&"object")
    state = battle._get_boss_lock_state(boss)
    if int(Dictionary(state.get("locks_progress", {})).get("object", 0)) != 1:
        return _fail("Interaction event hook should progress object lock.")

    battle._progress_boss_lock_for_event(&"name")
    state = battle._get_boss_lock_state(boss)
    if int(Dictionary(state.get("locks_progress", {})).get("name", 0)) != 1:
        return _fail("Name event hook should progress name lock.")

    battle._progress_boss_lock_for_event(&"cleanse")
    state = battle._get_boss_lock_state(boss)
    var hook_progress: Dictionary = state.get("locks_progress", {})
    if int(hook_progress.get("cleanse", 0)) != 1:
        return _fail("Cleanse event hook should progress cleanse lock.")
    if not bool(state.get("broken", false)):
        return _fail("Boss lock should break after all hook progress types are complete.")

    battle.queue_free()
    await process_frame
    return true

func _spawn_battle(stage) -> Node:
    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)
    battle.set_stage(stage)
    await process_frame
    await process_frame
    return battle

func _find_boss(battle):
    for enemy in battle.enemy_units:
        if is_instance_valid(enemy) and enemy.unit_data != null and enemy.unit_data.is_boss:
            return enemy
    return null

func _find_ally(battle):
    for ally in battle.ally_units:
        if is_instance_valid(ally) and ally.unit_data != null and not ally.is_defeated():
            return ally
    return null

func _fail(message: String) -> bool:
    if not _failed:
        _failed = true
        push_error(message)
        quit(1)
    return false
