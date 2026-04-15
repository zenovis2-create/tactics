class_name StatusService
extends Node

## Manages 망각(Mangak/Oblivion) stacks per unit and derived stat effects.
## SYS-005, SYS-006, SYS-007

const UnitActor = preload("res://scripts/battle/unit_actor.gd")

const STACK_EFFECTS: Array[Dictionary] = [
	{},
	{"accuracy_mod": -5},
	{"accuracy_mod": -10, "evasion_mod": -5},
	{"accuracy_mod": -15, "evasion_mod": -10, "skills_sealed": true},
]

const MAX_STACK := 3

# unit_instance_id -> stack count (0-3)
var _stacks: Dictionary = {}
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

## Get the stat modifier dictionary for a unit's current stack level.
func get_effects(unit: UnitActor) -> Dictionary:
	var stack: int = get_oblivion_stack(unit)
	return STACK_EFFECTS[clampi(stack, 0, MAX_STACK)].duplicate()

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
	_stacks.erase(unit.get_instance_id())

## Clear all stacks (between battles).
func reset() -> void:
	_stacks.clear()

## Full session log of all stack events.
func get_event_log() -> Array[Dictionary]:
	return _log.duplicate()

## Summary counts for telemetry.
func get_summary() -> Dictionary:
	var applied: int = 0
	var cleansed: int = 0
	for entry: Dictionary in _log:
		if entry.get("event") == "stack_applied":
			applied += int(entry.get("amount", 0))
		elif entry.get("event") == "stack_cleansed":
			cleansed += int(entry.get("amount", 0))
	return {"total_applied": applied, "total_cleansed": cleansed, "events": _log.size()}

func _unit_name(unit: UnitActor) -> String:
	if unit.unit_data != null:
		return String(unit.unit_data.unit_id)
	return "unknown"
