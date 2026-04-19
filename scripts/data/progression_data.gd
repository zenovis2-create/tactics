class_name ProgressionData
extends Resource

const ChronicleEntry = preload("res://scripts/battle/chronicle_entry.gd")

## Serializable campaign-level meta state.
## Owned by ProgressionService; persisted in save file.

const CommanderProfile = preload("res://scripts/battle/commander_profile.gd")

# Burden: 0-9. Tracks moral cost of Rian's recovered truths.
# 0 = no weight, 9 = maximum accumulated burden.
@export var burden: int = 0

# Trust: 0-9. Tracks collective trust between Rian and his squad.
# 0 = minimal trust, 9 = full cohesion.
@export var trust: int = 0

# Fragment set: which memory fragments have been recovered.
# Keys are fragment IDs (StringName); value is always true.
@export var recovered_fragments: Dictionary = {}

# Ending tendency: updated automatically from burden/trust thresholds.
# Values: "true_ending", "bad_ending", "undetermined"
@export var ending_tendency: StringName = &"undetermined"

# Command unlock set: fragment-gated commands that are now available.
# Keys are command IDs (StringName); value is always true.
@export var unlocked_commands: Dictionary = {}

# Per-unit progression snapshot keyed by unit_id string.
# Value shape: {"level": int, "exp": int}
@export var unit_progression: Dictionary = {}

@export var previous_fragment_count: int = 0

@export var previous_command_count: int = 0

@export var previous_fragment_ids: Array[String] = []

@export var previous_command_ids: Array[String] = []

@export var ally_unlocked: Dictionary = {}

@export var mira_unlocked: bool = false

@export var melkion_unlocked: bool = false

@export var badges_of_heroism: int = 0

@export var earned_badges: Array[String] = []

@export var ng_plus_purchases: Array[String] = []

@export var ng_plus_saved_fragments: Array[String] = []

@export var free_name_call: bool = false

@export var recovering_units: Array[String] = []

@export var sacrificed_units: Array = []

@export var recover_chapter_count: int = 0

func is_ally_unlocked(unit_key: StringName) -> bool:
	return bool(ally_unlocked.get(String(unit_key), false))

func unlock_ally(unit_key: StringName) -> void:
	ally_unlocked[String(unit_key)] = true
	match unit_key:
		&"mira":
			mira_unlocked = true
		&"melkion":
			melkion_unlocked = true
		_:
			pass

@export var choices_made: Array[String] = []
@export var chapters_completed: Array[String] = []
@export var chronicle_entries: Array[ChronicleEntry] = []
@export var encyclopedia_entries: Dictionary = {}
@export var encyclopedia_comments: Dictionary = {}
@export var battle_records: Array = []
@export var support_history: Array[Dictionary] = []
@export var comment_history: Array[Dictionary] = []
@export var available_support_conversations: Array[String] = []
@export var support_progress_by_pair: Dictionary = {}
@export var flooded_stages: Array[String] = []
@export var epitaphs: Array[String] = []
@export var memorial_records: Array[Dictionary] = []
@export var stage_memorials: Dictionary = {}
@export var ashes_collected: Array[Dictionary] = []
@export var enoch_wounded: bool = false
@export var ledger_count: int = 0
@export var world_timeline_id: String = "A"
@export var worldview_fragments: Array[String] = []
@export var worldview_complete: bool = false
@export var mira_trust_level: int = 0
@export var neri_disposition: String = "neutral"
@export var lete_early_alliance: bool = false
@export var noah_phase2_multiplier: float = 1.0
@export var melkion_awareness: bool = false
@export var ch10_attack_bonus: int = 0
@export var ch10_defense_bonus: int = 0
@export var namecall_rejected_count: int = 0
@export var commander_profile: CommanderProfile = CommanderProfile.new()

func earn_badge(badge_id: String, amount: int) -> bool:
	var normalized: String = badge_id.strip_edges()
	if normalized.is_empty() or amount <= 0 or earned_badges.has(normalized):
		return false
	earned_badges.append(normalized)
	badges_of_heroism += amount
	return true

func has_ng_plus_purchase(item_id: String) -> bool:
	return ng_plus_purchases.has(item_id.strip_edges())

func add_ng_plus_purchase(item_id: String) -> bool:
	var normalized: String = item_id.strip_edges()
	if normalized.is_empty() or ng_plus_purchases.has(normalized):
		return false
	ng_plus_purchases.append(normalized)
	return true

