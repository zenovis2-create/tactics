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
		"quiet_strategy": [
			"{chapter_title}에서는 아군의 이름이 하나도 꺾이지 않았다. {enemy_phrase}는 오래 준비된 포위 속에 잠잠히 무너졌고, {choice_phrase}는 전장을 처음보다 더 고요하게 남겼다.",
			"{chapter_title}의 끝은 조용했다. {enemy_phrase}는 서두르지 않는 진형 앞에 스러졌고, {action_phrase}; 그 뒤에 남은 것은 {choice_phrase}뿐이었다.",
			"{chapter_title}의 기록은 피 대신 침묵을 먼저 적는다. {enemy_phrase}는 빈틈없이 조여 온 흐름에 밀렸고, {choice_phrase}는 마지막까지 흔들리지 않았다."
		],
		"weather_master": [
			"{chapter_title}에선 {weather_phrase}마저 아군의 편에 섰다. {action_phrase}; 그 사이 {enemy_phrase}는 젖은 갈대처럼 꺾였다.",
			"{chapter_title}의 하늘은 {weather_phrase}로 뒤집혔고, 그 틈마다 {action_phrase}. 결국 {enemy_phrase}는 날씨와 진형을 함께 버티지 못했다.",
			"{weather_phrase}가 {chapter_title}의 전황을 덮는 동안, {action_phrase}. 그 물결 끝에서 {enemy_phrase}는 더는 전열을 세우지 못했다."
		],
		"default": [
			"{chapter_title}에는 한 겹 부드러운 빛이 내려앉았다. {enemy_phrase}는 {turn_phrase} 물러났고, {action_phrase}.",
			"{chapter_title}의 마지막 장면은 날카롭기보다 길게 남았다. {enemy_phrase}는 {turn_phrase} 무너졌고, 그 자리를 {action_phrase}가 채웠다.",
			"{chapter_title}의 기록은 소란보다 여운을 남긴다. {enemy_phrase}는 {turn_phrase} 힘을 잃었고, {action_phrase}."
		]
	},
	ChronicleEntry.ChronicleStyle.CONCISE: {
		"overwhelming_force": [
			"{chapter_title}은 {turn_phrase} 확보되었다. 투입 아군은 {ally_count}명, 확인된 적은 {enemy_count}개체였으며, {enemy_phrase}는 계획된 순서대로 정리되었다.",
			"{chapter_title} 공략은 {turn_phrase} 끝났다. 아군 {ally_count}명이 적 {enemy_count}개체를 상대했고, {enemy_phrase}는 우선순위에 따라 차례로 제거되었다.",
			"{chapter_title} 전투는 {turn_phrase} 매듭지어졌다. 수적으로 불리했지만 {enemy_phrase}는 단계적으로 격파되었고, 전열은 끝까지 통제되었다."
		],
		"default": [
			"{chapter_title} 전투는 {turn_phrase} 종료되었다. {enemy_phrase}가 제압되었고, {casualty_phrase}. 또한 {action_phrase}.",
			"{chapter_title}은 {turn_phrase} 결론이 났다. {enemy_phrase}는 모두 무너졌고, {casualty_phrase}; 전장에선 {action_phrase}가 기록되었다.",
			"{chapter_title}의 야전 기록은 단순하다. {turn_phrase} {enemy_phrase}를 정리했고, {casualty_phrase}. 결정적 국면에서는 {action_phrase}."
		]
	},
	ChronicleEntry.ChronicleStyle.BATTLE: {
		"desperate_victory": [
			"{chapter_title}은 마지막 공방 끝에 간신히 열렸다. {casualty_phrase}; {final_turn_loss} {action_phrase}, 그제야 적 전열이 갈라졌다.",
			"{chapter_title}의 승부는 최후의 한 수에서 갈렸다. {final_turn_loss}, 그러나 {action_phrase}가 이어졌고, 끝내 {enemy_phrase}가 무너졌다.",
			"{chapter_title}은 마지막 턴에야 손에 들어왔다. {casualty_phrase}; {final_turn_loss} 생긴 틈을 파고들어 {action_phrase}, 적은 더는 버티지 못했다."
		],
		"default": [
			"{chapter_title}은 {turn_phrase} 무력으로 돌파되었다. {enemy_phrase}는 차례로 베어졌고, {casualty_phrase}; 이어서 {action_phrase}.",
			"{chapter_title}의 결말은 병장기의 힘으로 쓰였다. {turn_phrase} {enemy_phrase}를 눌렀고, {casualty_phrase}. 승부를 기울인 것은 {action_phrase}였다.",
			"{chapter_title} 전투는 힘으로 밀어붙여 끝냈다. {enemy_phrase}는 무너졌고 {casualty_phrase}; 마지막까지 전열을 지탱한 것은 {action_phrase}였다."
		]
	},
}

