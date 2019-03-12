extends Label

var MyNPC
var Ticks : int = 0

func _ready():
	MyNPC = get_parent()
	set_text(MyNPC.name)


func _process(_delta):
	Ticks += 1
	
	if Ticks % 40 == 0: # once a second or so
		if MyNPC.get_state() ==MyNPC.States.WAITING_FOR_DIALOG:
			set_text("press Space to interact")
		else:
			set_text(MyNPC.name)
