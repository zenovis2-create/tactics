extends SceneTree

const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_assert_texture_size("forest tile card", BattleArtCatalog.load_tile_card("forest.png"), Vector2i(48, 48))
	_assert_texture_size("forest tile icon", BattleArtCatalog.load_tile_icon("forest.png"), Vector2i(24, 24))
	_assert_texture_size("wall tile card", BattleArtCatalog.load_tile_card("wall.png"), Vector2i(48, 48))
	_assert_texture_size("wall tile icon", BattleArtCatalog.load_tile_icon("wall.png"), Vector2i(24, 24))

	print("[PASS] imagegen_tile_surface_runtime_runner validated production tile surface texture sizes.")
	quit(0)

func _assert_texture_size(label: String, texture: Texture2D, expected: Vector2i) -> void:
	if texture == null:
		return _fail("%s is missing." % label)

	var actual := Vector2i(texture.get_width(), texture.get_height())
	if actual != expected:
		return _fail("%s expected %s, got %s." % [label, expected, actual])

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
