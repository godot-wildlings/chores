"""
Main.gd is the default scene. 

Responsibilities:
-add and remove scenes
-relay messages between sibling children

"""


extends Node

# Declare member variables here. Examples:
onready var global = get_node("/root/global")
onready var BGMusic = get_node("BGMusic")
var Music_Last_Playback_Position : float = 0.0

onready var PauseLabel = get_node("GUIContainer/FullRect/PauseLabel")

var DialogBox = preload("res://GUI/DialogBox.tscn")
onready var DialogBoxContainer = get_node("GUIContainer/FullRect/CenterContainer/DialogBoxes")

enum States { initializing, playing, paused }
var State = States.initializing



signal DialogBox_completed(box_name)

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_dialog_box("IntroText", ["Welcome to GWJ7", "Have Fun"], self)
	global.set_main(self)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_state(state):
	State = state

func spawn_dialog_box(boxTitle : String, textArray : Array, requestedBy):
	var newDialogBox = DialogBox.instance()
	DialogBoxContainer.add_child(newDialogBox)
	newDialogBox.start(boxTitle, textArray, self, requestedBy)
		# note: the order is important. Must add_child() before you can start()

func show_pause_menu():
	find_node("PauseMenu").show()
	PauseLabel.set_text("PAUSED")
	
	Music_Last_Playback_Position = BGMusic.get_playback_position()
	BGMusic.stop()

#	BGMusic.set_stream_paused(true)
	global.pause_game()

func hide_pause_menu():
	find_node("PauseMenu").hide()
	global.resume_game()
	PauseLabel.set_text("Press esc to Pause Game")
#	BGMusic.set_stream_paused(false)
	BGMusic.play()
	BGMusic.seek(Music_Last_Playback_Position)

func start_game():
	set_state(States.playing)
	$BGMusic.play()
	
		
func _input(event):
	if State == States.playing:
		if event.is_action_pressed("pause"):
			show_pause_menu()
			set_state(States.paused)
			global.pause_game()
	elif State == States.paused:
		if event.is_action_pressed("pause"):
			hide_pause_menu()
			set_state(States.playing)
			global.resume_game()
			
	
func _on_DialogBox_completed(dialog_box_title, requesting_node):
	if dialog_box_title == "IntroText":
		start_game()

	# other nodes may need dialog boxes, they'll ask Main for one, then expect a callback
	elif requesting_node != self:
		var _err = connect("DialogBox_completed", requesting_node, "_on_BialogBox_completed")
		if _err: push_warning(_err)
		emit_signal("DialogBox_completed", dialog_box_title)
		disconnect("DialogBox_completed", requesting_node, "_on_BialogBox_completed")
