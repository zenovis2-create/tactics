class_name LayeredMusic
extends Node

const BGM_MANIFEST_PATH := "res://data/audio/bgm_manifest.json"
const BUS_SILENCE_DB := -80.0

const BASE_MELODY := "BASE_MELODY"
const DRUMS_PERCUSSION := "DRUMS_PERCUSSION"
const STRINGS_EMOTION := "STRINGS_EMOTION"
const VOCAL_CHORUS := "VOCAL_CHORUS"
const NATURE_AMBIENCE := "NATURE_AMBIENCE"

const LAYER_ORDER := [
	BASE_MELODY,
	DRUMS_PERCUSSION,
	STRINGS_EMOTION,
	VOCAL_CHORUS,
	NATURE_AMBIENCE,
]

var LAYER_CONFIG := {
	BASE_MELODY: {
		"aliases": PackedStringArray(["BASE", "BASE_MELODY"]),
		"bus_name": &"MusicBase",
		"player_name": "BaseMelodyPlayer",
		"default_level": 1.0,
	},
	DRUMS_PERCUSSION: {
		"aliases": PackedStringArray(["DRUMS", "DRUMS_PERCUSSION"]),
		"bus_name": &"MusicDrums",
		"player_name": "DrumsPercussionPlayer",
		"default_level": 1.0,
	},
	STRINGS_EMOTION: {
		"aliases": PackedStringArray(["STRINGS", "STRINGS_EMOTION"]),
		"bus_name": &"MusicStrings",
		"player_name": "StringsEmotionPlayer",
		"default_level": 1.0,
	},
	VOCAL_CHORUS: {
		"aliases": PackedStringArray(["VOCAL", "VOCAL_CHORUS"]),
		"bus_name": &"MusicVocal",
		"player_name": "VocalChorusPlayer",
		"default_level": 1.0,
	},
	NATURE_AMBIENCE: {
		"aliases": PackedStringArray(["AMBIENCE", "NATURE", "NATURE_AMBIENCE"]),
		"bus_name": &"MusicAmbience",
		"player_name": "NatureAmbiencePlayer",
		"default_level": 1.0,
	},
}

var _cue_manifest: Dictionary = {}
var _players: Dictionary = {}
var _layer_levels: Dictionary = {}
var _layer_base_targets: Dictionary = {}
var _layer_temporary_bonuses: Dictionary = {}
var _layer_tweens: Dictionary = {}
var _spotlight_tokens: Dictionary = {}
var _current_base_track: String = ""


func _ready() -> void:
	_load_manifest()
	_ensure_bus_layout()
	_ensure_players()
	deactivate_all_layers(0.0)


func play_layered_track(base_track: String, layers: Array[String]) -> void:
	_current_base_track = base_track.strip_edges()
	_ensure_bus_layout()
	_ensure_players()
	_clear_spotlight_state()
	_assign_streams(_current_base_track)
	_start_players()
	for layer_id in LAYER_ORDER:
		_layer_base_targets[layer_id] = 0.0
		_apply_layer_target(layer_id, 0.0)
	activate_layer(BASE_MELODY, 0.0)
	for layer_name in layers:
		activate_layer(layer_name, 0.0)


func activate_layer(layer_name: String, fade_time: float = 1.0) -> void:
	var layer_id := _normalize_layer_name(layer_name)
	if layer_id.is_empty():
		return
	_set_layer_level_internal(layer_id, float(LAYER_CONFIG.get(layer_id, {}).get("default_level", 1.0)), fade_time)


func deactivate_layer(layer_name: String, fade_time: float = 1.0) -> void:
	var layer_id := _normalize_layer_name(layer_name)
	if layer_id.is_empty():
		return
	_layer_temporary_bonuses[layer_id] = 0.0
	_set_layer_level_internal(layer_id, 0.0, fade_time)


func deactivate_all_layers(fade_time: float = 1.0) -> void:
	_clear_spotlight_state()
	for layer_id in LAYER_ORDER:
		_layer_temporary_bonuses[layer_id] = 0.0
		_set_layer_level_internal(layer_id, 0.0, fade_time)


