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

	if not await _assert_populated_skills_contract(panel):
		return
	if not await _assert_invalid_selection_fallback(panel):
		return
	if not await _assert_empty_party_fallback(panel):
		return

	print("[PASS] campaign_panel_skill_section_runner validated dedicated camp skills section populated, selection, and fallback states.")
	quit(0)


func _assert_populated_skills_contract(panel: Node) -> bool:
	panel.show_state(
		CampaignState.MODE_CAMP,
		"Skill Review",
		"Inspect the squad before the next sortie.",
		"Continue",
		{
			"active_section": "skills",
			"selected_party_unit_id": "ally_bran",
			"party_entries": ["Bran ready", "Serin ready"],
			"party_details": _build_party_details()
		}
	)
	await process_frame

	if String(panel.get_snapshot().get("active_section", "")) != "skills":
		return _fail("CampaignPanel should accept the skills section as an active camp section.")

	var skill_button: Button = panel.get_node_or_null("Panel/Margin/Content/SectionTabs/SkillsButton")
	var party_button: Button = panel.get_node_or_null("Panel/Margin/Content/SectionTabs/PartyButton")
	var summary_button: Button = panel.get_node_or_null("Panel/Margin/Content/SectionTabs/SummaryButton")
	if skill_button == null:
		return _fail("CampaignPanel should expose a dedicated SkillsButton tab in camp UI.")
	if party_button == null or summary_button == null:
		return _fail("CampaignPanel should expose adjacent Party/Summary tabs in camp UI.")
	if not skill_button.disabled:
		return _fail("SkillsButton should be disabled while the skills section is active.")
	if party_button.disabled or summary_button.disabled:
		return _fail("Adjacent Party/Summary tabs should remain enabled while skills is active.")

	var skill_section: Control = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SkillsSection")
	var summary_section: Control = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SummarySection")
	var party_section: Control = panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection")
	if skill_section == null:
		return _fail("CampaignPanel should expose a dedicated SkillsSection surface in camp UI.")
	if not skill_section.visible:
		return _fail("SkillsSection should be visible when skills is active.")
	if summary_section == null or summary_section.visible:
		return _fail("SummarySection should be hidden when skills is active.")
	if party_section == null or party_section.visible:
		return _fail("PartySection should be hidden when skills is active.")

	var snapshot: Dictionary = panel.get_snapshot()
	if not _text_contains_all(String(snapshot.get("section_hint", "")), ["스킬 설명", "자원 비용", "숙련도"]):
		return _fail("Skills section hint should explain description/cost/proficiency review.")

	var skills_heading: Label = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SkillsSection/SkillsHeading")
	if skills_heading == null or String(skills_heading.text).find("(2)") == -1:
		return _fail("SkillsHeading should reflect two party detail entries.")

	var selected_unit_label: Label = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SkillsSection/SelectedUnitLabel")
	if selected_unit_label == null or String(selected_unit_label.text).find("Bran") == -1:
		return _fail("Skills section should show the selected party member name.")

	var skill_list: RichTextLabel = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SkillsSection/SkillList")
	if skill_list == null:
		return _fail("Skills section should expose a SkillList surface.")
	var skill_text := String(skill_list.text)
	if not _text_contains_all(skill_text, ["Shield Bash", "Slams the enemy shield-first", "MP 2", "Lv 2", "EXP 10/30"]):
		return _fail("Skills section should render Bran skill name, description, cost, level, and EXP details.")
	if not _text_contains_all(skill_text, ["Veteran Guard", "비용: 없음", "Lv 5 / MAX"]):
		return _fail("Skills section should render no-cost and max-level skill fallbacks.")

	if not panel.select_party_by_unit_id("ally_serin"):
		return _fail("select_party_by_unit_id should accept a valid second party member.")
	await process_frame
	var switched_snapshot: Dictionary = panel.get_snapshot()
	if String(switched_snapshot.get("selected_party_unit_id", "")) != "ally_serin":
		return _fail("Snapshot should mirror the switched selected party unit id.")
	if String(switched_snapshot.get("active_section", "")) != "skills":
		return _fail("Switching party members should preserve the active skills section.")
	if String(selected_unit_label.text).find("Serin") == -1:
		return _fail("SelectedUnitLabel should update after switching to Serin.")
	var serin_skill_text := String(skill_list.text)
	if not _text_contains_all(serin_skill_text, ["First Aid", "설명 정보가 아직 연결되지 않았다."]):
		return _fail("SkillList should use the fallback description for a selected unit without detailed skill_entries.")
	return true


