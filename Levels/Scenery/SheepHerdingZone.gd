extends Area2D

signal dialog_box_requested(textArr)

export var min_amount_of_sheeps_to_rescue : int = 3
export var dialog_box_title : String = "Thank you!"
export var dialog_text_array : Array = [
		"Thanks for all your help, Friedrich.",
		"We depend on you so much. I don't know what I'd do without you."
]

var amount_of_rescued_sheep : int = 0
var total_amount_of_sheep : int = 0
var dialog_shown : bool = false

func _ready() -> void:
	#warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_Area2D_body_entered")
	call_deferred("start")

func start() -> void:
	var err = connect("dialog_box_requested", global.main_scene, "_on_DialogBox_requested")
	if err: push_warning(err)
	if global.current_level:
		if global.current_level.has_node("Animals"):
			var animal_container : Node2D = global.current_level.get_node("Animals")
			if animal_container.has_node("FlockOfSheep"):
				total_amount_of_sheep = animal_container.get_node("FlockOfSheep").get_child_count()

func express_gratitude():
	emit_signal("dialog_box_requested", dialog_box_title, dialog_text_array, self)
	dialog_shown = true
		
func _on_Area2D_body_entered(body : PhysicsBody2D) -> void:
	if body.is_in_group("livestock"):
		amount_of_rescued_sheep += 1
		if not dialog_shown and amount_of_rescued_sheep >= min_amount_of_sheeps_to_rescue:
			express_gratitude()
		
#warning-ignore:unused_argument
func _on_DialogBox_completed(title: String) -> void:
	pass