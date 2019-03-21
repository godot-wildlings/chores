extends Node

enum States { INITIALIZING, READY, PAUSED }
enum Difficulties { EASY, MEDIUM, HARD }

var options : Dictionary = { 
		"projectiles_add_initial_velocity" : true,
		"arrow_speed" : 1000
	}

var _state : int = States.INITIALIZING setget _set_state
#warning-ignore:unused_class_variable
var difficulty : int = Difficulties.MEDIUM
#warning-ignore:unused_class_variable
var game_speed : float = 1.0
#warning-ignore:unused_class_variable
var main_scene : Node
#warning-ignore:unused_class_variable
var current_level : Node2D
#warning-ignore:unused_class_variable
var DEBUG : bool = false

#warning-ignore:unused_class_variable
var player : KinematicBody2D

func _set_state(new_state : int):
	_state = new_state
	# note: in order for this setter to be called, it's not enough to do
	# _state = value, instead you have to call self._state = value

func pause_game():
	# note. This will stop the phsyics engine and every _process function
	# to keep a node active, set Pause mode in the inspector
	get_tree().paused = true
	# BG Music continues to play. I should probably stop the audioserver.
	
func resume_game():
	get_tree().paused = false