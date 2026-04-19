extends Node

const EmotionalLayerControllerScript = preload("res://scripts/audio/emotional_layer_controller.gd")


func _ready() -> void:
	call_deferred("_ensure_emotional_layer_controller_singleton")


func _ensure_emotional_layer_controller_singleton() -> Node:
	var controller: Node = get_tree().root.get_node_or_null("EmotionalLayerController")
	if controller != null:
		return controller
	controller = EmotionalLayerControllerScript.new()
	controller.name = "EmotionalLayerController"
	get_tree().root.add_child(controller)
	return controller
