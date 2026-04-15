class_name BattleResultScreen
extends Control
## 전투 결과 전용 화면 — 파랜드택틱스 스타일의 구조화된 결과 표시.
## 승리/패배 제목 + 목표 + 보상 + 기억 조각 + Burden/Trust 변화 + 지원 공격 횟수.

signal result_confirmed

const ProgressionService = preload("res://scripts/battle/progression_service.gd")

@onready var background: ColorRect = $Background
@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $Panel/Margin/Content/TitleLabel
@onready var body_label: RichTextLabel = $Panel/Margin/Content/BodyLabel
@onready var confirm_button: Button = $Panel/Margin/Content/ConfirmButton

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

	# 기억 조각
	var fragment_id: String = str(result.get("fragment_id", ""))
	if not fragment_id.is_empty():
		body_lines.append("[b]Memory Fragment:[/b] %s" % fragment_id)

	var recovered_fragments: Array = result.get("recovered_fragment_ids", [])
	if not recovered_fragments.is_empty():
		body_lines.append("[b]Recovered Fragments:[/b] %s" % ", ".join(recovered_fragments))

	# 커맨드 해금
	var command_unlocked: String = str(result.get("command_unlocked", ""))
	if not command_unlocked.is_empty():
		body_lines.append("[b]Command Unlocked:[/b] %s" % command_unlocked)

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

	if title_label != null:
		title_label.text = title
	if body_label != null:
		body_label.text = "\n".join(body_lines)

	# 버튼 포커스
	if confirm_button != null:
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