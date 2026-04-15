extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH09B_FINAL_STAGE = preload("res://data/stages/ch09b_05_stage.tres")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)

    await process_frame
    await process_frame

    var campaign = main.campaign_controller
    if campaign == null:
        push_error("Equipment restriction runner could not resolve campaign controller.")
        quit(1)
        return

    campaign.debug_unlock_weapon_ids([
        &"wp_archive_ashblade",
        &"wp_zero_trace_staff",
        &"wp_valtor_command_lance",
        &"wp_saria_mercy_staff",
        &"wp_houndline_bow",
        &"wp_standard_breaker_blade",
        &"wp_keeper_root_staff",
        &"wp_eclipse_resonance_blade"
    ])
    campaign.debug_unlock_armor_ids([
        &"ar_greenwood_cloak",
        &"ar_whiteflow_vestment",
        &"ar_archive_smoke_coat",
        &"ar_elyor_procession_mail",
        &"ar_ruin_tracker_coat",
        &"ar_capital_witness_plate",
        &"ar_revision_guard_cloak",
        &"ar_bellward_plate"
    ])
    campaign.debug_seed_chapter_camp(&"CH09B", 4, CH09B_FINAL_STAGE)
    await process_frame
    await process_frame

    if not await _assert_bran_restrictions(main, campaign):
        return
    if not await _assert_tia_restrictions(main, campaign):
        return
    if not await _assert_noah_restrictions(main, campaign):
        return
    if not await _assert_serin_restrictions(main, campaign):
        return

    print("[PASS] Equipment restriction runner verified unit-specific weapon and armor restrictions.")
    quit(0)

func _assert_bran_restrictions(main, campaign) -> bool:
    var bran_detail := await _cycle_unit(main, campaign, "Bran")
    var weapon_name: String = String(bran_detail.get("weapon_slot", ""))
    var armor_name: String = String(bran_detail.get("armor_slot", ""))
    if weapon_name.contains("Staff") or weapon_name.contains("Bow"):
        push_error("Bran should not equip staff/bow weapons, got %s." % weapon_name)
        quit(1)
        return false
    if armor_name.contains("Vestment") or armor_name.contains("Cloak"):
        push_error("Bran should not equip robe/light armor, got %s." % armor_name)
        quit(1)
        return false
    return true

func _assert_tia_restrictions(main, campaign) -> bool:
    var tia_detail := await _cycle_unit(main, campaign, "Tia")
    var weapon_name: String = String(tia_detail.get("weapon_slot", ""))
    var armor_name: String = String(tia_detail.get("armor_slot", ""))
    if not weapon_name.contains("Bow"):
        push_error("Tia should stay on bow-type weapons, got %s." % weapon_name)
        quit(1)
        return false
    if armor_name.contains("Plate") or armor_name.contains("Mail") or armor_name.contains("Vestment"):
        push_error("Tia should not equip heavy/robe armor, got %s." % armor_name)
        quit(1)
        return false
    return true

func _assert_noah_restrictions(main, campaign) -> bool:
    var noah_detail := await _cycle_unit(main, campaign, "Noah")
    var weapon_name: String = String(noah_detail.get("weapon_slot", ""))
    var armor_name: String = String(noah_detail.get("armor_slot", ""))
    if not weapon_name.contains("Staff"):
        push_error("Noah should stay on staff-type weapons, got %s." % weapon_name)
        quit(1)
        return false
    if not armor_name.contains("Cloak") and not armor_name.contains("Vestment"):
        push_error("Noah should stay on robe-type armor, got %s." % armor_name)
        quit(1)
        return false
    return true

func _assert_serin_restrictions(main, campaign) -> bool:
    var serin_detail := await _cycle_unit(main, campaign, "Serin")
    var weapon_name: String = String(serin_detail.get("weapon_slot", ""))
    var armor_name: String = String(serin_detail.get("armor_slot", ""))
    if not weapon_name.contains("Staff"):
        push_error("Serin should stay on staff-type weapons, got %s." % weapon_name)
        quit(1)
        return false
    if not armor_name.contains("Cloak") and not armor_name.contains("Vestment"):
        push_error("Serin should stay on robe-type armor, got %s." % armor_name)
        quit(1)
        return false
    return true

func _cycle_unit(main, campaign, expected_name: String) -> Dictionary:
    var snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var party_details: Array = snapshot.get("party_details", [])
    var index: int = _find_party_index(party_details, expected_name)
    if index == -1:
        push_error("Equipment restriction runner expected %s in the camp roster." % expected_name)
        quit(1)
        return {}
    main.campaign_panel.select_party_index(index)
    await process_frame
    var unit_id: StringName = StringName(main.campaign_panel.get_snapshot().get("selected_party_unit_id", ""))
    campaign.cycle_weapon_for_unit(unit_id)
    await process_frame
    campaign.cycle_armor_for_unit(unit_id)
    await process_frame
    var updated_snapshot: Dictionary = main.campaign_panel.get_snapshot()
    return _find_party_entry(updated_snapshot.get("party_details", []), expected_name)

func _find_party_index(party_details: Array, expected_name: String) -> int:
    for index in range(party_details.size()):
        var entry = party_details[index]
        if typeof(entry) == TYPE_DICTIONARY and String(entry.get("name", "")) == expected_name:
            return index
    return -1

func _find_party_entry(party_details: Array, expected_name: String) -> Dictionary:
    for entry in party_details:
        if typeof(entry) == TYPE_DICTIONARY and String(entry.get("name", "")) == expected_name:
            return entry
    return {}
