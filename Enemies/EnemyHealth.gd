"""
EnemyHealth.gd should be responsible for 
	- receiving hits
	- taking damage
	- tracking health
	- dying
	- hiding or showing death sprites
	- disabling collision boxes
	- alerting the entity of life or death status
		- to prevent movement, vocalization and attacks

	
"""


extends Node2D

# Declare member variables here. Examples:
enum States { DEAD, ALIVE }
var state = States.ALIVE

export var max_health : float
export var health : float
onready var entity = get_parent()

signal dropped_below_zero()

# Called when the node enters the scene tree for the first time.
func _ready():
	if health < 0:
		die()

	var err = connect("dropped_below_zero", entity, "_on_Health_dropped_below_zero")
	if err : push_warning(err)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func is_alive():
	if state == States.ALIVE:
		return true
	else:
		return false

func get_health_ratio():
	var ratio = health / max_health
	#print(self.name, "get_health_ratio == ", ratio)
	return ratio
	

func die():
	$HealthBar.hide()
	emit_signal("dropped_below_zero")
	
func take_damage(damage):
	health -= damage
	if health <= 0:
		die()
	else:
		$HealthBar.set_value(get_health_ratio()*100)
		flash_red()
		
func flash_red():
	var node_to_colorize = entity

	var tween = entity.get_node("Tween")
	tween.interpolate_property(node_to_colorize, "modulate",
			Color.red, Color.white, .25,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_hit(damage): # signal from arrow
	take_damage(damage)

