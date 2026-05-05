extends SceneTree

const StageResolutionService = preload("res://scripts/battle/stage_resolution_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")

const STAGE_ID := &"CH04_05"
const TEST_SLOT := 2

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var service := StageResolutionService.new()
	var data := ProgressionData.new()
	var report := _build_stage_report()

	service.resolve(report, data)

	if not _assert_progression_flags(data):
		return
	var stage_record: Dictionary = data.call("get_stage_clear_record", STAGE_ID)
	if not _assert_stage_clear_record(stage_record):
		return
	if not _assert_unlocks(data):
		return
	if not await _assert_save_load_roundtrip(data, stage_record):
		return

	print("[PASS] stage_resolution_runner: stage resolution commits progression, records, unlocks, and survives save/load.")
	quit(0)


func _build_stage_report() -> Dictionary:
	return {
		"stage_id": STAGE_ID,
		"cleared": true,
		"optional_objective_ids_completed": ["collect_2_research_logs"],
		"obtained_memory_fragment_id": "mem_frag_ch04_test",
		"obtained_evidence_ids": ["evidence:ark_research_log_a", "evidence:ark_research_log_b"],
		"rescued_npc_ids": ["npc:ark_technician"],
		"opened_treasure_ids": ["treasure:crypt_key"],
		"battle_temp_counters": {"research_logs": 2, "rescued_scholars": 1},
		"battle_temp_flags": {"collect_2_research_logs": true, "ark_survives_flooded_section": true},
		"telemetry": {"rounds": 5, "objective_completion_rate": 1.0}
	}


func _assert_progression_flags(data: ProgressionData) -> bool:
	if not data.cleared_stage_ids.has(STAGE_ID):
		return _fail("resolve should register cleared stage ids.")
	if not data.recovered_fragments.has(&"mem_frag_ch04_test"):
		return _fail("resolve should persist obtained memory fragment ids.")
	for flag_name in [
		"flag_ch04_complete",
		"flag_memory_ch04_ark_research_seen",
		"flag_evidence_archive_transfer_obtained",
		"evidence:ark_research_log_a",
		"evidence:ark_research_log_b",
		"npc:ark_technician",
		"collect_2_research_logs",
		"ark_survives_flooded_section",
		"flag_resonance_serin"
	]:
		if not bool(data.flags.get(flag_name, false)):
			return _fail("resolve should commit progression flag: %s" % flag_name)
	if not data.discovered_treasure_ids.has("treasure:crypt_key"):
		return _fail("resolve should persist opened treasure ids.")
	return true


func _assert_stage_clear_record(stage_record: Dictionary) -> bool:
	if stage_record.is_empty():
		return _fail("resolve should persist a stage clear record payload.")
	if String(stage_record.get("stage_id", "")) != String(STAGE_ID):
		return _fail("stage clear record should preserve stage_id.")
	if not bool(stage_record.get("cleared", false)):
		return _fail("stage clear record should preserve cleared=true.")
	var completed: Array = stage_record.get("optional_objective_ids_completed", [])
	if not completed.has("collect_2_research_logs"):
		return _fail("stage clear record should persist optional objective ids.")
	if String(stage_record.get("obtained_memory_fragment_id", "")) != "mem_frag_ch04_test":
		return _fail("stage clear record should persist obtained memory fragment id.")
	var evidence_ids: Array = stage_record.get("obtained_evidence_ids", [])
	if not evidence_ids.has("evidence:ark_research_log_a") or not evidence_ids.has("evidence:ark_research_log_b"):
		return _fail("stage clear record should persist all obtained evidence ids.")
	var rescued_ids: Array = stage_record.get("rescued_npc_ids", [])
	if not rescued_ids.has("npc:ark_technician"):
		return _fail("stage clear record should persist rescued npc ids.")
	var treasure_ids: Array = stage_record.get("opened_treasure_ids", [])
	if not treasure_ids.has("treasure:crypt_key"):
		return _fail("stage clear record should persist opened treasure ids.")
	var counters: Dictionary = stage_record.get("battle_temp_counters", {})
	if int(counters.get("research_logs", 0)) != 2:
		return _fail("stage clear record should persist research_logs counter.")
	if int(counters.get("rescued_scholars", 0)) != 1:
		return _fail("stage clear record should persist rescued_scholars counter.")
	var flags: Dictionary = stage_record.get("battle_temp_flags", {})
	if not bool(flags.get("collect_2_research_logs", false)) or not bool(flags.get("ark_survives_flooded_section", false)):
		return _fail("stage clear record should persist true battle_temp_flags.")
	var telemetry: Dictionary = stage_record.get("telemetry", {})
	if int(telemetry.get("rounds", 0)) != 5:
		return _fail("stage clear record should persist telemetry rounds.")
	if absf(float(telemetry.get("objective_completion_rate", -1.0)) - 1.0) > 0.001:
		return _fail("stage clear record should persist telemetry objective completion rate.")
	return true


