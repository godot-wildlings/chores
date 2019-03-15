"""
Find the target. Set a timer and teleport to various locations within
some ideal range of the target.

"""

extends Node

var Target
var Entity
#var Velocity : Vector2

var velocity_vectors : Array
export var Speed : float = 100
export var Preferred_Range : int = 200

enum States { DISABLED, ENABLED, TELEPORTING }
var _state = States.DISABLED

var Ticks : int = 0
var BlinkTimer : Timer
#var ready_to_blink : bool = false


signal teleport_requested()
signal teleport_completed()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func start(entity, target):
	Entity = entity
	Target = target
	#print("Blink starting")
	setup_blink_timer()
	var err = connect("teleport_requested", Entity, "_on_teleport_requested")
	err = connect("teleport_completed", Entity, "_on_teleport_completed")
	if err: push_warning(str(err))
	
func setup_blink_timer():
	BlinkTimer = Timer.new()
	add_child(BlinkTimer)
	BlinkTimer.set_wait_time(rand_range(0.5, 1.5))
	BlinkTimer.connect("timeout", self, "_on_BlinkTimer_timeout")
	BlinkTimer.start()

func set_state(newState):
	#print("blink received set_state command")
	if newState == States.DISABLED:
		BlinkTimer.stop()
		

	_state = newState

func _process(delta):
	if _state == States.DISABLED:
		return # some other script will handle movement

	if Entity.get_state() == Entity.States.DEAD:
		return # no need to do anything

	
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

func blink():
	"""Notes:
	You're not supposed to teleport a KinematicBody2D.
	Best I can do is make it invisible and collision-free, move it to the destination quickly,
	then reactivate it.
	"""	
	# pick a new location
	var blink_distance = 200
	
	var newPos = Entity.get_global_position()
	newPos.x += rand_range(-blink_distance, blink_distance)
	newPos.y += rand_range(-blink_distance, blink_distance)

	#turn entity invis and disable collision
	emit_signal("teleport_requested")
	
	_state = States.TELEPORTING
	
	Entity.call_deferred("move_and_collide", newPos - Entity.get_global_position())
	
	call_deferred("reappear")
	
func reappear():
	emit_signal("teleport_completed")
	
	
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
	
	
func _on_BlinkTimer_timeout():
	BlinkTimer.set_wait_time(rand_range(0.5, 1.5))
	BlinkTimer.start()
	blink()