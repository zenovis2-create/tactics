class_name LayeredMusic
extends Node

const MANIFEST_PATH := "res://data/audio/bgm_manifest.json"
const STUB_LAYER_ASSET_PATH := "res://audio/bgm/bgm_battle_default.wav"
const SILENT_VOLUME_DB := -80.0
const DEFAULT_CUE_ID := "bgm_battle_default"
const LAYER_IDS: Array[String] = ["base", "drums", "strings", "vocal", "ambience", "spotlight"]

var _cue_manifest: Dictionary = {}
var _stream_cache: Dictionary = {}
var _players: Dictionary = {}
var _layer_levels: Dictionary = {}
var _layer_targets: Dictionary = {}
var _layer_tweens: Dictionary = {}
var _layer_asset_paths: Dictionary = {}
var _current_cue_id: String = ""
var _base_transition_player: AudioStreamPlayer = null
var _base_crossfade_tween: Tween = null
var _stop_tween: Tween = null


func _ready() -> void:
	_load_manifest()
	_ensure_players()
	_assign_stub_streams()
	for layer_name in LAYER_IDS:
		_layer_levels[layer_name] = 0.0
		_layer_targets[layer_name] = 0.0
		_apply_layer_volume(0.0, layer_name)


func _exit_tree() -> void:
	_stop_base_crossfade()
	if _stop_tween != null and is_instance_valid(_stop_tween):
		_stop_tween.kill()
	for player_variant in _players.values():
		var player := player_variant as AudioStreamPlayer
		if player == null or not is_instance_valid(player):
			continue
		player.stop()
		player.stream = null
	if _base_transition_player != null and is_instance_valid(_base_transition_player):
		_base_transition_player.stop()
		_base_transition_player.stream = null


func play_cue(cue_id: String, restart: bool = false) -> void:
	var normalized_cue_id := cue_id.strip_edges()
	if normalized_cue_id.is_empty():
		return
	_ensure_players()
	var base_player := _get_player("base")
	if not restart and _current_cue_id == normalized_cue_id and base_player != null and base_player.stream != null:
		_set_layer_target("base", 1.0, 0.0)
		return
	var stream := _resolve_stream_for_cue(normalized_cue_id)
	if stream == null:
		return
	_stop_base_crossfade()
	_current_cue_id = normalized_cue_id
	_layer_asset_paths["base"] = _resolve_cue_asset_path(normalized_cue_id)
	if base_player != null:
		base_player.stop()
		base_player.stream = null
		base_player.stream = stream
		if not _should_skip_playback():
			base_player.play()
	_set_layer_target("base", 1.0, 0.0)


func activate_layer(layer_name: String, fade_time: float = 1.0) -> void:
	var normalized_layer := _normalize_layer_name(layer_name)
	if normalized_layer.is_empty():
		return
	_prepare_layer_for_activation(normalized_layer)
	_set_layer_target(normalized_layer, 1.0, fade_time)


func deactivate_layer(layer_name: String, fade_time: float = 1.0) -> void:
	var normalized_layer := _normalize_layer_name(layer_name)
	if normalized_layer.is_empty():
		return
	_set_layer_target(normalized_layer, 0.0, fade_time)


func trigger_spotlight_music(spotlight_type: String, fade_time: float = 2.0) -> void:
	var normalized_type := spotlight_type.strip_edges().to_lower()
	if normalized_type.is_empty():
		return
	if _current_cue_id.is_empty():
		play_cue(DEFAULT_CUE_ID)
	activate_layer("spotlight", fade_time)
	match normalized_type:
		"bond_death":
			activate_layer("strings", fade_time)
			activate_layer("vocal", fade_time)
		"boss":
			activate_layer("drums", fade_time)
		"critical":
			activate_layer("strings", fade_time)
		"victory":
			activate_layer("ambience", fade_time)
		_:
			return


