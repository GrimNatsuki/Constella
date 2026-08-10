extends Node2D

@onready var timer = $Timer

var radius: float
var color = Color(1.0, 1.0, 1.0, 1.0)
var thickness = 5.0

var timer_duration = 1.0
var peak:float = 0.8
func _ready() -> void:
	timer.start(timer_duration)
	pass 


func _process(delta: float) -> void:
	queue_redraw()

var time: float

func _on_draw() -> void:
	time = timer_duration - timer.time_left
	if time<peak:
		color.a = time/peak
	draw_circle(Vector2.ZERO, radius*(timer.time_left + 1), color, false, thickness, true)
	pass


func _on_timer_timeout() -> void:
	print("timeout")
