extends Area2D

signal book_picked_up
signal level_requested(path_to_level)

func tell_player():
	var _err = connect("book_picked_up", global.player, "_on_book_picked_up")
	if _err: push_warning(_err)
	emit_signal("book_picked_up")
	disconnect("book_picked_up", global.player, "_on_book_picked_up")

func tell_main():
	var _err = connect("level_requested", global.main_scene, "_on_level_requested")
	if _err: push_warning(_err)
	emit_signal("level_requested", "res://Levels/IllustratedManuscript.tscn")


func _on_EvilBook_body_entered(body):
	if body == global.player:
		tell_player()
		tell_main()
		
		