extends KinematicBody2D

signal health_changed

onready var _player : KinematicBody2D = global.player
onready var health : float = max_health setget _set_health

enum States { ALIVE, DEAD }
var _state = States.ALIVE

export var speed : float = 100
#warning-ignore:unused_class_variable
export var on_hit_dmg : float = 1
export var max_health : float = 3

var _hitstun : int = 0
var _move_timer : int = 0
var _move_timer_length : int = 30
var _knock_dir : Vector2 = Vector2.ZERO
var _move_dir : Vector2
var _initial_modulate : Color

func _ready():
	$Label.text = "Health: " + str(health)
	_initial_modulate = modulate
	var _err = connect("health_changed", self, "_on_health_change")
	if _err: push_warning(_err)
	$DeadBody.hide()
	
	
#warning-ignore:unused_argument	
func _physics_process(delta : float):
	if is_instance_valid(_player) and _state == States.ALIVE:
		_movement_loop()
		_damage_loop()
		if _move_timer > 0:
			_move_timer -= 1
		if _move_timer == 0 || is_on_wall():
			_move_dir = _player.global_position - global_position
			_move_timer = _move_timer_length

func _movement_loop():
	var motion : Vector2
	if _hitstun == 0:
		motion = _move_dir.normalized() * speed 
	else:
		motion = _knock_dir.normalized() * 125
	
	var _collision = move_and_slide(motion, Vector2.ZERO)
	

func _damage_loop():
	health = min(max_health, health)
	if _hitstun > 0:
		_hitstun -= 1
		modulate = Color.red
	else:
		modulate = _initial_modulate
		if health <= 0:
			die()

	if health > 0:
		for body in $Hitbox.get_overlapping_bodies():
			if body.is_in_group("projectiles"):
				if _hitstun == 0 and body.damage != 0:
					self.health -= body.damage
					$HitNoise.play()
					_hitstun = 10
					_knock_dir = get_global_transform().origin - body.get_global_transform().origin 
					body.queue_free() # make arrows disappear


func die():
	# spawn corpse and bloodstain
	# queue_free after a timer, if desired
	$Sprite.hide()
	$DeadBody.show()
	$DeadBody/CorpseDuration.start() # disappear later
	_state = States.DEAD

func _on_level_initialized():
	_player = global.player

func _on_health_change():
	$Label.text = "Health: " + str(health)

func _set_health(new_health : float):
	if new_health != health:
		health = new_health
		emit_signal("health_changed")
		

#func _on_hit(damage): # signal from BigArrow.tscn
#	$HitNoise.play()
#	health -= damage
#	if health < 0:
#		die()
		
	

func _on_CorpseDuration_timeout():
	call_deferred("queue_free")
