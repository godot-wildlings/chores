extends Label

var MyNPC

func _ready():
	MyNPC = get_parent()

func _process(_delta):
	set_text(MyNPC.state_strings[MyNPC._state])
