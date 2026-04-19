class_name CombatService
extends Node

const UnitActor = preload("res://scripts/battle/unit_actor.gd")
const SkillData = preload("res://scripts/data/skill_data.gd")

const STEP_HIT_CHECK: StringName = &"hit_check"
const STEP_GUARD_CALC: StringName = &"guard_calc"
const STEP_DAMAGE_APPLY: StringName = &"damage_apply"
const STEP_STATUS_APPLY: StringName = &"status_apply"
const STEP_DEFEAT_CHECK: StringName = &"defeat_check"
const STEP_COUNTER_CHECK: StringName = &"counter_check"

func resolve_attack(attacker: UnitActor, defender: UnitActor, skill: SkillData = null, context: Dictionary = {}) -> Dictionary:
    var trace: Array = []
    var primary_result := {
        "damage": 0,
        "target_hp_before": defender.current_hp,
        "target_hp_after": defender.current_hp,
        "target_defeated": false
    }
    var transition_reason := "attack_resolved_deterministic"

    var hit_event := _step_hit_check(attacker, defender, skill, context)
    trace.append(hit_event)
    if bool(hit_event.get("hit", true)):
        primary_result = _resolve_strike(attacker, defender, skill, context, trace)
    else:
        transition_reason = "attack_missed"

    var counterattack := _resolve_counterattack(attacker, defender, context, trace)
    if transition_reason == "attack_missed" and bool(counterattack.get("triggered", false)):
        transition_reason = "attack_missed_counter_resolved"

    return {
        "damage": primary_result.get("damage", 0),
        "defender_hp_before": primary_result.get("target_hp_before", defender.current_hp),
        "defender_hp_after": primary_result.get("target_hp_after", defender.current_hp),
        "defender_defeated": primary_result.get("target_defeated", false),
        "counterattack": counterattack,
        "pipeline_trace": trace,
        "transition_reason": transition_reason
    }

func _resolve_strike(attacker: UnitActor, defender: UnitActor, skill: SkillData, context: Dictionary, trace: Array) -> Dictionary:
    var guard_event := _step_guard_calc(attacker, defender, skill, context)
    trace.append(guard_event)

    var damage_event := _step_damage_apply(defender, guard_event, context)
    trace.append(damage_event)

    var status_event := _step_status_apply(attacker, defender, skill)
    trace.append(status_event)

    var defeat_event := _step_defeat_check(defender)
    trace.append(defeat_event)

    return {
        "damage": damage_event.get("damage", 0),
        "target_hp_before": damage_event.get("hp_before", defender.current_hp),
        "target_hp_after": damage_event.get("hp_after", defender.current_hp),
        "target_defeated": defeat_event.get("defender_defeated", false)
    }

func _resolve_counterattack(original_attacker: UnitActor, defender: UnitActor, context: Dictionary, trace: Array) -> Dictionary:
    var counter_context: Dictionary = context.get("counter_context", {})
    var counter_event := {
        "step": STEP_COUNTER_CHECK,
        "triggered": false,
        "reason": "counterattack_unavailable"
    }

    if not bool(context.get("allow_counterattack", true)):
        trace.append(counter_event)
        return counter_event

    if not is_instance_valid(defender) or defender.is_defeated():
        trace.append(counter_event)
        return counter_event

    var defender_skill: SkillData = defender.get_default_skill()
    var defender_range: int = defender_skill.range if defender_skill != null else defender.get_attack_range()
    var distance: int = abs(original_attacker.grid_position.x - defender.grid_position.x) + abs(original_attacker.grid_position.y - defender.grid_position.y)
    if distance > defender_range:
        counter_event["reason"] = "counterattack_out_of_range"
        trace.append(counter_event)
        return counter_event

    counter_event["triggered"] = true
    counter_event["reason"] = "counterattack_triggered"
    trace.append(counter_event)

    var hit_event := _step_hit_check(defender, original_attacker, defender_skill)
    trace.append(hit_event)
    if not bool(hit_event.get("hit", true)):
        return {
            "triggered": true,
            "reason": "counterattack_missed",
            "damage": 0,
            "target_hp_before": original_attacker.current_hp,
            "target_hp_after": original_attacker.current_hp,
            "target_defeated": false
        }

    var counter_result := _resolve_strike(defender, original_attacker, defender_skill, counter_context, trace)
    counter_result["triggered"] = true
    counter_result["reason"] = "counterattack_resolved"
    return counter_result

