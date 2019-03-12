extends Node2D

signal level_initialized

var Ticks : int = 0
var Debug : bool = true

func start():
	print(self.name, " level started.")
	global.current_level = self
	
	"""no need. Player registers itself"""
#	if has_node("Player"):
#		global.player = $Player
#	else:
#		global.player = null
	
	var _err = connect("level_initialized", global.main_scene, "_on_level_initialized")
	connect_NPC_listeners()
	emit_signal("level_initialized")
	disconnect("level_initialized", global.main_scene, "_on_level_initialized")
	

func connect_NPC_listeners():
	if has_node("enemies"):
		for enemy in $enemies.get_children():
			if enemy.has_method("_on_level_initialized"):
				var _err = connect("level_initialized", enemy, "_on_level_initialized")
func end():
	# all the cleanup stuff. remove things as necessary
	queue_free()

func print_debug_info():
	print(self.name, " printing debug info" )
	print("==> global.main_scene == ", global.main_scene )
	print("==> global.main_scene.current_level_node == ", global.main_scene.current_level_node)
	print("==> global.main_scene._state == ", global.main_scene.get_state())

func _process(_delta):
#	Ticks += 1
#	if Debug == true and Ticks % 20 == 0:
#		print_debug_info()
	pass


