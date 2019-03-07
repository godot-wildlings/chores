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

onready var LevelContainer = $LevelContainer
var LevelScenes = [ "res://Levels/Level1.tscn", "res://Levels/Level2.tscn" ]
var Level_Num : int = -1
#var Current_Level_Node

signal DialogBox_completed(box_name)

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_dialog_box("IntroText", ["Welcome to GWJ7", "Have Fun"], self)
	global.set_main(self)
	transition("fade-in")


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
	PauseLabel.set_text("PAUSED. Press esc to resume.")
	
	Music_Last_Playback_Position = BGMusic.get_playback_position()
	BGMusic.stop()

#	BGMusic.set_stream_paused(true)
	global.pause_game()

func hide_pause_menu():
	find_node("PauseMenu").hide()
	global.resume_game()
	PauseLabel.set_text("Press esc to Pause Game.")
#	BGMusic.set_stream_paused(false)
	BGMusic.play()
	BGMusic.seek(Music_Last_Playback_Position)

func start_game():
	set_state(States.playing)
	$BGMusic.play()
	start_next_level()


func transition(animation_name):
	$AnimationPlayer.play(animation_name)


	
	


func start_next_level():
	# Need to add fade out and fade in

	transition("fade-out")
	yield(get_tree().create_timer(0.5), "timeout")
	
	if Current_Level_Node != null:
		if Current_Level_Node.has_method("end"):
			Current_Level_Node.end() # levels should free themselves
		else:
			Current_Level_Node.queue_free()
		
	Level_Num = wrapi(Level_Num+1, 0, LevelScenes.size())
	
	var current_level_scene = load(LevelScenes[Level_Num])
	Current_Level_Node = current_level_scene.instance()
	LevelContainer.add_child(Current_Level_Node)
	
	if Current_Level_Node.has_method("start"):
		Current_Level_Node.start()

	transition("fade-in")
	yield(get_tree().create_timer(0.5), "timeout")
		
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
	
	if event.is_action_pressed("next_level"):
		start_next_level()
	
func _on_DialogBox_completed(dialog_box_title, requesting_node):
	if dialog_box_title == "IntroText":
		start_game()

	# other nodes may need dialog boxes, they'll ask Main for one, then expect a callback
	elif requesting_node != self:
		var _err = connect("DialogBox_completed", requesting_node, "_on_BialogBox_completed")
		if _err: push_warning(_err)
		emit_signal("DialogBox_completed", dialog_box_title)
		disconnect("DialogBox_completed", requesting_node, "_on_BialogBox_completed")
