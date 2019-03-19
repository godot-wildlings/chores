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
			move()
			
	else:
		Entity = get_parent().get_parent()
		Target = global.player

func get_velocity():
	return Velocity

func move():
	Velocity = Vector2.ZERO
	Velocity += get_vector_toward_player()
	Velocity += get_vector_away_from_neighbours()

	Entity.move_and_slide(Velocity * Speed)

	
func get_vector_toward_player():
	var return_vec = Vector2.ZERO
	var myPos = Entity.get_global_position()
	var targetPos = Target.get_global_position()
	return_vec = (targetPos - myPos).normalized()
	return return_vec

func get_vector_away_from_neighbours():
	var return_vec = Vector2.ZERO
	var max_range_to_avoid: float = 55
	var myPos = Entity.get_global_position()
	for creep in get_tree().get_nodes_in_group("enemies"):
		var creepPos = creep.get_global_position()
		if myPos.distance_squared_to(creepPos) < max_range_to_avoid * max_range_to_avoid:
			return_vec += myPos - creepPos
	return_vec = return_vec.normalized()
	
	return return_vec
	
	
	
	
	
	
	
	












	



