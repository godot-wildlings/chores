extends KinematicBody2D

signal health_changed
signal shoot

onready var projectile_container : Node2D = util.get_main_node().get_node("ProjectileContainer")
onready var _player : KinematicBody2D = global.player
onready var health : float = max_health setget _set_health


export var projectile_tscn : PackedScene = preload("res://Projectiles/Fireball/Fireball.tscn") as PackedScene
export var spawn_distance : float = 10
export var speed : float = 100
export var on_hit_dmg : float = 1
export var max_health : float = 3

var _hitstun : int = 0
var _move_timer : int = 0
var _move_timer_length : int = 30
var _knock_dir : Vector2 = Vector2.ZERO
var _move_dir : Vector2
var _texture_default : Texture
var _texture_hurt : Texture
var _is_in_attack_range : bool = false

"""
walk up until in range (determined by area2d collisionshape)
start attacking (timer based cooldown)

"""

func _ready():
	yield(get_tree().create_timer(0.2), "timeout") # wait for player
	_player = global.player
	
	_texture_default = $Sprite.texture
	_texture_hurt = load($Sprite.texture.get_path().replace(".png", "_hurt.png")) as Texture
	$Label.text = "Health: " + str(health)
	connect("health_changed", self, "_on_health_change")
	#warning-ignore:return_value_discarded
	$AttackRadius.connect("body_entered", self, "_on_AttackRadius_body_entered")
	#warning-ignore:return_value_discarded
	$AttackRadius.connect("body_exited", self, "_on_AttackRadius_body_exited")
	
func _physics_process(delta : float):
	_damage_loop()
	
	if not _is_in_attack_range:
		_movement_loop()
		if _move_timer > 0:
			_move_timer -= 1
		if _move_timer == 0 || is_on_wall():
			_move_dir = _player.position - position
			_move_timer = _move_timer_length
	else:
		_attack()
		
func _movement_loop():
	var motion : Vector2
	if _hitstun == 0:
		motion = _move_dir.normalized() * speed 
	else:
		motion = _knock_dir.normalized() * 125
	
	move_and_slide(motion, Vector2.ZERO)
	
func _damage_loop():
	health = min(max_health, health)
	if _hitstun > 0:
		_hitstun -= 1
		$Sprite.texture = _texture_hurt
	else:
		$Sprite.texture = _texture_default
		if health <= 0:
			queue_free()
	
	for body in $Hitbox.get_overlapping_bodies():
		if body.is_in_group("projectiles"):
			if _hitstun == 0 and body.damage != 0:
				self.health -= body.damage
				_hitstun = 10
				_knock_dir = get_global_transform().origin - body.get_global_transform().origin 
				body.queue_free()

func _attack():
	var projectile_instance : Node2D = projectile_tscn.instance()
	projectile_container.add_child(projectile_instance)
	if projectile_instance.has_method("shoot"):

		projectile_instance.shoot(global_position, (_player.global_position - global_position).angle())
#		$AudioStreamPlayer.play()
		emit_signal("shoot")

func _on_AttackRadius_body_entered(body : PhysicsBody2D):
	if body == global.player:
		_is_in_attack_range = true

func _on_AttackRadius_body_exited(body : PhysicsBody2D):
	if body == global.player:
		_is_in_attack_range = false

func _on_health_change():
	$Label.text = "Health: " + str(health)

func _set_health(new_health : float):
	if new_health != health:
		health = new_health
		emit_signal("health_changed")