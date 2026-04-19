class_name ProgressionData
extends Resource

## Serializable campaign-level meta state.
## Owned by ProgressionService; persisted in save file.

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

@export var sacrificed_units: Array[String] = []

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
@export var encyclopedia_entries: Dictionary = {}
@export var battle_records: Array = []
@export var support_history: Array[Dictionary] = []
@export var available_support_conversations: Array[String] = []
@export var epitaphs: Array[String] = []
@export var enoch_wounded: bool = false
@export var ledger_count: int = 0
@export var mira_trust_level: int = 0
@export var neri_disposition: String = "neutral"
@export var lete_early_alliance: bool = false
@export var noah_phase2_multiplier: float = 1.0
@export var melkion_awareness: bool = false
@export var ch10_attack_bonus: int = 0
@export var ch10_defense_bonus: int = 0

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
	support_history.clear()
	available_support_conversations.clear()
	enoch_wounded = false
	ledger_count = 0
	mira_trust_level = 0
	neri_disposition = "neutral"
	lete_early_alliance = false
	noah_phase2_multiplier = 1.0
	melkion_awareness = false
	ch10_attack_bonus = 0
	ch10_defense_bonus = 0
	free_name_call = has_ng_plus_purchase("divine_blessing")

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

func add_battle_record(record: Dictionary) -> void:
	var stage_id := String(record.get("stage_id", "")).strip_edges()
	if stage_id.is_empty():
		return
	for index in range(battle_records.size()):
		if String(battle_records[index].get("stage_id", "")) == stage_id:
			battle_records[index] = record.duplicate(true)
			return
	battle_records.append(record.duplicate(true))

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
	for existing_entry in support_history:
		if String(existing_entry.get("pair", "")) == pair_id and int(existing_entry.get("rank", 0)) == rank:
			clear_support_conversation_available(pair_id, rank)
			return false
	var stored_entry := {
		"pair": pair_id,
		"rank": rank,
		"chapter": String(entry.get("chapter", "")).strip_edges(),
		"stage_id": String(entry.get("stage_id", "")).strip_edges(),
		"timestamp": int(entry.get("timestamp", Time.get_unix_time_from_system()))
	}
	support_history.append(stored_entry)
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
		"encyclopedia_entries": encyclopedia_entries.duplicate(true),
		"battle_records": battle_records.duplicate(true),
		"support_history": support_history.duplicate(true),
		"available_support_conversations": available_support_conversations.duplicate(),
		"epitaphs": epitaphs.duplicate(),
		"enoch_wounded": enoch_wounded,
		"ledger_count": ledger_count,
		"mira_trust_level": mira_trust_level,
		"neri_disposition": neri_disposition,
		"lete_early_alliance": lete_early_alliance,
		"noah_phase2_multiplier": noah_phase2_multiplier,
		"melkion_awareness": melkion_awareness,
		"ch10_attack_bonus": ch10_attack_bonus,
		"ch10_defense_bonus": ch10_defense_bonus,
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
		"sacrificed_units": sacrificed_units.duplicate(),
		"recover_chapter_count": recover_chapter_count
	}
