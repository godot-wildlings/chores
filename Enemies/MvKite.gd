"""
Find the target. Maintain your distance at a specific radius.
Then oscillate back and forth along that tangent.

"""

extends Node

var Target
var Entity
#var Velocity : Vector2

var velocity_vectors : Array
export var Speed : float = 100
export var Preferred_Range : int = 400

enum States { DISABLED, ENABLED }
var _state = States.DISABLED

var Ticks : int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func start(entity, target):
	Entity = entity
	Target = target


func set_state(newState):
	_state = newState

func _process(delta):
	if _state == States.DISABLED:
		return # some other script will handle movement
	
	Ticks += 1
	


	
	if is_instance_valid(Entity) and is_instance_valid(Target):
		if Entity.is_dead() == false:
			set_velocity_vectors()
			move(delta)
			
	else:
		Entity = get_parent().get_parent()
		Target = global.player

func move(delta):
	var move_vec = average_velocity_vectors() * Speed * delta * global.game_speed
	var collision = Entity.move_and_collide(move_vec)
	if collision:
		pass

func set_velocity_vectors():
	velocity_vectors = []
	if is_too_close():
		#print("too_close")
		var vec_away_from_player = Vector2.ZERO - get_vector_toward_player()
		velocity_vectors.push_back(vec_away_from_player)
	elif is_too_far():
		#print("too_far")
		velocity_vectors.push_back(get_vector_toward_player())
	velocity_vectors.push_back(get_oscillating_dodge_vector())

func average_velocity_vectors():
	var returnVec : Vector2 = Vector2.ZERO
	for vector in velocity_vectors:
		returnVec += vector
	#print(self.name, " returnVec.normalized() " , returnVec.normalized())
	return returnVec.normalized()

func is_too_close():
	var myPos = Entity.get_global_position()
	var targetPos = Target.get_global_position()
	if myPos.distance_squared_to(targetPos) < 0.8 * Preferred_Range * Preferred_Range:
		return true
	else:
		return false
		
func is_too_far():
	var myPos = Entity.get_global_position()
	var targetPos = Target.get_global_position()
	if myPos.distance_squared_to(targetPos) > 1.2 * Preferred_Range * Preferred_Range:
		return true
	else:
		return false
	
		

func get_vector_toward_player():
	var returnVec = Vector2.ZERO
	var myPos = Entity.get_global_position()
	var targetPos = Target.get_global_position()
	returnVec = (targetPos - myPos).normalized()
	return returnVec




func get_oscillating_dodge_vector():
	# grab the tangent to the vector between entity and target
	# move along that tangent in a sine fasion
	var myPos = Entity.get_global_position()
	var targetPos = Target.get_global_position()
	var tangent = (targetPos - myPos).normalized().rotated(PI/2.0)
	
	var frequency = 0.04
	var returnVec = tangent * sin(float(Ticks) * frequency)
	#print(returnVec)
	return returnVec
	