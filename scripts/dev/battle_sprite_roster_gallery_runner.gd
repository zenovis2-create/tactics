extends SceneTree

const GALLERY_SCENE: PackedScene = preload("res://scenes/dev/BattleSpriteRosterGallery.tscn")
const EXPECTED_MIN_ANIMATED_SPRITES := 26


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene := GALLERY_SCENE.instantiate()
	root.add_child(scene)

	await process_frame
	await process_frame

	if not _assert_gallery_loaded(scene):
		return

	print("[PASS] battle_sprite_roster_gallery_runner validated ally/enemy roster gallery loading.")
	quit(0)


func _assert_gallery_loaded(scene: Node) -> bool:
	var animated_count := 0
	var non_empty_animation_sets := 0

	for child in scene.get_children():
		if child is AnimatedSprite2D:
			animated_count += 1
			var sprite := child as AnimatedSprite2D
			if sprite.sprite_frames == null:
				return _fail("%s should have SpriteFrames assigned." % sprite.name)
			var names := sprite.sprite_frames.get_animation_names()
			if names.is_empty():
				return _fail("%s should expose animation names." % sprite.name)
			var has_frames := false
			for animation_name in names:
				if sprite.sprite_frames.get_frame_count(animation_name) > 0:
					has_frames = true
					break
			if has_frames:
				non_empty_animation_sets += 1
			else:
				return _fail("%s should contain at least one non-empty animation." % sprite.name)

	if animated_count < EXPECTED_MIN_ANIMATED_SPRITES:
		return _fail("Roster gallery should load at least %d animated sprites." % EXPECTED_MIN_ANIMATED_SPRITES)

	if non_empty_animation_sets < EXPECTED_MIN_ANIMATED_SPRITES:
		return _fail("All roster gallery sprites should have at least one non-empty animation.")

	return true


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
