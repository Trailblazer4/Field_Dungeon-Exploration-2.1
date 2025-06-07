extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# handle mouse inputs
	#if active && Input.is_action_just_pressed("click"):
		#menu.item_selection.emit(menu.spells[menu.cursor], menu)
		#print("Used")
	pass


var active: bool = false
var menu
func _on_mouse_entered():
	menu = get_parent().get_parent()
	active = true
	#$VBoxContainer.get_child(cursor).get_node("ColorRect").color = defaultColor
	get_parent().get_child(menu.cursor).get_node("ColorRect").color = menu.defaultColor
	#cursor += upDir
	menu.cursor = get_parent().get_children().find(self)
	print(menu.cursor)
	#$VBoxContainer.get_child(cursor).get_node("ColorRect").color = selectColor
	get_node("ColorRect").color = menu.selectColor


func _on_mouse_exited():
	active = false
	get_node("ColorRect").color = menu.defaultColor
	menu.cursor = -1
