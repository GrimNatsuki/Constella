extends Node2D

@onready var timer = $Timer
var scene
var note_data = NoteData.new()

var note:Node2D
var notes: Array[Node2D]
var notes_total:int = 2

var timing_circle

var chart_active: bool = false
var song_playing: bool = false

var song_length: float = 8
var bpm: float = 138 
var subdivision_per_beat: int = 12
var beats_per_bar: int = 4
var countdown = 4

var seconds_per_beat:float = 60.0/bpm
var seconds_per_subdivision: float = 60.0/bpm/subdivision_per_beat

var current_beat: int = 0
var current_bar: int = 0
var current_subdivision = 0

var grid_size:Vector2

func init_grid():
	grid_size.x = get_viewport_rect().size.x/80
	grid_size.y = get_viewport_rect().size.y/45

var id_counter: int = 0

func set_note_id():
	note_data.id = id_counter
	id_counter +=1

#func activate_note():
	#note_data.active = true	

#func set_note_timing(timing:int):
	#note_data.timing = timing
#func set_note_pos(x:float, y:float):
	#note_data.position = Vector2(x*grid_size.x, y*grid_size.y)
#func set_note_scale(scale:int):
	#note_data.scale = scale
#func set_note_duration(duration:int):
	#note_data.duration = duration
#func set_note_type(note:Node2D):
	#note_data.type = NoteData.NoteType
#func set_note_data(note:Node2D):
	#note.position = note_data.position
#func spawn_note(note_data:NoteData):
	#pass


var note_scale: float = 4.0

func set_note_timing(bar:int, beat:int, sub:int)->float:
	note.sub = bar*beats_per_bar*subdivision_per_beat +beat*subdivision_per_beat + sub
	return (note.sub * seconds_per_subdivision)

func set_note_position(x:float, y:float)->Vector2:
	return Vector2(x*grid_size.x, y*grid_size.y)

func _ready() -> void:
	init_grid()
	
	timer.start(countdown)
	chart_active = true
	
	scene = preload("res://scenes/note.tscn")
	
	#for i in range(notes.size()):
		#pass
	
	#scene = preload("res://scenes/timing_circle.tscn")
	#timing_circle = scene.instantiate()
	
	#instance 0
	note = scene.instantiate()
	note.position = set_note_position(40.5, 23.0)
	note.radius = grid_size.y*note_scale
	note.timing = set_note_timing(0, 0, 0)
	notes.append(note)
	print(notes[0].timing)
	print(notes[0])
	
	#instance 1
	note = scene.instantiate()
	note.position = set_note_position(20.0, 23.0)
	note.radius = grid_size.y*note_scale
	note.timing = set_note_timing(0, 1, 0)
	notes.append(note)

	#instance 2 
	note = scene.instantiate()
	note.position = set_note_position(40.5, 23.0)
	note.radius = grid_size.y*note_scale
	note.timing = set_note_timing(0, 2, 0)
	notes.append(note)
	
	#instance 3
	note = scene.instantiate()
	note.position = set_note_position(60, 23.0)
	note.radius = grid_size.y*note_scale
	note.timing = set_note_timing(0, 3, 0)
	notes.append(note)
	
	#instance 4
	note = scene.instantiate()
	note.position = set_note_position(40.5, 23.0)
	note.radius = grid_size.y*note_scale
	note.timing = set_note_timing(0, 3, 6)
	notes.append(note)
	
	#set_note_data(timing_circle)
	#timing_circle.radius = note.radius
	#add_child(timing_circle)
	print("chart start...")
	print("song starting soon...")
	
var song_time: float
var next_note_spawn_index: int = 0
var note_earliest_active_index: int = 0

var active_notes_id: Array[int]

func _process(delta: float) -> void:
	if chart_active:
		#while note_earliest_active_index < notes.size() and notes[note_earliest_active_index].touched:
			#remove_child(notes[note_earliest_active_index])
			#notes[note_earliest_active_index].active = false
			#note_earliest_active_index += 1
		for i in range(active_notes_id.size() -1, -1, -1):
			if notes[active_notes_id[i]].touched:
				remove_child(notes[active_notes_id[i]])
				notes[active_notes_id[i]].active = false
				active_notes_id.erase(active_notes_id[i])
		
		if song_playing:
			song_time = song_length - timer.time_left
			while ((song_time) >= (current_subdivision+1)*seconds_per_subdivision):
				#print(str(current_bar)+ " : " + str(current_beat) + " : " + str(current_subdivision))
				while next_note_spawn_index < notes.size() and notes[next_note_spawn_index].timing <= song_time:
					notes[next_note_spawn_index].active = true
					add_child(notes[next_note_spawn_index])
					active_notes_id.append(next_note_spawn_index)
					next_note_spawn_index += 1
					
				current_subdivision += 1
				if (current_subdivision % subdivision_per_beat == 0):
					current_beat += 1
					if (current_beat % beats_per_bar == 0):
						current_bar +=1
		else:
			while(timer.time_left <= countdown):
				if countdown != 1:
					print("song starts in: " + str(countdown - 1) + "...")
				countdown -= 1
				if countdown == 0:
					print("song start")

func _on_timer_timeout() -> void:
	if !song_playing:
		song_playing = true
		timer.start(song_length)
	else:
		print("song finished")
		song_playing = false
		chart_active = false
		queue_free()
