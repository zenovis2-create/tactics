class_name SaveService
extends Node

## Disk persistence for ProgressionData.
## Saves to user://saves/slot_N.tres (ResourceSaver) with JSON sidecar for inspection.

const ProgressionData = preload("res://scripts/data/progression_data.gd")
const EndingResolver = preload("res://scripts/battle/ending_resolver.gd")
const CampaignCatalog = preload("res://scripts/campaign/campaign_catalog.gd")

const SAVE_DIR := "user://saves/"
const SLOT_PREFIX := "slot_"
const SLOT_EXT := ".tres"
const SIDECAR_EXT := ".json"
const MANUAL_SLOT_COUNT := 3
const AUTOSAVE_SLOT := 3

const DEFAULT_ENDING_TENDENCY := "undetermined"

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

# --- Public API ---

## Save ProgressionData to the given slot (default 0).
func save_progression(data: ProgressionData, slot: int = 0, extra_metadata: Dictionary = {}) -> Error:
	if data != null:
		data.migrate_legacy_ids()
	var path := _slot_path(slot)
	var err := ResourceSaver.save(data, path)
	if err == OK:
		_write_sidecar(data, slot, extra_metadata)
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
		(loaded as ProgressionData).migrate_legacy_ids()
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
	var metadata := _build_slot_metadata(slot_has_save, slot)
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

func _write_sidecar(data: ProgressionData, slot: int, extra_metadata: Dictionary = {}) -> void:
	var sidecar := _sidecar_path(slot)
	var file := FileAccess.open(sidecar, FileAccess.WRITE)
	if file == null:
		return
	var snapshot := data.to_debug_dict()
	snapshot["exists"] = true
	snapshot["chapter"] = _derive_latest_chapter(data)
	snapshot.merge(_build_ending_progress_snapshot(data))
	snapshot["saved_at"] = Time.get_datetime_string_from_system()
	snapshot["unit_progression_summary"] = _build_unit_progression_summary(data)
	if not extra_metadata.is_empty():
		snapshot.merge(extra_metadata, true)
	file.store_string(JSON.stringify(snapshot, "\t"))
	file.close()

func _build_slot_metadata(exists: bool, slot: int) -> Dictionary:
	return {
		"exists": exists,
		"is_autosave": slot == AUTOSAVE_SLOT,
		"slot_label": "자동저장" if slot == AUTOSAVE_SLOT else "슬롯 %d" % slot,
		"autosave_reason": "",
		"chapter": "",
		"burden": 0,
		"trust": 0,
		"gold": 0,
		"ending_tendency": DEFAULT_ENDING_TENDENCY,
		"ng_plus_available": false,
		"last_completed_ending": "",
		"ending_resonance_count": 0,
		"ending_name_anchors_ok": false,
		"ending_all_name_calls": false,
		"saved_at": "",
		"unit_progression_summary": ""
	}

func _build_ending_progress_snapshot(data: ProgressionData) -> Dictionary:
	var status: Dictionary = EndingResolver.get_ending_conditions_status(data)
	var missing_resonance: Array = status.get("missing_resonance_flags", [])
	return {
		"ending_resonance_count": EndingResolver.REQUIRED_RESONANCE_FLAGS.size() - missing_resonance.size(),
		"ending_name_anchors_ok": bool(status.get("name_anchors_ok", false)),
		"ending_all_name_calls": bool(status.get("all_name_calls", false)),
	}

func _derive_latest_chapter(data: ProgressionData) -> String:
	if data == null:
		return ""
	var best_rank: int = -1
	var best_label: String = ""
	for stage_id_variant in data.cleared_stage_ids:
		var stage_id: String = String(stage_id_variant).to_upper()
		if not stage_id.begins_with("CH"):
			continue
		var chapter_label := _extract_chapter_label(stage_id)
		var rank := _chapter_rank_for_label(chapter_label)
		if rank > best_rank:
			best_rank = rank
			best_label = chapter_label
	return best_label

func _extract_chapter_label(stage_id: String) -> String:
	var upper := stage_id.to_upper()
	if upper.begins_with("CH09A"):
		return "CH09A"
	if upper.begins_with("CH09B"):
		return "CH09B"
	for idx in range(2, upper.length()):
		if not upper[idx].is_valid_int():
			var digits := upper.substr(2, idx - 2)
			if digits.is_empty():
				return ""
			return "CH%s" % digits.pad_zeros(2)
	return ""

func _chapter_rank_for_label(chapter_label: String) -> int:
	match chapter_label:
		"CH01":
			return 1
		"CH02":
			return 2
		"CH03":
			return 3
		"CH04":
			return 4
		"CH05":
			return 5
		"CH06":
			return 6
		"CH07":
			return 7
		"CH08":
			return 8
		"CH09A":
			return 9
		"CH09B":
			return 10
		"CH10":
			return 11
		_:
			return -1

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
