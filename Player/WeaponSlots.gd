extends Node2D
"""
Weapon slots

Does the following:
- Makes sure the currently equipped weapons (both melee & raned) are correctly orientated,
	based on the players mouse position
- Adjusts the weapons sprite z-index depth in order to hide it behind the players head, 
	when pointing the weapon above him
- Flips weapon sprites on y axis based on the mouse position.x

ToDo's:
	- Player can only always have one of either ranged or melee weapons equipped
"""
signal weapon_changed

export var offset_distance : float = 10

var active_weapon : Node2D setget _set_active_weapon
var active_weapon_sprite : Sprite

func _ready():
	if $Melee.get_child_count() > 0:
		var first_melee_weapon = $Melee.get_child(0)
		if first_melee_weapon.is_in_group("melee_weapons"):
			self.active_weapon = first_melee_weapon
	elif $Ranged.get_child_count() > 0:
		var first_ranged_weapon = $Ranged.get_child(0)
		if first_ranged_weapon.is_in_group("ranged_weapons"):
			self.active_weapon = first_ranged_weapon

#warning-ignore:unused_argument
func _process(delta : float):
	if Input.is_action_pressed("equip_melee_weapon"):
		_equip_first_melee_weapon()
	elif Input.is_action_pressed("equip_ranged_weapon"):
		_equip_first_ranged_weapon()

	_orientate_weapon()
	_adjust_weapon_depth()
	_flip_weapon_sprites()

func attack():
	active_weapon.attack()

func _orientate_weapon():
	position = Vector2.ZERO
	rotation = 0
	
	var new_position : Vector2 = get_local_mouse_position().normalized() * offset_distance
	var new_rotation : float = get_local_mouse_position().angle()
	
	position = new_position
	rotation = new_rotation
	
func _adjust_weapon_depth():
	if position.y >= 0:
		z_index = 1
	else:
		z_index = -1
	
func _flip_weapon_sprites():
	var new_scale_y : float = 0
	if position.x > 0:
		new_scale_y = 1
	elif position.x < 0:
		new_scale_y = -1
	
func _equip_first_melee_weapon():
	if $Melee.get_child_count() > 0:
		self.active_weapon = $Melee.get_child(0)

func _equip_first_ranged_weapon():
	if $Ranged.get_child_count() > 0:
		self.active_weapon = $Ranged.get_child(0)

func _set_active_weapon(new_active_weapon):
	if new_active_weapon != active_weapon:
		active_weapon = new_active_weapon
		active_weapon_sprite = new_active_weapon.get_node("Sprite" + str(active_weapon.name)) as Sprite
		emit_signal("weapon_changed")
