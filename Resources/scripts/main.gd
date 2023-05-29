extends ColorRect

# Onready Variables
@onready var btnContainer = get_node("Screen/Button_container/OperationBtn_container")
@onready var memoryBtnContainer = get_node("Screen/Button_container/MemoryBtn_container")
@onready var memScrollContainer = get_node("memory_pnl/memScrollContainer/VBoxContainer")
@onready var workArea = get_node("Screen/HBoxContainer/WorkArea_container/work_lbl")
@onready var prevWorkArea = get_node("Screen/HBoxContainer/WorkArea_container/prevWork_lbl")
@onready var history_pnl = get_node("history_pnl")
@onready var memory_pnl = get_node("memory_pnl")
@onready var overlay = get_node("overlay")

# Variables
var has_been_used = false
var operator = "" #stores the current working operator
var first_num : float #stores the first number
var second_num : float #stores the second number
var memory : Array = [] #stores number to Memory
var history : Dictionary = {} #stores calculation history
var animation_type = Tween.TRANS_CIRC #sets global tweening style
var animation_speed : float = 0.25 #sets global tween speed

# Resource Variables
var memoryCell_res : Resource = preload("res://Resources/scenes/memory_cell.tscn")


func _ready():
	# Connect number buttons to _numButtons()
	for btn in btnContainer.get_children():
		if btn.name.is_valid_int():
			btn.pressed.connect(Callable(self, "_numButtons").bind(btn))


#----------------------------------------------------------------
# All number buttons are connected to this function via a signal.
# When pressed, the button gets the number string it has and 
# sends it to the "work area" / screen.
# This is to reduce code complexity. 
#----------------------------------------------------------------
func _numButtons(btn):
	# to replace zero if no calculation has been done
	if has_been_used == false:
		workArea.text = btn.name
		has_been_used = true
	else:
		workArea.text += btn.name


# Clears both screens
func _on_clear_btn_pressed():
	workArea.text = "0"
	prevWorkArea.text = ""
	has_been_used = false


# Clears the base work area if a final answer is not given
func _on_clear_eq_btn_pressed():
	if has_been_used == true:
		workArea.text = "0"
		has_been_used = false
	else:
		# Called the clear button function to reduce code repitition
		_on_clear_btn_pressed()


#----------------------------------------------------------------
# If the work area has not been used, clear the previous work area
# else, delete singular characters until the last
# then replace with "0"
#----------------------------------------------------------------
func _on_delete_btn_pressed():
	if has_been_used == true:
		if workArea.text.length() >= 2:
			workArea.text = workArea.text.left(-1)
		else:
			# if the last number is removed, restore the screen to a cleared state
			workArea.text = "0"
			has_been_used = false


#----------------------------------------------------------------
# Sets has been  used to false after solving a problem
# this is to clear the screen with new numbers.
#----------------------------------------------------------------
func _on_equals_btn_pressed():
	has_been_used = false
	# Stores the result of the equation
	var result : float
	# Stores the second number
	second_num = workArea.text.to_float()
	# Add error Protection later
	
	if operator == "+":
		result = first_num + second_num
	elif operator == "-":
		result = first_num - second_num
	elif operator == "*":
		result = first_num * second_num
	elif operator == "/":
		result = first_num / second_num
	
	# Shows operation on the previous work area
	prevWorkArea.text = str(first_num) + " " + operator + " " + str(second_num) + " ="
	# Show the final output
	workArea.text = str(result)
	
	# Store the result in the history dictionary if there are no errors
	history[prevWorkArea.text] = workArea.text


#----------------------------------------------------------------
# Sets has been used to false after solving a problem
# this is to clear the screen with new numbers.
#----------------------------------------------------------------
func _on_plus_btn_pressed():
	has_been_used = false
	# Stores first number
	first_num = workArea.text.to_float()
	# Stores the operator
	operator = "+"
	# Shows the output on the previous 
	prevWorkArea.text = str(first_num) + " " + operator


