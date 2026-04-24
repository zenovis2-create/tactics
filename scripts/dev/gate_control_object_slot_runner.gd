extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var texture: Texture2D = BattleArtCatalog.load_object_icon("gate_control.png")
	if texture == null:
		push_error("gate_control production object icon should load from the runtime promotion slot.")
		quit(1)
		return

	print("[PASS] gate_control_object_slot_runner validated production object icon loading.")
	quit(0)
