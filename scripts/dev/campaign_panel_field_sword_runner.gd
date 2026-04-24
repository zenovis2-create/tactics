extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const StageData = preload("res://scripts/data/stage_data.gd")
const FIELD_SWORD_IMAGE := "res://assets/props/field_sword_01/runtime/field_sword_01_integration_v01.png"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var stage: StageData = preload("res://data/stages/ch01_05_stage.tres")
	main.campaign_controller.debug_seed_chapter_camp(&"CH01", 4, stage)
	await process_frame
	await process_frame

	var panel = main.campaign_panel
	if panel == null:
		return _fail("Main should expose campaign_panel.")

	if not panel.select_party_by_unit_id("ally_rian"):
		return _fail("CampaignPanel should be able to select Rian in CH01 camp.")
	await process_frame

	var support_card = panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SupportCard")
	if support_card == null or not support_card.visible:
		return _fail("SupportCard should be visible for Rian.")

	var support_heading: Label = panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SupportCard/Margin/Stack/HeadingLabel")
	if support_heading == null or support_heading.text.find("검") == -1:
		return _fail("Rian support surface should expose the field sword heading.")

	var preview: TextureRect = panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SupportCard/Margin/Stack/Preview")
	if preview == null or preview.texture == null:
		return _fail("Rian support surface should resolve a field sword texture.")

	panel._select_section(panel.SECTION_SUMMARY)
	await process_frame
	var cards_root = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SummarySection/PresentationCards")
	if cards_root == null or cards_root.get_child_count() == 0:
		return _fail("CH01 camp should render presentation cards.")

	var found_field_sword := false
	for child in cards_root.get_children():
		var found_preview := _find_first_texture_rect(child)
		if found_preview != null and found_preview.texture != null:
			found_field_sword = true
			break
	if not found_field_sword:
		return _fail("CH01 camp should render an image-backed field sword presentation card.")

	if not FileAccess.file_exists(ProjectSettings.globalize_path(FIELD_SWORD_IMAGE)):
		return _fail("Field sword integration image should exist for support routing.")

	print("[PASS] campaign_panel_field_sword_runner validated field sword camp/detail support surfaces.")
	quit(0)


func _find_first_texture_rect(node: Node) -> TextureRect:
	if node is TextureRect:
		return node
	for child in node.get_children():
		var found = _find_first_texture_rect(child)
		if found != null:
			return found
	return null


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
