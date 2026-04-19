class_name HeirloomService
extends Node

const HeirloomData = preload("res://scripts/data/heirloom_data.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

const BADGE_PLAYTHROUGH_BASELINE: int = 43
const HIDDEN_FRAGMENT_HOLDER_IDS: Array[String] = ["lete", "mira", "melkion"]

var _active_heirloom: HeirloomData
var _unit_bonus_by_id: Dictionary = {}
var _boss_bonus_percent: int = 0
var _early_join_unlocks: Array[String] = []
var _player_title: String = ""
var _encounter_visibility_enabled: bool = false

func generate_heirloom(progression_data: ProgressionData) -> HeirloomData:
	var heirloom := HeirloomData.new()
	if progression_data == null:
		heirloom.chronicle_summary = heirloom.to_summary()
		return heirloom

	heirloom.playthrough_count = _count_playthroughs(progression_data)
	heirloom.clan_name = _resolve_clan_name(progression_data)
	heirloom.clan_symbol = _resolve_clan_symbol(progression_data)
	heirloom.inherited_skills = _build_inherited_skills(progression_data)
	heirloom.curse_units = _extract_curse_units(progression_data)
	heirloom.rescued_fragment_holders = _extract_rescued_fragment_holders(progression_data)

	var battle_stats := _build_battle_statistics(progression_data)
	heirloom.total_battles = int(battle_stats.get("total_battles", 0))
	heirloom.total_victories = int(battle_stats.get("total_victories", 0))
	heirloom.total_deaths = int(battle_stats.get("total_deaths", 0))
	heirloom.chronicle_summary = _build_chronicle_summary(heirloom, battle_stats)
	return heirloom

func apply_heirloom_to_ngplus(heirloom: HeirloomData, target_progression: ProgressionData) -> void:
	_reset_runtime_state()
	if heirloom == null:
		return

	_active_heirloom = heirloom
	_boss_bonus_percent = max(0, heirloom.curse_units.size()) * 10
	_early_join_unlocks = heirloom.rescued_fragment_holders.duplicate()
	_player_title = "clan of %s" % (heirloom.clan_name if not heirloom.clan_name.is_empty() else "Nameless")
	_encounter_visibility_enabled = bool(get_clan_skill_bonus(heirloom.clan_symbol).get("encounter_visibility", false))

	var clan_bonus := get_clan_skill_bonus(heirloom.clan_symbol)
	var inherited_bonus := _build_inherited_skill_stat_bonus(heirloom.inherited_skills)
	var unit_ids := _collect_progression_unit_ids(target_progression)
	for unit_id in unit_ids:
		if _is_probable_boss(unit_id, target_progression):
			_unit_bonus_by_id[unit_id] = {
				"attack_percent_mod": _boss_bonus_percent,
				"defense_percent_mod": _boss_bonus_percent,
			}
			continue
		var merged := _merge_bonus_dicts(clan_bonus, inherited_bonus)
		if not merged.is_empty():
			_unit_bonus_by_id[unit_id] = merged

	if target_progression == null:
		return

	for holder_id in _early_join_unlocks:
		target_progression.unlock_ally(StringName(holder_id))
	target_progression.encyclopedia_comments["player_title"] = _player_title
	target_progression.encyclopedia_comments["heirloom_chronicle"] = heirloom.chronicle_summary

func get_clan_skill_bonus(clan_symbol: int) -> Dictionary:
	match clan_symbol:
		HeirloomData.ClanSymbol.SWORD:
			return {"attack_percent_mod": 5, "bonus_desc": "Attack skills deal +5% damage."}
		HeirloomData.ClanSymbol.SHIELD:
			return {"hp_bonus": 10, "bonus_desc": "All units gain +10 HP."}
		HeirloomData.ClanSymbol.STAR:
			return {"crit_rate_bonus": 5, "bonus_desc": "Critical rate +5%."}
		HeirloomData.ClanSymbol.DRAGON:
			return {"boss_damage_taken_percent": 5, "bonus_desc": "Bosses take +5% damage."}
		HeirloomData.ClanSymbol.WOLF:
			return {"encounter_visibility": true, "bonus_desc": "Enemy encounter rate is visible on the overworld."}
		_:
			return {}

func get_active_heirloom() -> HeirloomData:
	return _active_heirloom

func get_unit_bonus(unit_id: StringName) -> Dictionary:
	var normalized := String(unit_id).strip_edges()
	if normalized.is_empty():
		return {}
	return (_unit_bonus_by_id.get(normalized, {}) as Dictionary).duplicate(true)

func get_player_title() -> String:
	return _player_title

func get_early_join_unlocks() -> Array[String]:
	return _early_join_unlocks.duplicate()

func is_encounter_visibility_enabled() -> bool:
	return _encounter_visibility_enabled

func get_attack_context_bonus(attacker, defender) -> Dictionary:
	var resolved: Dictionary = {}
	var attacker_id := _resolve_unit_id(attacker)
	var defender_id := _resolve_unit_id(defender)
	var attacker_bonus := get_unit_bonus(attacker_id)
	var defender_bonus := get_unit_bonus(defender_id)

	_add_numeric_bonus(resolved, "attack_percent_mod", int(attacker_bonus.get("attack_percent_mod", 0)))
	_add_numeric_bonus(resolved, "crit_rate_bonus", int(attacker_bonus.get("crit_rate_bonus", 0)))
	if _is_boss_unit(defender):
		_add_numeric_bonus(resolved, "defense_percent_mod", int(defender_bonus.get("defense_percent_mod", 0)))
		if _active_heirloom != null and _active_heirloom.clan_symbol == HeirloomData.ClanSymbol.DRAGON and _is_ally_unit(attacker):
			_add_numeric_bonus(resolved, "attack_percent_mod", int(get_clan_skill_bonus(_active_heirloom.clan_symbol).get("boss_damage_taken_percent", 0)))
	return resolved

func get_unit_max_hp_bonus(unit_id: StringName) -> int:
	return int(get_unit_bonus(unit_id).get("hp_bonus", 0))

func get_unit_attack_bonus(unit_id: StringName) -> int:
	return int(get_unit_bonus(unit_id).get("attack_bonus", 0))

func get_unit_defense_bonus(unit_id: StringName) -> int:
	return int(get_unit_bonus(unit_id).get("defense_bonus", 0))

func _reset_runtime_state() -> void:
	_active_heirloom = null
	_unit_bonus_by_id.clear()
	_boss_bonus_percent = 0
	_early_join_unlocks.clear()
	_player_title = ""
	_encounter_visibility_enabled = false

func _count_playthroughs(progression_data: ProgressionData) -> int:
	var completed_runs: int = 0
	for badge_id in progression_data.earned_badges:
		var normalized := String(badge_id).strip_edges().to_lower()
		if normalized.begins_with("ending:"):
			completed_runs += 1
	if completed_runs > 0:
		return completed_runs
	for badge_id in progression_data.earned_badges:
		var normalized := String(badge_id).strip_edges().to_lower()
		if normalized.begins_with("stage_clear:ch10"):
			completed_runs += 1
	if completed_runs > 0:
		return completed_runs
	if progression_data.badges_of_heroism <= 0:
		return 0
	return maxi(1, int(ceil(float(progression_data.badges_of_heroism) / float(BADGE_PLAYTHROUGH_BASELINE))))

func _resolve_clan_name(progression_data: ProgressionData) -> String:
	var normalized_timeline := progression_data.world_timeline_id.strip_edges().to_upper()
	if normalized_timeline.is_empty():
		normalized_timeline = "A"
	var prefix := "Aster" if normalized_timeline == "A" else "Veil"
	var suffix := _resolve_clan_suffix(progression_data)
	return "%s %s" % [prefix, suffix]

func _resolve_clan_suffix(progression_data: ProgressionData) -> String:
	var source_records: Array[String] = progression_data.choices_made.duplicate()
	if source_records.is_empty():
		return "Ledger"
	var first_record := String(source_records[0]).strip_edges()
	if first_record.find(":") == -1:
		return _humanize_token(first_record)
	var option_id := first_record.get_slice(":", 1)
	if option_id.is_empty():
		return "Ledger"
	return _humanize_token(option_id)

func _resolve_clan_symbol(progression_data: ProgressionData) -> int:
	if progression_data.worldview_complete:
		return HeirloomData.ClanSymbol.DRAGON
	var highest_support := 0
	for pair_id in progression_data.support_progress_by_pair.keys():
		var record := progression_data.support_progress_by_pair.get(pair_id, {}) as Dictionary
		highest_support = maxi(highest_support, int(record.get("milestone_rank", 0)))
	if highest_support >= 5:
		return HeirloomData.ClanSymbol.STAR
	if progression_data.ledger_count >= 5:
		return HeirloomData.ClanSymbol.SHIELD
	if not _extract_curse_units(progression_data).is_empty():
		return HeirloomData.ClanSymbol.WOLF
	return HeirloomData.ClanSymbol.SWORD

func _build_inherited_skills(progression_data: ProgressionData) -> Array[Dictionary]:
	var skills: Array[Dictionary] = []
	var rank_keys: Array[String] = []
	for pair_key in progression_data.support_progress_by_pair.keys():
		rank_keys.append(String(pair_key))
	rank_keys.sort()
	for pair_key in rank_keys:
		var progress := progression_data.support_progress_by_pair.get(pair_key, {}) as Dictionary
		var milestone_rank := int(progress.get("milestone_rank", 0))
		if milestone_rank < 4:
			continue
		skills.append({
			"skill_id": "legacy_support_%s" % pair_key.replace("|", "_"),
			"source_chapter": "SUPPORT",
			"bonus_desc": "%s rank %d resolve lingers." % [_humanize_pair_id(pair_key), milestone_rank]
		})
	var choice_records: Array[String] = progression_data.choices_made.duplicate()
	choice_records.sort()
	for choice_record in choice_records:
		if skills.size() >= 4:
			break
		var normalized := String(choice_record).strip_edges()
		if normalized.is_empty() or normalized.find(":") == -1:
			continue
		var chapter_id := normalized.get_slice(":", 0)
		var option_id := normalized.get_slice(":", 1)
		skills.append({
			"skill_id": "legacy_choice_%s" % option_id,
			"source_chapter": chapter_id,
			"bonus_desc": "%s from %s endures." % [_humanize_token(option_id), chapter_id]
		})
	return skills

func _extract_curse_units(progression_data: ProgressionData) -> Array[String]:
	var cursed_lookup: Dictionary = {}
	for sacrifice in progression_data.get_sacrifice_records():
		var unit_id := String(sacrifice.get("unit_id", "")).strip_edges()
		if not unit_id.is_empty():
			cursed_lookup[unit_id] = true
	for memorial in progression_data.get_honor_roll():
		var unit_id := String(memorial.get("unit_id", "")).strip_edges()
		if not unit_id.is_empty():
			cursed_lookup[unit_id] = true
	var cursed_units: Array[String] = []
	for unit_id in cursed_lookup.keys():
		cursed_units.append(String(unit_id))
	cursed_units.sort()
	return cursed_units

func _extract_rescued_fragment_holders(progression_data: ProgressionData) -> Array[String]:
	var rescued_lookup: Dictionary = {}
	var fragment_ids := progression_data.get_worldview_fragment_ids()
	for holder_id in HIDDEN_FRAGMENT_HOLDER_IDS:
		if progression_data.is_ally_unlocked(StringName(holder_id)):
			rescued_lookup[holder_id] = true
			continue
		for fragment_id in fragment_ids:
			if String(fragment_id).to_lower().find(holder_id) != -1:
				rescued_lookup[holder_id] = true
				break
	var rescued: Array[String] = []
	for holder_id in rescued_lookup.keys():
		rescued.append(String(holder_id))
	rescued.sort()
	return rescued

func _build_battle_statistics(progression_data: ProgressionData) -> Dictionary:
	var total_battles := progression_data.battle_records.size()
	var total_victories := 0
	var total_deaths := 0
	for record_variant in progression_data.battle_records:
		var record := record_variant as Dictionary
		if String(record.get("result", "")).to_lower() == "victory":
			total_victories += 1
		total_deaths += int(record.get("ally_deaths", 0))
	if total_battles == 0:
		for badge_id in progression_data.earned_badges:
			if String(badge_id).to_lower().begins_with("stage_clear:"):
				total_battles += 1
				total_victories += 1
	total_deaths = maxi(total_deaths, _extract_curse_units(progression_data).size())
	return {
		"total_battles": total_battles,
		"total_victories": total_victories,
		"total_deaths": total_deaths,
	}

func _build_chronicle_summary(heirloom: HeirloomData, battle_stats: Dictionary) -> String:
	var summary_parts: Array[String] = []
	summary_parts.append("%s 가문은 %d번의 대전 중 %d승을 남겼다." % [heirloom.clan_name if not heirloom.clan_name.is_empty() else "이름 없는 집안", int(battle_stats.get("total_battles", 0)), int(battle_stats.get("total_victories", 0))])
	if int(battle_stats.get("total_deaths", 0)) > 0:
		summary_parts.append("넘어진 %d명의 이름은 보스들의 분노가 되었다." % int(battle_stats.get("total_deaths", 0)))
	if not heirloom.rescued_fragment_holders.is_empty():
		summary_parts.append("%s 의 귀환은 다음 시대를 앞당긴다." % ", ".join(heirloom.rescued_fragment_holders))
	if not heirloom.inherited_skills.is_empty():
		summary_parts.append("남겨진 전술은 %d개의 계승 기술로 봉인되었다." % heirloom.inherited_skills.size())
	return " ".join(summary_parts).strip_edges()

func _build_inherited_skill_stat_bonus(inherited_skills: Array[Dictionary]) -> Dictionary:
	if inherited_skills.is_empty():
		return {}
	var skill_count := inherited_skills.size()
	return {
		"attack_bonus": maxi(1, int(ceil(float(skill_count) / 2.0))),
		"defense_bonus": int(floor(float(skill_count) / 2.0)),
	}

func _collect_progression_unit_ids(target_progression: ProgressionData) -> Array[String]:
	var unit_lookup: Dictionary = {}
	if target_progression == null:
		return []
	for unit_id in target_progression.unit_progression.keys():
		var normalized := String(unit_id).strip_edges()
		if not normalized.is_empty():
			unit_lookup[normalized] = true
	for unlocked_key in target_progression.ally_unlocked.keys():
		var normalized := String(unlocked_key).strip_edges()
		if not normalized.is_empty():
			unit_lookup[normalized] = true
	var unit_ids: Array[String] = []
	for unit_id in unit_lookup.keys():
		unit_ids.append(String(unit_id))
	unit_ids.sort()
	return unit_ids

func _is_probable_boss(unit_id: String, target_progression: ProgressionData) -> bool:
	if unit_id.begins_with("enemy_"):
		var snapshot := target_progression.unit_progression.get(unit_id, {}) as Dictionary
		var unit_data = snapshot.get("unit_data", null)
		if unit_data != null and bool(unit_data.get("is_boss")):
			return true
		return unit_id.find("boss") != -1 or unit_id.find("valgar") != -1 or unit_id.find("noah") != -1
	return false

func _merge_bonus_dicts(first: Dictionary, second: Dictionary) -> Dictionary:
	var merged: Dictionary = {}
	for source in [first, second]:
		for key_variant in source.keys():
			var key := String(key_variant)
			var value = source.get(key_variant)
			if typeof(value) in [TYPE_INT, TYPE_FLOAT]:
				merged[key] = float(merged.get(key, 0.0)) + float(value)
			elif typeof(value) == TYPE_BOOL:
				merged[key] = bool(value) or bool(merged.get(key, false))
	return _normalize_numeric_bonus_dict(merged)

func _normalize_numeric_bonus_dict(source: Dictionary) -> Dictionary:
	var normalized: Dictionary = {}
	for key_variant in source.keys():
		var key := String(key_variant)
		var value = source.get(key_variant)
		if typeof(value) == TYPE_FLOAT:
			normalized[key] = int(round(float(value))) if key.ends_with("bonus") or key.ends_with("mod") or key.ends_with("percent") else value
		else:
			normalized[key] = value
	return normalized

func _resolve_unit_id(unit) -> StringName:
	if unit == null:
		return &""
	if unit.has_method("get"):
		var unit_data = unit.get("unit_data")
		if unit_data != null:
			var raw_unit_id = unit_data.get("unit_id")
			if raw_unit_id != null:
				return StringName(String(raw_unit_id))
	return &""

func _is_boss_unit(unit) -> bool:
	if unit == null or not unit.has_method("get"):
		return false
	var unit_data = unit.get("unit_data")
	return unit_data != null and bool(unit_data.get("is_boss"))

func _is_ally_unit(unit) -> bool:
	if unit == null:
		return false
	if unit.has_method("get"):
		return String(unit.get("faction")) == "ally"
	return false

func _add_numeric_bonus(target: Dictionary, key: String, amount: int) -> void:
	if amount == 0:
		return
	target[key] = int(target.get(key, 0)) + amount

func _humanize_token(token: String) -> String:
	var normalized := token.strip_edges().trim_prefix("ch")
	if normalized.is_empty():
		return "Legacy"
	var parts := normalized.split("_", false)
	for index in range(parts.size()):
		parts[index] = String(parts[index]).capitalize()
	return " ".join(parts)

func _humanize_pair_id(pair_id: String) -> String:
	var parts := pair_id.split("|", false)
	for index in range(parts.size()):
		parts[index] = _humanize_token(String(parts[index]).trim_prefix("ally_").trim_prefix("enemy_"))
	return " & ".join(parts)
