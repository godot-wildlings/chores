extends AudioStreamPlayer

onready var entity : Node2D = get_parent()

func _ready():
	connect("finished", self, "_on_AudioStreamPlayer_finished")
	
func _on_AudioStreamPlayer_finished():
	if entity.has_node("AudioStreamPlayerLoop"):
		entity.get_node("AudioStreamPlayerLoop").play()