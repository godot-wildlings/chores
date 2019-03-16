"""
Vocalization.gd should be responsible for:
	- making idle noises at random intervals
	- changing pitch and volume based on situation
	- making noises when entity gets hit
	- making attack noises

"""


extends Node2D

var NoiseTimer : Timer
var base_noise_time : float
onready var entity = get_parent()

func _ready():
	if has_node("NoiseTimer") == false:
		create_noise_timer()
	else:
		NoiseTimer = $NoiseTimer
	connect_noise_timer()
	base_noise_time = NoiseTimer.get_wait_time()
	reset_noise_timer()

func create_noise_timer():
	NoiseTimer = Timer.new()
	NoiseTimer.name = "NoiseTimer"
	add_child(NoiseTimer)
	NoiseTimer.set_wait_time(2.0)


func connect_noise_timer():
	var err = NoiseTimer.connect("timeout", self, "_on_NoiseTimer_timeout")
	if err: push_warning(err)
	
func reset_noise_timer():
	var min_time = base_noise_time * 0.8
	var max_time = base_noise_time * 1.2
	NoiseTimer.set_wait_time(rand_range(min_time, max_time))
	NoiseTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_pitch(size : float):  # expect a value between 0 and 1
	if size > 1 or size < 0:
		push_warning(self.name + " set_pitch() expected a value between 0 and 1")
	if has_node("AudioStreamPlayer2D"):
		$AudioStreamPlayer2D.set_pitch_scale(lerp(0.8, 1.3, size))

func set_random_pitch():
	set_pitch(randf())

func make_injury_noise():
	var injury_noisemaker : AudioStreamPlayer2D
	var types = entity.enemy_types
	if entity.type_of_enemy == types.BLINK:
		injury_noisemaker = $HumanInjuredNoise
		injury_noisemaker.set_pitch_scale(rand_range(0.5, 0.7))
	elif entity.type_of_enemy == types.RUSH:
		injury_noisemaker = $ZombieInjuredNoise
	elif entity.type_of_enemy == types.KITE:
		injury_noisemaker = $SkeletonInjuredNoise

	# should I check to see if it's already playing?
	# if I don't, it'll have better game feel, but I could get beatboxing monsters.
	injury_noisemaker.play()

func make_noise():
	
	set_random_pitch()
		
	if has_node("AudioStreamPlayer2D"):
		if $AudioStreamPlayer2D.is_playing() == false: # don't stutter/beatbox			 
			$AudioStreamPlayer2D.set_volume_db(rand_range(-40.0, -22.0))
			$AudioStreamPlayer2D.play()



func _on_NoiseTimer_timeout():
	var chance_of_bleeting = 0.2
	if randf() < chance_of_bleeting:
		make_noise()
	if global.main_scene.is_paused() == false:
		$NoiseTimer.set_wait_time(rand_range(1.0, 3.0))
		$NoiseTimer.start()

func _on_hit(_damage):
	
	make_injury_noise()
	
