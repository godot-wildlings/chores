"""
Player should be able to:
	- move
	- shoot
	- switch forms (demon/human)
	- take damage
	- die
	- interact with NPCs
"""

extends KinematicBody2D

#signal health_changed
signal level_requested(path_to_level)
signal weapon_requested(weapon_name)

enum States { IDLE, WALKING, RUNNING, CHATTING, DEAD }

onready var health : float = max_health # setget _set_health

export var max_health : float = 10

export var is_demon : bool = false
export var demon_health : float = 20

const SPEED : int = 200
const RUN_SPEED_MULTIPLIER : float = 2.0
var _state : int = States.IDLE setget _set_state
var _iframes : int = 0
var _move_dir =  Vector2.ZERO
var velocity : Vector2

var previous_positions : Array = [] # <-- HAX for the demon h_flipping

func _ready():
	global.player = self
	$Label.text = "Health: " + str(health)
	#warning-ignore:return_value_discarded
	connect_signals()

	
	if is_demon == true:
		become_demon()
	else:
		become_human()

func connect_signals():

#	var _err
#	_err = connect("health_changed", self, "_on_health_change")
#	if _err: push_warning(_err)


	var _err = null
	_err = connect("weapon_requested", $WeaponSlots, "_on_weapon_requested")
	if _err: push_warning(_err)

func toggle_form():
	if is_demon == true:
		become_human()
	else:
		become_demon()
			
func become_demon():
	emit_signal("weapon_requested", "FireCaster")
	show_demon_sprites()
	is_demon = true
	max_health = demon_health
	health = max_health
	
func become_human():
	emit_signal("weapon_requested", "Bow")
	show_human_sprites()
	is_demon = false
		
func show_human_sprites():
	$Sprite.show()
	$DemonForm.hide()

func show_demon_sprites():
	$DemonForm.show()
	$Sprite.hide()

#warning-ignore:unused_argument
func _process(delta):
	if _state == States.CHATTING or _state == States.DEAD:
		return
		

	if Input.is_action_just_pressed("attack"):
		$WeaponSlots.attack()

	if Input.is_action_just_pressed("transform"):
		toggle_form()

func _physics_process(delta):
	match _state:
		States.IDLE: 
			_state_idle()
		States.WALKING:
			_state_walking(delta)
			
		States.RUNNING:
			_state_running(delta)

func _state_idle():
	_controls_loop()
	if _move_dir != Vector2.ZERO:
		self._state = States.WALKING
	else:
		if is_demon == false:
			_update_human_animation(Vector2.ZERO)
		else:
			_update_demon_animation(Vector2.ZERO)
		_damage_loop()

#warning-ignore:unused_argument
func _state_walking(delta : float):
	if not Input.is_action_pressed("mv_walk"):
		self._state = States.RUNNING
	else:
		_controls_loop()
		if _move_dir == Vector2.ZERO:
			self._state = States.IDLE
		else:
			_movement_loop(delta)

#warning-ignore:unused_argument
func _state_running(delta : float):
	if Input.is_action_pressed("mv_walk"):
		self._state = States.WALKING
	else:
		_controls_loop()
		if _move_dir == Vector2.ZERO:
			self._state = States.IDLE
		else:
			_movement_loop(delta)

func _controls_loop():
	var up : bool = Input.is_action_pressed("mv_up")
	var down : bool = Input.is_action_pressed("mv_down")
	var left : bool = Input.is_action_pressed("mv_left")
	var right : bool = Input.is_action_pressed("mv_right")
	
	_move_dir.x = - int(left) + int(right)
	_move_dir.y = - int(up) + int(down)
	
func get_kiting_multiplier() -> float:
	var myPos = get_global_position()
	var mousePos = get_global_mouse_position()
	if _move_dir.dot( (mousePos - myPos).normalized() ) < 0:
		# info about using dot product for facing found here:
				# https://docs.godotengine.org/en/latest/tutorials/math/vector_math.html?highlight=vector%20math#facing
		return 0.75 # kiting. slow down
	else:
		return 1.0 # moving toward mouse. full speed ahead
	
func _movement_loop(delta):
	
	
	var motion : Vector2
	if _state == States.RUNNING:
		motion = _move_dir.normalized() * SPEED * RUN_SPEED_MULTIPLIER * get_kiting_multiplier()
	elif _state == States.WALKING:
		motion = _move_dir.normalized() * SPEED
	if is_demon == false:
		_update_human_animation(motion)
	else:
		_update_demon_animation(motion)
	
	
	#warning-ignore:return_value_discarded
	var redirected_velocity = move_and_slide(motion, Vector2.ZERO)
	velocity = redirected_velocity

func _update_human_animation(motion : Vector2):
	if _state == States.RUNNING:
		$AnimationPlayer.play("player_run")
		play_random_step_sfx(true)
	elif _state == States.WALKING:
		$AnimationPlayer.play("player_walk")
		play_random_step_sfx()
	if motion.x > 0:
		$Sprite.flip_h = false
	elif motion.x < 0:
		$Sprite.flip_h = true
	elif motion == Vector2.ZERO:
		$AnimationPlayer.play("player_idle")
	if get_local_mouse_position().x >= 0:
		$Sprite.flip_h = false
	elif get_local_mouse_position().x <= 0:
		$Sprite.flip_h = true

