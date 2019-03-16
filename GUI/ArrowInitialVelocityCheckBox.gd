extends CheckBox

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#warning-ignore:return_value_discarded
func _on_CheckBox_toggled(button_pressed):
	global.options["projectiles_add_initial_velocity"] = is_pressed()
