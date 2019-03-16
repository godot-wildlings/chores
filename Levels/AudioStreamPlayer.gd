extends AudioStreamPlayer

onready var entity : Node2D = get_parent()

func _ready():
	var err = connect("finished", self, "_on_AudioStreamPlayer_finished")
	if err: push_warning(str(err))
	
func _on_AudioStreamPlayer_finished():
	if entity.has_node("AudioStreamPlayerLoop"):
		entity.get_node("AudioStreamPlayerLoop").play()