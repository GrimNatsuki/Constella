extends Node2D


var scene
var constellation

var touch_id:Array[int]
const MAX_CURSOR:int = 10
var cursor:Node2D
var cursors:Array[Node2D]
var touch_pos:Array[Vector2]


func _ready() -> void:
	scene = preload("res://scenes/touch_cursor.tscn")
	for i in range(MAX_CURSOR):
		cursor = scene.instantiate()
		add_child(cursor)
		cursors.append(cursor)
		pass
	
	scene = preload("res://scenes/constellation.tscn")
	constellation = scene.instantiate()
	add_child(constellation)
	constellation.position = Vector2.ZERO
	pass

func _process(delta: float) -> void:
	pass


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventScreenTouch) or (event is InputEventScreenDrag):
		if (event is InputEventScreenTouch):
			if event.pressed:
				cursors[event.index].show()
			else:
				cursors[event.index].hide()
			if touch_id.size() > 0:
				print(touch_id)
			pass
		
		if (event is InputEventScreenDrag):
			if event.index == 1:
				#print(event.position)
				pass
		for i in cursors.size():
			if i == event.index:
				cursors[i].position = event.position
	pass
