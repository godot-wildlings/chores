extends Node2D

signal level_initialized

#var Ticks : int = 0
#var Debug : bool = true

#warning-ignore:unused_class_variable
export var params : Dictionary

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

func _on_projectile_requested(bullet_scene, vel, pos, rot_deg):
	if has_node("Projectiles") == false:
		var container = Node2D.new()
		container.name = "Projectiles"
		add_child(container)
	var new_projectile = bullet_scene.instance()
	$Projectiles.add_child(new_projectile)
	if new_projectile.has_method("shoot"):
		new_projectile.shoot(vel, pos, rot_deg)
	