func set_ng_plus_saved_fragments(fragment_ids: Array[String]) -> void:
	ng_plus_saved_fragments = fragment_ids.duplicate()
	ng_plus_saved_fragments.sort()

func reset_for_new_campaign() -> void:
	var saved_fragments: Array[String] = get_recovered_fragment_ids()
	if not saved_fragments.is_empty():
		set_ng_plus_saved_fragments(saved_fragments)

	burden = 0
	trust = 0
	recovered_fragments.clear()
	ending_tendency = &"undetermined"
	unlocked_commands.clear()
	unit_progression.clear()
	previous_fragment_count = 0
	previous_command_count = 0
	previous_fragment_ids.clear()
	previous_command_ids.clear()
	ally_unlocked.clear()
	mira_unlocked = false
	melkion_unlocked = false
	choices_made.clear()
	chronicle_entries.clear()
	encyclopedia_comments.clear()
	support_history.clear()
	comment_history.clear()
	available_support_conversations.clear()
	support_progress_by_pair.clear()
	flooded_stages.clear()
	recovering_units.clear()
	sacrificed_units.clear()
	recover_chapter_count = 0
	epitaphs.clear()
	memorial_records.clear()
	ashes_collected.clear()
	enoch_wounded = false
	ledger_count = 0
	world_timeline_id = "A"
	worldview_fragments.clear()
	worldview_complete = false
	mira_trust_level = 0
	neri_disposition = "neutral"
	lete_early_alliance = false
	noah_phase2_multiplier = 1.0
	melkion_awareness = false
	ch10_attack_bonus = 0
	ch10_defense_bonus = 0
	namecall_rejected_count = 0
	commander_profile = CommanderProfile.new()
	free_name_call = has_ng_plus_purchase("divine_blessing")

func ensure_commander_profile() -> CommanderProfile:
	if commander_profile == null:
		commander_profile = CommanderProfile.new()
	return commander_profile

func has_fragment(fragment_id: StringName) -> bool:
	return recovered_fragments.has(fragment_id)

func has_command(command_id: StringName) -> bool:
	return unlocked_commands.has(command_id)

func get_recovered_fragment_ids() -> Array[String]:
	var ids: Array[String] = []
	for fragment_id in recovered_fragments.keys():
		ids.append(String(fragment_id))
	ids.sort()
	return ids

func get_unlocked_command_ids() -> Array[String]:
	var ids: Array[String] = []
	for command_id in unlocked_commands.keys():
		ids.append(String(command_id))
	ids.sort()
	return ids

func has_worldview_fragment(fragment_id: String) -> bool:
	var normalized := fragment_id.strip_edges()
	return not normalized.is_empty() and worldview_fragments.has(normalized)

func add_worldview_fragment(fragment_id: String) -> bool:
	var normalized := fragment_id.strip_edges()
	if normalized.is_empty() or worldview_fragments.has(normalized):
		return false
	worldview_fragments.append(normalized)
	worldview_fragments.sort()
	return true

func get_worldview_fragment_ids() -> Array[String]:
	var ids := worldview_fragments.duplicate()
	ids.sort()
	return ids

func get_newly_unlocked_commands() -> Array[String]:
	var ids: Array[String] = get_unlocked_command_ids()
	var recent: Array[String] = []
	for command_id in ids:
		if not previous_command_ids.has(command_id):
			recent.append(command_id)
	return recent

func get_recently_recovered_fragments() -> Array[String]:
	var ids: Array[String] = get_recovered_fragment_ids()
	var recent: Array[String] = []
	for fragment_id in ids:
		if not previous_fragment_ids.has(fragment_id):
			recent.append(fragment_id)
	return recent

func snapshot_unlock_state() -> void:
	previous_fragment_count = recovered_fragments.size()
	previous_command_count = unlocked_commands.size()
	previous_fragment_ids = get_recovered_fragment_ids()
	previous_command_ids = get_unlocked_command_ids()

func get_unit_progress(unit_id: StringName) -> Dictionary:
	var key := String(unit_id)
	var value: Dictionary = unit_progression.get(key, {})
	return {
		"level": max(1, int(value.get("level", 1))),
		"exp": max(0, int(value.get("exp", 0)))
	}

func set_unit_progress(unit_id: StringName, level: int, exp: int) -> void:
	unit_progression[String(unit_id)] = {
		"level": max(1, level),
		"exp": max(0, exp)
	}

