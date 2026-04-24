extends SceneTree

const PREVIEW_SCENE: PackedScene = preload("res://scenes/dev/CH09BRootArchivePreview.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene := PREVIEW_SCENE.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	if not _assert_ground_loaded(scene):
		return
	if not _assert_prop_mix_loaded(scene):
		return
	if not _assert_character_layer_loaded(scene):
		return

	print("VISUAL_QA_SUMMARY=%s" % JSON.stringify({
		"preview_case": "ch09b",
		"family": "archive",
		"chapter_props": ["archive_lectern_01", "revision_core_01", "truth_dais_01"],
		"expected_animated_characters": 5,
	}))
	print("[PASS] ch09b_root_archive_preview_runner validated root-archive preview loading.")
	quit(0)


func _assert_ground_loaded(scene: Node) -> bool:
	var ground_root := scene.get_node_or_null("GroundRoot")
	if ground_root == null:
		return _fail("CH09B root archive preview should expose GroundRoot.")
	if ground_root.get_child_count() <= 0:
		return _fail("CH09B root archive preview should spawn ground sprites.")
	var textured := 0
	for child in ground_root.get_children():
		if child is Sprite2D and child.texture != null:
			textured += 1
	if textured == 0:
		return _fail("CH09B root archive ground sprites should resolve textures.")
	return true


func _assert_prop_mix_loaded(scene: Node) -> bool:
	var prop_root := scene.get_node_or_null("PropRoot")
	if prop_root == null:
		return _fail("CH09B root archive preview should expose PropRoot.")
	var textured := 0
	for child in prop_root.get_children():
		if child is Sprite2D and child.texture != null:
			textured += 1
	if textured < 3:
		return _fail("CH09B root archive preview should load archive-lectern, revision-core, and truth-dais chapter props.")
	return true


func _assert_character_layer_loaded(scene: Node) -> bool:
	var character_root := scene.get_node_or_null("CharacterRoot")
	if character_root == null:
		return _fail("CH09B root archive preview should expose CharacterRoot.")
	var animated_count := 0
	for child in character_root.get_children():
		if child is AnimatedSprite2D:
			animated_count += 1
			var sprite := child as AnimatedSprite2D
			if sprite.sprite_frames == null:
				return _fail("%s should have SpriteFrames." % sprite.name)
	if animated_count < 5:
		return _fail("CH09B root archive preview should load five animated characters.")
	return true


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
