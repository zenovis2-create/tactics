extends RefCounted

const ProgressionData = preload("res://scripts/data/progression_data.gd")

static func build_battle_scar_lines(progression_data: ProgressionData) -> Array[String]:
	var lines: Array[String] = []
	if progression_data == null:
		return lines
	var markers := _get_sorted_markers(progression_data)
	for marker in markers:
		var chapter_name := String(marker.get("chapter_name", String(marker.get("chapter_id", "")).to_upper())).strip_edges()
		var chapter_id := String(marker.get("chapter_id", "")).strip_edges().to_upper()
		var visit_count: int = max(0, int(marker.get("visit_count", 0)))
		var last_visit := String(marker.get("last_visit_date", "")).strip_edges()
		var parts: Array[String] = ["🪦 %s" % chapter_name]
		if not chapter_id.is_empty():
			parts.append("(%s)" % chapter_id)
		parts.append("— %d회 전투" % visit_count)
		if not last_visit.is_empty():
			parts.append("· 마지막 흔적 %s" % last_visit)
		lines.append(" ".join(parts))
	return lines

static func build_battle_scar_museum_line(progression_data: ProgressionData) -> String:
	if progression_data == null:
		return ""
	var museum_location := _resolve_museum_location(progression_data)
	if museum_location.is_empty():
		return ""
	for marker in _get_sorted_markers(progression_data):
		if String(marker.get("chapter_id", "")).strip_edges().to_lower() != museum_location:
			continue
		var chapter_name := String(marker.get("chapter_name", museum_location.to_upper())).strip_edges()
		return "🏛 %s — 가장 많은 전투가 벌어진 위치에 전장의 museum이 세워졌습니다." % chapter_name
	return "🏛 %s — 가장 많은 전투가 벌어진 위치에 전장의 museum이 세워졌습니다." % museum_location.to_upper()

static func _get_sorted_markers(progression_data: ProgressionData) -> Array[Dictionary]:
	var markers: Array[Dictionary] = []
	for entry in progression_data.persistent_markers:
		if typeof(entry) == TYPE_DICTIONARY:
			markers.append((entry as Dictionary).duplicate(true))
	markers.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var visits_a := int(a.get("visit_count", 0))
		var visits_b := int(b.get("visit_count", 0))
		if visits_a == visits_b:
			return String(a.get("chapter_id", "")) < String(b.get("chapter_id", ""))
		return visits_a > visits_b
	)
	return markers

static func _resolve_museum_location(progression_data: ProgressionData) -> String:
	var encoded_location := String(progression_data.encyclopedia_comments.get("terrain_museum_location", "")).strip_edges().to_lower()
	if not encoded_location.is_empty():
		return encoded_location
	var best_stage_id := ""
	var best_visit_count := 0
	for stage_id_variant in progression_data.battle_visit_counts.keys():
		var stage_id := String(stage_id_variant).strip_edges().to_lower()
		var visit_count: int = max(0, int(progression_data.battle_visit_counts.get(stage_id_variant, 0)))
		if visit_count > best_visit_count or (visit_count == best_visit_count and not stage_id.is_empty() and (best_stage_id.is_empty() or stage_id < best_stage_id)):
			best_visit_count = visit_count
			best_stage_id = stage_id
	return best_stage_id
