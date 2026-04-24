extends SceneTree

const PREVIEW_SCENE: PackedScene = preload("res://scenes/dev/BattleIntegrationPreview.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene := PREVIEW_SCENE.instantiate()
	root.add_child(scene)

	await process_frame
	await process_frame

	if not _assert_environment_loaded(scene):
		return
	if not _assert_character_gallery_loaded(scene):
		return

	print("[PASS] battle_integration_preview_runner validated environment and sprite asset loading.")
	quit(0)


func _assert_environment_loaded(scene: Node) -> bool:
	var ground_root := scene.get_node_or_null("GroundRoot")
	var prop_root := scene.get_node_or_null("PropRoot")
	if ground_root == null or prop_root == null:
		return _fail("BattleIntegrationPreview should expose GroundRoot and PropRoot.")

	if ground_root.get_child_count() <= 0:
		return _fail("GroundRoot should contain generated terrain sprites.")
	if prop_root.get_child_count() <= 0:
		return _fail("PropRoot should contain objective/equipment support sprites.")

	var textured_ground := 0
	for child in ground_root.get_children():
		if child is Sprite2D and child.texture != null:
			textured_ground += 1
	if textured_ground == 0:
		return _fail("GroundRoot sprites should resolve textures.")

	var textured_props := 0
	for child in prop_root.get_children():
		if child is Sprite2D and child.texture != null:
			textured_props += 1
	if textured_props == 0:
		return _fail("PropRoot sprites should resolve textures.")

	return true


func _assert_character_gallery_loaded(scene: Node) -> bool:
	var character_root := scene.get_node_or_null("CharacterRoot")
	if character_root == null:
		return _fail("BattleIntegrationPreview should expose CharacterRoot.")

	var sprite_count := 0
	for child in character_root.get_children():
		if child is AnimatedSprite2D:
			sprite_count += 1
			var sprite := child as AnimatedSprite2D
			if sprite.sprite_frames == null:
				return _fail("%s should have SpriteFrames assigned." % sprite.name)
			if sprite.sprite_frames.get_animation_names().is_empty():
				return _fail("%s should expose at least one animation." % sprite.name)
			var any_frames := false
			for animation_name in sprite.sprite_frames.get_animation_names():
				if sprite.sprite_frames.get_frame_count(animation_name) > 0:
					any_frames = true
					break
			if not any_frames:
				return _fail("%s should contain at least one non-empty animation." % sprite.name)

	if sprite_count < 5:
		return _fail("BattleIntegrationPreview should load 5 animated roster sprites.")
	return true


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
