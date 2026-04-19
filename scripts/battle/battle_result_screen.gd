class_name BattleResultScreen
extends Control
## 전투 결과 전용 화면 — 파랜드택틱스 스타일의 구조화된 결과 표시.
## 승리/패배 제목 + 목표 + 보상 + 기억 조각 + Burden/Trust 변화 + 지원 공격 횟수.

signal result_confirmed
signal encyclopedia_requested

const ProgressionService = preload("res://scripts/battle/progression_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const SupportConversations = preload("res://scripts/data/support_conversations.gd")

@onready var background: ColorRect = get_node_or_null("Background") as ColorRect
@onready var panel: PanelContainer = get_node_or_null("Panel") as PanelContainer
@onready var title_label: Label = get_node_or_null("Panel/Margin/Content/TitleLabel") as Label
@onready var body_label: RichTextLabel = get_node_or_null("Panel/Margin/Content/BodyLabel") as RichTextLabel
@onready var badge_narrative_panel: PanelContainer = get_node_or_null("Panel/Margin/Content/BadgeDeathsNarrativePanel") as PanelContainer
@onready var badge_narrative_gradient: TextureRect = get_node_or_null("Panel/Margin/Content/BadgeDeathsNarrativePanel/Gradient") as TextureRect
@onready var badge_narrative_summary_label: Label = get_node_or_null("Panel/Margin/Content/BadgeDeathsNarrativePanel/Margin/Content/SummaryLabel") as Label
@onready var badge_narrative_text_label: Label = get_node_or_null("Panel/Margin/Content/BadgeDeathsNarrativePanel/Margin/Content/NarrativeLabel") as Label
@onready var badge_narrative_stone_label: Label = get_node_or_null("Panel/Margin/Content/BadgeDeathsNarrativePanel/Margin/Content/StoneLabel") as Label
@onready var footer_buttons: HBoxContainer = get_node_or_null("Panel/Margin/Content/FooterButtons") as HBoxContainer
@onready var open_encyclopedia_button: Button = get_node_or_null("Panel/Margin/Content/FooterButtons/OpenEncyclopediaButton") as Button
@onready var confirm_button: Button = get_node_or_null("Panel/Margin/Content/FooterButtons/ConfirmButton") as Button

var _last_result: Dictionary = {}

func _ready() -> void:
	visible = false
	# _ensure_labels는 setup()에서도 호출되므로 노드가 없으면 폴백 생성
	_ensure_labels()
	_ensure_badge_narrative_section()
	_ensure_footer_buttons()
	_ensure_confirm_button()
	_ensure_open_encyclopedia_button()
	_style_badge_narrative_section()
	if confirm_button != null:
		confirm_button.pressed.connect(_on_confirm)
	if open_encyclopedia_button != null:
		open_encyclopedia_button.pressed.connect(_on_open_encyclopedia)


func _ensure_labels() -> void:
	if title_label != null and body_label != null:
		return
	# _onready가 로드되지 않은 경우 수동 생성
	if title_label == null:
		title_label = Label.new()
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(title_label)
	if body_label == null:
		body_label = RichTextLabel.new()
		body_label.bbcode_enabled = true
		body_label.fit_content = true
		add_child(body_label)

func _ensure_confirm_button() -> void:
	if confirm_button != null:
		return
	_ensure_footer_buttons()
	confirm_button = Button.new()
	confirm_button.text = "Confirm"
	footer_buttons.add_child(confirm_button)

func _ensure_badge_narrative_section() -> void:
	if badge_narrative_panel != null and badge_narrative_summary_label != null and badge_narrative_text_label != null and badge_narrative_stone_label != null:
		return
	var content := get_node_or_null("Panel/Margin/Content") as VBoxContainer
	badge_narrative_panel = PanelContainer.new()
	badge_narrative_panel.name = "BadgeDeathsNarrativePanel"
	badge_narrative_panel.visible = false
	badge_narrative_panel.custom_minimum_size = Vector2(0.0, 180.0)

	badge_narrative_gradient = TextureRect.new()
	badge_narrative_gradient.name = "Gradient"
	badge_narrative_gradient.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge_narrative_gradient.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	badge_narrative_panel.add_child(badge_narrative_gradient)

	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	badge_narrative_panel.add_child(margin)

	var content_box := VBoxContainer.new()
	content_box.name = "Content"
	content_box.add_theme_constant_override("separation", 10)
	margin.add_child(content_box)

	badge_narrative_summary_label = Label.new()
	badge_narrative_summary_label.name = "SummaryLabel"
	badge_narrative_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_box.add_child(badge_narrative_summary_label)

	badge_narrative_text_label = Label.new()
	badge_narrative_text_label.name = "NarrativeLabel"
	badge_narrative_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_box.add_child(badge_narrative_text_label)

	badge_narrative_stone_label = Label.new()
	badge_narrative_stone_label.name = "StoneLabel"
	badge_narrative_stone_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_box.add_child(badge_narrative_stone_label)

	if content != null:
		content.add_child(badge_narrative_panel)
		if footer_buttons != null and footer_buttons.get_parent() == content:
			content.move_child(badge_narrative_panel, footer_buttons.get_index())
	else:
		add_child(badge_narrative_panel)

func _ensure_footer_buttons() -> void:
	if footer_buttons != null:
		return
	footer_buttons = HBoxContainer.new()
	footer_buttons.name = "FooterButtons"
	footer_buttons.alignment = BoxContainer.ALIGNMENT_END
	add_child(footer_buttons)

func _ensure_open_encyclopedia_button() -> void:
	if open_encyclopedia_button != null:
		return
	_ensure_footer_buttons()
	open_encyclopedia_button = Button.new()
	open_encyclopedia_button.name = "OpenEncyclopediaButton"
	open_encyclopedia_button.text = "Open Encyclopedia"
	footer_buttons.add_child(open_encyclopedia_button)

func _style_badge_narrative_section() -> void:
	if badge_narrative_panel != null:
		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
		panel_style.border_color = Color(0.709804, 0.580392, 0.427451, 0.9)
		panel_style.set_border_width_all(2)
		panel_style.set_corner_radius_all(14)
		panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
		panel_style.shadow_size = 6
		badge_narrative_panel.add_theme_stylebox_override("panel", panel_style)
	if badge_narrative_gradient != null:
		var gradient := Gradient.new()
		gradient.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
		gradient.colors = PackedColorArray([
			Color(0.078431, 0.047059, 0.07451, 0.96),
			Color(0.14902, 0.090196, 0.109804, 0.94),
			Color(0.043137, 0.043137, 0.058824, 0.98)
		])
		var texture := GradientTexture2D.new()
		texture.gradient = gradient
		texture.fill = GradientTexture2D.FILL_LINEAR
		texture.fill_from = Vector2(0.0, 0.0)
		texture.fill_to = Vector2(1.0, 1.0)
		badge_narrative_gradient.texture = texture
		badge_narrative_gradient.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		badge_narrative_gradient.stretch_mode = TextureRect.STRETCH_SCALE
	if badge_narrative_summary_label != null:
		badge_narrative_summary_label.add_theme_color_override("font_color", Color(0.972549, 0.905882, 0.803922, 1.0))
		badge_narrative_summary_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
		badge_narrative_summary_label.add_theme_constant_override("outline_size", 2)
		badge_narrative_summary_label.add_theme_font_size_override("font_size", 17)
	if badge_narrative_text_label != null:
		badge_narrative_text_label.add_theme_color_override("font_color", Color(0.968627, 0.933333, 0.87451, 1.0))
		badge_narrative_text_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.88))
		badge_narrative_text_label.add_theme_constant_override("outline_size", 1)
		badge_narrative_text_label.add_theme_font_size_override("font_size", 15)
	if badge_narrative_stone_label != null:
		badge_narrative_stone_label.add_theme_color_override("font_color", Color(0.823529, 0.843137, 0.839216, 1.0))
		badge_narrative_stone_label.add_theme_color_override("font_outline_color", Color(0.121569, 0.121569, 0.141176, 0.96))
		badge_narrative_stone_label.add_theme_constant_override("outline_size", 4)
		badge_narrative_stone_label.add_theme_font_size_override("font_size", 16)

