# utility scripts
extends Node

func rand_dir():
	var d = randi() % 4
	match d:
		0:
			return Vector2.LEFT
		1:
			return Vector2.RIGHT
		2:
			return Vector2.UP
		3:
			return Vector2.DOWN
			
func rand_dir_float():
	var d = randf() * 2 * PI
	return Vector2(1, 0).rotated(d)