func _on_minus_btn_pressed():
	has_been_used = false
	# Stores first number
	first_num = workArea.text.to_float()
	# Stores the operator
	operator = "-"
	# Shows the output on the previous 
	prevWorkArea.text = str(first_num) + " " + operator


func _on_multiply_btn_pressed():
	has_been_used = false
	# Stores first number
	first_num = workArea.text.to_float()
	# Stores the operator
	operator = "*"
	# Shows the output on the previous 
	prevWorkArea.text = str(first_num) + " " + operator


func _on_divide_btn_pressed():
	has_been_used = false
	# Stores first number
	first_num = workArea.text.to_float()
	# Stores the operator
	operator = "/"
	# Shows the output on the previous 
	prevWorkArea.text = str(first_num) + " " + operator


func _on_square_btn_pressed():
	has_been_used = false
	# Stores the result of the equation
	var result : float
	# Stores first number
	first_num = workArea.text.to_float()
	# Square the number
	result = first_num ** 2
	# Show the equation on the previous work area
	# Does not work exactly like the default app
	# May be changed later with history
	prevWorkArea.text = "sqr(" + workArea.text + ")"
	# Show the final result
	workArea.text = str(result)


func _on_square_root_btn_pressed():
	has_been_used = false
	# Stores the result of the equation
	var result : float
	# Stores first number
	first_num = workArea.text.to_float()
	# Root the number
	result = sqrt(first_num)
	# Show the equation on the previous work area
	# Does not work exactly like the default app
	# May be changed later
	prevWorkArea.text = "√(" + workArea.text + ")"
	# Show the final result
	workArea.text = str(result)


func _on_fraction_btn_pressed():
	has_been_used = false
	# Stores the result of the equation
	var result : float
	# Stores first number
	first_num = workArea.text.to_float()
	# Fraction the number
	result = 1 / first_num
	# Show the equation on the previous work area
	# Does not work exactly like the default app
	# May be changed later
	prevWorkArea.text = "1/(" + workArea.text + ")"
	# Show the final result
	workArea.text = str(result)


func _on_negate_btn_pressed():
	has_been_used = false
	# Stores the result of the equation
	var result : float
	# Stores first number
	first_num = workArea.text.to_float()
	# Fraction the number
	result = - first_num
	# Show the equation on the previous work area
	# Does not work exactly like the default app
	# May be changed later
	prevWorkArea.text = "negate(" + workArea.text + ")"
	# Show the final result
	workArea.text = str(result)


func _on_period_btn_pressed():
	# It just works like this in the official app
	if has_been_used == true:
		workArea.text = workArea.text + "."
	else:
		workArea.text = "0."
		has_been_used = true


# Stores munbers to memory
func _on_ms_btn_pressed():
	has_been_used = false
	# Add value to memory
	memory.append(workArea.text.to_float())
	# Enable any disabled memory buttons
	for btn in memoryBtnContainer.get_children():
		if btn.disabled == true:
			btn.disabled = false
	# Add memory cell to memScrollContainer
	var physical_mem = memoryCell_res.instantiate()
	# Set value before adding to scene tree
	physical_mem.number = workArea.text.to_float()
	# Add instance to container
	memScrollContainer.add_child(physical_mem)
	# Hide the warning label
	$memory_pnl/memWarning_lbl.visible = false
	# Connect the instanced memory cell signals
	physical_mem.clear.connect(self.memory_cell_clear.bind(physical_mem)) # clear
	physical_mem.add.connect(self.memory_cell_add.bind(physical_mem)) # add
	physical_mem.subtract.connect(self.memory_cell_sub.bind(physical_mem)) # subtract


# add to memory
func _on_m_plus_btn_pressed():
	has_been_used = false
	# If the memory is empty, add the current value to memory
	if memory.is_empty():
		_on_ms_btn_pressed()
	# Else add the current work area value to the last stored value
	else:
		memory[-1] += workArea.text.to_float()
		# Update GUI to show changes made
		memScrollContainer.get_child(-1).number = memory[-1]


