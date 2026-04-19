class_name MemorialSceneBondSection
extends VBoxContainer

const BondEndingRegistry = preload("res://scripts/battle/bond_ending_registry.gd")
const SupportConversations = preload("res://scripts/data/support_conversations.gd")

const HEADER_TEXT := "함께 간 사람들"
const DEFAULT_REGISTERED_PAIRS := [
	{"pair_id": "rian+noah", "units": ["rian", "noah"], "chapter_number": 4, "ending_title": "The Bell Fell Silent"},
	{"pair_id": "lete+mira", "units": ["lete", "mira"], "chapter_number": 8, "ending_title": "Ashes in the Monastery Rain"},
	{"pair_id": "melkion+mira", "units": ["melkion", "mira"], "chapter_number": 9, "ending_title": "The Truth We Buried"},
	{"pair_id": BondEndingRegistry.RANDOM_PAIR_ID, "units": [], "chapter_number": 0, "ending_title": "Two Lights Lost"}
]

var _progression_data: Variant = null
var _header_label: Label
var _card_grid: GridContainer

func _ready() -> void:
	_ensure_structure()
	refresh()

func set_progression_data(progression_data: Variant) -> void:
	_progression_data = progression_data
	refresh()

func refresh() -> void:
	_ensure_structure()
	_clear_children(_card_grid)
	var unlocked_entries: Array[Dictionary] = []
	for entry in get_registered_pairs(_progression_data):
		if bool(entry.get("unlocked", false)):
			unlocked_entries.append(entry)
	if unlocked_entries.is_empty():
		var empty_label := Label.new()
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_label.text = "아직 함께 쓰러진 기록이 없습니다."
		_card_grid.add_child(empty_label)
		return
	for entry in unlocked_entries:
		_card_grid.add_child(_build_card(entry))

static func get_registered_pairs(source: Variant = null) -> Array[Dictionary]:
	var raw_entries := _read_registry_pairs()
	if raw_entries.is_empty():
		raw_entries = _dictionary_array_from_variant(DEFAULT_REGISTERED_PAIRS)
	var unlocked_by_pair := _build_unlock_map(source, raw_entries)
	var normalized_entries: Array[Dictionary] = []
	for raw_entry in raw_entries:
		var normalized_entry := _normalize_entry(raw_entry, unlocked_by_pair)
		if not normalized_entry.is_empty():
			normalized_entries.append(normalized_entry)
	normalized_entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var chapter_a := int(a.get("chapter_number", 999))
		var chapter_b := int(b.get("chapter_number", 999))
		if chapter_a == chapter_b:
			return String(a.get("pair_names", "")) < String(b.get("pair_names", ""))
		return chapter_a < chapter_b
	)
	return normalized_entries

func _ensure_structure() -> void:
	if _header_label != null and _card_grid != null:
		return
	alignment = BoxContainer.ALIGNMENT_BEGIN
	add_theme_constant_override("separation", 12)
	_header_label = get_node_or_null("Header") as Label
	if _header_label == null:
		_header_label = Label.new()
		_header_label.name = "Header"
		_header_label.text = HEADER_TEXT
		_header_label.add_theme_font_size_override("font_size", 24)
		add_child(_header_label)
	_card_grid = get_node_or_null("CardGrid") as GridContainer
	if _card_grid == null:
		_card_grid = GridContainer.new()
		_card_grid.name = "CardGrid"
		_card_grid.columns = 2
		_card_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_card_grid.add_theme_constant_override("separation", 12)
		add_child(_card_grid)