func crossfade_to_cue(cue_id: String, fade_duration: float = 2.0) -> void:
	var normalized_cue_id := cue_id.strip_edges()
	if normalized_cue_id.is_empty():
		return
	_ensure_players()
	var stream := _resolve_stream_for_cue(normalized_cue_id)
	if stream == null:
		return
	_current_cue_id = normalized_cue_id
	_layer_asset_paths["base"] = _resolve_cue_asset_path(normalized_cue_id)
	_stop_base_crossfade()
	var base_player := _get_player("base")
	if _base_transition_player == null:
		_base_transition_player = _create_player("BaseTransitionPlayer")
		add_child(_base_transition_player)
	_base_transition_player.stop()
	_base_transition_player.stream = null
	_base_transition_player.stream = stream
	_base_transition_player.volume_db = SILENT_VOLUME_DB
	if not _should_skip_playback():
		_base_transition_player.play()
	if base_player == null or base_player.stream == null or fade_duration <= 0.0:
		if base_player != null:
			base_player.stop()
			base_player.stream = null
			base_player.stream = stream
			if not _should_skip_playback():
				base_player.play()
		_set_layer_target("base", 1.0, 0.0)
		return
	_prepare_layer_for_activation("base")
	var current_level: float = max(float(_layer_levels.get("base", 0.0)), 0.0001)
	_base_crossfade_tween = create_tween()
	_base_crossfade_tween.set_parallel(true)
	_base_crossfade_tween.tween_method(Callable(self, "_apply_base_crossfade_level"), current_level, 0.0, fade_duration)
	_base_crossfade_tween.tween_method(Callable(self, "_apply_transition_crossfade_level"), 0.0, 1.0, fade_duration)
	_base_crossfade_tween.chain().tween_callback(Callable(self, "_complete_base_crossfade"))


func stop_all(fade_time: float = 2.0) -> void:
	_stop_base_crossfade()
	if _stop_tween != null and is_instance_valid(_stop_tween):
		_stop_tween.kill()
	for layer_name in LAYER_IDS:
		deactivate_layer(layer_name, fade_time)
	if fade_time <= 0.0:
		_stop_all_players()
		return
	_stop_tween = create_tween()
	_stop_tween.tween_interval(fade_time)
	_stop_tween.tween_callback(Callable(self, "_stop_all_players"))


func is_layer_active(layer_name: String) -> bool:
	var normalized_layer := _normalize_layer_name(layer_name)
	if normalized_layer.is_empty():
		return false
	return float(_layer_targets.get(normalized_layer, 0.0)) > 0.01 or float(_layer_levels.get(normalized_layer, 0.0)) > 0.01


func get_active_layers() -> Array[String]:
	var active_layers: Array[String] = []
	for layer_name in LAYER_IDS:
		if is_layer_active(layer_name):
			active_layers.append(layer_name)
	return active_layers


func _should_skip_playback() -> bool:
	return OS.has_feature("standalone") or DisplayServer.get_name() == "headless"


func _load_manifest() -> void:
	_cue_manifest.clear()
	if not FileAccess.file_exists(MANIFEST_PATH):
		return
	var source := FileAccess.get_file_as_string(MANIFEST_PATH)
	var parsed: Variant = JSON.parse_string(source)
	if parsed is Dictionary:
		_cue_manifest = parsed


func _ensure_players() -> void:
	for layer_name in LAYER_IDS:
		if _players.has(layer_name):
			continue
		var player := _create_player("%sLayerPlayer" % layer_name.capitalize())
		add_child(player)
		_players[layer_name] = player
	if _base_transition_player == null:
		_base_transition_player = _create_player("BaseTransitionPlayer")
		add_child(_base_transition_player)


