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
@onready var footer_buttons: HBoxContainer = get_node_or_null("Panel/Margin/Content/FooterButtons") as HBoxContainer
@onready var open_encyclopedia_button: Button = get_node_or_null("Panel/Margin/Content/FooterButtons/OpenEncyclopediaButton") as Button
@onready var confirm_button: Button = get_node_or_null("Panel/Margin/Content/FooterButtons/ConfirmButton") as Button

var _last_result: Dictionary = {}

func _ready() -> void:
	visible = false
	# _ensure_labels는 setup()에서도 호출되므로 노드가 없으면 폴백 생성
	_ensure_labels()
	_ensure_footer_buttons()
	_ensure_confirm_button()
	_ensure_open_encyclopedia_button()
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

	if title_label != null:
		title_label.text = title
	if body_label != null:
		body_label.text = "\n".join(body_lines)

	# 버튼 포커스
	if confirm_button != null:
		confirm_button.grab_focus()
	if open_encyclopedia_button != null:
		open_encyclopedia_button.disabled = false

func hide_result() -> void:
	visible = false

func get_result_snapshot() -> Dictionary:
	return {
		"visible": visible,
		"title": title_label.text if title_label != null else "",
		"body_lines_count": body_label.text.count("\n") + 1 if body_label != null else 0,
		"has_confirm_button": confirm_button != null,
		"has_open_encyclopedia_button": open_encyclopedia_button != null
	}

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
