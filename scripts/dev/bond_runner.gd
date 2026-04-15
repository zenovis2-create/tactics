extends SceneTree

## 4-F: Bond 시스템 검증 러너
## - BondData 필드 확인
## - BondCatalog 6인 로드
## - apply_bond_delta() clamp 검증
## - get_squad_trust_average() 계산
## - can_support_attack() bond 3+ 조건
## - get_name_anchor_eligible() bond 5 조건
## - get_snapshot() 키 검증
## - 이벤트 로그 기록

const BondData = preload("res://scripts/data/bond_data.gd")
const BondService = preload("res://scripts/battle/bond_service.gd")
const BondCatalog = preload("res://data/bonds/bond_catalog.gd")

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var svc: BondService = BondService.new()
    root.add_child(svc)
    await process_frame

    if not _assert_bond_data_fields(): return
    if not _assert_catalog_loads(): return
    if not _assert_bond_delta_clamp(svc): return
    if not _assert_trust_average(svc): return
    if not _assert_support_attack_bond_gate(svc): return
    if not _assert_name_anchor_eligible(svc): return
    if not _assert_snapshot_keys(svc): return
    if not _assert_event_log(svc): return

    print("[PASS] bond_runner: all assertions passed.")
    quit(0)

# --- Assertions ---

func _assert_bond_data_fields() -> bool:
    var d: BondData = BondData.new()
    if not d.get("companion_id") is StringName:
        return _fail("BondData.companion_id must be StringName")
    if not d.get("bond_level") is int:
        return _fail("BondData.bond_level must be int")
    if not d.get("arc_flags_required") is Array:
        return _fail("BondData.arc_flags_required must be Array")
    return true

func _assert_catalog_loads() -> bool:
    var all: Array[BondData] = BondCatalog.get_all()
    if all.size() != 6:
        return _fail("BondCatalog.get_all() should return 6 companions, got %d" % all.size())
    for d: BondData in all:
        if not d.is_valid():
            return _fail("BondData companion_id empty for one entry")
    var serin: BondData = BondCatalog.get_by_id(&"ally_serin")
    if serin == null:
        return _fail("ally_serin not found in BondCatalog")
    if serin.companion_id != &"ally_serin":
        return _fail("ally_serin companion_id mismatch")
    return true

func _assert_bond_delta_clamp(svc: BondService) -> bool:
    svc.reset()
    # 초기값 0
    if svc.get_bond(&"ally_serin") != 0:
        return _fail("Initial bond should be 0")
    # +2 → 2
    svc.apply_bond_delta(&"ally_serin", 2, "test")
    if svc.get_bond(&"ally_serin") != 2:
        return _fail("Bond should be 2 after +2")
    # +10 → clamp to 5
    svc.apply_bond_delta(&"ally_serin", 10, "test")
    if svc.get_bond(&"ally_serin") != 5:
        return _fail("Bond should clamp to 5, got %d" % svc.get_bond(&"ally_serin"))
    # -100 → clamp to 0
    svc.apply_bond_delta(&"ally_serin", -100, "test")
    if svc.get_bond(&"ally_serin") != 0:
        return _fail("Bond should clamp to 0")
    return true

func _assert_trust_average(svc: BondService) -> bool:
    svc.reset()
    var avg: float = svc.get_squad_trust_average()
    if avg != 0.0:
        return _fail("Initial average should be 0.0, got %.2f" % avg)
    # 모든 동료 bond 3으로 설정
    for id: StringName in BondService.COMPANION_IDS:
        svc.apply_bond_delta(id, 3, "test")
    avg = svc.get_squad_trust_average()
    if avg != 3.0:
        return _fail("Average should be 3.0 with all bonds at 3, got %.2f" % avg)
    return true

func _assert_support_attack_bond_gate(svc: BondService) -> bool:
    svc.reset()
    # bond < 3: can_support_attack는 null 유닛에 대해 false
    # (실제 UnitActor 없이 bond 조건만 테스트)
    if svc.get_bond(&"ally_serin") >= BondService.SUPPORT_ATTACK_MIN_BOND:
        return _fail("Bond 0 should not meet support attack threshold")
    svc.apply_bond_delta(&"ally_serin", 3, "test")
    if svc.get_bond(&"ally_serin") < BondService.SUPPORT_ATTACK_MIN_BOND:
        return _fail("Bond 3 should meet support attack threshold")
    # can_support_attack(null, null) → false (null guard)
    if svc.can_support_attack(null, null):
        return _fail("can_support_attack(null, null) should be false")
    return true

func _assert_name_anchor_eligible(svc: BondService) -> bool:
    svc.reset()
    var eligible: Array[StringName] = svc.get_name_anchor_eligible()
    if not eligible.is_empty():
        return _fail("No bond-5 companions initially, eligible should be empty")
    # ally_serin bond = 5
    svc.apply_bond_delta(&"ally_serin", 5, "test")
    eligible = svc.get_name_anchor_eligible()
    if not eligible.has(&"ally_serin"):
        return _fail("ally_serin with bond 5 should be Name Anchor eligible")
    if eligible.size() != 1:
        return _fail("Only 1 companion at bond 5, eligible size should be 1")
    return true

func _assert_snapshot_keys(svc: BondService) -> bool:
    var snap: Dictionary = svc.get_snapshot()
    for key: String in ["bonds", "squad_trust_average", "name_anchor_eligible"]:
        if not snap.has(key):
            return _fail("snapshot missing key: %s" % key)
    return true

func _assert_event_log(svc: BondService) -> bool:
    svc.reset()
    svc.apply_bond_delta(&"ally_bran", 1, "test_event")
    var log: Array[Dictionary] = svc.get_event_log()
    var found: bool = false
    for entry: Dictionary in log:
        if entry.get("event") == "bond_changed" and entry.get("companion_id") == &"ally_bran":
            found = true
    if not found:
        return _fail("event log should contain bond_changed for ally_bran")
    return true

func _fail(msg: String) -> bool:
    print("[FAIL] ", msg)
    _failed = true
    quit(1)
    return false
