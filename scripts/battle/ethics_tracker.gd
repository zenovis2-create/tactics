class_name EthicsTracker
extends Node

const ProgressionData = preload("res://scripts/data/progression_data.gd")

const MIN_ETHICS_SCORE := -100.0
const MAX_ETHICS_SCORE := 100.0
const RUTHLESS_THRESHOLD := -30.0
const COMPASSIONATE_THRESHOLD := 30.0
const DECISION_WEIGHTS := {
	"spared_enemy": 5.0,
	"burned_bridge": -10.0,
	"saved_supply_train": 8.0,
	"ignored_warning": -5.0,
	"recruited_hidden_unit": 10.0,
	"left_unit_to_die": -15.0,
}

var ethics_score: float = 0.0
var decision_log: Array[Dictionary] = []

var _progression_service: Node = null
var _progression_data: ProgressionData = null

func _ready() -> void:
	_hydrate_from_progression()

func bind_progression_service(service: Node) -> void:
	_progression_service = service
	_hydrate_from_progression()

func bind_progression(progression_data: ProgressionData) -> void:
	_progression_service = null
	_progression_data = progression_data
	_hydrate_from_progression()

func reset_tracking() -> void:
	ethics_score = 0.0
	decision_log.clear()
	_sync_progression()

func get_decision_weight(key: String) -> float:
	return float(DECISION_WEIGHTS.get(key.strip_edges(), 0.0))

func record_decision(chapter_id: String, key: String, weight: float) -> void:
	var normalized_key := key.strip_edges()
	if normalized_key.is_empty():
		return

	_hydrate_from_progression()

	var resolved_weight := weight
	if is_zero_approx(resolved_weight):
		resolved_weight = get_decision_weight(normalized_key)

	decision_log.append({
		"chapter_id": chapter_id.strip_edges().to_upper(),
		"decision_key": normalized_key,
		"weight": resolved_weight,
	})
	ethics_score = clampf(ethics_score + resolved_weight, MIN_ETHICS_SCORE, MAX_ETHICS_SCORE)
	_sync_progression()

func get_ethics_bracket() -> String:
	_hydrate_from_progression()
	if ethics_score <= RUTHLESS_THRESHOLD:
		return "ruthless"
	if ethics_score > COMPASSIONATE_THRESHOLD:
		return "compassionate"
	return "pragmatic"

func get_ethics_descriptor() -> String:
	_hydrate_from_progression()
	var merciful_actions := _count_decision("spared_enemy") + _count_decision("saved_supply_train") + _count_decision("recruited_hidden_unit")
	var cruel_actions := _count_decision("burned_bridge") + _count_decision("ignored_warning") + _count_decision("left_unit_to_die")
	match get_ethics_bracket():
		"ruthless":
			if _count_decision("left_unit_to_die") > 0 or _count_decision("burned_bridge") >= 2:
				return "당신은 승리를 위해 다리를 태우고 동료마저 버릴 수 있는 냉혹한 지휘관이다."
			return "당신은 자비보다 결과를 우선하며 전장을 굴복시킨 정복자의 흔적을 남겼다."
		"compassionate":
			if merciful_actions >= 3:
				return "당신은 위험을 감수하고서라도 사람을 살려 두는 수호자의 길을 걸었다."
			return "당신은 상처를 짊어지고도 타인을 지키려는 자비로운 지휘관이다."
		_:
			if merciful_actions > 0 and cruel_actions > 0:
				return "당신은 필요할 때 손을 더럽히지만 끝내 선을 넘지 않으려는 실용적 지휘관이다."
			return "당신은 살아남기 위해 계산하면서도 완전히 무너지지 않은 생존형 지휘관이다."

func _count_decision(decision_key: String) -> int:
	var count := 0
	for entry in decision_log:
		if String(entry.get("decision_key", "")).strip_edges() == decision_key:
			count += 1
	return count

func _hydrate_from_progression() -> void:
	var progression := _resolve_progression_data()
	if progression == null:
		return
	_progression_data = progression
	ethics_score = clampf(float(progression.ethics_score), MIN_ETHICS_SCORE, MAX_ETHICS_SCORE)
	decision_log = _duplicate_log(progression.ethics_decision_log)

func _sync_progression() -> void:
	var progression := _resolve_progression_data()
	if progression == null:
		return
	progression.ethics_score = ethics_score
	progression.ethics_decision_log = _duplicate_log(decision_log)

func _resolve_progression_data() -> ProgressionData:
	if _progression_service != null and _progression_service.has_method("get_data"):
		var service_data = _progression_service.get_data()
		if service_data is ProgressionData:
			return service_data as ProgressionData
	if _progression_data != null:
		return _progression_data
	var progression_service := _resolve_progression_service()
	if progression_service != null and progression_service.has_method("get_data"):
		var resolved = progression_service.get_data()
		if resolved is ProgressionData:
			_progression_service = progression_service
			return resolved as ProgressionData
	return null

func _resolve_progression_service() -> Node:
	var battle_controller = get_node_or_null("/root/Main/BattleScene")
	if battle_controller != null:
		var service = battle_controller.get("progression_service")
		if service != null:
			return service
	for child in get_tree().root.get_children():
		var nested_battle = child.find_child("BattleScene", true, false)
		if nested_battle == null:
			continue
		var service = nested_battle.get("progression_service")
		if service != null:
			return service
	return null

func _duplicate_log(source: Array) -> Array[Dictionary]:
	var copy: Array[Dictionary] = []
	for entry in source:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		copy.append((entry as Dictionary).duplicate(true))
	return copy
