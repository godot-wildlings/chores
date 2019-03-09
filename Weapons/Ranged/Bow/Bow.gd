extends Node2D

signal shoot

onready var bullet_container : Node2D = util.get_main_node().get_node("ProjectileContainer")

export var projectile_tscn : PackedScene = preload("res://Projectiles/Arrow/Arrow.tscn") as PackedScene
export var spawn_distance : float = 10

var _spawn_position : Position2D

func _ready():
	_spawn_position = Position2D.new()
	_spawn_position.name = "SpawnPosition"
	add_child(_spawn_position)
	_spawn_position.global_position = global_position + Vector2(spawn_distance, 0)

func attack():
	_shoot()

func _shoot():
	var projectile_instance : Node2D = projectile_tscn.instance()
	bullet_container.add_child(projectile_instance)
	if projectile_instance.has_method("shoot"):
		projectile_instance.shoot(_spawn_position.global_position, global_rotation_degrees)
#		$AudioStreamPlayer.play()
		emit_signal("shoot")