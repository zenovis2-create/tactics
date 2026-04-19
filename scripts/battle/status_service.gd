class_name StatusService
extends Node

## Manages 망각(Mangak/Oblivion) stacks per unit and weather psychology statuses.
## SYS-005, SYS-006, SYS-007

const UnitActor = preload("res://scripts/battle/unit_actor.gd")

const STACK_EFFECTS: Array[Dictionary] = [
    {},
    {"accuracy_mod": -5},
    {"accuracy_mod": -10, "evasion_mod": -5},
    {"accuracy_mod": -15, "evasion_mod": -10, "skills_sealed": true},
]

const STATUS_FEAR: StringName = &"fear"
const STATUS_CONFUSION: StringName = &"混乱"
const STATUS_NIGHT_SMOKE: StringName = &"눈不适应"
const STATUS_RAIN_COMFORT: StringName = &"비옷의慰め"

const STATUS_EFFECTS: Dictionary = {
    STATUS_FEAR: {"ability_locked": true, "skip_turn": true},
    STATUS_CONFUSION: {"defense_percent_mod": 20, "accuracy_mod": -15},
    STATUS_NIGHT_SMOKE: {"attack_percent_mod": -10},
    STATUS_RAIN_COMFORT: {"crit_rate_bonus": 10}
}

const MAX_STACK := 3

# unit_instance_id -> stack count (0-3)
var _stacks: Dictionary = {}
var _statuses: Dictionary = {}
var _log: Array[Dictionary] = []

# --- Public API ---

## Apply oblivion stacks to a unit. Clamped at MAX_STACK.
func apply_stack(unit: UnitActor, amount: int, reason: String = "enemy_applied") -> Dictionary:
    if not is_instance_valid(unit):
        return {}
    var uid: int = unit.get_instance_id()
    var before: int = _stacks.get(uid, 0)
    var after: int = clampi(before + amount, 0, MAX_STACK)
    _stacks[uid] = after
    var entry: Dictionary = {
        "event": "stack_applied",
        "unit_id": uid,
        "unit_name": _unit_name(unit),
        "before": before,
        "after": after,
        "amount": amount,
        "reason": reason
    }
    _log.append(entry)
    if after > before:
        print("[StatusService] 망각 stack applied | unit=%s before=%d after=%d" % [_unit_name(unit), before, after])
    return entry

## Cleanse (remove) oblivion stacks. Used by healer Clarity skill.
func cleanse_stack(unit: UnitActor, amount: int, reason: String = "clarity_cleanse") -> Dictionary:
    if not is_instance_valid(unit):
        return {}
    var uid: int = unit.get_instance_id()
    var before: int = _stacks.get(uid, 0)
    var after: int = clampi(before - amount, 0, MAX_STACK)
    _stacks[uid] = after
    var entry: Dictionary = {
        "event": "stack_cleansed",
        "unit_id": uid,
        "unit_name": _unit_name(unit),
        "before": before,
        "after": after,
        "amount": amount,
        "reason": reason
    }
    _log.append(entry)
    print("[StatusService] 망각 stack cleansed | unit=%s before=%d after=%d" % [_unit_name(unit), before, after])
    return entry

## Get current oblivion stack count for a unit.
func get_oblivion_stack(unit: UnitActor) -> int:
    if not is_instance_valid(unit):
        return 0
    return _stacks.get(unit.get_instance_id(), 0)

## Get the stat modifier dictionary for a unit's current oblivion stack level.
func get_oblivion_effects(unit: UnitActor) -> Dictionary:
    var stack: int = get_oblivion_stack(unit)
    return STACK_EFFECTS[clampi(stack, 0, MAX_STACK)].duplicate()

## Get the merged status modifiers for a unit's active weather psychology statuses.
func get_status_effects(unit: UnitActor) -> Dictionary:
    if not is_instance_valid(unit):
        return {}
    var uid: int = unit.get_instance_id()
    var merged: Dictionary = {}
    var unit_statuses: Dictionary = _statuses.get(uid, {})
    for status_name_variant in unit_statuses.keys():
        var status_name: StringName = StringName(status_name_variant)
        var status_fx: Dictionary = STATUS_EFFECTS.get(status_name, {})
        _merge_effects(merged, status_fx)
    return merged

## Get the full stat modifier dictionary for a unit.
func get_effects(unit: UnitActor) -> Dictionary:
    var merged: Dictionary = get_oblivion_effects(unit)
    _merge_effects(merged, get_status_effects(unit))
    return merged

func apply_status(unit: UnitActor, status_name: StringName, reason: String = "weather", remaining_turns: int = -1, payload: Dictionary = {}) -> Dictionary:
    if not is_instance_valid(unit):
        return {}
    if not STATUS_EFFECTS.has(status_name):
        return {}
    var uid: int = unit.get_instance_id()
    var unit_statuses: Dictionary = _statuses.get(uid, {})
    var before_active: bool = unit_statuses.has(status_name)
    unit_statuses[status_name] = {
        "remaining_turns": remaining_turns,
        "reason": reason,
        "payload": payload.duplicate(true)
    }
    _statuses[uid] = unit_statuses
    var entry: Dictionary = {
        "event": "status_applied",
        "unit_id": uid,
        "unit_name": _unit_name(unit),
        "status": String(status_name),
        "reason": reason,
        "remaining_turns": remaining_turns,
        "already_active": before_active
    }
    _log.append(entry)
    return entry

