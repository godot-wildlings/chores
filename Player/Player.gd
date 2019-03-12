extends KinematicBody2D

signal health_changed
signal level_requested(path_to_level)

enum States { IDLE, WALKING, RUNNING, DEAD }

onready var health : float = max_health setget _set_health

export var max_health : float = 3

const SPEED : int = 200
const RUN_SPEED_MULTIPLIER : float = 2.0
var _state : int = States.IDLE setget _set_state
var _iframes : int = 0
var _move_dir =  Vector2.ZERO
var velocity : Vector2

func _ready():
	global.player = self
	$Label.text = "Health: " + str(health)
	#warning-ignore:return_value_discarded
	connect("health_changed", self, "_on_health_change")

#warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_pressed("attack"):
		$WeaponSlots.attack()

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
		_update_animation(Vector2.ZERO)
		_damage_loop()

#warning-ignore:unused_argument
func _state_walking(delta : float):
	if Input.is_action_pressed("mv_run"):
		self._state = States.RUNNING
	else:
		_controls_loop()
		if _move_dir == Vector2.ZERO:
			self._state = States.IDLE
		else:
			_movement_loop(delta)

#warning-ignore:unused_argument
func _state_running(delta : float):
	if not Input.is_action_pressed("mv_run"):
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
	
func _movement_loop(delta):
	var motion : Vector2
	if _state == States.RUNNING:
		motion = _move_dir.normalized() * SPEED * RUN_SPEED_MULTIPLIER
	elif _state == States.WALKING:
		motion = _move_dir.normalized() * SPEED
	_update_animation(motion)
	
	#warning-ignore:return_value_discarded
	var collision = move_and_collide(motion * delta)
	velocity = motion

func _update_animation(motion : Vector2):
	if _state == States.RUNNING:
		$AnimationPlayer.play("player_run")
	elif _state == States.WALKING:
		$AnimationPlayer.play("player_walk")
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

func _damage_loop():
	health = min(max_health, health)
	if _iframes > 0:
		_iframes -= 1
		modulate = Color(255, 0, 0, 1)
	else:
		modulate = Color(1, 1, 1, 1)
		if health <= 0:
			self._state = States.DEAD
	
	for body in $Hitbox.get_overlapping_bodies():
		if body.is_in_group("enemies") or body.is_in_group("projectiles"):
			if _iframes == 0:
				if body.get("on_hit_dmg") != null and body.on_hit_dmg != 0:
					self.health -= body.on_hit_dmg
					_iframes = 10
				elif body.get("damage") != null and body.damage != 0:
					self.health -= body.damage
					_iframes = 10

func _on_health_change():
	if health <= 0:
		self._state = States.DEAD
	$Label.text = "Health: " + str(health)

func _set_health(new_health : float):
	if new_health != health:
		health = new_health
		emit_signal("health_changed")

func die():
	print("GAME OVER")
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
