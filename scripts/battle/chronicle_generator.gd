class_name ChronicleGenerator
extends Node

const ChronicleEntry = preload("res://scripts/battle/chronicle_entry.gd")
const GhostFormationData = preload("res://scripts/data/ghost_formation_data.gd")
const StageData = preload("res://scripts/data/stage_data.gd")

const DEFAULT_STYLE := ChronicleEntry.ChronicleStyle.CONCISE
const ADAPTIVE_PATTERN_AGGRESSIVE := "aggressive"
const ADAPTIVE_PATTERN_DEFENSIVE := "defensive"
const ADAPTIVE_PATTERN_MERCIFUL := "merciful"
const ADAPTIVE_PATTERN_BALANCED := "balanced"
const STYLE_TRIGGER_PRIORITY: Array[String] = [
	"desperate_victory",
	"weather_master",
	"quiet_strategy",
	"overwhelming_force",
]
const STYLE_PRIORITY := {
	"desperate_victory": ChronicleEntry.ChronicleStyle.BATTLE,
	"weather_master": ChronicleEntry.ChronicleStyle.POETIC,
	"quiet_strategy": ChronicleEntry.ChronicleStyle.POETIC,
	"overwhelming_force": ChronicleEntry.ChronicleStyle.CONCISE,
}

var chronicle_templates := {
	ChronicleEntry.ChronicleStyle.POETIC: {
		"quiet_strategy": "{chapter_title} ended with no ally laid low; {enemy_phrase} fell before a patient design, and {choice_phrase} left the field quieter than it began.",
		"weather_master": "At {chapter_title}, {weather_phrase} bent around the company while {action_phrase}; {enemy_phrase} broke like reeds beneath a river's mind.",
		"default": "{chapter_title} passed beneath a softer light; {enemy_phrase} yielded after {turn_phrase}, and {action_phrase}."
	},
	ChronicleEntry.ChronicleStyle.CONCISE: {
		"overwhelming_force": "{chapter_title} was secured in {turn_phrase}. Our line faced {enemy_count} hostiles with only {ally_count} allies committed, and {enemy_phrase} were cleared in deliberate order.",
		"default": "{chapter_title} concluded after {turn_phrase}. {enemy_phrase} were defeated, {casualty_phrase}, and {action_phrase}."
	},
	ChronicleEntry.ChronicleStyle.BATTLE: {
		"desperate_victory": "{chapter_title} was taken on the final exchange. {casualty_phrase}; {final_turn_loss} held long enough for {action_phrase}, and the enemy line finally broke.",
		"default": "{chapter_title} ended by force of arms after {turn_phrase}. {enemy_phrase} were cut down, {casualty_phrase}, and {action_phrase}."
	},
}

func generate_entry(chapter_id: String, battle_log: Array, choices_made: Array) -> ChronicleEntry:
	var normalized_chapter_id := chapter_id.strip_edges().to_upper()
	var summary := _normalize_battle_log(battle_log)
	var trigger_events := _detect_trigger_events(summary)
	var resolved_style: ChronicleEntry.ChronicleStyle = _resolve_style(trigger_events)
	var context := _build_template_context(normalized_chapter_id, summary, choices_made)
	var narrative_text := _build_narrative_text(resolved_style, trigger_events, context)

	var entry := ChronicleEntry.new()
	entry.chapter_id = normalized_chapter_id
	entry.chapter_title = String(context.get("chapter_title", normalized_chapter_id))
	entry.entry_date = Time.get_date_string_from_system()
	entry.narrative_text = narrative_text
	entry.style = resolved_style
	entry.trigger_events = trigger_events
	var adaptive_context := build_adaptive_dialogue_context(normalized_chapter_id, battle_log, choices_made)
	var npc_personality = get_node_or_null("/root/NPCPersonality")
	if npc_personality != null and npc_personality.has_method("queue_chronicle_reference"):
		npc_personality.queue_chronicle_reference(entry, adaptive_context)
	return entry

func extract_ghost_pattern(chronicle_entry: ChronicleEntry, player_tag: String = "Unknown", is_anonymous: bool = true) -> GhostFormationData:
	return GhostFormationData.create_from_chronicle(chronicle_entry, player_tag, is_anonymous)

