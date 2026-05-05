extends SceneTree

const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const BattleBoard = preload("res://scripts/battle/battle_board.gd")

const STORY_TILE_CARD_FILES := [
	"archives.png",
	"ash.png",
	"corridor.png",
	"flooded.png",
	"floodgate.png",
	"gate_control.png",
	"hymn.png",
	"keep.png",
	"keeper.png",
	"marked.png",
	"market.png",
	"memory_abyss.png",
	"revision.png",
	"shadow.png",
	"shrine.png",
	"thicket.png",
	"tunnel.png",
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var board := BattleBoard.new()
	root.add_child(board)
	var snapshot: Dictionary = board.get_surface_contract_snapshot()

	if float(snapshot.get("tile_card_inset", 99.0)) > 4.0:
		return _fail("BattleBoard tile card inset should be tightened so tile cards read as board surface.")
	if float(snapshot.get("tile_icon_size", 0.0)) < 18.0:
		return _fail("BattleBoard tile icon size should stay readable after surface promotion.")
	var alphas: Dictionary = snapshot.get("card_alphas", {})
	if float(alphas.get("plain", 0.0)) < 0.14:
		return _fail("Plain tile card alpha is too weak to meaningfully affect board surface.")
	if float(alphas.get("forest", 0.0)) < 0.24:
		return _fail("Forest tile card alpha is too weak to read as terrain surface.")
	if float(alphas.get("wall", 0.0)) < 0.18:
		return _fail("Wall tile card alpha is too weak to read as structure surface.")
	for file_name in STORY_TILE_CARD_FILES:
		var texture := BattleArtCatalog.load_tile_card(file_name)
		if texture == null:
			return _fail("Story runtime tile card failed to load: %s" % file_name)
		if texture.get_width() != 48 or texture.get_height() != 48:
			return _fail("Story runtime tile card should be 48x48: %s" % file_name)

	print("[PASS] battle_board_surface_runner validated promoted board-surface tile card contract.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
