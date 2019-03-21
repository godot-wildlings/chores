extends Area2D

signal hit(weapon_damage)

enum States { FLYING, STUCK }
var _state = States.FLYING
 
export var speed : float = 600
#warning-ignore:unused_class_variable
export var damage : int = 1
export var persist_after_impact : bool = false

var velocity : Vector2 = Vector2.ZERO

func _ready():
	connect_signals()
	speed = global.options["arrow_speed"]

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

##warning-ignore:unused_argument
#func shoot(initial_velocity: Vector2, rot_deg : float):
#	"""why do arrows know their own velocity? shouldn't they only ever move at the initial_velocity given them?"""
#	#global_position = bullet_position
#	var direction = Vector2(1,0).rotated(deg2rad(rot_deg))
#	var base_velocity = direction.normalized() * global.options["arrow_speed"]
#
#	if _state == States.FLYING:
#
#		if global.options["projectiles_add_initial_velocity"] == true:
#			#old method : included player velocity
#			velocity = initial_velocity + base_velocity
#		else:
#			velocity = base_velocity
#		rotation += direction.angle()
#	play_sound_effect()

#warning-ignore:unused_argument
func shoot(arrow_velocity: Vector2, rot_deg : float):
	velocity = arrow_velocity
	rotation = deg2rad(rot_deg)
	play_sound_effect()


	
func play_sound_effect():
	if has_node("SFX"):
		var sfx : Node2D = get_node("SFX")
		var sfx_count : int = sfx.get_child_count()
		var rnd_sfx : int = randi() % sfx_count
		var sfx_player : AudioStreamPlayer2D = sfx.get_child(rnd_sfx)
		sfx_player.play()

func disappear():
	if has_node("CollisionShape2D"):
		$CollisionShape2D.call_deferred("set_disabled", true)
	if has_node("Sprite"):
		$Sprite.set_visible(false)
		
	call_deferred("queue_free")

func _on_DurationTimer_timeout():
	disappear()

func hit_entity(entity):
	if entity.has_method("_on_hit"):
		var _err = connect("hit", entity, "_on_hit")
		if _err: push_warning(_err)
		emit_signal("hit", damage)
		disconnect("hit", entity, "_on_hit")
		if persist_after_impact == true:
			_state = States.STUCK
		else:
			disappear()

func _on_projectile_body_entered(body):
	#print(self.name, " hit body: ", body)
	if body.is_in_group("enemies") or body.is_in_group("livestock"):
		hit_entity(body)
	else:
		#disappear() # might hit Tilemap
		pass # was hitting too many tiles

func _on_projectile_area_entered(area):
	#print(self.name, " hit area: ", area )
	# enemies might have Area2D hitboxes or kinematicBody2D collision shapes
	if area.is_in_group("enemies") or area.is_in_group("livestock"):		
		hit_entity(area)
	else:
		# disappear() # might hit NPCs
		pass # not important for MVP
		