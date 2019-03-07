"""
This comes from old code: might need cleaning up / refactoring. -PS

DialogBox displays a succession of text strings from an array.
Individual letters are revealed with keystroke audio on a timer timeout.

SceneTree should look like this:
	DialogBox : Panel
		DialogTextBox : RichTextEdit
			LetterTimer : Timer
				KeypressNoise : AudioStream


"""

extends Panel

# Declare member variables here. Examples:
var TextBox : Panel
var LetterTimer : Timer 
var KeypressAudio : AudioStreamPlayer

export var DialogText : Array  = [""]

var CurrentLine = 0
var DisplayedText = ""
var CurrentLineText = ""
var NumLettersDisplayed : int = 0
var RequestedBy
var BoxTitle : String

var ElapsedTime : float = 0.0

#var NodeToFollow



signal completed(boxName, requestedBy)


# Called when the node enters the scene tree for the first time.
func _ready():
	TextBox = get_node("MarginContainer/DialogTextBox")
	KeypressAudio = get_node("KeypressNoise")
	LetterTimer = get_node("LetterTimer")
	var _err = LetterTimer.connect("timeout", self, "_on_LetterTimer_timeout")
	if _err: push_warning(_err)
		# I connect this signal in code rather than in the inspector, because
		# too many times I've had bugs related to inspector signals I forgot to connect.
	LetterTimer.start()
	



func start(boxTitle : String, textArray : Array, parentScene, requestedBy):
	BoxTitle = boxTitle
	DialogText = textArray
	RequestedBy = requestedBy

	var _err = connect("completed", parentScene, "_on_DialogBox_completed")
	if _err: push_warning(_err)
	
	DisplayedText = ""
	if DialogText.size() > 0:
		CurrentLineText = DialogText[0]
	else:
		end() # quit if there's no text to show
	LetterTimer.start()
	TextBox.set_bbcode(CurrentLineText)
	TextBox.set_visible_characters(0)
	
func end():
	emit_signal("completed", BoxTitle, RequestedBy)

	queue_free()

func showNextLine():
	CurrentLine += 1
	NumLettersDisplayed = 0
	if CurrentLine >= DialogText.size():
		end()
	else:
		CurrentLineText = DialogText[CurrentLine]
		TextBox.set_bbcode(CurrentLineText)
		TextBox.set_visible_characters(NumLettersDisplayed)
		LetterTimer.start()
		


func showNextLetter():
	if NumLettersDisplayed < CurrentLineText.length():
		LetterTimer.start()


		NumLettersDisplayed += 1
		KeypressAudio.play()
		
		
	TextBox.set_visible_characters(NumLettersDisplayed)
	#DialogBox.set_text(CurrentLineText.left(NumLettersDisplayed))

func revealAllLettersOrShowNextLine():
	if NumLettersDisplayed < CurrentLineText.length(): # show the whole message
		NumLettersDisplayed = CurrentLineText.length()
	else: # show the next line
		showNextLine()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ElapsedTime += delta
	
	if Input.is_action_just_pressed("ui_cancel"):
		end()
	
#	if is_instance_valid(NodeToFollow):
#		set_global_position(NodeToFollow.get_global_position() + Vector2(0, -200))
	if Input.is_action_just_pressed("ui_accept"):
		revealAllLettersOrShowNextLine()

	if Input.is_action_just_pressed("shoot"):
		revealAllLettersOrShowNextLine()



func _on_LetterTimer_timeout():
	showNextLetter()



func _on_DialogTextBox_meta_clicked(meta):
	print(self.name, " meta == ", meta )
	#OS.execute(meta)
	var _err = OS.shell_open(meta)
	if _err: push_warning(_err)
	

func _on_Panel_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			revealAllLettersOrShowNextLine()

func fast_forward_on_mouseclick(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			revealAllLettersOrShowNextLine()
			
func _on_DialogBox_gui_input(event):
	fast_forward_on_mouseclick(event)

func _on_DialogTextBox_gui_input(event):
	fast_forward_on_mouseclick(event)