func show_result(result: Dictionary) -> void:
	_last_result = result
	_record_battle_result(result)
	visible = true

	var title: String = str(result.get("title", "Battle Result"))
	var body_lines: PackedStringArray = []

	# 목표
	var objective: String = str(result.get("objective", ""))
	if not objective.is_empty():
		body_lines.append("[b]Objective:[/b] %s" % objective)

	# 보상
	var reward_entries: Array = result.get("reward_entries", [])
	if not reward_entries.is_empty():
		body_lines.append("[b]Rewards:[/b]")
		for entry in reward_entries:
			body_lines.append("  • %s" % str(entry))

	var unit_exp_results: Array = result.get("unit_exp_results", [])
	if not unit_exp_results.is_empty():
		body_lines.append("[b]Unit EXP:[/b]")
		for entry in unit_exp_results:
			body_lines.append("  • %s Lv %d -> %d (+%d EXP)%s" % [
				str(entry.get("display_name", entry.get("unit_id", "Unit"))),
				int(entry.get("level_before", 1)),
				int(entry.get("level_after", 1)),
				int(entry.get("exp_gain", 0)),
				" LEVEL UP!" if bool(entry.get("leveled_up", false)) else ""
			])

	# 기억 조각
	var fragment_id: String = str(result.get("fragment_id", ""))
	if not fragment_id.is_empty():
		body_lines.append("[b]Memory Fragment:[/b] %s" % fragment_id)

	var recovered_fragments: Array = result.get("recovered_fragment_ids", [])
	if not recovered_fragments.is_empty():
		body_lines.append("[b]기억 복원:[/b] %s" % ", ".join(recovered_fragments))

	# 커맨드 해금
	var command_unlocked: String = str(result.get("command_unlocked", ""))
	if not command_unlocked.is_empty():
		body_lines.append("[b]해금:[/b] %s" % command_unlocked)

	# 기록 (기억/물증/편지) — 캠프로 전달
	var memory_entries: Array = result.get("memory_entries", [])
	var evidence_entries: Array = result.get("evidence_entries", [])
	var letter_entries: Array = result.get("letter_entries", [])
	if not memory_entries.is_empty():
		body_lines.append("[b]Memory:[/b] %d entries" % memory_entries.size())
	if not evidence_entries.is_empty():
		body_lines.append("[b]Evidence:[/b] %d entries" % evidence_entries.size())
	if not letter_entries.is_empty():
		body_lines.append("[b]Letters:[/b] %d entries" % letter_entries.size())

	# Burden/Trust 변화
	var burden_delta: int = int(result.get("burden_delta", 0))
	var trust_delta: int = int(result.get("trust_delta", 0))
	if burden_delta != 0 or trust_delta != 0:
		body_lines.append("[b]Burden:[/b] %+d  [b]Trust:[/b] %+d" % [burden_delta, trust_delta])

	# 지원 공격
	var support_count: int = int(result.get("support_attack_count", 0))
	if support_count > 0:
		body_lines.append("[b]Support Attacks:[/b] %d" % support_count)
		var support_bond: int = int(result.get("supporter_bond_level", 0))
		if support_bond > 0:
			body_lines.append("[b]Support Bond:[/b] %d" % support_bond)

	var closest_bond: Dictionary = result.get("closest_bond", {})
	if not closest_bond.is_empty():
		body_lines.append("Your closest bond was %s — %s support, %d battles together" % [
			_resolve_closest_bond_ally_name(String(closest_bond.get("pair", ""))),
			SupportConversations.get_rank_label(int(closest_bond.get("rank", 0))),
			int(closest_bond.get("battles_together", 0))
		])

	var world_timeline_id := String(result.get("world_timeline_id", "A")).strip_edges()
	if world_timeline_id.is_empty():
		world_timeline_id = "A"
	body_lines.append("[b]World Timeline:[/b] %s" % world_timeline_id)
	var world_timeline_text := String(result.get("world_timeline_text", "")).strip_edges()
	if not world_timeline_text.is_empty():
		body_lines.append(world_timeline_text)

	var moral_ending_lines := _build_moral_ending_lines(result)
	for line in moral_ending_lines:
		body_lines.append(line)

	if title_label != null:
		title_label.text = title
	if body_label != null:
		body_label.text = "\n".join(body_lines)

	var progression: ProgressionData = result.get("progression_data", null) as ProgressionData
	_apply_badge_narrative(progression, result)

	# 버튼 포커스
	if confirm_button != null:
		confirm_button.grab_focus()
	if open_encyclopedia_button != null:
		open_encyclopedia_button.disabled = false

