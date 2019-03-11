extends Node2D

signal dialog_box_requested(boxtitle, requestingScene)
signal new_level_requested(level_scene)

func _ready():
	pass # Replace with function body.

func start():
	connect("dialog_box_requested", global.main_scene, "_on_DialogBox_requested")
	
	var intro_text = [
			"You're a good boy, Friederich. You do your chores and complete your studies. \n\nGo see what your grandparents have for you today. \n\nI've gone to town.\n\tLove, Mother"
	]
	
	
	emit_signal("dialog_box_requested", "IntroText", intro_text, self)


func _on_DialogBox_completed(box_title):
	if box_title == "IntroText":
		connect("new_level_requested", global.main_scene, "_on_level_requested")
		emit_signal("new_level_requested", load("res://Levels/Farm.tscn"))
		
