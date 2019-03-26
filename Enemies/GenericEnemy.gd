"""
An enemy will be composed of a conductor and various subsystems
GenericEnemy.gd is the conductor. The entity should also have nodes for:
	- Movement
	- Vocalization
	- Attacks
	- Health
		

GenericEnemy.gd itself should be responsible for:
	- relaying signals between subsystems:
		eg: health takes damage, then vocalization makes noise
	- deciding which type of behaviour to ask subsystems for
	- acting as eyes and ears for subsystems
	
"""

extends KinematicBody2D

onready var Health = $Health
onready var Movement = $Movement
#warning-ignore:unused_class_variable
onready var Attacks = $Attacks
onready var Vocalization = $Vocalization
onready var Hitbox = $Hitbox


enum enemy_types { RUSH, KITE, BLINK, MOB, SNEAKY }
export (enemy_types) var type_of_enemy = enemy_types.RUSH

enum States { DEAD, IDLE, FLEEING, ATTACKING, SNEAKING }
var _state = States.IDLE

export var immunities : Dictionary = { 
		"physical": false,
		"magical": false
	}


#var BehaviourTimer : Timer
#var base_behaviour_time : float = 3.0

signal hit(damage)
signal died()

func _ready():
	set_random_size(get_scale(), 0.2)
	set_random_color()
	
#	if Health.is_alive():
#		choose_behaviour()
	
	#setup_behaviour_timer()

	connect_signals()
	initialize_components()
	
func initialize_components():
	Movement.start(type_of_enemy)

	
func get_state():
	return _state
	
func is_dead():
	if _state == States.DEAD:
		return true
	else:
		return false
		
func connect_signals():
	var err = connect("hit", Health, "_on_hit")
	if err: push_warning(err)

	err = connect("hit", Vocalization, "_on_hit")
	if err: push_warning(err)

	err = connect("died", Movement, "_on_entity_died")
	if err: push_warning(err)


#All this behaviour signalling is unimplemented	
#func setup_behaviour_timer():
#	if has_node("BehaviourTimer") == false:
#		create_behaviour_timer()
#	BehaviourTimer = $BehaviourTimer
#	base_behaviour_time = BehaviourTimer.get_wait_time()
#	connect_behaviour_timer()
#	reset_behaviour_timer()
#
#func create_behaviour_timer():
#	BehaviourTimer = Timer.new()
#	BehaviourTimer.name = "BehaviourTimer"
#	add_child(BehaviourTimer)
#	BehaviourTimer.set_wait_time(base_behaviour_time)
#
#
#func connect_behaviour_timer():
#	var err = BehaviourTimer.connect("timeout", self, "_on_BehaviourTimer_timeout")
#	if err : push_warning("Error connecting BehaviourTimer: " + str(err))
#
#func reset_behaviour_timer():
#	var min_time = base_behaviour_time * 0.8
#	var max_time = base_behaviour_time * 1.2
#	BehaviourTimer.set_wait_time(rand_range(min_time, max_time))
#	BehaviourTimer.start()


	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func set_random_size(base_scale : Vector2, deviation : float):
	if deviation < 0 or deviation > 1:
		push_warning(self.name + " expected deviation between 0 and 1. Not: " + str(deviation)) 
		
	var rand_deviation = rand_range(1 - deviation, 1 + deviation)
	set_scale(base_scale * rand_deviation)
	
func set_random_color():
	var lightness = rand_range(0.7, 1.0)
	set_modulate(Color(lightness, lightness, lightness))

func choose_behaviour():
	
	#print(self.name, ": choose_behaviour not yet implemented." )
	pass
	

func die():
	# spawn a blood splotch and a dead sheep sprite
	_state = States.DEAD
	disable_hitboxes()
	var entity = self
	entity.remove_from_group("enemies")
	entity.Hitbox.remove_from_group("enemies")
	
	print(entity.get_groups())
	entity.get_node("DeadBody").show()
	entity.get_node("LiveBody").hide()
	entity.get_node("AnimationPlayer").stop()
	entity.get_node("BehaviourTimer").stop()
	Vocalization.get_node("NoiseTimer").stop()
	place_corpse_behind_live_enemies()
	emit_signal("died")

func place_corpse_behind_live_enemies():
	var entity = self
	#entity.set_z_index(-1)
	entity.get_parent().move_child( entity, 0 )
	

func disable_hitboxes():
	get_node("CollisionShape2D").call_deferred("set_disabled", true)
	Hitbox.get_node("CollisionShape2D").call_deferred("set_disabled", true)

func enable_hitboxes():
	get_node("CollisionShape2D").call_deferred("set_disabled", false)
	Hitbox.get_node("CollisionShape2D").call_deferred("set_disabled", false)
		
func get_velocity():
	return Movement.get_velocity()
	
func _on_BehaviourTimer_timeout():
	pass
	# not yet implemented.

func _on_Hitbox_received_hit(damage, damage_type):
	#print("Entity received hit" )
	#print("immunities: ", immunities)
	if immunities[damage_type] == false:
		
		
		emit_signal("hit", damage)

func _on_Health_dropped_below_zero():
	die()


func _on_teleport_requested():
	call_deferred("disable_hitboxes")

func _on_teleport_completed():
	call_deferred("enable_hitboxes")
	
func _on_attack_completed():
	Movement.walk()
	