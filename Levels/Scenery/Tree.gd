extends StaticBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	if randf() < 0.3:
		$Tree1.show()
		$Tree2.hide()
	else:
		$Tree1.hide()
		$Tree2.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
