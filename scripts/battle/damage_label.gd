class_name DamageLabel
extends Node2D

## 전투 중 데미지/MISS/GUARD/CRITICAL 텍스트를 유닛 위로 부유시키는 팝업.
## 파랜드택틱스 스타일: 즉각 시각 피드백, 짧은 지속, 자동 소멸.

const FLOAT_DISTANCE := 40.0
const DURATION := 0.8
const FONT_SIZE_NORMAL := 18
const FONT_SIZE_CRIT := 24

var _type_colors: Dictionary = {
	&"damage": Color(0.95, 0.22, 0.18),
	&"drowning": Color(0.317647, 0.717647, 0.94902),
	&"heal": Color(0.27, 0.88, 0.53),
	&"miss": Color(0.62, 0.62, 0.62),
	&"guard": Color(0.93, 0.76, 0.28),
	&"critical": Color(1.0, 0.55, 0.0),
}

var _label: Label

func _ready() -> void:
	_ensure_label()


func _ensure_label() -> void:
	if _label != null:
		return
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# 외곽선 효과 (모바일 가독성)
	_label.add_theme_font_size_override("font_size", FONT_SIZE_NORMAL)
	_label.add_theme_constant_override("outline_size", 2)
	_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	add_child(_label)


func setup(amount: int, type: StringName = &"damage") -> void:
	_ensure_label()
	var text: String = _format_text(amount, type)
	var font_size: int = FONT_SIZE_CRIT if type == &"critical" else FONT_SIZE_NORMAL
	var color: Color = _type_colors.get(type, Color.WHITE)

	_label.text = text
	_label.add_theme_font_size_override("font_size", font_size)
	_label.add_theme_color_override("font_color", color)
	_label.position = Vector2(-30, -20)  # 유닛 중심 위에서 시작
	_play_animation()


func _format_text(amount: int, type: StringName) -> String:
	match type:
		&"miss":
			return "MISS"
		&"guard":
			return "GUARD"
		&"heal":
			return "+%d" % amount
		&"critical":
			return "%d!" % amount
		_:
			return str(amount)


func _play_animation() -> void:
	var target_y: float = _label.position.y - FLOAT_DISTANCE
	var tw := create_tween().set_trans(Tween.TRANS_SINE)
	tw.tween_property(_label, "position:y", target_y, DURATION * 0.7)
	tw.parallel().tween_property(_label, "modulate:a", 0.0, DURATION).set_delay(DURATION * 0.3)
	tw.tween_callback(queue_free)
