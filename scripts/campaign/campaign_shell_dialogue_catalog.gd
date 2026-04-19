class_name CampaignShellDialogueCatalog
extends RefCounted

const SupportConversations = preload("res://data/support_conversations.gd")

const SUPPORT_RANK_ORDER: Array[int] = [1, 2, 3]

static func get_support_dialogue(pair_id: String, rank: int) -> String:
	if rank < 1 or rank > 3:
		return ""
	return SupportConversations.get_conversation(pair_id, rank)

static func get_support_dialogue_entries(pair_id: String) -> Array[String]:
	var entries: Array[String] = []
	for rank in SUPPORT_RANK_ORDER:
		var line := get_support_dialogue(pair_id, rank)
		if line.is_empty():
			continue
		entries.append("%s Rank — %s" % [SupportConversations.get_rank_label(rank), line])
	return entries

static func get_all_support_dialogue_entries() -> Dictionary:
	var entries: Dictionary = {}
	for pair_id in SupportConversations.CONVERSATIONS.keys():
		entries[String(pair_id)] = get_support_dialogue_entries(String(pair_id))
	return entries

const CH01_BRIEFING := {
	"chapter": "CH01 — Dawn Oath",
	"turn_limit": 10,
	"enemy_intel": [
		"3x Vanguard — shielded oath line holding the center",
		"2x Skirmisher — ridge pressure on both flanks",
		"1x Roderic (Boss) — commander unit anchoring the final push",
		"[KNOWN] The enemy wants the squad trapped in the narrow lane"
	],
	"terrain_summary": [
		"Ridge Cliffs: defense advantage on the outer corners",
		"Broken Rock Line: blocks the straight advance",
		"Center Pass: single-lane pressure point into the commander line"
	],
	"optional_objectives": [
		"Defeat enemy commander with Serin",
		"No ally casualties"
	],
	"brief_text": "The border raiders are finally standing in formation instead of scattering. This is the squad's first real test against a line that expects them to break first."
}

const CH02_BRIEFING := {
	"chapter": "CH02 — Broken Border Fortress",
	"turn_limit": 12,
	"enemy_intel": [
		"2x Vanguard — gate guard holding the inner breach",
		"2x Skirmisher — smoke-side harassment from the ramparts",
		"1x Hardren Captain (Boss) — fortress command at the banner hall",
		"[KNOWN] Bran's remaining line is trapped behind the last choke"
	],
	"terrain_summary": [
		"Gate Approach: narrow entry with no easy retreat",
		"Rampart Smoke: limited sightlines and flank pressure",
		"Banner Hall: the boss can reinforce from the interior"
	],
	"optional_objectives": [
		"Lete must survive",
		"Activate 3 traps"
	],
	"brief_text": "Hardren is still burning, but the last defensive shell has not collapsed. If the squad wants the fortress intact enough to read, they have to hit fast and clean."
}

const CH03_BRIEFING := {
	"chapter": "CH03 — Whispering Greenwood",
	"turn_limit": 11,
	"enemy_intel": [
		"3x Skirmisher — hidden shooters covering the altar path",
		"2x Vanguard — trap-line enforcers holding the burn lane",
		"1x Forest Hunt Captain (Boss) — final hunter command at the shrine",
		"[KNOWN] Greenwood punishes careless movement more than direct aggression"
	],
	"terrain_summary": [
		"Forest Traps: movement lanes are pre-sighted",
		"Burn Scar: low-cover route through the basin",
		"Hunter Altar: final stand location with overlapping fire"
	],
	"optional_objectives": [
		"Tia defeats enemy boss",
		"No structures destroyed"
	],
	"brief_text": "Tia is watching from inside the trees, and the squad is walking into a battlefield built to punish hesitation. Every lane through Greenwood has already been chosen by someone."
}

