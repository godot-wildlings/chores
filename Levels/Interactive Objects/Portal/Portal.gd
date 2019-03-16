extends Node2D

export var path_to_exit_scene : String
signal level_requested(exit_path)

func _ready():
	call_deferred("start")

func start():
	#warning-ignore:return_value_discarded	
	$Area2D.connect("body_entered", self, "on_Area2D_body_entered")

#	var my_level = get_parent()	
#	if my_level.has("Params"):
#		if my_level.Params["Exit_Scene"] != null:
#			path_to_exit_scene = my_level.Params["Exit_Scene"]
#			print(self.name, " Exit_Scene == ", path_to_exit_scene)

func on_Area2D_body_entered(body : PhysicsBody2D):
	if body == null:
		return # why is this even happening? How do null bodies trigger the signal?
	
	print(self.name, " body entered: ", body )
	if body == global.player:
		#warning-ignore:return_value_discarded
#		get_tree().change_scene_to(target_scene)
#		global.player.get_node("Camera2D").zoom = Vector2(0.5, 0.5)
		
		connect("level_requested", global.main_scene, "_on_level_requested")
		emit_signal("level_requested", path_to_exit_scene)
		disconnect("level_requested", global.main_scene, "_on_level_requested")

	elif body.is_in_group("livestock"):
		body.queue_free()
		
		# need to send a signal to main to add one more sheep to Farm
		# we already know which scene the portal is connected to
		# but the scene isn't live.. so it'd have to be json or something
		
		# or we could tell the player that they're "carrying" sheep.
		# so when they reappear, the sheep appear with them.
		
		# someday, maybe.
		
		
		