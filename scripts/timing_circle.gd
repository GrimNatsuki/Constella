extends Node2D

@onready var timer = $Timer

var radius: float
var color = Color(1.0, 1.0, 1.0, 1.0)
var thickness = 10.0
var _scale = 8.0

var timing: float = 0.0
var sub: int = 0
var pos_coord:Vector2
var note_type = NoteData.Type.TRACE

var shrink_dur = 1.0
var peak:float = 0.8
var shrinking_rad = radius

func spawn() -> void:
	show()
	process_mode = Node.PROCESS_MODE_INHERIT
	timer.start(shrink_dur)
func despawn() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	pass 
	
var progress:float = 1.0
var time: float

func _process(delta: float) -> void:
	if progress == 0.0:
		despawn()
	
	time = shrink_dur - timer.time_left
	progress = timer.time_left/shrink_dur
	shrinking_rad = _scale*radius*progress	+ (radius) + (thickness/2.0)
	queue_redraw()



func _on_draw() -> void:

	#if time<peak:
		#color.a = time/peak
	#draw_circle(Vector2.ZERO, radius*(timer.time_left + 1), color, false, thickness, true)
	draw_circle(Vector2.ZERO, shrinking_rad, color, false, thickness, true)
	pass


func _on_timer_timeout() -> void:
	pass
