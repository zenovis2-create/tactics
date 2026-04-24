extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH10_05_STAGE = preload("res://data/stages/ch10_05_stage.tres")

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if not await _assert_ch10_final_karuon_patterns():
        return
    print("[PASS] extended_boss_pattern_runner: CH10 final Karuon phase, bell pressure, final toll, and victory surfaces passed.")
    quit(0)

func _spawn_battle() -> Node:
    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)
    battle.set_stage(CH10_05_STAGE)
    await process_frame
    await process_frame
    return battle

func _assert_ch10_final_karuon_patterns() -> bool:
    var battle = await _spawn_battle()
    if battle == null:
        return _fail("CH10_05 boss runner could not instantiate battle.")
    if battle.enemy_units.is_empty() or battle.ally_units.is_empty():
        return _fail("CH10_05 boss runner expected at least one enemy and ally.")

    var boss = battle.enemy_units[0]
    var marked_ally = battle.ally_units[0]
    if boss.unit_data.get_boss_phase_for_hp(70.0) != &"royal_edict":
        return _fail("CH10_05 final Karuon should enter royal_edict around 70% HP.")
    if boss.unit_data.get_boss_phase_for_hp(45.0) != &"name_severance":
        return _fail("CH10_05 final Karuon should enter name_severance around 45% HP.")
    if boss.unit_data.get_boss_phase_for_hp(20.0) != &"final_toll":
        return _fail("CH10_05 final Karuon should enter final_toll around 20% HP.")

    battle.boss_phase_by_unit[boss.get_instance_id()] = &"name_severance"
    battle._set_unit_visual_status(marked_ally, &"mark", 2)
    var bell_action: Dictionary = battle._ai_action_karon(boss)
    if String(bell_action.get("type", "")) != "karon_bell_of_erasure":
        return _fail("CH10_05 name_severance should choose bell-of-erasure against a marked ally.")
    battle._use_karon_bell_of_erasure(boss)
    if not battle.boss_event_history.has("karon_bell_of_erasure"):
        return _fail("CH10_05 boss runner never observed karon_bell_of_erasure.")
    if int(battle._get_unit_visual_status_turns(marked_ally, &"mark")) <= 0:
        return _fail("CH10_05 bell pressure should keep the exposed ally marked.")

    battle._apply_boss_phase_effects(boss, &"final_toll", &"name_severance")
    battle._use_karon_final_toll(boss)
    if not battle.boss_event_history.has("karon_final_toll"):
        return _fail("CH10_05 boss runner never observed karon_final_toll.")
    if not bool(battle.battle_objective_flags.get("karon_final_toll", false)):
        return _fail("CH10_05 final toll should surface the karon_final_toll objective flag.")
    for ally in battle.ally_units:
        if ally == null or not is_instance_valid(ally):
            continue
        if int(battle.bond_suppression_turns_by_unit.get(ally.get_instance_id(), 0)) <= 0:
            return _fail("CH10_05 final toll should suppress ally bond bonuses.")

    for object_actor in battle.interactive_objects:
        if object_actor != null and is_instance_valid(object_actor):
            object_actor.is_resolved = true
    battle.enemy_units.clear()
    if not battle._check_battle_end():
        return _fail("CH10_05 forced boss victory did not resolve.")
    if int(battle.current_phase) != int(battle.BattlePhase.VICTORY):
        return _fail("CH10_05 boss battle did not finish in victory.")

    battle.queue_free()
    await process_frame
    return true

func _fail(message: String) -> bool:
    if _failed:
        return false
    _failed = true
    push_error(message)
    quit(1)
    return false
