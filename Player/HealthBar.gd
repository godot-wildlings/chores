extends TextureProgress

# Declare member variables here. Examples:
onready var player = get_parent().get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_value(player.health / player.max_health * 100)
