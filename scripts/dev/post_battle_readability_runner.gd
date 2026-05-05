extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const BattleResultScreen = preload("res://scripts/battle/battle_result_screen.gd")
const CampaignController = preload("res://scripts/campaign/campaign_controller.gd")
const CampaignPanel = preload("res://scripts/campaign/campaign_panel.gd")
const CampaignState = preload("res://scripts/campaign/campaign_state.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_battle_result_optional_objective_labels():
		return
	if not _assert_result_screen_optional_objective_labels_and_legacy_fallback():
		return
	if not await _assert_campaign_handoff_compact_details():
		return
	if not await _assert_campaign_camp_growth_review_payload():
		return
	print("[PASS] post_battle_readability_runner: all assertions passed.")
	quit(0)

func _assert_battle_result_optional_objective_labels() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame
	var stage := _make_victory_stage(&"handoff_readability", "Handoff Readability")
	battle.set_stage(stage)
	await process_frame
	await process_frame
	if battle.last_result_summary.is_empty():
		if not battle._check_battle_end():
			return _fail("Battle with no enemies should end in victory for readability labels.")
		await process_frame
	var summary: Dictionary = battle.last_result_summary.duplicate(true)
	if not Array(summary.get("optional_objectives_completed", [])).has("no_ally_losses"):
		return _fail("Legacy completed optional objective id should remain. summary=%s" % str(summary))
	if not Array(summary.get("optional_objectives_failed", [])).has("secure_scout_cache"):
		return _fail("Legacy failed optional objective id should remain. summary=%s" % str(summary))
	var completed_entries: Array = summary.get("optional_objective_completed_entries", [])
	var failed_entries: Array = summary.get("optional_objective_failed_entries", [])
	if completed_entries.size() != 1 or failed_entries.size() != 1:
		return _fail("Readable optional objective entries should mirror completed/failed ids. summary=%s" % str(summary))
	var completed: Dictionary = completed_entries[0]
	var failed: Dictionary = failed_entries[0]
	if String(completed.get("description", "")).find("Keep every ally standing") == -1 or int(completed.get("star_value", 0)) != 1:
		return _fail("Completed optional objective should expose description/star_value. entry=%s" % str(completed))
	if String(failed.get("description", "")).find("Secure the scout cache") == -1 or bool(failed.get("completed", true)):
		return _fail("Failed optional objective should expose readable failed metadata. entry=%s" % str(failed))
	var before: Dictionary = battle.last_result_summary.duplicate(true)
	if not battle._check_battle_end():
		return _fail("Repeated _check_battle_end should remain terminal for readability metadata.")
	await process_frame
	if battle.last_result_summary != before:
		return _fail("Repeated _check_battle_end should not mutate readability metadata.")
	battle.queue_free()
	await process_frame
	return true

func _assert_result_screen_optional_objective_labels_and_legacy_fallback() -> bool:
	var screen := BattleResultScreen.new()
	root.add_child(screen)
	screen.show_result({
		"title": "Victory",
		"optional_objectives_completed": ["no_ally_losses"],
		"optional_objectives_failed": ["secure_scout_cache"],
		"optional_objective_completed_entries": [{"id": "no_ally_losses", "description": "Keep every ally standing", "star_value": 1, "completed": true}],
		"optional_objective_failed_entries": [{"id": "secure_scout_cache", "description": "Secure the scout cache", "star_value": 1, "completed": false}],
	})
	var snapshot: Dictionary = screen.get_result_snapshot()
	var content := String(snapshot.get("content_text", ""))
	if content.find("Keep every ally standing (+1★)") == -1 or content.find("Secure the scout cache (+1★)") == -1:
		return _fail("BattleResultScreen should prefer readable optional objective labels. content=%s" % content)
	screen.show_result({
		"title": "Victory",
		"optional_objectives_completed": ["legacy_complete_id"],
		"optional_objectives_failed": ["legacy_failed_id"],
	})
	snapshot = screen.get_result_snapshot()
	content = String(snapshot.get("content_text", ""))
	if content.find("legacy_complete_id") == -1 or content.find("legacy_failed_id") == -1:
		return _fail("BattleResultScreen should keep legacy optional objective id fallback. content=%s" % content)
	screen.queue_free()
	return true

func _assert_campaign_handoff_compact_details() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	var campaign := CampaignController.new()
	root.add_child(battle)
	root.add_child(campaign)
	await process_frame
	await process_frame
	campaign.setup(battle, null)
	var stage := _make_victory_stage(&"handoff_readability_campaign", "Handoff Readability Campaign")
	campaign._current_stage = stage
	campaign._active_stage_index = 0
	battle.last_result_summary = {
		"outcome": "victory",
		"post_battle_handoff": true,
		"post_battle_cutscene_id": "ch01_02_outro",
		"post_battle_cutscene_available": true,
		"next_destination_summary": "다음 목적지: readability bridge.",
		"quick_summary_line": "Victory — 3★ / optional 1/2",
		"next_action_line": "다음 목적지: readability bridge.",
		"stars_earned": 3,
		"optional_objectives_completed": ["no_ally_losses"],
		"optional_objectives_failed": ["secure_scout_cache"],
		"optional_objective_completed_entries": [{"id": "no_ally_losses", "description": "Keep every ally standing", "star_value": 1, "completed": true}],
		"optional_objective_failed_entries": [{"id": "secure_scout_cache", "description": "Secure the scout cache", "star_value": 1, "completed": false}],
		"reward_entries": ["1200G", "Amber Key"],
		"unit_exp_results": [
			{
				"unit_id": "readability_ally",
				"display_name": "Readability Ally",
				"level_before": 1,
				"level_after": 2,
				"exp_gain": 80,
				"leveled_up": true
			}
		],
		"bonus_exp_pool": 30,
		"bonus_exp_results": [
			{
				"unit_id": "readability_support",
				"display_name": "Readability Support",
				"exp_gain": 30
			}
		],
		"skill_exp_results": [
			{
				"unit_id": "readability_ally",
				"display_name": "Readability Ally",
				"skill_id": "readability_skill",
				"skill_name": "Readability Skill",
				"level_before": 1,
				"level_after": 1,
				"exp_gain": 15,
				"leveled_up": false
			}
		],
		"bonus_recommendation_line": "추천 보너스 대상: 뒤처진 유닛 — Readability Support",
		"treasure_entries": ["Amber Key"],
		"support_attack_count": 2,
		"support_conversations": [{"pair_label": "Rian / Serin", "rank_label": "B"}],
	}
	campaign._on_battle_finished(&"victory", stage.stage_id)
	await process_frame
	var snapshot: Dictionary = campaign.get_state_snapshot()
	if String(snapshot.get("mode", "")) != CampaignState.MODE_CUTSCENE:
		return _fail("Readable handoff should still route non-final victory to MODE_CUTSCENE. snapshot=%s" % str(snapshot))
	var body := String(snapshot.get("panel_body", ""))
	for needle in ["결과 요약: Victory — 3★ / optional 1/2", "다음 행동: 다음 목적지: readability bridge.", "길드 보고: 보상 2건 / 전투 EXP 1명 / 스킬 EXP 1건 / 보너스 EXP 30 배정", "보상 정산: 1200G, Amber Key", "보너스 EXP 배정: Readability Support +30 EXP", "스킬 EXP: Readability Ally / Readability Skill +15 EXP", "성장 확인: 추천 보너스 대상: 뒤처진 유닛 — Readability Support / 캠프에서 스킬 확인", "Keep every ally standing", "Secure the scout cache", "지원 상승: Rian / Serin / B", "Amber Key", "readability bridge"]:
		if body.find(String(needle)) == -1:
			return _fail("Campaign readable handoff missing '%s'. body=%s" % [String(needle), body])
	if body.find("다음 목적지: readability bridge.") != body.rfind("다음 목적지: readability bridge."):
		return _fail("Campaign readable handoff should not duplicate next destination. body=%s" % body)
	campaign.queue_free()
	battle.queue_free()
	await process_frame
	return true

func _assert_campaign_camp_growth_review_payload() -> bool:
	var battle = BATTLE_SCENE.instantiate()
	var campaign := CampaignController.new()
	root.add_child(battle)
	root.add_child(campaign)
	await process_frame
	await process_frame
	campaign.setup(battle, null)
	battle.last_result_summary = {
		"unit_exp_results": [{"unit_id": "readability_ally", "display_name": "Readability Ally", "exp_gain": 80}],
		"bonus_exp_pool": 30,
		"bonus_exp_results": [{"unit_id": "readability_support", "display_name": "Readability Support", "exp_gain": 30}],
		"skill_exp_results": [{"unit_id": "readability_ally", "display_name": "Readability Ally", "skill_id": "readability_skill", "skill_name": "Readability Skill", "exp_gain": 6, "leveled_up": true}],
		"bonus_recommendation_line": "추천 보너스 대상: 뒤처진 유닛 — Readability Support"
	}
	var payload: Dictionary = campaign._build_panel_payload(CampaignState.MODE_CAMP)
	var growth_lines: Array = payload.get("last_battle_growth_review_lines", [])
	for needle in ["전투 EXP: 1명 성장", "스킬 점검: Readability Ally / Readability Skill +6 EXP / 숙련 상승", "보너스 EXP: Readability Support +30 EXP", "성장 추천: 추천 보너스 대상: 뒤처진 유닛 — Readability Support"]:
		if not growth_lines.has(String(needle)):
			return _fail("Camp growth review payload missing '%s'. lines=%s" % [String(needle), str(growth_lines)])
	var badges: Dictionary = payload.get("section_badges", {})
	if String(badges.get(CampaignPanel.SECTION_SKILLS, "")) != "성장":
		return _fail("Camp growth review should badge the skills section. badges=%s" % str(badges))
	if String(payload.get("recommendation", "")).find("직전 의뢰 성장") == -1:
		return _fail("Camp recommendation should cue last request growth review. payload=%s" % str(payload))
	var skill_exp_payload: Array = payload.get("last_battle_skill_exp_results", [])
	if skill_exp_payload.size() != 1 or String(Dictionary(skill_exp_payload[0]).get("skill_id", "")) != "readability_skill":
		return _fail("Camp payload should preserve recent skill EXP entries for the skills tab. payload=%s" % str(payload))
	campaign.queue_free()
	battle.queue_free()
	await process_frame
	return true

func _make_victory_stage(stage_id: StringName, title: String) -> StageData:
	var stage := StageData.new()
	stage.stage_id = stage_id
	stage.stage_title = title
	stage.grid_size = Vector2i(3, 3)
	stage.cell_size = Vector2i(64, 64)
	stage.win_condition = &"defeat_all_enemies"
	stage.objective_text = "Verify post-battle readability labels."
	stage.clear_cutscene_id = &"ch01_02_outro"
	stage.next_destination_summary = "다음 목적지: readability bridge."
	stage.optional_objectives = [
		{"id": "no_ally_losses", "description": "Keep every ally standing", "condition": "no_ally_casualties", "star_value": 1},
		{"id": "secure_scout_cache", "description": "Secure the scout cache", "condition": "flag:secure_scout_cache", "star_value": 1},
	]
	stage.ally_units = [_make_unit(&"readability_ally", "Readability Ally", "ally", 30, 7, 1)]
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

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
