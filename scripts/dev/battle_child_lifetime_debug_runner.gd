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

	var board = battle.get_node_or_null("BattleBoard")
	var hud = battle.get_node_or_null("CanvasLayer/BattleHUD")
	var status_service = battle.status_service
	var telemetry_service = battle.telemetry_service
	var reward_service = battle.reward_service
	var cutscene_player = battle.cutscene_player
	var bond_service = battle.bond_service

	print("[DEBUG] before cleanup | battle=%s board=%s hud=%s status=%s telemetry=%s reward=%s cutscene=%s bond=%s" % [
		is_instance_valid(battle),
		is_instance_valid(board),
		is_instance_valid(hud),
		is_instance_valid(status_service),
		is_instance_valid(telemetry_service),
		is_instance_valid(reward_service),
		is_instance_valid(cutscene_player),
		is_instance_valid(bond_service)
	])

	battle.queue_free()
	await process_frame
	print("[DEBUG] after 1 frame | battle=%s board=%s hud=%s status=%s telemetry=%s reward=%s cutscene=%s bond=%s root_children=%d" % [
		is_instance_valid(battle),
		is_instance_valid(board),
		is_instance_valid(hud),
		is_instance_valid(status_service),
		is_instance_valid(telemetry_service),
		is_instance_valid(reward_service),
		is_instance_valid(cutscene_player),
		is_instance_valid(bond_service),
		root.get_child_count()
	])

	await process_frame
	print("[DEBUG] after 2 frames | battle=%s board=%s hud=%s status=%s telemetry=%s reward=%s cutscene=%s bond=%s root_children=%d" % [
		is_instance_valid(battle),
		is_instance_valid(board),
		is_instance_valid(hud),
		is_instance_valid(status_service),
		is_instance_valid(telemetry_service),
		is_instance_valid(reward_service),
		is_instance_valid(cutscene_player),
		is_instance_valid(bond_service),
		root.get_child_count()
	])

	print("[PASS] battle_child_lifetime_debug_runner captured post-queue_free child/service validity snapshots.")
	quit(0)
