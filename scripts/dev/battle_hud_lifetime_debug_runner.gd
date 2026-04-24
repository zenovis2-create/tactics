extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH07_MARKET = preload("res://data/stages/ch07_01_stage.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	battle.set_stage(CH07_MARKET)

	await process_frame
	await process_frame

	var hud = battle.get_node_or_null("CanvasLayer/BattleHUD")
	if hud == null:
		push_error("Battle HUD lifetime debug runner could not find BattleHUD.")
		quit(1)
		return

	var result_snapshot: Dictionary = hud.get_result_snapshot()
	print("[DEBUG] before cleanup | hud_valid=%s result_visible=%s title=%s body_len=%d root_children=%d" % [
		is_instance_valid(hud),
		bool(result_snapshot.get("visible", false)),
		String(result_snapshot.get("title", "")),
		String(result_snapshot.get("body", "")).length(),
		root.get_child_count()
	])

	battle.queue_free()
	await process_frame
	print("[DEBUG] after 1 frame | hud_valid=%s root_children=%d" % [
		is_instance_valid(hud),
		root.get_child_count()
	])

	await process_frame
	print("[DEBUG] after 2 frames | hud_valid=%s root_children=%d" % [
		is_instance_valid(hud),
		root.get_child_count()
	])

	print("[PASS] battle_hud_lifetime_debug_runner captured HUD lifetime around cleanup.")
	quit(0)
