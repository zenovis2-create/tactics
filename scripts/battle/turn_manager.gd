class_name TurnManager
extends Node

const UnitActor = preload("res://scripts/battle/unit_actor.gd")

signal action_state_changed(unit: UnitActor, from_state: StringName, to_state: StringName, reason: String, payload: Dictionary)

const STATE_READY: StringName = &"READY"
const STATE_MOVED: StringName = &"MOVED"
const STATE_ACTED: StringName = &"ACTED"
const STATE_EXHAUSTED: StringName = &"EXHAUSTED"
const STATE_DOWNED: StringName = &"DOWNED"

const ALLOWED_TRANSITIONS := {
    STATE_READY: [STATE_MOVED, STATE_ACTED, STATE_DOWNED],
    STATE_MOVED: [STATE_READY, STATE_ACTED, STATE_EXHAUSTED, STATE_DOWNED],
    STATE_ACTED: [STATE_EXHAUSTED, STATE_DOWNED],
    STATE_EXHAUSTED: [STATE_DOWNED],
    STATE_DOWNED: []
}

var active_faction: String = "ally"
var unit_states: Dictionary = {}
var last_transition: Dictionary = {}

func begin_phase(faction: String, units: Array, reason: String = "phase_start") -> void:
    active_faction = faction

    for unit in units:
        if not is_instance_valid(unit):
            continue

        if unit.is_defeated():
            _force_state(unit, STATE_DOWNED, "unit_downed", {"phase_owner": faction})
            continue

        var next_state: StringName = STATE_READY if unit.faction == faction else STATE_EXHAUSTED
        _force_state(unit, next_state, reason, {"phase_owner": faction})

func can_unit_act(unit: UnitActor) -> bool:
    if not is_instance_valid(unit) or unit.is_defeated() or unit.faction != active_faction:
        return false

    var state: StringName = get_unit_state(unit)
    return state == STATE_READY or state == STATE_MOVED

func mark_moved(unit: UnitActor, reason: String = "unit_moved", payload: Dictionary = {}) -> Dictionary:
    return _set_unit_state(unit, STATE_MOVED, reason, payload)

func reset_to_ready(unit: UnitActor, reason: String = "unit_ready", payload: Dictionary = {}) -> Dictionary:
    return _set_unit_state(unit, STATE_READY, reason, payload)

func mark_acted(unit: UnitActor, reason: String = "unit_acted", payload: Dictionary = {}) -> Dictionary:
    var acted_event := _set_unit_state(unit, STATE_ACTED, reason, payload)
    var exhausted_event := _set_unit_state(unit, STATE_EXHAUSTED, "unit_exhausted", payload)

    return {
        "acted": acted_event,
        "exhausted": exhausted_event
    }

func mark_downed(unit: UnitActor, reason: String = "unit_downed", payload: Dictionary = {}) -> Dictionary:
    return _set_unit_state(unit, STATE_DOWNED, reason, payload)

func is_phase_complete(faction: String, units: Array) -> bool:
    for unit in units:
        if not is_instance_valid(unit) or unit.faction != faction:
            continue

        var state: StringName = get_unit_state(unit)
        if state != STATE_EXHAUSTED and state != STATE_DOWNED:
            return false

    return true

func get_unit_state(unit: UnitActor) -> StringName:
    if not is_instance_valid(unit):
        return STATE_DOWNED
    return unit_states.get(unit.get_instance_id(), STATE_READY)

func get_ready_unit_count(faction: String, units: Array) -> int:
    var count := 0

    for unit in units:
        if not is_instance_valid(unit) or unit.faction != faction:
            continue

        if can_unit_act(unit):
            count += 1

    return count

func is_unit_exhausted(unit: UnitActor) -> bool:
    var state: StringName = get_unit_state(unit)
    return state == STATE_EXHAUSTED or state == STATE_DOWNED

func _set_unit_state(unit: UnitActor, next_state: StringName, reason: String, payload: Dictionary) -> Dictionary:
    if not is_instance_valid(unit):
        return {}

    var unit_id: int = unit.get_instance_id()
    var current_state: StringName = unit_states.get(unit_id, STATE_READY)

    if current_state == next_state:
        return {
            "changed": false,
            "from_state": current_state,
            "to_state": next_state,
            "reason": reason,
            "payload": payload
        }

    if not _is_transition_allowed(current_state, next_state):
        push_warning("TurnManager rejected invalid transition %s -> %s" % [String(current_state), String(next_state)])
        return {
            "changed": false,
            "error": "invalid_transition",
            "from_state": current_state,
            "to_state": next_state,
            "reason": reason,
            "payload": payload
        }

    return _force_state(unit, next_state, reason, payload)

func _force_state(unit: UnitActor, next_state: StringName, reason: String, payload: Dictionary) -> Dictionary:
    var unit_id: int = unit.get_instance_id()
    var current_state: StringName = unit_states.get(unit_id, STATE_READY)

    unit_states[unit_id] = next_state
    unit.has_acted = next_state == STATE_EXHAUSTED or next_state == STATE_DOWNED

    last_transition = {
        "unit_id": unit_id,
        "from_state": current_state,
        "to_state": next_state,
        "reason": reason,
        "payload": payload,
        "changed": current_state != next_state
    }

    if current_state != next_state:
        action_state_changed.emit(unit, current_state, next_state, reason, payload)

    return last_transition

func _is_transition_allowed(current_state: StringName, next_state: StringName) -> bool:
    var allowed: Array = ALLOWED_TRANSITIONS.get(current_state, [])
    return next_state in allowed
