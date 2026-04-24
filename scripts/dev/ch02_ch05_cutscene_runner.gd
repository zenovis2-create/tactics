extends SceneTree

const CutsceneCatalog = preload("res://data/cutscenes/cutscene_catalog.gd")

const STAGES := [
	preload("res://data/stages/ch02_01_stage.tres"),
	preload("res://data/stages/ch02_02_stage.tres"),
	preload("res://data/stages/ch02_03_stage.tres"),
	preload("res://data/stages/ch02_04_stage.tres"),
	preload("res://data/stages/ch02_05_stage.tres"),
	preload("res://data/stages/ch03_01_stage.tres"),
	preload("res://data/stages/ch03_02_stage.tres"),
	preload("res://data/stages/ch03_03_stage.tres"),
	preload("res://data/stages/ch03_04_stage.tres"),
	preload("res://data/stages/ch03_05_stage.tres"),
	preload("res://data/stages/ch04_01_stage.tres"),
	preload("res://data/stages/ch04_02_stage.tres"),
	preload("res://data/stages/ch04_03_stage.tres"),
	preload("res://data/stages/ch04_04_stage.tres"),
	preload("res://data/stages/ch04_05_stage.tres"),
	preload("res://data/stages/ch05_01_stage.tres"),
	preload("res://data/stages/ch05_02_stage.tres"),
	preload("res://data/stages/ch05_03_stage.tres"),
	preload("res://data/stages/ch05_04_stage.tres"),
	preload("res://data/stages/ch05_05_stage.tres"),
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for stage in STAGES:
		if stage == null:
			return _fail("Stage preload failed inside CH02~CH05 cutscene runner.")
		if stage.start_cutscene_id == &"":
			return _fail("%s should expose start_cutscene_id." % String(stage.stage_id))
		if stage.clear_cutscene_id == &"":
			return _fail("%s should expose clear_cutscene_id." % String(stage.stage_id))
		if String(stage.next_destination_summary).strip_edges().is_empty():
			return _fail("%s should expose next_destination_summary." % String(stage.stage_id))

		var start_cutscene = CutsceneCatalog.get_cutscene(stage.start_cutscene_id)
		if start_cutscene == null:
			return _fail("%s start cutscene should resolve in catalog: %s" % [String(stage.stage_id), String(stage.start_cutscene_id)])
		if start_cutscene.get_beat_count() <= 0:
			return _fail("%s start cutscene should expose at least one beat." % String(stage.stage_id))

		var clear_cutscene = CutsceneCatalog.get_cutscene(stage.clear_cutscene_id)
		if clear_cutscene == null:
			return _fail("%s clear cutscene should resolve in catalog: %s" % [String(stage.stage_id), String(stage.clear_cutscene_id)])
		if clear_cutscene.get_beat_count() <= 0:
			return _fail("%s clear cutscene should expose at least one beat." % String(stage.stage_id))

	print("[PASS] ch02_ch05_cutscene_runner: CH02~CH05 stages resolve valid start/clear cutscenes.")
	quit(0)

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
