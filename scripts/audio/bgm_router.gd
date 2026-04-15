class_name BgmRouter
extends Node

const MANIFEST_PATH := "res://data/audio/bgm_manifest.json"

var _cue_manifest: Dictionary = {}
var _stream_cache: Dictionary = {}
var _player: AudioStreamPlayer
var _current_cue_id: String = ""

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
	_current_cue_id = normalized_cue_id
	# Headless 모드에서는 Dummy 드라이버가 AudioStreamPlaybackWAV를 종료 전에 해제하지 않는다.
	if DisplayServer.get_name() == "headless":
		return
	_replace_player()
	_player.stream = stream
	_player.play()

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
	_player = AudioStreamPlayer.new()
	_player.name = "BgmPlayer"
	_player.bus = &"Master"
	_player.autoplay = false
	add_child(_player)

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
	if _player != null:
		_player.stop()
		_player.stream = null
		if is_instance_valid(_player):
			_player.free()
		_player = null
	_ensure_player()

func _release_audio_resources() -> void:
	if _player != null:
		_player.stop()
		_player.stream = null
		if is_instance_valid(_player):
			_player.free()
		_player = null
	_current_cue_id = ""
	_stream_cache.clear()
