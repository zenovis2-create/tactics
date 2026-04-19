class_name TacticalNote
extends Resource

@export var note_id: String = ""
@export var name: String = ""
@export var tags: Array[String] = []
@export var unit_formations: Array[Dictionary] = []
@export_multiline var description: String = ""
@export var created_at: String = ""
@export_range(1, 5, 1) var difficulty_rating: int = 1
@export var usage_count: int = 0

func setup(note_name: String, note_tags: Array, formations: Array, note_description: String, difficulty: int) -> TacticalNote:
	note_id = _generate_note_id()
	name = _sanitize_name(note_name)
	tags = _sanitize_tags(note_tags)
	unit_formations = _sanitize_formations(formations)
	description = _sanitize_description(note_description)
	created_at = _generate_created_at()
	difficulty_rating = clampi(difficulty, 1, 5)
	usage_count = 0
	return self

func apply_updates(updates: Dictionary) -> void:
	if updates.has("name"):
		name = _sanitize_name(String(updates.get("name", name)))
	if updates.has("tags"):
		tags = _sanitize_tags(updates.get("tags", tags))
	if updates.has("unit_formations"):
		unit_formations = _sanitize_formations(updates.get("unit_formations", unit_formations))
	if updates.has("description"):
		description = _sanitize_description(String(updates.get("description", description)))
	if updates.has("difficulty_rating"):
		difficulty_rating = clampi(int(updates.get("difficulty_rating", difficulty_rating)), 1, 5)
	if updates.has("usage_count"):
		usage_count = maxi(0, int(updates.get("usage_count", usage_count)))

func to_debug_dict() -> Dictionary:
	return {
		"note_id": note_id,
		"name": name,
		"tags": tags.duplicate(),
		"unit_formations": unit_formations.duplicate(true),
		"description": description,
		"created_at": created_at,
		"difficulty_rating": difficulty_rating,
		"usage_count": usage_count
	}

func _generate_note_id() -> String:
	var unix_time := Time.get_unix_time_from_system()
	return "%s_%s" % [str(hash(unix_time)), str(Time.get_ticks_usec())]

func _generate_created_at() -> String:
	return Time.get_datetime_string_from_system().replace(" ", "T")

func _sanitize_name(value: String) -> String:
	var normalized := value.strip_edges()
	if normalized.is_empty():
		return "새 전술 노트"
	return normalized.left(32)

func _sanitize_description(value: String) -> String:
	return value.strip_edges().left(280)

func _sanitize_tags(raw_tags: Variant) -> Array[String]:
	var sanitized: Array[String] = []
	if raw_tags is Array:
		for raw_tag in raw_tags:
			var normalized := String(raw_tag).strip_edges()
			if normalized.is_empty() or sanitized.has(normalized):
				continue
			sanitized.append(normalized)
	return sanitized

func _sanitize_formations(raw_formations: Variant) -> Array[Dictionary]:
	var sanitized: Array[Dictionary] = []
	if raw_formations is Array:
		for raw_formation in raw_formations:
			if not (raw_formation is Dictionary):
				continue
			var formation := raw_formation as Dictionary
			var unit_id := String(formation.get("unit_id", "")).strip_edges()
			if unit_id.is_empty():
				continue
			var position_value: Variant = formation.get("position", Vector2i.ZERO)
			var position := Vector2i.ZERO
			if position_value is Vector2i:
				position = position_value
			elif position_value is Vector2:
				position = Vector2i(position_value)
			var role := String(formation.get("role", "")).strip_edges()
			sanitized.append({
				"unit_id": unit_id,
				"position": position,
				"role": role
			})
	return sanitized
