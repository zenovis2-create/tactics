extends SceneTree

const PREVIEW_SCENE: PackedScene = preload("res://scenes/dev/CH06IronKeepPreview.tscn")


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

	print("[PASS] ch06_iron_keep_preview_runner validated iron-keep preview loading.")
	quit(0)


func _assert_ground_loaded(scene: Node) -> bool:
	var ground_root := scene.get_node_or_null("GroundRoot")
	if ground_root == null:
		return _fail("CH06 iron keep preview should expose GroundRoot.")
	if ground_root.get_child_count() <= 0:
		return _fail("CH06 iron keep preview should spawn ground sprites.")
	var textured := 0
	var edge_like := 0
	for child in ground_root.get_children():
		if child is Sprite2D and child.texture != null:
			textured += 1
			var sprite := child as Sprite2D
			if sprite.scale.x > 1.0:
				edge_like += 1
	if textured == 0:
		return _fail("Iron-keep ground sprites should resolve textures.")
	if edge_like == 0:
		return _fail("CH06 iron keep preview should load fortress edge support sprites.")
	return true


func _assert_prop_mix_loaded(scene: Node) -> bool:
	var prop_root := scene.get_node_or_null("PropRoot")
	if prop_root == null:
		return _fail("CH06 iron keep preview should expose PropRoot.")
	var textured := 0
	for child in prop_root.get_children():
		if child is Sprite2D and child.texture != null:
			textured += 1
	if textured < 4:
		return _fail("CH06 iron keep preview should load altar, lever, gate-control, and shield support props.")
	return true


func _assert_character_layer_loaded(scene: Node) -> bool:
	var character_root := scene.get_node_or_null("CharacterRoot")
	if character_root == null:
		return _fail("CH06 iron keep preview should expose CharacterRoot.")
	var animated_count := 0
	for child in character_root.get_children():
		if child is AnimatedSprite2D:
			animated_count += 1
	if animated_count < 4:
		return _fail("CH06 iron keep preview should load four animated characters.")
	return true


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
