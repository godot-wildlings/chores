extends Node2D

signal level_initialized

func start():
	print(self.name, " level started.")
	global.current_level = self
	global.player = $Player
	
	connect("level_initialized", global.main_scene, "_on_level_initialized")
	connect_NPC_listeners()
	emit_signal("level_initialized")
	disconnect("level_initialized", global.main_scene, "_on_level_initialized")
	

func connect_NPC_listeners():
	if has_node("enemies"):
		for enemy in $enemies.get_children():
			if enemy.has_method("_on_level_initialized"):
				connect("level_initialized", enemy, "_on_level_initialized")
func end():
	# all the cleanup stuff. remove things as necessary
	queue_free()
