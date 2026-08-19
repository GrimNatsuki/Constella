extends Node

var event_index
var touch_id:Array[int]
var touch_pos:Array[Vector2]

func _ready() -> void:
	touch_pos.resize(10)
	pass


func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch) or (event is InputEventScreenDrag):
		if (event is InputEventScreenTouch):
			event_index = event.index
			
			pass
		
		for i in range(10):
			if i == event.index:
				touch_pos[i] = event.position
		#print(touch_pos[0])
	pass
