class_name EncyclopediaPanel
extends Control

const ProgressionData = preload("res://scripts/data/progression_data.gd")
const CampaignShellDialogueCatalog = preload("res://scripts/campaign/campaign_shell_dialogue_catalog.gd")
const MemorialSceneScript = preload("res://scripts/campaign/memorial_scene.gd")
const MemorialSceneBondSection = preload("res://scripts/campaign/memorial_scene_bond_section.gd")
const SupportConversations = preload("res://scripts/data/support_conversations.gd")
const GhostFormationData = preload("res://scripts/data/ghost_formation_data.gd")
const GuildSystem = preload("res://scripts/battle/guild_system.gd")

signal close_requested

const TAB_CODEX := "codex"
const TAB_TIMELINE := "timeline"
const TAB_MEMORIAL := "memorial"
const TAB_ATLAS := "atlas"
const TAB_BOND_ENDINGS := "bond_endings"
const TAB_USER_CREATED := "user_created"
const TAB_GUILD := "guild"
const TAB_DESTINY := "destiny"
const MAX_COMMENT_LENGTH := 280
const GHOST_REGISTRY_PATH := "user://ghost_registry.dat"
const TAB_ORDER := [TAB_CODEX, TAB_TIMELINE, TAB_MEMORIAL, TAB_ATLAS, TAB_BOND_ENDINGS, TAB_USER_CREATED, TAB_GUILD, TAB_DESTINY]
const TAB_LABELS := {
	TAB_CODEX: "Codex",
	TAB_TIMELINE: "Timeline",
	TAB_MEMORIAL: "Memorial",
	TAB_ATLAS: "Atlas",
	TAB_BOND_ENDINGS: "Bond Endings",
	TAB_USER_CREATED: "User Created",
	TAB_GUILD: "Guild",
	TAB_DESTINY: "Destiny"
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
@onready var bond_endings_button: Button = $Panel/Margin/Content/TabButtons/BondEndingsButton
var user_created_button: Button
var _user_created_tab: Control
var _user_created_list: Control
var guild_button: Button
var _guild_tab: Control
var _guild_list: Control
var _guild_create_container: Control
var destiny_button: Button
var _destiny_tab: Control
@onready var codex_tab: Control = $Panel/Margin/Content/BodyStack/CodexTab
@onready var codex_cards: GridContainer = $Panel/Margin/Content/BodyStack/CodexTab/CodexBody/CodexScroll/CodexCards
@onready var codex_detail_label: RichTextLabel = $Panel/Margin/Content/BodyStack/CodexTab/CodexBody/CodexDetail/Margin/DetailStack/DetailLabel
@onready var worldview_detail_label: RichTextLabel = $Panel/Margin/Content/BodyStack/CodexTab/CodexBody/CodexDetail/Margin/DetailStack/WorldviewLabel
@onready var codex_detail_stack: VBoxContainer = $Panel/Margin/Content/BodyStack/CodexTab/CodexBody/CodexDetail/Margin/DetailStack
@onready var timeline_tab: Control = $Panel/Margin/Content/BodyStack/TimelineTab
@onready var timeline_label: RichTextLabel = $Panel/Margin/Content/BodyStack/TimelineTab/TimelineScroll/TimelineLabel
@onready var memorial_tab: Control = $Panel/Margin/Content/BodyStack/MemorialTab
@onready var memorial_cards: GridContainer = $Panel/Margin/Content/BodyStack/MemorialTab/MemorialScroll/MemorialCards
@onready var atlas_tab: Control = $Panel/Margin/Content/BodyStack/AtlasTab
@onready var atlas_label: RichTextLabel = $Panel/Margin/Content/BodyStack/AtlasTab/AtlasScroll/AtlasLabel
@onready var bond_endings_tab: Control = $Panel/Margin/Content/BodyStack/BondEndingsTab
@onready var bond_endings_list: VBoxContainer = $Panel/Margin/Content/BodyStack/BondEndingsTab/BondEndingsScroll/BondEndingsList

var _progression_data: ProgressionData = null
var _active_chapter_id: StringName = StringName()
var _active_tab: String = TAB_CODEX
var _selected_codex_key: String = ""
var _codex_keys: Array[String] = []
var _support_history_toggle: Button
var _support_history_label: RichTextLabel
var _support_history_expanded: bool = false
var _comment_editor_container: VBoxContainer
var _comment_editor_text: TextEdit
var _comment_counter_label: Label
var _comment_save_button: Button
var _comment_cancel_button: Button
var _comment_editor_open: bool = false
var _comment_editor_unit_key: String = ""
var _comment_text_syncing: bool = false

func _ready() -> void:
	visible = false
	title_label.text = "Post-Game Encyclopedia"
	close_button.pressed.connect(_on_close_pressed)
	codex_button.pressed.connect(func() -> void: select_tab(TAB_CODEX))
	timeline_button.pressed.connect(func() -> void: select_tab(TAB_TIMELINE))
	memorial_button.pressed.connect(func() -> void: select_tab(TAB_MEMORIAL))
	atlas_button.pressed.connect(func() -> void: select_tab(TAB_ATLAS))
	bond_endings_button.pressed.connect(func() -> void: select_tab(TAB_BOND_ENDINGS))
	user_created_button = _get_node_or_null("Panel/Margin/Content/TabButtons/UserCreatedButton")
	_user_created_tab = _get_node_or_null("Panel/Margin/Content/BodyStack/UserCreatedTab")
	_user_created_list = _get_node_or_null("Panel/Margin/Content/BodyStack/UserCreatedTab/UserCreatedScroll/UserCreatedList")
	if user_created_button != null:
		user_created_button.pressed.connect(func() -> void: select_tab(TAB_USER_CREATED))
	guild_button = _get_node_or_null("Panel/Margin/Content/TabButtons/GuildButton")
	_guild_tab = _get_node_or_null("Panel/Margin/Content/BodyStack/GuildTab")
	_guild_list = _get_node_or_null("Panel/Margin/Content/BodyStack/GuildTab/GuildScroll/GuildList")
	_guild_create_container = _get_node_or_null("Panel/Margin/Content/BodyStack/GuildTab/GuildCreateContainer")
	if guild_button != null:
		guild_button.pressed.connect(func() -> void: select_tab(TAB_GUILD))
	destiny_button = _get_node_or_null("Panel/Margin/Content/TabButtons/DestinyButton")
	_destiny_tab = _get_node_or_null("Panel/Margin/Content/BodyStack/DestinyTab")
	if destiny_button != null:
		destiny_button.pressed.connect(func() -> void: select_tab(TAB_DESTINY))
	_ensure_comment_editor_section()
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
	_close_comment_editor()
	_rebuild_codex()
	_rebuild_timeline()
	_rebuild_memorial()
	_rebuild_atlas()
	_rebuild_bond_endings()
	_rebuild_user_created_scenarios()
	_rebuild_guild_tab()
	_rebuild_destiny_tab()
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
	bond_endings_tab.visible = tab_name == TAB_BOND_ENDINGS
	if _user_created_tab != null:
		_user_created_tab.visible = tab_name == TAB_USER_CREATED
	if _guild_tab != null:
		_guild_tab.visible = tab_name == TAB_GUILD
	if _destiny_tab != null:
		_destiny_tab.visible = tab_name == TAB_DESTINY
	codex_button.disabled = tab_name == TAB_CODEX
	timeline_button.disabled = tab_name == TAB_TIMELINE
	memorial_button.disabled = tab_name == TAB_MEMORIAL
	atlas_button.disabled = tab_name == TAB_ATLAS
	bond_endings_button.disabled = tab_name == TAB_BOND_ENDINGS
	if guild_button != null:
		guild_button.disabled = tab_name == TAB_GUILD
	if destiny_button != null:
		destiny_button.disabled = tab_name == TAB_DESTINY

func select_codex_entry(unit_key: String) -> void:
	if not _codex_keys.has(unit_key):
		return
	if _comment_editor_open and _comment_editor_unit_key != unit_key:
		_close_comment_editor()
	_selected_codex_key = unit_key
	_rebuild_codex()

func get_snapshot() -> Dictionary:
	return {
		"visible": visible,
		"active_tab": _active_tab,
		"codex_count": _codex_keys.size(),
		"selected_codex_key": _selected_codex_key,
		"codex_detail": codex_detail_label.text,
		"worldview_detail": worldview_detail_label.text,
		"selected_comment": _progression_data.get_encyclopedia_comment(StringName(_selected_codex_key)) if _progression_data != null and not _selected_codex_key.is_empty() else "",
		"comment_editor_visible": _comment_editor_container.visible if _comment_editor_container != null else false,
		"comment_counter_text": _comment_counter_label.text if _comment_counter_label != null else "",
		"comment_history_count": _progression_data.get_comment_history_for_unit(StringName(_selected_codex_key)).size() if _progression_data != null and not _selected_codex_key.is_empty() else 0,
		"support_history_text": _support_history_label.text if _support_history_label != null else "",
		"timeline_text": timeline_label.text,
		"memorial_count": min(3, _progression_data.get_honor_roll().size()) if _progression_data != null else 0,
		"atlas_text": atlas_label.text,
		"bond_endings_count": _get_unlocked_bond_ending_count(),
		"atlas_memorial_marker": _build_atlas_memorial_marker_text(),
		"atlas_stage_memorials": _build_atlas_stage_memorial_lines()
	}

func _rebuild_codex() -> void:
	_clear_children(codex_cards)
	_codex_keys.clear()
	if _progression_data == null:
		codex_detail_label.text = ""
		worldview_detail_label.text = ""
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
		worldview_detail_label.text = _build_worldview_detail_text()
		return
	if _selected_codex_key.is_empty() or not _codex_keys.has(_selected_codex_key):
		_selected_codex_key = _codex_keys[0]
	for unit_key in _codex_keys:
		var entry: Dictionary = _progression_data.encyclopedia_entries.get(unit_key, {})
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(190.0, 112.0)
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 8)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_right", 8)
		margin.add_theme_constant_override("margin_bottom", 8)
		var stack := VBoxContainer.new()
		stack.add_theme_constant_override("separation", 6)
		var button := Button.new()
		button.text = _build_codex_card_label(entry)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.custom_minimum_size = Vector2(0.0, 76.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.disabled = unit_key == _selected_codex_key
		button.tooltip_text = _build_codex_tooltip(entry)
		button.pressed.connect(func() -> void:
			_selected_codex_key = unit_key
			_rebuild_codex()
		)
		var comment_button := Button.new()
		comment_button.text = _build_comment_button_label(unit_key)
		comment_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		comment_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		comment_button.tooltip_text = _build_comment_button_tooltip(unit_key)
		comment_button.pressed.connect(func() -> void:
			_open_comment_editor(unit_key)
		)
		stack.add_child(button)
		stack.add_child(comment_button)
		margin.add_child(stack)
		card.add_child(margin)
		codex_cards.add_child(card)
	_render_codex_detail()

func _render_codex_detail() -> void:
	if _progression_data == null or _selected_codex_key.is_empty():
		codex_detail_label.text = ""
		worldview_detail_label.text = ""
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
	lines.append("")
	lines.append("[b]PLAYER NOTES[/b]")
	var comment := _progression_data.get_encyclopedia_comment(StringName(_selected_codex_key))
	if comment.is_empty():
		lines.append("[i]첫 코멘트를 남기세요 ✏️[/i]")
	else:
		lines.append("[b]%s[/b]" % _escape_bbcode(comment))
	codex_detail_label.text = "\n".join(lines)
	worldview_detail_label.text = _build_worldview_detail_text()
	_render_comment_editor()
	_render_support_history(entry)

func open_comment_editor(unit_key: String) -> void:
	_open_comment_editor(unit_key)

func set_comment_draft(comment_text: String) -> void:
	if _comment_editor_text == null:
		return
	_comment_text_syncing = true
	_comment_editor_text.text = _truncate_comment_text(comment_text)
	_comment_text_syncing = false
	_update_comment_counter()
	_update_comment_save_state()

func save_comment_draft() -> void:
	_save_comment_editor()

func _ensure_comment_editor_section() -> void:
	if codex_detail_stack == null or _comment_editor_container != null:
		return
	_comment_editor_container = VBoxContainer.new()
	_comment_editor_container.visible = false
	_comment_editor_container.add_theme_constant_override("separation", 8)
	var title := Label.new()
	title.text = "코멘트 쓰기"
	_comment_editor_container.add_child(title)
	_comment_editor_text = TextEdit.new()
	_comment_editor_text.custom_minimum_size = Vector2(0.0, 110.0)
	_comment_editor_text.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_comment_editor_text.text_changed.connect(_on_comment_text_changed)
	_comment_editor_container.add_child(_comment_editor_text)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	_comment_counter_label = Label.new()
	footer.add_child(_comment_counter_label)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(spacer)
	_comment_save_button = Button.new()
	_comment_save_button.text = "저장"
	_comment_save_button.pressed.connect(_save_comment_editor)
	footer.add_child(_comment_save_button)
	_comment_cancel_button = Button.new()
	_comment_cancel_button.text = "취소"
	_comment_cancel_button.pressed.connect(_cancel_comment_editor)
	footer.add_child(_comment_cancel_button)
	_comment_editor_container.add_child(footer)
	codex_detail_stack.add_child(_comment_editor_container)
	_update_comment_counter()
	_update_comment_save_state()

func _render_comment_editor() -> void:
	if _comment_editor_container == null or _comment_editor_text == null:
		return
	var should_show := _comment_editor_open and not _comment_editor_unit_key.is_empty() and _comment_editor_unit_key == _selected_codex_key
	_comment_editor_container.visible = should_show
	if not should_show:
		return
	if _comment_editor_text.text != _progression_data.get_encyclopedia_comment(StringName(_comment_editor_unit_key)) and _comment_editor_text.text.strip_edges().is_empty():
		_comment_text_syncing = true
		_comment_editor_text.text = _progression_data.get_encyclopedia_comment(StringName(_comment_editor_unit_key))
		_comment_text_syncing = false
	_update_comment_counter()
	_update_comment_save_state()

func _open_comment_editor(unit_key: String) -> void:
	if _progression_data == null:
		return
	var normalized_unit_key := unit_key.strip_edges()
	if normalized_unit_key.is_empty() or not _progression_data.encyclopedia_entries.has(normalized_unit_key):
		return
	_selected_codex_key = normalized_unit_key
	_comment_editor_open = true
	_comment_editor_unit_key = normalized_unit_key
	set_comment_draft(_progression_data.get_encyclopedia_comment(StringName(normalized_unit_key)))
	_rebuild_codex()
	if _comment_editor_text != null:
		_comment_editor_text.grab_focus()

func _cancel_comment_editor() -> void:
	_close_comment_editor()
	_render_codex_detail()

func _close_comment_editor(clear_draft: bool = true) -> void:
	_comment_editor_open = false
	_comment_editor_unit_key = ""
	if clear_draft and _comment_editor_text != null:
		_comment_text_syncing = true
		_comment_editor_text.text = ""
		_comment_text_syncing = false
	_update_comment_counter()
	_update_comment_save_state()
	if _comment_editor_container != null:
		_comment_editor_container.visible = false

func _save_comment_editor() -> void:
	if _progression_data == null or _comment_editor_text == null:
		return
	var unit_key := _comment_editor_unit_key.strip_edges()
	var comment_text := _comment_editor_text.text.strip_edges()
	if unit_key.is_empty() or comment_text.is_empty():
		return
	var did_save := _progression_data.set_encyclopedia_comment(
		StringName(unit_key),
		_truncate_comment_text(comment_text),
		_resolve_comment_author_name(),
		Time.get_datetime_string_from_system()
	)
	_close_comment_editor()
	if did_save:
		_rebuild_codex()
	else:
		_render_codex_detail()

func _on_comment_text_changed() -> void:
	if _comment_text_syncing or _comment_editor_text == null:
		return
	var truncated := _truncate_comment_text(_comment_editor_text.text)
	if truncated != _comment_editor_text.text:
		_comment_text_syncing = true
		_comment_editor_text.text = truncated
		_comment_text_syncing = false
	_update_comment_counter()
	_update_comment_save_state()

func _update_comment_counter() -> void:
	if _comment_counter_label == null or _comment_editor_text == null:
		return
	_comment_counter_label.text = "%d/%d" % [_comment_editor_text.text.length(), MAX_COMMENT_LENGTH]

func _update_comment_save_state() -> void:
	if _comment_save_button == null or _comment_editor_text == null:
		return
	_comment_save_button.disabled = _comment_editor_text.text.strip_edges().is_empty()

func _ensure_support_history_section() -> void:
	if codex_detail_stack == null or _support_history_toggle != null:
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
	codex_detail_stack.add_child(_support_history_toggle)
	codex_detail_stack.add_child(_support_history_label)

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

func _build_worldview_detail_text() -> String:
	if _progression_data == null:
		return ""
	var fragment_ids := _progression_data.get_worldview_fragment_ids()
	var cards := CampaignShellDialogueCatalog.get_worldview_fragment_cards(fragment_ids, _progression_data.world_timeline_id)
	var lines: Array[String] = [
		"[b]Worldview Fragments[/b] (%d/3 collected)" % fragment_ids.size()
	]
	for card in cards:
		var prefix := "• [color=lime]Collected[/color]" if bool(card.get("collected", false)) else "• [color=gray]Locked[/color]"
		lines.append("%s — %s" % [prefix, String(card.get("name", "Fragment"))])
		lines.append("  %s" % String(card.get("description", "")).strip_edges())
	if _progression_data.worldview_complete:
		lines.append("")
		lines.append("[b]Museum of Truth[/b] unlocked")
	return "\n".join(lines)

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
	var ghost_lines := _build_ghost_record_lines()
	if not ghost_lines.is_empty():
		if not lines.is_empty():
			lines.append("")
		lines.append_array(ghost_lines)
	timeline_label.text = "\n".join(lines)

func _build_ghost_record_lines() -> Array[String]:
	var lines: Array[String] = ["[b]Ghost Records[/b]"]
	var ghost_records := _load_ghost_records()
	if ghost_records.is_empty():
		lines.append("  • No ghost battle records registered yet.")
		return lines
	for ghost in ghost_records:
		var ghost_id_text := String(ghost.ghost_id).strip_edges()
		var player_tag := ghost.player_tag.strip_edges()
		var chapter_id := ghost.chapter_id.strip_edges().to_upper()
		if player_tag.is_empty():
			player_tag = "Anonymous"
		if chapter_id.is_empty():
			chapter_id = "Unknown"
		lines.append("  • ghost_id: %s" % ghost_id_text)
		lines.append("    player_tag: %s | chapter: %s | avg_turns: %.1f | difficulty_rating: %d" % [
			player_tag,
			chapter_id,
			ghost.avg_turns,
			ghost.difficulty_rating
		])
	return lines

func _load_ghost_records() -> Array[GhostFormationData]:
	var ghost_records: Array[GhostFormationData] = []
	if not FileAccess.file_exists(GHOST_REGISTRY_PATH):
		return ghost_records
	var file := FileAccess.open(GHOST_REGISTRY_PATH, FileAccess.READ)
	if file == null:
		return ghost_records
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return ghost_records
	var data := parsed as Dictionary
	var raw_ghosts: Array = data.get("ghosts", []) as Array
	if typeof(raw_ghosts) != TYPE_ARRAY:
		return ghost_records
	for raw_ghost in raw_ghosts:
		if typeof(raw_ghost) != TYPE_DICTIONARY:
			continue
		var ghost := GhostFormationData.create_from_dict(raw_ghost as Dictionary)
		if ghost == null or String(ghost.ghost_id).strip_edges().is_empty():
			continue
		ghost_records.append(ghost)
	ghost_records.sort_custom(func(a: GhostFormationData, b: GhostFormationData) -> bool:
		var chapter_a := a.chapter_id.strip_edges().to_upper()
		var chapter_b := b.chapter_id.strip_edges().to_upper()
		if chapter_a == chapter_b:
			if is_equal_approx(a.avg_turns, b.avg_turns):
				return String(a.ghost_id) < String(b.ghost_id)
			return a.avg_turns < b.avg_turns
		return chapter_a < chapter_b
	)
	return ghost_records

func _rebuild_memorial() -> void:
	_clear_children(memorial_cards)
	if _progression_data == null:
		return
	if _progression_data.get_honor_roll().is_empty():
		var empty_label := Label.new()
		empty_label.text = "No sacrifices have been etched into the memorial."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		memorial_cards.add_child(empty_label)
	else:
		var honor_roll := _progression_data.get_honor_roll()
		for index in range(min(3, honor_roll.size())):
			var record := honor_roll[index]
			var card := PanelContainer.new()
			card.custom_minimum_size = Vector2(200.0, 120.0)
			var margin := MarginContainer.new()
			margin.add_theme_constant_override("margin_left", 10)
			margin.add_theme_constant_override("margin_top", 10)
			margin.add_theme_constant_override("margin_right", 10)
			margin.add_theme_constant_override("margin_bottom", 10)
			var label := Label.new()
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.text = "%s\n%s" % [
				String(record.get("unit_name", "The Fallen")),
				String(record.get("epitaph", ""))
			]
			margin.add_child(label)
			card.add_child(margin)
			memorial_cards.add_child(card)
	var battle_scar_lines := MemorialSceneScript.build_battle_scar_lines(_progression_data)
	var museum_line := MemorialSceneScript.build_battle_scar_museum_line(_progression_data)
	if battle_scar_lines.is_empty() and museum_line.is_empty():
		return
	var battle_scar_card := PanelContainer.new()
	battle_scar_card.custom_minimum_size = Vector2(200.0, 120.0)
	var battle_scar_margin := MarginContainer.new()
	battle_scar_margin.add_theme_constant_override("margin_left", 10)
	battle_scar_margin.add_theme_constant_override("margin_top", 10)
	battle_scar_margin.add_theme_constant_override("margin_right", 10)
	battle_scar_margin.add_theme_constant_override("margin_bottom", 10)
	var battle_scar_label := Label.new()
	battle_scar_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var battle_scar_text_lines: Array[String] = ["전장의자국"]
	if not museum_line.is_empty():
		battle_scar_text_lines.append(museum_line)
	for line in battle_scar_lines:
		battle_scar_text_lines.append(line)
	battle_scar_label.text = "\n".join(battle_scar_text_lines)
	battle_scar_margin.add_child(battle_scar_label)
	battle_scar_card.add_child(battle_scar_margin)
	memorial_cards.add_child(battle_scar_card)

func _rebuild_atlas() -> void:
	if _progression_data == null:
		atlas_label.text = ""
		return
	var chapters := _get_completed_chapters()
	if chapters.is_empty() and _active_chapter_id != StringName():
		chapters.append(String(_active_chapter_id))
	var marker_text := _build_atlas_memorial_marker_text()
	var stage_memorial_lines := _build_atlas_stage_memorial_lines()
	var battle_scar_lines := MemorialSceneScript.build_battle_scar_lines(_progression_data)
	var battle_scar_museum_line := MemorialSceneScript.build_battle_scar_museum_line(_progression_data)
	if chapters.is_empty() and marker_text.is_empty():
		if stage_memorial_lines.is_empty() and battle_scar_lines.is_empty() and battle_scar_museum_line.is_empty():
			atlas_label.text = "No route has been charted yet."
			return
	var locations: Array[String] = []
	for chapter_id in chapters:
		locations.append(_get_location_name(chapter_id))
	var lines: Array[String] = []
	if not locations.is_empty():
		lines.append("[b]Visited Route[/b]")
		lines.append(" -> ".join(locations))
	if not marker_text.is_empty():
		if not lines.is_empty():
			lines.append("")
		lines.append("[b]Memorial Marker[/b]")
		lines.append(marker_text)
	if not stage_memorial_lines.is_empty():
		if not lines.is_empty():
			lines.append("")
		lines.append("[b]Terrain Remembers[/b]")
		for line in stage_memorial_lines:
			lines.append(line)
	if not battle_scar_lines.is_empty() or not battle_scar_museum_line.is_empty():
		if not lines.is_empty():
			lines.append("")
		lines.append("[b]전장의자국[/b]")
		if not battle_scar_museum_line.is_empty():
			lines.append(battle_scar_museum_line)
		for line in battle_scar_lines:
			lines.append(line)
	atlas_label.text = "\n".join(lines)

func _rebuild_bond_endings() -> void:
	_clear_children(bond_endings_list)
	var endings: Array[Dictionary] = MemorialSceneBondSection.get_registered_pairs(_progression_data)
	if endings.is_empty():
		var empty_label := Label.new()
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_label.text = "No bond endings have been registered yet."
		bond_endings_list.add_child(empty_label)
		return
	for ending in endings:
		bond_endings_list.add_child(_build_bond_ending_entry(ending))

func _build_bond_ending_entry(ending: Dictionary) -> PanelContainer:
	var unlocked := bool(ending.get("unlocked", false))
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0.0, 96.0)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 4)
	var title := Label.new()
	title.add_theme_font_size_override("font_size", 20)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.text = String(ending.get("ending_title", "???")) if unlocked else "???"
	var meta := Label.new()
	meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if unlocked:
		meta.text = "%s\nChapter %d · %s" % [
			String(ending.get("pair_names", "")),
			int(ending.get("chapter_number", 0)),
			String(ending.get("unlocked_date", "Unknown date"))
		]
	else:
		meta.text = "???"
	stack.add_child(title)
	stack.add_child(meta)
	margin.add_child(stack)
	card.add_child(margin)
	return card

