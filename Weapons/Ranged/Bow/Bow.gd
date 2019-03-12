extends Node2D

signal shoot(pos, rot, vel, rot_deg)

#onready var projectile_container : Node2D = util.get_main_node().get_node("ProjectileContainer")
# let Level.gd worry about this for the moment

export var projectile_tscn : PackedScene = preload("res://Projectiles/Arrow/Arrow.tscn") as PackedScene
export var spawn_distance : float = 10

var _spawn_position : Position2D

func _ready():
	_spawn_position = Position2D.new()
	_spawn_position.name = "SpawnPosition"
	add_child(_spawn_position)
	_spawn_position.global_position = global_position + Vector2(spawn_distance, 0)
	
	
func attack(vel):
	_shoot(vel)


func _shoot(vel):
	connect("shoot", global.current_level, "_on_projectile_requested")
	emit_signal("shoot", projectile_tscn, vel, _spawn_position.global_position, global_rotation_degrees)
	disconnect("shoot", global.current_level, "_on_projectile_requested")
	
#	var projectile_instance : Node2D = projectile_tscn.instance()
#	projectile_container.add_child(projectile_instance)
#	if projectile_instance.has_method("shoot"):
#		projectile_instance.shoot(_spawn_position.global_position, global_rotation_degrees, my_archer.velocity)
##		$AudioStreamPlayer.play()
#		emit_signal("shoot")