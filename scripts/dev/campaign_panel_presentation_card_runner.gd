extends SceneTree

const PANEL_SCENE: PackedScene = preload("res://scenes/campaign/CampaignPanel.tscn")
const SHIELD_IMAGE := "res://assets/props/paladin_shield/runtime/paladin_shield_integration_v01.png"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var panel = PANEL_SCENE.instantiate()
	root.add_child(panel)
	await process_frame

	if not await _assert_image_backed_card(panel):
		return
	if not await _assert_meta_only_cards(panel):
		return

	print("[PASS] campaign_panel_presentation_card_runner validated image-backed and meta-only presentation cards.")
	quit(0)


func _assert_image_backed_card(panel: Node) -> bool:
	panel.show_state(
		"camp",
		"Test Camp",
		"Body",
		"Continue",
		{
			"presentation_cards": [
				{
					"eyebrow": "장비",
					"title": "방패 실루엣 기준",
					"body": "테스트 카드",
					"image_path": SHIELD_IMAGE
				}
			]
		}
	)
	await process_frame

	var cards_root = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SummarySection/PresentationCards")
	if cards_root == null:
		return _fail("CampaignPanel should expose PresentationCards root.")
	if cards_root.get_child_count() != 1:
		return _fail("CampaignPanel should create exactly one presentation card for the image payload.")

	var card = cards_root.get_child(0)
	var preview = _find_first_texture_rect(card)
	if preview == null:
		return _fail("Presentation card should include a TextureRect preview when image_path is provided.")
	if preview.texture == null:
		return _fail("Presentation card preview should resolve its texture.")
	return true