func _get_unlocked_bond_ending_count() -> int:
	var count := 0
	for ending in MemorialSceneBondSection.get_registered_pairs(_progression_data):
		if bool(ending.get("unlocked", false)):
			count += 1
	return count

func _build_atlas_memorial_marker_text() -> String:
	if _progression_data == null:
		return ""
	var marker := _progression_data.get_first_memorial_marker()
	if marker.is_empty():
		return ""
	var chapter_id := String(marker.get("chapter_id", "")).strip_edges()
	if chapter_id.is_empty():
		chapter_id = _derive_chapter_from_stage(String(marker.get("stage_id", "")).strip_edges())
	var location_name := _get_location_name(chapter_id) if not chapter_id.is_empty() else String(marker.get("stage_id", "Memorial Site"))
	return "✦ %s — %s" % [location_name, String(marker.get("unit_name", "The Fallen"))]

func _build_atlas_stage_memorial_lines() -> Array[String]:
	var lines: Array[String] = []
	if _progression_data == null:
		return lines
	var memorials: Dictionary = _progression_data.get_stage_memorial_snapshot()
	var stage_ids: Array[String] = []
	for stage_id_variant in memorials.keys():
		stage_ids.append(String(stage_id_variant))
	stage_ids.sort()
	for stage_id in stage_ids:
		var memorial := memorials.get(stage_id, {}) as Dictionary
		if memorial.is_empty():
			continue
		var chapter_id := _derive_chapter_from_stage(stage_id)
		var location_name := _get_location_name(chapter_id) if not chapter_id.is_empty() else stage_id
		var marker_type := String(memorial.get("marker_type", "flower")).strip_edges().to_lower()
		var icon := "🌸"
		if marker_type == "medal":
			icon = "🏅"
		elif marker_type == "candle":
			icon = "🕯️"
		var objective := String(memorial.get("objective", "")).strip_edges()
		lines.append("%s %s (%s) — %s" % [icon, location_name, stage_id, objective])
	return lines

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

