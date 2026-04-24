extends SceneTree

const PREVIEW_SCENE: PackedScene = preload("res://scenes/dev/CH10FinalBellPreview.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene := PREVIEW_SCENE.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var ground_root := scene.get_node_or_null("GroundRoot")
	var prop_root := scene.get_node_or_null("PropRoot")
	var character_root := scene.get_node_or_null("CharacterRoot")
	if ground_root == null or prop_root == null or character_root == null:
		return _fail("CH10 final bell preview should expose GroundRoot, PropRoot, and CharacterRoot.")
	if ground_root.get_child_count() <= 0:
		return _fail("CH10 final bell preview should spawn ground sprites.")
	var textured_props := 0
	for child in prop_root.get_children():
		if child is Sprite2D and child.texture != null:
			textured_props += 1
	if textured_props < 2:
		return _fail("CH10 final bell preview should load anchor-chain and bell-dais chapter props.")
	var animated_count := 0
	for child in character_root.get_children():
		if child is AnimatedSprite2D:
			animated_count += 1
	if animated_count < 5:
		return _fail("CH10 final bell preview should load five animated characters.")

	print("VISUAL_QA_SUMMARY=%s" % JSON.stringify({
		"preview_case": "ch10",
		"family": "final_bell",
		"chapter_props": ["anchor_chain_01", "bell_dais_01"],
		"expected_animated_characters": 5,
	}))
	print("[PASS] ch10_final_bell_preview_runner validated final-bell preview loading.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
