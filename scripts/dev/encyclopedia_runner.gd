extends SceneTree

const ProgressionData = preload("res://scripts/data/progression_data.gd")
const EncyclopediaPanelScene = preload("res://scenes/ui/encyclopedia_panel.tscn")
const CampaignPanelScene = preload("res://scenes/campaign/CampaignPanel.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var progression := ProgressionData.new()
	_seed_progression(progression)

	var encyclopedia = EncyclopediaPanelScene.instantiate()
	root.add_child(encyclopedia)
	await process_frame
	encyclopedia.show_encyclopedia(progression, &"CH05")
	await process_frame

	if not _assert_codex(encyclopedia):
		return
	if not _assert_timeline(encyclopedia):
		return
	if not _assert_memorial(encyclopedia):
		return
	if not _assert_atlas(encyclopedia):
		return
	if not await _assert_camp_button_visibility():
		return

	print("[PASS] encyclopedia_runner: all assertions passed.")
	quit(0)

func _seed_progression(progression: ProgressionData) -> void:
	progression.chapters_completed = ["CH01", "CH03", "CH05"]
	progression.choices_made = [
		"CH03_BRANCH:ch03_spare_watchtower",
		"CH05_CAMP:ch05_save_ledgers"
	]
	progression.encyclopedia_entries = {
		"ally_rian": {
			"name": "Rian",
			"type": "Ally",
			"chapter_introduced": 1,
			"stats": {"hp": 18, "attack": 6, "defense": 4, "movement": 4, "range": 1},
			"quote": "I remember enough to keep walking.",
			"support_rank": 3
		},
		"enemy_ash_watcher": {
			"name": "Ash Watcher",
			"type": "Enemy",
			"chapter_introduced": 1,
			"stats": {"hp": 12, "attack": 5, "defense": 2, "movement": 3, "range": 1},
			"quote": "The order stands until the bell breaks.",
			"support_rank": 0
		}
	}
	progression.battle_records = [
		{"stage_id": "CH01_05", "turns": 4, "star_rating": 3, "objectives_completed": ["Secure the ash road"], "notes": "Hardren trail secured."},
		{"stage_id": "CH03_05", "turns": 6, "star_rating": 2, "objectives_completed": ["Break the river ambush"], "notes": "Greenwood route opened."},
		{"stage_id": "CH05_05", "turns": 5, "star_rating": 3, "objectives_completed": ["Hold the archive wing"], "notes": "Archive proof relay recovered."}
	]
	progression.add_sacrificed_unit("ally_serin", "Serin", "She held the bridge lantern high enough for the squad to cross.")
	progression.add_memorial_record("ally_serin", "Serin", "She held the bridge lantern high enough for the squad to cross.", "CH01", "CH01_05")

func _assert_codex(encyclopedia) -> bool:
	encyclopedia.select_codex_entry("ally_rian")
	var snapshot: Dictionary = encyclopedia.get_snapshot()
	if int(snapshot.get("codex_count", 0)) < 2:
		return _fail("Codex tab should render the seeded ally and enemy entries.")
	if String(snapshot.get("codex_detail", "")).find("Rian") == -1:
		return _fail("Codex detail should expand the first selected entry.")
	return true

func _assert_timeline(encyclopedia) -> bool:
	encyclopedia.select_tab("timeline")
	var snapshot: Dictionary = encyclopedia.get_snapshot()
	var timeline_text := String(snapshot.get("timeline_text", ""))
	if timeline_text.find("CH05") == -1 or timeline_text.find("ch05_save_ledgers") == -1:
		return _fail("Timeline tab should list completed chapters and recorded choices.")
	return true

func _assert_memorial(encyclopedia) -> bool:
	encyclopedia.select_tab("memorial")
	var snapshot: Dictionary = encyclopedia.get_snapshot()
	if int(snapshot.get("memorial_count", 0)) != 1:
		return _fail("Memorial tab should render the seeded epitaph entry.")
	return true

func _assert_atlas(encyclopedia) -> bool:
	encyclopedia.select_tab("atlas")
	var snapshot: Dictionary = encyclopedia.get_snapshot()
	var atlas_text := String(snapshot.get("atlas_text", ""))
	if atlas_text.find("Hardren Ashfields") == -1 or atlas_text.find("Saria Archive") == -1:
		return _fail("Atlas tab should show the visited route across completed chapters.")
	return true

func _assert_camp_button_visibility() -> bool:
	var campaign_panel = CampaignPanelScene.instantiate()
	root.add_child(campaign_panel)
	await process_frame
	campaign_panel.show_state("camp", "Camp", "Review the route.", "Next Battle")
	var encyclopedia_button: Button = campaign_panel.get_node_or_null("Panel/Margin/Content/FooterRow/EncyclopediaButton")
	if encyclopedia_button == null or not encyclopedia_button.visible or encyclopedia_button.disabled:
		return _fail("CampaignPanel should expose the Encyclopedia button in camp mode.")
	return true

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
