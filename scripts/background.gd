extends CanvasLayer
@onready var background_img = $BackgroundImg


var background_tex = preload("res://assets/bad_apple_bg.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	background_img.texture = background_tex
	background_img.modulate = Color(0.5, 0.5, 0.5, 1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