func build_adaptive_dialogue_context(chapter_id: String, battle_log: Array, choices_made: Array) -> Dictionary:
	var normalized_chapter_id := chapter_id.strip_edges().to_upper()
	var summary := _normalize_battle_log(battle_log)
	var trigger_events := _detect_trigger_events(summary)
	var pattern := _resolve_adaptive_pattern(summary, choices_made, trigger_events)
	return {
		"chapter_id": normalized_chapter_id,
		"pattern": pattern,
		"pattern_reason": _describe_adaptive_pattern(pattern, summary, choices_made, trigger_events),
		"boss_mercy": pattern == ADAPTIVE_PATTERN_MERCIFUL,
		"rush_count": _count_rush_moments(summary, trigger_events),
		"stall_count": _count_stall_moments(summary, trigger_events),
		"turn_count": int(summary.get("turn_count", 1)),
		"trigger_events": trigger_events.duplicate(),
	}

func _normalize_battle_log(battle_log: Array) -> Dictionary:
	var summary := {
		"turn_count": 1,
		"enemy_count": 0,
		"ally_count": 0,
		"enemies_defeated": [],
		"allies_lost": [],
		"weather_events": [],
		"key_moments": [],
	}

	for raw_entry in battle_log:
		if typeof(raw_entry) != TYPE_DICTIONARY:
			continue
		var entry := raw_entry as Dictionary
		summary["turn_count"] = maxi(int(summary.get("turn_count", 1)), int(entry.get("turn_count", summary.get("turn_count", 1))))
		summary["enemy_count"] = maxi(int(summary.get("enemy_count", 0)), int(entry.get("enemy_count", 0)))
		summary["ally_count"] = maxi(int(summary.get("ally_count", 0)), int(entry.get("ally_count", 0)))
		_append_unique_strings(summary["enemies_defeated"], entry.get("enemies_defeated", []))
		_append_unique_dictionaries(summary["allies_lost"], _normalize_loss_entries(entry.get("allies_lost", [])))
		_append_unique_strings(summary["weather_events"], entry.get("weather_events", []))
		_append_key_moments(summary["key_moments"], entry.get("key_moments", []), int(entry.get("turn_count", summary.get("turn_count", 1))))

	if int(summary.get("enemy_count", 0)) <= 0:
		summary["enemy_count"] = (summary.get("enemies_defeated", []) as Array).size()
	if int(summary.get("ally_count", 0)) <= 0:
		summary["ally_count"] = maxi(1, _estimate_ally_count(summary))

	return summary

func _detect_trigger_events(summary: Dictionary) -> Array[String]:
	var triggers: Array[String] = []
	var allies_lost: Array = summary.get("allies_lost", [])
	var weather_events: Array = summary.get("weather_events", [])
	var enemy_count := int(summary.get("enemy_count", 0))
	var ally_count := maxi(1, int(summary.get("ally_count", 1)))

	if allies_lost.is_empty():
		triggers.append("quiet_strategy")
	if enemy_count >= ally_count * 3:
		triggers.append("overwhelming_force")
	if _has_final_turn_loss(summary):
		triggers.append("desperate_victory")
	if weather_events.size() >= 3:
		triggers.append("weather_master")

	return triggers

func _resolve_style(trigger_events: Array[String]) -> ChronicleEntry.ChronicleStyle:
	for trigger_event in STYLE_TRIGGER_PRIORITY:
		if trigger_events.has(trigger_event):
			return STYLE_PRIORITY[trigger_event]
	return DEFAULT_STYLE

