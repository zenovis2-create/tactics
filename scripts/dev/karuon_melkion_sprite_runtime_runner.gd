extends SceneTree

const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")
const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")
const KARUON_DATA = preload("res://data/units/enemy_karuon.tres")
const KARUON_FINAL_DATA = preload("res://data/units/enemy_karuon_final.tres")
const MELKION_ALLY_DATA = preload("res://data/units/ally_melkion_ally.tres")
const MELKION_ENEMY_DATA = preload("res://data/units/enemy_melkion_ch09b_05.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for state in ["idle", "move", "attack", "guard"]:
		for alias in ["Karuon", "enemy_karuon", "enemy_karuon_final", "enemy_karon", "enemy_karon_final"]:
			if not _assert_frames(alias, state, 8):
				return
		for alias in ["ally_melkion_ally", "melkion_ally"]:
			if not _assert_frames(alias, state, 8):
				return
	if BattleArtCatalog.load_character_sprite_frames("Melkion", "idle").size() != 0:
		return _fail("Melkion display name should remain unmapped because ally/enemy Melkion share the same label.")
	if not await _assert_unit_visual_layer(KARUON_DATA, "Karuon", "Karuon"):
		return
	if not await _assert_unit_visual_layer(KARUON_FINAL_DATA, "Final Karuon", "Karuon"):
		return
	if not await _assert_unit_visual_layer(MELKION_ALLY_DATA, "Ally Melkion", "ally_melkion_ally"):
		return
	if not await _assert_enemy_melkion_keeps_fallback():
		return
	print("[PASS] karuon_melkion_sprite_runtime_runner validated Karuon/Melkion sprite aliases and Unit visual layers.")
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

func _assert_enemy_melkion_keeps_fallback() -> bool:
	var unit = UNIT_SCENE.instantiate()
	root.add_child(unit)
	unit.setup_from_data(MELKION_ENEMY_DATA)
	await process_frame
	var art_layer: CanvasItem = unit.get_node_or_null("CharacterVisualRoot")
	if art_layer == null:
		return _fail("Enemy Melkion Unit scene should expose CharacterVisualRoot layer.")
	if art_layer.visible:
		return _fail("Enemy Melkion should not consume ally_melkion_ally sprites through shared display_name Melkion.")
	if not unit.token_art.visible:
		return _fail("Enemy Melkion should keep generic token art visible until an enemy-specific sprite anchor exists.")
	unit.queue_free()
	await process_frame
	return true

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
