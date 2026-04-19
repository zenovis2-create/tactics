class_name MemorialWallAshes
extends VBoxContainer

const CARD_COLUMNS := 2
const CARD_PADDING := 10
const RARITY_BORDER_COLORS := {
	"COMMON": Color("7a7f8a"),
	"RARE": Color("4f7cff"),
	"LEGENDARY": Color("d9b44a")
}

@onready var header_label: Label = $HeaderLabel
@onready var empty_label: Label = $EmptyLabel
@onready var ashes_scroll: ScrollContainer = $AshesScroll
@onready var ashes_grid: GridContainer = $AshesScroll/AshesGrid

func _ready() -> void:
	if header_label != null:
		header_label.text = "역사의 그림자"
	if ashes_grid != null:
		ashes_grid.columns = CARD_COLUMNS
	render_entries([])

func render_entries(entries: Array) -> void:
	_clear_cards()
	var count := entries.size()
	if empty_label != null:
		empty_label.visible = count == 0
	if ashes_scroll != null:
		ashes_scroll.visible = count > 0
		ashes_scroll.custom_minimum_size = Vector2(0, 360) if count > 10 else Vector2.ZERO
	for entry in entries:
		ashes_grid.add_child(_build_card(entry as Dictionary))

func get_snapshot() -> Dictionary:
	var names: Array[String] = []
	for child in ashes_grid.get_children():
		if child.has_meta("enemy_name"):
			names.append(String(child.get_meta("enemy_name")))
	return {
		"ashes_count": ashes_grid.get_child_count(),
		"visible": visible,
		"enemy_names": names
	}

func _clear_cards() -> void:
	for child in ashes_grid.get_children():
		child.queue_free()

func _build_card(entry: Dictionary) -> PanelContainer:
	var rarity := String(entry.get("rarity", "COMMON")).to_upper()
	var border_color: Color = RARITY_BORDER_COLORS.get(rarity, RARITY_BORDER_COLORS["COMMON"])
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 164)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.set_meta("enemy_name", String(entry.get("enemy_name", "Unknown")))
	var style := StyleBoxFlat.new()
	style.bg_color = Color("141922")
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border_color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	card.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", CARD_PADDING)
	margin.add_theme_constant_override("margin_top", CARD_PADDING)
	margin.add_theme_constant_override("margin_right", CARD_PADDING)
	margin.add_theme_constant_override("margin_bottom", CARD_PADDING)
	card.add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 6)
	margin.add_child(stack)

	var portrait := ColorRect.new()
	portrait.custom_minimum_size = Vector2(56, 56)
	portrait.color = border_color.darkened(0.35)
	stack.add_child(portrait)

	var name_label := Label.new()
	name_label.text = String(entry.get("enemy_name", "Unknown"))
	name_label.add_theme_font_size_override("font_size", 18)
	stack.add_child(name_label)

	var last_words_label := Label.new()
	last_words_label.text = String(entry.get("last_words", "..."))
	last_words_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	last_words_label.add_theme_font_size_override("font_size", 15)
	stack.add_child(last_words_label)

	var chapter_label := Label.new()
	chapter_label.text = "기록: %s" % String(entry.get("chapter_defeated", ""))
	chapter_label.add_theme_font_size_override("font_size", 14)
	chapter_label.modulate = Color("b8becc")
	stack.add_child(chapter_label)

	return card