func hide_result() -> void:
	visible = false
	if badge_narrative_panel != null:
		badge_narrative_panel.visible = false

func get_result_snapshot() -> Dictionary:
	return {
		"visible": visible,
		"title": title_label.text if title_label != null else "",
		"body_lines_count": body_label.text.count("\n") + 1 if body_label != null else 0,
		"badge_narrative_visible": badge_narrative_panel.visible if badge_narrative_panel != null else false,
		"badge_narrative_summary": badge_narrative_summary_label.text if badge_narrative_summary_label != null else "",
		"badge_narrative_text": badge_narrative_text_label.text if badge_narrative_text_label != null else "",
		"badge_narrative_stone": badge_narrative_stone_label.text if badge_narrative_stone_label != null else "",
		"has_confirm_button": confirm_button != null,
		"has_open_encyclopedia_button": open_encyclopedia_button != null
	}

func _apply_badge_narrative(progression: ProgressionData, result: Dictionary) -> void:
	if badge_narrative_panel == null or badge_narrative_summary_label == null or badge_narrative_text_label == null or badge_narrative_stone_label == null:
		return
	var payload := build_badge_narrative_payload(progression)
	var narrative := String(payload.get("narrative", ""))
	result["badge_narrative"] = narrative
	var total_badges := int(payload.get("total_badges", 0))
	if total_badges <= 0:
		badge_narrative_panel.visible = false
		badge_narrative_summary_label.text = ""
		badge_narrative_text_label.text = ""
		badge_narrative_stone_label.text = ""
		return
	badge_narrative_panel.visible = true
	badge_narrative_summary_label.text = "\n".join([
		String(payload.get("badge_line", "")),
		String(payload.get("rebirth_line", "")),
		String(payload.get("battle_record_line", "")),
		String(payload.get("sacrifice_line", ""))
	]).strip_edges()
	badge_narrative_text_label.text = narrative
	badge_narrative_stone_label.text = String(payload.get("stone_text", ""))

