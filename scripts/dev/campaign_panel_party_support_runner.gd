extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const StageData = preload("res://scripts/data/stage_data.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var stage: StageData = preload("res://data/stages/ch02_05_stage.tres")
	main.campaign_controller.debug_seed_chapter_camp(&"CH02", 4, stage)
	await process_frame
	await process_frame

	var panel = main.campaign_panel
	if panel == null:
		return _fail("Main should expose campaign_panel.")
	if not panel.select_party_by_unit_id("ally_bran"):
		return _fail("CampaignPanel should be able to select Bran in CH02 camp.")
	await process_frame

	var support_card = panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SupportCard")
	if support_card == null:
		return _fail("CampaignPanel should expose SupportCard.")
	if not support_card.visible:
		return _fail("SupportCard should be visible for Bran.")

	var preview = panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SupportCard/Margin/Stack/Preview")
	if preview == null or preview.texture == null:
		return _fail("SupportCard preview should resolve a texture for Bran.")

	print("[PASS] campaign_panel_party_support_runner validated paladin shield support surface in party detail.")
	quit(0)


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
