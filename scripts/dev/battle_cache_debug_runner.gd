extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CH07_MARKET = preload("res://data/stages/ch07_01_stage.tres")
const CH08_VANISHED_TRAIL = preload("res://data/stages/ch08_01_stage.tres")
const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const TelegraphTextureLibrary = preload("res://scripts/battle/telegraph_texture_library.gd")

const CASES := [
	{"label": "CH07_01", "stage": CH07_MARKET},
	{"label": "CH08_01", "stage": CH08_VANISHED_TRAIL},
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("[DEBUG] initial static caches | battle_art=%d telegraph=%d" % [
		Dictionary(BattleArtCatalog._cache).size(),
		Dictionary(TelegraphTextureLibrary._cache).size()
	])

	for case_data in CASES:
		await _run_case(case_data)

	print("[DEBUG] final static caches | battle_art=%d telegraph=%d" % [
		Dictionary(BattleArtCatalog._cache).size(),
		Dictionary(TelegraphTextureLibrary._cache).size()
	])

	print("[PASS] battle_cache_debug_runner captured cache sizes across repeated battle-scene churn.")
	quit(0)

func _run_case(case_data: Dictionary) -> void:
	var battle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	battle.set_stage(case_data["stage"])

	await process_frame
	await process_frame

	var board = battle.get_node_or_null("BattleBoard")
	print("[DEBUG] %s live caches | battle_art=%d telegraph=%d board_icons=%d board_cards=%d controller_fx=%d" % [
		String(case_data["label"]),
		Dictionary(BattleArtCatalog._cache).size(),
		Dictionary(TelegraphTextureLibrary._cache).size(),
		0 if board == null else int(Dictionary(board._tile_icon_cache).size()),
		0 if board == null else int(Dictionary(board._tile_card_cache).size()),
		int(Dictionary(battle._fx_cache).size())
	])

	battle.queue_free()
	await process_frame
	await process_frame

	print("[DEBUG] %s post-cleanup static caches | battle_art=%d telegraph=%d" % [
		String(case_data["label"]),
		Dictionary(BattleArtCatalog._cache).size(),
		Dictionary(TelegraphTextureLibrary._cache).size()
	])
