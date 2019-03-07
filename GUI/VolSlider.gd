extends HSlider

# Declare member variables here. Examples:
export var Bus : int = 0



# Called when the node enters the scene tree for the first time.
func _ready():
	var _err = connect("value_changed", self, "_on_VolSlider_value_changed")
	if _err: push_warning(_err)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_VolSlider_value_changed(value):
	AudioServer.set_bus_volume_db(Bus, value)
