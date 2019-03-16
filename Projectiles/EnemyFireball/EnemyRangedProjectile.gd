extends Area2D

signal hit(weapon_damage)

onready var anim_player : AnimationPlayer = $AnimationPlayer

enum States { FLYING, STUCK }
var _state = States.FLYING

export var speed : float = 600
#warning-ignore:unused_class_variable
export var damage : int = 1
export var persist_after_impact : bool = false

var velocity : Vector2 = Vector2.ZERO

func _ready():
	connect_signals()


func connect_signals():
	var _err
	_err = connect("area_entered", self, "_on_projectile_area_entered")
	if _err:
		push_warning(_err)
	_err = null
	_err = connect("body_entered", self, "_on_projectile_body_entered")
	if _err:
		push_warning(_err)

func _process(delta):
	if _state == States.FLYING:
		position += velocity * delta


func shoot(initial_velocity: Vector2, bullet_position : Vector2, rot_deg : float):
	global_position = bullet_position
	var direction = Vector2(1,0).rotated(deg2rad(rot_deg))
	var base_velocity = direction.normalized() * speed
	
	if anim_player.has_animation("shoot"):
		anim_player.play("shoot")
	
	if _state == States.FLYING:
		velocity = initial_velocity + base_velocity
		rotation += direction.angle()
	if has_node("SFX"):
		var sfx : Node2D = get_node("SFX")
		var sfx_count : int = sfx.get_child_count()
		var rnd_sfx : int = randi() % sfx_count
		var sfx_player : AudioStreamPlayer2D = sfx.get_child(rnd_sfx)
		sfx_player.play()

func disappear():
	$CollisionShape2D.call_deferred("set_disabled", true)
	call_deferred("queue_free")

func _on_DurationTimer_timeout():
	disappear()


func hit_entity(entity):
	if entity.has_method("_on_hit"):
		var _err = connect("hit", entity, "_on_hit")
		if _err: push_warning(_err)
		emit_signal("hit", damage)
		disconnect("hit", entity, "_on_hit")
		if has_node("HitNoise"):
			$HitNoise.play()
		if persist_after_impact == true:
			_state = States.STUCK
		else:
			disappear()




func _on_projectile_body_entered(body):
	#print(self.name, " hit body: ", body)
	if body == global.player:
		hit_entity(body)
	else:
		#disappear() # might hit Tilemap
		pass # was hitting too many tiles

func _on_projectile_area_entered(area):
	var parent = area.get_parent() # human form
	var grandparent = parent.get_parent() # demon form
	if parent == global.player:
		hit_entity(parent)
	elif grandparent == global.player:
		hit_entity(grandparent)
