"""
Sheep floock and avoid the player.
They're useful as a herding minigame during the daytime farm.
"""

extends KinematicBody2D

enum States { INITIALIZING, FLOCKING, GRAZING, IDLE, FLEEING, DEAD }
var _state = States.INITIALIZING

var velocity = Vector2.ZERO
#var base_speed : float = 100
var speed : float = 100
var direction : float = 0
var base_scale : Vector2 = Vector2(0.5, 0.5)
var Ticks : int = 0
var fear_of_player : float = 2.0
var fear_range : float = 400.0
var goal_vectors : Array = []
var frightened : bool = false

export var health : int = 3
export var Debug : bool = true


func _ready():
	$DeadBody.hide()
	$BodyParts.show()
	
	get_random_color()
	get_random_size()
	
	if health > 0:
		set_random_behaviour_state()
	else:
		die()

func set_random_behaviour_state():
	if randf() < 0.95:
		_state = States.FLOCKING
	else:
		_state = States.GRAZING
	

func flock():
	velocity = Vector2.ZERO

	goal_vectors = [
			get_random_direction_vector() /2,
			get_vector_toward_flock(),
			get_vector_away_from_neighbours(),
			get_vector_away_from_player() * fear_of_player # overweight this one. It's important
		]
		
	for vector in goal_vectors:
		velocity += vector
	velocity = velocity.normalized()
	
	
	
	if $AnimationPlayer.is_playing() == false:
		$AnimationPlayer.play("walk")


	

		
func graze(_delta):
	$AnimationPlayer.play("graze")
		


func get_random_color():
	var lightness = rand_range(0.3, 1.0)
	$BodyParts.set_modulate(Color(lightness, lightness, lightness))

func set_pitch(size : float):  # expect a value between 0 and 1
	if size > 1 or size < 0:
		push_warning(self.name + " set_pitch() expected a value between 0 and 1")
	if has_node("AudioStreamPlayer2D"):
		$AudioStreamPlayer2D.set_pitch_scale(lerp(0.8, 1.5, size))

func get_random_size():
	var min_size = 0.45
	var max_size = 0.70
	
	var rand_size = rand_range(min_size, max_size)
	base_scale = Vector2(rand_size, rand_size)
	set_scale(base_scale)
	set_pitch( (rand_size - min_size) / (max_size - min_size))

func get_vector_away_from_player():
	var avoid_vector : Vector2 = Vector2.ZERO
	
	if is_instance_valid(global.player):
		var myPos = get_global_position()
		var playerPos = global.player.get_global_position()
		if myPos.distance_squared_to(playerPos) < fear_range * fear_range:
			avoid_vector = (myPos - playerPos).normalized()
	return avoid_vector
		
	

func get_vector_toward_flock():
	var average_position = Vector2.ZERO
	for sheep in get_flock():
		average_position += sheep.get_global_position()
	average_position /= get_flock_size()
	return (average_position - get_global_position()).normalized()

func get_flock():
	var flock_container = get_parent()
	var flock = flock_container.get_children()
	return flock

func get_flock_size():
	return get_parent().get_child_count()
	
func get_vector_away_from_neighbours() -> Vector2:
	var avoid_vector : Vector2 = Vector2.ZERO
	
	for sheep in get_flock():
		var dist_squared = get_global_position().distance_squared_to(sheep.get_global_position())
		
		var avoid_distance = 60
		if dist_squared < avoid_distance * avoid_distance:
			avoid_vector -= (sheep.get_global_position() - get_global_position()).normalized()
	if avoid_vector.length() > 0:
		avoid_vector = avoid_vector.normalized()
	return avoid_vector
			
func get_random_speed():
	if not is_instance_valid(global.player):
		return

	var rand_speed = rand_range(200, 250.0)
	# increase based on fear and proximity to player
	if frightened: rand_speed *= 1.5
	
	var myPos = get_global_position()
	var playerPos = global.player.get_global_position()
	var poking_distance : int = 100
	if myPos.distance_squared_to(playerPos) < poking_distance * poking_distance:
		rand_speed *= 1.5

	return rand_speed

			
func get_random_direction_vector():
	var rand_dir_vector : Vector2
	direction = randf()*2*PI # 2Pi Rad is 360deg
	rand_dir_vector = Vector2(1, 0).rotated(direction)
	return rand_dir_vector

func flip_sprites(direction_vector):
	if direction_vector.x > 0:
		$BodyParts.scale = Vector2(-base_scale.x, base_scale.y)
	else: 
		$BodyParts.scale = base_scale


func _physics_process(delta):
	Ticks += 1
	if Debug: 
		update()
	
	
	if _state == States.FLOCKING:
		var myVec = Vector2(1,0).rotated(get_global_rotation())
		var turningVec = myVec.linear_interpolate(velocity, 0.8)
		var move_vector = turningVec * speed * delta * global.game_speed
		flip_sprites(move_vector)
		var collision = move_and_collide(move_vector)
		if collision:
			collision = move_and_collide(collision.get_remainder().bounce(collision.get_normal()))

	elif _state == States.GRAZING:
		graze(delta)
	
func _draw():
	var colors = [Color.red, Color.darkgreen, Color.blue, Color.pink]
	var i = 0
	for vector in goal_vectors:
		draw_line(to_local(get_global_position()), to_local(get_global_position() + vector * 30), colors[i], 3, true)
		i = wrapi(i + 1, 0, colors.size())
	
func _on_BehaviourChangeTimer_timeout():
	set_random_behaviour_state()
	if _state == States.FLOCKING:
		flock()
	speed = get_random_speed()
	$BehaviourChangeTimer.set_wait_time(rand_range(0.5, 1.0))
	$BehaviourChangeTimer.start()

func bleet():
	if has_node("AudioStreamPlayer2D"):
		if $AudioStreamPlayer2D.is_playing() == false: # don't stutter/beatbox			 
			$AudioStreamPlayer2D.set_volume_db(rand_range(-40.0, -22.0))
			$AudioStreamPlayer2D.play()



func _on_NoiseTimer_timeout():
	var chance_of_bleeting = 0.2
	if randf() < chance_of_bleeting:
		bleet()
	if global.main_scene.is_paused() == false:
		$NoiseTimer.set_wait_time(rand_range(1.0, 3.0))
		$NoiseTimer.start()
				

func disable_hitboxes():
	$CollisionShape2D.call_deferred("set_disabled", true)
	$HitBox/CollisionShape2D.call_deferred("set_disabled", true)
	

func die():
	# spawn a blood splotch and a dead sheep sprite
	_state = States.DEAD
	disable_hitboxes()
	$DeadBody.show()
	$BodyParts.hide()
	$AnimationPlayer.stop()
	$BehaviourChangeTimer.stop()
	$NoiseTimer.stop()

	
		
func _on_hit(damage): # signal from arrow
	health -= damage
	if health <= 0:
		die()
	else:
		frightened = true
		bleet()
		fear_of_player = 30.0
		fear_range = 600.0
