class_name AudioEventRouter
extends Node

signal cue_triggered(cue_id: String)

const MANIFEST_PATH := "res://data/audio/sfx_manifest.json"
const FALLBACK_MANIFEST_PATH := "res://data/audio/sfx_placeholder_manifest.json"
const PLAYER_POOL_SIZE := 4

var cue_history: Array[String] = []
var missing_cues: Array[String] = []

var _cue_manifest: Dictionary = {}
var _stream_cache: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _last_asset_path: String = ""
var _last_manifest_path: String = ""
var _next_player_index: int = 0
var _cue_manifest_sources: Dictionary = {}

func _ready() -> void:
	_load_manifest()
	_ensure_players()

func _exit_tree() -> void:
	_release_audio_resources()

func attach_battle_hud(hud) -> void:
	if hud == null or not hud.has_signal("ui_cue_requested"):
		return
	if not hud.ui_cue_requested.is_connected(_on_ui_cue_requested):
		hud.ui_cue_requested.connect(_on_ui_cue_requested)

func attach_campaign_panel(panel) -> void:
	if panel == null or not panel.has_signal("ui_cue_requested"):
		return
	if not panel.ui_cue_requested.is_connected(_on_ui_cue_requested):
		panel.ui_cue_requested.connect(_on_ui_cue_requested)

func get_snapshot() -> Dictionary:
	return {
		"last_cue": cue_history[-1] if not cue_history.is_empty() else "",
		"cue_history": cue_history.duplicate(),
		"last_asset_path": _last_asset_path,
		"last_manifest_path": _last_manifest_path,
		"manifest_count": _cue_manifest.size(),
		"missing_cues": missing_cues.duplicate()
	}

func _on_ui_cue_requested(cue_id: String) -> void:
	if cue_id.strip_edges().is_empty():
		return
	cue_history.append(cue_id)
	if cue_history.size() > 64:
		cue_history.pop_front()
	_play_cue(cue_id)
	cue_triggered.emit(cue_id)

func _load_manifest() -> void:
	_cue_manifest.clear()
	_cue_manifest_sources.clear()
	_load_manifest_file(FALLBACK_MANIFEST_PATH, false)
	_load_manifest_file(MANIFEST_PATH, true)
	if _cue_manifest.is_empty():
		push_warning("Audio cue manifests are missing or empty: %s, %s." % [MANIFEST_PATH, FALLBACK_MANIFEST_PATH])

func _load_manifest_file(path: String, override_existing: bool) -> void:
	if not FileAccess.file_exists(path):
		return
	var source: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(source)
	if not (parsed is Dictionary):
		push_warning("Audio cue manifest could not be parsed from %s." % path)
		return
	for cue_id_variant in parsed.keys():
		var cue_id: String = String(cue_id_variant)
		if not override_existing and _cue_manifest.has(cue_id):
			continue
		_cue_manifest[cue_id] = parsed[cue_id]
		_cue_manifest_sources[cue_id] = path

func _ensure_players() -> void:
	if not _players.is_empty():
		return
	for index in range(PLAYER_POOL_SIZE):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "CuePlayer%d" % index
		player.bus = &"Master"
		add_child(player)
		_players.append(player)

func _play_cue(cue_id: String) -> void:
	_last_asset_path = ""
	var stream: AudioStream = _resolve_stream(cue_id)
	if stream == null:
		_register_missing_cue(cue_id)
		return
	if _players.is_empty():
		return
	# Headless 모드에서는 Dummy 드라이버가 오디오 프레임을 실시간 처리하지 않아
	# AudioStreamPlaybackWAV가 종료 시까지 해제되지 않는다. 재생 자체를 건너뛴다.
	if DisplayServer.get_name() == "headless":
		return
	var player: AudioStreamPlayer = _players[_next_player_index]
	_next_player_index = (_next_player_index + 1) % _players.size()
	player.stop()
	player.stream = null   # 이전 AudioStreamPlayback 명시적 해제
	player.stream = stream
	player.play()

func _resolve_stream(cue_id: String) -> AudioStream:
	var entry_variant: Variant = _cue_manifest.get(cue_id, {})
	if not (entry_variant is Dictionary):
		return null
	var entry: Dictionary = entry_variant
	var asset_path: String = String(entry.get("asset_path", ""))
	if asset_path.is_empty():
		return null
	_last_asset_path = asset_path
	_last_manifest_path = String(_cue_manifest_sources.get(cue_id, ""))
	if _stream_cache.has(asset_path):
		return _stream_cache[asset_path] as AudioStream
	var stream: AudioStream = null
	if asset_path.ends_with(".ogg"):
		var absolute_path: String = ProjectSettings.globalize_path(asset_path)
		if FileAccess.file_exists(absolute_path):
			stream = AudioStreamOggVorbis.load_from_file(absolute_path)
	elif asset_path.ends_with(".wav"):
		var absolute_path_wav: String = ProjectSettings.globalize_path(asset_path)
		if FileAccess.file_exists(absolute_path_wav):
			stream = AudioStreamWAV.load_from_file(absolute_path_wav)
	else:
		stream = load(asset_path) as AudioStream
	if stream == null:
		return null
	_stream_cache[asset_path] = stream
	return stream

func _register_missing_cue(cue_id: String) -> void:
	if missing_cues.has(cue_id):
		return
	missing_cues.append(cue_id)

func _release_audio_resources() -> void:
	for player in _players:
		if player == null or not is_instance_valid(player):
			continue
		player.stop()
		player.stream = null
		player.free()
	_players.clear()
	_stream_cache.clear()
	_last_asset_path = ""
	_last_manifest_path = ""