# subtract from memory
func _on_m_minus_btn_pressed():
	has_been_used = false
	# If the memory is empty, add the current value to memory
	if memory.is_empty():
		# temporarily store the initial value
		# could be more efficient
		var tempWorkArea = workArea.text
		# Negate the value to be stored
		_on_negate_btn_pressed()
		_on_ms_btn_pressed()
		_on_clear_eq_btn_pressed()
		# Hide the operation carried out
		workArea.text = tempWorkArea
		# Else subtract the current work area value to the last stored value
	else:
		memory[-1] -= workArea.text.to_float()
		# Update GUI to show changes made
		memScrollContainer.get_child(-1).number = memory[-1]


# memory recall
func _on_mr_btn_pressed():
	has_been_used = false
	_on_clear_btn_pressed()
	workArea.text = str(memory[-1])


# memory clear
func _on_mc_btn_pressed():
	has_been_used = false
	# Erase the momory
	memory = []
	# Directly disable the memory buttons once the memory is empty
	$Screen/Button_container/MemoryBtn_container/mc_btn.disabled = true
	$Screen/Button_container/MemoryBtn_container/mr_btn.disabled = true
	$Screen/Button_container/MemoryBtn_container/mDown_btn.disabled = true
	# Make the warning label visible
	$memory_pnl/memWarning_lbl.visible = true
	# Delete instanced memory buttons
	for btn in $memory_pnl/memScrollContainer/VBoxContainer.get_children():
		btn.queue_free()


#----------------------------------------------------------------
# Make the memory panel visible
# Animate the panel size to the size of the numpad
# this is done to work with different monitor heights
#----------------------------------------------------------------
func _on_m_down_btn_pressed():
	var numpad_size = btnContainer.size #numpad size
	overlay.visible = true
	memory_pnl.visible = true
	var tween = get_tree().create_tween() #tween to animate GUI
	tween.tween_property(memory_pnl, "custom_minimum_size", numpad_size, animation_speed).set_trans(animation_type)


func _on_history_btn_pressed():
	var numpad_size = btnContainer.size #numpad size
	overlay.visible = true
	history_pnl.visible = true
	var tween = get_tree().create_tween() #tween to animate GUI
	tween.tween_property(history_pnl, "custom_minimum_size", numpad_size, animation_speed).set_trans(animation_type)



#----------------------------------------------------------------
# Appears with custom popups
# Causes popups to close once clicked
#----------------------------------------------------------------
func _on_overlay_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			# Wait for hide animation to finish
			await reset_popups()
			overlay.visible = false

# resets all popups
func reset_popups():
	for popup in get_tree().get_nodes_in_group("popup"):
		var tween = get_tree().create_tween() #tween to animate GUI
		tween.tween_property(popup, "custom_minimum_size", Vector2(0,0), animation_speed / 2).set_trans(animation_type)
		# Wait for hide animation to finish
		await  tween.finished
		popup.visible = false


#----------------------------------------------------------------
# Memory cell functions
# The instanced signals are connected to these functions
#----------------------------------------------------------------
func memory_cell_clear(node):
	# clear specific value
	memory.erase(node.number)
	# Delete the node
	node.queue_free()
	# If the memory is empty clear the memory
	if memory == []:
		_on_mc_btn_pressed()


func memory_cell_add(node):
	# get and add value from the workspace to the memory
	memory[node.get_index()] += workArea.text.to_float()
	# update gui
	memScrollContainer.get_child(node.get_index()).number = memory[node.get_index()]


func memory_cell_sub(node):
	# get and add value from the workspace to the memory
	memory[node.get_index()] -= workArea.text.to_float()
	# update gui
	memScrollContainer.get_child(node.get_index()).number = memory[node.get_index()]

