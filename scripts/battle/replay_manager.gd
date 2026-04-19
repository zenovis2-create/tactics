class_name ReplayManager
extends Node

# Replay Manager — CRUD operations for battle replays
# Handles local storage of user-recorded battles for the Replay Market

signal replay_uploaded(replay_id: StringName)
signal replay_deleted(replay_id: StringName)

const SAVE_PATH := "user://replays/"
const INDEX_FILE := "user://replays/index.dat"

var _replay_index: Array[String] = []

func _ready() -> void:
	_ensure_save_directory()
	_load_index()

func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_recursive_absolute(SAVE_PATH)

func _load_index() -> void:
	if FileAccess.file_exists(INDEX_FILE):
		var f := FileAccess.open(INDEX_FILE, FileAccess.READ)
		if f != null:
			var data: Dictionary = f.get_var()
			_replay_index = Array(data.get("replay_ids", []))

func _save_index() -> void:
	var f := FileAccess.open(INDEX_FILE, FileAccess.WRITE)
	if f != null:
		f.store_var({"replay_ids": _replay_index})

func save_replay(replay: Resource) -> StringName:
	if replay == null:
		return &""
	var replay_id: StringName = replay.get("replay_id")
	if replay_id == null:
		replay_id = &""
	if replay_id == &"":
		replay_id = StringName("replay_%d" % Time.get_unix_time_from_system())
		replay.set("replay_id", replay_id)
	var path := "%s%s.tres" % [SAVE_PATH, replay_id]
	var err := ResourceSaver.save(replay, path)
	if err == OK:
		if not _replay_index.has(String(replay_id)):
			_replay_index.append(String(replay_id))
			_save_index()
		replay_uploaded.emit(replay_id)
	return replay_id

func load_replay(replay_id: StringName) -> Resource:
	var path := "%s%s.tres" % [SAVE_PATH, replay_id]
	if not FileAccess.file_exists(path):
		return null
	return ResourceLoader.load(path)

func delete_replay(replay_id: StringName) -> bool:
	var path := "%s%s.tres" % [SAVE_PATH, replay_id]
	if not FileAccess.file_exists(path):
		return false
	var err := DirAccess.remove_absolute(path)
	if err == OK:
		_replay_index.erase(String(replay_id))
		_save_index()
		replay_deleted.emit(replay_id)
		return true
	return false

func get_all_replays() -> Array:
	var replays: Array = []
	for replay_id: String in _replay_index:
		var replay: Resource = load_replay(StringName(replay_id))
		if replay != null:
			replays.append(replay)
	return replays

func get_replay_count() -> int:
	return _replay_index.size()

func get_replays_by_chapter(chapter_id: String) -> Array:
	var results: Array = []
	for replay in get_all_replays():
		if replay != null and replay.get("chapter_id") == chapter_id:
			results.append(replay)
	return results

func clear_all_replays() -> void:
	for replay_id: String in _replay_index:
		var path := "%s%s.tres" % [SAVE_PATH, replay_id]
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	_replay_index.clear()
	_save_index()

# Online stubs — return false/null in offline mode
func upload_replay_to_server(replay_id: StringName) -> bool:
	push_warning("[ReplayManager] upload_replay_to_server() is a stub — returns false in offline mode")
	return false

func download_replay(server_replay_id: String) -> Resource:
	push_warning("[ReplayManager] download_replay() is a stub — returns null in offline mode")
	return null

func is_online() -> bool:
	return false

func list_server_replays() -> Array:
	push_warning("[ReplayManager] list_server_replays() is a stub — returns empty array in offline mode")
	return []
