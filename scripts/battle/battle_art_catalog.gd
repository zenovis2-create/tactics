class_name BattleArtCatalog
extends RefCounted

static var _cache: Dictionary = {}
static var _ally_sprite_anchor_map := {
	"Rian": "sprite_anchor_rian",
	"ally_rian": "sprite_anchor_rian",
	"Serin": "sprite_anchor_serin",
	"ally_serin": "sprite_anchor_serin",
	"Tia": "sprite_anchor_tia",
	"ally_tia": "sprite_anchor_tia",
	"Bran": "sprite_anchor_bran",
	"ally_bran": "sprite_anchor_bran",
	"Enoch": "sprite_anchor_enoch",
	"ally_enoch": "sprite_anchor_enoch",
	"Kyle": "sprite_anchor_kyle",
	"ally_kyle": "sprite_anchor_kyle",
	"ally_karl": "sprite_anchor_kyle",
	"Noah": "sprite_anchor_noah",
	"ally_noah": "sprite_anchor_noah",
	"Mira": "sprite_anchor_mira",
	"ally_mira": "sprite_anchor_mira",
	"Lete": "sprite_anchor_lete",
	"ally_lete": "sprite_anchor_lete",
	"enemy_lete": "sprite_anchor_enemy_lete",
	"Vanguard": "sprite_anchor_vanguard",
	"ally_vanguard": "sprite_anchor_vanguard",
	"Scout": "sprite_anchor_scout",
	"ally_scout": "sprite_anchor_scout",
	"Saria": "sprite_anchor_enemy_saria",
	"enemy_saria": "sprite_anchor_enemy_saria",
	"Saria II": "sprite_anchor_enemy_saria",
	"enemy_saria_2": "sprite_anchor_enemy_saria",
	"Basil": "sprite_anchor_enemy_basil",
	"enemy_basil": "sprite_anchor_enemy_basil",
	"Hes": "sprite_anchor_enemy_hes",
	"enemy_hes": "sprite_anchor_enemy_hes",
	"Resin Warden": "sprite_anchor_enemy_resin_warden",
	"enemy_resin_warden": "sprite_anchor_enemy_resin_warden",
	"Ash Archivist": "sprite_anchor_enemy_ash_archivist",
	"enemy_ash_archivist": "sprite_anchor_enemy_ash_archivist",
	"enemy_barten": "sprite_anchor_enemy_barten",
	"enemy_varten": "sprite_anchor_enemy_barten",
	"Valgar": "sprite_anchor_enemy_valgar",
	"enemy_valgar": "sprite_anchor_enemy_valgar",
	"Valgar II": "sprite_anchor_enemy_valgar",
	"enemy_valgar_2": "sprite_anchor_enemy_valgar",
	"enemy_melkion": "sprite_anchor_enemy_melkion",
	"enemy_kyle_1": "sprite_anchor_enemy_kyle",
	"enemy_karl_1": "sprite_anchor_enemy_kyle",
	"Hardren Captain": "sprite_anchor_enemy_hardren_captain",
	"enemy_hardren_captain": "sprite_anchor_enemy_hardren_captain",
	"Roderic": "sprite_anchor_enemy_roderic",
	"enemy_roderic": "sprite_anchor_enemy_roderic",
	"Karuon": "sprite_anchor_enemy_karuon",
	"enemy_karuon": "sprite_anchor_enemy_karuon",
	"enemy_karuon_final": "sprite_anchor_enemy_karuon_final",
	"enemy_karon": "sprite_anchor_enemy_karuon",
	"enemy_karon_1": "sprite_anchor_enemy_karuon",
	"enemy_karon_final": "sprite_anchor_enemy_karuon_final",
	"ally_melkion_ally": "sprite_anchor_melkion_ally",
	"melkion_ally": "sprite_anchor_melkion_ally",
	"Raider": "sprite_anchor_enemy_raider",
	"enemy_raider": "sprite_anchor_enemy_raider",
	"Skirmisher": "sprite_anchor_enemy_skirmisher",
	"enemy_skirmisher": "sprite_anchor_enemy_skirmisher",
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

static func load_fx_animation(file_name: String) -> Array[Texture2D]:
	if file_name.is_empty():
		return []

	var effect_id := String(file_name).get_basename()
	var cache_key := "fx-animation|%s" % effect_id
	if _cache.has(cache_key):
		return _cache[cache_key]

	var frame_dir := "res://assets/fx/%s/runtime/default" % effect_id
	var absolute_dir := ProjectSettings.globalize_path(frame_dir)
	if not DirAccess.dir_exists_absolute(absolute_dir):
		_cache[cache_key] = []
		return []

	var dir := DirAccess.open(frame_dir)
	if dir == null:
		_cache[cache_key] = []
		return []

	var file_names: PackedStringArray = []
	dir.list_dir_begin()
	while true:
		var candidate := dir.get_next()
		if candidate.is_empty():
			break
		if dir.current_is_dir():
			continue
		if candidate.to_lower().ends_with(".png"):
			file_names.append(candidate)
	dir.list_dir_end()
	file_names.sort()

	var frames: Array[Texture2D] = []
	for candidate in file_names:
		var texture := _load_texture_from_resource_path("%s/%s" % [frame_dir, candidate])
		if texture != null:
			frames.append(texture)

	_cache[cache_key] = frames
	return frames

static func load_object_interaction_animation(object_type: String) -> Array[Texture2D]:
	if object_type.is_empty():
		return []

	var cache_key := "object-interaction-animation|%s" % object_type
	if _cache.has(cache_key):
		return _cache[cache_key]

	var frame_dir := "res://assets/objects/interactions/%s/runtime/interact" % object_type
	var absolute_dir := ProjectSettings.globalize_path(frame_dir)
	if not DirAccess.dir_exists_absolute(absolute_dir):
		_cache[cache_key] = []
		return []

	var dir := DirAccess.open(frame_dir)
	if dir == null:
		_cache[cache_key] = []
		return []

	var file_names: PackedStringArray = []
	dir.list_dir_begin()
	while true:
		var candidate := dir.get_next()
		if candidate.is_empty():
			break
		if dir.current_is_dir():
			continue
		if candidate.to_lower().ends_with(".png"):
			file_names.append(candidate)
	dir.list_dir_end()
	file_names.sort()

	var frames: Array[Texture2D] = []
	for candidate in file_names:
		var texture := _load_texture_from_resource_path("%s/%s" % [frame_dir, candidate])
		if texture != null:
			frames.append(texture)

	_cache[cache_key] = frames
	return frames

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

static func _load_texture_from_resource_path(resource_path: String) -> Texture2D:
	var absolute_path := ProjectSettings.globalize_path(resource_path)
	if not FileAccess.file_exists(absolute_path):
		return null
	var image := Image.new()
	if image.load(absolute_path) != OK:
		return null
	return ImageTexture.create_from_image(image)
