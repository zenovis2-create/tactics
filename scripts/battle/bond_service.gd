class_name BondService
extends Node

signal s_rank_ally_died(unit_id: StringName, unit_name: String, support_rank: int)
signal support_progress_updated(pair_id: String, new_rank: int)

## SYS Bond: 동료별 Bond 레벨 추적
## - Bond 0-5 per companion
## - Bond 3+: 인접 지원 공격 가능
## - Bond 5: Name Anchor 조건 참여 가능
## - get_squad_trust_average(): ProgressionService.trust 업데이트용

const BondData = preload("res://scripts/data/bond_data.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")

const MAX_BOND: int = 5
const LEGACY_MAX_SUPPORT_RANK: int = 4
const SUPPORT_CONVERSATION_RANK: int = 3
const SUPPORT_B_RANK: int = 4
const SUPPORT_A_RANK: int = 5
const SUPPORT_S_RANK: int = 6
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
var _progression_data: ProgressionData = null
var _support_progress_by_pair: Dictionary = {}

func _ready() -> void:
    _initialize_bonds()

func _initialize_bonds() -> void:
    var starting_bond: int = MAX_BOND if _has_bond_anchor_purchase() else 0
    for id: StringName in COMPANION_IDS:
        _bonds[id] = starting_bond

func setup_progression(data: ProgressionData) -> void:
    _progression_data = data
    _initialize_bonds()
    _load_support_progress_from_progression()

func _has_bond_anchor_purchase() -> bool:
    return _progression_data != null and _progression_data.ng_plus_purchases.has("bond_anchor")

## bond 레벨 조회 (없으면 0)
func get_bond(companion_id: StringName) -> int:
    return int(_bonds.get(companion_id, 0))

func get_support_rank(unit_a: StringName, unit_b: StringName) -> int:
    var normalized_a: StringName = _normalize_support_unit_id(unit_a)
    var normalized_b: StringName = _normalize_support_unit_id(unit_b)
    if normalized_a == &"" or normalized_b == &"" or normalized_a == normalized_b:
        return 0
    var pair_id := _make_support_pair_id(normalized_a, normalized_b)
    if _support_progress_by_pair.has(pair_id):
        return _resolve_progress_rank(_support_progress_by_pair.get(pair_id, {}) as Dictionary)
    if normalized_a == &"ally_rian" and COMPANION_IDS.has(normalized_b):
        return clampi(get_bond(normalized_b) - 1, 0, LEGACY_MAX_SUPPORT_RANK)
    if normalized_b == &"ally_rian" and COMPANION_IDS.has(normalized_a):
        return clampi(get_bond(normalized_a) - 1, 0, LEGACY_MAX_SUPPORT_RANK)
    return 0

func get_battles_together(unit_a: StringName, unit_b: StringName) -> int:
    var pair_id := _make_support_pair_id(_normalize_support_unit_id(unit_a), _normalize_support_unit_id(unit_b))
    if pair_id.is_empty() or not _support_progress_by_pair.has(pair_id):
        return 0
    return int((_support_progress_by_pair.get(pair_id, {}) as Dictionary).get("battles_together", 0))

func register_support_progress(unit_a: StringName, unit_b: StringName, chapter_id: StringName = StringName(), stage_id: StringName = StringName()) -> Dictionary:
    var normalized_a: StringName = _normalize_support_unit_id(unit_a)
    var normalized_b: StringName = _normalize_support_unit_id(unit_b)
    var pair_id := _make_support_pair_id(normalized_a, normalized_b)
    if pair_id.is_empty() or not _is_rian_support_pair(normalized_a, normalized_b):
        return {}

    var progress: Dictionary = (_support_progress_by_pair.get(pair_id, {}) as Dictionary).duplicate(true)
    var previous_rank: int = _resolve_progress_rank(progress)
    var previous_milestone_rank: int = _resolve_milestone_rank(progress)
    var rank_bonus: int = _resolve_rank_bonus(progress)
    var battles_together: int = int(progress.get("battles_together", 0)) + 1
    var new_rank: int = _calculate_support_rank_from_battles(battles_together)
    progress["pair"] = pair_id
    progress["battles_together"] = battles_together
    progress["milestone_rank"] = max(previous_milestone_rank, new_rank)
    progress["rank_bonus"] = rank_bonus
    progress["rank"] = clampi(int(progress.get("milestone_rank", 0)) + rank_bonus, 0, SUPPORT_S_RANK)
    progress["chapter"] = String(chapter_id)
    progress["stage_id"] = String(stage_id)
    _support_progress_by_pair[pair_id] = progress
    _sync_support_progress_to_progression()

    var entry := {
        "event": "support_progress_registered",
        "pair": pair_id,
        "battles_together": battles_together,
        "rank_before": previous_rank,
        "rank_after": int(progress.get("rank", 0)),
        "milestone_rank_before": previous_milestone_rank,
        "milestone_rank_after": int(progress.get("milestone_rank", 0)),
        "chapter": String(chapter_id),
        "stage_id": String(stage_id)
    }
    _event_log.append(entry)

    if int(progress.get("milestone_rank", 0)) > previous_milestone_rank:
        support_progress_updated.emit(pair_id, int(progress.get("milestone_rank", 0)))
    return entry

