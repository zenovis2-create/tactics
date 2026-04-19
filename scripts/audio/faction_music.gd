class_name FactionMusic
extends Node

# Cross-Faction Music Warfare — faction-specific BGM with cross-fade transitions
# Supports: FARLAND_EMPIRE, LEONICA_RESISTANCE, NEUTRAL_MERCENARIES
# CH10 Final: multiple factions blend simultaneously

const FARLAND_EMPIRE := "FARLAND_EMPIRE"
const LEONICA_RESISTANCE := "LEONICA_RESISTANCE"
const NEUTRAL_MERCENARIES := "NEUTRAL_MERCENARIES"
const ALL_FACTIONS := [FARLAND_EMPIRE, LEONICA_RESISTANCE, NEUTRAL_MERCENARIES]

const FACTION_TRACKS := {
	FARLAND_EMPIRE: "res://data/audio/faction_empire.mp3",
	LEONICA_RESISTANCE: "res://data/audio/faction_leonica.mp3",
	NEUTRAL_MERCENARIES: "res://data/audio/faction_mercenaries.mp3"
}

const FACTION_DISPLAY_NAMES := {
	FARLAND_EMPIRE: "Farland Empire",
	LEONICA_RESISTANCE: "Leonica Resistance",
	NEUTRAL_MERCENARIES: "Neutral Mercenaries"
}

const FACTION_DESCRIPTIONS := {
	FARLAND_EMPIRE: "Imperial brass and drum corps — authoritative, disciplined",
	LEONICA_RESISTANCE: "Folk strings and woodwinds — defiant, passionate",
	NEUTRAL_MERCENARIES: "Celtic fiddle and percussion — pragmatic, adaptable"
}

var _current_faction: String = ""
var _current_stream: AudioStreamPlayer = null
var _blend_streams: Dictionary = {}
var _blend_factions: Array[String] = []
var _fade_duration: float = 2.0
var _volume: float = 1.0
var _is_blending: bool = false

func _ready() -> void:
	_current_stream = AudioStreamPlayer.new()
	_current_stream.bus = &"Music"
	add_child(_current_stream)

func play_faction_music(faction: String, fade_duration: float = 2.0) -> void:
	if not ALL_FACTIONS.has(faction):
		push_warning("[FactionMusic] Unknown faction: ", faction)
		return
	var track_path: String = FACTION_TRACKS.get(faction, "")
	_fade_duration = fade_duration
	if track_path.is_empty() or not FileAccess.file_exists(track_path):
		_current_faction = faction
		_play_silence_with_fade(fade_duration)
		return
	var stream: AudioStream = load(track_path)
	if stream == null:
		push_warning("[FactionMusic] Failed to load track: ", track_path)
		_current_faction = faction
		return
	if _current_stream.playing and _fade_duration > 0:
		_crossfade_to_stream(stream, fade_duration)
	else:
		_current_stream.stream = stream
		_current_stream.volume_db = linear_to_db(_volume)
		_current_stream.play()
	_current_faction = faction
	_is_blending = false
	print("[FactionMusic] Playing: %s (%s)" % [faction, FACTION_DISPLAY_NAMES.get(faction, faction)])

func _play_silence_with_fade(fade_duration: float) -> void:
	if _current_stream == null:
		return
	if _current_stream.playing and fade_duration > 0:
		var tween := create_tween()
		tween.tween_property(_current_stream, "volume_db", db_to_linear(0.0), fade_duration)
		await tween.finished
	_current_stream.stop()

func _crossfade_to_stream(new_stream: AudioStream, duration: float) -> void:
	var old_player: AudioStreamPlayer = _current_stream
	var new_player: AudioStreamPlayer = AudioStreamPlayer.new()
	new_player.bus = _current_stream.bus
	new_player.stream = new_stream
	new_player.volume_db = db_to_linear(0.0)
	add_child(new_player)
	new_player.play()
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(new_player, "volume_db", db_to_linear(_volume), duration)
	tween.tween_property(old_player, "volume_db", db_to_linear(0.0), duration)
	await tween.finished
	old_player.stop()
	old_player.queue_free()
	_current_stream = new_player

