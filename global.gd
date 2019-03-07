extends Node

# Declare member variables here. Examples:
enum States { initializing, ready, paused }
var State : int = States.initializing

var MainScene : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func pause_game():
	# note. This will stop the phsyics engine and every _process function
	# to keep a node active, set Pause mode in the inspector
	get_tree().paused = true
	# BG Music continues to play. I should probably stop the audioserver.
	
	
func resume_game():
	get_tree().paused = false

func get_state():
	return State

func set_main(node):
	MainScene = node