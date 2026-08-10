@tool
extends Node2D

@onready var collision_shape_2d = $Area2D/CollisionShape2D

var touched: bool = false
var active: bool = true

var radius: float = 60
const white = Color(1.0, 1.0, 1.0, 1.0)

func _ready() -> void:
	collision_shape_2d.shape.radius = radius

func _process(delta: float) -> void:
	pass

func _on_draw() -> void:
	draw_circle(Vector2.ZERO, radius, white, true, 0.0, true)
	pass


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		touched = event.pressed