func crossfade_to_faction(faction: String, duration: float = 2.0) -> void:
	play_faction_music(faction, duration)

func stop_faction_music(fade_duration: float = 2.0) -> void:
	_current_faction = ""
	_is_blending = false
	for stream_node: Node in _blend_streams.values():
		if stream_node is AudioStreamPlayer:
			stream_node.stop()
			stream_node.queue_free()
	_blend_streams.clear()
	_blend_factions.clear()
	if _current_stream == null:
		return
	if fade_duration > 0 and _current_stream.playing:
		var tween := create_tween()
		tween.tween_property(_current_stream, "volume_db", db_to_linear(0.0), fade_duration)
		await tween.finished
	_current_stream.stop()
	print("[FactionMusic] Stopped")

func play_faction_blend(factions: Array[String], fade_duration: float = 2.0) -> void:
	# CH10 Final: multiple faction themes play simultaneously creating polyphonic harmony
	for faction: String in factions:
		if not ALL_FACTIONS.has(faction):
			continue
		if _blend_factions.has(faction):
			continue
		_blend_factions.append(faction)
		if _blend_streams.has(faction):
			continue
		var track_path: String = FACTION_TRACKS.get(faction, "")
		if track_path.is_empty() or not FileAccess.file_exists(track_path):
			continue
		var stream: AudioStream = load(track_path)
		if stream == null:
			continue
		var blend_player := AudioStreamPlayer.new()
		blend_player.bus = _current_stream.bus
		blend_player.stream = stream
		blend_player.volume_db = db_to_linear(0.0)
		add_child(blend_player)
		blend_player.play()
		_blend_streams[faction] = blend_player
		var tween := create_tween()
		tween.set_parallel(true)
		for other_faction: String in _blend_streams.keys():
			var other_player: AudioStreamPlayer = _blend_streams[other_faction]
			tween.tween_property(other_player, "volume_db", linear_to_db(_volume * 0.7), fade_duration)
		if _current_stream.playing:
			tween.tween_property(_current_stream, "volume_db", linear_to_db(_volume * 0.5), fade_duration)
		else:
			_current_stream.volume_db = linear_to_db(_volume * 0.5)
		await tween.finished
	_is_blending = true
	print("[FactionMusic] Faction blend: ", ", ".join(factions))

func set_volume(volume_level: float) -> void:
	_volume = clampf(volume_level, 0.0, 1.0)
	if _current_stream != null:
		_current_stream.volume_db = db_to_linear(_volume)

func get_current_faction() -> String:
	return _current_faction

func is_playing() -> bool:
	return _current_stream != null and _current_stream.playing

func is_faction_active(faction: String) -> bool:
	if _current_faction == faction and not _is_blending:
		return true
	if _is_blending and _blend_factions.has(faction):
		return true
	return _blend_streams.has(faction)

func get_faction_for_chapter(chapter_id: String) -> String:
	# Map chapter IDs to faction territories
	var chapter_upper := chapter_id.to_upper()
	if chapter_upper.begins_with("CH01") or chapter_upper.begins_with("CH02"):
		return FARLAND_EMPIRE
	if chapter_upper.begins_with("CH03") or chapter_upper.begins_with("CH04"):
		return NEUTRAL_MERCENARIES
	if chapter_upper.begins_with("CH05") or chapter_upper.begins_with("CH06"):
		return FARLAND_EMPIRE
	if chapter_upper.begins_with("CH07") or chapter_upper.begins_with("CH08"):
		return LEONICA_RESISTANCE
	if chapter_upper.begins_with("CH09") or chapter_upper.begins_with("CH10"):
		return FARLAND_EMPIRE
	return ""

func get_all_factions() -> Array:
	return ALL_FACTIONS.duplicate()

func get_faction_info(faction: String) -> Dictionary:
	return {
		"id": faction,
		"name": FACTION_DISPLAY_NAMES.get(faction, faction),
		"description": FACTION_DESCRIPTIONS.get(faction, ""),
		"track_path": FACTION_TRACKS.get(faction, ""),
		"is_playing": is_faction_active(faction)
	}
