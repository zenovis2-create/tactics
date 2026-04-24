class_name HuntStageRegistry
extends RefCounted

const StageData = preload("res://scripts/data/stage_data.gd")

const HUNT_STAGE_BY_ID := {
	&"HUNT_BASIL": preload("res://data/stages/hunt_basil_stage.tres"),
	&"HUNT_SARIA": preload("res://data/stages/hunt_saria_stage.tres"),
	&"HUNT_LETE": preload("res://data/stages/hunt_lete_stage.tres"),
	&"HUNT_MELKION": preload("res://data/stages/hunt_melkion_stage.tres"),
	&"HUNT_KARUON": preload("res://data/stages/hunt_karuon_stage.tres"),
}

static func get_stage(stage_id: StringName) -> StageData:
	return HUNT_STAGE_BY_ID.get(stage_id, null)
