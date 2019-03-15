extends Area2D

signal hit(damage)

export var speed : float = 400
#warning-ignore:unused_class_variable
export var damage : int = 1

var velocity : Vector2 = Vector2.ZERO

func _ready():
	connect("area_entered", self, "_on_area_entered")
#	connect("body_entered", self, "_on_body_entered")

func _process(delta):
	position += velocity * delta

func shoot(bullet_position : Vector2, rot : float, initial_velocity : Vector2):
	#print(self.name, " shooting fireball", " pos: ", bullet_position, ", rot: ", rot, ", vel: " ,initial_velocity )
	global_position = bullet_position
	velocity = Vector2.RIGHT.rotated(rot) * speed + initial_velocity
	rotation = rot
	if has_node("SFX"):
		var sfx : Node2D = get_node("SFX")
		var sfx_count : int = sfx.get_child_count()
		var rnd_sfx : int = randi() % sfx_count
		var sfx_player : AudioStreamPlayer2D = sfx.get_child(rnd_sfx)
		sfx_player.play()

func _on_area_entered(area : Area2D):
	if is_instance_valid(area.get_parent()):
		if area.get_parent() == global.player:
			connect("hit", area.get_parent(), "_on_hit")
			emit_signal("hit", damage)

#
#func _on_body_entered(body : PhysicsBody2D):
#	print(body)
#	if body == global.player:
#		connect("hit", body, "_on_hit")
#		emit_signal("hit", damage)