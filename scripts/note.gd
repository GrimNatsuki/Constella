extends Node2D

enum State{
	INVISIBLE_INACTIVE, #invisible, no touch inputs
	VISIBLE_INACTIVE, #visible, not in the timing window yet (preview_dur), blocked by other notes, no touch
	VISIBLE_ACTIVE, #visible, can be touched, no blocking notes
	HIT, #already hit, might still be visible e.g. hit fx, no touch inputs, can't block other notes
	MISS
}

@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var timer = $Timer
@onready var sprite = $Sprite2D

var time: float

#note properties
var preview_dur:float = 1.0
var hit_window:float = 0.5
var spawn_timing = 0.0
var timing: float = 0.0
var sub: int = 0
var pos_coord:Vector2
var note_type = NoteData.NoteType.TAP
var radius: float

var white = Color(1.0, 1.0, 1.0, 1.0)
var black = Color(0.0, 0.0, 0.0, 1.0)
var color:Color

var state

var touched: bool = false
var input_active: bool = false
var blocked_by_id:int = -1
var blocks_ids:Array[int]
var hit_time: float

var sprite_rect:Vector2

func spawn() -> void:
	show()
	activate()
	process_mode = Node.PROCESS_MODE_INHERIT
	timer.start(preview_dur)

func activate()->void:
	if blocked_by_id < 0:
		input_active = true 

func hit()->void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	state = State.INVISIBLE_INACTIVE

func miss()->void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	state = State.MISS
	
func _ready() -> void:
	sprite_rect = sprite.get_rect().size
	print(str(sprite_rect.x) +", " +str(sprite_rect.y))
	sprite.scale=Vector2(1/sprite_rect.x,1/sprite_rect.y)*(2.0*radius)
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	collision_shape_2d.shape.radius = radius
		
var preview:bool = true

func _process(delta: float) -> void:
	
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
			color.r = 0.0
			color.g = 0.0
			color.b = 0.0
		State.VISIBLE_ACTIVE:
			color.r = 1.0
			color.g = 1.0
			color.b = 1.0
		State.HIT:
			pass
	if preview:
		color.a = 1.0 - timer.time_left/preview_dur
		sprite.modulate.a = 1.0 - timer.time_left/preview_dur
	else:
		pass
	queue_redraw()

func _on_draw() -> void:
	#draw_circle(Vector2.ZERO, radius, color, true, 0.0, true)
	pass

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventScreenTouch):
		if event.pressed and (state == State.VISIBLE_ACTIVE):
			touched = event.pressed

func _on_tree_exited() -> void:
	pass

func _on_timer_timeout() -> void:
	if preview:
		timer.start(hit_window)
		preview = false
	else:
		miss()
	pass
