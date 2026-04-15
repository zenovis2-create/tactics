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
        push_error("Final chapter accessory runner could not resolve campaign controller.")
        quit(1)
        return

    campaign.debug_unlock_accessory_ids([
        &"acc_moonlit_pursuit_sigil",
        &"acc_houndfang_mark",
        &"acc_ruin_holdfast_charm",
        &"acc_bannerline_clasp",
        &"acc_nameless_watch_badge",
        &"acc_officer_rescue_cipher",
        &"acc_revision_ward_pin",
        &"acc_keeper_thread_seal",
        &"acc_archive_proof_relay",
        &"acc_resonance_knot",
        &"acc_tower_ward_signet",
        &"acc_bell_oath_relic"
    ])
    campaign.debug_seed_chapter_camp(&"CH09B", 4, CH09B_FINAL_STAGE)
    await process_frame
    await process_frame

    var snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var inventory_entries: Array = snapshot.get("inventory_entries", [])
    if inventory_entries.is_empty():
        push_error("Final chapter accessory runner expected CH08~CH10 accessories in inventory.")
        quit(1)
        return

    if not _contains_inventory_entry(inventory_entries, "Bell Oath Relic"):
        push_error("Final chapter accessory runner expected Bell Oath Relic to appear in camp inventory.")
        quit(1)
        return

    var noah_index: int = _find_party_index(snapshot.get("party_details", []), "Noah")
    if noah_index == -1:
        push_error("Final chapter accessory runner expected Noah in the CH09B camp roster.")
        quit(1)
        return

    main.campaign_panel.select_party_index(noah_index)
    await process_frame
    campaign.assign_unit_to_sortie(&"ally_noah")
    await process_frame
    campaign.cycle_accessory_for_unit(&"ally_noah")
    await process_frame

    var updated_snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var noah_detail: Dictionary = _find_party_entry(updated_snapshot.get("party_details", []), "Noah")
    if String(noah_detail.get("accessory_slot", "")) == "None":
        push_error("Final chapter accessory runner expected Noah to equip a final-chapter accessory.")
        quit(1)
        return

    main.advance_campaign_step()
    await process_frame
    await process_frame
    main.advance_campaign_step()
    await process_frame
    await process_frame

    var battle = main.battle_controller
    if battle == null:
        push_error("Final chapter accessory runner could not resolve battle controller.")
        quit(1)
        return

    var noah_unit = _find_battle_unit(battle.ally_units, "Noah")
    if noah_unit == null:
        push_error("Final chapter accessory runner expected Noah in the deployed battle party.")
        quit(1)
        return

    if noah_unit.get_attack() <= noah_unit.unit_data.attack and noah_unit.get_movement() <= noah_unit.unit_data.movement and noah_unit.get_defense() <= noah_unit.unit_data.defense:
        push_error("Final chapter accessory runner expected Noah's equipped accessory to affect battle stats.")
        quit(1)
        return

    print("[PASS] Final chapter accessory runner unlocked CH08~CH10 accessories, equipped Noah, and carried the bonus into battle.")
    quit(0)

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

func _contains_inventory_entry(inventory_entries: Array, expected_text: String) -> bool:
    for entry in inventory_entries:
        if String(entry).contains(expected_text):
            return true
    return false

func _find_battle_unit(units: Array, expected_name: String):
    for unit in units:
        if unit == null or not is_instance_valid(unit) or unit.unit_data == null:
            continue
        if unit.unit_data.display_name == expected_name:
            return unit
    return null