func _build_moral_ending_lines(result: Dictionary) -> PackedStringArray:
	var lines := PackedStringArray()
	var stage_id := String(result.get("stage_id", "")).strip_edges().to_upper()
	if not result.has("finale_result") and not stage_id.begins_with("CH10"):
		return lines
	var moral_consequence = get_node_or_null("/root/MoralConsequence")
	if moral_consequence == null or not moral_consequence.has_method("apply_consequences_to_ending"):
		return lines
	var ending_payload: Dictionary = moral_consequence.apply_consequences_to_ending()
	if ending_payload.is_empty():
		return lines
	result["moral_ending"] = ending_payload
	var ending_variant := String(ending_payload.get("ending_variant", "")).strip_edges()
	if not ending_variant.is_empty():
		lines.append("[b]Ending Variant:[/b] %s" % ending_variant)
	var ending_text := String(ending_payload.get("ending_text", "")).strip_edges()
	if not ending_text.is_empty():
		lines.append(ending_text)
	var world_state_description := String(ending_payload.get("world_state_description", "")).strip_edges()
	if not world_state_description.is_empty():
		lines.append(world_state_description)
	return lines

static func build_badge_narrative_payload(progression: ProgressionData) -> Dictionary:
	var payload := {
		"total_badges": 0,
		"badge_line": "",
		"rebirth_line": "",
		"battle_record_line": "",
		"sacrifice_line": "",
		"narrative": "",
		"stone_text": ""
	}
	if progression == null:
		return payload
	var total_badges := int(progression.badges_of_heroism)
	payload["total_badges"] = total_badges
	if total_badges <= 0:
		return payload
	var sacrifice_records: Array[Dictionary] = progression.get_sacrifice_records()
	var first_record: Dictionary = sacrifice_records[0] if not sacrifice_records.is_empty() else {}
	var first_name := String(first_record.get("name", "이름 없는 동료")).strip_edges()
	var first_epitaph := String(first_record.get("epitaph", "")).strip_edges()
	payload["badge_line"] = "Badges of Heroism: %d" % total_badges
	payload["rebirth_line"] = "%d badges = %d전 %d생 = 1 true death" % [total_badges, total_badges, total_badges]
	payload["battle_record_line"] = "%d전 — 전사 없이 돌아왔다" % total_badges
	var narrative := "당신은 %d전투를 치렀다.\n" % total_badges
	narrative += "매 전투마다, 당신은 한 걸음씩 다가왔다.\n"
	if not sacrifice_records.is_empty():
		narrative += "하지만 진정으로 fight한 것은 오직 한 번.\n"
		narrative += "%s — %s" % [
			first_name,
			first_epitaph if not first_epitaph.is_empty() else "끝내 남기지 못한 마지막 말"
		]
		payload["sacrifice_line"] = "단 한 번, 영원히 남은 죽음: %s" % first_name
		var memorial_lines: Array[String] = []
		for record in sacrifice_records:
			var record_name := String(record.get("name", "이름 없는 동료")).strip_edges()
			var record_epitaph := String(record.get("epitaph", "")).strip_edges()
			memorial_lines.append(record_name)
			if not record_epitaph.is_empty():
				memorial_lines.append("\"%s\"" % record_epitaph)
			memorial_lines.append("이 이름은 石에 새겨졌다")
		payload["stone_text"] = "\n\n".join(memorial_lines)
	else:
		narrative += "살아남은 것은 당신의 의지가 아니다.\n"
		narrative += "살아남은 것은 주변 사람들의 믿음이었다."
		payload["sacrifice_line"] = "당신은 모든 전투에서 살아남았다. 하지만 정말로 fight한 사람만이 여기 도달할 수 있었다"
		payload["stone_text"] = payload["sacrifice_line"]
	payload["narrative"] = narrative
	return payload

