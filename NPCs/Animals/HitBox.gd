"""
Simple relay of _on_hit signals. Arrows will detect the hitbox instead of the root Sheep node
"""

extends Area2D

signal hit(damage)

# Called when the node enters the scene tree for the first time.
func _ready():
	var _err = connect("hit", get_parent(), "_on_hit")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_hit(damage):
	print(self.name, " received hit for ", damage )
	emit_signal("hit", damage)
	