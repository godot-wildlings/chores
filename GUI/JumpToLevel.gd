extends Button

signal level_requested(path_to_level)

onready var level_options = get_parent().get_node("ChooseLevel")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var levels = [
		"res://Levels/Caves.tscn",
		"res://Levels/NightFarm.tscn",
		"res://Levels/NightCaves.tscn",
		"res://Levels/InteriorCottageStart.tscn",
		"res://Levels/IllustratedManuscript.tscn",
		"res://Test/Test.tscn",
		"res://Levels/InteriorCottageEnd.tscn",
		"res://Levels/Book2.tscn",
		"res://Levels/GoodEnding.tscn",
		"res://Levels/EvilEnding.tscn",
	]

	var i = 0
	for level in levels:
		level_options.add_item(level, i)
		i += 1



	level_options.select(0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_JumpToLevel_pressed():
	var _err = connect("level_requested", global.main_scene, "_on_level_requested")
	if _err : push_warning(_err)
	emit_signal("level_requested", level_options.get_item_text(level_options.get_selected_id()))
	disconnect("level_requested", global.main_scene, "_on_level_requested")
	