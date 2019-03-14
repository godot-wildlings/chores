extends Node2D

# Declare member variables here. Examples:
enum States { DISABLED, ENABLED, RELOADING }
var _state = States.DISABLED

var entity
var target
var attack_ready : bool = false
export var attack_range = 75
export var projectile_scene : PackedScene
export var speed : float = 300

enum attack_types { MELEE, RANGED }
export (attack_types) var attack_type

var damage_per_attack = 1

signal hit(damage)
signal projectile_requested(pos, rot, vel)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

func start(newEntity, newTarget):
	entity = newEntity
	target = newTarget
	var err = connect("projectile_requested", global.current_level, "_on_projectile_requested")
	if err: push_warning(err)
	

func attack_ranged(attackTarget):
	print(attackTarget)
	print(self.name,  " attacking ", attackTarget.name )
	# ask level to spawn a projectile
	var myPos = $Muzzle.get_global_position()
	var targetPos = target.get_global_position()
	var deviation = rand_range(-5, 5) # in degrees, apparently
	var rot_deg = rad2deg(Vector2.RIGHT.angle_to(targetPos)) + deviation
	var initial_vel = Vector2.ZERO
	emit_signal("projectile_requested", projectile_scene, initial_vel, myPos, rot_deg )
	attack_ready = false
	
func attack_melee(attackTarget):
	if not is_instance_valid(attackTarget):
		return
	
	#print("CLAW CLAW")
	# no need for a projectile. just damage the target
	if attackTarget.has_method("_on_hit"):
		var err = connect("hit", attackTarget, "_on_hit")
		if err: push_warning(err)
		emit_signal("hit", damage_per_attack)
		disconnect("hit", attackTarget, "_on_hit")
	attack_ready = false
	
func set_state(newState):
	_state = newState


func in_range(attackTarget):
	if not is_instance_valid(attackTarget):
		return
		
	var myPos = entity.get_global_position()
	var targetPos = attackTarget.get_global_position()
	if myPos.distance_squared_to(targetPos) < attack_range * attack_range:
		return true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _state == States.ENABLED and entity.get_state() != entity.States.DEAD:
		if attack_ready and in_range(target):
			if attack_type == attack_types.MELEE:
				attack_melee(target)
			elif attack_type == attack_types.RANGED:
				attack_ranged(target)

func _on_attack_ready(): # signal from weapon selector
	attack_ready = true