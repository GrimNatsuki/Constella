@tool
extends Node2D

@onready var timer = $Timer
var scene
var note_data = NoteData.new()

var note

var timing_circle

var chart_active: bool = false
var song_playing: bool = false

var song_length: float = 8
var bpm: float = 120 
var subdivision_per_beat: int = 8
var beats_per_bar: int = 4
var countdown = 3

var seconds_per_beat:float = 60.0/bpm
var seconds_per_subdivision: float = 60.0/bpm/subdivision_per_beat

var current_beat: int = 0
var current_bar: int = 0
var current_subdivision = 0

var note_timings = [7, 15, 23, 31]

var grid_size:Vector2

func set_note_pos(x:float, y:float):
	note_data.position = Vector2(x*grid_size.x, y*grid_size.y)
	
func set_note_size(size:int):
	note_data.size = size

func set_note_data(note:Node2D):
	note.position = note_data.position

func init_grid():
	grid_size.x = get_viewport_rect().size.x/80
	grid_size.y = get_viewport_rect().size.y/45
	
func spawn_note(note_data:NoteData):
	pass

func _ready() -> void:
	
	
	init_grid()
	
	timer.start(countdown)
	chart_active = true
	scene = preload("res://scenes/note.tscn")
	note = scene.instantiate()
	scene = preload("res://scenes/timing_circle.tscn")
	timing_circle = scene.instantiate()
	
	set_note_pos(40.5, 23)
	set_note_data(note)
	add_child(note)
	
	set_note_data(timing_circle)
	timing_circle.radius = note.radius
	add_child(timing_circle)
	

func _process(delta: float) -> void:
	if chart_active:
		if song_playing:
			while ((song_length - timer.time_left) >= (current_subdivision+1)*seconds_per_subdivision):
				if note.touched:
					print(song_length - timer.time_left)
				if current_subdivision in note_timings:
					#print(str(current_bar)+ " : " + str(current_beat) + " : " + str(current_subdivision))
					pass
				current_subdivision += 1
				if (current_subdivision % subdivision_per_beat == 0):
					current_beat += 1
					if (current_beat % beats_per_bar == 0):
						current_bar +=1
		else:
			while(timer.time_left <= countdown):
				print("Song starts in: " + str(countdown) + "...")
				countdown -= 1		
			
func _on_timer_timeout() -> void:
	print("timeout")
	if !song_playing:
		song_playing = true
		timer.start(song_length)
	else:
		song_playing = false
		chart_active = false
