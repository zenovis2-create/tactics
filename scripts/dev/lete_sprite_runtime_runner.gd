extends SceneTree

const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")
const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const LETE_DATA = preload("res://data/units/ally_lete.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for state in ["idle", "move", "attack", "guard"]:
		for alias in ["Lete", "ally_lete"]:
			if not _assert_frames(alias, state, 8):
				return
		if not _assert_frames("enemy_lete", state, 8):
			return
	if not await _assert_unit_visual_layer():
		return
	print("[PASS] lete_sprite_runtime_runner validated Lete sprite catalog aliases and Unit visual layer.")
	quit(0)

func _assert_frames(unit_name: String, state: String, expected_count: int) -> bool:
	var frames := BattleArtCatalog.load_character_sprite_frames(unit_name, state)
	if frames.size() != expected_count:
		return _fail("%s should resolve %d %s sprite frames, found %d." % [unit_name, expected_count, state, frames.size()])
	return true

func _assert_unit_visual_layer() -> bool:
	var unit = UNIT_SCENE.instantiate()
	root.add_child(unit)
	unit.setup_from_data(LETE_DATA)
	await process_frame
	var art_layer: CanvasItem = unit.get_node_or_null("CharacterVisualRoot")
	if art_layer == null:
		return _fail("Unit scene should expose CharacterVisualRoot layer.")
	if not art_layer.visible:
		return _fail("Lete should show CharacterVisualRoot when sprite frames exist.")
	var frames := BattleArtCatalog.load_character_sprite_frames(String(LETE_DATA.display_name), "idle")
	if frames.is_empty():
		return _fail("Lete should resolve idle sprite frames from display name.")
	if unit.character_sprite.texture != frames[0]:
		return _fail("Lete should render the first idle sprite frame instead of token art.")
	if unit.token_art.visible:
		return _fail("Lete should hide generic token art when character sprites exist.")
	unit.queue_free()
	await process_frame
	return true

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
