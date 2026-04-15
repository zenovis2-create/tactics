class_name CampaignCatalog
extends RefCounted

const UnitData = preload("res://scripts/data/unit_data.gd")
const AccessoryData = preload("res://scripts/data/accessory_data.gd")
const WeaponData = preload("res://scripts/data/weapon_data.gd")
const ArmorData = preload("res://scripts/data/armor_data.gd")

const WEAPON_FALLBACK_PREVIEW := "res://artifacts/ash36/ash36_weapon_sword_cutout_v1.png"
const ARMOR_FALLBACK_PREVIEW := "res://artifacts/ash36/ash36_armor_heavy_cutout_v1.png"
const ACCESSORY_FALLBACK_PREVIEW := "res://artifacts/ash37/ash37_accessory_memory_seal_variants_v1.png"

const PARTY_ROSTER_ORDER: Array[StringName] = [
    &"ally_rian",
    &"ally_serin",
    &"ally_bran",
    &"ally_tia",
    &"ally_enoch",
    &"ally_karl",
    &"ally_noah"
]

const UNIT_BY_ID := {
    &"ally_rian": preload("res://data/units/ally_rian.tres"),
    &"ally_serin": preload("res://data/units/ally_serin.tres"),
    &"ally_bran": preload("res://data/units/ally_bran.tres"),
    &"ally_tia": preload("res://data/units/ally_tia.tres"),
    &"ally_enoch": preload("res://data/units/ally_enoch.tres"),
    &"ally_karl": preload("res://data/units/ally_karl.tres"),
    &"ally_noah": preload("res://data/units/ally_noah.tres")
}

const ACCESSORY_BY_ID := {
    &"acc_militia_emblem": preload("res://data/accessories/acc_militia_emblem.tres"),
    &"acc_broken_captain_seal": preload("res://data/accessories/acc_broken_captain_seal.tres"),
    &"acc_gatekeeper_ring": preload("res://data/accessories/acc_gatekeeper_ring.tres"),
    &"acc_hardren_iron_crest": preload("res://data/accessories/acc_hardren_iron_crest.tres"),
    &"acc_verdant_plume": preload("res://data/accessories/acc_verdant_plume.tres"),
    &"acc_trap_hunter_needle": preload("res://data/accessories/acc_trap_hunter_needle.tres"),
    &"acc_sap_charm": preload("res://data/accessories/acc_sap_charm.tres"),
    &"acc_watergate_boots": preload("res://data/accessories/acc_watergate_boots.tres"),
    &"acc_locked_bell_shard": preload("res://data/accessories/acc_locked_bell_shard.tres"),
    &"acc_sanctified_pendant": preload("res://data/accessories/acc_sanctified_pendant.tres"),
    &"acc_whiteflow_token": preload("res://data/accessories/acc_whiteflow_token.tres"),
    &"acc_gray_bookmark": preload("res://data/accessories/acc_gray_bookmark.tres"),
    &"acc_heatproof_archivist_coat": preload("res://data/accessories/acc_heatproof_archivist_coat.tres"),
    &"acc_zero_trace_codex": preload("res://data/accessories/acc_zero_trace_codex.tres"),
    &"acc_artillery_sight": preload("res://data/accessories/acc_artillery_sight.tres"),
    &"acc_valtor_command_cuirass": preload("res://data/accessories/acc_valtor_command_cuirass.tres"),
    &"acc_oath_ring": preload("res://data/accessories/acc_oath_ring.tres"),
    &"acc_memory_bell": preload("res://data/accessories/acc_memory_bell.tres"),
    &"acc_knot_talisman": preload("res://data/accessories/acc_knot_talisman.tres"),
    &"acc_namebound_thread": preload("res://data/accessories/acc_namebound_thread.tres"),
    &"acc_moonlit_pursuit_sigil": preload("res://data/accessories/acc_moonlit_pursuit_sigil.tres"),
    &"acc_houndfang_mark": preload("res://data/accessories/acc_houndfang_mark.tres"),
    &"acc_ruin_holdfast_charm": preload("res://data/accessories/acc_ruin_holdfast_charm.tres"),
    &"acc_bannerline_clasp": preload("res://data/accessories/acc_bannerline_clasp.tres"),
    &"acc_nameless_watch_badge": preload("res://data/accessories/acc_nameless_watch_badge.tres"),
    &"acc_officer_rescue_cipher": preload("res://data/accessories/acc_officer_rescue_cipher.tres"),
    &"acc_revision_ward_pin": preload("res://data/accessories/acc_revision_ward_pin.tres"),
    &"acc_keeper_thread_seal": preload("res://data/accessories/acc_keeper_thread_seal.tres"),
    &"acc_archive_proof_relay": preload("res://data/accessories/acc_archive_proof_relay.tres"),
    &"acc_resonance_knot": preload("res://data/accessories/acc_resonance_knot.tres"),
    &"acc_tower_ward_signet": preload("res://data/accessories/acc_tower_ward_signet.tres"),
    &"acc_bell_oath_relic": preload("res://data/accessories/acc_bell_oath_relic.tres")
}

