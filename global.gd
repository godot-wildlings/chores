extends Node

enum States { INITIALIZING, READY, PAUSED }
enum Difficulties { EASY, MEDIUM, HARD }

# Declare member variables here. Examples:
var _state : int = States.INITIALIZING setget _set_state
var difficulty : int = Difficulties.MEDIUM
var game_speed : float = 1.0
var main_scene : Node

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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