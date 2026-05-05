extends SceneTree

const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")
const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const RAIDER_DATA = preload("res://data/units/enemy_raider.tres")
const SKIRMISHER_DATA = preload("res://data/units/enemy_skirmisher.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for state in ["idle", "move", "attack", "guard"]:
		for alias in ["Raider", "enemy_raider"]:
			if not _assert_frames(alias, state, 8):
				return
		for alias in ["Skirmisher", "enemy_skirmisher"]:
			if not _assert_frames(alias, state, 8):
				return
	if not await _assert_unit_visual_layer(RAIDER_DATA, "Raider", "enemy_raider"):
		return
	if not await _assert_unit_visual_layer(SKIRMISHER_DATA, "Skirmisher", "enemy_skirmisher"):
		return
	print("[PASS] enemy_infantry_sprite_runtime_runner validated Raider/Skirmisher sprite aliases and Unit visual layers.")
	quit(0)

func _assert_frames(unit_name: String, state: String, expected_count: int) -> bool:
	var frames := BattleArtCatalog.load_character_sprite_frames(unit_name, state)
	if frames.size() != expected_count:
		return _fail("%s should resolve %d %s sprite frames, found %d." % [unit_name, expected_count, state, frames.size()])
	return true

func _assert_unit_visual_layer(unit_data: Resource, label: String, lookup_name: String) -> bool:
	var unit = UNIT_SCENE.instantiate()
	root.add_child(unit)
	unit.setup_from_data(unit_data)
	await process_frame
	var art_layer: CanvasItem = unit.get_node_or_null("CharacterVisualRoot")
	if art_layer == null:
		return _fail("%s Unit scene should expose CharacterVisualRoot layer." % label)
	if not art_layer.visible:
		return _fail("%s should show CharacterVisualRoot when sprite frames exist." % label)
	var frames := BattleArtCatalog.load_character_sprite_frames(lookup_name, "idle")
	if frames.is_empty():
		return _fail("%s should resolve idle sprite frames from %s." % [label, lookup_name])
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
