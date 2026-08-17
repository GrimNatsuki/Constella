extends RefCounted
class_name NoteData

enum Type{
	TAP,
	HOLD,
	FLICK,
	CATCH,
	TRACE
}

var position = Vector2.ZERO
var scale:float = 1.0
var bar:int = 0
var beat:int = 0
var sub: int = 0
var duration: int = 0
var type: Type = Type.TAP
