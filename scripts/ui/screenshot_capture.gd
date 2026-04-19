class_name ScreenshotCapture
extends Node

# ScreenshotCapture — stub for highlight detection and clip saving
# In production: integrates with ReplayManager to save highlight clips

signal highlight_detected(event_type: String, screenshot_path: String)
signal clip_saved(clip_id: String, path: String)

const SAVE_PATH := "user://highlights/"
const CLIP_DURATION_SEC := 10

var _capture_enabled: bool = false
var _highlight_threshold: float = 0.75
var _last_capture_time: float = 0.0
var _capture_cooldown: float = 3.0
var _pending_highlights: Array = []

func _ready() -> void:
	_capture_enabled = false
	_ensure_save_directory()

func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_recursive_absolute(SAVE_PATH)

func enable_capture() -> void:
	_capture_enabled = true
	print("[ScreenshotCapture] Capture enabled")

func disable_capture() -> void:
	_capture_enabled = false
	print("[ScreenshotCapture] Capture disabled")

func is_capture_enabled() -> bool:
	return _capture_enabled

# Stub: Evaluate a battle event and decide if it's a highlight
func evaluate_event(event_data: Dictionary) -> bool:
	if not _capture_enabled:
		return false
	var event_type: String = event_data.get("type", "")
	if event_type.is_empty():
		return false
	# Simple threshold-based highlight detection
	var intensity: float = event_data.get("intensity", 0.0)
	var dramatic: bool = event_data.get("dramatic", false)
	var is_highlight := intensity >= _highlight_threshold or dramatic
	if is_highlight:
		var now := Time.get_unix_time_from_system()
		if now - _last_capture_time >= _capture_cooldown:
			_last_capture_time = now
			_queue_highlight(event_data)
	return is_highlight

func _queue_highlight(event_data: Dictionary) -> void:
	var highlight_id := "hl_%d" % Time.get_unix_time_from_system()
	var path := _generate_screenshot_path(highlight_id)
	_pending_highlights.append({
		"id": highlight_id,
		"path": path,
		"event_data": event_data
	})
	highlight_detected.emit(event_data.get("type", "unknown"), path)

func _generate_screenshot_path(highlight_id: String) -> String:
	return "%s%s.png" % [SAVE_PATH, highlight_id]

# Stub: Take a screenshot. In real implementation, this uses godot's
# viewport texture capture. Returns path on success, empty string on failure.
func capture_screenshot(label: String = "highlight") -> String:
	if not _capture_enabled:
		push_warning("[ScreenshotCapture] Capture not enabled, screenshot skipped")
		return ""
	var screenshot_id := "ss_%s_%d" % [label, Time.get_unix_time_from_system()]
	var path := "%s%s.png" % [SAVE_PATH, screenshot_id]
	print("[ScreenshotCapture] Screenshot captured: %s" % path)
	return path

# Stub: Save a clip (in real implementation, would capture last N seconds)
func save_clip(clip_id: String, duration_sec: int = CLIP_DURATION_SEC) -> String:
	var path := "%s%s.webm" % [SAVE_PATH, clip_id]
	print("[ScreenshotCapture] Clip saved: %s (%ds)" % [path, duration_sec])
	clip_saved.emit(clip_id, path)
	return path

func set_highlight_threshold(threshold: float) -> void:
	_highlight_threshold = clampf(threshold, 0.0, 1.0)

func get_highlight_threshold() -> float:
	return _highlight_threshold

func set_capture_cooldown(cooldown: float) -> void:
	_capture_cooldown = maxf(cooldown, 0.5)

func get_pending_highlights() -> Array:
	return _pending_highlights.duplicate()

func clear_pending_highlights() -> void:
	_pending_highlights.clear()

# Stub: Save highlight metadata to ReplayManager
func save_highlight_to_replay(replay_id: StringName, highlight_path: String) -> bool:
	push_warning("[ScreenshotCapture] save_highlight_to_replay() is a stub — replay integration not implemented")
	return false
