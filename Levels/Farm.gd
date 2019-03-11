extends Node2D


func _ready():
	pass # Replace with function body.

func start():
	print(self.name, " level started.")
	global.current_level = self

func end():
	# all the cleanup stuff. remove things as necessary
	pass
