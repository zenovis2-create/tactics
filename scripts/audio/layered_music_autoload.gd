extends Node

const LayeredMusicScript = preload("res://scripts/audio/layered_music.gd")


func _ready() -> void:
	call_deferred("_ensure_layered_music_singleton")


func play_cue(cue_id: String, restart: bool = false) -> void:
	var layered_music: Node = _ensure_layered_music_singleton()
	if layered_music != null:
		layered_music.play_cue(cue_id, restart)


func activate_layer(layer_name: String, fade_time: float = 1.0) -> void:
	var layered_music: Node = _ensure_layered_music_singleton()
	if layered_music != null:
		layered_music.activate_layer(layer_name, fade_time)


func deactivate_layer(layer_name: String, fade_time: float = 1.0) -> void:
	var layered_music: Node = _ensure_layered_music_singleton()
	if layered_music != null:
		layered_music.deactivate_layer(layer_name, fade_time)


func trigger_spotlight_music(spotlight_type: String, fade_time: float = 2.0) -> void:
	var layered_music: Node = _ensure_layered_music_singleton()
	if layered_music != null:
		layered_music.trigger_spotlight_music(spotlight_type, fade_time)


func crossfade_to_cue(cue_id: String, fade_duration: float = 2.0) -> void:
	var layered_music: Node = _ensure_layered_music_singleton()
	if layered_music != null:
		layered_music.crossfade_to_cue(cue_id, fade_duration)


func stop_all(fade_time: float = 2.0) -> void:
	var layered_music: Node = _ensure_layered_music_singleton()
	if layered_music != null:
		layered_music.stop_all(fade_time)


func is_layer_active(layer_name: String) -> bool:
	var layered_music: Node = _ensure_layered_music_singleton()
	if layered_music == null:
		return false
	return layered_music.is_layer_active(layer_name)


func get_active_layers() -> Array[String]:
	var layered_music: Node = _ensure_layered_music_singleton()
	if layered_music == null:
		return []
	return layered_music.get_active_layers()


func _ensure_layered_music_singleton() -> Node:
	var layered_music: Node = get_tree().root.get_node_or_null("LayeredMusic")
	if layered_music != null:
		return layered_music
	layered_music = LayeredMusicScript.new()
	layered_music.name = "LayeredMusic"
	get_tree().root.add_child(layered_music)
	return layered_music
