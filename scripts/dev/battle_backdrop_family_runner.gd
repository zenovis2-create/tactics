extends SceneTree

const BattleBoard = preload("res://scripts/battle/battle_board.gd")
const CH03_STAGE = preload("res://data/stages/ch03_01_stage.tres")
const CH06_STAGE = preload("res://data/stages/ch06_02_stage.tres")
const CH07_STAGE = preload("res://data/stages/ch07_01_stage.tres")
const CH09B_STAGE = preload("res://data/stages/ch09b_01_stage.tres")
const CH10_STAGE = preload("res://data/stages/ch10_01_stage.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var board := BattleBoard.new()
	root.add_child(board)

	board.set_stage(CH03_STAGE)
	var forest_snapshot: Dictionary = board.get_surface_contract_snapshot()
	if String(forest_snapshot.get("backdrop_family", "")) != "forest":
		return _fail("CH03 backdrop should classify as forest family.")
	if float(forest_snapshot.get("backdrop_density", 0.0)) < 0.55:
		return _fail("CH03 forest backdrop density is too weak to read as actual field scenery.")

	board.set_stage(CH06_STAGE)
	var fortress_snapshot: Dictionary = board.get_surface_contract_snapshot()
	if String(fortress_snapshot.get("backdrop_family", "")) != "fortress":
		return _fail("CH06 backdrop should classify as fortress family.")
	if float(fortress_snapshot.get("backdrop_density", 0.0)) < 0.55:
		return _fail("CH06 fortress backdrop density is too weak to read as actual built environment.")

	board.set_stage(CH07_STAGE)
	var city_snapshot: Dictionary = board.get_surface_contract_snapshot()
	if String(city_snapshot.get("backdrop_family", "")) != "city":
		return _fail("CH07 backdrop should classify as city family.")
	if float(city_snapshot.get("backdrop_density", 0.0)) < 0.55:
		return _fail("CH07 city backdrop density is too weak to read as civic skyline.")

	board.set_stage(CH09B_STAGE)
	var archive_snapshot: Dictionary = board.get_surface_contract_snapshot()
	if String(archive_snapshot.get("backdrop_family", "")) != "archive":
		return _fail("CH09B backdrop should classify as archive family.")
	if float(archive_snapshot.get("backdrop_density", 0.0)) < 0.55:
		return _fail("CH09B archive backdrop density is too weak to read as shelving depth.")

	board.set_stage(CH10_STAGE)
	var bell_snapshot: Dictionary = board.get_surface_contract_snapshot()
	if String(bell_snapshot.get("backdrop_family", "")) != "final_bell":
		return _fail("CH10 backdrop should classify as final_bell family.")
	if float(bell_snapshot.get("backdrop_density", 0.0)) < 0.55:
		return _fail("CH10 final-bell backdrop density is too weak to read as terminal landmark space.")

	print("[PASS] battle_backdrop_family_runner validated backdrop family classification and density.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
