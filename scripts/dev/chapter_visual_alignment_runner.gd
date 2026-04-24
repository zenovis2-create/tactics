extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH03_PREVIEW: PackedScene = preload("res://scenes/dev/CH03ForestTrapPreview.tscn")
const CH02_PREVIEW: PackedScene = preload("res://scenes/dev/CH02FortressArtPreview.tscn")
const CH07_PREVIEW: PackedScene = preload("res://scenes/dev/CH07RitualCityPreview.tscn")
const CH09B_PREVIEW: PackedScene = preload("res://scenes/dev/CH09BRootArchivePreview.tscn")
const CH10_PREVIEW: PackedScene = preload("res://scenes/dev/CH10FinalBellPreview.tscn")
const CH03_STAGE = preload("res://data/stages/ch03_01_stage.tres")
const CH06_STAGE = preload("res://data/stages/ch06_02_stage.tres")
const CH07_STAGE = preload("res://data/stages/ch07_01_stage.tres")
const CH09B_STAGE = preload("res://data/stages/ch09b_01_stage.tres")
const CH10_STAGE = preload("res://data/stages/ch10_01_stage.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_family_alignment(CH03_PREVIEW, CH03_STAGE, "forest"):
		return
	if not await _assert_family_alignment(CH02_PREVIEW, CH06_STAGE, "fortress"):
		return
	if not await _assert_family_alignment(CH07_PREVIEW, CH07_STAGE, "city"):
		return
	if not await _assert_family_alignment(CH09B_PREVIEW, CH09B_STAGE, "archive"):
		return
	if not await _assert_family_alignment(CH10_PREVIEW, CH10_STAGE, "final_bell"):
		return
	print("[PASS] chapter_visual_alignment_runner validated preview-to-battle family alignment.")
	quit(0)

func _assert_family_alignment(preview_scene: PackedScene, stage_data, expected_family: String) -> bool:
	var preview := preview_scene.instantiate()
	root.add_child(preview)
	await process_frame
	await process_frame

	var ground_root := preview.get_node_or_null("GroundRoot")
	var prop_root := preview.get_node_or_null("PropRoot")
	var character_root := preview.get_node_or_null("CharacterRoot")
	if ground_root == null or prop_root == null or character_root == null:
		return _fail("Preview scene should expose GroundRoot, PropRoot, and CharacterRoot for %s family." % expected_family)
	if ground_root.get_child_count() <= 0:
		return _fail("Preview scene should contain ground sprites for %s family." % expected_family)
	if character_root.get_child_count() <= 0:
		return _fail("Preview scene should contain character sprites for %s family." % expected_family)

	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	battle.set_stage(stage_data)
	await process_frame
	await process_frame

	var snapshot: Dictionary = battle.battle_board.get_surface_contract_snapshot()
	if String(snapshot.get("surface_family", "")) != expected_family:
		return _fail("Battle board family drifted. expected=%s actual=%s" % [expected_family, String(snapshot.get("surface_family", ""))])

	preview.queue_free()
	battle.queue_free()
	await process_frame
	return true

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
