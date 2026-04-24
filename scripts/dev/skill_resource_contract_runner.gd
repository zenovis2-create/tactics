extends SceneTree

const SkillData = preload("res://scripts/data/skill_data.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not _assert_skill_schema_contract():
		return
	if not _assert_representative_skill_resources():
		return
	if not _assert_core_ally_skill_loadouts():
		return
	print("[PASS] skill_resource_contract_runner: all assertions passed.")
	quit(0)

func _assert_skill_schema_contract() -> bool:
	var skill := SkillData.new()
	if skill.exp_to_next_level(1) != 30:
		return _fail("SkillData.exp_to_next_level(1) should return 30.")
	if skill.exp_to_next_level(4) != 150:
		return _fail("SkillData.exp_to_next_level(4) should return 150.")
	if skill.exp_to_next_level(5) != 0:
		return _fail("SkillData.exp_to_next_level() should return 0 at max level.")
	skill.power_modifier = 2
	skill.skill_level = 3
	skill.power_modifier_by_level = {3: 4}
	if skill.get_effective_power_modifier() != 6:
		return _fail("SkillData should apply power_modifier_by_level bonus at current level.")
	skill.skill_exp = 40
	if skill.exp_remaining() != 60:
		return _fail("SkillData.exp_remaining() should subtract current EXP from next threshold.")
	return true

func _assert_representative_skill_resources() -> bool:
	var tactical_shift: SkillData = load("res://data/skills/tactical_shift.tres")
	var collapse_line: SkillData = load("res://data/skills/collapse_line.tres")
	var command_marker: SkillData = load("res://data/skills/command_marker.tres")
	var ark_breath: SkillData = load("res://data/skills/ark_breath.tres")
	var never_forget: SkillData = load("res://data/skills/never_forget.tres")
	var iron_wall: SkillData = load("res://data/skills/iron_wall.tres")
	var pin_shot: SkillData = load("res://data/skills/pin_shot.tres")
	var memory_burn: SkillData = load("res://data/skills/memory_burn.tres")
	var comet_charge: SkillData = load("res://data/skills/comet_charge.tres")
	var resources: Array[SkillData] = [
		tactical_shift, collapse_line, command_marker, ark_breath, never_forget,
		iron_wall, pin_shot, memory_burn, comet_charge
	]
	for resource in resources:
		if resource == null:
			return _fail("Representative skill resources should all load successfully.")
	if tactical_shift.unlock_flag != &"flag_memory_ch01_first_order_seen":
		return _fail("tactical_shift should preserve its flag-based unlock.")
	if collapse_line.get_status_type() != &"oblivion" or collapse_line.get_status_duration() != 2:
		return _fail("collapse_line should expose oblivion status metadata with duration 2.")
	if command_marker.get_status_type() != &"mark":
		return _fail("command_marker should expose mark status metadata.")
	if ark_breath.targeting_rule != &"adjacent_ally":
		return _fail("ark_breath should target adjacent allies.")
	if never_forget.get_status_type() != &"oblivion":
		return _fail("never_forget should still describe oblivion cleanse metadata.")
	if iron_wall.targeting_rule != &"adjacent_ally":
		return _fail("iron_wall should be an ally-facing defensive skill.")
	if pin_shot.get_status_type() != &"fear":
		return _fail("pin_shot should expose fear status metadata.")
	if memory_burn.get_status_type() != &"oblivion":
		return _fail("memory_burn should expose oblivion status metadata.")
	if comet_charge.range != 2 or comet_charge.power_modifier < 4:
		return _fail("comet_charge should remain a high-pressure range 2 charge skill.")
	return true

func _assert_core_ally_skill_loadouts() -> bool:
	var expected := {
		"res://data/units/ally_rian.tres": [&"basic_attack", &"tactical_shift", &"collapse_line", &"command_marker"],
		"res://data/units/ally_serin.tres": [&"basic_attack", &"ark_breath", &"never_forget", &"pure_barrier", &"dawn_prayer"],
		"res://data/units/ally_bran.tres": [&"basic_attack", &"iron_wall", &"shield_bash", &"last_bastion"],
		"res://data/units/ally_tia.tres": [&"basic_attack", &"pin_shot", &"leap_shot", &"jump_shot"],
		"res://data/units/ally_enoch.tres": [&"basic_attack", &"memory_burn", &"seal_script", &"truth_read"],
		"res://data/units/ally_kyle.tres": [&"basic_attack", &"comet_charge", &"formation_break", &"last_bastion"],
	}
	for unit_path in expected.keys():
		var unit: UnitData = load(unit_path)
		if unit == null:
			return _fail("Core ally unit resource failed to load: %s" % unit_path)
		var skills: Array[SkillData] = unit.get_all_skills()
		if skills.size() != expected[unit_path].size():
			return _fail("Core ally skill loadout size mismatch for %s." % unit_path)
		for expected_skill_id in expected[unit_path]:
			if unit.get_skill_by_id(expected_skill_id) == null:
				return _fail("%s should expose %s through UnitData.get_skill_by_id()." % [unit_path, String(expected_skill_id)])
	return true

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
