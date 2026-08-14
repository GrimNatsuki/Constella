extends Node2D

enum State{
	INVISIBLE_INACTIVE, #invisible, no touch inputs
	VISIBLE_INACTIVE, #visible, not in the timing window yet (preview_dur), blocked by other notes, no touch
	VISIBLE_ACTIVE, #visible, can be touched, no blocking notes
	HIT #already hit, might still be visible e.g. hit fx, no touch inputs, can't block other notes
}

@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var timer = $Timer

var time: float

var note_preview_dur:float = 1.0

var timing: float = 0.0
var sub: int = 0
var pos_coord:Vector2
var note_type = NoteData.NoteType.TAP

var radius: float = 1.0

var white = Color(1.0, 1.0, 1.0, 1.0)
var black = Color(0.0, 0.0, 0.0, 1.0)
var color:Color

var state 

var touched: bool = false
var input_active: bool = false
var blocked_by_id:int = -1
var blocks_ids:Array[int]

func spawn() -> void:
	show()
	activate()

func activate()->void:
	if blocked_by_id < 0:
		input_active = true

func hit()->void:
	hide()
	print("hit")

func _ready() -> void:
	hide()
	timer.start(note_preview_dur)
	collision_shape_2d.shape.radius = radius
var one_shot_bool = true

func _process(delta: float) -> void:
	time = note_preview_dur - timer.time_left
	
	if !input_active and !visible:
		state = State.INVISIBLE_INACTIVE
	elif !input_active and visible:
		if touched:
			state = State.HIT
		else:
			state = State.VISIBLE_INACTIVE
	elif input_active and visible:
		state = State.VISIBLE_ACTIVE
	
	if blocked_by_id<0 and !touched:
		input_active = true
	else:
		input_active = false
		
	match state:
		State.INVISIBLE_INACTIVE:
			pass
		State.VISIBLE_INACTIVE:
			color = black
		State.VISIBLE_ACTIVE:
			color = white
		State.HIT:
			pass
			#print("note is hit")
	
	queue_redraw()

func _on_draw() -> void:
	draw_circle(Vector2.ZERO, radius, color, true, 0.0, true)
	pass

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventScreenTouch):
		if event.pressed and (state == State.VISIBLE_ACTIVE):
			touched = event.pressed
			#hide()
			#set_process(false)

func _on_tree_exited() -> void:
	pass

func _on_timer_timeout() -> void:
	#if !active and !touched:
		#active = true
	#elif active and !touched:
		#active = false
	pass
