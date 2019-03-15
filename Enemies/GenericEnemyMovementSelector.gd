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
onready var enemy_types = get_parent().enemy_types

var default_movement
var default_walk_anim

func _ready():
	pass

func _physics_process(_delta):
	pass
# ToDo: fix blinking when flipping
#	if entity.type_of_enemy != enemy_types.BLINK:
#		if default_movement.Velocity.x > 0:
#			entity.scale.x = 1
#		elif default_movement.Velocity.x < 0:
#			entity.scale.x = -1

func start(type_of_enemy):
	set_default_movement(type_of_enemy)
	set_default_walk_anim(type_of_enemy)
	if entity.has_node("AnimationPlayer"):
		var anim_player = entity.get_node("AnimationPlayer")
		anim_player.play(default_walk_anim)
	
func set_default_movement(type_of_enemy):
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

func set_default_walk_anim(type_of_enemy):
	match type_of_enemy:
		enemy_types.RUSH:
			default_walk_anim = "enemy_melee_walk"
		enemy_types.KITE, enemy_types.BLINK:
			default_walk_anim = "enemy_ranged_walk"

func _on_entity_died():
	print(self.name, " received message: entity died" )
	_state = States.DEAD
	default_movement.set_state(default_movement.States.DISABLED)
	default_movement = null


