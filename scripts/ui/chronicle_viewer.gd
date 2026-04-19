class_name ChronicleViewer
extends Control

const ChronicleEntry = preload("res://scripts/battle/chronicle_entry.gd")
const DestinyManagerRef = preload("res://scripts/battle/destiny_manager.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

const DISPLAY_ORDER: Array[String] = [
	"CH01_02",
	"CH04_01",
	"CH07_05",
	"CH09B_05",
	"CH10_05",
]

var _progression_data: ProgressionData = null
var _current_spread_index: int = 0
var _entries_by_chapter: Dictionary = {}
var _destiny_manager: Node = null

var _left_page: Control
var _right_page: Control
var _left_chapter_label: Label
var _right_chapter_label: Label
var _left_title_label: Label
var _right_title_label: Label
var _left_date_label: Label
var _right_date_label: Label
var _left_body_label: RichTextLabel
var _right_body_label: RichTextLabel
var _prev_button: Button
var _next_button: Button
var _page_borders: Array[Line2D] = []
var _rewrite_panel: PanelContainer
var _rewrite_hint_label: Label
var _rewrite_list: VBoxContainer

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_interface()
	_ensure_destiny_manager()
	_refresh_entry_catalog()
	_render_spread()
	resized.connect(_refresh_page_borders)

func bind_progression(progression_data: ProgressionData) -> void:
	_progression_data = progression_data
	if _destiny_manager != null:
		_destiny_manager.refresh_from_progression(_progression_data)
	_refresh_entry_catalog()
	_render_spread()

func request_tts_preview() -> void:
	pass

func _build_interface() -> void:
	var root_margin := MarginContainer.new()
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 36)
	root_margin.add_theme_constant_override("margin_top", 28)
	root_margin.add_theme_constant_override("margin_right", 36)
	root_margin.add_theme_constant_override("margin_bottom", 28)
	add_child(root_margin)

	var root_stack := VBoxContainer.new()
	root_stack.add_theme_constant_override("separation", 18)
	root_margin.add_child(root_stack)

	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 12)
	root_stack.add_child(header)

	_prev_button = Button.new()
	_prev_button.text = "◀ Previous"
	_prev_button.pressed.connect(_show_previous_spread)
	header.add_child(_prev_button)

	var heading := Label.new()
	heading.text = "Living Chronicle"
	heading.add_theme_font_size_override("font_size", 28)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(heading)

	_next_button = Button.new()
	_next_button.text = "Next ▶"
	_next_button.pressed.connect(_show_next_spread)
	header.add_child(_next_button)

	var book_container := HBoxContainer.new()
	book_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	book_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	book_container.add_theme_constant_override("separation", 0)
	root_stack.add_child(book_container)

	_left_page = _build_page("left")
	_right_page = _build_page("right")
	var spine := ColorRect.new()
	spine.custom_minimum_size = Vector2(18, 0)
	spine.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spine.color = Color("5a3d26")

	book_container.add_child(_left_page)
	book_container.add_child(spine)
	book_container.add_child(_right_page)

	_rewrite_panel = PanelContainer.new()
	_rewrite_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rewrite_panel.custom_minimum_size = Vector2(0, 180)
	root_stack.add_child(_rewrite_panel)

	var rewrite_margin := MarginContainer.new()
	rewrite_margin.add_theme_constant_override("margin_left", 22)
	rewrite_margin.add_theme_constant_override("margin_top", 18)
	rewrite_margin.add_theme_constant_override("margin_right", 22)
	rewrite_margin.add_theme_constant_override("margin_bottom", 18)
	_rewrite_panel.add_child(rewrite_margin)

	var rewrite_stack := VBoxContainer.new()
	rewrite_stack.add_theme_constant_override("separation", 10)
	rewrite_margin.add_child(rewrite_stack)

	var rewrite_title := Label.new()
	rewrite_title.text = "Rewrite the Chronicle"
	rewrite_title.add_theme_font_size_override("font_size", 22)
	rewrite_stack.add_child(rewrite_title)

	_rewrite_hint_label = Label.new()
	_rewrite_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rewrite_hint_label.modulate = Color("7d6851")
	rewrite_stack.add_child(_rewrite_hint_label)

	var rewrite_scroll := ScrollContainer.new()
	rewrite_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rewrite_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rewrite_scroll.custom_minimum_size = Vector2(0, 120)
	rewrite_stack.add_child(rewrite_scroll)

	_rewrite_list = VBoxContainer.new()
	_rewrite_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rewrite_list.add_theme_constant_override("separation", 12)
	rewrite_scroll.add_child(_rewrite_list)

	_refresh_page_borders()
	_refresh_rewrite_panel()

