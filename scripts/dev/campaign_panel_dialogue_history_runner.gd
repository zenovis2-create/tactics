extends SceneTree

const PANEL_SCENE: PackedScene = preload("res://scenes/campaign/CampaignPanel.tscn")
const CampaignState = preload("res://scripts/campaign/campaign_state.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var panel = PANEL_SCENE.instantiate()
	root.add_child(panel)
	await process_frame
	await process_frame

	if not await _assert_populated_dialogue_history_contract(panel):
		return
	if not await _assert_empty_dialogue_history_fallback(panel):
		return

	print("[PASS] campaign_panel_dialogue_history_runner validated the dedicated camp dialogue history section.")
	quit(0)


func _assert_populated_dialogue_history_contract(panel) -> bool:
	panel.show_state(
		CampaignState.MODE_CAMP,
		"Dialogue History",
		"Review the latest camp handoff before the next sortie.",
		"Continue",
		{
			"active_section": "dialogue_history",
			"dialogue_entries": [
				"세린: 제국이 다시 움직이기 전에 우리가 먼저 길을 정해야 해.",
				"Support B Rank — Bran keeps the rear gate sealed until Rian gives the signal.",
				"Handoff — The archive relay now points north toward the ruined observatory."
			],
			"party_entries": ["Rian ready"],
			"party_details": [
				{
					"unit_id": "ally_rian",
					"name": "Rian",
					"hp_text": "22/22",
					"attack": 8,
					"defense": 5,
					"move": 5,
					"range": 1,
					"skill": "Pulse Cut"
				}
			],
			"memory_entries": ["Archive embers preserved."],
			"evidence_entries": ["North relay sigil copied."],
			"letter_entries": ["Scout note recovered."],
			"presentation_cards": [
				{
					"eyebrow": "동료",
					"title": "세린이 북쪽 계주를 짚다",
					"body": "캠프 인계가 다음 경로를 확정한다."
				}
			]
		}
	)
	await process_frame

	var snapshot: Dictionary = panel.get_snapshot()
	var dialogue_button = panel.get_node_or_null("Panel/Margin/Content/SectionTabs/DialogueHistoryButton")
	if dialogue_button == null:
		return _fail("CampaignPanel should expose a dedicated DialogueHistoryButton tab in camp UI.")
	var records_button = panel.get_node_or_null("Panel/Margin/Content/SectionTabs/RecordsButton")
	if records_button == null:
		return _fail("CampaignPanel should keep RecordsButton adjacent to dialogue history.")
	var summary_section = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SummarySection")
	var dialogue_section = panel.get_node_or_null("Panel/Margin/Content/BodyStack/DialogueHistorySection")
	if dialogue_section == null:
		return _fail("CampaignPanel should expose a dedicated DialogueHistorySection surface in camp UI.")
	if String(snapshot.get("active_section", "")) != "dialogue_history":
		return _fail("CampaignPanel should accept dialogue_history as an active camp section.")
	if not dialogue_section.visible:
		return _fail("DialogueHistorySection should be visible when active_section=dialogue_history.")
	if summary_section == null or summary_section.visible:
		return _fail("SummarySection should be hidden while dialogue_history is active.")
	if not bool(dialogue_button.disabled):
		return _fail("DialogueHistoryButton should be disabled while its section is active.")
	if bool(records_button.disabled):
		return _fail("RecordsButton should remain enabled while dialogue_history is active.")
	if not _text_contains_all(String(snapshot.get("section_hint", "")), ["최근 대화", "지원 대화", "인계"]):
		return _fail("Dialogue history section hint should explain recent/support/handoff review.")
	var dialogue_entries: Array = snapshot.get("dialogue_entries", [])
	if dialogue_entries.size() != 3 or not String(dialogue_entries[0]).begins_with("Empire link:"):
		return _fail("Camp dialogue entries should normalize 제국 handoff lines with Empire link prefix.")
	var section_badges: Dictionary = snapshot.get("section_badges", {})
	if String(section_badges.get("dialogue_history", "")) != "신규 3":
		return _fail("Dialogue history badge should auto-populate from dialogue entry count.")
	if String(dialogue_button.text).find("대화 이력") == -1 or String(dialogue_button.text).find("신규 3") == -1:
		return _fail("DialogueHistoryButton label should mirror the 신규 3 badge.")
	var recent_heading = panel.get_node_or_null("Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/RecentHeading")
	if recent_heading == null or String(recent_heading.text).find("(1)") == -1:
		return _fail("Dialogue history section should expose a recent heading with count 1.")
	var support_heading = panel.get_node_or_null("Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/SupportHeading")
	if support_heading == null or String(support_heading.text).find("(1)") == -1:
		return _fail("Dialogue history section should expose a support heading with count 1.")
	var handoff_heading = panel.get_node_or_null("Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/HandoffHeading")
	if handoff_heading == null or String(handoff_heading.text).find("(1)") == -1:
		return _fail("Dialogue history section should expose a handoff heading with count 1.")
	var recent_list = panel.get_node_or_null("Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/RecentList")
	if recent_list == null or String(recent_list.text).find("Empire link") == -1 or String(recent_list.text).find("세린") == -1:
		return _fail("Dialogue history section should render normalized recent dialogue entries.")
	var support_list = panel.get_node_or_null("Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/SupportList")
	if support_list == null or String(support_list.text).find("Support B Rank") == -1 or String(support_list.text).find("Bran") == -1:
		return _fail("Dialogue history section should render support dialogue entries.")
	var handoff_list = panel.get_node_or_null("Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/HandoffList")
	if handoff_list == null or String(handoff_list.text).find("Handoff") == -1 or String(handoff_list.text).find("observatory") == -1:
		return _fail("Dialogue history section should render handoff dialogue entries.")
	var summary_dialogue_list = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SummarySection/DialogueList")
	if summary_dialogue_list == null or not _text_contains_all(String(summary_dialogue_list.text), ["Empire link", "Support B Rank", "Handoff"]):
		return _fail("Summary dialogue list should mirror normalized dialogue history entries.")
	return true


func _assert_empty_dialogue_history_fallback(panel) -> bool:
	panel.show_state(
		CampaignState.MODE_CAMP,
		"Empty Dialogue History",
		"No dialogue yet.",
		"Continue",
		{
			"active_section": "dialogue_history",
			"dialogue_entries": [],
			"party_entries": ["Rian ready"],
			"party_details": [{"unit_id": "ally_rian", "name": "Rian", "hp_text": "22/22"}]
		}
	)
	await process_frame
	var snapshot: Dictionary = panel.get_snapshot()
	if String(snapshot.get("active_section", "")) != "dialogue_history":
		return _fail("Empty dialogue payload should still keep dialogue_history active.")
	if String(Dictionary(snapshot.get("section_badges", {})).get("dialogue_history", "")) != "":
		return _fail("Empty dialogue payload should not auto-populate a 신규 badge.")
	var recent_list = panel.get_node_or_null("Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/RecentList")
	var support_list = panel.get_node_or_null("Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/SupportList")
	var handoff_list = panel.get_node_or_null("Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/HandoffList")
	if recent_list == null or String(recent_list.text).find("아직 기록된 최근 대화가 없다") == -1:
		return _fail("Empty dialogue history should render recent fallback text.")
	if support_list == null or String(support_list.text).find("아직 해금된 지원 대화가 없다") == -1:
		return _fail("Empty dialogue history should render support fallback text.")
	if handoff_list == null or String(handoff_list.text).find("아직 기록된 인계 대화가 없다") == -1:
		return _fail("Empty dialogue history should render handoff fallback text.")
	return true


func _text_contains_all(text: String, needles: Array[String]) -> bool:
	for needle in needles:
		if text.find(needle) == -1:
			return false
	return true


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
