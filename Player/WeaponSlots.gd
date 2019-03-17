extends Node2D
"""
Weapon slots

Does the following:
- Makes sure the currently equipped weapons (both melee & raned) are correctly orientated,
	based on the players mouse position
- Adjusts the weapons sprite z-index depth in order to hide it behind the players head, 
	when pointing the weapon above him
- Flips weapon sprites on y axis based on the mouse position.x
"""
signal weapon_changed

export var offset_distance : float = 10

var active_weapon : Node2D setget _set_active_weapon
var active_weapon_sprite : Sprite

#func _ready():
#	if $Melee.get_child_count() > 0:
#		var first_melee_weapon = $Melee.get_child(0)
#		if first_melee_weapon.is_in_group("melee_weapons"):
#			self.active_weapon = first_melee_weapon
#	elif $Ranged.get_child_count() > 0:
#		var first_ranged_weapon = $Ranged.get_child(0)
#		if first_ranged_weapon.is_in_group("ranged_weapons"):
#			self.active_weapon = first_ranged_weapon

#warning-ignore:unused_argument
func _process(delta : float):
	if Input.is_action_pressed("equip_melee_weapon"):
		_equip_first_melee_weapon()
	elif Input.is_action_pressed("equip_ranged_weapon"):
		_equip_first_ranged_weapon()

	_orientate_weapon()
#	_adjust_weapon_depth()
	#_flip_weapon_sprites()

func attack():
	active_weapon.attack()

func _orientate_weapon():
	#position = Vector2.ZERO
#	rotation = 0
#
#	#var new_position : Vector2 = get_local_mouse_position().normalized() * offset_distance
	var myPos = get_global_position()
	var mousePos = get_global_mouse_position()

	
	var vector_to_mouse = mousePos - myPos
	
	var rot_to_mouse
	if sign(vector_to_mouse.x) > 0:
		rot_to_mouse = Vector2.RIGHT.angle_to_point(vector_to_mouse)
	else:
		
		vector_to_mouse.y *= -1
		
		rot_to_mouse = Vector2.LEFT.angle_to_point(vector_to_mouse)
	#var new_rotation : float = get_local_mouse_position().angle()
#
#
#	#position = new_position
	
	
	
	var mouse_side = sign(vector_to_mouse.x)
	flip_left_bow(mouse_side)
	
	set_global_rotation(rot_to_mouse + mouse_side * PI)


func flip_left_bow(direction):
	scale.y = direction


#func _adjust_weapon_depth():
#	if position.y >= 0:
#		z_index = 1
#	else:
#		z_index = -1
#
#func _flip_weapon_sprites():
#	var new_scale_y : float = 0
#	if position.x > 0:
#		new_scale_y = 1
#	elif position.x < 0:
#		new_scale_y = -1
#
func _equip_first_melee_weapon():
	if $Melee.get_child_count() > 0:
		self.active_weapon = $Melee.get_child(0)

func _equip_first_ranged_weapon():
	if $Ranged.get_child_count() > 0:
		self.active_weapon = $Ranged.get_child(0)

func _set_active_weapon(new_active_weapon):
	if new_active_weapon != active_weapon:
		active_weapon = new_active_weapon
		if new_active_weapon.has_node("Sprite" + str(active_weapon.name)):
			active_weapon_sprite = new_active_weapon.get_node("Sprite" + str(active_weapon.name)) as Sprite
		emit_signal("weapon_changed")

func _on_weapon_requested(weapon_name): # signal from player
	if $Ranged.has_node(weapon_name):
		self.active_weapon = $Ranged.get_node(weapon_name)
	elif $Melee.has_node(weapon_name):
		self.active_weapon = $Melee.get_node(weapon_name)
	else:
		push_error(self.name + " doesn't have that weapon: " + weapon_name)
	
	
	