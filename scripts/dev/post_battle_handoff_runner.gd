extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const BattleResultScreen = preload("res://scripts/battle/battle_result_screen.gd")
const CampaignController = preload("res://scripts/campaign/campaign_controller.gd")
const CampaignState = preload("res://scripts/campaign/campaign_state.gd")
const CAMPAIGN_PANEL_SCENE: PackedScene = preload("res://scenes/campaign/CampaignPanel.tscn")
const CutsceneCatalog = preload("res://data/cutscenes/cutscene_catalog.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_battle_result_handoff_metadata_and_idempotency():
		return
	if not await _assert_campaign_cutscene_handoff_panel():
		return
	if not _assert_result_screen_story_lines():
		return
	if not _assert_final_empty_clear_does_not_force_handoff():
		return
	print("[PASS] post_battle_handoff_runner: all assertions passed.")
	quit(0)

func _assert_battle_result_handoff_metadata_and_idempotency() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	var signal_counts := {"battle_finished": 0}
	battle.battle_finished.connect(func(_result: StringName, _stage_id: StringName) -> void:
		signal_counts["battle_finished"] = int(signal_counts.get("battle_finished", 0)) + 1
	)
	await process_frame
	await process_frame
	var stage := _make_victory_stage(&"handoff_victory", "Handoff Victory", &"ch01_02_outro", "다음 목적지: old road handoff camp.")
	battle.set_stage(stage)
	await process_frame
	await process_frame
	if battle.last_result_summary.is_empty():
		if not battle._check_battle_end():
			return _fail("Battle with no enemies should end in victory.")
		await process_frame
	var summary: Dictionary = battle.last_result_summary.duplicate(true)
	if String(summary.get("post_battle_cutscene_id", "")) != "ch01_02_outro":
		return _fail("Victory result should expose post_battle_cutscene_id. summary=%s" % str(summary))
	if not bool(summary.get("post_battle_cutscene_available", false)) or not bool(summary.get("post_battle_handoff", false)):
		return _fail("Victory result should mark valid post-battle handoff metadata. summary=%s" % str(summary))
	if String(summary.get("next_destination_summary", "")).find("old road handoff camp") == -1:
		return _fail("Victory result should carry next_destination_summary. summary=%s" % str(summary))
	if _cutscene_event_count(battle, &"ch01_02_outro") != 0:
		return _fail("BattleController should not directly play the clear cutscene during result construction.")
	var summary_before: Dictionary = battle.last_result_summary.duplicate(true)
	var signal_count_before := int(signal_counts.get("battle_finished", 0))
	if not battle._check_battle_end():
		return _fail("Repeated _check_battle_end should keep terminal victory state.")
	await process_frame
	if int(signal_counts.get("battle_finished", 0)) != signal_count_before:
		return _fail("Repeated _check_battle_end duplicated battle_finished signal.")
	if battle.last_result_summary != summary_before:
		return _fail("Repeated _check_battle_end duplicated or mutated handoff metadata.")
	battle.queue_free()
	await process_frame
	return true

func _assert_campaign_cutscene_handoff_panel() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	var panel = CAMPAIGN_PANEL_SCENE.instantiate()
	var campaign := CampaignController.new()
	root.add_child(battle)
	root.add_child(panel)
	root.add_child(campaign)
	await process_frame
	await process_frame
	campaign.setup(battle, panel)
	var stage := _make_victory_stage(&"handoff_campaign_stage", "Handoff Campaign Stage", &"ch01_02_outro", "다음 목적지: amber bridge rendezvous.")
	campaign._current_stage = stage
	campaign._active_stage_index = 0
	battle.last_result_summary = {
		"outcome": "victory",
		"post_battle_handoff": true,
		"post_battle_cutscene_id": "ch01_02_outro",
		"post_battle_cutscene_available": true,
		"next_destination_summary": "다음 목적지: amber bridge rendezvous.",
		"quick_summary_line": "Victory — 3★ / optional 1/1",
		"next_action_line": "다음 목적지: amber bridge rendezvous.",
		"stars_earned": 3,
		"optional_objectives_completed": ["Rescue the scout"],
		"optional_objectives_failed": [],
		"treasure_entries": ["Amber Key"],
		"support_attack_count": 2,
		"support_conversations": [{"pair_label": "Rian / Serin", "rank_label": "B"}],
	}
	campaign._on_battle_finished(&"victory", stage.stage_id)
	await process_frame
	var snapshot: Dictionary = campaign.get_state_snapshot()
	if String(snapshot.get("mode", "")) != CampaignState.MODE_CUTSCENE:
		return _fail("Non-final victory should route CampaignController to MODE_CUTSCENE. snapshot=%s" % str(snapshot))
	var body := String(snapshot.get("panel_body", ""))
	for needle in ["결과 요약: Victory — 3★ / optional 1/1", "다음 행동: 다음 목적지: amber bridge rendezvous.", "ch01_02_outro", "amber bridge rendezvous", "Amber Key", "지원", "선택 목표", "3/3"]:
		if body.find(String(needle)) == -1:
			return _fail("Campaign cutscene summary missing '%s'. body=%s" % [String(needle), body])
	if body.find("다음 목적지: amber bridge rendezvous.") != body.rfind("다음 목적지: amber bridge rendezvous."):
		return _fail("Campaign cutscene summary should not duplicate next destination. body=%s" % body)
	var expected_next_action := "다음 목적지: amber bridge rendezvous."
	if String(snapshot.get("recommendation", "")) != expected_next_action:
		return _fail("Campaign cutscene recommendation should use result next_action_line. snapshot=%s" % str(snapshot))
	if String(snapshot.get("flow_text", "")) != expected_next_action:
		return _fail("Campaign cutscene flow label should use result next_action_line. snapshot=%s" % str(snapshot))
	campaign.queue_free()
	panel.queue_free()
	battle.queue_free()
	await process_frame
	return true

func _assert_result_screen_story_lines() -> bool:
	var screen := BattleResultScreen.new()
	root.add_child(screen)
	screen.show_result({
		"title": "Victory",
		"post_battle_cutscene_id": "ch01_02_outro",
		"next_destination_summary": "다음 목적지: result screen ridge.",
	})
	var snapshot: Dictionary = screen.get_result_snapshot()
	var content := String(snapshot.get("content_text", ""))
	if not Array(snapshot.get("section_ids", [])).has("story"):
		return _fail("BattleResultScreen should keep Story section when handoff metadata is present. snapshot=%s" % str(snapshot))
	if content.find("ch01_02_outro") == -1 or content.find("result screen ridge") == -1:
		return _fail("BattleResultScreen Story section should render cutscene id and next destination. content=%s" % content)
	screen.queue_free()
	return true

func _assert_final_empty_clear_does_not_force_handoff() -> bool:
	var campaign := CampaignController.new()
	var final_stage := StageData.new()
	final_stage.stage_id = &"CH10_05"
	final_stage.stage_title = "Final Empty Clear"
	final_stage.clear_cutscene_id = &""
	final_stage.next_destination_summary = "다음 목적지: final resolution is owned by ending flow."
	var resolved: StringName = campaign._resolve_post_battle_cutscene_id({}, final_stage)
	if resolved != &"":
		return _fail("Final stage with empty clear_cutscene_id should not resolve a generic post-battle cutscene. resolved=%s" % String(resolved))
	var result_metadata := {"post_battle_handoff": false, "next_destination_summary": ""}
	var battle = BATTLE_SCENE.instantiate()
	battle.stage_data = final_stage
	battle._populate_post_battle_handoff_metadata(result_metadata)
	battle.free()
	if bool(result_metadata.get("post_battle_handoff", false)) or not String(result_metadata.get("post_battle_cutscene_id", "")).is_empty():
		campaign.free()
		return _fail("Final stage with empty clear_cutscene_id should not force generic battle-result handoff metadata. metadata=%s" % str(result_metadata))
	var summary := {}
	campaign._current_stage = final_stage
	campaign._build_cutscene_summary(final_stage, _make_victory_stage(&"after_final", "After Final", &"", ""), summary)
	if bool(summary.get("post_battle_handoff", false)):
		campaign.free()
		return _fail("Empty final clear_cutscene_id should not force generic handoff metadata.")
	campaign.free()
	return true

func _make_victory_stage(stage_id: StringName, title: String, clear_cutscene_id: StringName, next_summary: String) -> StageData:
	var stage := StageData.new()
	stage.stage_id = stage_id
	stage.stage_title = title
	stage.grid_size = Vector2i(3, 3)
	stage.cell_size = Vector2i(64, 64)
	stage.win_condition = &"defeat_all_enemies"
	stage.objective_text = "Verify post-battle handoff."
	stage.clear_cutscene_id = clear_cutscene_id
	stage.next_destination_summary = next_summary
	stage.ally_units = [_make_unit(&"handoff_ally", "Handoff Ally", "ally", 30, 7, 1)]
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

func _cutscene_event_count(battle, cutscene_id: StringName) -> int:
	if battle.cutscene_player == null:
		return 0
	var count := 0
	for event in battle.cutscene_player.get_event_log():
		var typed_event: Dictionary = event
		if typed_event.get("id", &"") == cutscene_id:
			count += 1
	return count

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
