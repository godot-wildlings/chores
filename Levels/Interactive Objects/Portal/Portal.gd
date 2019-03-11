extends Node2D

export var level_path : String
signal level_requested(level_path)

func _ready():
	#warning-ignore:return_value_discarded
	$Area2D.connect("body_entered", self, "on_Area2D_body_entered")

func on_Area2D_body_entered(body : PhysicsBody2D):
	if body == global.player:
		#warning-ignore:return_value_discarded
#		get_tree().change_scene_to(target_scene)
#		global.player.get_node("Camera2D").zoom = Vector2(0.5, 0.5)
		
		connect("level_requested", global.main_scene, "_on_level_requested")
		emit_signal("level_requested", level_path)
		disconnect("level_requested", global.main_scene, "_on_level_requested")
