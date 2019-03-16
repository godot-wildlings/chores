extends TextureProgress

# Declare member variables here. Examples:
onready var Baphomet = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	set_value(Baphomet.health / Baphomet.max_health * 100)
