extends Node2D

signal level_initialized


func _ready():
	pass # Replace with function body.

func start():
	print(self.name, " level started.")
	global.current_level = self
	
	connect("level_initialized", global.main_scene, "_on_level_initialized")	
	emit_signal("level_initialized")
	disconnect("level_initialized", global.main_scene, "_on_level_initialized")	
	
	
func end():
	# all the cleanup stuff. remove things as necessary
	queue_free()
