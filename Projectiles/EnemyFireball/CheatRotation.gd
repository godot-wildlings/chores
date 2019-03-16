"""
Quick hack to make the flaming skull projectile always face up.

"""

extends Sprite

# Declare member variables here. Examples:
var last_x : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var myPos = get_global_position()
	set_global_rotation(0)
	if myPos.x < last_x:
		flip_h = true
	
	last_x = get_global_position().x