func _build_template_context(chapter_id: String, summary: Dictionary, choices_made: Array) -> Dictionary:
	var chapter_title := _resolve_stage_title(chapter_id)
	var enemies_defeated: Array = summary.get("enemies_defeated", [])
	var allies_lost: Array = summary.get("allies_lost", [])
	var weather_events: Array = summary.get("weather_events", [])
	var key_moments: Array = summary.get("key_moments", [])
	var final_turn_loss := _describe_final_turn_loss(summary)
	var casualty_phrase := "no ally was lost"
	if not allies_lost.is_empty():
		casualty_phrase = "%d allies fell" % allies_lost.size()
	return {
		"chapter_id": chapter_id,
		"chapter_title": chapter_title,
		"turn_phrase": _format_turn_phrase(int(summary.get("turn_count", 1))),
		"enemy_phrase": _describe_enemy_types(enemies_defeated),
		"enemy_count": int(summary.get("enemy_count", enemies_defeated.size())),
		"ally_count": int(summary.get("ally_count", 1)),
		"casualty_phrase": casualty_phrase,
		"weather_phrase": _describe_weather(weather_events),
		"action_phrase": _describe_key_actions(key_moments),
		"choice_phrase": _describe_choice_trace(choices_made),
		"final_turn_loss": final_turn_loss,
	}

func _build_narrative_text(style: ChronicleEntry.ChronicleStyle, trigger_events: Array[String], context: Dictionary) -> String:
	var template_group: Dictionary = chronicle_templates.get(style, chronicle_templates[DEFAULT_STYLE])
	var template := String(template_group.get("default", "{chapter_title} was recorded without a field note."))
	for trigger_event in trigger_events:
		if template_group.has(trigger_event):
			template = String(template_group.get(trigger_event, template))
			break
	return template.format(context)

func _resolve_stage_title(chapter_id: String) -> String:
	var stage_path := "res://data/stages/%s_stage.tres" % chapter_id.to_lower()
	if ResourceLoader.exists(stage_path):
		var stage := load(stage_path) as StageData
		if stage != null:
			return stage.stage_title.strip_edges()
	return chapter_id.replace("_", " ")

func _append_unique_strings(target: Variant, values: Variant) -> void:
	if typeof(target) != TYPE_ARRAY:
		return
	var resolved_target := target as Array
	for value in values:
		var normalized := String(value).strip_edges()
		if normalized.is_empty() or resolved_target.has(normalized):
			continue
		resolved_target.append(normalized)

func _append_unique_dictionaries(target: Variant, values: Array[Dictionary]) -> void:
	if typeof(target) != TYPE_ARRAY:
		return
	var resolved_target := target as Array
	for value in values:
		if resolved_target.has(value):
			continue
		resolved_target.append(value)

func _append_key_moments(target: Variant, values: Variant, fallback_turn: int) -> void:
	if typeof(target) != TYPE_ARRAY:
		return
	var resolved_target := target as Array
	for raw_value in values:
		if typeof(raw_value) != TYPE_DICTIONARY:
			continue
		var moment := (raw_value as Dictionary).duplicate(true)
		moment["turn"] = int(moment.get("turn", fallback_turn))
		resolved_target.append(moment)

func _normalize_loss_entries(raw_losses: Variant) -> Array[Dictionary]:
	var losses: Array[Dictionary] = []
	for raw_loss in raw_losses:
		if typeof(raw_loss) == TYPE_DICTIONARY:
			var loss := raw_loss as Dictionary
			losses.append({
				"unit_id": String(loss.get("unit_id", loss.get("name", ""))).strip_edges(),
				"turn": int(loss.get("turn", -1)),
			})
		else:
			var unit_id := String(raw_loss).strip_edges()
			if unit_id.is_empty():
				continue
			losses.append({
				"unit_id": unit_id,
				"turn": -1,
			})
	return losses

func _estimate_ally_count(summary: Dictionary) -> int:
	var actor_ids: Dictionary = {}
	for raw_moment in summary.get("key_moments", []):
		if typeof(raw_moment) != TYPE_DICTIONARY:
			continue
		var actor_id := String((raw_moment as Dictionary).get("actor_id", "")).strip_edges()
		if actor_id.is_empty():
			continue
		actor_ids[actor_id] = true
	return actor_ids.size()

func _has_final_turn_loss(summary: Dictionary) -> bool:
	var final_turn := int(summary.get("turn_count", 1))
	for raw_loss in summary.get("allies_lost", []):
		if typeof(raw_loss) == TYPE_DICTIONARY and int((raw_loss as Dictionary).get("turn", -1)) == final_turn:
			return true
	for raw_moment in summary.get("key_moments", []):
		if typeof(raw_moment) != TYPE_DICTIONARY:
			continue
		var moment := raw_moment as Dictionary
		if int(moment.get("turn", -1)) != final_turn:
			continue
		if bool(moment.get("actor_died", false)) or (String(moment.get("source", "")) == "damage_share" and not (moment.get("killed_unit_ids", []) as Array).is_empty()):
			return true
	return false

