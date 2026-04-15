class_name AudioEventRouter
extends Node

signal cue_triggered(cue_id: String)

const MANIFEST_PATH := "res://data/audio/sfx_placeholder_manifest.json"
const PLAYER_POOL_SIZE := 4

var cue_history: Array[String] = []
var missing_cues: Array[String] = []

var _cue_manifest: Dictionary = {}
var _stream_cache: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _last_asset_path: String = ""
var _next_player_index: int = 0

func _ready() -> void:
	_load_manifest()
	_ensure_players()

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
	if not FileAccess.file_exists(MANIFEST_PATH):
		push_warning("Audio cue manifest is missing at %s." % MANIFEST_PATH)
		return
	var source: String = FileAccess.get_file_as_string(MANIFEST_PATH)
	var parsed: Variant = JSON.parse_string(source)
	if not (parsed is Dictionary):
		push_warning("Audio cue manifest could not be parsed from %s." % MANIFEST_PATH)
		return
	_cue_manifest = parsed

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
	var player: AudioStreamPlayer = _players[_next_player_index]
	_next_player_index = (_next_player_index + 1) % _players.size()
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
