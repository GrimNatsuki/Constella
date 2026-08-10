extends RefCounted
class_name NoteData

enum NoteType{
	TAP,
	HOLD,
	FLICK,
	CATCH,
	TRACE
}

var id: int = 0
var active: bool = true
var timing: int = 0
var position = Vector2.ZERO
var size:float = 60.0
var scale:float = 1.0
var duration: int = 0
var type: NoteType = NoteType.TAP
