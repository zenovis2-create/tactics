extends SceneTree

const BgmRouterScript = preload("res://scripts/audio/bgm_router.gd")

var _router: Node = null


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_router = BgmRouterScript.new()
	root.add_child(_router)
	await process_frame
	await process_frame

	_router.play_cue("bgm_title")
	await process_frame
	await process_frame

	_router.play_cue("bgm_battle_default", true)
	await process_frame
	await process_frame

	if _router.has_method("stop"):
		_router.stop()
	await process_frame

	if _router != null and is_instance_valid(_router):
		_router.queue_free()
		_router = null
	await process_frame
	await process_frame

	print("[PASS] bgm_router_min_runner completed.")
	quit(0)
