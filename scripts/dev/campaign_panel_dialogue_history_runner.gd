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

	var dialogue_button = panel.get_node_or_null("Panel/Margin/Content/SectionTabs/DialogueHistoryButton")
	if dialogue_button == null:
		return _fail("CampaignPanel should expose a dedicated DialogueHistoryButton tab in camp UI.")

	var dialogue_section = panel.get_node_or_null("Panel/Margin/Content/BodyStack/DialogueHistorySection")
	if dialogue_section == null:
		return _fail("CampaignPanel should expose a dedicated DialogueHistorySection surface in camp UI.")

	if String(panel.get_snapshot().get("active_section", "")) != "dialogue_history":
		return _fail("CampaignPanel should accept dialogue_history as an active camp section.")

	var recent_heading = panel.get_node_or_null("Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/RecentHeading")
	if recent_heading == null:
		return _fail("Dialogue history section should expose a recent heading.")

	var recent_list = panel.get_node_or_null("Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/RecentList")
	if recent_list == null or String(recent_list.text).find("세린") == -1:
		return _fail("Dialogue history section should render recent dialogue entries.")

	var support_list = panel.get_node_or_null("Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/SupportList")
	if support_list == null or String(support_list.text).find("Bran") == -1:
		return _fail("Dialogue history section should render support dialogue entries.")

	var handoff_list = panel.get_node_or_null("Panel/Margin/Content/BodyStack/DialogueHistorySection/DialogueHistoryStack/HandoffList")
	if handoff_list == null or String(handoff_list.text).find("observatory") == -1:
		return _fail("Dialogue history section should render handoff dialogue entries.")

	print("[PASS] campaign_panel_dialogue_history_runner validated the dedicated camp dialogue history section.")
	quit(0)


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
