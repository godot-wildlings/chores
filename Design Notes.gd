"""
Quick scratch notes for getting started.


Project Page: https://github.com/godot-wildlings/gwj7

Razor / X-Statement:
	Our game is ...

Emotion / Mood / Aesthetic:
	...

Minimum Viable Product:
	What are the least features required to ship?
	...


Features Needed (owner):
	- Title Screen
	- Pause Menu
	- Dialog Boxes
	- Options Page
		- audio sliders
		- resolution

	- Game Scene
	- Level Switching
	- Player Avatars
		- Items
	- Obstacles
	- Enemies?

	- save/load game?

	...
Architecture:
	global.gd is an autoload for dependency injection and utility functions.
	most nodes should have:
		onready var global = get_node('/root/global') # at the top
	most nodes should have a state. For example:
		enum States { initializing, idle, hunting, retreating }
		var State = States.initializing

	
Bugs:
	probably use issues in github
		https://github.com/godot-wildlings/gwj7/issues

Game-Feel / Enhancements:
	probably use issues on github
		https://github.com/godot-wildlings/gwj7/issues


StyleGuides:
	Godot: http://docs.godotengine.org/en/latest/getting_started/scripting/gdscript/gdscript_styleguide.html
	GDQuest: http://docs.godotengine.org/en/latest/getting_started/scripting/gdscript/gdscript_styleguide.html

"""

extends Node
