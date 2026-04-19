class_name EncyclopediaPanel
extends Control

const ProgressionData = preload("res://scripts/data/progression_data.gd")
const SupportConversations = preload("res://scripts/data/support_conversations.gd")

signal close_requested

const TAB_CODEX := "codex"
const TAB_TIMELINE := "timeline"
const TAB_MEMORIAL := "memorial"
const TAB_ATLAS := "atlas"
const TAB_ORDER := [TAB_CODEX, TAB_TIMELINE, TAB_MEMORIAL, TAB_ATLAS]
const TAB_LABELS := {
	TAB_CODEX: "Codex",
	TAB_TIMELINE: "Timeline",
	TAB_MEMORIAL: "Memorial",
	TAB_ATLAS: "Atlas"
}
const CHAPTER_LOCATION_NAMES := {
	"CH01": "Hardren Ashfields",
	"CH02": "Hardren Fortress",
	"CH03": "Greenwood",
	"CH04": "Whiteflow Monastery",
	"CH05": "Saria Archive",
	"CH06": "Valtor Gate",
	"CH07": "Ellyor",
	"CH08": "Black Hound Ruins",
	"CH09A": "Broken Standard",
	"CH09B": "Root Archive",
	"CH10": "Nameless Tower"
}

@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $Panel/Margin/Content/HeaderRow/TitleLabel
@onready var close_button: Button = $Panel/Margin/Content/HeaderRow/CloseButton
@onready var codex_button: Button = $Panel/Margin/Content/TabButtons/CodexButton
@onready var timeline_button: Button = $Panel/Margin/Content/TabButtons/TimelineButton
@onready var memorial_button: Button = $Panel/Margin/Content/TabButtons/MemorialButton
@onready var atlas_button: Button = $Panel/Margin/Content/TabButtons/AtlasButton
@onready var codex_tab: Control = $Panel/Margin/Content/BodyStack/CodexTab
@onready var codex_cards: GridContainer = $Panel/Margin/Content/BodyStack/CodexTab/CodexBody/CodexScroll/CodexCards
@onready var codex_detail_label: RichTextLabel = $Panel/Margin/Content/BodyStack/CodexTab/CodexBody/CodexDetail/Margin/DetailLabel
@onready var codex_detail_margin: MarginContainer = $Panel/Margin/Content/BodyStack/CodexTab/CodexBody/CodexDetail/Margin
@onready var timeline_tab: Control = $Panel/Margin/Content/BodyStack/TimelineTab
@onready var timeline_label: RichTextLabel = $Panel/Margin/Content/BodyStack/TimelineTab/TimelineScroll/TimelineLabel
@onready var memorial_tab: Control = $Panel/Margin/Content/BodyStack/MemorialTab
@onready var memorial_cards: GridContainer = $Panel/Margin/Content/BodyStack/MemorialTab/MemorialScroll/MemorialCards
@onready var atlas_tab: Control = $Panel/Margin/Content/BodyStack/AtlasTab
@onready var atlas_label: RichTextLabel = $Panel/Margin/Content/BodyStack/AtlasTab/AtlasScroll/AtlasLabel

var _progression_data: ProgressionData = null
var _active_chapter_id: StringName = StringName()
var _active_tab: String = TAB_CODEX
var _selected_codex_key: String = ""
var _codex_keys: Array[String] = []
var _support_history_toggle: Button
var _support_history_label: RichTextLabel
var _support_history_expanded: bool = false

func _ready() -> void:
	visible = false
	title_label.text = "Post-Game Encyclopedia"
	close_button.pressed.connect(_on_close_pressed)
	codex_button.pressed.connect(func() -> void: select_tab(TAB_CODEX))
	timeline_button.pressed.connect(func() -> void: select_tab(TAB_TIMELINE))
	memorial_button.pressed.connect(func() -> void: select_tab(TAB_MEMORIAL))
	atlas_button.pressed.connect(func() -> void: select_tab(TAB_ATLAS))
	_ensure_support_history_section()
	select_tab(TAB_CODEX)

