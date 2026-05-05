extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH07_FINAL_STAGE = preload("res://data/stages/ch07_05_stage.tres")
const ACCESSORY_DIR := "data/accessories"
const RES_PREFIX := "res:/"

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)

    await process_frame
    await process_frame

    var campaign = main.campaign_controller
    if campaign == null:
        push_error("Lategame accessory runner could not resolve campaign controller.")
        quit(1)
        return

    campaign.debug_unlock_accessory_ids([
        &"acc_gray_bookmark",
        &"acc_heatproof_archivist_coat",
        &"acc_zero_trace_codex",
        &"acc_artillery_sight",
        &"acc_valtor_command_cuirass",
        &"acc_oath_ring",
        &"acc_memory_bell",
        &"acc_knot_talisman",
        &"acc_namebound_thread"
    ])
    campaign.debug_seed_chapter_camp(&"CH07", 4, CH07_FINAL_STAGE)
    await process_frame
    await process_frame

    var snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var inventory_entries: Array = snapshot.get("inventory_entries", [])
    if inventory_entries.is_empty():
        push_error("Lategame accessory runner expected CH05~CH07 accessories in inventory.")
        quit(1)
        return

    if not _assert_full_accessory_catalog_flavor():
        quit(1)
        return

    if not _contains_inventory_entry(inventory_entries, "Namebound Thread"):
        push_error("Lategame accessory runner expected Namebound Thread to appear in camp inventory.")
        quit(1)
        return

    var enoch_index: int = _find_party_index(snapshot.get("party_details", []), "Enoch")
    if enoch_index == -1:
        push_error("Lategame accessory runner expected Enoch in the CH07 camp roster.")
        quit(1)
        return

    main.campaign_panel.select_party_index(enoch_index)
    await process_frame
    campaign.assign_unit_to_sortie(&"ally_enoch")
    await process_frame
    campaign.cycle_accessory_for_unit(&"ally_enoch")
    await process_frame

    var updated_snapshot: Dictionary = main.campaign_panel.get_snapshot()
    var enoch_detail: Dictionary = _find_party_entry(updated_snapshot.get("party_details", []), "Enoch")
    if String(enoch_detail.get("accessory_slot", "")) == "None":
        push_error("Lategame accessory runner expected Enoch to equip a late-game accessory.")
        quit(1)
        return
    if String(enoch_detail.get("accessory_summary", "")).is_empty():
        push_error("Lategame accessory runner expected equipped accessory flavor summary in party details.")
        quit(1)
        return
    if String(enoch_detail.get("accessory_flavor_text", "")).is_empty():
        push_error("Lategame accessory runner expected equipped accessory flavor text in party details.")
        quit(1)
        return
    if String(enoch_detail.get("accessory_flavor_text", "")) == String(enoch_detail.get("accessory_summary", "")):
        push_error("Lategame accessory runner expected accessory flavor text to be distinct from the summary surface.")
        quit(1)
        return

    var accessory_hint = main.campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/AccessoryCard/Margin/Stack/HintLabel")
    if accessory_hint == null:
        push_error("Lategame accessory runner could not resolve accessory hint label.")
        quit(1)
        return
    if String(accessory_hint.text).find("Eligible:") == -1 or String(accessory_hint.text).find(String(enoch_detail.get("accessory_summary", ""))) == -1 or String(accessory_hint.text).find(String(enoch_detail.get("accessory_flavor_text", ""))) == -1:
        push_error("Lategame accessory runner expected accessory hint label to show summary, flavor text, and eligibility.")
        quit(1)
        return

    var equipped_accessory_entry: String = _find_inventory_entry(updated_snapshot.get("inventory_entries", []), String(enoch_detail.get("accessory_slot", "")))
    if equipped_accessory_entry.is_empty() or equipped_accessory_entry.find(String(enoch_detail.get("accessory_flavor_text", ""))) == -1:
        push_error("Lategame accessory runner expected accessory inventory entries to surface flavor text.")
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
        push_error("Lategame accessory runner could not resolve battle controller.")
        quit(1)
        return

    var enoch_unit = _find_battle_unit(battle.ally_units, "Enoch")
    if enoch_unit == null:
        push_error("Lategame accessory runner expected Enoch in the deployed battle party.")
        quit(1)
        return

    if enoch_unit.get_attack() <= enoch_unit.unit_data.attack and enoch_unit.get_movement() <= enoch_unit.unit_data.movement and enoch_unit.get_defense() <= enoch_unit.unit_data.defense:
        push_error("Lategame accessory runner expected Enoch's equipped accessory to affect battle stats.")
        quit(1)
        return

    print("[PASS] Lategame accessory runner unlocked CH05~CH07 accessories, equipped Enoch, and carried the bonus into battle.")
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

func _find_inventory_entry(inventory_entries: Array, expected_text: String) -> String:
    for entry in inventory_entries:
        var text := String(entry)
        if text.contains(expected_text):
            return text
    return ""

func _find_battle_unit(units: Array, expected_name: String):
    for unit in units:
        if unit == null or not is_instance_valid(unit) or unit.unit_data == null:
            continue
        if unit.unit_data.display_name == expected_name:
            return unit
    return null

func _assert_full_accessory_catalog_flavor() -> bool:
    var dir := DirAccess.open(RES_PREFIX + "/" + ACCESSORY_DIR)
    if dir == null:
        push_error("Lategame accessory runner could not open accessory catalog.")
        return false
    var files := dir.get_files()
    files.sort()
    for file_name in files:
        if not String(file_name).ends_with(".tres"):
            continue
        var path := RES_PREFIX + "/" + ACCESSORY_DIR + "/" + file_name
        var accessory = load(path)
        if accessory == null:
            push_error("Accessory catalog entry failed to load: %s" % path)
            return false
        var summary := String(accessory.summary).strip_edges()
        var flavor := String(accessory.flavor_text).strip_edges()
        if summary.is_empty():
            push_error("Accessory summary should not be empty: %s" % path)
            return false
        if flavor.is_empty():
            push_error("Accessory flavor_text should not be empty: %s" % path)
            return false
        if flavor == summary:
            push_error("Accessory flavor_text should be distinct from summary: %s" % path)
            return false
    return true
