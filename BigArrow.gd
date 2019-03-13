extends Area2D

enum States { FLYING, STUCK }
var _state = States.FLYING
var velocity : Vector2 = Vector2.ZERO
export var damage : float = 10

func _ready():
	pass # Replace with function body.

func start(pos, vel, rot):
	set_global_position(pos)
	velocity = vel
	set_global_rotation(rot)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_global_position(velocity * delta * global.game_speed)


func _on_BigArrow_body_entered(body):
	if body.has_method("_on_hit"):
		connect("hit", body, "_on_hit")
		emit_signal("hit", damage)
		disconnect("hit", body, "_on_hit")
		