func show_context(context: Dictionary) -> void:
	show_encyclopedia(
		context.get("progression_data", null) as ProgressionData,
		StringName(context.get("active_chapter_id", ""))
	)

func show_encyclopedia(progression_data: ProgressionData, active_chapter_id: StringName = StringName()) -> void:
	_progression_data = progression_data
	_active_chapter_id = active_chapter_id
	if _progression_data == null:
		return
	_rebuild_codex()
	_rebuild_timeline()
	_rebuild_memorial()
	_rebuild_atlas()
	visible = true
	select_tab(TAB_CODEX)

func hide_panel() -> void:
	visible = false

func select_tab(tab_name: String) -> void:
	if not TAB_ORDER.has(tab_name):
		tab_name = TAB_CODEX
	_active_tab = tab_name
	codex_tab.visible = tab_name == TAB_CODEX
	timeline_tab.visible = tab_name == TAB_TIMELINE
	memorial_tab.visible = tab_name == TAB_MEMORIAL
	atlas_tab.visible = tab_name == TAB_ATLAS
	codex_button.disabled = tab_name == TAB_CODEX
	timeline_button.disabled = tab_name == TAB_TIMELINE
	memorial_button.disabled = tab_name == TAB_MEMORIAL
	atlas_button.disabled = tab_name == TAB_ATLAS

func select_codex_entry(unit_key: String) -> void:
	if not _codex_keys.has(unit_key):
		return
	_selected_codex_key = unit_key
	_rebuild_codex()

func get_snapshot() -> Dictionary:
	return {
		"visible": visible,
		"active_tab": _active_tab,
		"codex_count": _codex_keys.size(),
		"selected_codex_key": _selected_codex_key,
		"codex_detail": codex_detail_label.text,
		"support_history_text": _support_history_label.text if _support_history_label != null else "",
		"timeline_text": timeline_label.text,
		"memorial_count": min(3, _progression_data.epitaphs.size()) if _progression_data != null else 0,
		"atlas_text": atlas_label.text
	}

func _rebuild_codex() -> void:
	_clear_children(codex_cards)
	_codex_keys.clear()
	if _progression_data == null:
		codex_detail_label.text = ""
		return
	for unit_key in _progression_data.encyclopedia_entries.keys():
		_codex_keys.append(String(unit_key))
	_codex_keys.sort_custom(func(a: String, b: String) -> bool:
		var entry_a: Dictionary = _progression_data.encyclopedia_entries.get(a, {})
		var entry_b: Dictionary = _progression_data.encyclopedia_entries.get(b, {})
		var chapter_a := int(entry_a.get("chapter_introduced", 999))
		var chapter_b := int(entry_b.get("chapter_introduced", 999))
		if chapter_a == chapter_b:
			return String(entry_a.get("name", a)) < String(entry_b.get("name", b))
		return chapter_a < chapter_b
	)
	if _codex_keys.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No entries recorded yet."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		codex_cards.add_child(empty_label)
		_selected_codex_key = ""
		codex_detail_label.text = "Recruit allies or defeat enemies to start the record."
		return
	if _selected_codex_key.is_empty() or not _codex_keys.has(_selected_codex_key):
		_selected_codex_key = _codex_keys[0]
	for unit_key in _codex_keys:
		var entry: Dictionary = _progression_data.encyclopedia_entries.get(unit_key, {})
		var button := Button.new()
		button.text = _build_codex_card_label(entry)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.custom_minimum_size = Vector2(190.0, 76.0)
		button.disabled = unit_key == _selected_codex_key
		button.tooltip_text = _build_codex_tooltip(entry)
		button.pressed.connect(func() -> void:
			_selected_codex_key = unit_key
			_rebuild_codex()
		)
		codex_cards.add_child(button)
	_render_codex_detail()

