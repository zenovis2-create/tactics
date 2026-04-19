class_name EmotionalLayerController
extends Node

const DRUMS_TURN_EIGHT_LEVEL := 0.35
const DRUMS_TURN_STEP := 0.1


func _on_spotlight_triggered(spotlight_type: Variant, _unit_ids: Array = []) -> void:
	var music := _get_music()
	if music == null:
		return
	var normalized := String(spotlight_type).strip_edges().to_lower()
	if normalized.is_empty():
		return
	music.trigger_spotlight_music(normalized)


func _on_bond_death_started() -> void:
	var music := _get_music()
	if music == null:
		return
	music.trigger_spotlight_music("bond_death")


func _on_bond_death_triggered(_pair_id: String = "", _ending_id: String = "") -> void:
	_on_bond_death_started()


func _on_battle_turn_started(turn_num: int) -> void:
	if turn_num < 8:
		return
	var music := _get_music()
	if music == null or not music.has_method("set_layer_level"):
		return
	var drums_level: float = min(1.0, DRUMS_TURN_EIGHT_LEVEL + float(turn_num - 8) * DRUMS_TURN_STEP)
	music.set_layer_level("DRUMS_PERCUSSION", drums_level, 1.25)


func _get_music() -> Node:
	return get_node_or_null("/root/Music")
