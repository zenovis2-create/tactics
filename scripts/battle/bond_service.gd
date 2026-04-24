class_name BondService
extends Node

## SYS Bond: 동료별 Bond 레벨 추적
## - Bond 0-5 per companion
## - Bond 3+: 인접 지원 공격 가능
## - Bond 5: Name Anchor 조건 참여 가능
## - get_squad_trust_average(): ProgressionService.trust 업데이트용

const BondData = preload("res://scripts/data/bond_data.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const SupportConversations = preload("res://data/support_conversations.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")

const MAX_BOND: int = 5
const SUPPORT_ATTACK_MIN_BOND: int = 3
const SUPPORT_ATTACK_RANGE: int = 1  # 인접 타일

const COMPANION_ID_ALIASES := {
    &"ally_karl": &"ally_kyle",
}

## 6인 동료 목록
const COMPANION_IDS: Array[StringName] = [
    &"ally_serin",
    &"ally_bran",
    &"ally_tia",
    &"ally_enoch",
    &"ally_kyle",
    &"ally_noah"
]

## _bonds: companion_id -> bond_level (int)
var _bonds: Dictionary = {}
var support_ranks: Dictionary = {}
var shared_battles: Dictionary = {}
var _event_log: Array[Dictionary] = []

func _ready() -> void:
    _initialize_bonds()
    _initialize_support_tracking()

func _initialize_bonds() -> void:
    for id: StringName in COMPANION_IDS:
        _bonds[id] = 0

func _initialize_support_tracking() -> void:
    support_ranks.clear()
    shared_battles.clear()

func _canonicalize_companion_id(companion_id: StringName) -> StringName:
    return StringName(COMPANION_ID_ALIASES.get(companion_id, companion_id))

## bond 레벨 조회 (없으면 0)
func get_bond(companion_id: StringName) -> int:
    return int(_bonds.get(_canonicalize_companion_id(companion_id), 0))

## bond 변경 (clamp 0-5)
func apply_bond_delta(companion_id: StringName, delta: int, reason: String = "") -> Dictionary:
    var canonical_companion_id: StringName = _canonicalize_companion_id(companion_id)
    var before: int = get_bond(canonical_companion_id)
    var after: int = clampi(before + delta, 0, MAX_BOND)
    _bonds[canonical_companion_id] = after
    var entry: Dictionary = {
        "event": "bond_changed",
        "companion_id": canonical_companion_id,
        "before": before,
        "after": after,
        "delta": after - before,
        "reason": reason
    }
    _event_log.append(entry)
    return entry

func register_shared_battle(unit_a, unit_b) -> void:
    var pair_id := SupportConversations.get_pair_id(String(unit_a), String(unit_b))
    if pair_id.is_empty():
        return
    var next_shared_battles: int = get_shared_battle_count(unit_a, unit_b) + 1
    shared_battles[pair_id] = next_shared_battles
    var current_rank: int = int(support_ranks.get(pair_id, 0))
    if current_rank >= 4:
        return
    var unlocked_rank: int = _resolve_support_rank_for_battles(next_shared_battles)
    if unlocked_rank > current_rank:
        support_ranks[pair_id] = unlocked_rank

func get_support_rank(unit_a, unit_b) -> int:
    var pair_id := SupportConversations.get_pair_id(String(unit_a), String(unit_b))
    if pair_id.is_empty():
        return 0
    return clampi(int(support_ranks.get(pair_id, 0)), 0, 4)

func get_support_talk(unit_a, unit_b) -> String:
    var pair_id := SupportConversations.get_pair_id(String(unit_a), String(unit_b))
    if pair_id.is_empty():
        return ""
    var support_rank: int = get_support_rank(unit_a, unit_b)
    if support_rank < 1 or support_rank > 3:
        return ""
    return SupportConversations.get_conversation(pair_id, support_rank)

func get_shared_battle_count(unit_a, unit_b) -> int:
    var pair_id := SupportConversations.get_pair_id(String(unit_a), String(unit_b))
    if pair_id.is_empty():
        return 0
    return max(0, int(shared_battles.get(pair_id, 0)))

func _resolve_support_rank_for_battles(battle_count: int) -> int:
    if battle_count >= 10:
        return 3
    if battle_count >= 6:
        return 2
    if battle_count >= 3:
        return 1
    return 0

## bond 레벨 기반 지원 사거리 (미래 확장용; 현재는 항상 1)
func get_support_range(_companion_id: StringName) -> int:
    return SUPPORT_ATTACK_RANGE

## 두 유닛이 지원 공격 조건을 만족하는지 확인
## 조건: unit_b가 동료이고 bond 3+, unit_a와 인접
func can_support_attack(attacker: UnitActor, supporter: UnitActor) -> bool:
    if attacker == null or supporter == null:
        return false
    if not is_instance_valid(attacker) or not is_instance_valid(supporter):
        return false
    var supporter_id: StringName = supporter.unit_data.unit_id if supporter.unit_data != null else &""
    if get_bond(supporter_id) < SUPPORT_ATTACK_MIN_BOND:
        return false
    var dist: int = abs(attacker.grid_position.x - supporter.grid_position.x) + abs(attacker.grid_position.y - supporter.grid_position.y)
    return dist <= SUPPORT_ATTACK_RANGE

## 팀 평균 bond — ProgressionService.trust 업데이트용
func get_squad_trust_average() -> float:
    if _bonds.is_empty():
        return 0.0
    var total: float = 0.0
    for id: StringName in COMPANION_IDS:
        total += float(get_bond(id))
    return total / float(COMPANION_IDS.size())

## Name Anchor 조건: bond 5인 동료 목록
func get_name_anchor_eligible() -> Array[StringName]:
    var result: Array[StringName] = []
    for id: StringName in COMPANION_IDS:
        if get_bond(id) >= MAX_BOND:
            result.append(id)
    return result

## 모든 bond 초기화
func reset() -> void:
    _initialize_bonds()
    _initialize_support_tracking()
    _event_log.clear()

func load_from_progression(data: ProgressionData) -> void:
    _initialize_bonds()
    _initialize_support_tracking()
    _event_log.clear()
    if data == null:
        return
    for id: StringName in COMPANION_IDS:
        _bonds[id] = data.get_bond_level(id)
    if data.get_bond_level(&"ally_karl") > 0:
        _bonds[&"ally_kyle"] = max(int(_bonds.get(&"ally_kyle", 0)), data.get_bond_level(&"ally_karl"))
    for pair_id in data.get_support_ranks_snapshot().keys():
        support_ranks[String(pair_id)] = data.get_support_rank(String(pair_id))
    for pair_id in data.get_shared_battles_snapshot().keys():
        shared_battles[String(pair_id)] = data.get_shared_battle_count(String(pair_id))

func export_to_progression(data: ProgressionData) -> void:
    if data == null:
        return
    for id: StringName in COMPANION_IDS:
        data.set_bond_level(id, get_bond(id))
    data.set_bond_level(&"ally_karl", get_bond(&"ally_kyle"))
    for pair_id in support_ranks.keys():
        data.set_support_rank(String(pair_id), int(support_ranks[pair_id]))
    for pair_id in shared_battles.keys():
        data.set_shared_battle_count(String(pair_id), int(shared_battles[pair_id]))

func get_event_log() -> Array[Dictionary]:
    return _event_log.duplicate()

func get_snapshot() -> Dictionary:
    var snap: Dictionary = {}
    for id: StringName in COMPANION_IDS:
        snap[String(id)] = get_bond(id)
    var support_snapshot: Dictionary = {}
    var shared_battle_snapshot: Dictionary = {}
    for pair_id in support_ranks.keys():
        support_snapshot[String(pair_id)] = int(support_ranks[pair_id])
    for pair_id in shared_battles.keys():
        shared_battle_snapshot[String(pair_id)] = int(shared_battles[pair_id])
    return {
        "bonds": snap,
        "support_ranks": support_snapshot,
        "shared_battles": shared_battle_snapshot,
        "squad_trust_average": get_squad_trust_average(),
        "name_anchor_eligible": get_name_anchor_eligible()
    }