func _assert_invalid_selection_fallback(panel: Node) -> bool:
	panel.show_state(
		CampaignState.MODE_CAMP,
		"Skill Review",
		"Inspect the squad before the next sortie.",
		"Continue",
		{
			"active_section": "skills",
			"selected_party_unit_id": "missing_unit",
			"party_entries": ["Bran ready"],
			"party_details": [_build_party_details()[0]]
		}
	)
	await process_frame

	var snapshot: Dictionary = panel.get_snapshot()
	if String(snapshot.get("selected_party_unit_id", "")) != "ally_bran":
		return _fail("Invalid selected_party_unit_id should fall back to the first valid party unit.")
	var selected_unit_label: Label = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SkillsSection/SelectedUnitLabel")
	if selected_unit_label == null or String(selected_unit_label.text).find("Bran") == -1:
		return _fail("Invalid selected_party_unit_id fallback should render Bran skills.")
	return true


func _assert_empty_party_fallback(panel: Node) -> bool:
	panel.show_state(
		CampaignState.MODE_CAMP,
		"Skill Review",
		"Inspect the squad before the next sortie.",
		"Continue",
		{
			"active_section": "skills",
			"party_entries": [],
			"party_details": []
		}
	)
	await process_frame

	if String(panel.get_snapshot().get("active_section", "")) != "skills":
		return _fail("Empty party payload should keep the skills section active.")
	var skill_section: Control = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SkillsSection")
	if skill_section == null or not skill_section.visible:
		return _fail("Empty party payload should keep SkillsSection visible.")
	var selected_unit_label: Label = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SkillsSection/SelectedUnitLabel")
	var skill_list: RichTextLabel = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SkillsSection/SkillList")
	if selected_unit_label == null or String(selected_unit_label.text).find("선택된 부대원이 없다") == -1:
		return _fail("Empty party payload should show the no-selected-unit fallback.")
	if skill_list == null or String(skill_list.text).find("점검할 스킬이 없다") == -1:
		return _fail("Empty party payload should show the no-skills fallback.")
	return true


func _build_party_details() -> Array[Dictionary]:
	return [
		{
			"unit_id": "ally_bran",
			"name": "Bran",
			"hp_text": "24/24",
			"attack": 9,
			"defense": 7,
			"move": 4,
			"range": 1,
			"skill": "Shield Bash",
			"skill_entries": [
				{
					"name": "Shield Bash",
					"description": "Slams the enemy shield-first and staggers the front line.",
					"cost_text": "MP 2",
					"level": 2,
					"exp": 10,
					"exp_to_next": 30,
					"exp_remaining": 20
				},
				{
					"name": "Veteran Guard",
					"description": "Holds the choke point after long campaigns.",
					"cost_text": "",
					"level": 5,
					"exp_to_next": 0,
					"is_max": true
				}
			]
		},
		{
			"unit_id": "ally_serin",
			"name": "Serin",
			"hp_text": "18/18",
			"attack": 5,
			"defense": 4,
			"move": 5,
			"range": 2,
			"skill": "First Aid",
			"skill_entries": []
		}
	]


func _text_contains_all(text: String, needles: Array[String]) -> bool:
	for needle in needles:
		if text.find(needle) == -1:
			return false
	return true


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