func promote_name_call_support(unit_a: StringName, unit_b: StringName) -> int:
    var normalized_a: StringName = _normalize_support_unit_id(unit_a)
    var normalized_b: StringName = _normalize_support_unit_id(unit_b)
    var pair_id := _make_support_pair_id(normalized_a, normalized_b)
    if pair_id.is_empty() or not _is_rian_support_pair(normalized_a, normalized_b):
        return 0

    var progress: Dictionary = (_support_progress_by_pair.get(pair_id, {}) as Dictionary).duplicate(true)
    var previous_rank: int = _resolve_progress_rank(progress)
    var previous_milestone_rank: int = _resolve_milestone_rank(progress)
    var rank_bonus: int = _resolve_rank_bonus(progress)
    if previous_milestone_rank < SUPPORT_A_RANK:
        return previous_rank

    progress["pair"] = pair_id
    progress["battles_together"] = int(progress.get("battles_together", 0))
    progress["milestone_rank"] = SUPPORT_S_RANK
    progress["rank_bonus"] = rank_bonus
    progress["rank"] = clampi(SUPPORT_S_RANK + rank_bonus, 0, SUPPORT_S_RANK)
    _support_progress_by_pair[pair_id] = progress
    _sync_support_progress_to_progression()
    _event_log.append({
        "event": "support_name_call_promoted",
        "pair": pair_id,
        "rank_before": previous_rank,
        "rank_after": int(progress.get("rank", 0)),
        "milestone_rank_before": previous_milestone_rank,
        "milestone_rank_after": SUPPORT_S_RANK
    })
    if previous_milestone_rank < SUPPORT_S_RANK:
        support_progress_updated.emit(pair_id, SUPPORT_S_RANK)
    return int(progress.get("rank", 0))

func modify_support_rank(pair_id: String, delta: int) -> int:
    var normalized_pair := _normalize_support_pair_id(pair_id)
    if normalized_pair.is_empty():
        return 0
    var progress: Dictionary = (_support_progress_by_pair.get(normalized_pair, {}) as Dictionary).duplicate(true)
    var previous_rank: int = _resolve_progress_rank(progress)
    var milestone_rank: int = _resolve_milestone_rank(progress)
    var rank_bonus: int = _resolve_rank_bonus(progress) + delta
    progress["pair"] = normalized_pair
    progress["battles_together"] = int(progress.get("battles_together", 0))
    progress["milestone_rank"] = milestone_rank
    progress["rank_bonus"] = rank_bonus
    progress["rank"] = clampi(milestone_rank + rank_bonus, 0, SUPPORT_S_RANK)
    _support_progress_by_pair[normalized_pair] = progress
    _sync_support_progress_to_progression()
    _event_log.append({
        "event": "support_rank_modified",
        "pair": normalized_pair,
        "rank_before": previous_rank,
        "rank_after": int(progress.get("rank", 0)),
        "delta": int(progress.get("rank", 0)) - previous_rank
    })
    return int(progress.get("rank", 0))

func queue_next_support_bonus(pair_id: String, bonus: int) -> int:
    var normalized_pair := _normalize_support_pair_id(pair_id)
    if normalized_pair.is_empty() or bonus == 0:
        return get_pending_support_bonus(normalized_pair)
    var progress: Dictionary = (_support_progress_by_pair.get(normalized_pair, {}) as Dictionary).duplicate(true)
    var milestone_rank: int = _resolve_milestone_rank(progress)
    var rank_bonus: int = _resolve_rank_bonus(progress)
    progress["pair"] = normalized_pair
    progress["battles_together"] = int(progress.get("battles_together", 0))
    progress["milestone_rank"] = milestone_rank
    progress["rank_bonus"] = rank_bonus
    progress["rank"] = clampi(milestone_rank + rank_bonus, 0, SUPPORT_S_RANK)
    progress["pending_support_bonus"] = int(progress.get("pending_support_bonus", 0)) + bonus
    _support_progress_by_pair[normalized_pair] = progress
    _sync_support_progress_to_progression()
    _event_log.append({
        "event": "support_bonus_queued",
        "pair": normalized_pair,
        "pending_support_bonus": int(progress.get("pending_support_bonus", 0))
    })
    return int(progress.get("pending_support_bonus", 0))