func _build_comment_button_label(unit_key: String) -> String:
	if _progression_data == null:
		return "✏️ 코멘트"
	return "✏️ 코멘트 수정" if not _progression_data.get_encyclopedia_comment(StringName(unit_key)).is_empty() else "✏️ 코멘트 쓰기"

func _build_comment_button_tooltip(unit_key: String) -> String:
	if _progression_data == null:
		return "이 유닛에 대한 코멘트를 남깁니다."
	var comment := _progression_data.get_encyclopedia_comment(StringName(unit_key))
	if comment.is_empty():
		return "이 유닛에 대한 첫 코멘트를 남깁니다."
	return "현재 코멘트: %s" % comment

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

func _truncate_comment_text(raw_text: String) -> String:
	return raw_text.left(MAX_COMMENT_LENGTH)

func _escape_bbcode(raw_text: String) -> String:
	return raw_text.replace("[", "[lb]").replace("]", "[rb]")

func _resolve_comment_author_name() -> String:
	var user_name := OS.get_environment("USER").strip_edges()
	if user_name.is_empty():
		user_name = OS.get_environment("USERNAME").strip_edges()
	if user_name.is_empty():
		return "Anonymous Archivist"
	return user_name.capitalize()

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func _on_close_pressed() -> void:
	hide_panel()
	close_requested.emit()