func _render_codex_detail() -> void:
	if _progression_data == null or _selected_codex_key.is_empty():
		codex_detail_label.text = ""
		return
	var entry: Dictionary = _progression_data.encyclopedia_entries.get(_selected_codex_key, {})
	var stats: Dictionary = entry.get("stats", {})
	var lines: Array[String] = [
		"[b]%s[/b]" % String(entry.get("name", _selected_codex_key)),
		"Type: %s" % String(entry.get("type", "Unknown")),
		"Introduced: Chapter %d" % int(entry.get("chapter_introduced", 0))
	]
	if not String(entry.get("type", "")).begins_with("Enemy"):
		lines.append("Support Rank: %s" % _format_support_rank(int(entry.get("support_rank", 0))))
	lines.append("Stats: HP %d / ATK %d / DEF %d / MOV %d / RNG %d" % [
		int(stats.get("hp", 0)),
		int(stats.get("attack", 0)),
		int(stats.get("defense", 0)),
		int(stats.get("movement", 0)),
		int(stats.get("range", 0))
	])
	var quote := String(entry.get("quote", "")).strip_edges()
	if not quote.is_empty():
		lines.append("\n[i]\"%s\"[/i]" % quote)
	codex_detail_label.text = "\n".join(lines)
	_render_support_history(entry)

func _ensure_support_history_section() -> void:
	if codex_detail_margin == null or _support_history_toggle != null:
		return
	_support_history_toggle = Button.new()
	_support_history_toggle.text = "▶ Support History"
	_support_history_toggle.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_support_history_toggle.flat = true
	_support_history_toggle.pressed.connect(func() -> void:
		_support_history_expanded = not _support_history_expanded
		_render_codex_detail()
	)
	_support_history_label = RichTextLabel.new()
	_support_history_label.bbcode_enabled = true
	_support_history_label.fit_content = true
	_support_history_label.visible = false
	codex_detail_margin.add_child(_support_history_toggle)
	codex_detail_margin.add_child(_support_history_label)

func _render_support_history(entry: Dictionary) -> void:
	if _support_history_toggle == null or _support_history_label == null or _progression_data == null:
		return
	if String(entry.get("type", "")).begins_with("Enemy"):
		_support_history_toggle.visible = false
		_support_history_label.visible = false
		_support_history_label.text = ""
		return
	var support_rank := int(entry.get("support_rank", 0))
	var pair_id := SupportConversations.normalize_pair_id("ally_rian:%s" % _selected_codex_key)
	var history: Array[Dictionary] = _progression_data.get_support_history_for_pair(pair_id)
	if support_rank < 3 or history.is_empty() or _selected_codex_key == "ally_rian":
		_support_history_toggle.visible = false
		_support_history_label.visible = false
		_support_history_label.text = ""
		return
	_support_history_toggle.visible = true
	_support_history_toggle.text = ("▼" if _support_history_expanded else "▶") + " Support History"
	_support_history_label.visible = _support_history_expanded
	if not _support_history_expanded:
		_support_history_label.text = ""
		return
	var lines: Array[String] = []
	for history_entry in history:
		var rank_value := int(history_entry.get("rank", 0))
		var chapter := String(history_entry.get("chapter", "")).strip_edges()
		var chapter_label := chapter if not chapter.is_empty() else String(history_entry.get("stage_id", "")).strip_edges()
		var line_text := SupportConversations.get_support_history_line(pair_id, rank_value)
		lines.append("%s — %s-rank: \"%s\"" % [
			chapter_label,
			SupportConversations.get_rank_label(rank_value),
			line_text
		])
	_support_history_label.text = "[b]Relationship Timeline[/b]\n%s" % "\n".join(lines)

func _rebuild_timeline() -> void:
	if _progression_data == null:
		timeline_label.text = ""
		return
	var chapters := _get_completed_chapters()
	var lines: Array[String] = []
	for chapter_id in chapters:
		lines.append("[b]%s[/b] — %s" % [chapter_id, _get_location_name(chapter_id)])
		var chapter_choices := _get_choices_for_chapter(chapter_id)
		if chapter_choices.is_empty():
			lines.append("  • No branch choice recorded.")
		else:
			for choice_record in chapter_choices:
				lines.append("  • %s" % choice_record)
	if lines.is_empty():
		lines.append("No completed chapters recorded yet.")
	if not _progression_data.battle_records.is_empty():
		lines.append("\n[b]Battle Record[/b]")
		for record in _progression_data.battle_records:
			lines.append("  • %s — %d turns, %d★" % [
				String(record.get("stage_id", "")),
				int(record.get("turns", 0)),
				int(record.get("star_rating", 0))
			])
	timeline_label.text = "\n".join(lines)

