extends Node

func get_adapted_dialogue_key(npc_id: String, base_key: String) -> String:
	var normalized_key := base_key.strip_edges()
	if normalized_key.is_empty():
		return ""
	var personality = get_node_or_null("/root/NPCPersonality")
	if personality != null and personality.has_method("get_npc_dialogue_variant"):
		return String(personality.get_npc_dialogue_variant(npc_id, normalized_key)).strip_edges()
	return "%s_NEUTRAL" % normalized_key

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
	return "%s이 %s을 회상합니다: %s" % [npc_name, chronicle_title, narrative]

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