func _build_page(side: String) -> Control:
	var page_root := Control.new()
	page_root.custom_minimum_size = Vector2(420, 520)
	page_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_root.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var parchment := ColorRect.new()
	parchment.set_anchors_preset(Control.PRESET_FULL_RECT)
	parchment.color = Color("e7d8b3")
	page_root.add_child(parchment)

	var edge_shadow := ColorRect.new()
	edge_shadow.set_anchors_preset(Control.PRESET_FULL_RECT)
	edge_shadow.color = Color(0.32, 0.23, 0.12, 0.08)
	edge_shadow.offset_left = 8 if side == "right" else 0
	edge_shadow.offset_right = -8 if side == "left" else 0
	page_root.add_child(edge_shadow)

	var inner_tint := ColorRect.new()
	inner_tint.anchor_left = 0.08
	inner_tint.anchor_top = 0.06
	inner_tint.anchor_right = 0.92
	inner_tint.anchor_bottom = 0.94
	inner_tint.color = Color(0.98, 0.95, 0.84, 0.36)
	page_root.add_child(inner_tint)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_top", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_bottom", 34)
	page_root.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)

	var chapter_label := Label.new()
	chapter_label.add_theme_font_size_override("font_size", 14)
	chapter_label.modulate = Color("5f4b33")
	content.add_child(chapter_label)

	var title_label := Label.new()
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(title_label)

	var date_label := Label.new()
	date_label.add_theme_font_size_override("font_size", 13)
	date_label.modulate = Color("7d6851")
	content.add_child(date_label)

	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(0, 2)
	divider.color = Color("8a6b44")
	content.add_child(divider)

	var body_label := RichTextLabel.new()
	body_label.bbcode_enabled = false
	body_label.fit_content = false
	body_label.scroll_active = false
	body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("normal_font_size", 17)
	content.add_child(body_label)

	var border := Line2D.new()
	border.width = 2.0
	border.default_color = Color("7e5c3a")
	page_root.add_child(border)
	_page_borders.append(border)
	page_root.resized.connect(_refresh_page_borders)

	if side == "left":
		_left_chapter_label = chapter_label
		_left_title_label = title_label
		_left_date_label = date_label
		_left_body_label = body_label
	else:
		_right_chapter_label = chapter_label
		_right_title_label = title_label
		_right_date_label = date_label
		_right_body_label = body_label

	return page_root

func _refresh_entry_catalog() -> void:
	_entries_by_chapter.clear()
	for entry in _build_seeded_entries():
		_entries_by_chapter[entry.chapter_id] = entry
	if _progression_data != null:
		for raw_entry in _progression_data.chronicle_entries:
			var chronicle_entry := raw_entry as ChronicleEntry
			if chronicle_entry == null:
				continue
			var normalized_chapter_id := chronicle_entry.chapter_id.strip_edges().to_upper()
			if normalized_chapter_id.is_empty():
				continue
			_entries_by_chapter[normalized_chapter_id] = chronicle_entry