func _rebuild_memorial() -> void:
	_clear_children(memorial_cards)
	if _progression_data == null or _progression_data.epitaphs.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No sacrifices have been etched into the memorial."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		memorial_cards.add_child(empty_label)
		return
	for index in range(min(3, _progression_data.epitaphs.size())):
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(200.0, 120.0)
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_bottom", 10)
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = _progression_data.epitaphs[index]
		margin.add_child(label)
		card.add_child(margin)
		memorial_cards.add_child(card)

func _rebuild_atlas() -> void:
	if _progression_data == null:
		atlas_label.text = ""
		return
	var chapters := _get_completed_chapters()
	if chapters.is_empty() and _active_chapter_id != StringName():
		chapters.append(String(_active_chapter_id))
	if chapters.is_empty():
		atlas_label.text = "No route has been charted yet."
		return
	var locations: Array[String] = []
	for chapter_id in chapters:
		locations.append(_get_location_name(chapter_id))
	atlas_label.text = "[b]Visited Route[/b]\n%s" % " -> ".join(locations)

func _build_codex_card_label(entry: Dictionary) -> String:
	var support_suffix := ""
	if not String(entry.get("type", "")).begins_with("Enemy"):
		support_suffix = "\nRank %s" % _format_support_rank(int(entry.get("support_rank", 0)))
	return "%s\n%s%s" % [
		String(entry.get("name", "Unknown")),
		String(entry.get("type", "Unknown")),
		support_suffix
	]

func _build_codex_tooltip(entry: Dictionary) -> String:
	return "%s — Chapter %d" % [
		String(entry.get("name", "Unknown")),
		int(entry.get("chapter_introduced", 0))
	]

func _get_completed_chapters() -> Array[String]:
	var chapters: Array[String] = []
	if _progression_data == null:
		return chapters
	for chapter_id in _progression_data.chapters_completed:
		var normalized := String(chapter_id).strip_edges()
		if not normalized.is_empty() and not chapters.has(normalized):
			chapters.append(normalized)
	if chapters.is_empty():
		for record in _progression_data.battle_records:
			var stage_id := String(record.get("stage_id", ""))
			var derived := _derive_chapter_from_stage(stage_id)
			if not derived.is_empty() and not chapters.has(derived):
				chapters.append(derived)
	return chapters

func _get_choices_for_chapter(chapter_id: String) -> Array[String]:
	var lines: Array[String] = []
	if _progression_data == null:
		return lines
	for choice_record in _progression_data.choices_made:
		var text := String(choice_record)
		if _derive_chapter_from_choice(text) == chapter_id:
			lines.append(text)
	return lines

func _derive_chapter_from_stage(stage_id: String) -> String:
	var normalized := stage_id.to_upper().strip_edges()
	for chapter_id in CHAPTER_LOCATION_NAMES.keys():
		if normalized.begins_with(String(chapter_id)):
			return String(chapter_id)
	return ""

func _derive_chapter_from_choice(choice_record: String) -> String:
	var normalized := choice_record.to_upper().strip_edges()
	for chapter_id in CHAPTER_LOCATION_NAMES.keys():
		if normalized.begins_with(String(chapter_id)):
			return String(chapter_id)
	return ""

func _get_location_name(chapter_id: String) -> String:
	return String(CHAPTER_LOCATION_NAMES.get(chapter_id, chapter_id))

func _format_support_rank(rank_value: int) -> String:
	return SupportConversations.get_rank_label(rank_value)

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func _on_close_pressed() -> void:
	hide_panel()
	close_requested.emit()
