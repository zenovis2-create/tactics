class_name StageResolutionService
extends RefCounted

## Interprets StageClearReport and commits progression state to SaveData.
## See flag_progression_spec.md for design rules.

const ProgressionData = preload("res://scripts/data/progression_data.gd")

const STAGE_MEMORY_FLAGS := {
	&"CH01_05": "flag_memory_ch01_first_order_seen",
	&"CH02_05": "flag_memory_ch02_hardren_blueprint_seen",
	&"CH03_05": "flag_memory_ch03_forest_fire_order_seen",
	&"CH04_05": "flag_memory_ch04_ark_research_seen",
	&"CH05_05": "flag_memory_ch05_zero_revealed",
	&"CH06_05": "flag_memory_ch06_fortress_breach_context_seen",
	&"CH07_05": "flag_memory_ch07_zero_named_by_karon_seen",
	&"CH08_05": "flag_memory_ch08_north_corridor_context_seen",
	&"CH09A_05": "flag_memory_ch09a_returning_names_seen",
	&"CH09B_05": "flag_memory_ch09b_final_restored",
}

const STAGE_EVIDENCE_FLAGS := {
	&"CH01_05": "flag_evidence_hardren_seal_obtained",
	&"CH02_05": "flag_evidence_greenwood_orders_obtained",
	&"CH03_05": "flag_evidence_monastery_manifest_obtained",
	&"CH04_05": "flag_evidence_archive_transfer_obtained",
	&"CH05_05": "flag_evidence_fortress_ledger_obtained",
	&"CH06_05": "flag_evidence_elyor_edict_obtained",
	&"CH07_05": "flag_evidence_black_hound_orders_obtained",
	&"CH08_05": "flag_evidence_outer_gate_writ_obtained",
	&"CH09A_05": "flag_evidence_root_archive_pass_obtained",
	&"CH09B_05": "flag_evidence_eclipse_coords_obtained",
	&"CH10_05": "flag_ending_resolution_recorded",
}

const STAGE_RECRUITS := {
	&"CH02_05": &"ally_bran",
	&"CH03_05": &"ally_tia",
	&"CH05_05": &"ally_enoch",
	&"CH09A_05": &"ally_kyle",
	&"CH09B_05": &"ally_noah",
}

const STAGE_HUNT_UNLOCKS := {
	&"CH04_05": &"hunt_basil",
	&"CH07_05": &"hunt_saria",
	&"CH08_05": &"hunt_lete",
}

const STAGE_RESONANCE_FLAGS := {
	&"CH04_05": {"required_flag": "collect_2_research_logs", "result_flag": "flag_resonance_serin"},
	&"CH05_05": {"required_flag": "collect_3_ledger_entries", "result_flag": "flag_resonance_enoch"},
	&"CH06_05": {"required_flag": "fort_resistance_zero", "result_flag": "flag_resonance_bran"},
	&"CH08_05": {"required_flag": "lete_defects_alive", "result_flag": "flag_resonance_tia"},
	&"CH09A_05": {"required_flag": "karl_testifies", "result_flag": "flag_resonance_karl"},
	&"CH09B_05": {"required_flag": "noah_survives", "result_flag": "flag_resonance_noah"},
}

## StageClearReport from BattleController
## {stage_id, cleared, defeated_boss_id, optional_objective_ids_completed,
##  rescued_npc_ids, obtained_memory_fragment_id, obtained_evidence_ids,
##  opened_treasure_ids, battle_temp_counters, battle_temp_flags}

