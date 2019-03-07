extends OptionButton

# Declare member variables here. Examples:
onready var global = get_node("/root/global")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("Easy")
	add_item("Medium")
	add_item("Hard")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DifficultyButton_item_selected(ID):
	global.set_difficulty(ID)
	pass # Replace with function body.
