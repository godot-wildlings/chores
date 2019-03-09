"""
This comes from old code: might need cleaning up / refactoring. -PS

DialogBox displays a succession of text strings from an array.
Individual letters are revealed with keystroke audio on a timer timeout.

SceneTree should look like this:
	DialogBox : Panel
		dialog_text_box : RichTextEdit
			letter_timer : Timer
				KeypressNoise : AudioStream


"""
extends Panel

signal completed(boxName, requested_by)

export var dialog_text : Array  = [""]

var text_box : Panel
var letter_timer : Timer 
var keypress_audio : AudioStreamPlayer
var requested_by : Node
var current_line : int = 0
var num_letters_displayed : int = 0
var elapsed_time : float = 0.0
var displayed_text : String = ""
var current_line_text : String = ""
var box_title : String
#var node_to_follow

func _ready():
	text_box = $MarginContainer/DialogTextBox
	keypress_audio = $KeypressNoise
	letter_timer = $LetterTimer
	var _err = letter_timer.connect("timeout", self, "_on_LetterTimer_timeout")
	if _err: push_warning(_err)
		# I connect this signal in code rather than in the inspector, because
		# too many times I've had bugs related to inspector signals I forgot to connect.
	letter_timer.start()

func start(box_title : String, textArray : Array, parentScene : Node, requested_by : Node):
	self.box_title = box_title
	self.requested_by = requested_by
	self.dialog_text = textArray

	var _err = connect("completed", parentScene, "_on_DialogBox_completed")
	if _err: push_warning(_err)
	
	displayed_text = ""
	if dialog_text.size() > 0:
		current_line_text = dialog_text[0]
	else:
		end() # quit if there's no text to show
	letter_timer.start()
	text_box.set_bbcode(current_line_text)
	text_box.set_visible_characters(0)
	
func end():
	emit_signal("completed", box_title, requested_by)

	queue_free()

func show_next_line():
	current_line += 1
	num_letters_displayed = 0
	
	if current_line >= dialog_text.size():
		end()
	else:
		current_line_text = dialog_text[current_line]
		text_box.set_bbcode(current_line_text)
		text_box.set_visible_characters(num_letters_displayed)
		letter_timer.start()

func show_next_letter():
	if num_letters_displayed < current_line_text.length():
		letter_timer.start()
		num_letters_displayed += 1
		if keypress_audio.is_playing() == false:
			keypress_audio.set_pitch_scale(rand_range(0.9, 1.1))
			keypress_audio.set_volume_db(rand_range(-38.0, -28.0))
			keypress_audio.play()

	text_box.set_visible_characters(num_letters_displayed)
	#DialogBox.set_text(current_line_text.left(num_letters_displayed))

func reveal_all_letters_or_show_next_line():
	if num_letters_displayed < current_line_text.length(): # show the whole message
		num_letters_displayed = current_line_text.length()
	else: # show the next line
		show_next_line()

func _process(delta):
	elapsed_time += delta
	
	if Input.is_action_just_pressed("ui_cancel"):
		end()
	
#	if is_instance_valid(NodeToFollow):
#		set_global_position(NodeToFollow.get_global_position() + Vector2(0, -200))
	if Input.is_action_just_pressed("ui_accept"):
		reveal_all_letters_or_show_next_line()

	if Input.is_action_just_pressed("shoot"):
		reveal_all_letters_or_show_next_line()

func _on_LetterTimer_timeout():
	show_next_letter()

func _on_DialogTextBox_meta_clicked(meta):
	print(self.name, " meta == ", meta )
	#OS.execute(meta)
	var _err = OS.shell_open(meta)
	if _err: push_warning(_err)

func _on_Panel_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			reveal_all_letters_or_show_next_line()

func fast_forward_on_mouseclick(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			reveal_all_letters_or_show_next_line()

func _on_DialogBox_gui_input(event):
	fast_forward_on_mouseclick(event)

func _on_DialogTextBox_gui_input(event):
	fast_forward_on_mouseclick(event)