func _build_seeded_entries() -> Array[ChronicleEntry]:
	var entries: Array[ChronicleEntry] = []
	entries.append(_make_seed_entry("CH01_02", "Ashen Field", "Spring 12", ChronicleEntry.ChronicleStyle.CONCISE, "The company crossed the ash with measured steps, breaking the first raider cordon before panic could root itself."))
	entries.append(_make_seed_entry("CH04_01", "Flooded Cloister", "Spring 29", ChronicleEntry.ChronicleStyle.POETIC, "Rain pressed against the stone while the cloister gave way piece by piece, and discipline carried the squad through the drowned bells."))
	entries.append(_make_seed_entry("CH07_05", "Prayer of Ellyor", "Summer 17", ChronicleEntry.ChronicleStyle.BATTLE, "At the shrine, prayer and steel met together; the line bent, answered, and held long enough to turn the pursuit."))
	entries.append(_make_seed_entry("CH10_05", "선택한 사람들", "Winter 03", ChronicleEntry.ChronicleStyle.BATTLE, "The final tower was won by memory and stubborn order, each bell strike answering a name that refused to vanish."))
	return entries

func _make_seed_entry(chapter_id: String, chapter_title: String, entry_date: String, style: ChronicleEntry.ChronicleStyle, narrative_text: String) -> ChronicleEntry:
	var entry := ChronicleEntry.new()
	entry.chapter_id = chapter_id
	entry.chapter_title = chapter_title
	entry.entry_date = entry_date
	entry.style = style
	entry.narrative_text = narrative_text
	return entry

func _render_spread() -> void:
	_render_page(_current_spread_index, _left_chapter_label, _left_title_label, _left_date_label, _left_body_label)
	_render_page(_current_spread_index + 1, _right_chapter_label, _right_title_label, _right_date_label, _right_body_label)
	_prev_button.disabled = _current_spread_index <= 0
	_next_button.disabled = _current_spread_index + 2 >= DISPLAY_ORDER.size()
	_refresh_rewrite_panel()

func _render_page(index: int, chapter_label: Label, title_label: Label, date_label: Label, body_label: RichTextLabel) -> void:
	if chapter_label == null or title_label == null or date_label == null or body_label == null:
		return
	if index < 0 or index >= DISPLAY_ORDER.size():
		chapter_label.text = ""
		title_label.text = ""
		date_label.text = ""
		body_label.text = ""
		return

	var chapter_id := DISPLAY_ORDER[index]
	var entry := _entries_by_chapter.get(chapter_id, null) as ChronicleEntry
	if entry == null:
		chapter_label.text = _format_chapter_label(chapter_id)
		title_label.text = "???"
		date_label.text = ""
		body_label.text = "???"
		return

	chapter_label.text = _format_chapter_label(chapter_id)
	title_label.text = entry.chapter_title
	date_label.text = entry.entry_date
	body_label.text = entry.get_formatted_text()

func _format_chapter_label(chapter_id: String) -> String:
	var normalized := chapter_id.strip_edges().to_upper()
	if not normalized.begins_with("CH"):
		return normalized
	var split_index := normalized.find("_")
	var chapter_code := normalized.substr(2, split_index - 2) if split_index >= 0 else normalized.substr(2)
	var entry_code := normalized.get_slice("_", 1)
	if entry_code.is_empty():
		return "Chapter %s" % chapter_code
	return "Chapter %s • Entry %s" % [chapter_code, entry_code]

func _show_previous_spread() -> void:
	_current_spread_index = maxi(0, _current_spread_index - 2)
	_render_spread()

func _show_next_spread() -> void:
	_current_spread_index = mini(maxi(0, DISPLAY_ORDER.size() - 1), _current_spread_index + 2)
	_render_spread()

func _refresh_page_borders() -> void:
	var page_controls: Array[Control] = [_left_page, _right_page]
	for index in range(page_controls.size()):
		var page := page_controls[index]
		if page == null or index >= _page_borders.size():
			continue
		var border := _page_borders[index]
		var inset := 18.0
		var width := maxf(0.0, page.size.x - inset * 2.0)
		var height := maxf(0.0, page.size.y - inset * 2.0)
		border.points = PackedVector2Array([
			Vector2(inset, inset),
			Vector2(inset + width, inset),
			Vector2(inset + width, inset + height),
			Vector2(inset, inset + height),
			Vector2(inset, inset),
		])

