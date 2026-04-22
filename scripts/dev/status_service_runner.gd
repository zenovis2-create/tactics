extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var suite = load("res://tests/test_status_service.gd").new()
	var result: Dictionary = suite.run_tests()
	if int(result.get("failed", 0)) > 0:
		push_error("test_status_service failed: %s" % str(result.get("messages", [])))
		quit(1)
		return
	print("[PASS] status_service_runner: %d tests passed." % int(result.get("passed", 0)))
	quit(0)