func add_chapter_completed(chapter_id: StringName) -> void:
	var normalized := String(chapter_id).strip_edges()
	if normalized.is_empty() or chapters_completed.has(normalized):
		return
	chapters_completed.append(normalized)

func upsert_encyclopedia_entry(unit_id: StringName, entry: Dictionary) -> void:
	var key := String(unit_id).strip_edges()
	if key.is_empty():
		return
	var existing: Dictionary = encyclopedia_entries.get(key, {})
	var merged: Dictionary = existing.duplicate(true)
	for entry_key in entry.keys():
		merged[entry_key] = entry[entry_key]
	if not merged.has("name"):
		merged["name"] = key.capitalize()
	if not merged.has("type"):
		merged["type"] = "Unknown"
	if not merged.has("chapter_introduced"):
		merged["chapter_introduced"] = 1
	if not merged.has("stats"):
		merged["stats"] = {}
	if not merged.has("quote"):
		merged["quote"] = ""
	if not merged.has("support_rank"):
		merged["support_rank"] = 0
	encyclopedia_entries[key] = merged

func get_encyclopedia_comment(unit_id: StringName) -> String:
	var key := String(unit_id).strip_edges()
	if key.is_empty():
		return ""
	return String(encyclopedia_comments.get(key, "")).strip_edges()

func set_encyclopedia_comment(unit_id: StringName, comment_text: String, who: String = "", when: String = "") -> bool:
	var key := String(unit_id).strip_edges()
	var normalized_comment := comment_text.strip_edges().left(280)
	if key.is_empty() or normalized_comment.is_empty():
		return false
	var previous_comment := get_encyclopedia_comment(unit_id)
	if previous_comment == normalized_comment:
		return false
	encyclopedia_comments[key] = normalized_comment
	comment_history.append({
		"unit_id": key,
		"comment": normalized_comment,
		"who": who.strip_edges() if not who.is_empty() else "Anonymous Archivist",
		"when": when.strip_edges() if not when.is_empty() else Time.get_datetime_string_from_system(),
		"timestamp": int(Time.get_unix_time_from_system())
	})
	return true

func get_comment_history_for_unit(unit_id: StringName) -> Array[Dictionary]:
	var key := String(unit_id).strip_edges()
	var history: Array[Dictionary] = []
	if key.is_empty():
		return history
	for entry in comment_history:
		if String(entry.get("unit_id", "")).strip_edges() == key:
			history.append((entry as Dictionary).duplicate(true))
	history.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("timestamp", 0)) < int(b.get("timestamp", 0))
	)
	return history

func add_battle_record(record: Dictionary) -> void:
	var stage_id := String(record.get("stage_id", "")).strip_edges()
	if stage_id.is_empty():
		return
	for index in range(battle_records.size()):
		if String(battle_records[index].get("stage_id", "")) == stage_id:
			battle_records[index] = record.duplicate(true)
			return
	battle_records.append(record.duplicate(true))

func add_chronicle_entry(entry: ChronicleEntry) -> void:
	if entry == null:
		return
	var normalized_chapter_id := entry.chapter_id.strip_edges().to_upper()
	if normalized_chapter_id.is_empty():
		return
	entry.chapter_id = normalized_chapter_id
	for index in range(chronicle_entries.size()):
		var existing := chronicle_entries[index]
		if existing != null and existing.chapter_id.strip_edges().to_upper() == normalized_chapter_id:
			chronicle_entries[index] = entry
			return
	chronicle_entries.append(entry)

func get_chronicle_entry(chapter_id: String) -> ChronicleEntry:
	var normalized_chapter_id := chapter_id.strip_edges().to_upper()
	if normalized_chapter_id.is_empty():
		return null
	for entry in chronicle_entries:
		if entry != null and entry.chapter_id.strip_edges().to_upper() == normalized_chapter_id:
			return entry
	return null

func get_chronicle_entry_summaries() -> Array[Dictionary]:
	var summaries: Array[Dictionary] = []
	for entry in chronicle_entries:
		if entry == null:
			continue
		summaries.append(entry.to_summary_dict())
	return summaries

func mark_support_conversation_available(pair_id: String, rank: int) -> void:
	var normalized_pair := pair_id.strip_edges()
	if normalized_pair.is_empty() or rank <= 0:
		return
	var conversation_key := "%s:%d" % [normalized_pair, rank]
	if available_support_conversations.has(conversation_key):
		return
	available_support_conversations.append(conversation_key)

