extends Node2D

@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var timer = $Timer

var touched: bool = false
var active: bool = false
var time: float
var note_preview_dur:float = 1.0
var timing: float
var sub: int

var radius: float
var white = Color(1.0, 1.0, 1.0, 1.0)
var black = Color(0.0, 0.0, 0.0, 1.0)

var color:Color

func _ready() -> void:
	timer.start(note_preview_dur)
	collision_shape_2d.shape.radius = radius
	color = white

func _process(delta: float) -> void:
	time = note_preview_dur - timer.time_left
	queue_redraw()

func _on_draw() -> void:
	draw_circle(Vector2.ZERO, radius, color, true, 0.0, true)
	pass


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		touched = event.pressed
	
func _on_tree_exited() -> void:
	pass


func _on_timer_timeout() -> void:
	#if !active and !touched:
		#active = true
	#elif active and !touched:
		#active = false
	pass
		
