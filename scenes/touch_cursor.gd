extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	pass


func _on_draw() -> void:
	draw_circle(Vector2.ZERO, 72.0, Color(1.0, 1.0,1.0, 1.0), false, 5.0, true)
