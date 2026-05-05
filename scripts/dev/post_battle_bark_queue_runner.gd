extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const BattleResultScreen = preload("res://scripts/battle/battle_result_screen.gd")
const CampaignController = preload("res://scripts/campaign/campaign_controller.gd")
const CampaignState = preload("res://scripts/campaign/campaign_state.gd")
const CutsceneCatalog = preload("res://data/cutscenes/cutscene_catalog.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not _assert_authored_stage_bark_rules():
		return
	if not await _assert_battle_result_conditional_bark_queue_and_idempotency():
		return
	if not _assert_result_screen_bark_sections():
		return
	if not await _assert_campaign_handoff_bark_lines():
		return
	if not await _assert_final_empty_clear_stays_generic_bark_safe():
		return
	print("[PASS] post_battle_bark_queue_runner: all assertions passed.")
	quit(0)

func _assert_authored_stage_bark_rules() -> bool:
	var expected_optional_ids := {
		"CH01_02": ["ch01_02_no_ally_casualties"],
		"CH01_03": ["ch01_03_supply_cache_secured", "ch01_03_ruined_well_logged"],
		"CH01_04": ["ch01_04_west_lever_secured", "ch01_04_east_lever_secured"],
		"CH01_05": ["serin_defeats_enemy_commander", "no_ally_casualties"],
		"CH02_01": ["ch02_01_no_ally_casualties", "ch02_01_scout_survives"],
		"CH02_02": ["ch02_02_no_ally_casualties", "ch02_02_vanguard_holds_wall"],
		"CH02_03": ["ch02_03_no_ally_casualties", "ch02_03_scout_survives"],
		"CH02_04": ["ch02_04_west_tunnel_secured", "ch02_04_south_tunnel_secured", "ch02_04_inner_gate_secured"],
		"CH02_05": ["lete_survives", "activate_3_traps"],
		"CH03_01": ["ch03_01_west_trail_mapped", "ch03_01_east_trail_mapped"],
		"CH03_02": ["ch03_02_south_refugee_route_read", "ch03_02_north_snare_cut"],
		"CH03_03": ["ch03_03_refugee_cache_opened", "ch03_03_wildfire_residue_logged"],
		"CH03_04": ["ch03_04_west_resin_shrine_read", "ch03_04_east_ember_device_tuned"],
		"CH03_05": ["tia_defeats_enemy_boss", "no_structures_destroyed"],
		"CH04_01": ["ch04_01_no_ally_casualties", "ch04_01_scout_survives"],
		"CH04_02": ["ch04_02_no_ally_casualties", "ch04_02_vanguard_survives"],
		"CH04_03": ["ch04_03_west_sluice_aligned", "ch04_03_east_sluice_aligned"],
		"CH04_04": ["ch04_04_north_seal_read", "ch04_04_south_seal_read"],
		"CH04_05": ["ark_survives_flooded_section", "collect_2_research_logs"],
		"CH05_01": ["ch05_01_no_ally_casualties", "ch05_01_scout_survives"],
		"CH05_02": ["ch05_02_no_ally_casualties", "ch05_02_vanguard_survives"],
		"CH05_03": ["ch05_03_west_pressure_valve", "ch05_03_upper_stack_seal"],
		"CH05_04": ["ch05_04_truth_shelf_index", "ch05_04_zero_transfer_ledger"],
		"CH05_05": ["defeat_boss_without_noah_dying", "collect_3_ledger_entries"],
		"CH06_01": ["ch06_01_no_ally_casualties", "ch06_01_scout_survives"],
		"CH06_02": ["ch06_02_west_battery_winch", "ch06_02_center_chain_lift_gate"],
		"CH06_03": ["ch06_03_no_ally_casualties", "ch06_03_vanguard_survives"],
		"CH06_04": ["ch06_04_west_archive_case", "ch06_04_ceremonial_seal"],
		"CH06_05": ["valtor_civilian_escapes", "fort_resistance_zero"],
		"CH07_01": ["ch07_01_market_route_board", "ch07_01_queue_bell"],
		"CH07_02": ["ch07_02_silence_plaque", "ch07_02_queue_release_post"],
		"CH07_03": ["ch07_03_procession_roll", "ch07_03_witness_mark"],
		"CH07_04": ["ch07_04_west_sermon_pulley", "ch07_04_east_sermon_pulley"],
		"CH07_05": ["recruit_mira", "collect_city_seal"],
		"CH08_01": ["ch08_01_west_hound_sign", "ch08_01_east_signal_post"],
		"CH08_02": ["ch08_02_west_moon_scent_post", "ch08_02_east_split_line_cache"],
		"CH08_03": ["ch08_03_west_vent_capstan", "ch08_03_east_cell_record_case"],
		"CH08_04": ["ch08_04_west_control_brand", "ch08_04_east_control_brand"],
		"CH08_05": ["lete_defects_alive", "no_black_hound_casualties"],
		"CH09A_01": ["ch09a_01_west_defense_tablet", "ch09a_01_east_signal_standard"],
		"CH09A_02": ["ch09a_02_bridge_banner_ledger", "ch09a_02_oath_pike_post"],
		"CH09A_03": ["ch09a_03_west_oath_roll", "ch09a_03_east_censor_mark"],
		"CH09A_04": ["ch09a_04_west_cell_witness", "ch09a_04_east_censor_pike"],
		"CH09A_05": ["karl_testifies", "no_ally_casualties"],
		"CH09B_01": ["ch09b_01_west_root_seal", "ch09b_01_east_root_index"],
		"CH09B_02": ["ch09b_02_west_erased_shelf", "ch09b_02_east_revision_shelf"],
		"CH09B_03": ["ch09b_03_center_memory_lattice", "ch09b_03_east_keeper_record"],
		"CH09B_04": ["ch09b_04_west_revision_core", "ch09b_04_east_revision_core"],
		"CH09B_05": ["melkion_truth_revealed", "noah_survives"],
		"CH10_01": ["ch10_01_west_eclipse_tablet", "ch10_01_east_lift_latch"],
		"CH10_02": ["ch10_02_west_crest_control", "ch10_02_east_crest_control"],
		"CH10_03": ["ch10_03_west_corridor_anchor", "ch10_03_east_corridor_anchor"],
		"CH10_04": ["ch10_04_edict_throne", "no_ally_casualties"],
		"CH10_05": ["all_allies_name_called", "no_ally_casualties"],
	}
	for stage_path in [
		"res://data/stages/ch01_02_stage.tres",
		"res://data/stages/ch01_03_stage.tres",
		"res://data/stages/ch01_04_stage.tres",
		"res://data/stages/ch01_05_stage.tres",
		"res://data/stages/ch02_01_stage.tres",
		"res://data/stages/ch02_02_stage.tres",
		"res://data/stages/ch02_03_stage.tres",
		"res://data/stages/ch02_04_stage.tres",
		"res://data/stages/ch02_05_stage.tres",
		"res://data/stages/ch03_01_stage.tres",
		"res://data/stages/ch03_02_stage.tres",
		"res://data/stages/ch03_03_stage.tres",
		"res://data/stages/ch03_04_stage.tres",
		"res://data/stages/ch03_05_stage.tres",
		"res://data/stages/ch04_01_stage.tres",
		"res://data/stages/ch04_02_stage.tres",
		"res://data/stages/ch04_03_stage.tres",
		"res://data/stages/ch04_04_stage.tres",
		"res://data/stages/ch04_05_stage.tres",
		"res://data/stages/ch05_01_stage.tres",
		"res://data/stages/ch05_02_stage.tres",
		"res://data/stages/ch05_03_stage.tres",
		"res://data/stages/ch05_04_stage.tres",
		"res://data/stages/ch05_05_stage.tres",
		"res://data/stages/ch06_01_stage.tres",
		"res://data/stages/ch06_02_stage.tres",
		"res://data/stages/ch06_03_stage.tres",
		"res://data/stages/ch06_04_stage.tres",
		"res://data/stages/ch06_05_stage.tres",
		"res://data/stages/ch07_01_stage.tres",
		"res://data/stages/ch07_02_stage.tres",
		"res://data/stages/ch07_03_stage.tres",
		"res://data/stages/ch07_04_stage.tres",
		"res://data/stages/ch07_05_stage.tres",
		"res://data/stages/ch08_01_stage.tres",
		"res://data/stages/ch08_02_stage.tres",
		"res://data/stages/ch08_03_stage.tres",
		"res://data/stages/ch08_04_stage.tres",
		"res://data/stages/ch08_05_stage.tres",
		"res://data/stages/ch09a_01_stage.tres",
		"res://data/stages/ch09a_02_stage.tres",
		"res://data/stages/ch09a_03_stage.tres",
		"res://data/stages/ch09a_04_stage.tres",
		"res://data/stages/ch09a_05_stage.tres",
		"res://data/stages/ch09b_01_stage.tres",
		"res://data/stages/ch09b_02_stage.tres",
		"res://data/stages/ch09b_03_stage.tres",
		"res://data/stages/ch09b_04_stage.tres",
		"res://data/stages/ch09b_05_stage.tres",
		"res://data/stages/ch10_01_stage.tres",
		"res://data/stages/ch10_02_stage.tres",
		"res://data/stages/ch10_03_stage.tres",
		"res://data/stages/ch10_04_stage.tres",
		"res://data/stages/ch10_05_stage.tres",
	]:
		var stage: StageData = load(stage_path)
		if stage == null:
			return _fail("Authored stage should load for bark rule coverage: %s" % stage_path)
		if stage.post_battle_bark_rules.size() < 3:
			return _fail("%s should carry at least 3 authored post_battle_bark_rules." % String(stage.stage_id))
		var seen_sections := {}
		var seen_rule_ids := {}
		var allowed_optional_ids: Array = expected_optional_ids.get(String(stage.stage_id), [])
		for rule in stage.post_battle_bark_rules:
			if typeof(rule) != TYPE_DICTIONARY:
				return _fail("Authored bark rule should be a Dictionary. stage=%s rule=%s" % [String(stage.stage_id), str(rule)])
			var typed_rule: Dictionary = rule
			var section := String(typed_rule.get("section", "story"))
			var rule_id := String(typed_rule.get("id", ""))
			seen_sections[section] = true
			if not ["story", "bonds", "telemetry"].has(section):
				return _fail("Authored bark rule uses unsupported section. stage=%s rule=%s" % [String(stage.stage_id), str(typed_rule)])
			if rule_id.find(String(stage.stage_id).to_lower()) != 0:
				return _fail("Authored bark rule id should use stage prefix. stage=%s rule=%s" % [String(stage.stage_id), str(typed_rule)])
			if bool(seen_rule_ids.get(rule_id, false)):
				return _fail("Authored bark rule id should be unique per stage. stage=%s id=%s" % [String(stage.stage_id), rule_id])
			seen_rule_ids[rule_id] = true
			if String(typed_rule.get("speaker", "")).strip_edges().is_empty() or String(typed_rule.get("text", "")).strip_edges().is_empty():
				return _fail("Authored bark rule speaker/text should not be empty. stage=%s rule=%s" % [String(stage.stage_id), str(typed_rule)])
			var conditions: Dictionary = typed_rule.get("conditions", {}) if typeof(typed_rule.get("conditions", {})) == TYPE_DICTIONARY else {}
			for key in ["optional_completed", "optional_failed"]:
				var values: Array = conditions.get(key, []) if typeof(conditions.get(key, [])) == TYPE_ARRAY else []
				for value in values:
					if not allowed_optional_ids.has(String(value)):
						return _fail("Authored bark rule references unknown optional objective id. stage=%s key=%s value=%s" % [String(stage.stage_id), String(key), String(value)])
		for section in ["story", "bonds", "telemetry"]:
			if not bool(seen_sections.get(String(section), false)):
				return _fail("%s authored bark rules should cover section '%s'. sections=%s" % [String(stage.stage_id), String(section), str(seen_sections)])
	return true

func _assert_battle_result_conditional_bark_queue_and_idempotency() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame
	var stage := _make_bark_stage(&"bark_queue_victory", "Bark Queue Victory", &"ch01_02_outro", "다음 목적지: bark queue guild desk.")
	battle.set_stage(stage)
	await process_frame
	await process_frame
	if battle.last_result_summary.is_empty():
		if not battle._check_battle_end():
			return _fail("Battle with no enemies should end in victory for bark queue.")
		await process_frame
	var summary: Dictionary = battle.last_result_summary.duplicate(true)
	var bark_queue: Array = summary.get("post_battle_bark_queue", [])
	if int(summary.get("post_battle_bark_count", -1)) != 4 or bark_queue.size() != 4:
		return _fail("Conditional bark queue should cap matching barks at exactly 4 entries. summary=%s" % str(summary))
	for unwanted_id in ["bark_unmatched", "bark_empty_text", "bark_over_cap"]:
		if _has_bark_id(bark_queue, String(unwanted_id)):
			return _fail("Unmatched or empty bark should not be queued. id=%s queue=%s" % [String(unwanted_id), str(bark_queue)])
	for expected_id in ["bark_victory", "bark_missed", "bark_bonus", "bark_cap_fourth"]:
		if not _has_bark_id(bark_queue, String(expected_id)):
			return _fail("Expected bark id missing: %s queue=%s" % [String(expected_id), str(bark_queue)])
	var before: Dictionary = battle.last_result_summary.duplicate(true)
	if not battle._check_battle_end():
		return _fail("Repeated _check_battle_end should keep terminal bark queue state.")
	await process_frame
	if battle.last_result_summary != before:
		return _fail("Repeated _check_battle_end should not mutate bark queue metadata.")
	battle.queue_free()
	await process_frame
	return true

func _assert_result_screen_bark_sections() -> bool:
	var screen := BattleResultScreen.new()
	root.add_child(screen)
	screen.show_result({
		"title": "Victory",
		"post_battle_bark_queue": _sample_bark_queue(),
	})
	var snapshot: Dictionary = screen.get_result_snapshot()
	var content := String(snapshot.get("content_text", ""))
	for needle in ["[b]Afterword:[/b]", "Guide: The guild wants a short report.", "[b]Bond Bark:[/b]", "Rian: We held together.", "[b]Battle Read:[/b]", "System: Bonus experience was queued."]:
		if content.find(String(needle)) == -1:
			return _fail("BattleResultScreen should render bark queue inside existing sections. missing=%s content=%s" % [String(needle), content])
	var section_ids: Array = snapshot.get("section_ids", [])
	if section_ids != ["story", "bonds", "telemetry"]:
		return _fail("Bark-only result should activate existing story/bonds/telemetry sections in order. section_ids=%s" % str(section_ids))
	screen.queue_free()
	return true

func _assert_campaign_handoff_bark_lines() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	var campaign := CampaignController.new()
	root.add_child(battle)
	root.add_child(campaign)
	await process_frame
	await process_frame
	campaign.setup(battle, null)
	var stage := _make_bark_stage(&"bark_queue_campaign", "Bark Queue Campaign", &"ch01_02_outro", "다음 목적지: bark queue camp lane.")
	campaign._current_stage = stage
	campaign._active_stage_index = 0
	battle.last_result_summary = {
		"outcome": "victory",
		"post_battle_handoff": true,
		"post_battle_cutscene_id": "ch01_02_outro",
		"post_battle_cutscene_available": true,
		"next_destination_summary": "다음 목적지: bark queue camp lane.",
		"stars_earned": 2,
		"optional_objectives_completed": ["no_ally_losses"],
		"optional_objectives_failed": ["secure_scout_cache"],
		"post_battle_bark_queue": _sample_bark_queue(),
		"post_battle_bark_count": 3,
	}
	campaign._on_battle_finished(&"victory", stage.stage_id)
	await process_frame
	var snapshot: Dictionary = campaign.get_state_snapshot()
	if String(snapshot.get("mode", "")) != CampaignState.MODE_CUTSCENE:
		return _fail("Bark queue handoff should still route non-final victory to MODE_CUTSCENE. snapshot=%s" % str(snapshot))
	var body := String(snapshot.get("panel_body", ""))
	for needle in ["전후 대사: Guide — The guild wants a short report.", "전후 대사: Rian — We held together.", "전후 대사: System — Bonus experience was queued.", "bark queue camp lane"]:
		if body.find(String(needle)) == -1:
			return _fail("Campaign handoff should include compact bark lines. missing=%s body=%s" % [String(needle), body])
	campaign.queue_free()
	battle.queue_free()
	await process_frame
	return true

func _assert_final_empty_clear_stays_generic_bark_safe() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	var final_stage := StageData.new()
	final_stage.stage_id = &"CH10_05"
	final_stage.stage_title = "Final Bark Safe"
	final_stage.clear_cutscene_id = &""
	final_stage.next_destination_summary = "다음 목적지: ending flow owns this."
	final_stage.post_battle_bark_rules = [{"id": "final_safe", "speaker": "Guide", "text": "The ending flow keeps ownership.", "section": "story", "conditions": {"outcome": "victory"}}]
	var metadata := {"outcome": "victory", "post_battle_handoff": false, "post_battle_cutscene_id": "", "post_battle_bark_queue": [], "post_battle_bark_count": 0}
	battle.stage_data = final_stage
	battle._populate_post_battle_handoff_metadata(metadata)
	battle._populate_post_battle_bark_queue(metadata)
	if bool(metadata.get("post_battle_handoff", false)) or not String(metadata.get("post_battle_cutscene_id", "")).is_empty():
		return _fail("Final empty clear should not force generic handoff when bark rules exist. metadata=%s" % str(metadata))
	if int(metadata.get("post_battle_bark_count", 0)) != 1:
		return _fail("Final stage may carry explicit bark metadata without generic cutscene handoff. metadata=%s" % str(metadata))
	battle.queue_free()
	await process_frame
	return true

func _make_bark_stage(stage_id: StringName, title: String, clear_cutscene_id: StringName, next_summary: String) -> StageData:
	var stage := StageData.new()
	stage.stage_id = stage_id
	stage.stage_title = title
	stage.grid_size = Vector2i(3, 3)
	stage.cell_size = Vector2i(64, 64)
	stage.win_condition = &"defeat_all_enemies"
	stage.objective_text = "Verify post-battle conditional bark queue."
	stage.clear_cutscene_id = clear_cutscene_id
	stage.next_destination_summary = next_summary
	stage.optional_objectives = [
		{"id": "no_ally_losses", "description": "Keep every ally standing", "condition": "no_ally_casualties", "star_value": 1},
		{"id": "secure_scout_cache", "description": "Secure the scout cache", "condition": "flag:secure_scout_cache", "star_value": 1},
	]
	stage.post_battle_bark_rules = [
		{"id": "bark_victory", "speaker": "Guide", "text": "The guild wants a short report.", "section": "story", "conditions": {"outcome": "victory", "optional_completed": ["no_ally_losses"], "post_battle_handoff": true}},
		{"id": "bark_missed", "speaker": "Rian", "text": "We held together.", "section": "bonds", "conditions": {"outcome": "victory", "optional_failed": ["secure_scout_cache"]}},
		{"id": "bark_bonus", "speaker": "System", "text": "Bonus experience was queued.", "section": "telemetry", "conditions": {"outcome": "victory", "bonus_exp_min": 1}},
		{"id": "bark_cap_fourth", "speaker": "Guide", "text": "Fourth matching bark proves the queue cap boundary.", "section": "story", "conditions": {"outcome": "victory"}},
		{"id": "bark_over_cap", "speaker": "Guide", "text": "This fifth matching bark should be capped out.", "section": "story", "conditions": {"outcome": "victory"}},
		{"id": "bark_unmatched", "speaker": "Guide", "text": "This should not appear.", "section": "story", "conditions": {"optional_completed": ["missing_objective"]}},
		{"id": "bark_empty_text", "speaker": "Guide", "text": "", "section": "story", "conditions": {"outcome": "victory"}},
	]
	stage.ally_units = [_make_unit(&"bark_ally", "Bark Ally", "ally", 30, 7, 1)]
	stage.enemy_units = []
	stage.ally_spawns = [Vector2i(1, 1)]
	stage.enemy_spawns = []
	return stage

func _make_unit(unit_id: StringName, display_name: String, faction: String, hp: int, attack: int, defense: int) -> UnitData:
	var unit := UnitData.new()
	unit.unit_id = unit_id
	unit.display_name = display_name
	unit.faction = faction
	unit.max_hp = hp
	unit.attack = attack
	unit.defense = defense
	unit.movement = 3
	unit.attack_range = 1
	unit.default_skill = load("res://data/skills/basic_attack.tres")
	return unit

func _sample_bark_queue() -> Array[Dictionary]:
	return [
		{"id": "story_bark", "speaker": "Guide", "text": "The guild wants a short report.", "section": "story", "priority": 10},
		{"id": "bond_bark", "speaker": "Rian", "text": "We held together.", "section": "bonds", "priority": 20},
		{"id": "telemetry_bark", "speaker": "System", "text": "Bonus experience was queued.", "section": "telemetry", "priority": 30},
	]

func _has_bark_id(queue: Array, bark_id: String) -> bool:
	for entry in queue:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		if String(Dictionary(entry).get("id", "")) == bark_id:
			return true
	return false

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
