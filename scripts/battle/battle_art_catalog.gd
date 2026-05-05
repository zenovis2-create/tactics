class_name BattleArtCatalog
extends RefCounted

static var _cache: Dictionary = {}
static var _ally_sprite_anchor_map := {
	"Rian": "sprite_anchor_rian",
	"Serin": "sprite_anchor_serin",
	"Tia": "sprite_anchor_tia",
	"Bran": "sprite_anchor_bran",
	"Mira": "sprite_anchor_mira",
	"ally_mira": "sprite_anchor_mira",
	"Lete": "sprite_anchor_lete",
	"ally_lete": "sprite_anchor_lete",
	"enemy_lete": "sprite_anchor_lete",
	"Vanguard": "sprite_anchor_vanguard",
	"ally_vanguard": "sprite_anchor_vanguard",
	"Scout": "sprite_anchor_scout",
	"ally_scout": "sprite_anchor_scout",
	"Saria": "sprite_anchor_enemy_saria",
	"enemy_saria": "sprite_anchor_enemy_saria",
	"Raider": "sprite_anchor_enemy_raider",
	"Skirmisher": "sprite_anchor_enemy_skirmisher",
}

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

static func load_character_token_art(file_name: String) -> Texture2D:
	return _load_preferred_texture(
		[
			"assets/ui/production/character_token_art/"
		],
		file_name
	)

static func load_character_sprite_frames(unit_name: String, state: String) -> Array[Texture2D]:
	var anchor_dir: String = _ally_sprite_anchor_map.get(unit_name, "")
	if anchor_dir.is_empty() or state.is_empty():
		return []

	var cache_key := "character-sprite|%s|%s" % [unit_name, state]
	if _cache.has(cache_key):
		return _cache[cache_key]

	var frame_dir := "res://assets/characters/%s/runtime/%s" % [anchor_dir, state]
	var absolute_dir := ProjectSettings.globalize_path(frame_dir)
	if not DirAccess.dir_exists_absolute(absolute_dir):
		return []

	var file_names: PackedStringArray = []
	var dir := DirAccess.open(frame_dir)
	if dir == null:
		return []

	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name.is_empty():
			break
		if dir.current_is_dir():
			continue
		if not file_name.ends_with(".png"):
			continue
		file_names.append(file_name)
	dir.list_dir_end()
	file_names.sort()

	var frames: Array[Texture2D] = []
	for file_name in file_names:
		var texture := _load_preferred_texture(
			[
				"assets/characters/%s/runtime/%s/" % [anchor_dir, state]
			],
			file_name
		)
		if texture != null:
			frames.append(texture)

	_cache[cache_key] = frames
	return frames

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

static func clear_cache() -> void:
	_cache.clear()

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
