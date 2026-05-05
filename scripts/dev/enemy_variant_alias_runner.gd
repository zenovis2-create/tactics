extends SceneTree

const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")
const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")

const VARIANTS := [
	{
		"label": "Saria II",
		"data": preload("res://data/units/enemy_saria_2.tres"),
		"lookup": "enemy_saria_2",
		"aliases": ["enemy_saria_2", "Saria II"],
	},
	{
		"label": "Valgar II",
		"data": preload("res://data/units/enemy_valgar_2.tres"),
		"lookup": "enemy_valgar_2",
		"aliases": ["enemy_valgar_2", "Valgar II"],
	},
	{
		"label": "Karuon Variant",
		"data": preload("res://data/units/enemy_karon_1.tres"),
		"lookup": "enemy_karon_1",
		"aliases": ["enemy_karon_1"],
	},
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for variant in VARIANTS:
		for alias in variant["aliases"]:
			for state in ["idle", "move", "attack"]:
				var frames := BattleArtCatalog.load_character_sprite_frames(String(alias), state)
				if frames.size() != 8:
					return _fail("%s should resolve 8 %s frames through %s, found %d." % [variant["label"], state, alias, frames.size()])
		if not await _assert_unit_visual_layer(variant):
			return

	print("[PASS] enemy_variant_alias_runner validated fallback-safe Saria II/Valgar II/Karuon variant art aliases.")
	quit(0)


func _assert_unit_visual_layer(variant: Dictionary) -> bool:
	var unit = UNIT_SCENE.instantiate()
	root.add_child(unit)
	unit.setup_from_data(variant["data"])
	await process_frame

	var art_layer: CanvasItem = unit.get_node_or_null("CharacterVisualRoot")
	if art_layer == null:
		return _fail("%s Unit scene should expose CharacterVisualRoot layer." % variant["label"])
	if not art_layer.visible:
		return _fail("%s should show CharacterVisualRoot through explicit variant alias." % variant["label"])
	var frames := BattleArtCatalog.load_character_sprite_frames(String(variant["lookup"]), "idle")
	if not frames.has(unit.character_sprite.texture):
		return _fail("%s should render a catalog idle sprite frame." % variant["label"])
	if unit.token_art.visible:
		return _fail("%s should hide token art when sprite frames exist." % variant["label"])

	unit.queue_free()
	await process_frame
	return true


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
