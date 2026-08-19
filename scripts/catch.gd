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

var can_be_blocked = false
var can_block = true
var touched: bool = false
var input_active: bool = true #change to false later
var blocked_by_id:int = -1
var blocks_ids:Array[int]

var sprite_rect:Vector2

func spawn() -> void:
	show()
	activate()
	process_mode = Node.PROCESS_MODE_INHERIT
	timer.start(preview_dur)
	
func activate()->void:
	pass

func load_tex()->void:
	if hand == NoteData.Hand.LEFT:
		active_tex = preload("res://assets/noteSprites/blue_catch_active_01.png")
	else:
		active_tex = preload("res://assets/noteSprites/red_catch_active_01.png")

func _ready() -> void:
	load_tex()
	sprite.texture = active_tex
	sprite_rect = Vector2(256.0, 256.0)
	sprite.scale=Vector2(1/sprite_rect.x,1/sprite_rect.y)*(2.0*radius)
	collision_shape_2d.shape.radius = radius
	hide()
	state = State.VISIBLE_ACTIVE
	#process_mode = Node.PROCESS_MODE_DISABLED


func _process(delta: float) -> void:
	pass
	#if !input_active and !visible:
		#state = State.INVISIBLE_INACTIVE
	#elif !input_active and visible:
		#if touched:
			#state = State.HIT
		#else:
			#state = State.VISIBLE_INACTIVE
	#elif input_active and visible:
		#state = State.VISIBLE_ACTIVE



func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventScreenTouch) or (event is InputEventScreenDrag):
		print("catching")
