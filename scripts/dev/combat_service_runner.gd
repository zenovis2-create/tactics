extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var suite = load("res://tests/test_combat_service.gd").new()
	var result: Dictionary = suite.run_tests()
	suite.free()
	suite = null
	if int(result.get("failed", 0)) > 0:
		push_error("test_combat_service failed: %s" % str(result.get("messages", [])))
		quit(1)
		return
	print("[PASS] combat_service_runner: %d tests passed." % int(result.get("passed", 0)))
	quit(0)