func trigger_spotlight_music(spotlight_type: String) -> void:
	match spotlight_type.strip_edges().to_lower():
		"triple_kill":
			activate_layer(DRUMS_PERCUSSION, 0.4)
			_set_temporary_bonus(DRUMS_PERCUSSION, 0.3, 0.4, 5.0)
		"last_stand":
			_set_layer_level_internal(STRINGS_EMOTION, 1.4, 1.0)
		"bond_death":
			_set_layer_level_internal(VOCAL_CHORUS, 0.6, 3.0)
		"weather_master":
			_set_layer_level_internal(NATURE_AMBIENCE, 1.0, 1.0)


func set_layer_level(layer_name: String, level: float, fade_time: float = 1.0) -> void:
	var layer_id := _normalize_layer_name(layer_name)
	if layer_id.is_empty():
		return
	_set_layer_level_internal(layer_id, level, fade_time)


func has_layer(layer_name: String) -> bool:
	return not _normalize_layer_name(layer_name).is_empty()


func is_layer_active(layer_name: String) -> bool:
	var layer_id := _normalize_layer_name(layer_name)
	if layer_id.is_empty():
		return false
	return float(_layer_levels.get(layer_id, 0.0)) > 0.01 or float(_layer_base_targets.get(layer_id, 0.0)) > 0.01


func get_layer_level(layer_name: String) -> float:
	var layer_id := _normalize_layer_name(layer_name)
	if layer_id.is_empty():
		return 0.0
	return float(_layer_levels.get(layer_id, 0.0))


func get_active_layer_names() -> Array[String]:
	var active_layers: Array[String] = []
	for layer_id in LAYER_ORDER:
		if is_layer_active(layer_id):
			active_layers.append(layer_id)
	return active_layers


func _set_layer_level_internal(layer_id: String, level: float, fade_time: float) -> void:
	_layer_base_targets[layer_id] = max(level, 0.0)
	_apply_layer_target(layer_id, fade_time)


func _set_temporary_bonus(layer_id: String, bonus: float, fade_time: float, duration: float) -> void:
	var next_token := int(_spotlight_tokens.get(layer_id, 0)) + 1
	_spotlight_tokens[layer_id] = next_token
	_layer_temporary_bonuses[layer_id] = max(bonus, 0.0)
	_apply_layer_target(layer_id, fade_time)
	_restore_temporary_bonus(layer_id, next_token, duration, fade_time)


func _restore_temporary_bonus(layer_id: String, token: int, duration: float, fade_time: float) -> void:
	await get_tree().create_timer(duration, false).timeout
	if int(_spotlight_tokens.get(layer_id, 0)) != token:
		return
	_layer_temporary_bonuses[layer_id] = 0.0
	_apply_layer_target(layer_id, fade_time)


func _apply_layer_target(layer_id: String, fade_time: float) -> void:
	var target := float(_layer_base_targets.get(layer_id, 0.0)) + float(_layer_temporary_bonuses.get(layer_id, 0.0))
	_fade_layer_to(layer_id, target, fade_time)


func _fade_layer_to(layer_id: String, target: float, fade_time: float) -> void:
	var existing: Tween = _layer_tweens.get(layer_id, null)
	if existing != null and is_instance_valid(existing):
		existing.kill()
	if fade_time <= 0.0:
		_apply_layer_mix(target, layer_id)
		return
	var from_value := float(_layer_levels.get(layer_id, 0.0))
	var tween := create_tween()
	_layer_tweens[layer_id] = tween
	tween.tween_method(Callable(self, "_apply_layer_mix").bind(layer_id), from_value, target, fade_time)


func _apply_layer_mix(value: float, layer_id: String) -> void:
	_layer_levels[layer_id] = max(value, 0.0)
	var config: Dictionary = LAYER_CONFIG.get(layer_id, {})
	var bus_name: StringName = config.get("bus_name", &"Master")
	_set_bus_linear(bus_name, float(_layer_levels.get(layer_id, 0.0)))


