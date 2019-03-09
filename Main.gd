extends Node
"""
Main.gd is the default scene. 

Responsibilities:
-add and remove scenes
-relay messages between sibling children

"""

# Declare member variables here. Examples:
signal Dialog_box_completed(box_name)

onready var bg_music : AudioStreamPlayer = $BGMusic
onready var dialog_box_container : Control = $GUIContainer/FullRect/CenterContainer/DialogBoxes
onready var level_container : Node2D = $LevelContainer
onready var pause_label : Label = $GUIContainer/FullRect/PauseLabel
onready var dialog_box : PackedScene = preload("res://GUI/DialogBox.tscn")

enum States { INITIALIZING, PLAYING, PAUSED }

var _state : int = States.INITIALIZING setget _set_state
var music_last_playback_position : float = 0.0
var level_scenes : Array = []
var level_num : int = -1
var current_level_node : Node

func _ready():
	
	level_scenes.push_back("res://Levels/Level4.tscn")
	level_scenes.push_back("res://Levels/Level1.tscn")
	level_scenes.push_back("res://Levels/Level2.tscn")
	level_scenes.push_back("res://Levels/Level3.tscn")
	
	var intro_text = [
			"You're a good boy, Friederich. You do your chores and complete your studies. \n\nGo see what your grandparents have for you today. \n\nI've gone to town.\n\tLove, Mother"
	]
	spawn_dialog_box("IntroText", intro_text, self)
	global.main_scene = self
	transition("fade-in")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _set_state(new_state : int):
	_state = new_state
	# could check here whether or not the state was actually changed,
	# and then react on state change (emit signal e.g.)

func spawn_dialog_box(boxTitle : String, textArray : Array, requested_by):
	var new_dialog_box = dialog_box.instance()
	dialog_box_container.add_child(new_dialog_box)
	new_dialog_box.start(boxTitle, textArray, self, requested_by)
		# note: the order is important. Must add_child() before you can start()

func show_pause_menu():
	find_node("PauseMenu").show()
	pause_label.set_text("PAUSED. Press esc to resume.")
	
	music_last_playback_position = bg_music.get_playback_position()
	#bg_music.stop()

#	bg_music.set_stream_PAUSED(true)
	global.pause_game()

func hide_pause_menu():
	find_node("PauseMenu").hide()
	global.resume_game()
	pause_label.set_text("Press esc to Pause Game.")
#	bg_music.set_stream_PAUSED(false)
	#bg_music.play()
	bg_music.seek(music_last_playback_position)

func start_game():
	self._state = States.PLAYING
	bg_music.play()
	start_next_level()

func transition(animation_name : String):
	$AnimationPlayer.play(animation_name)

func start_next_level():
	# Need to add fade out and fade in

	transition("fade-out")
	yield(get_tree().create_timer(0.5), "timeout")
	
	if current_level_node != null:
		if current_level_node.has_method("end"):
			current_level_node.end() # levels should free themselves
		else:
			current_level_node.queue_free()
		
	level_num = wrapi(level_num+1, 0, level_scenes.size())
	
	var current_level_scene = load(level_scenes[level_num])
	current_level_node = current_level_scene.instance()
	level_container.add_child(current_level_node)
	
	if current_level_node.has_method("start"):
		current_level_node.start()

	transition("fade-in")
	yield(get_tree().create_timer(0.5), "timeout")

func _input(event : InputEvent):
	if _state == States.PLAYING:
		if event.is_action_pressed("pause"):
			show_pause_menu()
			_set_state(States.PAUSED)
			global.pause_game()
	elif _state == States.PAUSED:
		if event.is_action_pressed("pause"):
			hide_pause_menu()
			_set_state(States.PLAYING)
			global.resume_game()
	
	if event.is_action_pressed("next_level"):
		start_next_level()
	
func _on_DialogBox_completed(dialog_box_title : String, requesting_node : Node):
	if dialog_box_title == "IntroText":
		start_game()

	# other nodes may need dialog boxes, they'll ask Main for one, then expect a callback
	elif requesting_node != self:
		var _err = connect("Dialog_box_completed", requesting_node, "_on_DialogBox_completed")
		if _err: push_warning(_err)
		emit_signal("Dialog_box_completed", dialog_box_title)
		disconnect("Dialog_box_completed", requesting_node, "_on_DialogBox_completed")

func _on_DialogBox_requested(dialog_box_title : String, text_array : Array, requested_by ):
		spawn_dialog_box(dialog_box_title, text_array, requested_by)
		
