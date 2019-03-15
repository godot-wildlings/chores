"""
Take hits and relay the info to parent
"""

extends Area2D

signal received_hit(damage)
var Entity # might be kinematic or might be area. not sure yet



func _ready():
	Entity = get_parent()
	var err = connect("received_hit", Entity, "_on_Hitbox_received_hit")
	if err : push_warning(err)
	
func _on_hit(damage):
	#print("Hitbox received his. relaying to Entity: ", Entity)
	emit_signal("received_hit", damage, "physical")
	# later we might want to introduce damage types
	