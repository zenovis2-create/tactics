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
	if board == null:
		push_error("Battle board cache debug runner could not find BattleBoard.")
		quit(1)
		return

	print("[DEBUG] before cleanup | board_valid=%s tile_icons=%d tile_cards=%d root_children=%d" % [
		is_instance_valid(board),
		int(Dictionary(board._tile_icon_cache).size()),
		int(Dictionary(board._tile_card_cache).size()),
		root.get_child_count()
	])

	battle.queue_free()
	await process_frame
	print("[DEBUG] after 1 frame | board_valid=%s root_children=%d" % [
		is_instance_valid(board),
		root.get_child_count()
	])

	await process_frame
	print("[DEBUG] after 2 frames | board_valid=%s root_children=%d" % [
		is_instance_valid(board),
		root.get_child_count()
	])

	print("[PASS] battle_board_cache_lifetime_debug_runner captured board cache lifetime around cleanup.")
	quit(0)
