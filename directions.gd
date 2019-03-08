extends Node

const CENTER = Vector2(0, 0)
const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)
const UP = Vector2(0, -1)
const DOWN = Vector2(0, 1)

func rand():
	var d = randi() % 4
	match d:
		0:
			return LEFT
		1:
			return RIGHT
		2:
			return UP
		3:
			return DOWN