const STYLE_TEXT_VARIANTS := {
	"annals": [
		"연대기는 이렇게 적는다.",
		"후일의 기록자는 이 장면을 이렇게 남긴다.",
		"남겨진 장부의 첫 줄은 이렇게 시작된다."
	],
	"field_report": [
		"야전 보고는 전황부터 세운다.",
		"남은 병사들의 보고서는 먼저 사실을 적는다.",
		"전장 정리는 짧고 단단한 문장으로 남았다."
	],
	"witness": [
		"생존자들의 증언은 한 문장으로 겹쳐졌다.",
		"전장을 건넌 이들은 이렇게 입을 모았다.",
		"목격자들의 숨이 가라앉은 뒤 남은 말은 이것이었다."
	],
	"prayer": [
		"기도문처럼 낮은 숨결이 기록의 첫머리를 적신다.",
		"사라지지 않기를 바라는 마음이 문장 앞에 먼저 놓였다.",
		"누군가의 침묵 어린 기도가 이 기록의 머리글이 되었다."
	],
	"embers": [
		"식지 않은 재가 문장 끝마다 달라붙어 있었다.",
		"전투가 끝난 뒤에도 열기는 기록 바깥으로 새어 나왔다.",
		"마지막 충돌의 잔열이 아직 문장 속에 남아 있었다."
	],
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
	var casualty_phrase := "아군 피해는 없었다"
	if not allies_lost.is_empty():
		casualty_phrase = "아군 %d명이 쓰러졌다" % allies_lost.size()
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
	var template_variants := _variant_to_string_array(template_group.get("default", ["{chapter_title}의 전장은 기록만 남겼다."]))
	for trigger_event in trigger_events:
		if template_group.has(trigger_event):
			template_variants = _variant_to_string_array(template_group.get(trigger_event, template_variants))
			break
	var seed := "%s|%s|%s" % [String(context.get("chapter_id", "")), str(style), ",".join(trigger_events)]
	var template := _choose_variant(template_variants, seed)
	var style_text := choose_style_text(style, trigger_events, context)
	return "%s %s" % [style_text, template.format(context)]

func choose_style_text(style: ChronicleEntry.ChronicleStyle, trigger_events: Array[String], context: Dictionary = {}) -> String:
	var style_key := "annals"
	if trigger_events.has("weather_master"):
		style_key = "prayer"
	elif trigger_events.has("desperate_victory"):
		style_key = "embers"
	elif trigger_events.has("overwhelming_force"):
		style_key = "field_report"
	elif trigger_events.has("quiet_strategy"):
		style_key = "witness"
	elif style == ChronicleEntry.ChronicleStyle.BATTLE:
		style_key = "embers"
	elif style == ChronicleEntry.ChronicleStyle.POETIC:
		style_key = "prayer"
	var style_variants := _variant_to_string_array(STYLE_TEXT_VARIANTS.get(style_key, STYLE_TEXT_VARIANTS["annals"]))
	var seed := "%s|%s|%s" % [String(context.get("chapter_id", "")), style_key, String(context.get("chapter_title", ""))]
	return _choose_variant(style_variants, seed)

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
			return "%s이 마지막 공방을 버티다 쓰러진 뒤" % _humanize_identifier(String(loss.get("unit_id", "아군")))
	for raw_moment in summary.get("key_moments", []):
		if typeof(raw_moment) != TYPE_DICTIONARY:
			continue
		var moment := raw_moment as Dictionary
		if int(moment.get("turn", -1)) == final_turn and bool(moment.get("actor_died", false)):
			return "%s이 마지막 공방을 버티다 쓰러진 뒤" % _humanize_identifier(String(moment.get("actor_id", "아군")))
	return "마지막 공방에서 아군 하나가 쓰러진 뒤"

func _describe_enemy_types(enemies_defeated: Array) -> String:
	if enemies_defeated.is_empty():
		return "적 전열"
	var names: Array[String] = []
	for enemy_id in enemies_defeated:
		var humanized := _humanize_identifier(String(enemy_id))
		if names.has(humanized):
			continue
		names.append(humanized)
	if names.size() == 1:
		return names[0]
	if names.size() == 2:
		return "%s와 %s" % [names[0], names[1]]
	return "%s, 그리고 %s" % [", ".join(names.slice(0, names.size() - 1)), names[-1]]

func _describe_weather(weather_events: Array) -> String:
	if weather_events.is_empty():
		return "하늘은 잠잠했다"
	var phrases: Array[String] = []
	for event_id in weather_events:
		phrases.append(_humanize_identifier(String(event_id)))
	if phrases.size() == 1:
		return phrases[0]
	if phrases.size() == 2:
		return "%s와 %s" % [phrases[0], phrases[1]]
	return "%s, 그리고 %s" % [", ".join(phrases.slice(0, phrases.size() - 1)), phrases[-1]]

func _describe_key_actions(key_moments: Array) -> String:
	if key_moments.is_empty():
		return "대오는 끝내 무너지지 않았다"
	var phrases: Array[String] = []
	for raw_moment in key_moments:
		if typeof(raw_moment) != TYPE_DICTIONARY:
			continue
		var moment := raw_moment as Dictionary
		var moment_type := String(moment.get("type", "")).strip_edges()
		var actor_id := _humanize_identifier(String(moment.get("actor_id", "아군")))
		match moment_type:
			"attack":
				var target_id := _humanize_identifier(String(moment.get("target_id", "적")))
				phrases.append("%s이 %s을 몰아붙였다" % [actor_id, target_id])
			"sacrifice_play":
				var protected_id := _humanize_identifier(String(moment.get("protected_unit_id", "동료")))
				phrases.append("%s이 %s을 지키려 몸을 던졌다" % [actor_id, protected_id])
			"weather":
				phrases.append("%s의 기세로 기상이 흔들렸다" % _humanize_identifier(String(moment.get("weather_effect_id", "폭풍"))))
			_:
				continue
		if phrases.size() >= 2:
			break
	if phrases.is_empty():
		return "대오는 끝내 무너지지 않았다"
	if phrases.size() == 1:
		return phrases[0]
	return "%s, 그리고 %s" % [phrases[0], phrases[1]]

func _describe_choice_trace(choices_made: Array) -> String:
	if choices_made.is_empty():
		return "끝내 흔들리는 명령은 없었다"
	return "마지막에 남은 결단은 %s였다" % _humanize_identifier(String(choices_made[-1]))

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
			return "%d턴 동안 마무리 공세 %d회를 밀어붙인 돌파형 전개" % [int(summary.get("turn_count", 1)), _count_rush_moments(summary, trigger_events)]
		ADAPTIVE_PATTERN_DEFENSIVE:
			return "인내의 국면 %d회로 버텨 낸 방어형 전개" % _count_stall_moments(summary, trigger_events)
		ADAPTIVE_PATTERN_MERCIFUL:
			return "%s 끝에 남은 자비의 전개" % _describe_choice_trace(choices_made)
		_:
			return "공세와 수비가 맞물린 균형형 전개"

func _format_turn_phrase(turn_count: int) -> String:
	return "%d턴 만에" % maxi(1, turn_count)

func _variant_to_string_array(value: Variant) -> Array[String]:
	var lines: Array[String] = []
	if typeof(value) != TYPE_ARRAY and typeof(value) != TYPE_PACKED_STRING_ARRAY:
		return lines
	for entry in value:
		var text := String(entry).strip_edges()
		if text.is_empty():
			continue
		lines.append(text)
	return lines

func _choose_variant(options: Array[String], seed: String) -> String:
	if options.is_empty():
		return ""
	var index := int(abs(seed.hash())) % options.size()
	return options[index]

func _humanize_identifier(raw_value: String) -> String:
	var normalized := raw_value.strip_edges().replace("-", "_")
	if normalized.is_empty():
		return "알 수 없음"
	var parts := normalized.split("_", false)
	for index in range(parts.size()):
		parts[index] = String(parts[index]).capitalize()
	return " ".join(parts)
