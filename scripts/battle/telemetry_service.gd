class_name TelemetryService
extends Node

## M6: Battle metric collection and session reporting.
## SYS-021, SYS-022

## Metric keys emitted per battle.
const KEY_STAGE_ID := "stage_id"
const KEY_RESULT := "result"           # "victory" | "defeat"
const KEY_ROUNDS := "rounds"
const KEY_TURNS_TO_CLEAR := "turns_to_clear"
const KEY_OBLIVION_APPLIED := "oblivion_applied"
const KEY_OBLIVION_CLEANSED := "oblivion_cleansed"
const KEY_RESCUE_SUCCESS := "rescue_success"
const KEY_COMMAND_USAGE := "command_usage"        # Dictionary: command_id -> use_count
const KEY_FAILURE_CAUSES := "failure_causes"      # Array of reason strings
const KEY_ALLY_DEATHS := "ally_deaths"
const KEY_ENEMY_DEATHS := "enemy_deaths"
const KEY_STARTED_AT := "started_at"
const KEY_ENDED_AT := "ended_at"

var _session: Dictionary = {}
var _command_usage: Dictionary = {}
var _failure_causes: Array[String] = []
var _history: Array[Dictionary] = []    # Past completed battles this runtime session.

var _active: bool = false

# --- Public API ---

## Call at the start of each battle.
func record_battle_start(stage_id: StringName) -> void:
	_session = {
		KEY_STAGE_ID: String(stage_id),
		KEY_RESULT: "",
		KEY_ROUNDS: 0,
		KEY_TURNS_TO_CLEAR: 0,
		KEY_OBLIVION_APPLIED: 0,
		KEY_OBLIVION_CLEANSED: 0,
		KEY_RESCUE_SUCCESS: 0,
		KEY_ALLY_DEATHS: 0,
		KEY_ENEMY_DEATHS: 0,
		KEY_STARTED_AT: Time.get_datetime_string_from_system(),
		KEY_ENDED_AT: "",
		KEY_FAILURE_CAUSES: []
	}
	_command_usage = {}
	_failure_causes = []
	_active = true
	print("[TelemetryService] Battle started: %s" % stage_id)

## Call at the end of each round to update round count.
func record_round_complete(round_index: int) -> void:
	if not _active:
		return
	_session[KEY_ROUNDS] = round_index

## Call when an ally unit is defeated.
func record_ally_death(reason: String = "") -> void:
	if not _active:
		return
	_session[KEY_ALLY_DEATHS] = int(_session.get(KEY_ALLY_DEATHS, 0)) + 1
	if not reason.is_empty():
		_failure_causes.append(reason)

## Call when an enemy unit is defeated.
func record_enemy_death() -> void:
	if not _active:
		return
	_session[KEY_ENEMY_DEATHS] = int(_session.get(KEY_ENEMY_DEATHS, 0)) + 1

## Call whenever oblivion stacks are applied.
func record_oblivion_applied(amount: int) -> void:
	if not _active:
		return
	_session[KEY_OBLIVION_APPLIED] = int(_session.get(KEY_OBLIVION_APPLIED, 0)) + amount

## Call whenever oblivion stacks are cleansed (healer).
func record_oblivion_cleansed(amount: int) -> void:
	if not _active:
		return
	_session[KEY_OBLIVION_CLEANSED] = int(_session.get(KEY_OBLIVION_CLEANSED, 0)) + amount

## Call when an ally is rescued (healed from 0 or saved from defeat).
func record_rescue() -> void:
	if not _active:
		return
	_session[KEY_RESCUE_SUCCESS] = int(_session.get(KEY_RESCUE_SUCCESS, 0)) + 1

## Call whenever a player command is used.
func record_command_use(command_id: StringName) -> void:
	if not _active:
		return
	var key := String(command_id)
	_command_usage[key] = int(_command_usage.get(key, 0)) + 1

## Call at battle end with the result ("victory" | "defeat") and round count.
func record_battle_end(result: StringName, rounds: int) -> Dictionary:
	if not _active:
		return {}

	_session[KEY_RESULT] = String(result)
	_session[KEY_ROUNDS] = rounds
	_session[KEY_TURNS_TO_CLEAR] = rounds
	_session[KEY_COMMAND_USAGE] = _command_usage.duplicate()
	_session[KEY_FAILURE_CAUSES] = _failure_causes.duplicate()
	_session[KEY_ENDED_AT] = Time.get_datetime_string_from_system()

	_history.append(_session.duplicate())
	_active = false

	print("[TelemetryService] Battle ended: result=%s rounds=%d oblivion_applied=%d cleansed=%d" % [
		result, rounds,
		int(_session.get(KEY_OBLIVION_APPLIED, 0)),
		int(_session.get(KEY_OBLIVION_CLEANSED, 0))
	])
	return _session.duplicate()

## Returns the current session metrics (even mid-battle).
func get_session_snapshot() -> Dictionary:
	var snap := _session.duplicate()
	snap[KEY_COMMAND_USAGE] = _command_usage.duplicate()
	snap[KEY_FAILURE_CAUSES] = _failure_causes.duplicate()
	return snap

## Returns all completed battle records from this runtime session.
func get_history() -> Array[Dictionary]:
	return _history.duplicate()

## Chapter balance report: top 3 failure causes across all history entries.
func get_balance_report() -> Dictionary:
	var cause_counts: Dictionary = {}
	var total_battles := _history.size()
	var victories := 0
	var defeats := 0
	var avg_rounds := 0.0

	for record in _history:
		if record.get(KEY_RESULT) == "victory":
			victories += 1
		else:
			defeats += 1
		avg_rounds += float(record.get(KEY_ROUNDS, 0))
		for cause in record.get(KEY_FAILURE_CAUSES, []):
			cause_counts[cause] = int(cause_counts.get(cause, 0)) + 1

	if total_battles > 0:
		avg_rounds /= float(total_battles)

	# Sort by count descending, take top 3.
	var sorted_causes: Array = []
	for cause in cause_counts.keys():
		sorted_causes.append({"cause": cause, "count": cause_counts[cause]})
	sorted_causes.sort_custom(func(a, b): return a["count"] > b["count"])

	var top_causes: Array = []
	for i in range(mini(3, sorted_causes.size())):
		top_causes.append(sorted_causes[i])

	return {
		"total_battles": total_battles,
		"victories": victories,
		"defeats": defeats,
		"avg_rounds": snappedf(avg_rounds, 0.01),
		"top_failure_causes": top_causes
	}
