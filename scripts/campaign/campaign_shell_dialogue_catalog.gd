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

const CH04_03_BRIEFING := {
	"chapter": "CH04 — 수문 제어",
	"turn_limit": 12,
	"enemy_intel": [
		"침수 경로 수비병 2기 — 양측 수문 바퀴를 지키는 방어선",
		"견제병 2기 — 빗속 도하 구간에 압박을 거는 보조 화력",
		"[확인] 두 수문 제어점이 모두 맞춰져야 진입로가 안정된다"
	],
	"terrain_summary": [
		"서쪽 수문: 바깥 수위선을 붙잡는 첫 제어 지점",
		"동쪽 수문: 내부 도하 상태를 바꾸는 짝 제어 지점",
		"침수 경로: 두 수문이 맞춰지기 전까지 안전하지 않은 진입선"
	],
	"optional_objectives": [
		"성유물 금고 진입로 안정화",
		"아군 사망 없음"
	],
	"brief_text": "수문 제어는 진입 경로 자체의 안전도를 바꾼다. 이 전투에서는 지형 상태가 교전보다 먼저 승부를 가를 수 있다."
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
	"primary_threat": "발토르가 중앙 성문을 기준으로 광역 압박을 고정한다.",
	"formation_hint": "방패 유닛을 성문 전열에 세우고, 회복/원거리 유닛은 화로 밖 후열에 둔다.",
	"first_turn_warning": "첫 턴 무리한 중앙 진입은 포위와 화로 피해를 동시에 받는다.",
	"useful_counterplay": "측면 포대선을 먼저 낮추면 보스 접근 전 피해 교환을 줄일 수 있다.",
	"brief_text": "Valtor's iron keep is the last wall between the campaign and Ellyor. The siege math is simple — break it before it breaks you."
}

const CH06_02_BRIEFING := {
	"chapter": "CH06 — 포대선",
	"turn_limit": 15,
	"enemy_intel": [
		"포대선 인원 2기 — 양측 윈치를 지키는 외곽 포열 수비병",
		"지원병 1기 — 중앙 사슬 승강문 앞에서 압박을 거는 견제병",
		"[확인] 양측 포대와 중앙 승강문 제어를 모두 무너뜨려야 전선이 열린다"
	],
	"terrain_summary": [
		"서쪽 포대: 좌측 접근선을 붙잡는 외곽 공성 제어점",
		"사슬 승강문: 양측 포대 사이를 묶는 중앙 병목",
		"동쪽 포대: 우측 전선을 고정하는 대응 압박 지점"
	],
	"optional_objectives": [
		"포대선 완전 붕괴",
		"아군 사망 없음"
	],
	"brief_text": "포대선은 중앙 진입을 길게 노출시키며 압박을 고정한다. 엄폐 없는 전진은 포열선이 원하는 교환으로 이어진다."
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
	"primary_threat": "검열대가 시장 접근로를 덮고 이름 말소 압박을 누적시킨다.",
	"formation_hint": "리안을 전열 중앙에 두고, 미라 접근선에는 기동 유닛을 남겨 둔다.",
	"first_turn_warning": "첫 턴부터 시장 중앙으로 벌어지면 척후병 사격선이 후열을 끊는다.",
	"useful_counterplay": "이름 부름과 시민 경로 확보를 먼저 처리하면 보스 압박이 늦어진다.",
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
	"primary_threat": "검은 사냥개가 폐허 엄폐를 타고 후열을 추적한다.",
	"formation_hint": "중앙에 방어선을 세우고, 은신/기동 유닛은 측면 시야를 끊는 데 쓴다.",
	"first_turn_warning": "첫 턴 산개가 과하면 레테가 약한 유닛을 고립시킨다.",
	"useful_counterplay": "레테를 죽이지 않고 압박을 낮추려면 중앙 결투선과 생존 루트를 같이 관리한다.",
	"brief_text": "This is not a march anymore. It is Lete's last hunt, and every ruined wall in the forest is part of the trap she wants the squad to spring."
}

