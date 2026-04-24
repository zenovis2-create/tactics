extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH01_STAGE: StageData = preload("res://data/stages/ch01_05_stage.tres")
const StageData = preload("res://scripts/data/stage_data.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var stage: StageData = CH01_STAGE.duplicate(true)
	stage.stage_objective_hint = "기본 전장 힌트"
	stage.secret_hint_contract = {
		"hint_id": &"well_clue",
		"reward_category": "memory",
		"reveal_rules": [
			{
				"trigger": "scout",
				"unit_ids": PackedStringArray(["ally_scout"]),
				"level": 1,
				"preview": "Scout Trace",
				"text": "정찰병이 무너진 우물의 발자국을 읽었다."
			},
			{
				"trigger": "proximity",
				"cells": [Vector2i(3, 2)],
				"radius": 1,
				"level": 2,
				"preview": "Ruined Well",
				"text": "우물 곁 돌틈에 가려진 기록판이 있다."
			},
			{
				"trigger": "turn_cadence",
				"round": 2,
				"level": 3,
				"text": "시간이 지날수록 북쪽 잿빛 길이 더 선명해진다."
			}
		]
	}
	battle.set_stage(stage)
	await process_frame
	await process_frame

	var scout = battle.ally_units[1]
	if scout == null or not is_instance_valid(scout):
		return _fail("Expected ally_scout in duplicated CH01_05 stage.")

	var progression_data: ProgressionData = battle.progression_service.get_data()
	if progression_data == null:
		return _fail("Battle should expose progression data for hint persistence.")

	if progression_data.get_hint_reveal_level(stage.stage_id, &"well_clue") < 1:
		battle._select_unit(scout)
		await process_frame
	if progression_data.get_hint_reveal_level(stage.stage_id, &"well_clue") != 1:
		return _fail("Scout trigger should reveal level 1.")
	if battle.hud.objective_hint_label.text.find("정찰병이 무너진 우물의 발자국을 읽었다.") == -1:
		return _fail("Objective hint surface should append scout reveal text.")

	scout.set_grid_position(Vector2i(3, 2), stage.cell_size)
	battle._evaluate_secret_hint_reveals("proximity", scout)
	await process_frame
	if progression_data.get_hint_reveal_level(stage.stage_id, &"well_clue") != 2:
		return _fail("Proximity trigger should reveal level 2.")
	if battle.hud.objective_hint_label.text.find("우물 곁 돌틈에 가려진 기록판이 있다.") == -1:
		return _fail("Objective hint surface should append proximity reveal text.")

	battle.round_index = 2
	battle._evaluate_secret_hint_reveals("turn_cadence")
	await process_frame
	if progression_data.get_hint_reveal_level(stage.stage_id, &"well_clue") != 3:
		return _fail("Turn cadence trigger should reveal level 3.")
	if battle.hud.objective_hint_label.text.find("시간이 지날수록 북쪽 잿빛 길이 더 선명해진다.") == -1:
		return _fail("Objective hint surface should append turn cadence reveal text.")

	var hint_snapshot: Dictionary = battle.get_secret_hint_snapshot()
	if int(hint_snapshot.get("level", 0)) != 3:
		return _fail("Secret hint snapshot should expose final reveal level.")
	if Array(hint_snapshot.get("revealed_lines", [])).size() != 3:
		return _fail("Secret hint snapshot should expose all revealed lines.")

	print("[PASS] A8 secret hint runner: scout/proximity/turn cadence reveals persist and surface correctly.")
	quit(0)

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
