extends Button

signal level_requested(path_to_level)

onready var level_options = get_parent().get_node("ChooseLevel")

# Called when the node enters the scene tree for the first time.
func _ready():
	level_options.add_item("Caves", 0)
	level_options.set_item_text(0, "res://Levels/Caves.tscn")

	level_options.add_item("Farm", 1)
	level_options.set_item_text(1, "res://Levels/NightFarm.tscn")

	level_options.add_item("NightCaves", 2)
	level_options.set_item_text(2, "res://Levels/NightCaves.tscn")

	level_options.add_item("Cottage", 3)
	level_options.set_item_text(3, "res://Levels/InteriorCottageStart.tscn")

	level_options.add_item("Cottage", 4)
	level_options.set_item_text(4, "res://Levels/IllustratedManuscript.tscn")

	level_options.add_item("Test", 5)
	level_options.set_item_text(5, "res://Test/Test.tscn")


	level_options.select(0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_JumpToLevel_pressed():
	var _err = connect("level_requested", global.main_scene, "_on_level_requested")
	if _err : push_warning(_err)
	emit_signal("level_requested", level_options.get_item_text(level_options.get_selected_id()))
	disconnect("level_requested", global.main_scene, "_on_level_requested")
	