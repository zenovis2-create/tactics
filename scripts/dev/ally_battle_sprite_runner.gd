extends SceneTree

const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")
const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const RIAN_DATA = preload("res://data/units/ally_rian.tres")
const SERIN_DATA = preload("res://data/units/ally_serin.tres")
const TIA_DATA = preload("res://data/units/ally_tia.tres")
const BRAN_DATA = preload("res://data/units/ally_bran.tres")
const VANGUARD_DATA = preload("res://data/units/ally_vanguard.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if not _assert_sprite_frames(RIAN_DATA, "idle"):
		return
	if not _assert_sprite_frames(SERIN_DATA, "idle"):
		return
	if not _assert_sprite_frames(TIA_DATA, "idle"):
		return
	if not _assert_sprite_frames(BRAN_DATA, "idle"):
		return
	if not _assert_sprite_frames(VANGUARD_DATA, "idle"):
		return
	if not await _assert_move_state_transition():
		return
	print("[PASS] ally_battle_sprite_runner validated ally sprite-first frame resolution.")
	quit(0)

func _assert_sprite_frames(unit_data, state: String) -> bool:
	var frames = BattleArtCatalog.load_character_sprite_frames(String(unit_data.display_name), state)
	if frames.is_empty():
		return _fail("%s should resolve non-empty %s sprite frames." % [String(unit_data.display_name), state])
	return true

func _assert_move_state_transition() -> bool:
	var unit = UNIT_SCENE.instantiate()
	root.add_child(unit)
	unit.setup_from_data(RIAN_DATA)
	await process_frame
	unit.set_grid_position(Vector2i(2, 1))
	if unit.character_animation_player.current_animation != "move":
		return _fail("Rian should enter move animation when grid position changes.")
	await create_timer(0.20).timeout
	if unit.character_animation_player.current_animation != "idle":
		return _fail("Rian should return to idle after move visual completes.")
	unit.queue_free()
	await process_frame
	return true

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