const CH09A_BRIEFING := {
	"chapter": "CH09A — 부서진 군기",
	"turn_limit": 15,
	"enemy_intel": [
		"전위병 3기 — 증언문을 지키는 외곽선 병력",
		"척후병 2기 — 안뜰 안쪽에서 검열을 보조하는 지원병",
		"외곽선 대장 1기(보스) — 카일의 길을 막는 최후 명령권자",
		"[확인] 기억과 소거의 경계선이 이 전장에서 그대로 집행되고 있다"
	],
	"terrain_summary": [
		"남쪽 진입로: 사실상 유일한 안전 투입선",
		"검열 안뜰: 압박이 겹치는 노출 중심지",
		"근원 접근문: 증언과 기록보관소 사이의 마지막 병목"
	],
	"optional_objectives": [
		"카일의 증언 확보",
		"아군 사망 없음"
	],
	"primary_threat": "검열 안뜰의 중첩 압박이 증언 확보 전 접근선을 끊는다.",
	"formation_hint": "전열은 남쪽 병목을 막고, 기동 유닛은 증언문 쪽으로 짧게 진입한다.",
	"first_turn_warning": "첫 턴 중앙 노출은 척후병과 보스 압박을 동시에 부른다.",
	"useful_counterplay": "증언 확보를 우선하면 최종 병목에서 선택지가 늘어난다.",
	"brief_text": "카일의 방어선은 아직 서 있지만, 이제는 무엇이 살아남을 수 있는지를 가르는 필터가 되었다. 이 전투에서 부수는 것은 방어선 하나가 아니라, 사람을 지우는 기준 그 자체다."
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
	"primary_threat": "멜키온이 장거리 기록선과 재배치 압박으로 전투 흐름을 바꾼다.",
	"formation_hint": "노아를 보호 가능한 후열에 두고, 전열은 루트 선반의 긴 사선을 끊는다.",
	"first_turn_warning": "첫 턴 직선 진입은 기록선 사격과 보스 재편성에 걸린다.",
	"useful_counterplay": "중앙 핵심 노드를 먼저 흔들면 멜키온의 전장 편집 압박이 낮아진다.",
	"brief_text": "The root archive is not trying to kill the squad quickly. It is trying to decide which version of the battle is allowed to remain when it ends."
}

const CH10_BRIEFING := {
	"chapter": "CH10 — 무명의 탑",
	"turn_limit": 18,
	"enemy_intel": [
		"전위병 3기 — 종으로 오르는 최후의 성채 경비",
		"척후병 2기 — 종단 아래 회랑에서 압박을 거는 지원병",
		"카르온 1기(보스) — 마지막 진입을 지배하는 탑의 핵심 앵커",
		"[확인] 마지막 상승로는 종과 그에 묶인 이름들을 중심으로 설계되어 있다"
	],
	"terrain_summary": [
		"남쪽 종길: 적 사정거리로 길게 노출되는 진입 구간",
		"중앙 성채: 엄폐와 증원이 겹치는 중층 방어선",
		"북쪽 종단: 최후의 결전을 지배하는 고지대 앵커"
	],
	"optional_objectives": [
		"모든 아군 이름 부름",
		"아군 사망 없음"
	],
	"brief_text": "마지막 상승은 이제 단순히 탑 꼭대기에 도달하는 일이 아니다. 끝까지 남은 모든 이름을, 그것을 지우기 위해 세워진 마지막 구조물 바깥으로 끝내 끌고 나가는 일이다."
}

const CH10_05_BRIEFING := {
	"chapter": "CH10 — 마지막 이름",
	"turn_limit": 16,
	"enemy_intel": [
		"종단 1기 — 최종 접근로의 압박을 고정하는 의식 앵커",
		"닻 사슬 1기 — 종의 압박선을 끊을 수 있는 마지막 해제 제어점",
		"카르온 1기(보스) — 중앙 상승로를 지배하는 최종 탑의 핵심 앵커",
		"[확인] 마지막 진입은 닻 사슬을 확보해야만 안정적으로 열린다"
	],
	"terrain_summary": [
		"종길: 최종 의식 압박 아래 길게 노출되는 접근선",
		"중앙 성채: 마지막 상승을 둘러싼 다층 방어선",
		"닻 사슬: 최종 진입을 실제로 열 수 있는 마지막 해제 지점"
	],
	"optional_objectives": [
		"모든 아군 이름 부름",
		"아군 사망 없음"
	],
	"primary_threat": "종단과 카르온이 최종 접근로를 길게 묶어 후열까지 압박한다.",
	"formation_hint": "방패 유닛은 중앙 성채 입구에, 이름 부름 담당은 닻 사슬 접근선에 둔다.",
	"first_turn_warning": "첫 턴 종길로 곧장 밀면 사정거리 노출과 망각 압박이 겹친다.",
	"useful_counterplay": "닻 사슬을 먼저 확보하고 이름 부름을 순서대로 쓰면 최종 상승로가 안정된다.",
	"brief_text": "닻 사슬은 마지막 진입의 형태를 결정한다. 이 제어점을 확보해야 종의 압박선을 끊고 최종 상승을 자기 흐름으로 바꿀 수 있다."
}

static func get_briefing(stage_id: StringName) -> Dictionary:
	match stage_id:
		&"CH04_03":
			return CH04_03_BRIEFING.duplicate(true)
		&"CH06_02":
			return CH06_02_BRIEFING.duplicate(true)
		&"CH10_05":
			return CH10_05_BRIEFING.duplicate(true)
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
		&"CH10_05_BOSS":
			return CH10_BRIEFING.duplicate(true)
		_:
			return {}
