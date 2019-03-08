extends HSlider

# Declare member variables here. Examples:
export var Bus : int = 0



# Called when the node enters the scene tree for the first time.
func _ready():

	# creating the signal connection in code, because its too easy to have bugs from
	# inspector signals that didn't get hooked up right.
	var _err = connect("value_changed", self, "_on_VolSlider_value_changed")
	if _err: push_warning(_err)




func _on_VolSlider_value_changed(value):
	AudioServer.set_bus_volume_db(Bus, value)
