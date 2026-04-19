class_name HeirloomData
extends Resource

enum ClanSymbol {
	SWORD,
	SHIELD,
	STAR,
	DRAGON,
	WOLF,
}

@export var playthrough_count: int = 0
@export var clan_name: String = ""
@export var clan_symbol: ClanSymbol = ClanSymbol.SWORD
@export var inherited_skills: Array[Dictionary] = []
@export var curse_units: Array[String] = []
@export var rescued_fragment_holders: Array[String] = []
@export_multiline var chronicle_summary: String = ""
@export var total_battles: int = 0
@export var total_victories: int = 0
@export var total_deaths: int = 0
@export var terrain_damage_map: Dictionary = {}
@export var battle_visit_counts: Dictionary = {}
@export var persistent_markers: Array[Dictionary] = []
@export var battle_last_visit_dates: Dictionary = {}
@export var museum_location: String = ""

func to_summary() -> String:
	var lines: Array[String] = [
		"Farland의 노래",
		"%d번째 계승에서 %s의 문장이 다시 들린다." % [max(playthrough_count, 1), clan_name if not clan_name.is_empty() else "이름 없는 가문"],
		"전투 %d회, 승리 %d회, 잃은 이름 %d개가 기록되었다." % [max(total_battles, 0), max(total_victories, 0), max(total_deaths, 0)]
	]
	if not inherited_skills.is_empty():
		var skill_lines: Array[String] = []
		for entry in inherited_skills:
			var label := String(entry.get("bonus_desc", "")).strip_edges()
			if label.is_empty():
				label = String(entry.get("skill_id", "legacy_skill")).strip_edges()
			if not label.is_empty():
				skill_lines.append(label)
		if not skill_lines.is_empty():
			lines.append("이어받은 기술: %s" % ", ".join(skill_lines))
	if not curse_units.is_empty():
		lines.append("저주의 이름: %s" % ", ".join(curse_units))
	if not rescued_fragment_holders.is_empty():
		lines.append("구해낸 파편의 수호자: %s" % ", ".join(rescued_fragment_holders))
	if not chronicle_summary.is_empty():
		lines.append(chronicle_summary.strip_edges())
	return "\n".join(lines).strip_edges()
