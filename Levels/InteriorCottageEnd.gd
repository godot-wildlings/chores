"""
Final Scene.

Play a little animation, then spawn the dialog box.
Roll credits

"""

extends Node2D

signal dialog_box_requested(boxtitle, requestingScene)
signal new_level_requested(level_scene)

export var next_scene_path : String


func _ready():
	pass
	
func start():
	var anim = $AnimationPlayer
	anim.play("Ending")
	yield(anim, "animation_finished" )


	var _err = connect("dialog_box_requested", global.main_scene, "_on_DialogBox_requested")

	var outro_text = [
			"Mother!\n\n\n\tOh, Friedrich. I'm so sorry you had to go through that.\n\n\tI'm here now. Everything will be fine. Don't worry."
	]


	emit_signal("dialog_box_requested", "OutroText", outro_text, self)

func end():
	queue_free()


func _on_DialogBox_completed(box_title):
	if box_title == "OutroText":
		var _err = connect("new_level_requested", global.main_scene, "_on_level_requested")
		emit_signal("new_level_requested", next_scene_path)