func resolve(report: Dictionary, data: ProgressionData) -> ProgressionData:
	if report.get("cleared", false) == false:
		return data

	var stage_id: StringName = report.get("stage_id", &"")
	if stage_id == &"":
		return data

	# 1. Register cleared stage
	_register_cleared_stage(data, stage_id)

	# 2. Set chapter completion flags
	_set_chapter_flags(data, stage_id)

	# 3. Register memory fragments / memory flags
	_register_memory_fragments(data, stage_id, report)

	# 4. Register evidence flags
	_register_evidence(data, stage_id, report)

	# 5. Register rescued NPCs
	_register_rescued_npcs(data, report)

	# 6. Register treasure
	_register_treasure(data, report)

	# 7. Persist normalized stage clear record
	_persist_stage_clear_record(data, stage_id, report)

	# 8. Unlock systems
	_unlock_systems(data, stage_id)

	# 9. Handle recruitment
	_handle_recruitment(data, stage_id)

	# 10. Handle resonance seals
	_handle_resonance(data, stage_id, report)

	# 11. Handle stage objective / line flags
	_handle_stage_flags(data, stage_id, report)

	# 12. Handle hunt unlocks
	_handle_hunt_unlocks(data, stage_id)

	return data

# --- Internal ---

func _register_cleared_stage(data: ProgressionData, stage_id: StringName) -> void:
	var cleared: Array[StringName] = data.cleared_stage_ids.duplicate()
	if not cleared.has(stage_id):
		cleared.append(stage_id)
	data.cleared_stage_ids = cleared

func _set_chapter_flags(data: ProgressionData, stage_id: StringName) -> void:
	var chapter_key := _extract_chapter_key(stage_id)
	if chapter_key == &"":
		return

	var flag_key: String = "flag_%s_complete" % String(chapter_key).trim_suffix("_")
	data.flags[flag_key] = true

func _register_memory_fragments(data: ProgressionData, stage_id: StringName, report: Dictionary) -> void:
	var frag_id: String = String(report.get("obtained_memory_fragment_id", "")).strip_edges()
	if not frag_id.is_empty():
		data.recovered_fragments[StringName(frag_id)] = true
	var flag_key: String = String(STAGE_MEMORY_FLAGS.get(stage_id, "")).strip_edges()
	if not flag_key.is_empty():
		data.flags[flag_key] = true

func _register_evidence(data: ProgressionData, stage_id: StringName, report: Dictionary) -> void:
	var flag_key: String = String(STAGE_EVIDENCE_FLAGS.get(stage_id, "")).strip_edges()
	if not flag_key.is_empty():
		data.flags[flag_key] = true
	for evidence_id_variant in report.get("obtained_evidence_ids", []):
		var evidence_id: String = String(evidence_id_variant).strip_edges()
		if evidence_id.is_empty():
			continue
		data.flags[evidence_id] = true

func _register_rescued_npcs(data: ProgressionData, report: Dictionary) -> void:
	for npc_id_variant in report.get("rescued_npc_ids", []):
		var npc_id: String = String(npc_id_variant).strip_edges()
		if npc_id.is_empty():
			continue
		data.flags[npc_id] = true

func _register_treasure(data: ProgressionData, report: Dictionary) -> void:
	var treasure_ids: Array = report.get("opened_treasure_ids", [])
	for tid_variant in treasure_ids:
		var tid: String = String(tid_variant).strip_edges()
		if tid.is_empty():
			continue
		if not data.discovered_treasure_ids.has(tid):
			data.discovered_treasure_ids.append(tid)

func _persist_stage_clear_record(data: ProgressionData, stage_id: StringName, report: Dictionary) -> void:
	data.set_stage_clear_record(stage_id, {
		"stage_id": String(stage_id),
		"cleared": bool(report.get("cleared", false)),
		"optional_objective_ids_completed": Array(report.get("optional_objective_ids_completed", [])).duplicate(true),
		"obtained_memory_fragment_id": String(report.get("obtained_memory_fragment_id", "")).strip_edges(),
		"obtained_evidence_ids": Array(report.get("obtained_evidence_ids", [])).duplicate(true),
		"rescued_npc_ids": Array(report.get("rescued_npc_ids", [])).duplicate(true),
		"opened_treasure_ids": Array(report.get("opened_treasure_ids", [])).duplicate(true),
		"battle_temp_counters": Dictionary(report.get("battle_temp_counters", {})).duplicate(true),
		"battle_temp_flags": Dictionary(report.get("battle_temp_flags", {})).duplicate(true),
		"telemetry": Dictionary(report.get("telemetry", {})).duplicate(true),
	})

