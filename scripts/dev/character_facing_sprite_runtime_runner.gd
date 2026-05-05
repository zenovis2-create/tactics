extends SceneTree

const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")
const RIAN_DATA = preload("res://data/units/ally_rian.tres")
const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var flat_idle := BattleArtCatalog.load_character_sprite_frames("ally_rian", "idle")
	if flat_idle.size() != 8:
		return _fail("Rian flat idle loader should keep the 8-frame compatibility contract.")

	for facing in ["front_right", "front_left", "back_right", "back_left"]:
		var facing_idle := BattleArtCatalog.load_character_sprite_facing_frames("ally_rian", "idle", facing)
		if facing_idle.size() != 16:
			return _fail("Rian idle.%s should expose 16 facing frames, found %d." % [facing, facing_idle.size()])

	var unit = UNIT_SCENE.instantiate()
	root.add_child(unit)
	unit.setup_from_data(RIAN_DATA)
	await process_frame

	if not flat_idle.has(unit.character_sprite.texture):
		return _fail("Rian should start on flat idle frames for compatibility.")

	unit.set_grid_position(Vector2i(1, -1), Vector2i(64, 64))
	var back_right_move := BattleArtCatalog.load_character_sprite_facing_frames("ally_rian", "move", "back_right")
	if not back_right_move.has(unit.character_sprite.texture):
		return _fail("Rian movement toward back_right should switch to 16-frame back_right move sprites.")

	unit.play_attack_animation(Vector2i(0, 0), 64.0)
	var front_left_attack := BattleArtCatalog.load_character_sprite_facing_frames("ally_rian", "attack", "front_left")
	if not front_left_attack.has(unit.character_sprite.texture):
		return _fail("Rian attack toward front_left should switch to 16-frame front_left attack sprites.")

	unit.queue_free()
	await process_frame
	print("[PASS] character_facing_sprite_runtime_runner validated in-game 4-facing 16-frame sprite selection.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
