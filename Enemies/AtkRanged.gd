extends Node2D

# Declare member variables here. Examples:
enum States { DISABLED, ENABLED, RELOADING }
var _state = States.DISABLED

var entity
var target
var attack_ready : bool = false
export var attack_range = 400
export var projectile_scene : PackedScene
export var speed : float = 300

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
	

func attack(attackTarget):
	var myPos = $Muzzle.get_global_position()
	var targetPos = target.get_global_position()
	var target_vector = (targetPos - myPos).normalized()
	var deviation = 0.1 # add some variation because we don't know how to lead the player yet
	target_vector = target_vector.rotated(rand_range(-deviation, deviation))
	var rot = Vector2.RIGHT.angle_to(targetPos)
	var vel = target_vector * speed
	emit_signal("projectile_requested", projectile_scene, myPos, rot, vel)
	attack_ready = false
	
	
	
func set_state(newState):
	_state = newState


# Whoops: this is for melee
#	if attackTarget.has_method("_on_hit"):
#		var err = connect("hit", attackTarget, "_on_hit")
#		if err: push_warning(err)
#		emit_signal("hit", damage_per_attack)
#		disconnect("hit", attackTarget, "_on_hit")

func in_range(attackTarget):
	var myPos = entity.get_global_position()
	var targetPos = attackTarget.get_global_position()
	if myPos.distance_squared_to(targetPos) < attack_range * attack_range:
		return true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _state == States.ENABLED and entity.get_state() != entity.States.DEAD:
		if attack_ready and in_range(target):
			attack(target)

func _on_attack_ready(): # signal from weapon selector
	attack_ready = true