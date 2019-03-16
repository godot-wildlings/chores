extends KinematicBody2D

"""
NPC Characters


Should be able to do the following:
- Act friendly or hostile
- Spawn dialog boxes when player interacts with them
- Follow schedules and routines (go to house, go to work)
	- Needs navigation: https://www.youtube.com/watch?time_continue=8&v=Ad6Us73smNs
- Have short-term goals (chase, attack player or other entity)
- Give an item
- Take an item


"""

signal dialog_box_requested(textArr)


# Right now, I only have click-thru dialog boxes.
# I might need to add decision tree dialog boxes?
		# time permitting

# moved to Main
#signal started_chatting() # tell the player to stop shooting and moving
#signal stopped_chatting()

enum States { IDLE, WAITING_FOR_DIALOG, INTERACTING, MOVING, SLEEPING, FIGHTING }

#warning-ignore:unused_class_variable
var state_strings = ["IDLE", "WAITING_FOR_DIALOG", "INTERACTING", "MOVING", "SLEEPING", "FIGHTING"]

enum Goals { MOVE_RANDOMLY, TALK_TO_PLAYER, GO_HOME, GO_TO_WORK, FIGHT, FLEE, WORK, WAIT, SLEEP }


#warning-ignore:unused_class_variable
export var home : String = "House1"

#warning-ignore:unused_class_variable
export var reward_item : PackedScene

#warning-ignore:unused_class_variable
export var reward_item_name : String = "Axe"

export var dialog_box_title : String = "Introduction"
export var dialog_text_array : Array = [
		"Hello, Friederich!",
		"The Chaos Wastes are expanding. The beastmen are approaching. It's about time you learned to fight.",
		"Take this " + reward_item_name + " and fend off the next beastmen attack." 
]



var _state : int = States.IDLE setget set_state, get_state
var _goal : int = Goals.GO_TO_WORK

#onready var level : Node2D = global.main_scene.current_level_node

#warning-ignore:unused_class_variable
var target_destination : Vector2

var velocity : Vector2 = Vector2.ZERO
var direction_vector : Vector2 = Vector2.ZERO

#warning-ignore:unused_class_variable
var speed : float = 200.0

#var navigation : Navigation2D

func _ready():
	call_deferred("start")

func start():
	var err = connect("dialog_box_requested", global.main_scene, "_on_DialogBox_requested")
	if err: push_warning(err)
	
#	if level.has_node("Navigation2D"):
#		navigation = level.get_node("Navigation2D")
#	else:
#		push_warning("NPC, " + self.name + ", is lost. Can't find Navigation Node")
#

func _process(delta):
	consider_goals()
	move(delta)
	get_input()


func set_state(state):
	_state = state
	
func get_state():
	return _state

func consider_goals():
	match _goal:
		Goals.MOVE_RANDOMLY:
			direction_vector = global.rand_dir_float()
		Goals.TALK_TO_PLAYER:
			# move toward the player
			#target = level.get_player()
			pass


func get_input():
	if _state == States.WAITING_FOR_DIALOG:
		if Input.is_action_just_pressed("ui_accept"):
			_state = States.INTERACTING
			print(self.name, " requested dialog box: ", dialog_box_title)
			# moved started_chatting signal to main. it'll be required every time theres a dialog box
#			var _err = connect("started_chatting", global.player, "_on_NPC_started_chatting")
#			if _err: push_warning(_err)
			emit_signal("dialog_box_requested", dialog_box_title, dialog_text_array, self)
#			emit_signal("started_chatting")
#			disconnect("started_chatting", global.player, "_on_NPC_started_chatting")

func get_vector_toward_goal(_delta):
	# use the nav mesh on the level to get there.
	return Vector2.ZERO

	
func get_vector_away_from_NPCs(_delta):
	# go around NPCs in your way
	
	# check nearby objects in group "NPCs" and get the vector directly away from them
	return Vector2.ZERO


func move(delta):
	velocity += get_vector_toward_goal(delta)
	velocity += get_vector_away_from_NPCs(delta)
	
	var collision = move_and_collide(velocity * global.game_speed)
	if collision:
		#print(self.name, " ran into something")
		pass



func _on_DialogRange_body_entered(body):
	# player just showed up. Get ready to respond to interactions
	if _state != States.INTERACTING and body.name == "Player":
		_state = States.WAITING_FOR_DIALOG


func _on_DialogRange_body_exited(body):
	# player left. Go back to what you were doing
	if body.name == "Player":
		_state = States.IDLE
		# Maybe. It'll depend on Goal

func _on_DialogBox_completed(_title):
	# pick a new goal.
	_state = States.IDLE

	# moved to main
#	var _err = connect("stopped_chatting", global.player, "_on_NPC_stopped_chatting")
#	if _err: push_warning("Error in " + self.name + " _onDialogBox_completed: "  + str(_err))
#	emit_signal("stopped_chatting")
#	disconnect("stopped_chatting", global.player, "_on_NPC_stopped_chatting")
	