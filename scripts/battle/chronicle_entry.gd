class_name ChronicleEntry
extends Resource

enum ChronicleStyle {
	POETIC,
	CONCISE,
	BATTLE,
}

@export var chapter_id: String = ""
@export var chapter_title: String = ""
@export var entry_date: String = ""
@export_multiline var narrative_text: String = ""
@export var style: ChronicleStyle = ChronicleStyle.CONCISE
@export var trigger_events: Array[String] = []

func get_formatted_text() -> String:
	var base_text := narrative_text.strip_edges()
	if base_text.is_empty():
		return ""

	match style:
		ChronicleStyle.POETIC:
			var poetic_prefix := "Like ink caught in rain, "
			var poetic_suffix := " The page keeps the echo like a lantern behind mist."
			if trigger_events.has("weather_master"):
				poetic_prefix = "The wind, rain, and thunder wrote before the soldiers did; "
				poetic_suffix = " Nature itself seemed to lean over the margin."
			return _ensure_sentence(poetic_prefix + _lowercase_first(base_text) + poetic_suffix)
		ChronicleStyle.BATTLE:
			return _ensure_sentence("Battle record: %s Hold the line, mark the cost, and advance." % base_text)
		_:
			return _ensure_sentence("Field note: %s" % base_text)

func get_style_name() -> String:
	match style:
		ChronicleStyle.POETIC:
			return "POETIC"
		ChronicleStyle.BATTLE:
			return "BATTLE"
		_:
			return "CONCISE"

func to_summary_dict() -> Dictionary:
	return {
		"chapter_id": chapter_id,
		"chapter_title": chapter_title,
		"entry_date": entry_date,
		"style": get_style_name(),
		"trigger_events": trigger_events.duplicate(),
		"narrative_text": narrative_text,
		"formatted_text": get_formatted_text(),
	}

func _ensure_sentence(text: String) -> String:
	var normalized := text.strip_edges()
	if normalized.is_empty():
		return ""
	var final_char := normalized.right(1)
	if final_char in [".", "!", "?"]:
		return normalized
	return "%s." % normalized

func _lowercase_first(text: String) -> String:
	var normalized := text.strip_edges()
	if normalized.length() <= 1:
		return normalized.to_lower()
	return normalized.left(1).to_lower() + normalized.substr(1)