func _step_hit_check(_attacker: UnitActor, _defender: UnitActor, _skill: SkillData, context: Dictionary = {}) -> Dictionary:
    # 망각 accuracy penalty: oblivion_accuracy_mod is negative (e.g. -5, -10, -15).
    # Threshold: if effective hit chance <= 0, guaranteed miss.
    # Base hit chance = 100. Stack 3 = -15 → 85 (still hits).
    # Skill-sealed (stack 3) is handled separately in BattleController context.
    var oblivion_mod: int = int(context.get("oblivion_accuracy_mod", 0))
    var weather_accuracy_mod: int = int(context.get("accuracy_mod", 0))
    var total_accuracy_mod: int = oblivion_mod + weather_accuracy_mod
    var hit_chance: int = 100 + total_accuracy_mod

    # Deterministic miss: only when hit_chance <= 0 (requires very high stacking, future tuning).
    if hit_chance <= 0:
        return {
            "step": STEP_HIT_CHECK,
            "hit": false,
            "reason": "oblivion_accuracy_zero",
            "hit_chance": hit_chance,
            "accuracy_mod": total_accuracy_mod
        }

    return {
        "step": STEP_HIT_CHECK,
        "hit": true,
        "reason": "deterministic_no_rng",
        "hit_chance": hit_chance,
        "oblivion_mod": oblivion_mod,
        "accuracy_mod": total_accuracy_mod
    }

func _step_guard_calc(attacker: UnitActor, defender: UnitActor, skill: SkillData, context: Dictionary) -> Dictionary:
    var attack_value: int = attacker.get_attack()
    if skill != null:
        attack_value += skill.power_modifier
    attack_value += int(context.get("attack_bonus", 0))
    # Bond adjacency bonus: 공격자가 아군과 인접하면 명중 보너스
    attack_value += int(context.get("bond_attack_bonus", 0))
    var attack_percent_mod: int = int(context.get("attack_percent_mod", 0))
    if attack_percent_mod != 0:
        attack_value = maxi(1, int(round(float(attack_value) * (100.0 + float(attack_percent_mod)) / 100.0)))

    var terrain_defense_bonus := int(context.get("defense_bonus", 0))
    var defense_value: int = defender.get_defense() + terrain_defense_bonus
    var defense_percent_mod: int = int(context.get("defense_percent_mod", 0))
    if defense_percent_mod != 0:
        defense_value = maxi(0, int(round(float(defense_value) * (100.0 + float(defense_percent_mod)) / 100.0)))
    var damage: int = max(1, attack_value - defense_value)

    return {
        "step": STEP_GUARD_CALC,
        "attack_value": attack_value,
        "defense_value": defense_value,
        "attack_percent_mod": attack_percent_mod,
        "defense_percent_mod": defense_percent_mod,
        "terrain_defense_bonus": terrain_defense_bonus,
        "terrain_type": context.get("terrain_type", "plain"),
        "damage": damage,
        "crit_rate_bonus": int(context.get("crit_rate_bonus", 0))
    }

func _step_damage_apply(defender: UnitActor, guard_event: Dictionary, context: Dictionary = {}) -> Dictionary:
    var hp_before: int = defender.current_hp
    var damage: int = int(guard_event.get("damage", 0))
    var minimum_remaining_hp: int = max(0, int(context.get("story_retreat_min_hp", 0)))
    if minimum_remaining_hp > 0 and hp_before - damage <= minimum_remaining_hp:
        defender.current_hp = max(minimum_remaining_hp, hp_before - damage)
        defender._refresh_visuals()
        defender._play_damage_flash()
        defender.show_damage(damage, &"damage")
    else:
        defender.apply_damage(damage)

    return {
        "step": STEP_DAMAGE_APPLY,
        "damage": damage,
        "hp_before": hp_before,
        "hp_after": defender.current_hp
    }

func _step_status_apply(_attacker: UnitActor, _defender: UnitActor, _skill: SkillData) -> Dictionary:
    return {
        "step": STEP_STATUS_APPLY,
        "status_applied": false,
        "reason": "status_system_not_enabled"
    }

func _step_defeat_check(defender: UnitActor) -> Dictionary:
    return {
        "step": STEP_DEFEAT_CHECK,
        "defender_defeated": defender.is_defeated()
    }
