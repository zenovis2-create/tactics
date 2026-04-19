extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH06_05_STAGE = preload("res://data/stages/ch06_05_stage.tres")

var _pass_count: int = 0
var _fail_count: int = 0

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)

    await process_frame
    await process_frame

    battle.set_stage(CH06_05_STAGE)

    await process_frame
    await process_frame

    var valgar = _find_enemy(battle, &"enemy_valgar")
    var ally = battle.ally_units[0] if not battle.ally_units.is_empty() else null
    var escort = _find_enemy(battle, &"enemy_skirmisher")

    _assert(valgar != null, "CH06_05 deploys Valgar")
    if valgar == null:
        return _finish()

    _assert(valgar.unit_data.boss_pattern == &"valgar_ch06_05", "Valgar uses the CH06-specific boss pattern id")

    var fortify_action: Dictionary = battle._pick_enemy_action(valgar)
    _assert(String(fortify_action.get("type", "")) == "valgar_fortify", "Valgar opens with the fortification pressure action")

    if ally != null:
        battle._apply_enemy_action(valgar, fortify_action)
        await process_frame

        _assert(battle.boss_event_history.has("valgar_fortify"), "Valgar records the fortification telegraph event")
        _assert(battle.boss_charge_pending, "Valgar fortification primes a follow-up charge")
        _assert(battle.hud.telegraph_label.text.find("Fortify") != -1, "BattleHUD surfaces the Valgar fortification telegraph")
        var fortify_detail: String = battle.hud.telegraph_detail_label.text.to_lower()
        _assert(fortify_detail.find("pressure") != -1, "Fortification telegraph explains the pressure threat")
        _assert(fortify_detail.find("keep") == -1 and fortify_detail.find("turret") == -1, "Fortification telegraph stays generic instead of implying keep-specific logic")

        if escort != null:
            _assert(int(battle.enemy_attack_bonus_by_unit.get(escort.get_instance_id(), 0)) >= 1, "Fortification pressure buffs nearby supporting enemies")

        var charge_action: Dictionary = battle._pick_enemy_action(valgar)
        _assert(String(charge_action.get("type", "")) == "boss_charge", "Valgar follows fortification with a charge action")
        _assert(charge_action.get("target", null) == fortify_action.get("target", null), "Valgar charge keeps the same pressured target")
        valgar.set_grid_position(ally.grid_position + Vector2i(1, 0), battle.stage_data.cell_size)
        battle._apply_enemy_action(valgar, {"type": "boss_charge", "target": ally})
        await process_frame
        _assert(battle.boss_event_history.has("boss_charge"), "Valgar records the charge resolve event")
        _assert(not battle.boss_charge_pending, "Valgar clears the pending charge flag after charge resolution")
        _assert(battle.boss_marked_target_id == -1, "Valgar clears the pressured target id after charge resolution")

        battle.boss_charge_pending = true
        battle.boss_marked_target_id = -999
        var reset_action: Dictionary = battle._pick_enemy_action(valgar)
        _assert(String(reset_action.get("type", "")) == "valgar_fortify", "Valgar falls back to fortify when the pressured target is missing")
        _assert(not battle.boss_charge_pending, "Valgar clears stale charge state when the pressured target is missing")
        _assert(battle.boss_marked_target_id == -1, "Valgar resets the stale target id when the pressured target is missing")

    var late_phase: StringName = _get_lowest_threshold_phase(valgar.unit_data)
    valgar.current_hp = max(1, int(floor(float(valgar.unit_data.max_hp) * 0.2)))
    battle.enemy_attack_bonus_by_unit.clear()
    battle.enemy_movement_bonus_by_unit.clear()
    battle._check_boss_phase_transitions()

    _assert(late_phase != &"", "Valgar defines a late boss phase in unit data")
    _assert(battle.get_boss_phase_for_unit(valgar) == late_phase, "Valgar enters the late boss phase from unit-data thresholds")
    _assert(battle.boss_event_history.has("boss_phase_%s" % String(late_phase)), "Late-phase transition is recorded in boss event history")
    _assert(int(battle.enemy_attack_bonus_by_unit.get(valgar.get_instance_id(), 0)) >= 2, "Late Valgar phase applies a decisive attack buff")
    _assert(battle._get_effective_movement(valgar) >= valgar.get_movement() + 1, "Late Valgar phase increases movement for the charge finish")

    _finish()

func _find_enemy(battle, unit_id: StringName):
    for enemy in battle.enemy_units:
        if is_instance_valid(enemy) and enemy.unit_data != null and enemy.unit_data.unit_id == unit_id:
            return enemy
    return null

func _get_lowest_threshold_phase(unit_data) -> StringName:
    if unit_data == null or unit_data.boss_phase_thresholds.is_empty():
        return &""
    var thresholds: Array = unit_data.boss_phase_thresholds.keys()
    thresholds.sort()
    return unit_data.boss_phase_thresholds[thresholds[0]]

func _assert(condition: bool, label: String) -> void:
    if condition:
        _pass_count += 1
        print("[PASS] ch06_05_valgar_runner: %s" % label)
    else:
        _fail_count += 1
        push_error("[FAIL] ch06_05_valgar_runner: %s" % label)

func _finish() -> void:
    if _fail_count == 0:
        print("[PASS] ch06_05_valgar_runner: all %d assertions passed" % _pass_count)
        quit(0)
        return

    push_error("ch06_05_valgar_runner: %d/%d assertions failed" % [_fail_count, _pass_count + _fail_count])
    quit(1)
