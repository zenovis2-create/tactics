class_name EvolutionEvent
extends Resource

enum EffectType {
	DESTROY,
	TRANSFORM,
	SPAWN,
	BLOCK
}

const CH06_OUTER_WALL_TILES: Array[Vector2i] = [
	Vector2i(3, 3),
	Vector2i(4, 3),
	Vector2i(4, 4)
]

const CH08_TREE_CANDIDATES: Array[Vector2i] = [
	Vector2i(2, 4),
	Vector2i(5, 5),
	Vector2i(2, 5),
	Vector2i(5, 4)
]

const CH10_CENTRAL_PLATFORM_TILES: Array[Vector2i] = [
	Vector2i(7, 4),
	Vector2i(8, 4),
	Vector2i(9, 4),
	Vector2i(7, 6),
	Vector2i(8, 6),
	Vector2i(9, 6)
]

@export var event_id: String = ""
@export var trigger_turn: int = 1
@export var tile_positions: Array[Vector2i] = []
@export var effect_type: EffectType = EffectType.TRANSFORM
@export var new_terrain_type: String = ""
@export_multiline var narrative_text: String = ""

static func create_ch06_castle_siege_event() -> EvolutionEvent:
	return _build(
		"ch06_castle_siege_outer_wall",
		5,
		CH06_OUTER_WALL_TILES,
		EffectType.DESTROY,
		"crumbling_debris",
		"성벽이 무너진다!"
	)

static func create_ch08_dark_forest_block_event(trigger_turn_value: int, tile_position: Vector2i) -> EvolutionEvent:
	return _build(
		"ch08_dark_forest_fallen_tree_%d_%d_%d" % [trigger_turn_value, tile_position.x, tile_position.y],
		trigger_turn_value,
		[tile_position],
		EffectType.BLOCK,
		"fallen_tree",
		"나무가 쓰러졌다"
	)

static func create_ch10_final_corruption_event() -> EvolutionEvent:
	return _build(
		"ch10_final_central_platform_corruption",
		4,
		CH10_CENTRAL_PLATFORM_TILES,
		EffectType.TRANSFORM,
		"corrupted_ground",
		"중앙 제단이 오염된다!"
	)

static func _build(
	new_event_id: String,
	new_trigger_turn: int,
	new_tile_positions: Array[Vector2i],
	new_effect_type: int,
	new_terrain: String,
	new_narrative_text: String
) -> EvolutionEvent:
	var event: EvolutionEvent = new()
	event.event_id = new_event_id
	event.trigger_turn = new_trigger_turn
	event.tile_positions = new_tile_positions.duplicate()
	event.effect_type = new_effect_type
	event.new_terrain_type = new_terrain
	event.narrative_text = new_narrative_text
	return event
