class_name BondService
extends Node

## SYS Bond: 동료별 Bond 레벨 추적
## - Bond 0-5 per companion
## - Bond 3+: 인접 지원 공격 가능
## - Bond 5: Name Anchor 조건 참여 가능
## - get_squad_trust_average(): ProgressionService.trust 업데이트용

const BondData = preload("res://scripts/data/bond_data.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")

const MAX_BOND: int = 5
const SUPPORT_ATTACK_MIN_BOND: int = 3
const SUPPORT_ATTACK_RANGE: int = 1  # 인접 타일

## 6인 동료 목록
const COMPANION_IDS: Array[StringName] = [
    &"ally_serin",
    &"ally_bran",
    &"ally_tia",
    &"ally_enoch",
    &"ally_karl",
    &"ally_noah"
]

## _bonds: companion_id -> bond_level (int)
var _bonds: Dictionary = {}
var _event_log: Array[Dictionary] = []

func _ready() -> void:
    _initialize_bonds()

func _initialize_bonds() -> void:
    for id: StringName in COMPANION_IDS:
        _bonds[id] = 0

## bond 레벨 조회 (없으면 0)
func get_bond(companion_id: StringName) -> int:
    return int(_bonds.get(companion_id, 0))

## bond 변경 (clamp 0-5)
func apply_bond_delta(companion_id: StringName, delta: int, reason: String = "") -> Dictionary:
    var before: int = get_bond(companion_id)
    var after: int = clampi(before + delta, 0, MAX_BOND)
    _bonds[companion_id] = after
    var entry: Dictionary = {
        "event": "bond_changed",
        "companion_id": companion_id,
        "before": before,
        "after": after,
        "delta": after - before,
        "reason": reason
    }
    _event_log.append(entry)
    return entry

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
    _event_log.clear()

func get_event_log() -> Array[Dictionary]:
    return _event_log.duplicate()

func get_snapshot() -> Dictionary:
    var snap: Dictionary = {}
    for id: StringName in COMPANION_IDS:
        snap[String(id)] = get_bond(id)
    return {
        "bonds": snap,
        "squad_trust_average": get_squad_trust_average(),
        "name_anchor_eligible": get_name_anchor_eligible()
    }