func _describe_final_turn_loss(summary: Dictionary) -> String:
	var final_turn := int(summary.get("turn_count", 1))
	for raw_loss in summary.get("allies_lost", []):
		if typeof(raw_loss) != TYPE_DICTIONARY:
			continue
		var loss := raw_loss as Dictionary
		if int(loss.get("turn", -1)) == final_turn:
			return "%s fell on the final turn" % _humanize_identifier(String(loss.get("unit_id", "ally")))
	for raw_moment in summary.get("key_moments", []):
		if typeof(raw_moment) != TYPE_DICTIONARY:
			continue
		var moment := raw_moment as Dictionary
		if int(moment.get("turn", -1)) == final_turn and bool(moment.get("actor_died", false)):
			return "%s fell on the final turn" % _humanize_identifier(String(moment.get("actor_id", "ally")))
	return "an ally fell on the final turn"

func _describe_enemy_types(enemies_defeated: Array) -> String:
	if enemies_defeated.is_empty():
		return "the enemy line"
	var names: Array[String] = []
	for enemy_id in enemies_defeated:
		var humanized := _humanize_identifier(String(enemy_id))
		if names.has(humanized):
			continue
		names.append(humanized)
	if names.size() == 1:
		return names[0]
	if names.size() == 2:
		return "%s and %s" % [names[0], names[1]]
	return "%s, and %s" % [", ".join(names.slice(0, names.size() - 1)), names[-1]]

func _describe_weather(weather_events: Array) -> String:
	if weather_events.is_empty():
		return "the sky stayed plain"
	var phrases: Array[String] = []
	for event_id in weather_events:
		phrases.append(_humanize_identifier(String(event_id)))
	if phrases.size() == 1:
		return phrases[0]
	if phrases.size() == 2:
		return "%s and %s" % [phrases[0], phrases[1]]
	return "%s, and %s" % [", ".join(phrases.slice(0, phrases.size() - 1)), phrases[-1]]

func _describe_key_actions(key_moments: Array) -> String:
	if key_moments.is_empty():
		return "the line held without ornament"
	var phrases: Array[String] = []
	for raw_moment in key_moments:
		if typeof(raw_moment) != TYPE_DICTIONARY:
			continue
		var moment := raw_moment as Dictionary
		var moment_type := String(moment.get("type", "")).strip_edges()
		var actor_id := _humanize_identifier(String(moment.get("actor_id", "the squad")))
		match moment_type:
			"attack":
				var target_id := _humanize_identifier(String(moment.get("target_id", "the enemy")))
				phrases.append("%s struck at %s" % [actor_id, target_id])
			"sacrifice_play":
				var protected_id := _humanize_identifier(String(moment.get("protected_unit_id", "the wounded")))
				phrases.append("%s gave their place to shield %s" % [actor_id, protected_id])
			"weather":
				phrases.append("the weather turned with %s" % _humanize_identifier(String(moment.get("weather_effect_id", "storm pressure"))))
			_:
				continue
		if phrases.size() >= 2:
			break
	if phrases.is_empty():
		return "the line held without ornament"
	if phrases.size() == 1:
		return phrases[0]
	return "%s while %s" % [phrases[0], phrases[1]]

func _describe_choice_trace(choices_made: Array) -> String:
	if choices_made.is_empty():
		return "no disputed order remained"
	return "the last standing choice was %s" % _humanize_identifier(String(choices_made[-1]))

