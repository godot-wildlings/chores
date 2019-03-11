extends KinematicBody2D

export var speed : float = 400
#warning-ignore:unused_class_variable
export var damage : int = 1

var velocity : Vector2 = Vector2.ZERO

func _process(delta):
	position += velocity * delta

func shoot(bullet_position : Vector2, dir : Vector2):
	global_position = bullet_position
	velocity = dir.normalized() * speed
	rotation += dir.angle()