func clear_support_conversation_available(pair_id: String, rank: int) -> void:
	var conversation_key := "%s:%d" % [pair_id.strip_edges(), rank]
	var index := available_support_conversations.find(conversation_key)
	if index >= 0:
		available_support_conversations.remove_at(index)

func has_support_conversation_available(pair_id: String, rank: int) -> bool:
	return available_support_conversations.has("%s:%d" % [pair_id.strip_edges(), rank])

func record_support_history(entry: Dictionary) -> bool:
	var pair_id := String(entry.get("pair", "")).strip_edges()
	var rank := int(entry.get("rank", 0))
	if pair_id.is_empty() or rank <= 0:
		return false
	var consume_available := bool(entry.get("consume_available", true))
	for existing_entry in support_history:
		if String(existing_entry.get("pair", "")) == pair_id and int(existing_entry.get("rank", 0)) == rank:
			var existing_index := support_history.find(existing_entry)
			var merged_entry := (existing_entry as Dictionary).duplicate(true)
			merged_entry["chapter"] = String(entry.get("chapter", merged_entry.get("chapter", ""))).strip_edges()
			merged_entry["stage_id"] = String(entry.get("stage_id", merged_entry.get("stage_id", ""))).strip_edges()
			merged_entry["timestamp"] = int(entry.get("timestamp", merged_entry.get("timestamp", Time.get_unix_time_from_system())))
			for extra_key in entry.keys():
				if extra_key in ["pair", "rank", "chapter", "stage_id", "timestamp", "consume_available"]:
					continue
				merged_entry[extra_key] = entry[extra_key]
			support_history[existing_index] = merged_entry
			if consume_available:
				clear_support_conversation_available(pair_id, rank)
			return false
	var stored_entry := {
		"pair": pair_id,
		"rank": rank,
		"chapter": String(entry.get("chapter", "")).strip_edges(),
		"stage_id": String(entry.get("stage_id", "")).strip_edges(),
		"timestamp": int(entry.get("timestamp", Time.get_unix_time_from_system()))
	}
	for extra_key in entry.keys():
		if extra_key in ["pair", "rank", "chapter", "stage_id", "timestamp", "consume_available"]:
			continue
		stored_entry[extra_key] = entry[extra_key]
	support_history.append(stored_entry)
	if consume_available:
		clear_support_conversation_available(pair_id, rank)
	return true

func get_support_history_for_pair(pair_id: String) -> Array[Dictionary]:
	var normalized_pair := pair_id.strip_edges()
	var history: Array[Dictionary] = []
	if normalized_pair.is_empty():
		return history
	for entry in support_history:
		if String(entry.get("pair", "")) == normalized_pair:
			history.append((entry as Dictionary).duplicate(true))
	history.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("timestamp", 0)) < int(b.get("timestamp", 0))
	)
	return history

func add_epitaph(epitaph_text: String) -> void:
	var normalized := epitaph_text.strip_edges()
	if normalized.is_empty() or epitaphs.has(normalized):
		return
	epitaphs.append(normalized)

func set_unit_quote(unit_id: String, quote_text: String) -> void:
	var key := unit_id.strip_edges()
	var normalized_quote := quote_text.strip_edges()
	if key.is_empty():
		return
	var entry: Dictionary = encyclopedia_entries.get(key, {}).duplicate(true)
	if entry.is_empty():
		entry = {
			"name": key.capitalize(),
			"type": "Ally",
			"chapter_introduced": 1,
			"stats": {},
			"support_rank": 0
		}
	entry["quote"] = normalized_quote
	encyclopedia_entries[key] = entry

func get_unit_quote(unit_id: String) -> String:
	var key := unit_id.strip_edges()
	if key.is_empty():
		return ""
	return String(encyclopedia_entries.get(key, {}).get("quote", "")).strip_edges()

func add_memorial_record(unit_id: String, unit_name: String, epitaph_text: String, chapter_id: String = "", stage_id: String = "") -> Dictionary:
	var normalized_unit_id := unit_id.strip_edges()
	if normalized_unit_id.is_empty():
		return {}
	var normalized_name := unit_name.strip_edges()
	if normalized_name.is_empty():
		normalized_name = normalized_unit_id.capitalize()
	var normalized_epitaph := epitaph_text.strip_edges()
	var record := {
		"unit_id": normalized_unit_id,
		"unit_name": normalized_name,
		"epitaph": normalized_epitaph,
		"chapter_id": chapter_id.strip_edges(),
		"stage_id": stage_id.strip_edges(),
		"timestamp": int(Time.get_unix_time_from_system())
	}
	for index in range(memorial_records.size()):
		if String(memorial_records[index].get("unit_id", "")) == normalized_unit_id:
			memorial_records[index] = record
			if not normalized_epitaph.is_empty():
				add_epitaph("%s — %s" % [normalized_name, normalized_epitaph])
			return record
	memorial_records.append(record)
	if not normalized_epitaph.is_empty():
		add_epitaph("%s — %s" % [normalized_name, normalized_epitaph])
	return record

