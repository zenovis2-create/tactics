extends SceneTree

const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_assert_tile_directory("res://assets/ui/production/tile_cards", true)
	_assert_tile_directory("res://assets/ui/production/tile_icons", false)
	_assert_object_icon("command_obelisk.png")

	print("[PASS] ui_production_surface_runtime_runner validated production UI surface runtime loading.")
	quit(0)

func _assert_tile_directory(path: String, is_card: bool) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return _fail("%s is missing." % path)

	var expected := Vector2i(48, 48) if is_card else Vector2i(24, 24)
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name.is_empty():
			break
		if dir.current_is_dir() or not file_name.ends_with(".png"):
			continue

		var texture := BattleArtCatalog.load_tile_card(file_name) if is_card else BattleArtCatalog.load_tile_icon(file_name)
		_assert_texture_size("%s/%s" % [path, file_name], texture, expected)
	dir.list_dir_end()

func _assert_object_icon(file_name: String) -> void:
	var texture := BattleArtCatalog.load_object_icon(file_name)
	if texture == null:
		return _fail("%s should load through BattleArtCatalog." % file_name)

	var size := Vector2i(texture.get_width(), texture.get_height())
	if size != Vector2i(40, 40) and size != Vector2i(256, 256):
		return _fail("%s expected 40x40 or 256x256, got %s." % [file_name, size])

func _assert_texture_size(label: String, texture: Texture2D, expected: Vector2i) -> void:
	if texture == null:
		return _fail("%s is missing." % label)

	var actual := Vector2i(texture.get_width(), texture.get_height())
	if actual != expected:
		return _fail("%s expected %s, got %s." % [label, expected, actual])

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
