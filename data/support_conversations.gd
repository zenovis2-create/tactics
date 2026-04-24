class_name SupportConversations
extends RefCounted

const CONVERSATIONS: Dictionary = {
	"rian_serin": {
		1: "Serin: Rian, do you remember the border trail? ...I thought I would lose you there.",
		2: "Serin: You've changed. The way you fight now — it's like you finally believe you're worth protecting.",
		3: "Serin: Rian. When this is over — I'm staying. Not because of orders. Because of you.",
		4: "Serin: Rian. I remember your name. I remember everyone's name, because of you."
	},
	"rian_bran": {
		1: "Bran: You're not bad for someone who learned to fight yesterday.",
		2: "Bran: ...You held the line at Hardren. That wasn't luck.",
		3: "Bran: Rian. I was wrong about you. I'm glad I was wrong.",
		4: "Bran: Rian. The fortress fell. But you — you carried everyone out. I won't forget that name."
	},
	"rian_tia": {
		1: "Tia: The Greenwood tried to kill us both. We made it anyway.",
		2: "Tia: You fight like someone who has something to protect. ...Me too.",
		3: "Tia: Rian. You're the first person who ever believed my forest stories were worth hearing.",
		4: "Tia: Rian. I name you kin. The forest knows you now. It will remember."
	},
	"rian_enoch": {
		1: "Enoch: You read the archive ledgers faster than I did. Suspicious.",
		2: "Enoch: ...Zero was a person. You made me remember that again.",
		3: "Enoch: Rian. When we reached the Gray Archive, I thought — maybe this stranger is the one who'll believe what I found.",
		4: "Enoch: Rian. Zero had a name. So did you. The record will show both."
	},
	"rian_kyle": {
		1: "Kyle: The outer line was supposed to hold. It didn't. But you made it hold as long as it could.",
		2: "Kyle: I testified at the record gate. You were the only one who listened.",
		3: "Kyle: Rian. The broken standard — the one I carried — it was yours all along. You gave it back to me.",
		4: "Kyle: Rian. My testimony is in the record now. Your name is in my testimony."
	},
	"rian_noah": {
		1: "Noah: The archive keeper should not take sides. ...But you make it hard to stay neutral.",
		2: "Noah: Every record you uncovered — I filed them. All of them. For the record.",
		3: "Noah: Rian. I was going to edit you out of history. I'm glad I didn't.",
		4: "Noah: Rian. The record is complete. Your name — your real name — is in it. Forever."
	}
}

static func get_conversation(pair_id: String, rank: int) -> String:
	var normalized_pair_id := _canonicalize_pair_id(pair_id)
	if CONVERSATIONS.has(normalized_pair_id) and CONVERSATIONS[normalized_pair_id].has(rank):
		return String(CONVERSATIONS[normalized_pair_id][rank])
	return ""

static func get_pair_id(unit_a: String, unit_b: String) -> String:
	var left := _normalize_unit_token(unit_a)
	var right := _normalize_unit_token(unit_b)
	if left.is_empty() or right.is_empty() or left == right:
		return ""
	if left == "rian":
		return "rian_" + right
	if right == "rian":
		return "rian_" + left
	var sorted := [left, right]
	sorted.sort()
	return "%s_%s" % [sorted[0], sorted[1]]

static func get_rank_label(rank: int) -> String:
	match rank:
		1:
			return "C"
		2:
			return "B"
		3:
			return "A"
		4:
			return "S"
		_:
			return ""

static func _normalize_unit_token(unit_id: String) -> String:
	var normalized := unit_id.strip_edges().to_lower()
	if normalized.begins_with("ally_"):
		normalized = normalized.trim_prefix("ally_")
	elif normalized.begins_with("enemy_"):
		normalized = normalized.trim_prefix("enemy_")
	if normalized == "karl":
		return "kyle"
	return normalized

static func _canonicalize_pair_id(pair_id: String) -> String:
	var normalized_pair_id := pair_id.strip_edges().to_lower()
	if normalized_pair_id == "rian_karl":
		return "rian_kyle"
	return normalized_pair_id
