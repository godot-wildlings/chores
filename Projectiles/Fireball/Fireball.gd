extends Area2D

signal hit(damage)

export var speed : float = 400
#warning-ignore:unused_class_variable
export var damage : int = 1

var velocity : Vector2 = Vector2.ZERO

func _ready():
	var err = connect("area_entered", self, "_on_area_entered")
	if err: push_warning(str(err))
#	connect("body_entered", self, "_on_body_entered")

func _process(delta):
	position += velocity * delta

# seems strange. arguments don't match other shoot functions. Who's calling this?
func shoot(initial_velocity : Vector2, rot : float):
	#print(self.name, " shooting fireball", " pos: ", bullet_position, ", rot: ", rot, ", vel: " ,initial_velocity )
	#global_position = bullet_position
	velocity = Vector2.RIGHT.rotated(rot) * speed + initial_velocity
	rotation = rot
	if has_node("SFX"):
		var sfx : Node2D = get_node("SFX")
		var sfx_count : int = sfx.get_child_count()
		var rnd_sfx : int = randi() % sfx_count
		var sfx_player : AudioStreamPlayer2D = sfx.get_child(rnd_sfx)
		sfx_player.play()

func _on_area_entered(area : Area2D):
	var parent = area.get_parent()
	var grandparent = parent.get_parent()
	if is_instance_valid(parent):
		if parent == global.player:
			connect("hit", parent, "_on_hit")
			emit_signal("hit", damage)
			disconnect("hit", parent, "_on_hit")
			
		elif grandparent == global.player:
			var err = connect("hit", grandparent, "_on_hit")
			if err: push_warning(err)
			emit_signal("hit", damage)
			disconnect("hit", grandparent, "_on_hit")
#
#func _on_body_entered(body : PhysicsBody2D):
#	print(body)
#	if body == global.player:
#		connect("hit", body, "_on_hit")
#		emit_signal("hit", damage)