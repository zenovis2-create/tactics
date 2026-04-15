class_name CampaignChapterRegistry
extends RefCounted

const StageData = preload("res://scripts/data/stage_data.gd")

const CHAPTER_CH01: StringName = &"CH01"
const CHAPTER_CH02: StringName = &"CH02"
const CHAPTER_CH03: StringName = &"CH03"
const CHAPTER_CH04: StringName = &"CH04"
const CHAPTER_CH05: StringName = &"CH05"
const CHAPTER_CH06: StringName = &"CH06"
const CHAPTER_CH07: StringName = &"CH07"
const CHAPTER_CH08: StringName = &"CH08"
const CHAPTER_CH09A: StringName = &"CH09A"
const CHAPTER_CH09B: StringName = &"CH09B"
const CHAPTER_CH10: StringName = &"CH10"

const CHAPTER_RANK_BY_ID := {
    CHAPTER_CH01: 1,
    CHAPTER_CH02: 2,
    CHAPTER_CH03: 3,
    CHAPTER_CH04: 4,
    CHAPTER_CH05: 5,
    CHAPTER_CH06: 6,
    CHAPTER_CH07: 7,
    CHAPTER_CH08: 8,
    CHAPTER_CH09A: 9,
    CHAPTER_CH09B: 10,
    CHAPTER_CH10: 11
}

const STAGE_FLOW_BY_CHAPTER := {
    CHAPTER_CH01: [
        preload("res://data/stages/ch01_02_stage.tres"),
        preload("res://data/stages/ch01_03_stage.tres"),
        preload("res://data/stages/ch01_04_stage.tres"),
        preload("res://data/stages/ch01_05_stage.tres")
    ],
    CHAPTER_CH02: [
        preload("res://data/stages/ch02_01_stage.tres"),
        preload("res://data/stages/ch02_02_stage.tres"),
        preload("res://data/stages/ch02_03_stage.tres"),
        preload("res://data/stages/ch02_04_stage.tres"),
        preload("res://data/stages/ch02_05_stage.tres")
    ],
    CHAPTER_CH03: [
        preload("res://data/stages/ch03_01_stage.tres"),
        preload("res://data/stages/ch03_02_stage.tres"),
        preload("res://data/stages/ch03_03_stage.tres"),
        preload("res://data/stages/ch03_04_stage.tres"),
        preload("res://data/stages/ch03_05_stage.tres")
    ],
    CHAPTER_CH04: [
        preload("res://data/stages/ch04_01_stage.tres"),
        preload("res://data/stages/ch04_02_stage.tres"),
        preload("res://data/stages/ch04_03_stage.tres"),
        preload("res://data/stages/ch04_04_stage.tres"),
        preload("res://data/stages/ch04_05_stage.tres")
    ],
    CHAPTER_CH05: [
        preload("res://data/stages/ch05_01_stage.tres"),
        preload("res://data/stages/ch05_02_stage.tres"),
        preload("res://data/stages/ch05_03_stage.tres"),
        preload("res://data/stages/ch05_04_stage.tres"),
        preload("res://data/stages/ch05_05_stage.tres")
    ],
    CHAPTER_CH06: [
        preload("res://data/stages/ch06_01_stage.tres"),
        preload("res://data/stages/ch06_02_stage.tres"),
        preload("res://data/stages/ch06_03_stage.tres"),
        preload("res://data/stages/ch06_04_stage.tres"),
        preload("res://data/stages/ch06_05_stage.tres")
    ],
    CHAPTER_CH07: [
        preload("res://data/stages/ch07_01_stage.tres"),
        preload("res://data/stages/ch07_02_stage.tres"),
        preload("res://data/stages/ch07_03_stage.tres"),
        preload("res://data/stages/ch07_04_stage.tres"),
        preload("res://data/stages/ch07_05_stage.tres")
    ],
    CHAPTER_CH08: [
        preload("res://data/stages/ch08_01_stage.tres"),
        preload("res://data/stages/ch08_02_stage.tres"),
        preload("res://data/stages/ch08_03_stage.tres"),
        preload("res://data/stages/ch08_04_stage.tres"),
        preload("res://data/stages/ch08_05_stage.tres")
    ],
    CHAPTER_CH09A: [
        preload("res://data/stages/ch09a_01_stage.tres"),
        preload("res://data/stages/ch09a_02_stage.tres"),
        preload("res://data/stages/ch09a_03_stage.tres"),
        preload("res://data/stages/ch09a_04_stage.tres"),
        preload("res://data/stages/ch09a_05_stage.tres")
    ],
    CHAPTER_CH09B: [
        preload("res://data/stages/ch09b_01_stage.tres"),
        preload("res://data/stages/ch09b_02_stage.tres"),
        preload("res://data/stages/ch09b_03_stage.tres"),
        preload("res://data/stages/ch09b_04_stage.tres"),
        preload("res://data/stages/ch09b_05_stage.tres")
    ],
    CHAPTER_CH10: [
        preload("res://data/stages/ch10_01_stage.tres"),
        preload("res://data/stages/ch10_02_stage.tres"),
        preload("res://data/stages/ch10_03_stage.tres"),
        preload("res://data/stages/ch10_04_stage.tres"),
        preload("res://data/stages/ch10_05_stage.tres")
    ]
}

static func get_stage_flow(chapter_id: StringName) -> Array[StageData]:
    var stages: Array[StageData] = []
    var stage_flow: Variant = STAGE_FLOW_BY_CHAPTER.get(chapter_id, STAGE_FLOW_BY_CHAPTER[CHAPTER_CH01])
    if typeof(stage_flow) != TYPE_ARRAY:
        return stages
    for stage in stage_flow:
        if stage is StageData:
            stages.append(stage)
    return stages

static func get_rank(chapter_id: StringName) -> int:
    return int(CHAPTER_RANK_BY_ID.get(chapter_id, 1))
