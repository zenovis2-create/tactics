class_name BgmRouter
extends Node

const MANIFEST_PATH := "res://data/audio/bgm_manifest.json"
const SILENT_VOLUME_DB := -80.0

var _cue_manifest: Dictionary = {}
var _stream_cache: Dictionary = {}
var _player: AudioStreamPlayer
var _current_cue_id: String = ""
var _fade_tween: Tween

func _ready() -> void:
	_load_manifest()
	_ensure_player()

func _exit_tree() -> void:
	_release_audio_resources()

func play_cue(cue_id: String, restart: bool = false) -> void:
	var normalized_cue_id := cue_id.strip_edges()
	if normalized_cue_id.is_empty():
		return
	if not restart and _current_cue_id == normalized_cue_id and _player != null and _player.playing:
		return
	var stream := _resolve_stream(normalized_cue_id)
	if stream == null:
		push_warning("BGM cue '%s' is missing from manifest or could not be loaded." % normalized_cue_id)
		return
	_cancel_crossfade()
	_current_cue_id = normalized_cue_id
	# Headless 모드에서는 Dummy 드라이버가 AudioStreamPlaybackWAV를 종료 전에 해제하지 않는다.
	if _is_headless_runtime():
		return
	_replace_player()
	_player.stream = stream
	_player.play()
	_player.volume_db = 0.0

func crossfade_to_cue(cue_id: String, fade_duration: float = 2.0) -> void:
	_crossfade_to_cue_internal(cue_id, fade_duration, false)

func crossfade_to_cue_immediate(cue_id: String, fade_duration: float = 2.0) -> void:
	_crossfade_to_cue_internal(cue_id, fade_duration, true)

func stop() -> void:
	_release_audio_resources()

func get_current_cue_id() -> String:
	return _current_cue_id

func _load_manifest() -> void:
	if not FileAccess.file_exists(MANIFEST_PATH):
		push_warning("BGM manifest is missing at %s." % MANIFEST_PATH)
		return
	var source := FileAccess.get_file_as_string(MANIFEST_PATH)
	var parsed: Variant = JSON.parse_string(source)
	if parsed is Dictionary:
		_cue_manifest = parsed
	else:
		push_warning("BGM manifest could not be parsed from %s." % MANIFEST_PATH)

func _ensure_player() -> void:
	if _player != null:
		return
	_player = _create_player("BgmPlayer")

func _resolve_stream(cue_id: String) -> AudioStream:
	var entry_variant: Variant = _cue_manifest.get(cue_id, {})
	if not (entry_variant is Dictionary):
		return null
	var entry: Dictionary = entry_variant
	var asset_path := String(entry.get("asset_path", ""))
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

func _replace_player() -> void:
	_cancel_crossfade()
	_clear_extra_players(_player)
	if _player != null:
		_release_player(_player)
		_player = null
	_ensure_player()

func _release_audio_resources() -> void:
	_cancel_crossfade()
	_clear_extra_players(_player)
	if _player != null:
		_release_player(_player)
		_player = null
	_current_cue_id = ""
	_stream_cache.clear()

func _crossfade_to_cue_internal(cue_id: String, fade_duration: float, restart: bool) -> void:
	var normalized_cue_id := cue_id.strip_edges()
	if normalized_cue_id.is_empty():
		return
	if not restart and _current_cue_id == normalized_cue_id:
		return
	if fade_duration <= 0.0:
		play_cue(normalized_cue_id, restart)
		return
	var stream := _resolve_stream(normalized_cue_id)
	if stream == null:
		push_warning("BGM cue '%s' is missing from manifest or could not be loaded." % normalized_cue_id)
		return
	if _is_headless_runtime() or _player == null or not _player.playing:
		play_cue(normalized_cue_id, restart)
		return
	_cancel_crossfade()
	_clear_extra_players(_player)
	var old_player := _player
	var new_player := _create_player("BgmPlayerCrossfade")
	new_player.stream = stream
	new_player.volume_db = SILENT_VOLUME_DB
	new_player.play()
	_player = new_player
	_current_cue_id = normalized_cue_id
	_fade_tween = create_tween()
	_fade_tween.set_parallel(true)
	_fade_tween.tween_property(new_player, "volume_db", 0.0, fade_duration)
	_fade_tween.tween_property(old_player, "volume_db", SILENT_VOLUME_DB, fade_duration)
	await _fade_tween.finished
	if old_player != null and is_instance_valid(old_player):
		_release_player(old_player)
	_fade_tween = null

func _create_player(player_name: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.bus = &"Master"
	player.autoplay = false
	add_child(player)
	return player

func _cancel_crossfade() -> void:
	if _fade_tween == null:
		return
	_fade_tween.kill()
	_fade_tween = null

func _release_player(player: AudioStreamPlayer) -> void:
	if player == null:
		return
	player.stop()
	player.stream = null
	if is_instance_valid(player):
		player.free()

func _clear_extra_players(except_player: AudioStreamPlayer = null) -> void:
	for child in get_children():
		var child_player := child as AudioStreamPlayer
		if child_player == null or child_player == except_player:
			continue
		_release_player(child_player)

func _is_headless_runtime() -> bool:
	return DisplayServer.get_name() == "headless"
