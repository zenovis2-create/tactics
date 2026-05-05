extends SceneTree

const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")
const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const VANGUARD_DATA = preload("res://data/units/ally_vanguard.tres")
const SARIA_DATA = preload("res://data/units/enemy_saria.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for state in ["idle", "move", "attack", "guard"]:
		for alias in ["Vanguard", "ally_vanguard"]:
			if not _assert_frames(alias, state, 8):
				return
		for alias in ["Saria", "enemy_saria"]:
			if not _assert_frames(alias, state, 8):
				return
	if not await _assert_unit_visual_layer(VANGUARD_DATA, "Vanguard"):
		return
	if not await _assert_unit_visual_layer(SARIA_DATA, "Saria"):
		return
	print("[PASS] vanguard_saria_sprite_runtime_runner validated Vanguard/Saria sprite catalog aliases and Unit visual layers.")
	quit(0)

func _assert_frames(unit_name: String, state: String, expected_count: int) -> bool:
	var frames := BattleArtCatalog.load_character_sprite_frames(unit_name, state)
	if frames.size() != expected_count:
		return _fail("%s should resolve %d %s sprite frames, found %d." % [unit_name, expected_count, state, frames.size()])
	return true

func _assert_unit_visual_layer(unit_data: Resource, label: String) -> bool:
	var unit = UNIT_SCENE.instantiate()
	root.add_child(unit)
	unit.setup_from_data(unit_data)
	await process_frame
	var art_layer: CanvasItem = unit.get_node_or_null("CharacterVisualRoot")
	if art_layer == null:
		return _fail("%s Unit scene should expose CharacterVisualRoot layer." % label)
	if not art_layer.visible:
		return _fail("%s should show CharacterVisualRoot when sprite frames exist." % label)
	var frames := BattleArtCatalog.load_character_sprite_frames(String(unit_data.display_name), "idle")
	if frames.is_empty():
		return _fail("%s should resolve idle sprite frames from display name." % label)
	if not frames.has(unit.character_sprite.texture):
		return _fail("%s should render an idle sprite frame instead of token art." % label)
	if unit.token_art.visible:
		return _fail("%s should hide generic token art when character sprites exist." % label)
	unit.queue_free()
	await process_frame
	return true

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
