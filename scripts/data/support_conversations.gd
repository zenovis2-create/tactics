class_name SupportConversations
extends RefCounted

const RELATIONSHIP_TIMELINES := {
	"ally_rian:ally_serin": {
		3: "Remember when we barely made it through the flooded monastery? You still laughed after the doors sealed behind us.",
		4: "You covered the rear without being asked. I did not miss that, Rian.",
		5: "If the line breaks again, stay where I can reach you. I am done pretending that is only tactics.",
		6: "Say my name and I will answer. That is enough."
	}
}

const SUPPORT_CONVERSATION_ENTRIES := {
	"ally_rian:ally_serin": {
		3: {
			"topic": "The monastery still lingers between them. Serin finally names the fear she carried out of the flood.",
			"context_A": "You held us together in there. I'm glad you were beside me.",
			"context_B": "I still don't know what that night was supposed to mean for us.",
			"context_C": "Stay quiet and let Serin say everything she has been holding back."
		},
		4: {
			"topic": "Serin brings up the rear-guard line and asks whether Rian noticed how often she covered his blind side.",
			"context_A": "I noticed. I trusted your step before I understood why.",
			"context_B": "I noticed, but I still treated it like battlefield habit.",
			"context_C": "Let the silence sit so Serin can decide how much of the truth to share."
		},
		5: {
			"topic": "The next confession is harder: Serin admits her concern stopped feeling like tactics a long time ago.",
			"context_A": "Then stay close to me. I won't pretend this is only strategy either.",
			"context_B": "I feel it too, but I'm still trying to understand what to call it.",
			"context_C": "Listen without interrupting and trust Serin to finish the thought in her own way."
		},
		6: {
			"topic": "At the edge of the last battle, Serin asks whether a shared name can carry them farther than any oath.",
			"context_A": "It can. If you call, I'll answer every time.",
			"context_B": "I want to believe that, even if I still don't have the right words.",
			"context_C": "Answer with presence instead of certainty and let the bond speak first."
		}
	}
}

const NAME_CALL_LINES := {
	"ally_serin": {
		"generic": "Serin, hold formation with me.",
		3: "Serin. Stay on my mark—just like the monastery.",
		4: "Serin, with me. We have held worse lines than this.",
		5: "Serin—stay close. I know your rhythm now.",
		6: "Serin. I know your name, and I will not let it vanish."
	},
	"default": {
		"generic": "%s, with me.",
		3: "%s. Stay on my mark.",
		4: "%s, with me. We have weathered this much together.",
		5: "%s—stay close. I trust you.",
		6: "%s. I know your name. Answer me."
	}
}

const NAME_CALL_CHOICE_LINES := {
	"ally_serin": {
		"accept": "당신이 내 이름... 처음 불러준 사람입니다.",
		"defer": "당신과 싸울 수 있어서 다행입니다,长官."
	},
	"default": {
		"accept": "%s... you were the first to call my name.",
		"defer": "I am glad I can fight beside you, Commander."
	}
}

static func normalize_pair_id(pair_id: String) -> String:
	var normalized := pair_id.strip_edges()
	if normalized.is_empty():
		return ""
	var parts := normalized.split(":", false)
	if parts.size() != 2:
		return normalized
	parts.sort()
	return "%s:%s" % [parts[0], parts[1]]

static func get_support_conversation_entry(pair_id: String, rank: int) -> Dictionary:
	var normalized_pair := normalize_pair_id(pair_id)
	var pair_entries: Dictionary = SUPPORT_CONVERSATION_ENTRIES.get(normalized_pair, {})
	if pair_entries.has(rank):
		return (pair_entries.get(rank, {}) as Dictionary).duplicate(true)
	return _build_default_support_conversation(normalized_pair, rank)

static func get_support_history_line(pair_id: String, rank: int) -> String:
	var normalized_pair := normalize_pair_id(pair_id)
	var pair_lines: Dictionary = RELATIONSHIP_TIMELINES.get(normalized_pair, {})
	var exact_line := String(pair_lines.get(rank, "")).strip_edges()
	if not exact_line.is_empty():
		return exact_line
	match rank:
		6:
			return "The last exchange became a vow instead of a tactic."
		5:
			return "By then the conversation sounded more like trust than duty."
		4:
			return "The distance between them narrowed into something warm."
		3:
			return "They finally named the battle that first bound them together."
		_:
			return ""

static func get_name_call_line(unit_id: String, support_rank: int) -> String:
	var normalized_unit := unit_id.strip_edges()
	var line_set: Dictionary = NAME_CALL_LINES.get(normalized_unit, NAME_CALL_LINES["default"])
	var rank_key: Variant = "generic"
	if support_rank >= 6:
		rank_key = 6
	elif support_rank >= 5:
		rank_key = 5
	elif support_rank >= 4:
		rank_key = 4
	elif support_rank >= 3:
		rank_key = 3
	var template := String(line_set.get(rank_key, line_set.get("generic", "%s, with me.")))
	var ally_name := get_unit_display_name(normalized_unit)
	if template.contains("%s"):
		return template % ally_name
	return template

static func get_name_call_choice_line(unit_id: String, support_rank: int, accepted: bool) -> String:
	var normalized_unit := unit_id.strip_edges()
	if accepted and support_rank < 6:
		return get_name_call_line(normalized_unit, support_rank)
	var line_set: Dictionary = NAME_CALL_CHOICE_LINES.get(normalized_unit, NAME_CALL_CHOICE_LINES["default"])
	var template := String(line_set.get("accept" if accepted else "defer", "")).strip_edges()
	if template.is_empty():
		return get_name_call_line(normalized_unit, support_rank)
	var ally_name := get_unit_display_name(normalized_unit)
	if template.contains("%s"):
		return template % ally_name
	return template

static func get_rank_label(rank: int) -> String:
	if rank >= 6:
		return "S"
	if rank >= 5:
		return "A"
	if rank >= 4:
		return "B"
	if rank >= 3:
		return "C"
	match rank:
		2:
			return "B"
		1:
			return "C"
		_:
			return "-"

static func get_unit_display_name(unit_id: String) -> String:
	var normalized_unit := unit_id.strip_edges().trim_prefix("ally_")
	if normalized_unit.is_empty():
		return "Ally"
	return normalized_unit.capitalize()

static func _build_default_support_conversation(pair_id: String, rank: int) -> Dictionary:
	var ally_name := _resolve_pair_partner_name(pair_id)
	var topic := "The bond between Rian and %s rises after another shared battle." % ally_name
	match rank:
		4:
			topic = "%s quietly revisits a moment when trust arrived faster than either of them expected." % ally_name
		5:
			topic = "%s asks whether what they feel can still be called duty." % ally_name
		6:
			topic = "%s and Rian finally speak as if the bond itself has become an oath." % ally_name
	return {
		"topic": topic,
		"context_A": "Tell %s they have become someone you rely on." % ally_name,
		"context_B": "Admit that you still do not have a clean answer for what this bond means." ,
		"context_C": "Listen in silence and let %s decide the pace of the moment." % ally_name
	}

static func _resolve_pair_partner_name(pair_id: String) -> String:
	var normalized_pair := normalize_pair_id(pair_id)
	for unit_id in normalized_pair.split(":", false):
		if unit_id != "ally_rian":
			return get_unit_display_name(unit_id)
	return "Ally"