func get_memorial_record(unit_id: String) -> Dictionary:
	var normalized_unit_id := unit_id.strip_edges()
	if normalized_unit_id.is_empty():
		return {}
	for record in memorial_records:
		if String(record.get("unit_id", "")) == normalized_unit_id:
			return (record as Dictionary).duplicate(true)
	return {}

func get_honor_roll() -> Array[Dictionary]:
	var honor_roll: Array[Dictionary] = []
	for record in memorial_records:
		honor_roll.append((record as Dictionary).duplicate(true))
	honor_roll.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("timestamp", 0)) < int(b.get("timestamp", 0))
	)
	return honor_roll

func get_first_memorial_marker() -> Dictionary:
	var honor_roll := get_honor_roll()
	if honor_roll.is_empty():
		return {}
	return honor_roll[0].duplicate(true)

func upsert_stage_memorial(stage_id: String, objective: String, marker_type: String, chapter_when_achieved: int) -> Dictionary:
	var normalized_stage_id := stage_id.strip_edges().to_upper()
	var normalized_objective := objective.strip_edges()
	var normalized_marker_type := marker_type.strip_edges().to_lower()
	if normalized_stage_id.is_empty() or normalized_objective.is_empty():
		return {}
	if normalized_marker_type.is_empty():
		normalized_marker_type = "flower"
	var record := {
		"objective": normalized_objective,
		"marker_type": normalized_marker_type,
		"chapter_when_achieved": max(1, chapter_when_achieved)
	}
	stage_memorials[normalized_stage_id] = record
	return record.duplicate(true)

func get_stage_memorial(stage_id: String) -> Dictionary:
	var normalized_stage_id := stage_id.strip_edges().to_upper()
	if normalized_stage_id.is_empty() or not stage_memorials.has(normalized_stage_id):
		return {}
	return (stage_memorials.get(normalized_stage_id, {}) as Dictionary).duplicate(true)

func get_stage_memorial_snapshot() -> Dictionary:
	return stage_memorials.duplicate(true)

func has_sacrificed_unit(unit_id: String) -> bool:
	var normalized := unit_id.strip_edges()
	if normalized.is_empty():
		return false
	for entry_variant in sacrificed_units:
		if typeof(entry_variant) == TYPE_DICTIONARY:
			var entry := entry_variant as Dictionary
			if String(entry.get("unit_id", "")).strip_edges() == normalized:
				return true
			if String(entry.get("name", "")).strip_edges() == normalized:
				return true
		elif String(entry_variant).strip_edges() == normalized:
			return true
	return false

func add_sacrificed_unit(unit_id: String, unit_name: String = "", epitaph_text: String = "") -> bool:
	var normalized_id := unit_id.strip_edges()
	if normalized_id.is_empty() or has_sacrificed_unit(normalized_id):
		return false
	var resolved_name := unit_name.strip_edges()
	if resolved_name.is_empty():
		resolved_name = _humanize_sacrifice_name(normalized_id)
	sacrificed_units.append({
		"unit_id": normalized_id,
		"name": resolved_name,
		"epitaph": _normalize_epitaph_text(epitaph_text, resolved_name)
	})
	return true

func get_sacrifice_records() -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for index in range(sacrificed_units.size()):
		var raw_entry: Variant = sacrificed_units[index]
		var record := {
			"unit_id": "",
			"name": "",
			"epitaph": ""
		}
		if typeof(raw_entry) == TYPE_DICTIONARY:
			var entry := raw_entry as Dictionary
			record["unit_id"] = String(entry.get("unit_id", "")).strip_edges()
			record["name"] = String(entry.get("name", "")).strip_edges()
			record["epitaph"] = String(entry.get("epitaph", "")).strip_edges()
		else:
			record["unit_id"] = String(raw_entry).strip_edges()
		if String(record.get("name", "")).is_empty():
			record["name"] = _humanize_sacrifice_name(String(record.get("unit_id", "")))
		if String(record.get("epitaph", "")).is_empty() and index < epitaphs.size():
			record["epitaph"] = _normalize_epitaph_text(String(epitaphs[index]), String(record.get("name", "")))
		records.append(record)
	return records