func _rebuild_user_created_scenarios() -> void:
	if not _progression_data:
		return
	if not _user_created_tab or not _user_created_list:
		return
	var ScenarioLoader = load("res://scripts/dev/scenario_loader.gd")
	var scenarios: Array[Dictionary] = ScenarioLoader.list_all_scenarios()
	_clear_children(_user_created_list)
	if scenarios.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No user-created scenarios yet.\nCreate one from the Campaign menu."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_user_created_list.add_child(empty_label)
		return
	for scenario_info: Dictionary in scenarios:
		var card := _make_user_scenario_card(scenario_info)
		_user_created_list.add_child(card)

func _rebuild_guild_tab() -> void:
	if not _guild_tab or not _guild_list:
		return
	_clear_children(_guild_list)
	var gs: GuildSystem = GuildSystem.new()
	get_tree().root.add_child(gs)
	var in_guild := gs.is_in_guild()
	var guild: GuildSystem.Guild = gs.get_current_guild()
	if in_guild and guild != null:
		var header := Label.new()
		header.text = "[b]%s[/b]" % guild.name
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		header.add_theme_font_size_override("font_size", 22)
		_guild_list.add_child(header)
		var meta := Label.new()
		meta.text = "★%.1f avg grade  |  %d members  |  %s" % [
			guild.get_average_grade(), guild.members.size(), guild.banner_symbol
		]
		meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_guild_list.add_child(meta)
		var desc_lbl := Label.new()
		desc_lbl.text = guild.description if not guild.description.is_empty() else "No description."
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_guild_list.add_child(desc_lbl)
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(0.0, 8.0)
		_guild_list.add_child(spacer)
		var members_title := Label.new()
		members_title.text = "[b]Members[/b]"
		_guild_list.add_child(members_title)
		for member: GuildSystem.GuildMember in guild.members:
			var card := _make_guild_member_card(member, gs)
			_guild_list.add_child(card)
		var leave_btn := Button.new()
		leave_btn.text = "Leave Guild"
		leave_btn.pressed.connect(func() -> void:
			gs.leave_guild()
			_rebuild_guild_tab()
		)
		_guild_list.add_child(leave_btn)
	else:
		var welcome := Label.new()
		welcome.text = "Guild Community"
		welcome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		welcome.add_theme_font_size_override("font_size", 20)
		_guild_list.add_child(welcome)
		var no_guild := Label.new()
		no_guild.text = "You are not in a guild yet.\nCreate one to start your community!"
		no_guild.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_guild_list.add_child(no_guild)
		var create_btn := Button.new()
		create_btn.text = "Create Guild"
		create_btn.pressed.connect(func() -> void:
			gs.create_guild("New Guild", "Commander", "A freshly formed guild.", "sword")
			_rebuild_guild_tab()
		)
		_guild_list.add_child(create_btn)
		var spacer2 := Control.new()
		spacer2.custom_minimum_size = Vector2(0.0, 16.0)
		_guild_list.add_child(spacer2)
		var ranking_title := Label.new()
		ranking_title.text = "[b]Guild Rankings[/b]"
		_guild_list.add_child(ranking_title)
		var board: Array[Dictionary] = gs.get_ranking_board(5)
		if board.is_empty():
			var no_ranks := Label.new()
			no_ranks.text = "No guilds ranked yet."
			_guild_list.add_child(no_ranks)
		else:
			for entry: Dictionary in board:
				var rank_lbl := Label.new()
				rank_lbl.text = "⚔ %s [%s] — ★%.1f (%d)" % [
					entry.get("name", "???"),
					entry.get("banner_symbol", "sword"),
					float(entry.get("average_grade", 1.0)),
					int(entry.get("member_count", 0))
				]
				_guild_list.add_child(rank_lbl)
	gs.free()

