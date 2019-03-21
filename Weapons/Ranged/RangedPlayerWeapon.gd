extends Node2D

signal shoot(pos, rot, vel, rot_deg)

#onready var projectile_container : Node2D = util.get_main_node().get_node("ProjectileContainer")
# let Level.gd worry about this for the moment
enum States { IDLE, RELOADING, SHOOTING }
var _state = States.IDLE

export var projectile_tscn : PackedScene = preload("res://Projectiles/Arrow/Arrow.tscn") as PackedScene
export var spawn_distance : float = 10
export var wind_up_animation : String = "bow_wind_up"

var _spawn_position : Position2D
var Ticks : int = 0

func _ready():
	_spawn_position = Position2D.new()
	_spawn_position.name = "SpawnPosition"
	add_child(_spawn_position)
	_spawn_position.global_position = global_position + Vector2(spawn_distance, 0)

	
	
func attack():
	if _state == States.IDLE:
		_shoot()
	
#	$AnimationPlayer.play(wind_up_animation)
#	if $AnimationPlayer.is_connected("animation_finished", self, "_on_AnimationPlayer_animation_finished"):
#		$AnimationPlayer.disconnect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
#	#warning-ignore:return_value_discarded
#	$AnimationPlayer.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")


func _shoot():
	var mousePos = get_global_mouse_position()
	var spawnPos = _spawn_position.get_global_position()
	#warning-ignore:return_value_discarded
	connect("shoot", global.current_level, "_on_projectile_requested")
	var arrow_vel = (mousePos - spawnPos).normalized() * global.options["arrow_speed"] + global.player.velocity
	emit_signal("shoot", projectile_tscn, arrow_vel, spawnPos, global_rotation_degrees)
	#emit_signal("shoot", projectile_tscn, global.player.velocity, _spawn_position.global_position, global_rotation_degrees)
	disconnect("shoot", global.current_level, "_on_projectile_requested")
	_state = States.RELOADING
	$ReloadTimer.start()
	$AnimationPlayer.play("bow_release")

func _process(delta):
	Ticks += 1
	if global.DEBUG:
		update()

#func _on_AnimationPlayer_animation_finished(anim : String):
#	if anim == wind_up_animation:
#		_shoot()

func _on_ReloadTimer_timeout():
	_state = States.IDLE

func _draw():
	if global.DEBUG:
		draw_line(to_local(_spawn_position.global_position), to_local(get_global_mouse_position()), Color.antiquewhite, 3, true)
