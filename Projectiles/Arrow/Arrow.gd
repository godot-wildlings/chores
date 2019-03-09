extends KinematicBody2D

export var speed : float = 200
export var damage : int = 1

var velocity : Vector2 = Vector2.ZERO

func _process(delta):
	position += velocity * delta

func shoot(bullet_position : Vector2, rot_degrees : float):
	global_position = bullet_position
	var direction : Vector2 = Vector2.RIGHT.rotated(deg2rad(rot_degrees))
	velocity = direction.normalized() * speed
	rotation += direction.angle()