func _assert_unlocks(data: ProgressionData) -> bool:
	if not bool(data.flags.get("flag_system_hunt_board_unlocked", false)):
		return _fail("CH04 clear should unlock the hunt board system flag.")
	if not data.unlocked_hunt_ids.has(&"hunt_basil"):
		return _fail("CH04_05 should unlock hunt_basil.")
	return true


func _assert_save_load_roundtrip(data: ProgressionData, original_record: Dictionary) -> bool:
	var save_service := SaveService.new()
	root.add_child(save_service)
	await process_frame
	var err := save_service.save_progression(data, TEST_SLOT, {"autosave_reason": "f102_stage_resolution_runner"})
	if err != OK:
		return _fail("save_progression should persist stage resolution data.")
	var peek: Dictionary = save_service.peek_slot(TEST_SLOT)
	if not bool(peek.get("exists", false)):
		return _fail("peek_slot should report the f102 save exists before cleanup.")
	if String(peek.get("autosave_reason", "")) != "f102_stage_resolution_runner":
		return _fail("save sidecar metadata should preserve f102 autosave_reason.")
	if String(peek.get("chapter", "")) != "CH04":
		return _fail("save sidecar metadata should derive CH04 from CH04_05 clear.")
	var loaded := save_service.load_progression(TEST_SLOT)
	if loaded == null:
		save_service.delete_slot(TEST_SLOT)
		return _fail("stage resolution runner should load saved progression data.")
	if not bool(loaded.flags.get("evidence:ark_research_log_b", false)):
		save_service.delete_slot(TEST_SLOT)
		return _fail("obtained evidence ids should survive save/load.")
	if not loaded.discovered_treasure_ids.has("treasure:crypt_key"):
		save_service.delete_slot(TEST_SLOT)
		return _fail("opened treasure ids should survive save/load.")
	if not loaded.unlocked_hunt_ids.has(&"hunt_basil"):
		save_service.delete_slot(TEST_SLOT)
		return _fail("hunt unlock ids should survive save/load.")
	if not loaded.has_method("get_stage_clear_record"):
		save_service.delete_slot(TEST_SLOT)
		return _fail("loaded ProgressionData should expose get_stage_clear_record.")
	var loaded_record: Dictionary = loaded.call("get_stage_clear_record", STAGE_ID)
	if loaded_record.is_empty():
		save_service.delete_slot(TEST_SLOT)
		return _fail("loaded ProgressionData should preserve the stage clear record.")
	if int(Dictionary(loaded_record.get("battle_temp_counters", {})).get("rescued_scholars", 0)) != 1:
		save_service.delete_slot(TEST_SLOT)
		return _fail("stage clear record counters should survive save/load.")
	if Dictionary(loaded_record.get("telemetry", {})) != Dictionary(original_record.get("telemetry", {})):
		save_service.delete_slot(TEST_SLOT)
		return _fail("stage clear record telemetry should survive save/load without drift.")
	save_service.delete_slot(TEST_SLOT)
	if save_service.slot_exists(TEST_SLOT):
		return _fail("stage resolution runner should clean up its save slot after verification.")
	return true


func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
