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

var song_length: float = 20
var bpm: float = 138 
var subdivision_per_beat: int = 12
var beats_per_bar: int = 4
var countdown = 3

var seconds_per_beat:float = 60.0/bpm
var seconds_per_subdivision: float = 60.0/bpm/subdivision_per_beat

var current_beat: int = 0
var current_bar: int = 0
var current_subdivision = 0

var grid_size:Vector2

const center = Vector2(40.5, 30.0)

func init_grid():
	grid_size.x = get_viewport_rect().size.x/80
	grid_size.y = get_viewport_rect().size.y/60

var id_counter: int = 0

func set_note_id():
	note_data.id = id_counter
	id_counter +=1

var note_scale: float = 4.0 #minimum 2.0, max 4.0

func set_note_timing(bar:int, beat:int, sub:int)->float:
	note.sub = bar*beats_per_bar*subdivision_per_beat +beat*subdivision_per_beat + sub
	return (note.sub * seconds_per_subdivision)

func set_note_position(x:float, y:float)->Vector2:
	return Vector2(x*grid_size.x, y*grid_size.y)

func create_note(x: float, y:float, size_scale:float, bar:int, beat:int, sub:int)->void:
	note = scene.instantiate()
	note.pos_coord = Vector2(x, y)
	note.position = Vector2(x*grid_size.x, y*grid_size.y)
	note.radius = grid_size.y*size_scale
	note.timing = set_note_timing(bar, beat, sub)

	if !notes.is_empty():
		for i in range(notes.size()-1, -1, -1): #this counts n,...3, 2, 1, 0
			var x_dis:float = abs(notes[i].pos_coord.x - note.pos_coord.x)
			var y_dis:float = abs(notes[i].pos_coord.y - note.pos_coord.y)
			if (x_dis < 8.0) and (y_dis <8.0):
				note.blocked_by_id = i
				notes[i].blocks_ids.append(notes.size())
	notes.append(note)
	note.z_index = -(notes.size())
	add_child(note)

func _ready() -> void:
	init_grid()
	timer.start(countdown)
	chart_active = true
	
	scene = preload("res://scenes/note.tscn")
	
	create_note(center.x		, center.y			, note_scale, 0, 0, 0)
	create_note(center.x+8.0 	, center.y-8.0		, note_scale, 0, 0, 0)
	
	create_note(center.x 		, center.y-4.0		, note_scale, 0, 1, 0)
	create_note(center.x+8.0 	, center.y-4.0		, note_scale, 0, 1, 0)
	
	create_note(center.x 		, center.y-8.0		, note_scale, 0, 2, 0)
	create_note(center.x+8.0 	, center.y			, note_scale, 0, 2, 0)

	print("chart start...")
	print("song starting soon...")
	
var song_time: float
var next_note_id: int = 0

var notes_id_pool: Array[int]

var spawned_notes_id: Array[int]

var current_note
var current_note_id:int

func _process(delta: float) -> void:
	if chart_active:
		if song_playing:
			song_time = song_length - timer.time_left
			while ((song_time) >= (current_subdivision+1)*seconds_per_subdivision):
				while next_note_id < notes.size() and notes[next_note_id].timing <= song_time:
					notes[next_note_id].spawn()
					spawned_notes_id.append(next_note_id)
					next_note_id += 1
				current_subdivision += 1
				if (current_subdivision % subdivision_per_beat == 0):
					current_beat += 1
					if (current_beat % beats_per_bar == 0):
						current_bar +=1
						
			for i in range(spawned_notes_id.size() -1, -1, -1):
				current_note_id = spawned_notes_id[i] #current note id
				current_note = notes[current_note_id] #this is the note scene instance
				if current_note.state == current_note.State.HIT:
					current_note.hit()
					for j in current_note.blocks_ids.size():
						notes[current_note.blocks_ids[j]].blocked_by_id = -1
					
		else:
			while(timer.time_left <= countdown):
				if countdown != 1:
					print("song starts in: " + str(countdown - 1) + "...")
				countdown -= 1
				if countdown == 0:
					print("song start")
					

				#current_note.active = false
				
	#for i in notes.size():
		#if !notes[i].touched:
			#for j in notes.size():
				#if i == notes[j].blocked_by_id:
					#notes[j].blocked_by_id = -1
	
		
func _on_timer_timeout() -> void:
	if !song_playing:
		song_playing = true
		timer.start(song_length)
	else:
		print("song finished")
		song_playing = false
		chart_active = false
		queue_free()
