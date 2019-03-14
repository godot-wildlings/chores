"""
Select a subcomponent which will move the entity

subcomponents provide various movement behaviours.
	Possibilities:
	- kite and shoot
	- rush and mob
	- rush, strike, then dodge
	- kite, teleport and shoot
	- try to get behind the player

Note, movement is disconnected from attacks.
The attack script will decide when to attack


"""

extends Node

enum States { INITIALIZING, IDLE, FLEEING, AVOIDING, DEAD }
#warning-ignore:unused_class_variable
var _state = States.INITIALIZING

onready var entity = get_parent()

var default_movement


func _ready():
	pass

func start(type_of_enemy):
	set_default_movement(type_of_enemy)
	
func set_default_movement(type_of_enemy):
	var enemy_types = get_parent().enemy_types
	
	match type_of_enemy:
		enemy_types.RUSH:
			default_movement = $Rush
		enemy_types.KITE:
			default_movement = $Kite
		enemy_types.BLINK:
			default_movement = $Blink
			
	default_movement.set_state(default_movement.States.ENABLED)
	if default_movement.has_method("start"):
		default_movement.start(entity, global.player)


func _on_entity_died():
	print(self.name, " received message: entity died" )
	_state = States.DEAD
	default_movement.set_state(default_movement.States.DISABLED)
	default_movement = null


