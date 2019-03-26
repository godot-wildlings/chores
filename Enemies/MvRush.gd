"""
Find the target. Run straight at them.

This might seem weird. A subnode will be 
responsible for moving it's grandparent.

"""

extends Node2D

var Target
var Entity
var Velocity : Vector2
var velocity_vectors = []
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
	aggregate_velocity_vectors()
	Entity.move_and_slide(Velocity * Speed)

	if global.DEBUG:
		update()
	
func aggregate_velocity_vectors():
	velocity_vectors = []
	velocity_vectors.push_back(get_vector_toward_player())
	velocity_vectors.push_back(get_vector_away_from_neighbours())
	
	Velocity = Vector2.ZERO
	for vec in velocity_vectors:
		Velocity += vec
	
	
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
	
func _draw():
	if global.DEBUG:
		var colors = [Color.red, Color.lightgreen, Color.blue]
		var i : int = 0
		for vec in velocity_vectors:
			draw_line(Vector2.ZERO, vec*15.0, colors[wrapi(i, 0, colors.size())], 1, false)
			i += 1
	
	
	
	
	












	