func _normalize_epitaph_text(raw_epitaph: String, unit_name: String) -> String:
	var normalized := raw_epitaph.strip_edges()
	if normalized.is_empty():
		return ""
	var resolved_name := unit_name.strip_edges()
	if not resolved_name.is_empty():
		var long_prefix := "%s — " % resolved_name
		var short_prefix := "%s - " % resolved_name
		if normalized.begins_with(long_prefix):
			return normalized.trim_prefix(long_prefix).strip_edges()
		if normalized.begins_with(short_prefix):
			return normalized.trim_prefix(short_prefix).strip_edges()
	return normalized

func _humanize_sacrifice_name(raw_value: String) -> String:
	var normalized := raw_value.strip_edges()
	if normalized.begins_with("ally_"):
		normalized = normalized.trim_prefix("ally_")
	elif normalized.begins_with("enemy_"):
		normalized = normalized.trim_prefix("enemy_")
	if normalized.is_empty():
		return "Unknown"
	var parts := normalized.split("_", false)
	for index in range(parts.size()):
		parts[index] = String(parts[index]).capitalize()
	return " ".join(parts)

func get_unit_progress_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	var keys: Array[String] = []
	for unit_id in unit_progression.keys():
		keys.append(String(unit_id))
	keys.sort()
	for unit_id in keys:
		snapshot[unit_id] = get_unit_progress(StringName(unit_id))
	return snapshot

func get_burden_band() -> int:
	return clampi(burden, 0, 9)

func get_trust_band() -> int:
	return clampi(trust, 0, 9)

func to_debug_dict() -> Dictionary:
	return {
		"burden": burden,
		"trust": trust,
		"ending_tendency": String(ending_tendency),
		"choices_made": choices_made.duplicate(),
		"chapters_completed": chapters_completed.duplicate(),
		"chronicle_entries": get_chronicle_entry_summaries(),
		"encyclopedia_entries": encyclopedia_entries.duplicate(true),
		"encyclopedia_comments": encyclopedia_comments.duplicate(true),
		"battle_records": battle_records.duplicate(true),
		"support_history": support_history.duplicate(true),
		"comment_history": comment_history.duplicate(true),
		"available_support_conversations": available_support_conversations.duplicate(),
		"support_progress_by_pair": support_progress_by_pair.duplicate(true),
		"epitaphs": epitaphs.duplicate(),
		"memorial_records": memorial_records.duplicate(true),
		"ashes_collected": ashes_collected.duplicate(true),
		"stage_memorials": stage_memorials.duplicate(true),
		"enoch_wounded": enoch_wounded,
		"ledger_count": ledger_count,
		"worldview_fragments": get_worldview_fragment_ids(),
		"worldview_complete": worldview_complete,
		"mira_trust_level": mira_trust_level,
		"neri_disposition": neri_disposition,
		"lete_early_alliance": lete_early_alliance,
		"noah_phase2_multiplier": noah_phase2_multiplier,
		"melkion_awareness": melkion_awareness,
		"ch10_attack_bonus": ch10_attack_bonus,
		"ch10_defense_bonus": ch10_defense_bonus,
		"namecall_rejected_count": namecall_rejected_count,
		"commander_profile": ensure_commander_profile().to_debug_dict(),
		"badges_of_heroism": badges_of_heroism,
		"earned_badges": earned_badges.duplicate(),
		"ng_plus_purchases": ng_plus_purchases.duplicate(),
		"ng_plus_saved_fragments": ng_plus_saved_fragments.duplicate(),
		"free_name_call": free_name_call,
		"previous_fragment_count": previous_fragment_count,
		"previous_command_count": previous_command_count,
		"previous_fragment_ids": previous_fragment_ids.duplicate(),
		"previous_command_ids": previous_command_ids.duplicate(),
		"recovered_fragments": get_recovered_fragment_ids(),
		"unlocked_commands": get_unlocked_command_ids(),
		"unit_progression": get_unit_progress_snapshot(),
		"ally_unlocked": ally_unlocked.duplicate(true),
		"mira_unlocked": mira_unlocked,
		"melkion_unlocked": melkion_unlocked,
		"recovering_units": recovering_units.duplicate(),
		"sacrificed_units": get_sacrifice_records(),
		"recover_chapter_count": recover_chapter_count
	}