func _create_player(player_name: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.bus = &"Master"
	player.autoplay = false
	player.volume_db = SILENT_VOLUME_DB
	return player


func _assign_stub_streams() -> void:
	var stub_stream := _resolve_stream(STUB_LAYER_ASSET_PATH)
	if stub_stream == null:
		return
	for layer_name in ["drums", "strings", "vocal", "ambience", "spotlight"]:
		var player := _get_player(layer_name)
		if player == null:
			continue
		player.stream = stub_stream
		_layer_asset_paths[layer_name] = STUB_LAYER_ASSET_PATH


func _prepare_layer_for_activation(layer_name: String) -> void:
	var player := _get_player(layer_name)
	if player == null:
		return
	if layer_name == "base":
		if player.stream == null:
			if _current_cue_id.is_empty():
				play_cue(DEFAULT_CUE_ID)
			else:
				var stream := _resolve_stream_for_cue(_current_cue_id)
				if stream != null:
					player.stream = stream
	else:
		if player.stream == null:
			var stub_stream := _resolve_stream(STUB_LAYER_ASSET_PATH)
			if stub_stream != null:
				player.stream = stub_stream
				_layer_asset_paths[layer_name] = STUB_LAYER_ASSET_PATH
	if not _should_skip_playback() and player.stream != null and not player.playing:
		player.play()


func _set_layer_target(layer_name: String, target: float, fade_time: float) -> void:
	_layer_targets[layer_name] = clampf(target, 0.0, 1.0)
	_fade_layer_to(layer_name, float(_layer_targets[layer_name]), fade_time)


func _fade_layer_to(layer_name: String, target: float, fade_time: float) -> void:
	var existing_tween: Tween = _layer_tweens.get(layer_name, null)
	if existing_tween != null and is_instance_valid(existing_tween):
		existing_tween.kill()
	if fade_time <= 0.0:
		_apply_layer_volume(target, layer_name)
		if target <= 0.0:
			_stop_layer_player_if_finished(layer_name)
		return
	var start_level := float(_layer_levels.get(layer_name, 0.0))
	var tween := create_tween()
	_layer_tweens[layer_name] = tween
	tween.tween_method(Callable(self, "_apply_layer_volume").bind(layer_name), start_level, target, fade_time)
	tween.tween_callback(Callable(self, "_stop_layer_player_if_finished").bind(layer_name))


func _apply_layer_volume(value: float, layer_name: String) -> void:
	var clamped_value := clampf(value, 0.0, 1.0)
	_layer_levels[layer_name] = clamped_value
	var player := _get_player(layer_name)
	if player == null:
		return
	player.volume_db = SILENT_VOLUME_DB if clamped_value <= 0.0001 else linear_to_db(clamped_value)


func _apply_base_crossfade_level(value: float) -> void:
	_apply_layer_volume(value, "base")


func _apply_transition_crossfade_level(value: float) -> void:
	if _base_transition_player == null:
		return
	var clamped_value := clampf(value, 0.0, 1.0)
	_base_transition_player.volume_db = SILENT_VOLUME_DB if clamped_value <= 0.0001 else linear_to_db(clamped_value)


func _complete_base_crossfade() -> void:
	var base_player := _get_player("base")
	if base_player == null or _base_transition_player == null:
		return
	base_player.stop()
	base_player.stream = null
	base_player.stream = _base_transition_player.stream
	if not _should_skip_playback() and base_player.stream != null:
		base_player.play()
	_apply_layer_volume(1.0, "base")
	_layer_targets["base"] = 1.0
	_base_transition_player.stop()
	_base_transition_player.stream = null
	_base_transition_player.volume_db = SILENT_VOLUME_DB
	_base_crossfade_tween = null


func _stop_base_crossfade() -> void:
	if _base_crossfade_tween != null and is_instance_valid(_base_crossfade_tween):
		_base_crossfade_tween.kill()
	_base_crossfade_tween = null
	if _base_transition_player != null and is_instance_valid(_base_transition_player):
		_base_transition_player.stop()
		_base_transition_player.stream = null
		_base_transition_player.volume_db = SILENT_VOLUME_DB


func _stop_all_players() -> void:
	for layer_name in LAYER_IDS:
		_stop_layer_player_if_finished(layer_name)
	if _base_transition_player != null and is_instance_valid(_base_transition_player):
		_base_transition_player.stop()


func _stop_layer_player_if_finished(layer_name: String) -> void:
	if float(_layer_targets.get(layer_name, 0.0)) > 0.01 or float(_layer_levels.get(layer_name, 0.0)) > 0.01:
		return
	var player := _get_player(layer_name)
	if player == null:
		return
	player.stop()


func _get_player(layer_name: String) -> AudioStreamPlayer:
	return _players.get(layer_name, null) as AudioStreamPlayer


func _normalize_layer_name(layer_name: String) -> String:
	var normalized := layer_name.strip_edges().to_lower()
	match normalized:
		"base", "base_melody":
			return "base"
		"drums", "drums_percussion":
			return "drums"
		"strings", "strings_emotion":
			return "strings"
		"vocal", "vocal_chorus":
			return "vocal"
		"ambience", "ambience_nature", "nature_ambience":
			return "ambience"
		"spotlight":
			return "spotlight"
		_:
			return ""


func _resolve_cue_asset_path(cue_id: String) -> String:
	var entry_variant: Variant = _cue_manifest.get(cue_id, {})
	if not (entry_variant is Dictionary):
		return ""
	var entry: Dictionary = entry_variant
	return String(entry.get("asset_path", ""))


func _resolve_stream_for_cue(cue_id: String) -> AudioStream:
	var asset_path := _resolve_cue_asset_path(cue_id)
	if asset_path.is_empty():
		return null
	return _resolve_stream(asset_path)


func _resolve_stream(asset_path: String) -> AudioStream:
	if asset_path.is_empty():
		return null
	if _stream_cache.has(asset_path):
		return _stream_cache[asset_path] as AudioStream
	var absolute_path := ProjectSettings.globalize_path(asset_path)
	var stream: AudioStream = null
	if asset_path.ends_with(".wav") and FileAccess.file_exists(absolute_path):
		stream = AudioStreamWAV.load_from_file(absolute_path)
	elif asset_path.ends_with(".ogg") and FileAccess.file_exists(absolute_path):
		stream = AudioStreamOggVorbis.load_from_file(absolute_path)
	else:
		stream = load(asset_path) as AudioStream
	if stream == null:
		return null
	if stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	elif stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	_stream_cache[asset_path] = stream
	return stream