func _unlock_systems(data: ProgressionData, stage_id: StringName) -> void:
	var unlocks: Dictionary = {
		&"ch02": ["flag_system_inventory_unlocked", "flag_system_accessory_unlocked"],
		&"ch03": ["flag_system_armor_unlocked"],
		&"ch04": ["flag_system_hunt_board_unlocked"],
		&"ch05": ["flag_system_salvage_unlocked", "flag_system_sigil_ledger_unlocked"],
		&"ch06": ["flag_system_forge_unlocked"],
		&"ch07": ["flag_system_sigil_tuning_unlocked"],
		&"ch09b": ["flag_system_select_craft_unlocked", "flag_system_affix_calibration_unlocked"],
	}

	var chapter_key: StringName = _extract_chapter_key(stage_id)
	if unlocks.has(chapter_key):
		for flag_name: String in unlocks[chapter_key]:
			data.flags[flag_name] = true

func _handle_recruitment(data: ProgressionData, stage_id: StringName) -> void:
	var recruited_id: StringName = STAGE_RECRUITS.get(stage_id, &"")
	if recruited_id == &"":
		return
	var progress: Dictionary = data.get_unit_progress(recruited_id)
	progress["recruited"] = true
	data.unit_progression[String(recruited_id)] = progress

func _handle_resonance(data: ProgressionData, stage_id: StringName, report: Dictionary) -> void:
	var entry: Dictionary = STAGE_RESONANCE_FLAGS.get(stage_id, {})
	if entry.is_empty():
		return
	var required_flag: String = String(entry.get("required_flag", "")).strip_edges()
	var result_flag: String = String(entry.get("result_flag", "")).strip_edges()
	var battle_temp_flags: Dictionary = report.get("battle_temp_flags", {})
	if required_flag.is_empty() or result_flag.is_empty():
		return
	if bool(battle_temp_flags.get(required_flag, false)):
		data.flags[result_flag] = true

func _handle_stage_flags(data: ProgressionData, stage_id: StringName, report: Dictionary) -> void:
	var completed_objectives: Array = report.get("optional_objective_ids_completed", [])
	for objective_id_variant in completed_objectives:
		var objective_id: String = String(objective_id_variant).strip_edges()
		if objective_id.is_empty():
			continue
		data.flags[objective_id] = true
	var battle_temp_flags: Dictionary = report.get("battle_temp_flags", {})
	for key_variant in battle_temp_flags.keys():
		var key: String = String(key_variant).strip_edges()
		if key.is_empty():
			continue
		if bool(battle_temp_flags.get(key_variant, false)):
			data.flags[key] = true
	if stage_id == &"CH07_05" and bool(battle_temp_flags.get("recruit_mira", false)):
		data.flags["flag_ch07_mira_nery_rescued"] = true
	if stage_id == &"CH01_05" and bool(battle_temp_flags.get("flag_ch01_nery_saved", false)):
		data.flags["flag_ch01_nery_saved"] = true
	if stage_id == &"CH10_05" and bool(battle_temp_flags.get("final_bell_dais_held", false)):
		data.flags["flag_name_anchors_held_2plus"] = true

func _handle_hunt_unlocks(data: ProgressionData, stage_id: StringName) -> void:
	var hunt_id: StringName = STAGE_HUNT_UNLOCKS.get(stage_id, &"")
	if hunt_id == &"":
		return
	if not data.unlocked_hunt_ids.has(hunt_id):
		var ids = data.unlocked_hunt_ids.duplicate()
		ids.append(hunt_id)
		data.unlocked_hunt_ids = ids

func _extract_chapter_key(stage_id: StringName) -> StringName:
	var s := String(stage_id).to_lower()
	if s.begins_with("ch09a"):
		return &"ch09a"
	if s.begins_with("ch09b"):
		return &"ch09b"
	if s.begins_with("ch"):
		return StringName(s.left(4))
	elif s.begins_with("tutorial"):
		return &"ch01"
	return &""
