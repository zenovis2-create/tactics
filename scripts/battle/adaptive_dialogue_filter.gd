extends Node

const LEONIKA_DIALOGUE_KEYS := {
	"ruthless": "_CH10_LEONIKA_RUTHLESS",
	"pragmatic": "_CH10_LEONIKA_PRAGMATIC",
	"compassionate": "_CH10_LEONIKA_COMPASSIONATE",
}

func get_adapted_dialogue_key(npc_id: String, base_key: String, chronicle_context: Dictionary = {}) -> String:
	var normalized_key := base_key.strip_edges()
	if normalized_key.is_empty():
		return ""
	var normalized_npc_id := npc_id.strip_edges().to_lower()
	if normalized_npc_id == "leonika" and normalized_key.to_lower() == "ch10_final":
		return String(LEONIKA_DIALOGUE_KEYS.get(resolve_dialogue_track(npc_id, chronicle_context), LEONIKA_DIALOGUE_KEYS["pragmatic"]))
	var personality = get_node_or_null("/root/NPCPersonality")
	if personality != null and personality.has_method("get_npc_dialogue_variant"):
		return String(personality.get_npc_dialogue_variant(npc_id, normalized_key)).strip_edges()
	return "%s_NEUTRAL" % normalized_key

func resolve_dialogue_track(npc_id: String, chronicle_context: Dictionary = {}) -> String:
	var track := _get_ethics_bracket()
	var normalized_npc_id := npc_id.strip_edges().to_lower()
	if normalized_npc_id != "leonika":
		return track
	match _get_chronicle_pattern(chronicle_context):
		"aggressive":
			if track == "pragmatic":
				return "ruthless"
		"defensive":
			if track == "ruthless":
				return "pragmatic"
		"merciful":
			if track != "ruthless":
				return "compassionate"
	return track

func filter_dialogue_tree(dialogue_tree: Dictionary, npc_id: String, chronicle_context: Dictionary = {}) -> Array[String]:
	var track := resolve_dialogue_track(npc_id, chronicle_context)
	return _variant_to_string_array(dialogue_tree.get(track, dialogue_tree.get(_get_ethics_bracket(), dialogue_tree.get("pragmatic", []))))

func get_expression_mood(npc_id: String, chronicle_context: Dictionary = {}) -> String:
	var normalized_npc_id := npc_id.strip_edges().to_lower()
	if normalized_npc_id == "leonika":
		var pattern := _get_chronicle_pattern(chronicle_context)
		if pattern == "aggressive" or pattern == "defensive" or pattern == "merciful":
			return pattern
	return resolve_dialogue_track(npc_id, chronicle_context)

func inject_chronicle_reference(npc_id: String, chronicle_entry) -> String:
	var style_name := _extract_style_name(chronicle_entry)
	if style_name != "POETIC" and style_name != "BATTLE":
		return ""
	var personality = get_node_or_null("/root/NPCPersonality")
	var npc_name := "NPC"
	if personality != null and personality.has_method("get_display_name"):
		npc_name = String(personality.get_display_name(npc_id)).strip_edges()
	var chronicle_title := _extract_chronicle_field(chronicle_entry, "chapter_title")
	if chronicle_title.is_empty():
		chronicle_title = _extract_chronicle_field(chronicle_entry, "chapter_id")
	var narrative := _extract_chronicle_field(chronicle_entry, "narrative_text")
	if narrative.is_empty() and chronicle_entry != null and not (chronicle_entry is Dictionary) and chronicle_entry.has_method("get_formatted_text"):
		narrative = String(chronicle_entry.get_formatted_text()).strip_edges()
	if chronicle_title.is_empty() or narrative.is_empty():
		return ""
	var pattern_note := String(_extract_chronicle_field(chronicle_entry, "pattern_reason")).strip_edges()
	if pattern_note.is_empty():
		return "%s이 %s을 회상합니다: %s" % [npc_name, chronicle_title, narrative]
	return "%s이 %s의 전황을 떠올립니다 (%s): %s" % [npc_name, chronicle_title, pattern_note, narrative]

func _extract_style_name(chronicle_entry) -> String:
	if chronicle_entry == null:
		return ""
	if chronicle_entry is Dictionary:
		return String((chronicle_entry as Dictionary).get("style", "")).strip_edges().to_upper()
	if chronicle_entry.has_method("get_style_name"):
		return String(chronicle_entry.get_style_name()).strip_edges().to_upper()
	return String(chronicle_entry.style).strip_edges().to_upper()

func _extract_chronicle_field(chronicle_entry, field_name: String) -> String:
	if chronicle_entry == null:
		return ""
	if chronicle_entry is Dictionary:
		return String((chronicle_entry as Dictionary).get(field_name, "")).strip_edges()
	return String(chronicle_entry.get(field_name) if chronicle_entry != null else "").strip_edges()

func _get_ethics_bracket() -> String:
	var moral_consequence = get_node_or_null("/root/MoralConsequence")
	if moral_consequence != null and moral_consequence.has_method("get_dialogue_variant_track"):
		return String(moral_consequence.get_dialogue_variant_track()).strip_edges()
	var ethics = get_node_or_null("/root/Ethics")
	if ethics != null and ethics.has_method("get_ethics_bracket"):
		return String(ethics.get_ethics_bracket()).strip_edges()
	return "pragmatic"

func _get_chronicle_pattern(chronicle_context: Dictionary) -> String:
	return String(chronicle_context.get("pattern", "balanced")).strip_edges().to_lower()

func _variant_to_string_array(value: Variant) -> Array[String]:
	var lines: Array[String] = []
	if typeof(value) != TYPE_ARRAY and typeof(value) != TYPE_PACKED_STRING_ARRAY:
		return lines
	for raw_line in value:
		var normalized := String(raw_line).strip_edges()
		if normalized.is_empty():
			continue
		lines.append(normalized)
	return lines
