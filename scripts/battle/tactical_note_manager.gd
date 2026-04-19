class_name TacticalNoteManager
extends Node

const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const TacticalNote = preload("res://scripts/battle/tactical_note.gd")

# Offline-first stub flag for future async/server sync work.
const ONLINE_SYNC_CONFIGURED := false

var notes: Array[TacticalNote] = []

var _active_slot: int = 0
var _progression_data: ProgressionData = ProgressionData.new()
var _save_service: SaveService

func _ready() -> void:
	if _save_service == null:
		_save_service = SaveService.new()
		add_child(_save_service)
	call_deferred("reload_active_slot")

func set_active_slot(slot: int) -> void:
	_active_slot = maxi(0, slot)
	reload_active_slot()

func get_active_slot() -> int:
	return _active_slot

func bind_progression_data(data: ProgressionData) -> void:
	_progression_data = data if data != null else ProgressionData.new()
	_sync_notes_from_progression()

func reload_active_slot() -> void:
	if _save_service == null:
		return
	_progression_data = _save_service.load_progression(_active_slot)
	_sync_notes_from_progression()

func create_note(name: String, tags: Array, formations: Array, desc: String, difficulty: int) -> TacticalNote:
	var note := TacticalNote.new().setup(name, tags, formations, desc, difficulty)
	notes.append(note)
	_persist_notes()
	return note

func delete_note(note_id: String) -> void:
	var index := _find_note_index(note_id)
	if index < 0:
		return
	notes.remove_at(index)
	_persist_notes()

func update_note(note_id: String, updates: Dictionary) -> void:
	var note := get_note_by_id(note_id)
	if note == null:
		return
	note.apply_updates(updates)
	_persist_notes()

func get_note_by_id(note_id: String) -> TacticalNote:
	var normalized_id := note_id.strip_edges()
	if normalized_id.is_empty():
		return null
	for note in notes:
		if note != null and note.note_id == normalized_id:
			return note
	return null

func get_notes_by_tag(tag: String) -> Array[TacticalNote]:
	var matches: Array[TacticalNote] = []
	var normalized_tag := tag.strip_edges()
	if normalized_tag.is_empty():
		return matches
	for note in notes:
		if note != null and note.tags.has(normalized_tag):
			matches.append(note)
	return matches

func get_notes_by_difficulty(d: int) -> Array[TacticalNote]:
	var matches: Array[TacticalNote] = []
	for note in notes:
		if note != null and note.difficulty_rating == d:
			matches.append(note)
	return matches

func increment_usage(note_id: String) -> void:
	var note := get_note_by_id(note_id)
	if note == null:
		return
	note.usage_count += 1
	_persist_notes()

func upload_tactic_to_server(_note_id: String) -> void:
	print("ONLINE_SYNC_STUB: server not configured")

func download_tactic_from_server(_tactic_id: String) -> TacticalNote:
	print("ONLINE_SYNC_STUB: server not configured")
	return null

func is_online_mode() -> bool:
	print("OFFLINE_MODE")
	return ONLINE_SYNC_CONFIGURED

func _find_note_index(note_id: String) -> int:
	var normalized_id := note_id.strip_edges()
	for index in range(notes.size()):
		var note := notes[index]
		if note != null and note.note_id == normalized_id:
			return index
	return -1

func _sync_notes_from_progression() -> void:
	notes.clear()
	if _progression_data == null:
		_progression_data = ProgressionData.new()
	for note in _progression_data.tactical_notes:
		if note != null:
			notes.append(note)

func _persist_notes() -> void:
	if _progression_data == null:
		_progression_data = ProgressionData.new()
	_progression_data.tactical_notes = notes.duplicate()
	if _save_service != null:
		var save_error := _save_service.save_progression(_progression_data, _active_slot)
		if save_error != OK:
			push_warning("[TacticalNoteManager] Failed to save slot %d: %s" % [_active_slot, error_string(save_error)])
