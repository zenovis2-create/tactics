extends SceneTree

const CutsceneCatalog = preload("res://data/cutscenes/cutscene_catalog.gd")

const STAGE_CASES := [
	{"stage": preload("res://data/stages/ch06_01_stage.tres"), "expected_start": &"ch06_01_intro", "expected_clear": &"ch06_01_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch06_02_stage.tres"), "expected_start": &"ch06_02_intro", "expected_clear": &"ch06_02_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch06_03_stage.tres"), "expected_start": &"ch06_03_intro", "expected_clear": &"ch06_03_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch06_04_stage.tres"), "expected_start": &"ch06_04_intro", "expected_clear": &"ch06_04_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch06_05_stage.tres"), "expected_start": &"ch06_05_intro", "expected_clear": &"ch06_05_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch07_01_stage.tres"), "expected_start": &"ch07_01_intro", "expected_clear": &"ch07_01_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch07_02_stage.tres"), "expected_start": &"ch07_02_intro", "expected_clear": &"ch07_02_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch07_03_stage.tres"), "expected_start": &"ch07_03_intro", "expected_clear": &"ch07_03_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch07_04_stage.tres"), "expected_start": &"ch07_04_intro", "expected_clear": &"ch07_04_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch07_05_stage.tres"), "expected_start": &"ch07_05_intro", "expected_clear": &"ch07_05_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch08_01_stage.tres"), "expected_start": &"ch08_01_intro", "expected_clear": &"ch08_01_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch08_02_stage.tres"), "expected_start": &"ch08_02_intro", "expected_clear": &"ch08_02_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch08_03_stage.tres"), "expected_start": &"ch08_03_intro", "expected_clear": &"ch08_03_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch08_04_stage.tres"), "expected_start": &"ch08_04_intro", "expected_clear": &"ch08_04_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch08_05_stage.tres"), "expected_start": &"ch08_05_intro", "expected_clear": &"ch08_05_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch09a_01_stage.tres"), "expected_start": &"ch09a_01_intro", "expected_clear": &"ch09a_01_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch09a_02_stage.tres"), "expected_start": &"ch09a_02_intro", "expected_clear": &"ch09a_02_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch09a_03_stage.tres"), "expected_start": &"ch09a_03_intro", "expected_clear": &"ch09a_03_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch09a_04_stage.tres"), "expected_start": &"ch09a_04_intro", "expected_clear": &"ch09a_04_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch09a_05_stage.tres"), "expected_start": &"ch09a_05_intro", "expected_clear": &"ch09a_05_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch09b_01_stage.tres"), "expected_start": &"ch09b_01_intro", "expected_clear": &"ch09b_01_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch09b_02_stage.tres"), "expected_start": &"ch09b_02_intro", "expected_clear": &"ch09b_02_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch09b_03_stage.tres"), "expected_start": &"ch09b_03_intro", "expected_clear": &"ch09b_03_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch09b_04_stage.tres"), "expected_start": &"ch09b_04_intro", "expected_clear": &"ch09b_04_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch09b_05_stage.tres"), "expected_start": &"ch09b_05_intro", "expected_clear": &"ch09b_05_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch10_01_stage.tres"), "expected_start": &"ch10_01_intro", "expected_clear": &"ch10_01_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch10_02_stage.tres"), "expected_start": &"ch10_02_intro", "expected_clear": &"ch10_02_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch10_03_stage.tres"), "expected_start": &"ch10_03_intro", "expected_clear": &"ch10_03_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch10_04_stage.tres"), "expected_start": &"ch10_04_intro", "expected_clear": &"ch10_04_outro", "require_clear": true},
	{"stage": preload("res://data/stages/ch10_05_stage.tres"), "expected_start": &"ch10_05_intro", "expected_clear": &"", "require_clear": false}
]

const ENDING_CASES := [
	{"cutscene_id": &"ch10_normal_resolution_cinematic", "min_beats": 5},
	{"cutscene_id": &"ch10_true_resolution_cinematic", "min_beats": 5},
	{"cutscene_id": &"ch10_true_companion_scene", "min_beats": 7}
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for case_data in STAGE_CASES:
		if not _assert_stage_case(case_data):
			return
	for ending_case in ENDING_CASES:
		if not _assert_ending_case(ending_case):
			return
	print("[PASS] ch06_ch10_cutscene_runner: CH06~CH10 late-game cutscene contracts resolved for all stages and ending cinematics.")
	quit(0)

func _assert_stage_case(case_data: Dictionary) -> bool:
	var stage = case_data.get("stage", null)
	if stage == null:
		return _fail("Late-game cutscene runner stage preload failed.")
	var label := String(stage.stage_id)
	var expected_start: StringName = case_data.get("expected_start", &"")
	var expected_clear: StringName = case_data.get("expected_clear", &"")
	var require_clear: bool = bool(case_data.get("require_clear", true))

	if stage.start_cutscene_id != expected_start:
		return _fail("%s start_cutscene_id drifted." % label)
	if require_clear and stage.clear_cutscene_id != expected_clear:
		return _fail("%s clear_cutscene_id drifted." % label)
	if not require_clear and stage.clear_cutscene_id != &"":
		return _fail("%s should delegate clear cutscene to ending flow." % label)
	if String(stage.next_destination_summary).strip_edges().is_empty():
		return _fail("%s should expose next_destination_summary." % label)

	var start_cutscene = CutsceneCatalog.get_cutscene(stage.start_cutscene_id)
	if start_cutscene == null:
		return _fail("%s start cutscene should resolve in catalog: %s" % [label, String(stage.start_cutscene_id)])
	if start_cutscene.get_beat_count() < 2:
		return _fail("%s start cutscene should expose at least 2 beats." % label)

	if require_clear:
		var clear_cutscene = CutsceneCatalog.get_cutscene(stage.clear_cutscene_id)
		if clear_cutscene == null:
			return _fail("%s clear cutscene should resolve in catalog: %s" % [label, String(stage.clear_cutscene_id)])
		if clear_cutscene.get_beat_count() < 2:
			return _fail("%s clear cutscene should expose at least 2 beats so late-game clears are not a single shallow card." % label)

	return true

func _assert_ending_case(case_data: Dictionary) -> bool:
	var cutscene_id: StringName = case_data.get("cutscene_id", &"")
	var min_beats: int = int(case_data.get("min_beats", 1))
	var data = CutsceneCatalog.get_cutscene(cutscene_id)
	if data == null:
		return _fail("Ending cutscene should resolve in catalog: %s" % String(cutscene_id))
	if data.get_beat_count() < min_beats:
		return _fail("Ending cutscene %s should expose at least %d beats." % [String(cutscene_id), min_beats])
	return true

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
