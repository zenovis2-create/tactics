class_name SaveService
extends Node

## Disk persistence for ProgressionData.
## Saves to user://saves/slot_N.tres (ResourceSaver) with JSON sidecar for inspection.

const ProgressionData = preload("res://scripts/data/progression_data.gd")

const SAVE_DIR := "user://saves/"
const SLOT_PREFIX := "slot_"
const SLOT_EXT := ".tres"
const SIDECAR_EXT := ".json"

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

# --- Public API ---

## Save ProgressionData to the given slot (default 0).
func save_progression(data: ProgressionData, slot: int = 0) -> Error:
	var path := _slot_path(slot)
	var err := ResourceSaver.save(data, path)
	if err == OK:
		_write_sidecar(data, slot)
		print("[SaveService] Saved to %s" % path)
	else:
		push_warning("[SaveService] ResourceSaver failed for slot %d: %s" % [slot, error_string(err)])
	return err

## Load ProgressionData from the given slot. Returns a fresh default if not found.
func load_progression(slot: int = 0) -> ProgressionData:
	var path := _slot_path(slot)
	if not ResourceLoader.exists(path):
		print("[SaveService] No save at slot %d — returning default." % slot)
		return ProgressionData.new()

	var loaded = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if loaded is ProgressionData:
		print("[SaveService] Loaded slot %d from %s" % [slot, path])
		return loaded as ProgressionData
	else:
		push_warning("[SaveService] Slot %d data is not ProgressionData — returning default." % slot)
		return ProgressionData.new()

## Delete a save slot.
func delete_slot(slot: int = 0) -> void:
	var path := _slot_path(slot)
	if ResourceLoader.exists(path):
		DirAccess.remove_absolute(path)
	var sidecar := _sidecar_path(slot)
	if FileAccess.file_exists(sidecar):
		DirAccess.remove_absolute(sidecar)

## Returns true if a save exists for the given slot.
func slot_exists(slot: int = 0) -> bool:
	return ResourceLoader.exists(_slot_path(slot))

## Returns the burden/trust/tendency from a slot without full load (reads sidecar JSON).
func peek_slot(slot: int = 0) -> Dictionary:
	var sidecar := _sidecar_path(slot)
	if not FileAccess.file_exists(sidecar):
		return {}
	var file := FileAccess.open(sidecar, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	file.close()
	var parsed := JSON.parse_string(text)
	if parsed is Dictionary:
		return parsed
	return {}

# --- Internal ---

func _slot_path(slot: int) -> String:
	return SAVE_DIR + SLOT_PREFIX + str(slot) + SLOT_EXT

func _sidecar_path(slot: int) -> String:
	return SAVE_DIR + SLOT_PREFIX + str(slot) + SIDECAR_EXT

func _write_sidecar(data: ProgressionData, slot: int) -> void:
	var sidecar := _sidecar_path(slot)
	var file := FileAccess.open(sidecar, FileAccess.WRITE)
	if file == null:
		return
	var snapshot := data.to_debug_dict()
	snapshot["saved_at"] = Time.get_datetime_string_from_system()
	file.store_string(JSON.stringify(snapshot, "\t"))
	file.close()
