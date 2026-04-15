class_name BattleArtCatalog
extends RefCounted

static var _cache: Dictionary = {}

static func load_button_icon(file_name: String) -> Texture2D:
	return _load_preferred_texture(
		[
			"assets/ui/production/button_icons/",
			"assets/ui/icons_generated/"
		],
		file_name
	)

static func load_object_icon(file_name: String) -> Texture2D:
	return _load_preferred_texture(
		[
			"assets/ui/production/object_icons/",
			"assets/ui/object_icons_generated/"
		],
		file_name
	)

static func load_role_icon(file_name: String) -> Texture2D:
	return _load_preferred_texture(
		[
			"assets/ui/production/unit_role_icons/",
			"assets/ui/unit_role_icons_generated/"
		],
		file_name
	)

static func load_token_art(file_name: String) -> Texture2D:
	return _load_preferred_texture(
		[
			"assets/ui/production/unit_token_art/",
			"assets/ui/unit_token_art_generated/"
		],
		file_name
	)

static func load_tile_icon(file_name: String) -> Texture2D:
	return _load_preferred_texture(
		[
			"assets/ui/production/tile_icons/",
			"assets/ui/tile_icons_generated/"
		],
		file_name
	)

static func load_tile_card(file_name: String) -> Texture2D:
	return _load_preferred_texture(
		[
			"assets/ui/production/tile_cards/",
			"assets/ui/tile_cards_generated/"
		],
		file_name
	)

static func load_fx(file_name: String) -> Texture2D:
	return _load_preferred_texture(
		[
			"assets/ui/production/fx/",
			"assets/ui/fx_generated/"
		],
		file_name
	)

static func _load_preferred_texture(dir_paths: Array[String], file_name: String) -> Texture2D:
	if file_name.is_empty():
		return null

	for dir_path in dir_paths:
		var cache_key := "%s|%s" % [dir_path, file_name]
		if _cache.has(cache_key):
			return _cache[cache_key]

		var resource_path := "res://" + dir_path + file_name
		var absolute_path: String = ProjectSettings.globalize_path(resource_path)
		if not FileAccess.file_exists(absolute_path):
			continue

		var image := Image.new()
		if image.load(absolute_path) != OK:
			continue

		var texture: Texture2D = ImageTexture.create_from_image(image)
		_cache[cache_key] = texture
		return texture

	return null
