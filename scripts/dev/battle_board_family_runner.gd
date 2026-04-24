extends SceneTree

const BattleBoard = preload("res://scripts/battle/battle_board.gd")
const CH03_STAGE = preload("res://data/stages/ch03_01_stage.tres")
const CH06_STAGE = preload("res://data/stages/ch06_02_stage.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var board := BattleBoard.new()
	root.add_child(board)

	board.set_stage(CH03_STAGE)
	var forest_snapshot: Dictionary = board.get_surface_contract_snapshot()
	if String(forest_snapshot.get("surface_family", "")) != "forest":
		return _fail("CH03 board should classify as forest surface family.")

	board.set_stage(CH06_STAGE)
	var fortress_snapshot: Dictionary = board.get_surface_contract_snapshot()
	if String(fortress_snapshot.get("surface_family", "")) != "fortress":
		return _fail("CH06 board should classify as fortress surface family.")

	print("[PASS] battle_board_family_runner validated forest vs fortress board-family routing.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
