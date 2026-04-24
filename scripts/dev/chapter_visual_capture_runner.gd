extends SceneTree

const OUTPUT_DIR := "/tmp/tactics-visual-captures"
const CAPTURE_SIZE := Vector2i(1348, 816)
const CAPTURE_CASES := [
	{"name": "ch07_preview", "scene": preload("res://scenes/dev/CH07RitualCityPreview.tscn"), "frames": 3},
	{"name": "ch07_battle", "scene": preload("res://scenes/dev/ch07_representative_battle.tscn"), "frames": 4},
	{"name": "ch09b_preview", "scene": preload("res://scenes/dev/CH09BRootArchivePreview.tscn"), "frames": 3},
	{"name": "ch09b_battle", "scene": preload("res://scenes/dev/ch09b_representative_battle.tscn"), "frames": 4},
	{"name": "ch10_preview", "scene": preload("res://scenes/dev/CH10FinalBellPreview.tscn"), "frames": 3},
	{"name": "ch10_battle", "scene": preload("res://scenes/dev/ch10_representative_battle.tscn"), "frames": 4},
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)
	var viewport := SubViewport.new()
	viewport.name = "CaptureViewport"
	viewport.size = CAPTURE_SIZE
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.handle_input_locally = false
	root.add_child(viewport)

	for entry in CAPTURE_CASES:
		var scene: Node = entry["scene"].instantiate()
		viewport.add_child(scene)
		for _i in range(int(entry.get("frames", 3))):
			await process_frame
		var viewport_texture: ViewportTexture = viewport.get_texture()
		if viewport_texture == null:
			return _fail("Viewport texture was not ready for %s." % String(entry["name"]))
		var image: Image = viewport_texture.get_image()
		if image == null:
			return _fail("Failed to capture image for %s." % String(entry["name"]))
		var output_path := "%s/%s.png" % [OUTPUT_DIR, String(entry["name"])]
		var result: Error = image.save_png(output_path)
		if result != OK:
			return _fail("Failed to save capture for %s." % String(entry["name"]))
		scene.queue_free()
		await process_frame

	print(OUTPUT_DIR)
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