const WEAPON_BY_ID := {
    &"wp_archive_ashblade": preload("res://data/weapons/wp_archive_ashblade.tres"),
    &"wp_zero_trace_staff": preload("res://data/weapons/wp_zero_trace_staff.tres"),
    &"wp_valtor_command_lance": preload("res://data/weapons/wp_valtor_command_lance.tres"),
    &"wp_saria_mercy_staff": preload("res://data/weapons/wp_saria_mercy_staff.tres"),
    &"wp_houndline_bow": preload("res://data/weapons/wp_houndline_bow.tres"),
    &"wp_standard_breaker_blade": preload("res://data/weapons/wp_standard_breaker_blade.tres"),
    &"wp_keeper_root_staff": preload("res://data/weapons/wp_keeper_root_staff.tres"),
    &"wp_eclipse_resonance_blade": preload("res://data/weapons/wp_eclipse_resonance_blade.tres")
}

const ARMOR_BY_ID := {
    &"ar_greenwood_cloak": preload("res://data/armors/ar_greenwood_cloak.tres"),
    &"ar_whiteflow_vestment": preload("res://data/armors/ar_whiteflow_vestment.tres"),
    &"ar_archive_smoke_coat": preload("res://data/armors/ar_archive_smoke_coat.tres"),
    &"ar_elyor_procession_mail": preload("res://data/armors/ar_elyor_procession_mail.tres"),
    &"ar_ruin_tracker_coat": preload("res://data/armors/ar_ruin_tracker_coat.tres"),
    &"ar_capital_witness_plate": preload("res://data/armors/ar_capital_witness_plate.tres"),
    &"ar_revision_guard_cloak": preload("res://data/armors/ar_revision_guard_cloak.tres"),
    &"ar_bellward_plate": preload("res://data/armors/ar_bellward_plate.tres")
}

const WEAPON_PREVIEW_BY_ID := {
    &"wp_archive_ashblade": "res://artifacts/ash36/ash36_weapon_sword_cutout_v1.png",
    &"wp_zero_trace_staff": "res://artifacts/ash36/ash36_weapon_staff_cutout_v1.png",
    &"wp_valtor_command_lance": "res://artifacts/ash36/ash36_weapon_lance_cutout_v1.png",
    &"wp_saria_mercy_staff": "res://artifacts/ash36/ash36_weapon_staff_cutout_v1.png",
    &"wp_houndline_bow": "res://artifacts/ash36/ash36_weapon_bow_cutout_v1.png",
    &"wp_standard_breaker_blade": "res://artifacts/ash36/ash36_weapon_sword_cutout_v1.png",
    &"wp_keeper_root_staff": "res://artifacts/ash36/ash36_weapon_staff_cutout_v1.png",
    &"wp_eclipse_resonance_blade": "res://artifacts/ash36/ash36_weapon_sword_cutout_v1.png"
}

const ARMOR_PREVIEW_BY_ID := {
    &"ar_greenwood_cloak": "res://artifacts/ash36/ash36_armor_light_cutout_v1.png",
    &"ar_whiteflow_vestment": "res://artifacts/ash36/ash36_armor_robe_cutout_v1.png",
    &"ar_archive_smoke_coat": "res://artifacts/ash36/ash36_armor_robe_cutout_v1.png",
    &"ar_elyor_procession_mail": "res://artifacts/ash36/ash36_armor_heavy_cutout_v1.png",
    &"ar_ruin_tracker_coat": "res://artifacts/ash36/ash36_armor_light_cutout_v1.png",
    &"ar_capital_witness_plate": "res://artifacts/ash36/ash36_armor_heavy_cutout_v1.png",
    &"ar_revision_guard_cloak": "res://artifacts/ash36/ash36_armor_light_cutout_v1.png",
    &"ar_bellward_plate": "res://artifacts/ash36/ash36_armor_heavy_cutout_v1.png"
}

static func get_party_roster_order() -> Array[StringName]:
    return PARTY_ROSTER_ORDER.duplicate()

static func get_unit_data(unit_id: StringName) -> UnitData:
    return UNIT_BY_ID.get(unit_id, null) as UnitData

static func get_accessory_data(accessory_id: StringName) -> AccessoryData:
    return ACCESSORY_BY_ID.get(accessory_id, null) as AccessoryData

static func get_weapon_data(weapon_id: StringName) -> WeaponData:
    return WEAPON_BY_ID.get(weapon_id, null) as WeaponData

static func get_armor_data(armor_id: StringName) -> ArmorData:
    return ARMOR_BY_ID.get(armor_id, null) as ArmorData

static func get_weapon_preview_path(weapon_id: StringName) -> String:
    if WEAPON_PREVIEW_BY_ID.has(weapon_id):
        return String(WEAPON_PREVIEW_BY_ID[weapon_id])
    return WEAPON_FALLBACK_PREVIEW

static func get_armor_preview_path(armor_id: StringName) -> String:
    if ARMOR_PREVIEW_BY_ID.has(armor_id):
        return String(ARMOR_PREVIEW_BY_ID[armor_id])
    return ARMOR_FALLBACK_PREVIEW

static func get_accessory_preview_path(_accessory_id: StringName) -> String:
    return ACCESSORY_FALLBACK_PREVIEW