func play_random_step_sfx(running : bool = false):
	if is_instance_valid(global.current_level):
		match global.current_level.name:
			"Farm", "NightFarm":
				if has_node("StepSFXGrass"):
					play_random_sfx($StepSFXGrass)
			"Caves", "NightCaves":
				if has_node("StepSFXCaves"):
					play_random_sfx($StepSFXCaves)

func play_random_sfx(container : Node2D):
	if is_instance_valid(container):
		var sfx_count : int = container.get_child_count()
		var rnd_sfx_idx : int = randi() % sfx_count
		var sfx_audio_player : AudioStreamPlayer2D = container.get_child(rnd_sfx_idx)
		if is_instance_valid(sfx_audio_player):
			sfx_audio_player.play()

func get_direction_hack():
	# store a bunch of previous positions and get the average
	# so you can ignore blips in velocity when animating or h_flipping
	var myPos = get_global_position()
	var direction_vector = Vector2.ZERO
	previous_positions.push_front(myPos)
	if previous_positions.size() > 5:
		previous_positions.pop_back()
	
	for pos in previous_positions:
		direction_vector += pos
	direction_vector /= previous_positions.size()
	direction_vector -= myPos

	print(direction_vector)

	if direction_vector.x > 0:
		print("left")
		return -1
		
	else:
		print("right")
		return 1


func _update_demon_animation(motion : Vector2):
	
	if _state == States.RUNNING:
		$AnimationPlayer.play("demon_walk")
	elif _state == States.WALKING:
		$AnimationPlayer.play("demon_walk")

#	if get_direction_hack() > 0:
#		$DemonForm.set_scale(Vector2(1, 1))
#	else:
#		$DemonForm.set_scale(Vector2(-1, 1))

	if motion == Vector2.ZERO:
		$AnimationPlayer.play("demon_idle")
	
	var mousePos = get_local_mouse_position()
	flip_demon_sprites(sign(mousePos.x))

func flip_demon_sprites(direction):
		$DemonForm.set_scale(Vector2(direction, 1))
	
	

func _damage_loop():
	health = min(max_health, health)
	if _iframes > 0:
		_iframes -= 1
		modulate = Color(255, 0, 0, 1)
	else:
		modulate = Color(1, 1, 1, 1)
		if health <= 0:
			die()
			#self._state = States.DEAD

# moved to _on_hit
#	for body in $Hitbox.get_overlapping_bodies():
#		if body.is_in_group("enemies") or body.is_in_group("projectiles"):
#			if _iframes == 0:
#				if body.get("on_hit_dmg") != null and body.on_hit_dmg != 0:
#					self.health -= body.on_hit_dmg
#					_iframes = 10
#				elif body.get("damage") != null and body.damage != 0:
#					self.health -= body.damage
#					_iframes = 10

#func _on_health_change():
#	if health <= 0:
#		die()
#		#self._state = States.DEAD
		
#	$Label.text = "Health: " + str(health)

func take_damage(damage):
	health -= damage
	if has_node("HurtSFX"):
		var hurt_sfx_count : int = get_node("HurtSFX").get_child_count()
		var rnd_hurt_sfx : int = randi() % hurt_sfx_count
		var rnd_audio_player : AudioStreamPlayer2D = get_node("HurtSFX").get_child(rnd_hurt_sfx)
		if is_instance_valid(rnd_audio_player):
			rnd_audio_player.play()
	flash_red()
	if health <= 0:
		die()

func flash_red():
	var node_to_colorize
	if is_demon == false:
		node_to_colorize = $Sprite
	else:
		node_to_colorize = $DemonForm


	var tween = get_node("Tween")
	tween.interpolate_property(node_to_colorize, "modulate",
			Color.red, Color.white, .25,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


# moved all the set get health signaling stuff to _on_hit
#func _set_health(new_health : float):
#	if new_health != health:
#		health = new_health
#		#emit_signal("health_changed")

func die():
	print("GAME OVER")
#	if has_node("DeathSFX"):
#		var death_sfx_count : int = get_node("DeathSFX").get_child_count()
#		var rnd_death_sfx : int = randi() % death_sfx_count
#		var rnd_audio_player : AudioStreamPlayer2D = get_node("DeathSFX").get_child(rnd_death_sfx)
#		if is_instance_valid(rnd_audio_player):
#			rnd_audio_player.play()
	var _err = connect("level_requested", global.main_scene, "_on_level_requested")
	if _err: push_warning(_err)
	emit_signal("level_requested", "res://Levels/RIPFriederich.tscn")
	disconnect("level_requested", global.main_scene, "_on_level_requested")

	queue_free()

func _set_state(new_state : int):
	if _state != new_state:
		_state = new_state
		if new_state == States.DEAD:
			die()
		elif new_state == States.IDLE:
			velocity = Vector2.ZERO

func _on_book_picked_up():
	# do something. turn into a demon?
	pass

func _on_NPC_started_chatting():
	_state = States.CHATTING
	
func _on_NPC_stopped_chatting():
	_state = States.IDLE


func _on_hit(damage):
	take_damage(damage)
	
