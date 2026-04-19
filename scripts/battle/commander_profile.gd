class_name CommanderProfile
extends Resource

enum FlawType {
	NONE,
	PERSISTENT_BACKLINE,
	IGNORED_FLANKS,
	WEATHER_IGNORE,
	UNIT_SKIP
}

const FLAW_DESCRIPTIONS := {
	FlawType.NONE: "",
	FlawType.PERSISTENT_BACKLINE: "후열에만 기대는 완고한 지휘 습관이 전열의 결단을 무디게 만든다.",
	FlawType.IGNORED_FLANKS: "측면 각을 무시한 반복 지휘가 허술한 방어 습관으로 굳어졌다.",
	FlawType.WEATHER_IGNORE: "전장의 기후를 읽지 못한 채 명령을 밀어붙여 환경 역풍이 배가된다.",
	FlawType.UNIT_SKIP: "멈춘 병사를 방치하는 습관이 회복선의 손실로 되돌아온다."
}

const FLAW_PENALTIES := {
	FlawType.NONE: {},
	FlawType.PERSISTENT_BACKLINE: {"backline_unit_attack": -0.10},
	FlawType.IGNORED_FLANKS: {"flanking_damage_taken": 0.15},
	FlawType.WEATHER_IGNORE: {"weather_effect_scale": 2.0},
	FlawType.UNIT_SKIP: {"skipped_unit_respawn_hp_penalty": 20}
}

@export var flaw_type: int = FlawType.NONE
@export var repetition_count: int = 0
@export_range(0.0, 1.0, 0.01) var severity: float = 0.0
@export var flaw_description: String = ""
@export var active_penalty: Dictionary = {}

func reset() -> void:
	flaw_type = FlawType.NONE
	repetition_count = 0
	severity = 0.0
	flaw_description = ""
	active_penalty.clear()

func sync_description() -> void:
	flaw_description = get_flaw_description(flaw_type)

func activate_penalty() -> void:
	active_penalty = get_penalty_for_flaw(flaw_type)

func clear_penalty() -> void:
	active_penalty.clear()

func has_active_penalty() -> bool:
	return not active_penalty.is_empty()

func to_debug_dict() -> Dictionary:
	return {
		"flaw_type": flaw_type,
		"flaw_name": get_flaw_name(flaw_type),
		"repetition_count": repetition_count,
		"severity": severity,
		"flaw_description": flaw_description,
		"active_penalty": active_penalty.duplicate(true)
	}

static func get_flaw_name(flaw: int) -> String:
	match flaw:
		FlawType.PERSISTENT_BACKLINE:
			return "PERSISTENT_BACKLINE"
		FlawType.IGNORED_FLANKS:
			return "IGNORED_FLANKS"
		FlawType.WEATHER_IGNORE:
			return "WEATHER_IGNORE"
		FlawType.UNIT_SKIP:
			return "UNIT_SKIP"
		_:
			return "NONE"

static func get_flaw_description(flaw: int) -> String:
	return String(FLAW_DESCRIPTIONS.get(flaw, ""))

static func get_penalty_for_flaw(flaw: int) -> Dictionary:
	return (FLAW_PENALTIES.get(flaw, {}) as Dictionary).duplicate(true)
