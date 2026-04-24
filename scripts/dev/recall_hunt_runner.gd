extends SceneTree

const CampController = preload("res://scripts/camp/camp_controller.gd")
const CampHud = preload("res://scripts/camp/camp_hud.gd")
const CampData = preload("res://scripts/data/camp_data.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

const CAMP_HUD_SCENE = preload("res://scenes/camp/CampHUD.tscn")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var progression := ProgressionData.new()
	progression.flags["flag_ch08_complete"] = true
	progression.unlocked_hunt_ids = [&"hunt_basil", &"hunt_lete"]

	var controller := CampController.new()
	root.add_child(controller)
	await process_frame

	var camp_data: CampData = controller.enter_camp(&"ch08", {}, progression)
	if camp_data == null:
		return _fail("Recall hunt runner expected CampData from enter_camp.")
	if not camp_data.unlocked_axes.has(&"recall"):
		return _fail("Recall axis should unlock from ch08 onward.")
	if camp_data.recall_hunt_entries.size() != 3:
		return _fail("Recall hunt snapshot should expose all configured hunt entries.")

	var unlocked_ids: Array[String] = []
	for entry in camp_data.recall_hunt_entries:
		if bool(entry.get("unlocked", false)):
			unlocked_ids.append(String(entry.get("hunt_id", "")))
	if not unlocked_ids.has("hunt_basil") or not unlocked_ids.has("hunt_lete"):
		return _fail("Recall hunt snapshot should mark unlocked hunts from progression.")
	if unlocked_ids.has("hunt_saria"):
		return _fail("Recall hunt snapshot should keep locked hunts hidden until unlocked.")

	controller.open_recall_tab()
	if controller.get_camp_data().active_axis != &"recall":
		return _fail("CampController should switch active axis to recall.")

	if not controller.select_hunt(&"hunt_lete"):
		return _fail("CampController should allow selecting an unlocked hunt.")
	if controller.get_selected_hunt_stage_id() != &"HUNT_LETE":
		return _fail("Selected hunt should expose its target stage id.")
	if controller.select_hunt(&"hunt_saria"):
		return _fail("CampController should reject selecting a locked hunt.")

	var hud: CampHud = CAMP_HUD_SCENE.instantiate() as CampHud
	root.add_child(hud)
	hud.load_camp(camp_data)
	await process_frame
	hud.select_tab(&"recall")
	await process_frame

	var hud_snapshot: Dictionary = hud.get_layout_snapshot()
	if int(hud_snapshot.get("recall_entry_count", 0)) != 3:
		return _fail("CampHud snapshot should expose recall entry count.")
	if String(hud_snapshot.get("active_tab", "")) != "recall":
		return _fail("CampHud should switch to recall tab.")

	var recall_panel = hud.get_node_or_null("VBox/PanelArea/recall")
	if recall_panel == null or not recall_panel.has_method("get_layout_snapshot"):
		return _fail("CampHud should host a recall panel with snapshot support.")
	var recall_snapshot: Dictionary = recall_panel.get_layout_snapshot()
	if int(recall_snapshot.get("entry_count", 0)) != 3:
		return _fail("Recall panel should render all configured hunts.")
	var recall_unlocked: Array = recall_snapshot.get("unlocked_ids", [])
	if not recall_unlocked.has("hunt_basil") or not recall_unlocked.has("hunt_lete"):
		return _fail("Recall panel should mark the unlocked hunts as selectable.")

	print("[PASS] recall_hunt_runner: recall hunt unlock, selection, and UI snapshot checks passed.")
	quit(0)

func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	push_error(message)
	quit(1)
