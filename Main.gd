extends Node
"""
Main.gd is the default scene. 

Responsibilities:
-add and remove scenes
-relay messages between sibling children

"""

# Declare member variables here. Examples:
signal Dialog_box_completed(box_name)

onready var dialog_box_container : Control = $GUIContainer/FullRect/CenterContainer/DialogBoxes
onready var level_container : Node2D = $LevelContainer
onready var pause_label : Label = $GUIContainer/FullRect/PauseLabel
onready var dialog_box : PackedScene = preload("res://GUI/DialogBox.tscn")

enum States { INITIALIZING, PLAYING, PAUSED }

var first_scene : String = "res://Levels/InteriorCottageStart.tscn"

var _state : int = States.INITIALIZING setget _set_state
var current_level_node : Node

func _ready():
	
	global.main_scene = self
	transition("fade-in")
	load_level(first_scene)
	

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
	global.pause_game()

func hide_pause_menu():
	find_node("PauseMenu").hide()
	global.resume_game()
	pause_label.set_text("Press esc to Pause Game.")

#func start_game():
#	self._state = States.PLAYING

func transition(animation_name : String):
	$AnimationPlayer.play(animation_name)


func load_level(level_path : String):
	var level_scene = load(level_path)
	print(self.name, " loading ", level_scene)
	transition("fade-out")
	yield(get_tree().create_timer(0.5), "timeout")
	
	if current_level_node != null:
		if current_level_node.has_method("end"):
			current_level_node.end() # levels should free themselves
		else:
			current_level_node.queue_free()
		
	current_level_node = level_scene.instance()
	level_container.add_child(current_level_node)
	
	if current_level_node.has_method("start"):
		current_level_node.start()

	transition("fade-in")
	yield(get_tree().create_timer(0.5), "timeout")

	
func _on_level_requested(level_path : String):
	load_level(level_path)

func _on_level_initialized():
	_set_state(States.PLAYING)

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


func _on_DialogBox_completed(dialog_box_title : String, requesting_node : Node):
	# other nodes will expect a callback when their dialog box is done
	if requesting_node != self:
		var _err = connect("Dialog_box_completed", requesting_node, "_on_DialogBox_completed")
		if _err: push_warning(_err)
		emit_signal("Dialog_box_completed", dialog_box_title)
		disconnect("Dialog_box_completed", requesting_node, "_on_DialogBox_completed")

func _on_DialogBox_requested(dialog_box_title : String, text_array : Array, requested_by ):
		spawn_dialog_box(dialog_box_title, text_array, requested_by)
		
