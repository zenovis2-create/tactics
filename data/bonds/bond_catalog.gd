class_name BondCatalog
extends RefCounted

## Bond 카탈로그 — 6인 동료 초기 bond 데이터를 코드 기반으로 빌드

const BondData = preload("res://scripts/data/bond_data.gd")

static func build_serin() -> BondData:
    var d: BondData = BondData.new()
    d.companion_id = &"ally_serin"
    d.bond_level = 0
    d.arc_flags_required = [&"ch01_serin_arc_dawn_oath"]
    return d

static func build_bran() -> BondData:
    var d: BondData = BondData.new()
    d.companion_id = &"ally_bran"
    d.bond_level = 0
    d.arc_flags_required = [&"ch02_bran_arc_fortress_trust"]
    return d

static func build_tia() -> BondData:
    var d: BondData = BondData.new()
    d.companion_id = &"ally_tia"
    d.bond_level = 0
    d.arc_flags_required = [&"ch03_tia_arc_greenwood_truce"]
    return d

static func build_enoch() -> BondData:
    var d: BondData = BondData.new()
    d.companion_id = &"ally_enoch"
    d.bond_level = 0
    d.arc_flags_required = [&"ch05_enoch_arc_archive_recovered"]
    return d

static func build_karl() -> BondData:
    var d: BondData = BondData.new()
    d.companion_id = &"ally_karl"
    d.bond_level = 0
    d.arc_flags_required = [&"ch09a_karl_arc_outer_line_crossed"]
    return d

static func build_noah() -> BondData:
    var d: BondData = BondData.new()
    d.companion_id = &"ally_noah"
    d.bond_level = 0
    d.arc_flags_required = [&"ch09b_noah_arc_record_abyss"]
    return d

static func get_all() -> Array[BondData]:
    return [
        build_serin(),
        build_bran(),
        build_tia(),
        build_enoch(),
        build_karl(),
        build_noah()
    ]

static func get_by_id(companion_id: StringName) -> BondData:
    match companion_id:
        &"ally_serin": return build_serin()
        &"ally_bran": return build_bran()
        &"ally_tia": return build_tia()
        &"ally_enoch": return build_enoch()
        &"ally_karl": return build_karl()
        &"ally_noah": return build_noah()
        _: return null
