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
		push_error("Meta forge runner could not resolve campaign controller.")
		quit(1)
		return

	campaign.debug_unlock_accessory_ids([
		&"acc_keeper_thread_seal",
		&"acc_tower_ward_signet"
	])
	campaign.debug_seed_chapter_camp(&"CH09B", 4, CH09B_FINAL_STAGE)
	await process_frame
	await process_frame

	var progression = campaign._get_progression_data()
	if progression == null:
		push_error("Meta forge runner expected progression data in camp state.")
		quit(1)
		return

	progression.add_material(&"archive_ash", 2)
	progression.add_material(&"memory_thread", 2)
	progression.add_material(&"forest_essence", 1)
	progression.add_material(&"command_plate", 2)
	progression.add_material(&"sanctified_shard", 2)
	await process_frame

	if not campaign._craft_recipe(&"recipe_keeper_root_staff"):
		push_error("Meta forge runner expected Keeper Root Staff recipe to craft successfully.")
		quit(1)
		return

	if not campaign._is_item_owned(&"weapon", &"wp_keeper_root_staff"):
		push_error("Meta forge runner expected Keeper Root Staff to unlock after crafting.")
		quit(1)
		return

	if progression.get_material_count(&"archive_ash") != 0 or progression.get_material_count(&"memory_thread") != 0:
		push_error("Meta forge runner expected Keeper Root Staff craft to consume archive_ash and memory_thread.")
		quit(1)
		return

	progression.add_material(&"iron_frag", 1)
	campaign._equipped_accessory_by_unit_id[String(&"ally_noah")] = String(&"acc_keeper_thread_seal")
	campaign._correct_accessory_choice_for_unit(&"ally_noah")
	await process_frame

	var equipped_accessory_id: StringName = StringName(campaign._equipped_accessory_by_unit_id.get(String(&"ally_noah"), ""))
	if equipped_accessory_id != &"acc_tower_ward_signet":
		push_error("Meta forge runner expected accessory reforge to rotate Noah onto Tower Ward Signet.")
		quit(1)
		return

	if progression.get_material_count(&"iron_frag") != 0:
		push_error("Meta forge runner expected accessory reforge to consume one affordable material.")
		quit(1)
		return

	if not _inventory_has_line(main.campaign_panel.get_snapshot().get("inventory_entries", []), "장신구 보정:"):
		push_error("Meta forge runner expected camp inventory log to record accessory reforge.")
		quit(1)
		return

	print("[PASS] meta_forge_runner: late-game crafting and paid accessory reforge checks passed.")
	quit(0)

func _inventory_has_line(entries: Array, expected_text: String) -> bool:
	for entry in entries:
		if String(entry).contains(expected_text):
			return true
	return false
