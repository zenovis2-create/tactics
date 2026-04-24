class_name EndingResolver
extends RefCounted

## EndingResolver — Determines true ending vs normal ending.
## Canonical final gate:
## - 6 companion resonance flags complete
## - final battle name-anchor maintenance satisfied (2+ proxy)
## - all six name-call reactions fired

const REQUIRED_RESONANCE_FLAGS: Array[StringName] = [
	&"flag_resonance_serin",
	&"flag_resonance_bran",
	&"flag_resonance_tia",
	&"flag_resonance_enoch",
	&"flag_resonance_karl",
	&"flag_resonance_noah"
]

const REQUIRED_NAME_ANCHOR_FLAG: StringName = &"flag_name_anchors_held_2plus"
const REQUIRED_NAME_CALL_FLAG: StringName = &"all_allies_name_called"
const RESONANCE_FLAG_LABELS := {
	"flag_resonance_serin": "세린",
	"flag_resonance_bran": "브란",
	"flag_resonance_tia": "티아",
	"flag_resonance_enoch": "에녹",
	"flag_resonance_karl": "카일",
	"flag_resonance_noah": "노아"
}

## Ending type constants.
const ENDING_TRUE: StringName = &"true_ending"
const ENDING_NORMAL: StringName = &"normal_ending"

## Returns the ending type based on progression data.
## Robust: handles null data safely.
static func resolve_ending(data: ProgressionData) -> StringName:
	if data == null:
		return ENDING_NORMAL
	if _check_true_ending_conditions(data):
		return ENDING_TRUE
	return ENDING_NORMAL

## Checks all true-ending conditions.
static func _check_true_ending_conditions(data: ProgressionData) -> bool:
	if not _has_all_resonance_flags(data):
		return false
	if not _has_required_name_anchors(data):
		return false
	if not _has_all_name_calls(data):
		return false
	return true

static func _has_all_resonance_flags(data: ProgressionData) -> bool:
	for flag_id: StringName in REQUIRED_RESONANCE_FLAGS:
		if not bool(data.flags.get(String(flag_id), false)):
			return false
	return true

static func _has_required_name_anchors(data: ProgressionData) -> bool:
	return bool(data.flags.get(String(REQUIRED_NAME_ANCHOR_FLAG), false))

static func _has_all_name_calls(data: ProgressionData) -> bool:
	return bool(data.flags.get(String(REQUIRED_NAME_CALL_FLAG), false))

## Debug helper: returns a dictionary describing current ending condition status.
static func get_ending_conditions_status(data: ProgressionData) -> Dictionary:
	if data == null:
		return {
			"all_resonance_flags": false,
			"resonance_count": 0,
			"required_resonance_count": REQUIRED_RESONANCE_FLAGS.size(),
			"missing_resonance_flags": [],
			"missing_resonance_labels": [],
			"name_anchors_ok": false,
			"all_name_calls": false,
			"ready_for_true_ending": false,
			"resolved_ending": ENDING_NORMAL
		}
	var missing_flags := _get_missing_resonance_flags(data)
	var ready_for_true_ending := _check_true_ending_conditions(data)
	return {
		"all_resonance_flags": _has_all_resonance_flags(data),
		"resonance_count": _get_resonance_count(data),
		"required_resonance_count": REQUIRED_RESONANCE_FLAGS.size(),
		"missing_resonance_flags": missing_flags,
		"missing_resonance_labels": _format_resonance_flag_labels(missing_flags),
		"name_anchors_ok": _has_required_name_anchors(data),
		"all_name_calls": _has_all_name_calls(data),
		"ready_for_true_ending": ready_for_true_ending,
		"resolved_ending": ENDING_TRUE if ready_for_true_ending else ENDING_NORMAL
	}

static func get_criteria_summary_lines(data: ProgressionData) -> Array[String]:
	var status := get_ending_conditions_status(data)
	var lines: Array[String] = []
	lines.append("공명 인장 %d/%d" % [int(status.get("resonance_count", 0)), int(status.get("required_resonance_count", 0))])
	lines.append("이름 앵커 %s" % ("유지" if bool(status.get("name_anchors_ok", false)) else "미달"))
	lines.append("이름 부름 %s" % ("완료" if bool(status.get("all_name_calls", false)) else "미완"))
	var missing: Array = status.get("missing_resonance_labels", [])
	if not missing.is_empty():
		lines.append("미완 공명: %s" % ", ".join(missing))
	lines.append("현재 판정: %s" % ("진엔딩 기준 충족" if bool(status.get("ready_for_true_ending", false)) else "일반 엔딩"))
	return lines

static func _get_missing_resonance_flags(data: ProgressionData) -> Array[String]:
	var missing: Array[String] = []
	for flag_id: StringName in REQUIRED_RESONANCE_FLAGS:
		if not bool(data.flags.get(String(flag_id), false)):
			missing.append(String(flag_id))
	return missing

static func _format_resonance_flag_labels(flag_names: Array[String]) -> Array[String]:
	var labels: Array[String] = []
	for flag_name in flag_names:
		labels.append(String(RESONANCE_FLAG_LABELS.get(flag_name, flag_name)))
	return labels

static func _get_resonance_count(data: ProgressionData) -> int:
	var count: int = 0
	for flag_id: StringName in REQUIRED_RESONANCE_FLAGS:
		if bool(data.flags.get(String(flag_id), false)):
			count += 1
	return count
