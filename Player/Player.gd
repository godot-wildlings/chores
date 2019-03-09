extends KinematicBody2D

enum States { IDLE, WALKING, RUNNING }

const SPEED : int = 200
var _state : int = States.IDLE setget _set_state
var _move_dir =  Vector2.ZERO

func _ready():
	global.player = self

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

#warning-ignore:unused_argument
func _state_walking(delta : float):
	_controls_loop()
	if _move_dir == Vector2.ZERO:
		self._state = States.IDLE
	else:
		_movement_loop()

#warning-ignore:unused_argument
func _state_running(delta : float):
	pass

func _controls_loop():
	var up : bool = Input.is_action_pressed("ui_up")
	var down : bool = Input.is_action_pressed("ui_down")
	var left : bool = Input.is_action_pressed("ui_left")
	var right : bool = Input.is_action_pressed("ui_right")
	
	_move_dir.x = - int(left) + int(right)
	_move_dir.y = - int(up) + int(down)
	
func _movement_loop():
	var motion : Vector2
	motion = _move_dir.normalized() * SPEED
	
	#warning-ignore:return_value_discarded
	move_and_slide(motion, Vector2.ZERO)

func _set_state(new_state : int):
	print(new_state)
	_state = new_state