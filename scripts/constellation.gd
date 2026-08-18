extends Node2D

@onready var timer = $Timer
@onready var metronome_tick = $MetronomeTick
@onready var song = $Song

var scene

var note:Node2D
var notes: Array[Node2D]
var notes_total:int = 2

var timing_circle:Node2D
var timing_circles: Array[Node2D]

var chart_active: bool = false
var song_playing: bool = false

var song_length: float = 225.0

var bpm: float = 138 
var subdivision_per_beat: int = 12
var beats_per_bar: int = 4



var countdown = 1
var metronome_counter:int = 0

var seconds_per_beat:float = 60.0/bpm
var seconds_per_subdivision: float = 60.0/bpm/subdivision_per_beat

var song_audio_delay:float = (3 * seconds_per_beat) #seconds
var chart_offset:float = 0.15

var current_beat: int = 0
var current_bar: int = 0
var current_subdivision = 0

var grid_size:Vector2

const center = Vector2(80.5, 45.5)

func init_grid():
	grid_size.x = get_viewport_rect().size.x/160
	grid_size.y = get_viewport_rect().size.y/90

var id_counter: int = 0

var note_scale_max: float = 6.0
var note_scale: float = 6.0 #minimum 4.0, max 6.0


func set_timing_seconds(sub:int)->float:
	return (sub * seconds_per_subdivision)
func set_timing_sub(bar:int, beat:int, sub:int)->float:
	return ((bar+1)*beats_per_bar*subdivision_per_beat + beat*subdivision_per_beat + sub)

func set_note_position(x:float, y:float)->Vector2:
	return Vector2(x*grid_size.x, y*grid_size.y)


func create_note(type: NoteData.Type, hand:NoteData.Hand, pos_coord:Vector2, size_scale:float, bar:int, beat:int, sub:int)->void:
	if (notes.is_empty()) or (notes[-1].type != type):
		match type:
			NoteData.Type.TAP:
				scene = preload("res://scenes/tap.tscn")
			_:
				pass
	note = scene.instantiate()
	note.hand = hand
	note.type = type
	note.pos_coord = pos_coord
	note.position = pos_coord * grid_size
	note.radius = grid_size.y*size_scale
	note.sub = set_timing_sub(bar, beat, sub)
	note.timing = set_timing_seconds(note.sub)
	note.spawn_timing = note.timing - note.preview_dur

	if !notes.is_empty():
		for i in range(notes.size()-1, -1, -1): #this counts n,...3, 2, 1, 0
			var x_dis:float = abs(notes[i].pos_coord.x - note.pos_coord.x)
			var y_dis:float = abs(notes[i].pos_coord.y - note.pos_coord.y)
			if (x_dis < note_scale_max*2) and (y_dis <note_scale_max*2):
				note.blocked_by_id = i
				notes[i].blocks_ids.append(notes.size())
				break
	
	notes.append(note)
	note.z_index = -(notes.size())
	add_child(note)


func _ready() -> void:
	init_grid()
	timer.start(countdown)
	chart_active = true
	
	#scene = preload("res://scenes/note.tscn")
	
	create_note(NoteData.Type.TAP, NoteData.Hand.RIGHT	, Vector2(center.x+18.0		, center.y		), note_scale, 0, 0, 0)
	create_note(NoteData.Type.TAP, NoteData.Hand.LEFT	, Vector2(center.x-18.0		, center.y		), note_scale, 0, 1, 0)
	create_note(NoteData.Type.TAP, NoteData.Hand.RIGHT	, Vector2(center.x+12.0 	, center.y-12.0	), note_scale, 0, 2, 0)
	create_note(NoteData.Type.TAP, NoteData.Hand.LEFT	, Vector2(center.x-12.0 	, center.y-12.0	), note_scale, 0, 3, 0)
	
	scene = preload("res://scenes/timing_circle.tscn")
	for i in notes.size():
		timing_circle = scene.instantiate()
		timing_circle.pos_coord = notes[i].pos_coord
		timing_circle.position = notes[i].position
		timing_circle.radius = notes[i].radius #implcit scale multiply by 8
		timing_circle.sub = notes[i].sub
		timing_circle.timing = set_timing_seconds(timing_circle.sub) - timing_circle.shrink_dur
		timing_circles.append(timing_circle)
		add_child(timing_circle)
		
	
var song_time: float
var next_note_id: int = 0

var notes_id_pool: Array[int]

var spawned_notes_id: Array[int]
var spawned_timing_circles_id: Array[int]

var current_note
var current_note_id:int

var song_started = false
var note_scores:float = 0.0
var spark_score:int = 0

func _process(delta: float) -> void:
	if chart_active:
		if song_playing:
			song_time = song_length - timer.time_left
			while ((song_time) >= (current_subdivision+1)*seconds_per_subdivision):
				if (current_beat == 5) and !song_started:
					song.play(song_audio_delay)
					song_started = true
					
				for i in notes.size():
					if !(i in spawned_notes_id) and (notes[i].spawn_timing) < song_time:
						notes[i].spawn()
						spawned_notes_id.append(i)
				for i in timing_circles.size():
					if !(i in spawned_timing_circles_id) and timing_circles[i].timing < song_time:
						timing_circles[i].spawn()
						spawned_timing_circles_id.append(i)

				if (current_subdivision % subdivision_per_beat == 0):
					if (metronome_counter<4):
						metronome_tick.play()
						metronome_counter += 1
					if (current_beat % beats_per_bar == 0):
							current_bar +=1
					current_beat += 1
				current_subdivision += 1
				
			for i in range(spawned_notes_id.size() -1, -1, -1):
				current_note_id = spawned_notes_id[i] #current note id
				current_note = notes[current_note_id] #this is the note scene instance
				if current_note.state in [current_note.State.HIT, current_note.State.MISS]:

					if current_note.state == current_note.State.HIT:
						current_note.hit()
						var touch_offset = song_time - current_note.timing - chart_offset
						if abs(touch_offset) < 0.06:
							note_scores += 1.0
							if touch_offset > 0.03:
								print("perfect late")
							elif touch_offset < -0.03:
								print("perfect early")
							else:
								spark_score += 1
								print("perfect")
						else:
							if touch_offset > 0:
								note_scores += 0.5
								print("late")
							elif touch_offset < 0:
								note_scores += 0.5
								print("early")
						print((note_scores/notes.size())*100)
					for j in current_note.blocks_ids.size():
						var target_note = notes[current_note.blocks_ids[j]]
						target_note.blocked_by_id = -1
						target_note.activate()
		else:
			while(timer.time_left <= countdown):
				if countdown != 1:
					print("song starts in: " + str(countdown - 1) + "...")
				countdown -= 1
				if countdown == 0:
					pass

func _on_timer_timeout() -> void:
	if !song_playing:
		song_playing = true
		timer.start(song_length)
	else:
		print("song finished")
		song_playing = false
		chart_active = false
		queue_free()