func _rebuild_destiny_tab() -> void:
	if not _destiny_tab:
		return
	_clear_children(_destiny_tab)
	var dm_path := "res://scripts/battle/destiny_manager.gd"
	var DestinyManager = load(dm_path)
	if DestinyManager == null:
		var err_lbl := Label.new()
		err_lbl.text = "Destiny system not available."
		err_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_destiny_tab.add_child(err_lbl)
		return
	var dm: Node = DestinyManager.new()
	get_tree().root.add_child(dm)
	if not dm.has_method("is_destiny_unlocked"):
		var err_lbl := Label.new()
		err_lbl.text = "Destiny system not properly loaded."
		err_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_destiny_tab.add_child(err_lbl)
		dm.free()
		return
	var is_unlocked: bool = dm.is_destiny_unlocked()
	var header := Label.new()
	header.text = "역사의 기록자" if is_unlocked else "역사의 기록자 🔒"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 24)
	_destiny_tab.add_child(header)
	if not is_unlocked:
		var lock_lbl := Label.new()
		lock_lbl.text = "Unlocked at NG+3 or after completing the Third Eye."
		lock_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		_destiny_tab.add_child(lock_lbl)
		dm.free()
		return
	var history_lbl := Label.new()
	var change_count: int = dm.get_destiny_universe_state().get("change_count", 0)
	history_lbl.text = "Past decisions changed: %d" % change_count
	_destiny_tab.add_child(history_lbl)
	var decisions: Array = dm.get_past_decisions()
	if decisions.is_empty():
		var no_changes := Label.new()
		no_changes.text = "No past decisions have been changed yet."
		no_changes.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_destiny_tab.add_child(no_changes)
	else:
		var title := Label.new()
		title.text = "[b]Decision History[/b]"
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_destiny_tab.add_child(title)
		for decision: Dictionary in decisions:
			var card := PanelContainer.new()
			card.set("theme_override_styles/panel", _get_card_style())
			var vbox := VBoxContainer.new()
			card.add_child(vbox)
			var ch_lbl := Label.new()
			ch_lbl.text = "[b]%s[/b]" % decision.get("chapter_id", "???")
			vbox.add_child(ch_lbl)
			var choice_lbl := Label.new()
			choice_lbl.text = "Choice: %s" % decision.get("choice_key", "")
			vbox.add_child(choice_lbl)
			var change_lbl := Label.new()
			change_lbl.text = "%s → %s" % [decision.get("old_value", ""), decision.get("new_value", "")]
			change_lbl.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
			vbox.add_child(change_lbl)
			_destiny_tab.add_child(card)
	dm.free()

