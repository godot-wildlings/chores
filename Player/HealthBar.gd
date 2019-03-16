extends TextureProgress

# Declare member variables here. Examples:
onready var player = get_parent().get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	set_value(float(player.health) / float(player.max_health) * 100.0)
