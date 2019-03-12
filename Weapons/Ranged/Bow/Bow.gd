extends Node2D

signal shoot(pos, rot, vel, rot_deg)

#onready var projectile_container : Node2D = util.get_main_node().get_node("ProjectileContainer")
# let Level.gd worry about this for the moment

export var projectile_tscn : PackedScene = preload("res://Projectiles/Arrow/Arrow.tscn") as PackedScene
export var spawn_distance : float = 10
export var wind_up_animation : String = "bow_wind_up"

var _spawn_position : Position2D

func _ready():
	_spawn_position = Position2D.new()
	_spawn_position.name = "SpawnPosition"
	add_child(_spawn_position)
	_spawn_position.global_position = global_position + Vector2(spawn_distance, 0)

	
	
func attack(vel):
	$AnimationPlayer.play(wind_up_animation)
	if $AnimationPlayer.is_connected("animation_finished", self, "_on_AnimationPlayer_animation_finished"):
		$AnimationPlayer.disconnect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	#warning-ignore:return_value_discarded
	$AnimationPlayer.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished", [vel])


func _shoot(vel):
	#warning-ignore:return_value_discarded
	connect("shoot", global.current_level, "_on_projectile_requested")
	emit_signal("shoot", projectile_tscn, vel, _spawn_position.global_position, global_rotation_degrees)
	disconnect("shoot", global.current_level, "_on_projectile_requested")
	
func _on_AnimationPlayer_animation_finished(anim : String, vel : Vector2):
	if anim == wind_up_animation:
		_shoot(vel)