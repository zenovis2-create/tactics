extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH06_STAGE = preload("res://data/stages/ch06_05_stage.tres")
const BattleController = preload("res://scripts/battle/battle_controller.gd")
const CampaignController = preload("res://scripts/campaign/campaign_controller.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_stage_data_surface()
	if _failed:
		return

	await _assert_battle_star_progression()
	if _failed:
		return

	await _assert_campaign_progression_commit()
	if _failed:
		return

	print("[PASS] three_star_runner validated terrain feature parsing, star calculation tiers, and progression storage.")
	quit(0)

func _assert_stage_data_surface() -> void:
	_assert(CH06_STAGE.get("terrain_features") != null, "CH06_05 should expose terrain_features on StageData.")
	if _failed:
		return
	_assert(CH06_STAGE.get("optional_objectives") != null, "CH06_05 should expose optional_objectives on StageData.")
	if _failed:
		return
	var turn_limit_value: Variant = CH06_STAGE.get("turn_limit")
	_assert(int(turn_limit_value if turn_limit_value != null else 0) > 0, "CH06_05 should expose a positive turn_limit.")

func _assert_battle_star_progression() -> void:
	var clear_only: BattleController = await _make_battle()
	if _failed:
		return
	var stage_turn_limit: Variant = CH06_STAGE.get("turn_limit")
	clear_only.round_index = int(stage_turn_limit if stage_turn_limit != null else 20) + 2
	_force_resolve_all_interactions(clear_only)
	clear_only.enemy_units.clear()
	_assert(clear_only._check_battle_end(), "Forced clear-only battle should resolve victory.")
	if _failed:
		return
	await process_frame
	await process_frame
	var clear_summary: Dictionary = clear_only.get_last_result_summary()
	_assert_equal(int(clear_summary.get("stars_earned", 0)), 1, "Clear-only victory should earn 1 star.")
	clear_only.queue_free()
	await process_frame

	var turn_limit_clear: BattleController = await _make_battle()
	if _failed:
		return
	turn_limit_clear.round_index = 3
	_force_resolve_all_interactions(turn_limit_clear)
	turn_limit_clear.enemy_units.clear()
	_assert(turn_limit_clear._check_battle_end(), "Forced turn-limit battle should resolve victory.")
	if _failed:
		return
	await process_frame
	await process_frame
	var turn_limit_summary: Dictionary = turn_limit_clear.get_last_result_summary()
	_assert_equal(int(turn_limit_summary.get("stars_earned", 0)), 2, "Clear plus turn limit should earn 2 stars.")
	turn_limit_clear.queue_free()
	await process_frame

	var perfect_clear: BattleController = await _make_battle()
	if _failed:
		return
	perfect_clear.round_index = 2
	perfect_clear.battle_test_flags = {
		"valtor_civilian_escapes": true,
		"fort_resistance_zero": true
	}
	_force_resolve_all_interactions(perfect_clear)
	perfect_clear.enemy_units.clear()
	_assert(perfect_clear._check_battle_end(), "Forced perfect-clear battle should resolve victory.")
	if _failed:
		return
	await process_frame
	await process_frame
	var perfect_summary: Dictionary = perfect_clear.get_last_result_summary()
	_assert_equal(int(perfect_summary.get("stars_earned", 0)), 3, "Clear plus turn limit plus all objectives should earn 3 stars.")
	perfect_clear.queue_free()
	await process_frame

func _assert_campaign_progression_commit() -> void:
	var battle: BattleController = await _make_battle()
	if _failed:
		return
	battle.round_index = 2
	battle.battle_test_flags = {
		"valtor_civilian_escapes": true,
		"fort_resistance_zero": true
	}
	_force_resolve_all_interactions(battle)
	battle.enemy_units.clear()
	_assert(battle._check_battle_end(), "Campaign reward setup battle should resolve victory.")
	if _failed:
		return
	await process_frame
	await process_frame

	var controller := CampaignController.new()
	root.add_child(controller)
	controller._battle_controller = battle
	var progression := ProgressionData.new()
	battle.progression_service.load_data(progression)
	controller._commit_stage_rewards(CH06_STAGE)

	var stage_star_ratings_value: Variant = progression.get("stage_star_ratings")
	var stage_star_ratings: Dictionary = stage_star_ratings_value if stage_star_ratings_value is Dictionary else {}
	_assert_equal(int(stage_star_ratings.get(String(CH06_STAGE.stage_id), 0)), 3, "Campaign rewards should persist CH06_05 as a 3-star clear.")
	if _failed:
		return
	var total_stars_value: Variant = progression.get("total_stars")
	_assert_equal(int(total_stars_value if total_stars_value != null else 0), 3, "Campaign rewards should track total_stars.")

	battle.queue_free()
	controller.queue_free()
	await process_frame

func _make_battle() -> BattleController:
	var battle: BattleController = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame
	battle.set_stage(CH06_STAGE)
	await process_frame
	await process_frame
	return battle

func _force_resolve_all_interactions(battle: BattleController) -> void:
	if battle == null or battle.ally_units.is_empty():
		return
	var ally = battle.ally_units[0]
	for object_actor in battle.interactive_objects:
		if object_actor == null or not is_instance_valid(object_actor) or object_actor.is_resolved:
			continue
		battle._resolve_interaction(ally, object_actor)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_fail(message)

func _assert_equal(actual, expected, message: String) -> void:
	if actual == expected:
		return
	_fail("%s Expected %s, got %s." % [message, str(expected), str(actual)])

func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	push_error(message)
	quit(1)