const CH04_BRIEFING := {
	"chapter": "CH04 — Sunken Monastery",
	"turn_limit": 12,
	"enemy_intel": [
		"2x Vanguard — chapel defenders holding the dry ground",
		"2x Skirmisher — flooded-side harassment around the archive wing",
		"1x Basil (Boss) — altar guard controlling the research vault",
		"[KNOWN] Ark is the only one who reads the drowned route cleanly"
	],
	"terrain_summary": [
		"Flooded Cloister: slow movement and exposed crossings",
		"Chapel Floor: safer footing with stronger defensive cover",
		"Archive Wing: final approach to Ark's records"
	],
	"optional_objectives": [
		"Survive with Ark",
		"Collect 2 research logs"
	],
	"brief_text": "The monastery still holds Ark's work, but the waterline has turned the approach into a timing problem. Move too slowly and the defenders choose every exchange for you."
}

const CH05_BRIEFING := {
	"chapter": "CH05 — Gray Archive",
	"turn_limit": 13,
	"enemy_intel": [
		"3x Vanguard — ash-line custodians sealing the ledger route",
		"2x Skirmisher — shelf-side pressure from the burning stacks",
		"1x Archive Warden (Boss) — final seal on Zero's chamber",
		"[KNOWN] Enoch knows the layout, but the fire is already rewriting it"
	],
	"terrain_summary": [
		"Burning Stacks: collapsing sightlines and route pressure",
		"Ledger Lanes: narrow archive corridors limit deployment",
		"Core Vault: the last clean record room before the ash closes"
	],
	"optional_objectives": [
		"Defeat boss without Noah dying",
		"Collect 3 ledger entries"
	],
	"brief_text": "The archive is burning faster than the truth can be carried out of it. Zero's last stand is not only a fight for survival — it is a fight against the ash taking the record first."
}

const CH06_BRIEFING := {
	"chapter": "CH06 — Iron Keep of Valtor",
	"turn_limit": 15,
	"enemy_intel": [
		"3x Vanguard — standard formation, shield wall",
		"2x Skirmisher — flanking positions",
		"1x Valtor (Boss) — siege engine, AoE attacks",
		"[KNOWN] Valtor does not retreat"
	],
	"terrain_summary": [
		"Inner Bailey: high ground advantage",
		"Fire Braziers: environmental hazard around the keep lanes",
		"Gate Entrance: narrow pass, chokepoint"
	],
	"optional_objectives": [
		"Valtor's civilian escapes",
		"Reduce fort resistance to 0"
	],
	"brief_text": "Valtor's iron keep is the last wall between the campaign and Ellyor. The siege math is simple — break it before it breaks you."
}

const CH07_BRIEFING := {
	"chapter": "CH07 — City Without Names",
	"turn_limit": 14,
	"enemy_intel": [
		"2x Vanguard — processional guard at the city gate",
		"3x Skirmisher — censor teams covering the market approaches",
		"1x Procession Captain (Boss) — command unit enforcing the rite",
		"[KNOWN] Mira and Neri are somewhere inside the policy machine"
	],
	"terrain_summary": [
		"City Gate: tight front approach into the queue line",
		"Blank Market: open lanes with crossfire risk",
		"Procession Route: the boss can fall back through civilians and bells"
	],
	"optional_objectives": [
		"Recruit Mira",
		"Collect city seal"
	],
	"brief_text": "Ellyor does not look like a battlefield until the squad steps into the queue. Forgetting has become city policy, and the gate is where that policy starts biting back."
}

const CH08_BRIEFING := {
	"chapter": "CH08 — Black Hound Night",
	"turn_limit": 14,
	"enemy_intel": [
		"3x Skirmisher — black-hound hunters working the ruin lanes",
		"2x Vanguard — ruin sentries holding the central stones",
		"1x Lete (Boss) — relentless hunt lead across the forest ruins",
		"[KNOWN] The hunters know the terrain better than the squad does"
	],
	"terrain_summary": [
		"Forest Ruins: broken cover and sudden flank lines",
		"Collapsed Causeway: chokepoint into the hunt zone",
		"Moonlit Clearing: exposed center where Lete can force the duel"
	],
	"optional_objectives": [
		"Lete defects alive",
		"No black-hound casualties"
	],
	"brief_text": "This is not a march anymore. It is Lete's last hunt, and every ruined wall in the forest is part of the trap she wants the squad to spring."
}

