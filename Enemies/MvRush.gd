"""
Find the target. Run straight at them.

This might seem weird. A subnode will be 
responsible for moving it's grandparent.

"""

extends Node

var Target
var Entity
var Velocity : Vector2
export var Speed : float = 100

enum States { DISABLED, ENABLED }
var _state = States.DISABLED

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func start(entity, target):
	Entity = entity
	Target = target


func set_state(newState):
	_state = newState

func _process(_delta):
	if _state == States.DISABLED:
		return # some other script is handling movement
		
	if is_instance_valid(Entity) and is_instance_valid(Target):
		if Entity.is_dead() == false:
			move_toward_player()
	else:
		Entity = get_parent().get_parent()
		Target = global.player

func move_toward_player():
	var myPos = Entity.get_global_position()
	var targetPos = Target.get_global_position()
	Velocity = (targetPos - myPos).normalized() * Speed

	Entity.move_and_slide(Velocity)
