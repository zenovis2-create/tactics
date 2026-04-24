class_name HuntBoard
extends Node

## 회상 토벌전 해금/조회 관리

const HuntData = preload("res://scripts/data/hunt_data.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

const HuntCatalog = {
    &"hunt_basil": preload("res://data/hunts/hunt_basil.tres"),
    &"hunt_saria": preload("res://data/hunts/hunt_saria.tres"),
    &"hunt_lete": preload("res://data/hunts/hunt_lete.tres"),
    &"hunt_karuon": preload("res://data/hunts/hunt_karuon.tres"),
}

var _progression_data: ProgressionData = null

func set_progression_data(data: ProgressionData) -> void:
    _progression_data = data

func unlock_hunt(hunt_id: StringName) -> void:
    if _progression_data == null:
        return
    if not _progression_data.unlocked_hunt_ids.has(hunt_id):
        var ids = _progression_data.unlocked_hunt_ids.duplicate()
        ids.append(hunt_id)
        _progression_data.unlocked_hunt_ids = ids

func is_unlocked(hunt_id: StringName) -> bool:
    if _progression_data == null:
        return false
    return _progression_data.unlocked_hunt_ids.has(hunt_id)

func get_all_hunts() -> Array[HuntData]:
    var result: Array[HuntData] = []
    for hunt in HuntCatalog.values():
        result.append(hunt)
    return result

func get_unlocked_hunts() -> Array[HuntData]:
    var result: Array[HuntData] = []
    for hunt in HuntCatalog.values():
        if is_unlocked(hunt.hunt_id):
            result.append(hunt)
    return result

func get_hunt_data(hunt_id: StringName) -> HuntData:
    return HuntCatalog.get(hunt_id, null)
