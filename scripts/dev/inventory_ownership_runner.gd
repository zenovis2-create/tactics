extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH05_FINAL_STAGE = preload("res://data/stages/ch05_05_stage.tres")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_duplicate_weapon_ownership():
		return
	print("[PASS] inventory_ownership_runner: all assertions passed.")
	quit(0)

func _assert_duplicate_weapon_ownership() -> bool:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var campaign = main.campaign_controller
	campaign.debug_seed_chapter_camp(&"CH05", 4, CH05_FINAL_STAGE)
	await process_frame
	await process_frame

	var progression = campaign._get_progression_data()
	if progression == null:
		return _fail("ProgressionData should be available in camp mode.")

	progression.add_owned_item(&"weapon", &"wp_archive_ashblade", 2)
	await process_frame

	if progression.get_owned_item_count(&"weapon", &"wp_archive_ashblade") != 2:
		return _fail("Weapon ownership count should be 2 after adding two copies.")

	campaign.set_weapon_for_unit(&"ally_rian", &"wp_archive_ashblade")
	campaign.set_weapon_for_unit(&"ally_bran", &"wp_archive_ashblade")
	await process_frame

	if StringName(campaign._equipped_weapon_by_unit_id.get(String(&"ally_rian"), "")) != &"wp_archive_ashblade":
		return _fail("Rian should be allowed to equip the first owned copy.")
	if StringName(campaign._equipped_weapon_by_unit_id.get(String(&"ally_bran"), "")) != &"wp_archive_ashblade":
		return _fail("Bran should be allowed to equip the second owned copy.")

	if not campaign._sell_equipped_item(&"ally_rian", "weapon"):
		return _fail("Selling one equipped owned copy should succeed.")
	await process_frame

	if progression.get_owned_item_count(&"weapon", &"wp_archive_ashblade") != 1:
		return _fail("Selling one copy should reduce owned count from 2 to 1.")
	if StringName(campaign._equipped_weapon_by_unit_id.get(String(&"ally_rian"), "")) != &"":
		return _fail("Selling Rian's weapon should unequip Rian only.")
	if StringName(campaign._equipped_weapon_by_unit_id.get(String(&"ally_bran"), "")) != &"wp_archive_ashblade":
		return _fail("Bran should keep the remaining owned copy equipped.")

	var inventory_entries: Array = main.campaign_panel.get_snapshot().get("inventory_entries", [])
	if not _contains_line(inventory_entries, "x1"):
		return _fail("Inventory lines should surface the remaining count after one copy is sold.")

	main.queue_free()
	await process_frame
	return true

func _contains_line(lines: Array, needle: String) -> bool:
	for line in lines:
		if String(line).find(needle) != -1:
			return true
	return false

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