func _build_card(entry: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(220.0, 220.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.tooltip_text = _build_card_tooltip(entry)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)

	var portrait := TextureRect.new()
	portrait.custom_minimum_size = Vector2(0.0, 128.0)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_portrait_composite(portrait, String(entry.get("pair_id", "")), String(entry.get("portrait_path", "")))

	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = "%s\n%s · Chapter %d" % [
		String(entry.get("ending_title", "Bond Ending")),
		String(entry.get("pair_names", "")),
		int(entry.get("chapter_number", 0))
	]

	stack.add_child(portrait)
	stack.add_child(label)
	margin.add_child(stack)
	card.add_child(margin)
	return card

func _build_portrait_composite(portrait: TextureRect, pair_id: String, portrait_path: String) -> void:
	if not portrait_path.is_empty() and ResourceLoader.exists(portrait_path):
		portrait.texture = load(portrait_path)
		return
	var colors := _resolve_pair_colors(pair_id)
	var left_block := ColorRect.new()
	left_block.anchor_right = 0.5
	left_block.anchor_bottom = 1.0
	left_block.color = colors[0]
	left_block.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.add_child(left_block)
	var right_block := ColorRect.new()
	right_block.anchor_left = 0.5
	right_block.anchor_right = 1.0
	right_block.anchor_bottom = 1.0
	right_block.color = colors[1]
	right_block.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.add_child(right_block)
	var initials := Label.new()
	initials.anchor_right = 1.0
	initials.anchor_bottom = 1.0
	initials.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initials.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initials.add_theme_font_size_override("font_size", 26)
	initials.text = _build_pair_initials(pair_id)
	initials.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.add_child(initials)

func _build_card_tooltip(entry: Dictionary) -> String:
	var lines := [
		String(entry.get("pair_names", "")),
		String(entry.get("ending_title", "Bond Ending")),
		"Chapter %d" % int(entry.get("chapter_number", 0))
	]
	var unlocked_date := String(entry.get("unlocked_date", "")).strip_edges()
	if not unlocked_date.is_empty():
		lines.append("Unlocked %s" % unlocked_date)
	return "\n".join(lines)

static func _read_registry_pairs() -> Array[Dictionary]:
	var registry := BondEndingRegistry.new()
	var entries: Array[Dictionary] = []
	for pair_id in BondEndingRegistry.REGISTERED_PAIR_IDS:
		var ending := registry.get_pair_ending(pair_id)
		if ending == null:
			continue
		entries.append({
			"pair_id": ending.pair_id,
			"units": _string_array_from_unit_ids(ending.units),
			"ending_title": ending.ending_title,
			"ending_text": ending.ending_text,
			"slowmo_duration": ending.slowmo_duration
		})
	return entries

static func _build_unlock_map(source: Variant, raw_entries: Array[Dictionary]) -> Dictionary:
	var unlocked_by_pair: Dictionary = {}
	if source == null or not source.has_method("get_memorial_record"):
		return unlocked_by_pair
	for raw_entry in raw_entries:
		var pair_id := String(raw_entry.get("pair_id", "")).strip_edges().to_lower()
		if pair_id.is_empty():
			continue
		var latest_timestamp := 0
		var chapter_number := int(raw_entry.get("chapter_number", 0))
		var memorial_units: Array[String] = []
		for unit_id in raw_entry.get("units", []):
			memorial_units.append(String(unit_id).strip_edges())
		if memorial_units.is_empty():
			continue
		var all_units_present := true
		for unit_id in memorial_units:
			var record := source.call("get_memorial_record", _normalize_progression_unit_id(unit_id)) as Dictionary
			if record.is_empty():
				all_units_present = false
				break
			latest_timestamp = max(latest_timestamp, int(record.get("timestamp", 0)))
			if chapter_number <= 0:
				chapter_number = _chapter_number_from_text(String(record.get("chapter_id", "")))
		if not all_units_present:
			continue
		if latest_timestamp > 0:
			unlocked_by_pair[pair_id] = {
				"unlocked": true,
				"timestamp": latest_timestamp,
				"unlocked_date": _format_timestamp(latest_timestamp),
				"chapter_number": chapter_number
			}
	return unlocked_by_pair

static func _normalize_entry(raw_entry: Dictionary, unlocked_by_pair: Dictionary) -> Dictionary:
	var pair_id := String(raw_entry.get("pair_id", raw_entry.get("id", ""))).strip_edges().to_lower()
	if pair_id.is_empty():
		return {}
	var unlocked := bool(raw_entry.get("unlocked", raw_entry.get("triggered", false)))
	var unlocked_date := String(raw_entry.get("unlocked_date", raw_entry.get("date", ""))).strip_edges()
	var unlocked_timestamp := int(raw_entry.get("timestamp", 0))
	var chapter_number := int(raw_entry.get("chapter_number", _default_chapter_number(pair_id)))
	if unlocked_by_pair.has(pair_id):
		var unlock_entry := unlocked_by_pair.get(pair_id, {}) as Dictionary
		unlocked = bool(unlock_entry.get("unlocked", unlocked))
		if unlocked_date.is_empty():
			unlocked_date = String(unlock_entry.get("unlocked_date", "")).strip_edges()
		if unlocked_timestamp <= 0:
			unlocked_timestamp = int(unlock_entry.get("timestamp", 0))
		chapter_number = int(unlock_entry.get("chapter_number", chapter_number))
	if unlocked_date.is_empty() and unlocked_timestamp > 0:
		unlocked_date = _format_timestamp(unlocked_timestamp)
	var units := _string_array_from_variant(raw_entry.get("units", []))
	return {
		"pair_id": pair_id,
		"pair_names": String(raw_entry.get("pair_names", _build_pair_names(units, pair_id))).strip_edges(),
		"ending_title": String(raw_entry.get("ending_title", raw_entry.get("title", _build_default_title(pair_id)))).strip_edges(),
		"ending_text": String(raw_entry.get("ending_text", "")).strip_edges(),
		"chapter_number": chapter_number,
		"units": units,
		"portrait_path": String(raw_entry.get("portrait_path", "")).strip_edges(),
		"unlocked": unlocked,
		"unlocked_date": unlocked_date,
		"timestamp": unlocked_timestamp
	}

static func _build_pair_names(units: Array[String], pair_id: String) -> String:
	if units.is_empty():
		return _build_pair_names_from_pair_id(pair_id)
	var names: Array[String] = []
	for unit_id in units:
		names.append(_display_name_for_unit(unit_id))
	return " & ".join(names)

static func _build_pair_names_from_pair_id(pair_id: String) -> String:
	var names: Array[String] = []
	for unit_id in pair_id.split("+", false):
		names.append(_display_name_for_unit(unit_id))
	return " & ".join(names)

static func _build_default_title(pair_id: String) -> String:
	return "%s Bond Ending" % _resolve_partner_name(pair_id)

static func _resolve_partner_name(pair_id: String) -> String:
	for unit_id in pair_id.split("+", false):
		if unit_id != "rian":
			return _display_name_for_unit(unit_id)
	return "Bond"

static func _default_chapter_number(pair_id: String) -> int:
	for raw_entry in DEFAULT_REGISTERED_PAIRS:
		var entry := raw_entry as Dictionary
		if String(entry.get("pair_id", "")).strip_edges().to_lower() == pair_id:
			return int(entry.get("chapter_number", 0))
	return 0

static func _format_timestamp(timestamp: int) -> String:
	if timestamp <= 0:
		return ""
	var parts := Time.get_datetime_dict_from_unix_time(timestamp)
	return "%04d-%02d-%02d" % [
		int(parts.get("year", 0)),
		int(parts.get("month", 0)),
		int(parts.get("day", 0))
	]

static func _dictionary_array_from_variant(value: Variant) -> Array[Dictionary]:
	var dictionaries: Array[Dictionary] = []
	if typeof(value) != TYPE_ARRAY:
		return dictionaries
	for entry in value:
		if typeof(entry) == TYPE_DICTIONARY:
			dictionaries.append((entry as Dictionary).duplicate(true))
	return dictionaries

static func _string_array_from_variant(value: Variant) -> Array[String]:
	var strings: Array[String] = []
	if typeof(value) != TYPE_ARRAY:
		return strings
	for entry in value:
		strings.append(String(entry).strip_edges())
	return strings

static func _string_array_from_unit_ids(unit_ids: Array[StringName]) -> Array[String]:
	var strings: Array[String] = []
	for unit_id in unit_ids:
		strings.append(String(unit_id).strip_edges())
	return strings

static func _display_name_for_unit(unit_id: String) -> String:
	var normalized := unit_id.strip_edges().trim_prefix("ally_").trim_suffix("_ally")
	return normalized.capitalize() if not normalized.is_empty() else "Unknown"

static func _normalize_progression_unit_id(unit_id: String) -> String:
	var normalized := unit_id.strip_edges().to_lower().trim_prefix("ally_").trim_suffix("_ally")
	match normalized:
		"lete":
			return "ally_lete"
		"mira":
			return "ally_mira"
		"melkion":
			return "ally_melkion_ally"
		_:
			return "ally_%s" % normalized if not normalized.is_empty() else ""

static func _chapter_number_from_text(chapter_text: String) -> int:
	var normalized := chapter_text.strip_edges().to_upper()
	match normalized:
		"CH01":
			return 1
		"CH02":
			return 2
		"CH03":
			return 3
		"CH04":
			return 4
		"CH05":
			return 5
		"CH06":
			return 6
		"CH07":
			return 7
		"CH08":
			return 8
		"CH09A":
			return 9
		"CH09B":
			return 10
		"CH10":
			return 11
		_:
			return 0

func _resolve_pair_colors(pair_id: String) -> Array[Color]:
	var hash_value: int = abs(int(pair_id.hash()))
	var left_color := Color.from_hsv(float(hash_value % 100) / 100.0, 0.46, 0.52)
	var right_color := Color.from_hsv(float((hash_value / 7) % 100) / 100.0, 0.52, 0.68)
	return [left_color, right_color]

func _build_pair_initials(pair_id: String) -> String:
	var initials: Array[String] = []
	for unit_id in pair_id.split(":", false):
		var display_name := SupportConversations.get_unit_display_name(unit_id)
		if not display_name.is_empty():
			initials.append(display_name.left(1).to_upper())
	return "/".join(initials)

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