func get_pending_support_bonus(pair_id: String) -> int:
    var normalized_pair := _normalize_support_pair_id(pair_id)
    if normalized_pair.is_empty():
        return 0
    return int((_support_progress_by_pair.get(normalized_pair, {}) as Dictionary).get("pending_support_bonus", 0))

func consume_pending_support_bonus(pair_id: String) -> int:
    var normalized_pair := _normalize_support_pair_id(pair_id)
    if normalized_pair.is_empty() or not _support_progress_by_pair.has(normalized_pair):
        return 0
    var progress: Dictionary = (_support_progress_by_pair.get(normalized_pair, {}) as Dictionary).duplicate(true)
    var pending_bonus: int = int(progress.get("pending_support_bonus", 0))
    if pending_bonus == 0:
        return 0
    progress["milestone_rank"] = _resolve_milestone_rank(progress)
    progress["rank_bonus"] = _resolve_rank_bonus(progress)
    progress["rank"] = clampi(int(progress.get("milestone_rank", 0)) + int(progress.get("rank_bonus", 0)), 0, SUPPORT_S_RANK)
    progress["pending_support_bonus"] = 0
    _support_progress_by_pair[normalized_pair] = progress
    _sync_support_progress_to_progression()
    _event_log.append({
        "event": "support_bonus_consumed",
        "pair": normalized_pair,
        "consumed_bonus": pending_bonus
    })
    return pending_bonus

func _normalize_support_unit_id(unit_id: StringName) -> StringName:
    match unit_id:
        &"rian", &"ally_rian":
            return &"ally_rian"
        &"serin", &"ally_serin":
            return &"ally_serin"
        &"bran", &"ally_bran":
            return &"ally_bran"
        &"tia", &"ally_tia":
            return &"ally_tia"
        &"enoch", &"ally_enoch":
            return &"ally_enoch"
        &"karl", &"ally_karl":
            return &"ally_karl"
        &"noah", &"ally_noah":
            return &"ally_noah"
        _:
            return unit_id if COMPANION_IDS.has(unit_id) or unit_id == &"ally_rian" else &""

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
    _support_progress_by_pair.clear()
    _sync_support_progress_to_progression()

func get_event_log() -> Array[Dictionary]:
    return _event_log.duplicate()

func get_snapshot() -> Dictionary:
    var snap: Dictionary = {}
    for id: StringName in COMPANION_IDS:
        snap[String(id)] = get_bond(id)
    return {
        "bonds": snap,
        "support_progress_by_pair": _support_progress_by_pair.duplicate(true),
        "squad_trust_average": get_squad_trust_average(),
        "name_anchor_eligible": get_name_anchor_eligible()
    }

func notify_unit_died(unit_id: StringName, unit_name: String = "") -> void:
    var normalized_unit_id: StringName = _normalize_support_unit_id(unit_id)
    if normalized_unit_id == &"" or normalized_unit_id == &"ally_rian":
        return

    var support_rank: int = get_support_rank(&"ally_rian", normalized_unit_id)
    if not _qualifies_as_s_rank_pair(&"ally_rian", normalized_unit_id, support_rank):
        return

    var resolved_name := unit_name.strip_edges()
    if resolved_name.is_empty():
        resolved_name = String(normalized_unit_id).trim_prefix("ally_").capitalize()

    _event_log.append({
        "event": "s_rank_ally_died",
        "unit_id": String(normalized_unit_id),
        "unit_name": resolved_name,
        "support_rank": support_rank
    })
    s_rank_ally_died.emit(normalized_unit_id, resolved_name, support_rank)

func resolve_damage_share(target: UnitActor, total_damage: int, allies: Array) -> Dictionary:
    var target_id: StringName = target.unit_data.unit_id if target != null and target.unit_data != null else &""
    if target == null or not is_instance_valid(target):
        return {"original_damage": total_damage, "shared_amounts": [], "target_takes_all": true}
    if get_bond(target_id) < MAX_BOND:
        return {"original_damage": total_damage, "shared_amounts": [], "target_takes_all": true}

    var sharers: Array = []
    for ally in allies:
        if not is_instance_valid(ally) or ally == target or ally.is_defeated():
            continue
        var ally_id: StringName = ally.unit_data.unit_id if ally.unit_data != null else &""
        if get_bond(ally_id) < MAX_BOND:
            continue
        var dist: int = abs(target.grid_position.x - ally.grid_position.x) + abs(target.grid_position.y - ally.grid_position.y)
        if dist <= SUPPORT_ATTACK_RANGE:
            sharers.append(ally)

    if sharers.is_empty():
        return {"original_damage": total_damage, "shared_amounts": [], "target_takes_all": true}

    var share_count: int = sharers.size() + 1
    var share_amount: int = max(1, total_damage / share_count)
    var target_damage: int = total_damage - (share_amount * sharers.size())
    var shared_amounts: Array = []
    for ally in sharers:
        var ally_id: StringName = ally.unit_data.unit_id if ally.unit_data != null else &""
        shared_amounts.append({
            "unit_id": String(ally_id),
            "unit": ally,
            "shared_damage": share_amount
        })

    _event_log.append({
        "event": "damage_shared",
        "target_id": target_id,
        "original_damage": total_damage,
        "target_takes": target_damage,
        "shared_amounts": shared_amounts.size(),
        "share_per_ally": share_amount
    })

    return {
        "original_damage": total_damage,
        "shared_amounts": shared_amounts,
        "target_takes_all": false,
        "target_damage": target_damage,
        "share_per_ally": share_amount
    }