func _resolve_adaptive_pattern(summary: Dictionary, choices_made: Array, trigger_events: Array[String]) -> String:
	if _has_merciful_pattern(summary, choices_made):
		return ADAPTIVE_PATTERN_MERCIFUL
	var rush_count := _count_rush_moments(summary, trigger_events)
	var stall_count := _count_stall_moments(summary, trigger_events)
	var turn_count := int(summary.get("turn_count", 1))
	if rush_count > stall_count and turn_count <= 8:
		return ADAPTIVE_PATTERN_AGGRESSIVE
	if rush_count >= stall_count + 2:
		return ADAPTIVE_PATTERN_AGGRESSIVE
	if stall_count > rush_count and turn_count >= 10:
		return ADAPTIVE_PATTERN_DEFENSIVE
	if trigger_events.has("quiet_strategy") or turn_count >= 14:
		return ADAPTIVE_PATTERN_DEFENSIVE
	return ADAPTIVE_PATTERN_BALANCED

func _has_merciful_pattern(summary: Dictionary, choices_made: Array) -> bool:
	for raw_choice in choices_made:
		var normalized_choice := String(raw_choice).strip_edges().to_lower()
		if normalized_choice == "spared_enemy" or normalized_choice.contains("mercy"):
			return true
	for raw_moment in summary.get("key_moments", []):
		if typeof(raw_moment) != TYPE_DICTIONARY:
			continue
		var moment := raw_moment as Dictionary
		if bool(moment.get("boss_low_hp", false)) and (bool(moment.get("paused_attack", false)) or bool(moment.get("mercy_pause", false)) or bool(moment.get("spared", false))):
			return true
		var boss_hp := float(moment.get("boss_hp", -1.0))
		var boss_max_hp := float(moment.get("boss_max_hp", 0.0))
		if boss_max_hp > 0.0 and boss_hp >= 0.0 and (boss_hp / boss_max_hp) <= 0.25:
			var moment_type := String(moment.get("type", "")).strip_edges().to_lower()
			if moment_type.contains("mercy") or moment_type.contains("pause") or bool(moment.get("spared", false)):
				return true
	return false

func _count_rush_moments(summary: Dictionary, trigger_events: Array[String]) -> int:
	var rush_count := 0
	if trigger_events.has("overwhelming_force"):
		rush_count += 2
	for raw_moment in summary.get("key_moments", []):
		if typeof(raw_moment) != TYPE_DICTIONARY:
			continue
		var moment := raw_moment as Dictionary
		var moment_type := String(moment.get("type", "")).strip_edges().to_lower()
		if moment_type == "attack" or moment_type == "support_attack" or moment_type.contains("charge"):
			rush_count += 1
	return rush_count

func _count_stall_moments(summary: Dictionary, trigger_events: Array[String]) -> int:
	var stall_count := 0
	if trigger_events.has("quiet_strategy"):
		stall_count += 2
	if trigger_events.has("weather_master"):
		stall_count += 1
	for raw_moment in summary.get("key_moments", []):
		if typeof(raw_moment) != TYPE_DICTIONARY:
			continue
		var moment := raw_moment as Dictionary
		var moment_type := String(moment.get("type", "")).strip_edges().to_lower()
		if moment_type == "sacrifice_play" or moment_type == "weather" or moment_type.contains("wait") or moment_type.contains("guard"):
			stall_count += 1
	return stall_count

func _describe_adaptive_pattern(pattern: String, summary: Dictionary, choices_made: Array, trigger_events: Array[String]) -> String:
	match pattern:
		ADAPTIVE_PATTERN_AGGRESSIVE:
			return "rush pattern after %d turns with %d finishing exchanges" % [int(summary.get("turn_count", 1)), _count_rush_moments(summary, trigger_events)]
		ADAPTIVE_PATTERN_DEFENSIVE:
			return "stall pattern anchored by %d patient moments" % _count_stall_moments(summary, trigger_events)
		ADAPTIVE_PATTERN_MERCIFUL:
			return "mercy pattern after %s" % _describe_choice_trace(choices_made)
		_:
			return "balanced field record"

func _format_turn_phrase(turn_count: int) -> String:
	return "%d turns" % maxi(1, turn_count)

func _humanize_identifier(raw_value: String) -> String:
	var normalized := raw_value.strip_edges().replace("-", "_")
	if normalized.is_empty():
		return "unknown"
	var parts := normalized.split("_", false)
	for index in range(parts.size()):
		parts[index] = String(parts[index]).capitalize()
	return " ".join(parts)
