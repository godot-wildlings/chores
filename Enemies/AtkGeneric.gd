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
signal attack_completed()

func _process(_delta):
	if _state == States.ENABLED and entity.get_state() != entity.States.DEAD:
		if attack_ready and in_range(target):
			if attack_type == attack_types.MELEE:
				attack_melee(target)
			elif attack_type == attack_types.RANGED:
				attack_ranged(target)

func start(newEntity, newTarget):
	entity = newEntity
	target = newTarget
	var err = connect("projectile_requested", global.current_level, "_on_projectile_requested")
	if err: push_warning(err)
	err = connect("attack_completed", entity, "_on_attack_completed")

func attack_ranged(attackTarget):
		
	if entity.has_node("AnimationPlayer"): # this has to be first.
		var anim_player = entity.get_node("AnimationPlayer")
		anim_player.play(get_ranged_attack_animation(entity.type_of_enemy))
		yield(anim_player, "animation_finished")
		emit_signal("attack_completed")

	# player might have died before animation finished
	if is_instance_valid(attackTarget) == false:
		return
	
	
	# ask level to spawn a projectile
	var myPos = $Muzzle.get_global_position()
	#var myPos = entity.get_global_position()
	var targetPos = target.get_global_position()
	#var deviation = rand_range(-5, 5) # in degrees, apparently
	var deviation = 0.0
	var rot_deg = rad2deg(Vector2.RIGHT.angle_to(targetPos - myPos)) + deviation
	#var initial_vel = Vector2.ZERO
	var initial_vel = entity.get_velocity()
	attack_ready = false
	
	emit_signal("projectile_requested", projectile_scene, initial_vel, myPos, rot_deg )
	

func get_ranged_attack_animation(enemy_type):
	var type = entity.enemy_types
	match enemy_type:
		type.BLINK:
			return "enemy_blinker_attack"
			
		type.KITE:
			return "enemy_kiter_attack"
		type.RUSH:
			return "enemy_melee_attack"

		
	
func attack_melee(attackTarget):
	if not is_instance_valid(attackTarget):
		return
	attack_ready = false
	
	if has_node("Growl"):
		$Growl.play()
			
	if entity.has_node("AnimationPlayer"):
		var anim_player = entity.get_node("AnimationPlayer")
		anim_player.play("enemy_melee_attack")
		yield(anim_player, "animation_finished")
		
		#deal damage after the animation, not before
		if in_range(attackTarget):
			deal_damage(attackTarget)
		emit_signal("attack_completed")

func deal_damage(attackTarget):
	#print("CLAW CLAW")
	# no need for a projectile. just damage the target
	if has_node("ClawStrikeNoise"):
		$ClawStrikeNoise.play()

	if attackTarget.has_method("_on_hit"):
		var err = connect("hit", attackTarget, "_on_hit")
		if err: push_warning(err)
		emit_signal("hit", damage_per_attack)
		disconnect("hit", attackTarget, "_on_hit")

func set_state(newState):
	_state = newState

func in_range(attackTarget):
	if not is_instance_valid(attackTarget):
		return
		
	var myPos = entity.get_global_position()
	var targetPos = attackTarget.get_global_position()
	if myPos.distance_squared_to(targetPos) < attack_range * attack_range:
		return true

func _on_attack_ready(): # signal from weapon selector
	attack_ready = true