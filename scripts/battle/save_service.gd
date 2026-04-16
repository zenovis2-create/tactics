class_name SaveService
extends Node

## Disk persistence for ProgressionData.
## Saves to user://saves/slot_N.tres (ResourceSaver) with JSON sidecar for inspection.

const ProgressionData = preload("res://scripts/data/progression_data.gd")
const CampaignCatalog = preload("res://scripts/campaign/campaign_catalog.gd")

const SAVE_DIR := "user://saves/"
const SLOT_PREFIX := "slot_"
const SLOT_EXT := ".tres"
const SIDECAR_EXT := ".json"

const DEFAULT_ENDING_TENDENCY := "undetermined"

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
	var slot_has_save := slot_exists(slot)
	var metadata := _build_slot_metadata(slot_has_save)
	var sidecar := _sidecar_path(slot)
	if not FileAccess.file_exists(sidecar):
		return metadata
	var file := FileAccess.open(sidecar, FileAccess.READ)
	if file == null:
		return metadata
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		for key: String in (parsed as Dictionary).keys():
			metadata[key] = parsed[key]
	return metadata

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
	snapshot["exists"] = true
	snapshot["chapter"] = ""
	snapshot["saved_at"] = Time.get_datetime_string_from_system()
	snapshot["unit_progression_summary"] = _build_unit_progression_summary(data)
	file.store_string(JSON.stringify(snapshot, "\t"))
	file.close()

func _build_slot_metadata(exists: bool) -> Dictionary:
	return {
		"exists": exists,
		"chapter": "",
		"burden": 0,
		"trust": 0,
		"ending_tendency": DEFAULT_ENDING_TENDENCY,
		"saved_at": "",
		"unit_progression_summary": ""
	}

func _build_unit_progression_summary(data: ProgressionData) -> String:
	var snapshot: Dictionary = data.get_unit_progress_snapshot()
	if snapshot.is_empty():
		return ""
	var best_unit: String = ""
	var best_level: int = -1
	var best_exp: int = -1
	for unit_id in snapshot.keys():
		var entry: Dictionary = snapshot.get(unit_id, {})
		var level: int = int(entry.get("level", 1))
		var exp: int = int(entry.get("exp", 0))
		var unit_data = CampaignCatalog.get_unit_data(StringName(unit_id))
		var display_name: String = unit_data.display_name if unit_data != null else String(unit_id)
		if level > best_level or (level == best_level and exp > best_exp):
			best_unit = display_name
			best_level = level
			best_exp = exp
	return "%d units | top %s Lv %d (%d EXP)" % [snapshot.size(), best_unit, best_level, best_exp]
