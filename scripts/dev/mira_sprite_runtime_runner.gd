extends SceneTree

const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")
const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const MIRA_DATA = preload("res://data/units/ally_mira.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for state in ["idle", "move", "attack", "guard"]:
		if not _assert_frames("Mira", state, 8):
			return
		if not _assert_frames("ally_mira", state, 8):
			return
	if not await _assert_unit_visual_layer():
		return
	print("[PASS] mira_sprite_runtime_runner validated Mira sprite catalog aliases and Unit visual layer.")
	quit(0)

func _assert_frames(unit_name: String, state: String, expected_count: int) -> bool:
	var frames := BattleArtCatalog.load_character_sprite_frames(unit_name, state)
	if frames.size() != expected_count:
		return _fail("%s should resolve %d %s sprite frames, found %d." % [unit_name, expected_count, state, frames.size()])
	return true

func _assert_unit_visual_layer() -> bool:
	var unit = UNIT_SCENE.instantiate()
	root.add_child(unit)
	unit.setup_from_data(MIRA_DATA)
	await process_frame
	var art_layer: CanvasItem = unit.get_node_or_null("CharacterVisualRoot")
	if art_layer == null:
		return _fail("Unit scene should expose CharacterVisualRoot layer.")
	if not art_layer.visible:
		return _fail("Mira should show CharacterVisualRoot when sprite frames exist.")
	var frames := BattleArtCatalog.load_character_sprite_frames(String(MIRA_DATA.display_name), "idle")
	if frames.is_empty():
		return _fail("Mira should resolve idle sprite frames from display name.")
	if unit.character_sprite.texture != frames[0]:
		return _fail("Mira should render the first idle sprite frame instead of token art.")
	if unit.token_art.visible:
		return _fail("Mira should hide generic token art when character sprites exist.")
	unit.queue_free()
	await process_frame
	return true

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
