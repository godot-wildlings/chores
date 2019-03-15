extends Node2D

# Declare member variables here. Examples:
export var num_creeps_per_wave : int = 5
export var spawn_radius : float = 300
export var max_creeps : int = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	#call_deferred("start") # Replace with function body.
	pass # wait for Sinistar (whoops, I mean Baphomet)

func start():
	$SpawnTimer.start()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawn_creeps():
	print(self.name, " spawning creeps")
	# generate a wave of creeps
	var creep_container = get_creep_container()
	if creep_container.get_child_count() > max_creeps:
		return # too many creeps!

	var creep_type = randi()%3 # 0, 1, 2
	# 0 = RUSH, 1 = KITE, 2 = BLINK
	
	#warning-ignore:unused_class_variable
	for i in range(num_creeps_per_wave):
		var creep_scene = load("res://Enemies/GenericEnemy.tscn")
		
		#var spawn_pos = get_safe_location()
		# can't get desirable results out of get_safe_location
		
		var spawn_pos = get_global_position() + Vector2(rand_range(-100, 100), rand_range(-100, 100))
		
		if spawn_pos is Vector2:
			var new_creep = creep_scene.instance()
			new_creep.type_of_enemy = creep_type
			creep_container.add_child(new_creep)
			new_creep.set_global_position(spawn_pos)
			
func get_creep_container():
	var level = global.current_level
	if not level.has_node("enemies"):
		var enemies_node = Node2D.new()
		enemies_node.name = "enemies"
		level.add_child(enemies_node)
	return level.get_node("enemies")


# Can't get this working, so I'll just dump them nearby
#func get_safe_location():
#
#
#	var myPos = get_global_position()
#
#	var location_found : bool = false
#	# try this ten times, then give up
#	#warning-ignore:unused_class_variable
#	for i in range(10):
#		if not location_found:
#			var rand_direction = randf()*2*PI
#			var rand_distance = randf()*spawn_radius
#			var potential_location = Vector2.RIGHT.rotated(rand_direction) * rand_distance
#
#			var ray = $RayCast2D
#			ray.set_cast_to(potential_location) 
#			if not ray.is_colliding():
#				location_found = true
#				print(potential_location)
#				return (myPos + potential_location)
#			else:
#				var collider = ray.get_collider()
#				print(self.name, " RayCast2D is colliding with ", collider.name )
#	if not location_found:
#		return false

		
func _on_SpawnTimer_timeout():
	spawn_creeps()
	$SpawnTimer.start()
	
