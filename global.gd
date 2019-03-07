extends Node

# Declare member variables here. Examples:
enum States { initializing, ready, paused }
var State : int = States.initializing

enum Difficulties { easy, medium, hard }
var Difficulty : int = Difficulties.medium

var Game_Speed = 1.0

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

func set_difficulty(difficulty: int):
	Difficulty = difficulty

func get_difficult():
	return Difficulty

func get_state():
	return State

func get_game_speed():
	return Game_Speed
	
func set_game_speed(speed):
	Game_Speed = speed

func set_main(node):
	MainScene = node