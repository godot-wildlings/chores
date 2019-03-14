extends Node2D

# Declare member variables here. Examples:
var default_weapon
var entity
var target
var attack_timer

signal attack_ready

# Called when the node enters the scene tree for the first time.
func _ready():
	attack_timer = $AttackTimer
	call_deferred("start")

func start(): # should be called from Entity, but we'll call it from _ready for now
	entity = get_parent()
	target = global.player

	set_default_weapon()
	initialize_attack_timer()



	
func set_default_weapon():
	var enemy_types = entity.enemy_types
	match entity.type_of_enemy:
		enemy_types.RUSH:
			default_weapon = $Claws
		enemy_types.KITE:
			default_weapon = $Bullet
		enemy_types.BLINK:
			default_weapon = $Bullet
		
	default_weapon.set_state(default_weapon.States.ENABLED)
	default_weapon.start(entity, global.player)

	var err = connect("attack_ready", default_weapon, "_on_attack_ready")
	if err: push_warning(str(err))

	
	
func initialize_attack_timer():
	attack_timer.set_wait_time(rand_range(0.8, 1.2))
	attack_timer.connect("timeout", self, "_on_AttackTimer_timeout")
	attack_timer.start()
			
			
func _on_AttackTimer_timeout():
	emit_signal("attack_ready")
	attack_timer.start()
	