func _record_battle_result(result: Dictionary) -> void:
	var progression: ProgressionData = result.get("progression_data", null) as ProgressionData
	if progression == null:
		return
	var objectives: Array[String] = []
	var raw_objectives: Variant = result.get("objectives_completed", [])
	if typeof(raw_objectives) == TYPE_ARRAY:
		for entry in raw_objectives:
			objectives.append(String(entry))
	var notes := String(result.get("notes", "Battle cleared.")).strip_edges()
	_record_support_conversations(result, progression)
	progression.add_battle_record({
		"stage_id": String(result.get("stage_id", "")),
		"turns": int(result.get("turn_count", 0)),
		"star_rating": int(result.get("star_rating", 0)),
		"objectives_completed": objectives,
		"notes": notes
	})

func _record_support_conversations(result: Dictionary, progression: ProgressionData) -> void:
	if progression == null:
		return
	var raw_entries: Variant = result.get("support_conversations_fired", [])
	if typeof(raw_entries) != TYPE_ARRAY:
		return
	for entry_variant in raw_entries:
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry := entry_variant as Dictionary
		progression.record_support_history({
			"pair": String(entry.get("pair", "")).strip_edges(),
			"rank": int(entry.get("rank", 0)),
			"chapter": String(entry.get("chapter", result.get("chapter", ""))).strip_edges(),
			"stage_id": String(entry.get("stage_id", result.get("stage_id", ""))).strip_edges(),
			"timestamp": int(entry.get("timestamp", Time.get_unix_time_from_system()))
		})

func _resolve_closest_bond_ally_name(pair_id: String) -> String:
	var normalized_pair := SupportConversations.normalize_pair_id(pair_id)
	for unit_id in normalized_pair.split(":", false):
		if unit_id != "ally_rian":
			return SupportConversations.get_unit_display_name(unit_id)
	return "Ally"

func _on_confirm() -> void:
	result_confirmed.emit()
	hide_result()

func _on_open_encyclopedia() -> void:
	encyclopedia_requested.emit()