func _assert_meta_only_cards(panel: Node) -> bool:
	var meta_cards := [
		{
			"style": "support_memory",
			"eyebrow": "Support memory route",
			"title": "Pair Memory",
			"body": "Rian / Serin",
			"eyebrow_label": "After CH01-05",
			"source_label": "Bond +1 unlocked",
			"memory_stamp": "Support route stamp",
			"outcome_line": "Support memory linked",
			"callout": "NEW SUPPORT",
			"quote": "Hold the line together.",
			"memory_rail": "support",
			"badges": [{"label": "Rank", "value": "B", "complete": true}],
			"progress_rows": [{"icon": "◆", "label": "Trust", "value": "3/5", "ratio": 0.6, "pip_total": 5, "pip_filled": 3, "hint": "Two more camp talks.", "complete": false}]
		},
		{
			"style": "name_call_memory",
			"eyebrow": "Name call route",
			"title": "Name Anchor",
			"body": "Bell tower memory",
			"eyebrow_label": "After CH02-03",
			"source_label": "Trust threshold met",
			"memory_stamp": "Name route stamp",
			"outcome_line": "Name call prepared",
			"callout": "ANCHOR READY",
			"quote": "Say my name when the bell falls.",
			"memory_rail": "name_call"
		},
		{
			"style": "ending_criteria",
			"eyebrow": "Ending criteria",
			"title": "Truth OK",
			"body": "Burden High",
			"badges": [{"label": "Truth", "value": "OK", "complete": true}],
			"progress_rows": [{"icon": "✓", "label": "Fragments", "value": "4/4", "ratio": 1.0, "pip_total": 4, "pip_filled": 4, "hint": "Complete.", "complete": true}]
		},
		{
			"eyebrow": "Generic no image meta",
			"title": "Report",
			"body": "Scout",
			"source_label": "Route note added",
			"memory_rail": "generic",
			"progress_rows": [{"icon": "•", "label": "Clues", "value": "1/2", "ratio": 0.5, "pip_total": 2, "pip_filled": 1, "hint": "One more clue.", "complete": false}]
		}
	]

	panel.show_state(
		"camp",
		"Meta Camp",
		"Body",
		"Continue",
		{"presentation_cards": meta_cards}
	)
	await process_frame

	var cards_root = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SummarySection/PresentationCards")
	if cards_root == null:
		return _fail("CampaignPanel should expose PresentationCards root for meta-only cards.")
	if cards_root.get_child_count() != meta_cards.size():
		return _fail("CampaignPanel should render every meta-only presentation card. expected=%d actual=%d" % [meta_cards.size(), cards_root.get_child_count()])

	for child in cards_root.get_children():
		if _count_texture_rects(child) != 0:
			return _fail("Meta-only presentation cards should not create TextureRect previews when image_path is omitted.")

	var label_text := _collect_label_text(cards_root)
	if not _text_contains_all(label_text, [
		"Support memory route",
		"Pair Memory",
		"Rian / Serin",
		"After CH01-05",
		"Bond +1 unlocked",
		"Support route stamp",
		"Support memory linked",
		"NEW SUPPORT",
		"\"Hold the line together.\"",
		"Rank B",
		"Trust",
		"3/5",
		"Two more camp talks.",
		"Name call route",
		"Name Anchor",
		"Bell tower memory",
		"After CH02-03",
		"Trust threshold met",
		"Name route stamp",
		"Name call prepared",
		"ANCHOR READY",
		"\"Say my name when the bell falls.\"",
		"Ending criteria",
		"Truth OK",
		"Burden High",
		"Truth OK",
		"Fragments",
		"4/4",
		"Complete.",
		"Generic no image meta",
		"Report",
		"Scout",
		"Route note added",
		"Clues",
		"1/2",
		"One more clue."
	]):
		return _fail("Meta-only presentation cards should render all text metadata. labels=%s" % label_text)

	if _count_color_rects(cards_root) < 8:
		return _fail("Meta-only presentation cards should use node-backed rails/progress/pips instead of assets.")

	var snapshot: Dictionary = panel.get_snapshot()
	var snapshot_cards: Array = snapshot.get("presentation_cards", [])
	if snapshot_cards.size() != meta_cards.size():
		return _fail("Snapshot should preserve every meta-only presentation card payload.")
	var first: Dictionary = snapshot_cards[0]
	if String(first.get("style", "")) != "support_memory":
		return _fail("Snapshot should preserve support_memory style.")
	if String(first.get("memory_rail", "")) != "support":
		return _fail("Snapshot should preserve memory_rail metadata.")
	if String(first.get("quote", "")) != "Hold the line together.":
		return _fail("Snapshot should preserve quote metadata.")
	if _variant_to_dictionary_array(first.get("progress_rows", [])).is_empty():
		return _fail("Snapshot should preserve progress_rows metadata.")
	return true


func _find_first_texture_rect(node: Node) -> TextureRect:
	if node is TextureRect:
		return node
	for child in node.get_children():
		var found = _find_first_texture_rect(child)
		if found != null:
			return found
	return null


func _count_texture_rects(node: Node) -> int:
	var count := 1 if node is TextureRect else 0
	for child in node.get_children():
		count += _count_texture_rects(child)
	return count


func _count_color_rects(node: Node) -> int:
	var count := 1 if node is ColorRect else 0
	for child in node.get_children():
		count += _count_color_rects(child)
	return count


func _collect_label_text(node: Node) -> String:
	var lines: Array[String] = []
	_collect_label_text_recursive(node, lines)
	return "\n".join(lines)


func _collect_label_text_recursive(node: Node, lines: Array[String]) -> void:
	if node is Label:
		lines.append(String(node.text))
	for child in node.get_children():
		_collect_label_text_recursive(child, lines)


func _text_contains_all(text: String, needles: Array[String]) -> bool:
	for needle in needles:
		if text.find(needle) == -1:
			return false
	return true


func _variant_to_dictionary_array(value: Variant) -> Array[Dictionary]:
	var details: Array[Dictionary] = []
	if typeof(value) != TYPE_ARRAY:
		return details
	for entry in value:
		if typeof(entry) == TYPE_DICTIONARY:
			details.append(entry)
	return details


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
