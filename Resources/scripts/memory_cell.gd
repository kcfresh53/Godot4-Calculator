extends Panel

# Onready variables
@onready var memBtnContainer = get_node("VBoxContainer/memBtn_container")

# Variables
var number : float : set = _update_number

# Signals
signal clear(node)
signal add(node)
signal subtract(node)
signal hide

# Sets the value passed once instanced
func _ready():
	if number != null:
		$VBoxContainer/number_lbl.text = str(number)
	memBtnContainer.modulate = Color(0,0,0,0)
	self_modulate = Color("#202020")

# Updates the label if a number is changed
func _update_number(new_value):
	number = new_value
	$VBoxContainer/number_lbl.text = str(number)


func _on_mouse_entered():
	memBtnContainer.modulate = Color(255,255,255) #Show btn container
	self_modulate = Color("#393939") #Show hover color


func _on_mouse_exited():
	memBtnContainer.modulate = Color(0,0,0,0)
	self_modulate = Color("#202020") #Revert color


func _on_mc_btn_pressed():
	emit_signal("clear")


func _on_m_plus_btn_pressed():
	emit_signal("add")


func _on_m_sub_btn_pressed():
	emit_signal("subtract")


func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			emit_signal("hide")