func clear_status(unit: UnitActor, status_name: StringName, reason: String = "expired") -> Dictionary:
    if not is_instance_valid(unit):
        return {}
    var uid: int = unit.get_instance_id()
    var unit_statuses: Dictionary = _statuses.get(uid, {})
    if not unit_statuses.has(status_name):
        return {}
    unit_statuses.erase(status_name)
    if unit_statuses.is_empty():
        _statuses.erase(uid)
    else:
        _statuses[uid] = unit_statuses
    var entry: Dictionary = {
        "event": "status_cleared",
        "unit_id": uid,
        "unit_name": _unit_name(unit),
        "status": String(status_name),
        "reason": reason
    }
    _log.append(entry)
    return entry

func has_status(unit: UnitActor, status_name: StringName) -> bool:
    if not is_instance_valid(unit):
        return false
    var unit_statuses: Dictionary = _statuses.get(unit.get_instance_id(), {})
    return unit_statuses.has(status_name)

func get_statuses(unit: UnitActor) -> Array[StringName]:
    var result: Array[StringName] = []
    if not is_instance_valid(unit):
        return result
    var unit_statuses: Dictionary = _statuses.get(unit.get_instance_id(), {})
    for status_name_variant in unit_statuses.keys():
        result.append(StringName(status_name_variant))
    return result

func consume_turn_start_statuses(unit: UnitActor) -> Dictionary:
    var result := {
        "skip_turn": false,
        "consumed": []
    }
    if not is_instance_valid(unit):
        return result

    if has_status(unit, STATUS_FEAR):
        clear_status(unit, STATUS_FEAR, "turn_start_consumed")
        result["skip_turn"] = true
        var consumed_statuses: Array = result["consumed"]
        consumed_statuses.append(STATUS_FEAR)
        result["consumed"] = consumed_statuses

    var uid: int = unit.get_instance_id()
    var unit_statuses: Dictionary = _statuses.get(uid, {})
    if unit_statuses.is_empty():
        return result

    var expired: Array[StringName] = []
    for status_name_variant in unit_statuses.keys():
        var status_name: StringName = StringName(status_name_variant)
        var entry: Dictionary = unit_statuses.get(status_name, {})
        var remaining_turns: int = int(entry.get("remaining_turns", -1))
        if remaining_turns > 0:
            remaining_turns -= 1
            if remaining_turns <= 0:
                expired.append(status_name)
            else:
                entry["remaining_turns"] = remaining_turns
                unit_statuses[status_name] = entry
    for expired_status in expired:
        clear_status(unit, expired_status, "duration_expired")
    return result

## Returns true if the unit's skills are sealed (stack = 3).
func are_skills_sealed(unit: UnitActor) -> bool:
    return bool(get_effects(unit).get("skills_sealed", false))

## Process start-of-turn for all units in the list.
func tick_start_of_turn(units: Array, decay: bool = false) -> void:
    if not decay:
        return
    for unit in units:
        if not is_instance_valid(unit) or unit.is_defeated():
            continue
        var stack: int = get_oblivion_stack(unit)
        if stack > 0:
            cleanse_stack(unit, 1, "natural_decay")

## Remove tracking for a unit (called when unit is defeated/removed).
func remove_unit(unit: UnitActor) -> void:
    if not is_instance_valid(unit):
        return
    var uid: int = unit.get_instance_id()
    _stacks.erase(uid)
    _statuses.erase(uid)

## Clear all stacks (between battles).
func reset() -> void:
    _stacks.clear()
    _statuses.clear()
    _log.clear()

## Full session log of all stack events.
func get_event_log() -> Array[Dictionary]:
    return _log.duplicate()

## Summary counts for telemetry.
func get_summary() -> Dictionary:
    var applied: int = 0
    var cleansed: int = 0
    var status_applied: int = 0
    for entry: Dictionary in _log:
        if entry.get("event") == "stack_applied":
            applied += int(entry.get("amount", 0))
        elif entry.get("event") == "stack_cleansed":
            cleansed += int(entry.get("amount", 0))
        elif entry.get("event") == "status_applied":
            status_applied += 1
    return {"total_applied": applied, "total_cleansed": cleansed, "status_applied": status_applied, "events": _log.size()}

func _merge_effects(target: Dictionary, source: Dictionary) -> void:
    for key in source.keys():
        var value: Variant = source[key]
        if value is bool:
            target[key] = bool(target.get(key, false)) or bool(value)
        elif value is int:
            target[key] = int(target.get(key, 0)) + int(value)
        elif value is float:
            target[key] = float(target.get(key, 0.0)) + float(value)
        else:
            target[key] = value

func _unit_name(unit: UnitActor) -> String:
    if unit.unit_data != null:
        return String(unit.unit_data.unit_id)
    return "unknown"
