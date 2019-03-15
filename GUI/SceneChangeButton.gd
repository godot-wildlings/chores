extends Button

signal level_requested()
export var scene_path : String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass



func _on_BecomeDemonButton_pressed():
	var _err = connect("level_requested", global.main_scene, "_on_level_requested")
	emit_signal("level_requested", scene_path)