func _ensure_destiny_manager() -> void:
	if _destiny_manager != null:
		return
	_destiny_manager = DestinyManagerRef.new()
	_destiny_manager.name = "ChronicleDestinyManager"
	add_child(_destiny_manager)
	if _progression_data != null:
		_destiny_manager.refresh_from_progression(_progression_data)
	if _destiny_manager.has_signal("decisions_changed"):
		_destiny_manager.decisions_changed.connect(_on_destiny_decisions_changed)

func _refresh_rewrite_panel() -> void:
	if _rewrite_panel == null or _rewrite_hint_label == null or _rewrite_list == null:
		return
	_clear_rewrite_list()
	if _destiny_manager == null:
		_rewrite_hint_label.text = "Destiny data is not available in this Chronicle view."
		return
	if not _destiny_manager.is_destiny_unlocked():
		_rewrite_hint_label.text = "Unlocked at NG+3 or after completing the Third Eye."
		return
	var rewrite_entries: Array = _destiny_manager.get_chronicle_rewrite_entries()
	if rewrite_entries.is_empty():
		_rewrite_hint_label.text = "No recorded campaign choices can be rewritten yet."
		return
	_rewrite_hint_label.text = "Select a remembered branch to rewrite it. The Destiny system will resync the live world immediately."
	for entry in rewrite_entries:
		var card := _build_rewrite_card(entry)
		if card != null:
			_rewrite_list.add_child(card)

func _build_rewrite_card(entry: Dictionary) -> Control:
	var choice_key := String(entry.get("choice_key", "")).strip_edges()
	var chapter_id := String(entry.get("chapter_id", "")).strip_edges()
	if chapter_id.is_empty() or choice_key.is_empty():
		return null

	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	card.add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	margin.add_child(stack)

	var title_label := Label.new()
	title_label.text = "%s • %s" % [chapter_id, String(entry.get("title", choice_key)).strip_edges()]
	title_label.add_theme_font_size_override("font_size", 18)
	stack.add_child(title_label)

	var prompt_label := Label.new()
	prompt_label.text = String(entry.get("prompt", "")).strip_edges()
	prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_label.modulate = Color("6a533d")
	stack.add_child(prompt_label)

	var current_label := Label.new()
	current_label.text = "Current record: %s" % String(entry.get("current_label", entry.get("current_value", ""))).strip_edges()
	current_label.modulate = Color(0.24, 0.38, 0.3)
	stack.add_child(current_label)

	var option_row := HBoxContainer.new()
	option_row.add_theme_constant_override("separation", 8)
	option_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_child(option_row)

	for raw_option in entry.get("options", []):
		if typeof(raw_option) != TYPE_DICTIONARY:
			continue
		var option := raw_option as Dictionary
		var option_id := String(option.get("id", "")).strip_edges()
		if option_id.is_empty():
			continue
		var button := Button.new()
		button.text = String(option.get("label", option_id)).strip_edges()
		button.tooltip_text = String(option.get("hint", "")).strip_edges()
		button.disabled = bool(option.get("selected", false)) or bool(option.get("disabled", false))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func() -> void:
			_apply_chronicle_rewrite(chapter_id, choice_key, option_id)
		)
		option_row.add_child(button)
	return card

func _apply_chronicle_rewrite(chapter_id: String, choice_key: String, option_id: String) -> void:
	if _destiny_manager == null:
		return
	if not _destiny_manager.change_past_decision(chapter_id, choice_key, option_id):
		return
	if _progression_data != null:
		_destiny_manager.refresh_from_progression(_progression_data)
	_refresh_entry_catalog()
	_render_spread()

func _on_destiny_decisions_changed() -> void:
	_refresh_rewrite_panel()

func _clear_rewrite_list() -> void:
	if _rewrite_list == null:
		return
	for child in _rewrite_list.get_children():
		child.queue_free()
