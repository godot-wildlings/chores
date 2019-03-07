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


func get_state():
	return State

func set_main(node):
	MainScene = node