func _make_support_pair_id(unit_a: StringName, unit_b: StringName) -> String:
    if unit_a == &"" or unit_b == &"" or unit_a == unit_b:
        return ""
    var parts: Array[String] = [String(unit_a), String(unit_b)]
    parts.sort()
    return "%s:%s" % [parts[0], parts[1]]

func _normalize_support_pair_id(pair_id: String) -> String:
    var normalized := pair_id.strip_edges()
    if normalized.is_empty():
        return ""
    var parts := normalized.split(":", false)
    if parts.size() != 2:
        return ""
    parts.sort()
    return "%s:%s" % [parts[0], parts[1]]

func _is_rian_support_pair(unit_a: StringName, unit_b: StringName) -> bool:
    return (unit_a == &"ally_rian" and COMPANION_IDS.has(unit_b)) or (unit_b == &"ally_rian" and COMPANION_IDS.has(unit_a))

func _calculate_support_rank_from_battles(battles_together: int) -> int:
    if battles_together >= 10:
        return SUPPORT_A_RANK
    if battles_together >= 6:
        return SUPPORT_B_RANK
    if battles_together >= 3:
        return SUPPORT_CONVERSATION_RANK
    return 0

func _qualifies_as_s_rank_pair(unit_a: StringName, unit_b: StringName, support_rank: int = -1) -> bool:
    var pair_id := _make_support_pair_id(unit_a, unit_b)
    var resolved_rank := support_rank if support_rank >= 0 else get_support_rank(unit_a, unit_b)
    if _support_progress_by_pair.has(pair_id):
        return _resolve_milestone_rank(_support_progress_by_pair.get(pair_id, {}) as Dictionary) >= SUPPORT_S_RANK
    return resolved_rank >= LEGACY_MAX_SUPPORT_RANK

func _resolve_progress_rank(progress: Dictionary) -> int:
    if progress.is_empty():
        return 0
    var milestone_rank: int = _resolve_milestone_rank(progress)
    var rank_bonus: int = _resolve_rank_bonus(progress)
    return clampi(int(progress.get("rank", milestone_rank + rank_bonus)), 0, SUPPORT_S_RANK)

func _resolve_milestone_rank(progress: Dictionary) -> int:
    if progress.is_empty():
        return 0
    if progress.has("milestone_rank"):
        return int(progress.get("milestone_rank", 0))
    return int(progress.get("rank", 0))

func _resolve_rank_bonus(progress: Dictionary) -> int:
    if progress.is_empty():
        return 0
    if progress.has("rank_bonus"):
        return int(progress.get("rank_bonus", 0))
    return 0

func _load_support_progress_from_progression() -> void:
    _support_progress_by_pair.clear()
    if _progression_data == null:
        return
    for pair_key in _progression_data.support_progress_by_pair.keys():
        var normalized_pair := _normalize_support_pair_id(String(pair_key))
        if normalized_pair.is_empty():
            continue
        var progress := (_progression_data.support_progress_by_pair.get(pair_key, {}) as Dictionary).duplicate(true)
        var milestone_rank: int = _resolve_milestone_rank(progress)
        var rank_bonus: int = _resolve_rank_bonus(progress)
        progress["pair"] = normalized_pair
        progress["battles_together"] = int(progress.get("battles_together", 0))
        progress["milestone_rank"] = milestone_rank
        progress["rank_bonus"] = rank_bonus
        progress["rank"] = clampi(milestone_rank + rank_bonus, 0, SUPPORT_S_RANK)
        progress["pending_support_bonus"] = int(progress.get("pending_support_bonus", 0))
        _support_progress_by_pair[normalized_pair] = progress

func _sync_support_progress_to_progression() -> void:
    if _progression_data == null:
        return
    _progression_data.support_progress_by_pair = _support_progress_by_pair.duplicate(true)
