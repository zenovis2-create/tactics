extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const STAGE_CASES := [
	{"stage": preload("res://data/stages/ch03_01_stage.tres"), "surface": "forest", "backdrop": "forest"},
	{"stage": preload("res://data/stages/ch06_02_stage.tres"), "surface": "fortress", "backdrop": "fortress"},
	{"stage": preload("res://data/stages/ch07_01_stage.tres"), "surface": "city", "backdrop": "city"},
	{"stage": preload("res://data/stages/ch09b_01_stage.tres"), "surface": "archive", "backdrop": "archive"},
	{"stage": preload("res://data/stages/ch10_01_stage.tres"), "surface": "final_bell", "backdrop": "final_bell"},
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for entry in STAGE_CASES:
		if not await _assert_battle_visual_case(entry):
			return
	print("[PASS] battle_visual_qa_runner validated live chapter battle visual contracts.")
	quit(0)

func _assert_battle_visual_case(entry: Dictionary) -> bool:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	battle.set_stage(entry["stage"])
	await process_frame
	await process_frame

	var board_snapshot: Dictionary = battle.battle_board.get_surface_contract_snapshot()
	if String(board_snapshot.get("surface_family", "")) != String(entry["surface"]):
		return _fail("Surface family mismatch for %s." % String(entry["stage"].stage_id))
	if String(board_snapshot.get("backdrop_family", "")) != String(entry["backdrop"]):
		return _fail("Backdrop family mismatch for %s." % String(entry["stage"].stage_id))

	var hud_snapshot: Dictionary = battle.hud.get_layout_snapshot()
	if float(hud_snapshot.get("frame_width", 0.0)) <= 0.0:
		return _fail("HUD frame width missing for %s." % String(entry["stage"].stage_id))
	if float(hud_snapshot.get("bottom_panel_width", 0.0)) < float(hud_snapshot.get("frame_width", 0.0)):
		return _fail("Bottom panel should span board width for %s." % String(entry["stage"].stage_id))

	var visible_sprite_units := 0
	for unit in battle.ally_units + battle.enemy_units:
		if unit != null and is_instance_valid(unit) and unit.character_visual_root != null and unit.character_visual_root.visible:
			visible_sprite_units += 1
	if visible_sprite_units < 2:
		return _fail("Expected at least two sprite-visible units in %s." % String(entry["stage"].stage_id))

	var camera: Camera2D = battle.get_node_or_null("BattleCamera")
	if camera == null or not camera.enabled:
		return _fail("BattleCamera should be active for %s." % String(entry["stage"].stage_id))

	if battle.effects_root == null:
		return _fail("Effects root missing for %s." % String(entry["stage"].stage_id))

	battle.queue_free()
	await process_frame
	return true

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
