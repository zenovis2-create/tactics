extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const OUTPUT_PATH := "/tmp/tactics-battle-visual-snapshot.png"

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)

    get_root().size = Vector2i(1348, 816)

    await process_frame
    await process_frame
    await process_frame
    await process_frame

    var image: Image = get_root().get_texture().get_image()
    if image == null:
        push_error("Failed to capture viewport image.")
        quit(1)
        return

    var result: Error = image.save_png(OUTPUT_PATH)
    if result != OK:
        push_error("Failed to save viewport image to %s." % OUTPUT_PATH)
        quit(1)
        return

    print(OUTPUT_PATH)
    quit(0)
