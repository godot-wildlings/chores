extends KinematicBody2D

export var speed : float = 400
#warning-ignore:unused_class_variable
export var damage : int = 1

var velocity : Vector2 = Vector2.ZERO

func _process(delta):
	position += velocity * delta

func shoot(initial_velocity: Vector2, bullet_position : Vector2, rot_deg : float):
	global_position = bullet_position
	var direction = Vector2(1,0).rotated(deg2rad(rot_deg))
	var base_velocity = direction.normalized() * speed
	velocity = initial_velocity + base_velocity
	rotation += direction.angle()