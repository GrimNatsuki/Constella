extends Node2D

enum State{
	INVISIBLE_INACTIVE,
	VISIBLE_INACTIVE,
	VISIBLE_ACTIVE,
	HIT,
	MISS
}


@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var timer = $Timer

@onready var sprite = $Sprite2D
var active_tex
var inactive_tex

var time: float

#note properties

var type:NoteData.Type
var hand = NoteData.Hand.RIGHT
var pos_coord:Vector2
var sub: int = 0
var duration: float = 0

var preview_dur:float = 1.0
var hit_window:float = 0.5
var spawn_timing = 0.0
var timing: float = 0.0

var radius: float

#var white = Color(1.0, 1.0, 1.0, 1.0)
#var black = Color(0.0, 0.0, 0.0, 1.0)
#var color:Color

var state

var can_be_blocked = true
var can_block = true
var touched: bool = false
var input_active: bool = false
var blocked_by_id:int = -1
var blocks_ids:Array[int]


var sprite_rect:Vector2


func spawn() -> void:
	show()
	activate()
	process_mode = Node.PROCESS_MODE_INHERIT
	timer.start(preview_dur)

func activate()->void:
	if blocked_by_id < 0:
		input_active = true 
		sprite.texture = active_tex
	else:
		sprite.texture = inactive_tex

func hit()->void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	state = State.INVISIBLE_INACTIVE

func miss()->void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	state = State.MISS

func load_tex()->void:
	if hand == NoteData.Hand.LEFT:
		active_tex = preload("res://assets/noteSprites/blue_tap_active_01.png")
		inactive_tex = preload("res://assets/noteSprites/blue_tap_inactive_01.png")
	else:
		active_tex = preload("res://assets/noteSprites/red_tap_active_01.png")
		inactive_tex = preload("res://assets/noteSprites/red_tap_inactive_01.png")
	
func _ready() -> void:
	load_tex()
	sprite.texture = active_tex
	sprite_rect = Vector2(256.0, 256.0)
	sprite.scale=Vector2(1/sprite_rect.x,1/sprite_rect.y)*(2.0*radius)
	collision_shape_2d.shape.radius = radius
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED

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
			sprite.modulate = Color(0.8, 0.8, 0.8, 1.0)
		State.VISIBLE_ACTIVE:
			sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		State.HIT:
			pass
	if preview:

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
