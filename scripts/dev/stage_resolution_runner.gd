extends SceneTree

const StageResolutionService = preload("res://scripts/battle/stage_resolution_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var service := StageResolutionService.new()
	var data := ProgressionData.new()
	var report := {
		"stage_id": &"CH04_05",
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

	service.resolve(report, data)

	if not data.cleared_stage_ids.has(&"CH04_05"):
		return _fail("resolve should register cleared stage ids.")
	if not data.recovered_fragments.has(&"mem_frag_ch04_test"):
		return _fail("resolve should persist obtained memory fragment ids.")
	if not bool(data.flags.get("evidence:ark_research_log_a", false)):
		return _fail("resolve should commit obtained evidence ids into progression flags.")
	if not bool(data.flags.get("npc:ark_technician", false)):
		return _fail("resolve should commit rescued npc ids into progression flags.")
	if not bool(data.flags.get("flag_resonance_serin", false)):
		return _fail("resolve should still emit mapped resonance flags when required battle flags are met.")
	if not data.has_method("get_stage_clear_record"):
		return _fail("ProgressionData should expose get_stage_clear_record for persisted stage reports.")
	var stage_record: Dictionary = data.call("get_stage_clear_record", &"CH04_05")
	if stage_record.is_empty():
		return _fail("resolve should persist a stage clear record payload.")
	if int(Dictionary(stage_record.get("battle_temp_counters", {})).get("research_logs", 0)) != 2:
		return _fail("stage clear record should persist battle_temp_counters.")
	if int(Dictionary(stage_record.get("telemetry", {})).get("rounds", 0)) != 5:
		return _fail("stage clear record should persist telemetry payload.")

	var save_service := SaveService.new()
	root.add_child(save_service)
	await process_frame
	var err := save_service.save_progression(data, 2)
	if err != OK:
		return _fail("save_progression should persist stage resolution data.")
	var loaded := save_service.load_progression(2)
	save_service.delete_slot(2)
	if loaded == null:
		return _fail("stage resolution runner should load saved progression data.")
	if not bool(loaded.flags.get("evidence:ark_research_log_b", false)):
		return _fail("obtained evidence ids should survive save/load.")
	if not loaded.has_method("get_stage_clear_record"):
		return _fail("loaded ProgressionData should expose get_stage_clear_record.")
	var loaded_record: Dictionary = loaded.call("get_stage_clear_record", &"CH04_05")
	if int(Dictionary(loaded_record.get("battle_temp_counters", {})).get("rescued_scholars", 0)) != 1:
		return _fail("stage clear record counters should survive save/load.")

	print("[PASS] stage_resolution_runner: stage resolution commits progression and survives save/load.")
	quit(0)

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
