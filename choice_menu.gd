extends Control

signal choice_selection(selection)

var cme = load("res://ChoiceMenuElement.tscn")
var cursor: int = 0
#var defaultColor: Color = Color(0/255, 128/255, 125/255, 120/255)
#var selectColor: Color = Color(0/255, 148/255, 155/255, 150/255)
#var defaultColor: Color = Color(0.0, 0.501, 0.49, 0.4706)
#var selectColor: Color = Color(0.0, 0.5804, 0.6078, 0.588)
@export var defaultColor: Color = Color("00807d78")
@export var selectColor: Color = Color("00b9b582")
var limits: Array[int] = [0,8]
var choices = []


func _ready():
	if get_parent().has_method("on_choice_selection"):
		choice_selection.connect(get_parent().on_choice_selection)


func makeChoices(choice_list: Array):
	choices = choice_list
	for thing in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(thing)
		thing.queue_free()
	
	for i in range(len(choice_list)):
		var newLine = cme.instantiate()
		$VBoxContainer.add_child(newLine)
		
		newLine.get_node("Name").text = choice_list[i]
		newLine.get_node("ColorRect").color = defaultColor
		
		if i > 8:
			newLine.visible = false
	cursor = 0
	if len(choice_list) > 0:
		$"VBoxContainer".get_child(cursor).get_node("ColorRect").color = selectColor


func _process(delta):
	if Input.is_action_just_pressed("up") and cursor > 0:
		updateCursor(-1)
		if cursor < limits[0]:
			$VBoxContainer.get_child(limits[1]).visible = false
			limits[0] -= 1; limits[1] -= 1
			$VBoxContainer.get_child(limits[0]).visible = true

	if Input.is_action_just_pressed("down") and cursor < len(choices) - 1:
		updateCursor(1)
		if cursor > limits[1]:
			$VBoxContainer.get_child(limits[0]).visible = false
			limits[0] += 1; limits[1] += 1
			$VBoxContainer.get_child(limits[1]).visible = true
	
	if Input.is_action_just_pressed("confirm") and len(choices) > 0:
		choice_selection.emit(cursor)


func updateCursor(upDir: int):
	$VBoxContainer.get_child(cursor).get_node("ColorRect").color = defaultColor
	cursor += upDir
	$VBoxContainer.get_child(cursor).get_node("ColorRect").color = selectColor