const CH09A_BRIEFING := {
	"chapter": "CH09A — Broken Standard",
	"turn_limit": 15,
	"enemy_intel": [
		"3x Vanguard — outer-line soldiers holding the testimony gate",
		"2x Skirmisher — censor support inside the court",
		"1x Outer Line Captain (Boss) — final command blocking Kyle's route",
		"[KNOWN] The line between memory and erasure is being enforced in real time"
	],
	"terrain_summary": [
		"South Entry: the only safe insertion lane",
		"Censor Court: exposed center with overlapping pressure",
		"Root Access Gate: final choke between witness and archive"
	],
	"optional_objectives": [
		"Kyle testifies",
		"No allied casualties"
	],
	"brief_text": "Kyle's line is still standing, but it has been turned into a filter for what is allowed to survive. The squad is not only breaking a defense here — it is breaking a policy."
}

const CH09B_BRIEFING := {
	"chapter": "CH09B — Abyss of Record",
	"turn_limit": 16,
	"enemy_intel": [
		"2x Vanguard — archive enforcers at the root shelves",
		"3x Skirmisher — moving fire through the stack lanes",
		"1x Melkion (Boss) — archive keeper reshaping the battle flow",
		"[KNOWN] The editor watches and rearranges the battlefield itself"
	],
	"terrain_summary": [
		"Root Shelves: limited lanes with long sightlines",
		"Keeper Walks: elevated routes for ranged pressure",
		"Revision Core: central node where Melkion can reset the pace"
	],
	"optional_objectives": [
		"Melkion's truth revealed",
		"Noah survives"
	],
	"brief_text": "The root archive is not trying to kill the squad quickly. It is trying to decide which version of the battle is allowed to remain when it ends."
}

const CH10_BRIEFING := {
	"chapter": "CH10 — Nameless Tower",
	"turn_limit": 18,
	"enemy_intel": [
		"3x Vanguard — final keep guard on the bell ascent",
		"2x Skirmisher — corridor pressure below the dais",
		"1x Karron (Boss) — tower anchor controlling the final approach",
		"[KNOWN] The last ascent is built around the bell and the names tied to it"
	],
	"terrain_summary": [
		"South Bell Approach: long entry into enemy range",
		"Central Keep: layered cover and multiple reinforcement lanes",
		"North Bell Dais: final high-ground anchor before the end"
	],
	"optional_objectives": [
		"All allies Name Called",
		"No ally deaths"
	],
	"brief_text": "The final ascent is not about reaching the tower anymore. It is about carrying every surviving name through the last structure built to erase them."
}

static func get_briefing(stage_id: StringName) -> Dictionary:
	return {}
	match stage_id:
		&"CH01_05":
			return CH01_BRIEFING.duplicate(true)
		&"CH02_05":
			return CH02_BRIEFING.duplicate(true)
		&"CH03_05":
			return CH03_BRIEFING.duplicate(true)
		&"CH04_05":
			return CH04_BRIEFING.duplicate(true)
		&"CH05_05":
			return CH05_BRIEFING.duplicate(true)
		&"CH06_05":
			return CH06_BRIEFING.duplicate(true)
		&"CH07_05":
			return CH07_BRIEFING.duplicate(true)
		&"CH08_05":
			return CH08_BRIEFING.duplicate(true)
		&"CH09A_05":
			return CH09A_BRIEFING.duplicate(true)
		&"CH09B_05":
			return CH09B_BRIEFING.duplicate(true)
		&"CH10_05":
			return CH10_BRIEFING.duplicate(true)
		_:
			return {}
