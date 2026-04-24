extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var camera: Camera2D = battle.get_node_or_null("BattleCamera")
	if camera == null:
		return _fail("BattleScene should expose BattleCamera for framing control.")
	if not camera.enabled:
		return _fail("BattleCamera should be enabled.")

	var hud_snapshot: Dictionary = battle.hud.get_layout_snapshot()
	var frame_width: float = float(hud_snapshot.get("frame_width", 0.0))
	if frame_width <= 0.0:
		return _fail("BattleHUD should receive non-zero board frame metrics.")
	if float(hud_snapshot.get("top_bar_width", 0.0)) < minf(frame_width, 520.0):
		return _fail("Regular HUD top bar should feel board-anchored, not overly narrow.")
	if float(hud_snapshot.get("bottom_panel_width", 0.0)) < frame_width:
		return _fail("Bottom panel should span the board frame width.")

	print("[PASS] battle_frame_composition_runner validated board-anchored HUD composition and camera framing.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
