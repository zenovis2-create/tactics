class_name StreamerOverlay
extends Control

# Streamer Overlay — stub for Twitch/YouTube integration
# Displays viewer count, chat integration, and streaming controls

signal stream_started(channel_name: String)
signal stream_stopped()
signal chat_message_received(username: String, message: String)

const SAVE_PATH := "user://stream_data/"

var _is_streaming: bool = false
var _stream_channel: String = ""
var _viewer_count: int = 0
var _stream_title: String = ""
var _chat_messages: Array[String] = []
var _max_chat_messages: int = 50
var _oauth_token: String = ""

# Twitch/YouTube stubs
var _twitch_channel: String = ""
var _youtube_channel: String = ""

func _ready() -> void:
	modulate = Color(1, 1, 1, 0.85)
	visible = false

func start_stream(channel_name: String, title: String = "Tactics Battle") -> bool:
	if _is_streaming:
		push_warning("[StreamerOverlay] Already streaming. Stop first.")
		return false
	_stream_channel = channel_name
	_stream_title = title
	_is_streaming = true
	_viewer_count = randi() % 100 + 5  # Simulated viewer count
	print("[StreamerOverlay] Stream started on channel: %s" % channel_name)
	stream_started.emit(channel_name)
	return true

func stop_stream() -> void:
	if not _is_streaming:
		return
	_is_streaming = false
	_stream_channel = ""
	_viewer_count = 0
	_chat_messages.clear()
	print("[StreamerOverlay] Stream stopped.")
	stream_stopped.emit()

func is_streaming() -> bool:
	return _is_streaming

func get_channel_name() -> String:
	return _stream_channel

func get_stream_title() -> String:
	return _stream_title

# Twitch integration stubs
func connect_twitch(channel: String) -> bool:
	_twitch_channel = channel
	print("[StreamerOverlay] Twitch connection stub for: %s" % channel)
	return false  # Stub: not implemented

func disconnect_twitch() -> void:
	_twitch_channel = ""
	print("[StreamerOverlay] Twitch disconnected")

func is_twitch_connected() -> bool:
	return false  # Stub

func read_twitch_chat() -> Array:
	return []  # Stub: no messages

# YouTube integration stubs
func connect_youtube(channel_id: String) -> bool:
	_youtube_channel = channel_id
	print("[StreamerOverlay] YouTube connection stub for: %s" % channel_id)
	return false  # Stub: not implemented

func disconnect_youtube() -> void:
	_youtube_channel = ""
	print("[StreamerOverlay] YouTube disconnected")

func is_youtube_connected() -> bool:
	return false  # Stub

func read_youtube_chat() -> Array:
	return []  # Stub: no messages

# OAuth stub
func set_oauth_token(token: String) -> void:
	_oauth_token = token
	print("[StreamerOverlay] OAuth token set (stub)")

func has_oauth_token() -> bool:
	return not _oauth_token.is_empty()

# Viewer count
func set_viewer_count(count: int) -> void:
	_viewer_count = count

func get_viewer_count() -> int:
	return _viewer_count

func simulate_viewer_count() -> void:
	_viewer_count += randi() % 5 - 2
	_viewer_count = maxi(0, _viewer_count)

# Chat simulation (for demo purposes)
func simulate_chat_message(username: String, message: String) -> void:
	var formatted := "[%s] %s" % [username, message]
	_chat_messages.append(formatted)
	if _chat_messages.size() > _max_chat_messages:
		_chat_messages.pop_front()
	chat_message_received.emit(username, message)

func get_recent_chat(count: int = 10) -> Array[String]:
	var result: Array[String] = []
	var start := maxi(0, _chat_messages.size() - count)
	for i in range(start, _chat_messages.size()):
		result.append(_chat_messages[i])
	return result

func get_overlay_info() -> Dictionary:
	return {
		"is_streaming": _is_streaming,
		"channel": _stream_channel,
		"title": _stream_title,
		"viewer_count": _viewer_count,
		"twitch_connected": _twitch_channel != "",
		"youtube_connected": _youtube_channel != "",
		"chat_message_count": _chat_messages.size()
	}

# Twitch/YouTube OAuth stub methods
func twitch_oauth_connect(client_id: String, redirect_uri: String) -> bool:
	push_warning("[StreamerOverlay] twitch_oauth_connect() is a stub — returns false")
	return false

func youtube_oauth_connect(client_id: String, redirect_uri: String) -> bool:
	push_warning("[StreamerOverlay] youtube_oauth_connect() is a stub — returns false")
	return false

func is_online() -> bool:
	return _is_streaming