func _make_guild_member_card(member: GuildSystem.GuildMember, gs: GuildSystem) -> Control:
	var container := PanelContainer.new()
	container.set("theme_override_styles/panel", _get_card_style())
	var vbox := VBoxContainer.new()
	container.add_child(vbox)
	var name_lbl := Label.new()
	name_lbl.text = member.display_name + (" [Leader]" if member.is_leader else "")
	name_lbl.size_flags_vertical = SIZE_SHRINK_BEGIN
	vbox.add_child(name_lbl)
	var rank_lbl := Label.new()
	rank_lbl.text = "%s  |  ★%.1f" % [gs.get_member_rank_label(member.rank), member.battle_grade]
	rank_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	rank_lbl.size_flags_vertical = SIZE_SHRINK_BEGIN
	vbox.add_child(rank_lbl)
	return container

func _make_user_scenario_card(info: Dictionary) -> Control:
	var container := PanelContainer.new()
	container.set("theme_override_styles/panel", _get_card_style())
	var vbox := VBoxContainer.new()
	container.add_child(vbox)
	var title_label := Label.new()
	title_label.text = info.get("title", "Untitled")
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.size_flags_vertical = SIZE_SHRINK_BEGIN
	vbox.add_child(title_label)
	var meta_label := Label.new()
	meta_label.text = "by %s  |  ★%d  |  %d stage(s)" % [
		info.get("author", "Unknown"),
		info.get("difficulty", 1),
		info.get("stage_count", 0)
	]
	meta_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	meta_label.size_flags_vertical = SIZE_SHRINK_BEGIN
	vbox.add_child(meta_label)
	var tags_label := Label.new()
	var tags: Array = info.get("tags", [])
	if not tags.is_empty():
		tags_label.text = "Tags: %s" % ", ".join(tags)
		tags_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.7))
		tags_label.size_flags_vertical = SIZE_SHRINK_BEGIN
		vbox.add_child(tags_label)
	return container

func _get_card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.14, 0.18)
	style.set_border_color(Color(0.2, 0.22, 0.28))
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	return style

func _get_node_or_null(path: NodePath) -> Node:
	if has_node(path):
		return get_node(path)
	return null
