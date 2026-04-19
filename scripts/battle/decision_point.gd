extends Node

signal decision_made(chapter_id: String, choice_key: String, choice_value: Variant)

var progression_service: Node = null

func bind_progression_service(service: Node) -> void:
	progression_service = service

func trigger_decision(chapter_id: String, key: String, value: Variant) -> void:
	var normalized_key := key.strip_edges()
	if normalized_key.is_empty():
		push_warning("DecisionPoint rejected an empty decision key.")
		return
	if not _is_supported_value(value):
		push_warning("DecisionPoint rejected unsupported value type for %s." % normalized_key)
		return

	var progression_data = _get_progression_data()
	if progression_data != null:
		progression_data.world_state_bits[normalized_key] = value
		var chapter_number := _extract_chapter_number(chapter_id)
		if chapter_number > 0:
			progression_data.world_state_chapters[normalized_key] = chapter_number

	decision_made.emit(chapter_id, normalized_key, value)

func _is_supported_value(value: Variant) -> bool:
	var value_type := typeof(value)
	return value_type == TYPE_BOOL or value_type == TYPE_INT or value_type == TYPE_STRING

func _get_progression_data():
	if progression_service == null:
		progression_service = _resolve_progression_service()
	if progression_service == null or not progression_service.has_method("get_data"):
		return null
	return progression_service.get_data()

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

func _extract_chapter_number(chapter_id: String) -> int:
	var normalized := chapter_id.strip_edges().to_upper()
	if not normalized.begins_with("CH"):
		return 0
	var digits := ""
	for index in range(2, normalized.length()):
		var character := normalized[index]
		if character >= "0" and character <= "9":
			digits += character
		else:
			break
	return int(digits) if not digits.is_empty() else 0
