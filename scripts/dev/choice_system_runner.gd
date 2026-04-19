extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CampaignState = preload("res://scripts/campaign/campaign_state.gd")
const CampaignCatalog = preload("res://scripts/campaign/campaign_catalog.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const CH05_FINAL_STAGE = preload("res://data/stages/ch05_05_stage.tres")
const CH07_FINAL_STAGE = preload("res://data/stages/ch07_05_stage.tres")
const CH08_PRE_BOSS_STAGE = preload("res://data/stages/ch08_04_stage.tres")
const CH09A_FINAL_STAGE = preload("res://data/stages/ch09a_05_stage.tres")
const CH10_PRE_FINALE_STAGE = preload("res://data/stages/ch10_04_stage.tres")

const CASES: Array[Dictionary] = [
	{
		"label": "CH05 camp A",
		"choice_point_id": &"ch05_camp",
		"option_id": "ch05_save_ledgers",
		"seed_kind": "camp",
		"chapter_id": &"CH05",
		"stage_index": 4,
		"stage": CH05_FINAL_STAGE
	},
	{
		"label": "CH05 camp B",
		"choice_point_id": &"ch05_camp",
		"option_id": "ch05_save_enoch",
		"seed_kind": "camp",
		"chapter_id": &"CH05",
		"stage_index": 4,
		"stage": CH05_FINAL_STAGE
	},
	{
		"label": "CH07 interlude A",
		"choice_point_id": &"ch07_interlude",
		"option_id": "ch07_believe_mira",
		"seed_kind": "camp",
		"chapter_id": &"CH07",
		"stage_index": 4,
		"stage": CH07_FINAL_STAGE
	},
	{
		"label": "CH07 interlude B",
		"choice_point_id": &"ch07_interlude",
		"option_id": "ch07_doubt_mira",
		"seed_kind": "camp",
		"chapter_id": &"CH07",
		"stage_index": 4,
		"stage": CH07_FINAL_STAGE
	},
	{
		"label": "CH08 pre-boss A",
		"choice_point_id": &"ch08_pre_boss",
		"option_id": "ch08_accept_lete",
		"seed_kind": "pre_boss",
		"chapter_id": &"CH08",
		"stage_index": 3,
		"stage": CH08_PRE_BOSS_STAGE
	},
	{
		"label": "CH08 pre-boss B",
		"choice_point_id": &"ch08_pre_boss",
		"option_id": "ch08_reject_lete",
		"seed_kind": "pre_boss",
		"chapter_id": &"CH08",
		"stage_index": 3,
		"stage": CH08_PRE_BOSS_STAGE
	},
	{
		"label": "CH09A camp A",
		"choice_point_id": &"ch09a_camp",
		"option_id": "ch09a_public_testimony",
		"seed_kind": "camp",
		"chapter_id": &"CH09A",
		"stage_index": 4,
		"stage": CH09A_FINAL_STAGE
	},
	{
		"label": "CH09A camp B",
		"choice_point_id": &"ch09a_camp",
		"option_id": "ch09a_private_testimony",
		"seed_kind": "camp",
		"chapter_id": &"CH09A",
		"stage_index": 4,
		"stage": CH09A_FINAL_STAGE
	},
	{
		"label": "CH10 pre-finale A",
		"choice_point_id": &"ch10_pre_finale",
		"option_id": "ch10_name_the_fallen",
		"seed_kind": "pre_boss",
		"chapter_id": &"CH10",
		"stage_index": 3,
		"stage": CH10_PRE_FINALE_STAGE
	},
	{
		"label": "CH10 pre-finale B",
		"choice_point_id": &"ch10_pre_finale",
		"option_id": "ch10_name_the_principle",
		"seed_kind": "pre_boss",
		"chapter_id": &"CH10",
		"stage_index": 3,
		"stage": CH10_PRE_FINALE_STAGE
	},
	{
		"label": "CH10 pre-finale Destiny",
		"choice_point_id": &"ch10_pre_finale",
		"option_id": "ch10_record_the_chosen",
		"seed_kind": "pre_boss",
		"chapter_id": &"CH10",
		"stage_index": 3,
		"stage": CH10_PRE_FINALE_STAGE,
		"seed_destiny_unlocked": true,
		"expected_option_count": 3
	}
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var all_passed: bool = true
	for config in CASES:
		var result := await _run_case(config)
		if result.is_empty():
			print("[PASS] %s" % String(config.get("label", "choice case")))
		else:
			all_passed = false
			push_error("[FAIL] %s: %s" % [String(config.get("label", "choice case")), result])

	if all_passed:
		print("[PASS] choice_system_runner validated all %d choice outcomes." % CASES.size())
		quit(0)
		return

	quit(1)

func _run_case(config: Dictionary) -> String:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	if not main.has_method("get_campaign_state_snapshot"):
		main.queue_free()
		await process_frame
		return "Main scene script did not load cleanly."

	var campaign = main.get_node_or_null("CampaignController")
	if campaign == null:
		main.queue_free()
		await process_frame
		return "Campaign controller was not available."

	var blank_progression := ProgressionData.new()
	if main.has_method("_get_progression_data"):
		var battle = main.get_node_or_null("BattleScene")
		if battle != null and battle.progression_service != null:
			battle.progression_service.load_data(blank_progression)
	var save_service = main.get_node_or_null("SaveService")
	if save_service != null and save_service.has_method("save_progression"):
		save_service.save_progression(blank_progression, 0)

	var seed_error := await _seed_choice(main, campaign, config)
	if not seed_error.is_empty():
		main.queue_free()
		await process_frame
		return seed_error

	var campaign_panel = main.get_node_or_null("CanvasLayer/CampaignPanel")
	if campaign_panel == null:
		main.queue_free()
		await process_frame
		return "Campaign panel was not available."
	var panel_snapshot: Dictionary = campaign_panel.get_snapshot()
	var choice_error := _validate_choice_panel(panel_snapshot, config)
	if not choice_error.is_empty():
		main.queue_free()
		await process_frame
		return choice_error

	campaign._make_choice(String(config.get("option_id", "")))
	await process_frame
	await process_frame

	var verify_error := _verify_choice_outcome(main, config)
	main.queue_free()
	await process_frame
	await process_frame
	return verify_error

func _seed_choice(main: Node, campaign, config: Dictionary) -> String:
	var seed_kind := String(config.get("seed_kind", ""))
	match seed_kind:
		"camp":
			campaign.debug_seed_chapter_camp(
				config.get("chapter_id", StringName()),
				int(config.get("stage_index", 0)),
				config.get("stage", null)
			)
			await process_frame
			await process_frame
		"pre_boss":
			campaign._active_chapter_id = config.get("chapter_id", StringName())
			campaign._active_stage_index = int(config.get("stage_index", 0))
			campaign._current_stage = config.get("stage", null)
			campaign._active_mode = CampaignState.MODE_CUTSCENE
			if bool(config.get("seed_destiny_unlocked", false)):
				var progression = campaign._get_progression_data()
				if progression != null:
					progression.add_ng_plus_purchase("ng_plus_1")
					progression.add_ng_plus_purchase("ng_plus_2")
					progression.add_ng_plus_purchase("ng_plus_3")
			if not campaign.advance_step():
				return "advance_step() did not enter the pre-boss choice state."
			await process_frame
			await process_frame
		_:
			return "Unknown seed kind: %s" % seed_kind

	var snapshot: Dictionary = main.get_campaign_state_snapshot()
	if String(snapshot.get("mode", "")) != CampaignState.MODE_CHOICE:
		return "Expected choice mode after seeding, got %s." % snapshot.get("mode", "")
	return ""

func _validate_choice_panel(panel_snapshot: Dictionary, config: Dictionary) -> String:
	if String(panel_snapshot.get("mode", "")) != CampaignState.MODE_CHOICE:
		return "Campaign panel did not surface choice mode."
	if StringName(panel_snapshot.get("choice_stage_id", "")) != config.get("choice_point_id", StringName()):
		return "Choice panel surfaced %s instead of %s." % [panel_snapshot.get("choice_stage_id", ""), config.get("choice_point_id", StringName())]
	if String(panel_snapshot.get("choice_prompt", "")).strip_edges().is_empty():
		return "Choice prompt was empty."
	var options: Array = panel_snapshot.get("choice_options", [])
	var expected_option_count := int(config.get("expected_option_count", 2))
	if options.size() != expected_option_count:
		return "Expected %d choice options, got %d." % [expected_option_count, options.size()]
	for option in options:
		if typeof(option) != TYPE_DICTIONARY:
			return "Choice option payload was not a dictionary."
		if String(option.get("label", "")).strip_edges().is_empty():
			return "Choice option label was empty."
		if String(option.get("hint", "")).strip_edges().is_empty():
			return "Choice option hint was empty."
	return ""

func _verify_choice_outcome(main: Node, config: Dictionary) -> String:
	var battle = main.get_node_or_null("BattleScene")
	var progression = battle.progression_service.get_data() if battle != null and battle.progression_service != null else null
	if progression == null:
		return "Progression data was unavailable after choice resolution."

	var choice_record := "%s:%s" % [String(config.get("choice_point_id", StringName())), String(config.get("option_id", ""))]
	if not progression.choices_made.has(choice_record):
		return "Choice record %s was not persisted." % choice_record

	match StringName(config.get("choice_point_id", StringName())):
		&"ch05_camp":
			if String(config.get("option_id", "")) == "ch05_save_ledgers":
				if not progression.enoch_wounded or progression.ledger_count != 5:
					return "CH05 A did not wound Enoch and set ledger_count=5."
			else:
				if progression.enoch_wounded or progression.ledger_count != 2:
					return "CH05 B did not keep Enoch safe with ledger_count=2."
			if String(main.get_campaign_state_snapshot().get("mode", "")) != CampaignState.MODE_CAMP:
				return "CH05 choice did not return to camp mode."
		&"ch07_interlude":
			if String(config.get("option_id", "")) == "ch07_believe_mira":
				if progression.mira_trust_level != 2 or progression.neri_disposition != "hostile":
					return "CH07 A did not set Mira trust and Neri hostility."
			else:
				if progression.mira_trust_level != -1 or progression.neri_disposition != "neutral":
					return "CH07 B did not set the guarded-neutral route."
			if String(main.get_campaign_state_snapshot().get("mode", "")) != CampaignState.MODE_CAMP:
				return "CH07 choice did not return to camp mode."
		&"ch08_pre_boss":
			if battle == null or battle.stage_data == null or StringName(battle.stage_data.stage_id) != &"CH08_05":
				return "CH08 choice did not continue into CH08_05 battle."
			if String(config.get("option_id", "")) == "ch08_accept_lete":
				if not progression.lete_early_alliance:
					return "CH08 A did not persist lete_early_alliance."
				if battle.stage_data.enemy_units.size() != 1:
					return "CH08 A did not weaken the enemy roster."
				if not _battle_allies_contain_name(battle.ally_units, "Lete"):
					return "CH08 A did not add Lete to the ally roster."
			else:
				if progression.lete_early_alliance:
					return "CH08 B should leave lete_early_alliance false."
				if battle.stage_data.enemy_units.size() != 2:
					return "CH08 B should preserve the full enemy roster."
				if _battle_allies_contain_name(battle.ally_units, "Lete"):
					return "CH08 B should not add allied Lete."
		&"ch09a_camp":
			if String(config.get("option_id", "")) == "ch09a_public_testimony":
				if not is_equal_approx(progression.noah_phase2_multiplier, 2.0) or not progression.melkion_awareness:
					return "CH09A A did not set the public-testimony consequences."
			else:
				if not is_equal_approx(progression.noah_phase2_multiplier, 1.0) or progression.melkion_awareness:
					return "CH09A B did not preserve the private-testimony route."
			if String(main.get_campaign_state_snapshot().get("mode", "")) != CampaignState.MODE_CAMP:
				return "CH09A choice did not return to camp mode."
		&"ch10_pre_finale":
			if battle == null or battle.stage_data == null or StringName(battle.stage_data.stage_id) != &"CH10_05":
				return "CH10 choice did not continue into CH10_05 battle."
			if String(config.get("option_id", "")) == "ch10_name_the_fallen":
				if battle.stage_data.ally_attack_bonus != 1 or battle.stage_data.ally_defense_bonus != 0:
					return "CH10 A did not apply the ally attack bonus."
				if not _allies_gain_bonus_attack(battle.ally_units):
					return "CH10 A did not carry the attack bonus into ally battle stats."
			elif String(config.get("option_id", "")) == "ch10_record_the_chosen":
				if battle.stage_data.ally_attack_bonus != 1 or battle.stage_data.ally_defense_bonus != 1:
					return "CH10 Destiny did not apply the balanced ally bonuses."
				if not _allies_gain_bonus_attack(battle.ally_units) or not _allies_gain_bonus_defense(battle.ally_units):
					return "CH10 Destiny did not carry the balanced bonuses into ally battle stats."
			else:
				if battle.stage_data.ally_attack_bonus != 0 or battle.stage_data.ally_defense_bonus != 1:
					return "CH10 B did not apply the ally defense bonus."
				if not _allies_gain_bonus_defense(battle.ally_units):
					return "CH10 B did not carry the defense bonus into ally battle stats."
		_:
			return "Unknown choice point in verification: %s" % config.get("choice_point_id", StringName())

	return ""

func _battle_allies_contain_name(allies: Array, expected_name: String) -> bool:
	for unit in allies:
		if unit == null or not is_instance_valid(unit) or unit.unit_data == null:
			continue
		if String(unit.unit_data.display_name) == expected_name:
			return true
	return false

func _allies_gain_bonus_attack(allies: Array) -> bool:
	for unit in allies:
		if unit == null or not is_instance_valid(unit) or unit.unit_data == null:
			continue
		var base_unit = CampaignCatalog.get_unit_data(unit.unit_data.unit_id)
		if base_unit != null and unit.get_attack() > base_unit.attack:
			return true
	return false

func _allies_gain_bonus_defense(allies: Array) -> bool:
	for unit in allies:
		if unit == null or not is_instance_valid(unit) or unit.unit_data == null:
			continue
		var base_unit = CampaignCatalog.get_unit_data(unit.unit_data.unit_id)
		if base_unit != null and unit.get_defense() > base_unit.defense:
			return true
	return false
