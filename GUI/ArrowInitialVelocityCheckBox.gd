extends CheckBox

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	match self.name:
		"InitialVel":
			pressed = global.options["projectiles_add_initial_velocity"]
		"Debug":
			pressed = global.DEBUG
		"HoldToShoot":
			pressed = global.options["hold_to_shoot"]
		"ConfineMouse":
			pressed = global.options["confine_mouse"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_CheckBox_toggled(_button_pressed):
	match self.name:
		"InitialVel":
			global.options["projectiles_add_initial_velocity"] = is_pressed()
		"Debug":
			global.DEBUG = is_pressed()
		"HoldToShoot":
			global.options["hold_to_shoot"] = is_pressed()
		"ConfineMouse":
			global.options["confine_mouse"] = is_pressed()
			update_mouse_settings()
			
func update_mouse_settings():
	if global.options["confine_mouse"] == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	