func _set_bus_linear(bus_name: StringName, linear_value: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return
	if linear_value <= 0.0001:
		AudioServer.set_bus_volume_db(bus_index, BUS_SILENCE_DB)
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_value))


func _ensure_bus_layout() -> void:
	for layer_id in LAYER_ORDER:
		var config: Dictionary = LAYER_CONFIG.get(layer_id, {})
		var bus_name: StringName = config.get("bus_name", &"Master")
		if AudioServer.get_bus_index(bus_name) != -1:
			continue
		AudioServer.add_bus(AudioServer.get_bus_count())
		AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, bus_name)


func _ensure_players() -> void:
	if not _players.is_empty():
		return
	for layer_id in LAYER_ORDER:
		var config: Dictionary = LAYER_CONFIG.get(layer_id, {})
		var player := AudioStreamPlayer.new()
		player.name = String(config.get("player_name", "%sPlayer" % layer_id))
		player.bus = config.get("bus_name", &"Master")
		add_child(player)
		_players[layer_id] = player
		_layer_levels[layer_id] = 0.0
		_layer_base_targets[layer_id] = 0.0
		_layer_temporary_bonuses[layer_id] = 0.0
		_spotlight_tokens[layer_id] = 0


func _assign_streams(base_track: String) -> void:
	var stream := _resolve_stream(base_track)
	for layer_id in LAYER_ORDER:
		var player := _players.get(layer_id, null) as AudioStreamPlayer
		if player == null:
			continue
		player.stop()
		player.stream = stream


func _start_players() -> void:
	if DisplayServer.get_name() == "headless":
		return
	for player in _players.values():
		var typed_player := player as AudioStreamPlayer
		if typed_player == null or typed_player.stream == null:
			continue
		typed_player.play()


func _clear_spotlight_state() -> void:
	for layer_id in LAYER_ORDER:
		_spotlight_tokens[layer_id] = int(_spotlight_tokens.get(layer_id, 0)) + 1
		_layer_temporary_bonuses[layer_id] = 0.0


func _normalize_layer_name(layer_name: String) -> String:
	var normalized := layer_name.strip_edges().to_upper()
	if normalized.is_empty():
		return ""
	normalized = normalized.replace(" ", "_")
	for layer_id in LAYER_ORDER:
		var aliases: PackedStringArray = LAYER_CONFIG.get(layer_id, {}).get("aliases", PackedStringArray())
		if normalized == layer_id or aliases.has(normalized):
			return layer_id
	return ""


func _load_manifest() -> void:
	_cue_manifest.clear()
	if not FileAccess.file_exists(BGM_MANIFEST_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(BGM_MANIFEST_PATH))
	if parsed is Dictionary:
		_cue_manifest = parsed


func _resolve_stream(track_id: String) -> AudioStream:
	var normalized_track := track_id.strip_edges()
	if normalized_track.is_empty():
		return null
	var asset_path := normalized_track
	if _cue_manifest.has(normalized_track):
		var entry_variant: Variant = _cue_manifest.get(normalized_track, {})
		if entry_variant is Dictionary:
			asset_path = String((entry_variant as Dictionary).get("asset_path", normalized_track))
	if asset_path.is_empty():
		return null
	if asset_path.ends_with(".wav"):
		var absolute_path := ProjectSettings.globalize_path(asset_path)
		if FileAccess.file_exists(absolute_path):
			var wav_stream := AudioStreamWAV.load_from_file(absolute_path)
			if wav_stream != null:
				wav_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			return wav_stream
	if asset_path.ends_with(".ogg"):
		var absolute_ogg_path := ProjectSettings.globalize_path(asset_path)
		if FileAccess.file_exists(absolute_ogg_path):
			var ogg_stream := AudioStreamOggVorbis.load_from_file(absolute_ogg_path)
			if ogg_stream != null:
				ogg_stream.loop = true
			return ogg_stream
	return load(asset_path) as AudioStream
