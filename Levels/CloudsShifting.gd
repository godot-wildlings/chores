extends Sprite

# Declare member variables here. Examples:
var base_rect : Rect2
var texture_shift_x : float
export var speed_factor : float = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	base_rect = get_region_rect()
	texture_shift_x = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	texture_shift_x += 1 * speed_factor * delta
	texture_shift_x = wrapf(texture_shift_x, 0, base_rect.size.x)
	
	var new_rect = base_rect
	new_rect.position.x = texture_shift_x
	
	set_region_rect(new_rect)
