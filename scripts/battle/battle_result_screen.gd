class_name BattleResultScreen
extends Control
## 전투 결과 전용 화면 — 파랜드택틱스 스타일의 구조화된 결과 표시.
## 승리/패배 제목 + 목표 + 보상 + 기억 조각 + Burden/Trust 변화 + 지원 공격 횟수.

signal result_confirmed

@onready var background: ColorRect = get_node_or_null("Background") as ColorRect
@onready var panel: PanelContainer = get_node_or_null("Panel") as PanelContainer
@onready var title_label: Label = get_node_or_null("Panel/Margin/Content/TitleLabel") as Label
@onready var body_label: RichTextLabel = get_node_or_null("Panel/Margin/Content/BodyLabel") as RichTextLabel
@onready var confirm_button: Button = get_node_or_null("Panel/Margin/Content/ConfirmButton") as Button

var _last_result: Dictionary = {}

func _ready() -> void:
	visible = false
	# _ensure_labels는 setup()에서도 호출되므로 노드가 없으면 폴백 생성
	_ensure_labels()
	_ensure_confirm_button()
	if confirm_button != null:
		confirm_button.pressed.connect(_on_confirm)


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
	confirm_button = Button.new()
	confirm_button.text = "Confirm"
	add_child(confirm_button)

func show_result(result: Dictionary) -> void:
	_last_result = result
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
			var level_up_emphasis := " [color=#ffd36b][b]★ LEVEL UP! ★[/b][/color]" if bool(entry.get("leveled_up", false)) else ""
			body_lines.append("  • %s Lv %d -> %d (+%d EXP)%s" % [
				str(entry.get("display_name", entry.get("unit_id", "Unit"))),
				int(entry.get("level_before", 1)),
				int(entry.get("level_after", 1)),
				int(entry.get("exp_gain", 0)),
				level_up_emphasis
			])

	var bonus_exp_pool: int = int(result.get("bonus_exp_pool", 0))
	var bonus_exp_results: Array = result.get("bonus_exp_results", [])
	if bonus_exp_pool > 0 and not bonus_exp_results.is_empty():
		body_lines.append("[b]Bonus EXP:[/b] %d" % bonus_exp_pool)
		for entry in bonus_exp_results:
			body_lines.append("  • %s +%d bonus EXP" % [
				str(entry.get("display_name", entry.get("unit_id", "Unit"))),
				int(entry.get("exp_gain", 0))
			])

	var result_tags: Array = result.get("result_tags", [])
	if not result_tags.is_empty():
		body_lines.append("[b]Result Tags:[/b]")
		for tag in result_tags:
			body_lines.append("  • %s" % str(tag))

	var bonus_recommendation_line: String = str(result.get("bonus_recommendation_line", "")).strip_edges()
	if not bonus_recommendation_line.is_empty():
		body_lines.append(bonus_recommendation_line)

	# 기억 조각
	var memory_recovery_entries: Array = result.get("memory_recovery_entries", [])
	if not memory_recovery_entries.is_empty():
		body_lines.append("[b]Memory Recovery:[/b]")
		for entry in memory_recovery_entries:
			body_lines.append("  • %s" % str(entry))

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

	var support_conversations: Array = result.get("support_conversations", [])
	if not support_conversations.is_empty():
		body_lines.append("[b]Support Rank Up![/b]")
		for entry in support_conversations:
			if typeof(entry) != TYPE_DICTIONARY:
				continue
			var pair_label: String = str(entry.get("pair_label", "Support"))
			var rank_label: String = str(entry.get("rank_label", ""))
			var conversation_text: String = str(entry.get("text", "")).strip_edges()
			var header := "  • %s" % pair_label
			if not rank_label.is_empty():
				header += " (%s)" % rank_label
			body_lines.append(header)
			if not conversation_text.is_empty():
				body_lines.append("    %s" % conversation_text)

	var name_call_line: String = str(result.get("name_call_line", "")).strip_edges()
	if not name_call_line.is_empty():
		body_lines.append("[b]Name Call:[/b] %s" % name_call_line)

	var telemetry_summary: Array = result.get("telemetry_summary", [])
	if not telemetry_summary.is_empty():
		body_lines.append("[b]Telemetry:[/b]")
		for entry in telemetry_summary:
			body_lines.append("  • %s" % str(entry))

	if title_label != null:
		title_label.text = title
	if body_label != null:
		body_label.text = "\n".join(body_lines)

	# 버튼 포커스
	if confirm_button != null and confirm_button.is_inside_tree():
		confirm_button.grab_focus()

func hide_result() -> void:
	visible = false

func get_result_snapshot() -> Dictionary:
	return {
		"visible": visible,
		"title": title_label.text if title_label != null else "",
		"body_lines_count": body_label.text.count("\n") + 1 if body_label != null else 0,
		"has_confirm_button": confirm_button != null
	}

func _on_confirm() -> void:
	result_confirmed.emit()
	hide_result()
