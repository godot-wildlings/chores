extends KinematicBody2D

signal health_changed

enum States { IDLE, WALKING, RUNNING, DEAD }

onready var health : float = max_health setget _set_health

export var speed : float = 100
export var max_health : float = 3

const SPEED : int = 200
const RUN_SPEED_MULTIPLIER : float = 2.0
var _state : int = States.IDLE setget _set_state
var _iframes : int = 0
var _move_dir =  Vector2.ZERO
func _ready():
	global.player = self
	$Label.text = "Health: " + str(health)
	connect("health_changed", self, "_on_health_change")
	
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
			_movement_loop()

#warning-ignore:unused_argument
func _state_running(delta : float):
	if not Input.is_action_pressed("mv_run"):
		self._state = States.WALKING
	else:
		_controls_loop()
		if _move_dir == Vector2.ZERO:
			self._state = States.IDLE
		else:
			_movement_loop()

func _controls_loop():
	var up : bool = Input.is_action_pressed("mv_up")
	var down : bool = Input.is_action_pressed("mv_down")
	var left : bool = Input.is_action_pressed("mv_left")
	var right : bool = Input.is_action_pressed("mv_right")
	
	_move_dir.x = - int(left) + int(right)
	_move_dir.y = - int(up) + int(down)
	
func _movement_loop():
	var motion : Vector2
	if _state == States.RUNNING:
		motion = _move_dir.normalized() * SPEED * RUN_SPEED_MULTIPLIER
	elif _state == States.WALKING:
		motion = _move_dir.normalized() * SPEED
	
	#warning-ignore:return_value_discarded
	move_and_slide(motion, Vector2.ZERO)

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
		if body.is_in_group("enemies"):
			if _iframes == 0 and body.on_hit_dmg != 0:
				self.health -= body.on_hit_dmg
				_iframes = 10

func _on_health_change():
	if health <= 0:
		self._state = States.DEAD
	$Label.text = "Health: " + str(health)

func _set_health(new_health : float):
	if new_health != health:
		health = new_health
		emit_signal("health_changed")

func _set_state(new_state : int):
	if _state != new_state:
		_state = new_state
		if new_state == States.DEAD:
			print("GAME OVER")
			queue_free()
			get_tree().quit()

