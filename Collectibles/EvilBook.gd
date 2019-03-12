extends Area2D

signal book_picked_up
signal level_requested(path_to_level)

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("level_requested", global.main_scene, "_on_level_requested")


func _on_EvilBook_body_entered(body):
	if body == global.player:
		connect("book_picked_up", global.player, "_on_book_picked_up")
		emit_signal("book_picked_up")
		disconnect("book_picked_up", global.player, "_on_book_picked_up")
	
		connect("level_requested", global.main_scene, "_on_level_requested")
		emit_signal("level_requested", "res://Levels/IllustratedManuscript.tscn")
		