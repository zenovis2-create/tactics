extends SceneTree

const PANEL_SCENE: PackedScene = preload("res://scenes/campaign/CampaignPanel.tscn")
const SHIELD_IMAGE := "res://assets/props/paladin_shield/runtime/paladin_shield_integration_v01.png"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var panel = PANEL_SCENE.instantiate()
	root.add_child(panel)
	await process_frame

	panel.show_state(
		"camp",
		"Test Camp",
		"Body",
		"Continue",
		{
			"presentation_cards": [
				{
					"eyebrow": "장비",
					"title": "방패 실루엣 기준",
					"body": "테스트 카드",
					"image_path": SHIELD_IMAGE
				}
			]
		}
	)
	await process_frame

	var cards_root = panel.get_node_or_null("Panel/Margin/Content/BodyStack/SummarySection/PresentationCards")
	if cards_root == null:
		return _fail("CampaignPanel should expose PresentationCards root.")
	if cards_root.get_child_count() != 1:
		return _fail("CampaignPanel should create exactly one presentation card for the test payload.")

	var card = cards_root.get_child(0)
	var preview = _find_first_texture_rect(card)
	if preview == null:
		return _fail("Presentation card should include a TextureRect preview when image_path is provided.")
	if preview.texture == null:
		return _fail("Presentation card preview should resolve its texture.")

	print("[PASS] campaign_panel_presentation_card_runner validated image-backed presentation cards.")
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
