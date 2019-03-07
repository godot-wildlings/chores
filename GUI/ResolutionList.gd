extends OptionButton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("1920x1080")
	add_item("1024x768")
	add_item("800x600")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ResolutionList_item_selected(ID):
	pass # Replace with function body.
