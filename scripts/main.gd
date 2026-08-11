extends Node2D


var scene = preload("res://scenes/constellation.tscn")
var constellation = scene.instantiate()

func _ready() -> void:
	add_child(constellation)
	constellation.position = Vector2.ZERO
	pass

func _process(delta: float) -> void:
	pass
