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
		"Skill Review",
		"Inspect the squad before the next sortie.",
		"Continue",
		{
			"active_section": "skills",
			"selected_party_unit_id": "ally_bran",
			"party_entries": ["Bran ready"],
			"party_details": [
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
							"name": "Bulwark Cry",
							"description": "Draws enemy focus and fortifies nearby allies.",
							"cost_text": "SP 1",
							"level": 1,
							"exp": 0,
							"exp_to_next": 30,
							"exp_remaining": 30
						}
					]
				}
			]
		}
	)
	await process_frame

	var skill_button = panel.get_node_or_null("Panel/Margin/Content/SectionTabs/SkillsButton")
	if skill_button == null:
		return _fail("CampaignPanel should expose a dedicated SkillsButton tab in camp UI.")

	var skill_section = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SkillsSection")
	if skill_section == null:
		return _fail("CampaignPanel should expose a dedicated SkillsSection surface in camp UI.")

	if String(panel.get_snapshot().get("active_section", "")) != "skills":
		return _fail("CampaignPanel should accept the skills section as an active camp section.")

	var selected_unit_label = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SkillsSection/SelectedUnitLabel")
	if selected_unit_label == null or String(selected_unit_label.text).find("Bran") == -1:
		return _fail("Skills section should show the selected party member name.")

	var skill_list = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SkillsSection/SkillList")
	if skill_list == null:
		return _fail("Skills section should expose a SkillList surface.")
	var skill_text := String(skill_list.text)
	if skill_text.find("Shield Bash") == -1:
		return _fail("Skills section should render skill names for the selected unit.")
	if skill_text.find("Slams the enemy shield-first") == -1:
		return _fail("Skills section should render skill descriptions for the selected unit.")
	if skill_text.find("MP 2") == -1:
		return _fail("Skills section should render skill resource cost text.")
	if skill_text.find("Lv 2") == -1 or skill_text.find("EXP 10/30") == -1:
		return _fail("Skills section should render skill level and EXP details when available.")

	print("[PASS] campaign_panel_skill_section_runner validated the dedicated camp skills section.")
	quit(0)


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
