class_name MoralConsequenceService
extends Node

const EthicsTracker = preload("res://scripts/battle/ethics_tracker.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

class BossModifier:
	var boss_damage_multiplier: float = 1.0
	var boss_health_multiplier: float = 1.0
	var boss_resolve_dialogue: String = ""
	var boss_attitude: String = "neutral"

var _decision_point: Node = null

func _ready() -> void:
	call_deferred("_connect_decision_point")

func bind_progression_service(service: Node) -> void:
	var ethics := _get_ethics()
	if ethics != null:
		ethics.bind_progression_service(service)

func bind_progression(progression_data: ProgressionData) -> void:
	var ethics := _get_ethics()
	if ethics != null:
		ethics.bind_progression(progression_data)

func connect_decision_point(decision_point: Node) -> void:
	if decision_point == null or not decision_point.has_signal("decision_made"):
		return
	var callback := Callable(self, "_on_decision_made")
	if decision_point.is_connected("decision_made", callback):
		return
	decision_point.connect("decision_made", callback)
	_decision_point = decision_point

func apply_consequences_to_boss(boss_id: String) -> BossModifier:
	var modifier := BossModifier.new()
	var bracket := _get_ethics_bracket()
	match bracket:
		"ruthless":
			modifier.boss_damage_multiplier = 1.15
			modifier.boss_health_multiplier = 1.10
			modifier.boss_attitude = "hostile"
		"compassionate":
			modifier.boss_attitude = "judgmental"
			modifier.boss_resolve_dialogue = "당신의 자비가 약점을 만들었다"
		_:
			modifier.boss_attitude = "neutral"

	var boss_dialogue := get_boss_dialogue_variant(boss_id)
	if not boss_dialogue.is_empty():
		modifier.boss_resolve_dialogue = boss_dialogue
	return modifier

func apply_consequences_to_ending() -> Dictionary:
	var bracket := _get_ethics_bracket()
	var descriptor := _get_ethics_descriptor()
	match bracket:
		"ruthless":
			return {
				"ending_variant": "Conqueror's Ending",
				"ending_text": "왕국은 당신의 공포를 기억하며 무릎 꿇었다. %s" % descriptor,
				"world_state_description": "불타는 관문과 침묵한 마을이 당신의 선택을 증언한다.",
			}
		"compassionate":
			return {
				"ending_variant": "Guardian's Ending",
				"ending_text": "사람들은 당신이 남긴 자비를 따라 다시 성벽을 세운다. %s" % descriptor,
				"world_state_description": "상처 입은 세계는 여전히 불안하지만, 살아남은 이들은 서로를 지키기 시작했다.",
			}
		_:
			return {
				"ending_variant": "Survivor's Ending",
				"ending_text": "누구도 완전히 옳지 않았지만, 당신은 끝내 살아남을 길을 골랐다. %s" % descriptor,
				"world_state_description": "폐허 위의 질서는 차갑지만 단단하게 유지되고 있다.",
			}

func get_boss_dialogue_variant(boss_id: String) -> String:
	var normalized_boss_id := boss_id.strip_edges().to_lower()
	var bracket := _get_ethics_bracket()
	if normalized_boss_id == "leonika":
		match bracket:
			"ruthless":
				return "당신은 나보다 더한 학살자였다"
			"compassionate":
				return "당신의 손에 희망이 있었다"
			_:
				return "우리는 서로를 이해할 수 없다"
	match bracket:
		"ruthless":
			return "전장은 당신의 잔혹함을 이미 기억하고 있다"
		"compassionate":
			return "자비는 칼끝 앞에서 가장 먼저 흔들린다"
		_:
			return "생존만으로는 누구도 구원할 수 없다"

func resolve_boss_id(unit_data: UnitData) -> String:
	if unit_data == null:
		return ""
	var unit_id := String(unit_data.unit_id).strip_edges().to_lower()
	match unit_id:
		"enemy_basil", "enemy_saria":
			return "leonika"
		"enemy_lete":
			return "shadow_knight"
		"enemy_varten":
			return "dark_mage"
		_:
			return ""

func _connect_decision_point() -> void:
	var decision_point = get_node_or_null("/root/DecisionPoint")
	if decision_point == null:
		return
	connect_decision_point(decision_point)

func _on_decision_made(chapter_id: String, choice_key: String, _choice_value: Variant) -> void:
	var ethics := _get_ethics()
	if ethics == null:
		return
	var weight := ethics.get_decision_weight(choice_key)
	if is_zero_approx(weight):
		return
	ethics.record_decision(chapter_id, choice_key, weight)

func _get_ethics() -> EthicsTracker:
	return get_node_or_null("/root/Ethics") as EthicsTracker

func _get_ethics_bracket() -> String:
	var ethics := _get_ethics()
	if ethics == null:
		return "pragmatic"
	return ethics.get_ethics_bracket()

func _get_ethics_descriptor() -> String:
	var ethics := _get_ethics()
	if ethics == null:
		return "당신의 선택은 아직 뚜렷한 윤리적 색을 남기지 않았다."
	return ethics.get_ethics_descriptor()
