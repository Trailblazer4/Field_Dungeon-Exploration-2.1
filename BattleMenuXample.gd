extends Control

signal item_selection(selection, box)

var bme = load("res://BattleMenuElement.tscn")
var cursor: int = 0
#var defaultColor: Color = Color(0/255, 128/255, 125/255, 120/255)
#var selectColor: Color = Color(0/255, 148/255, 155/255, 150/255)
#var defaultColor: Color = Color(0.0, 0.501, 0.49, 0.4706)
#var selectColor: Color = Color(0.0, 0.5804, 0.6078, 0.588)
@export var defaultColor: Color = Color("00807d78")
@export var selectColor: Color = Color("00b9b582")
var limits: Array[int] = [0,8]

var spells = [
	#["Flame", "Ar", 20],
	#["Flame", "Ard", 40],
	#["Flame", "Ardent", 60],
	#["Flame", "Ar", 20],
	#["Flame", "Ard", 40],
	#["Flame", "Ardent", 60],
	#["Flame", "Ar", 20],
	#["Flame", "Ard", 40],
	#["Flame", "Ardent", 60],
	#["Flame", "Ar", 20],
	#["Flame", "Ard", 40],
	#["Flame", "Ardent", 60],
	#["Flame", "Ar", 20],
	#["Flame", "Ard", 40],
	#["Flame", "Ardent", 60],
]

var columns = 1

func _ready():
	#makeMagic(spells)
	if get_parent().has_method("on_item_selection"):
		item_selection.connect(get_parent().on_item_selection)
	

# i guess because of how it's set up already, i should make a function in this scene to create the magic menu
func makeMagic(spellList: Array[Spell]):
	spells = spellList
	for thing in $"VBoxContainer".get_children():
		$VBoxContainer.remove_child(thing)
		thing.queue_free()
	
	for i in range(len(spells)):
		var newLine = bme.instantiate()
		$VBoxContainer.add_child(newLine)
		
		newLine.get_node("HSplitContainer/Icon").text = str(spells[i].element)
		newLine.get_node("HSplitContainer/HSplitContainer/Name").text = spells[i].title
		newLine.get_node("HSplitContainer/HSplitContainer/SP Req").text = str(spells[i].spReq)
		newLine.get_node("ColorRect").color = defaultColor
		
		if i > 8:
			newLine.visible = false
	cursor = 0
	if len(spellList) > 0:
		$"VBoxContainer".get_child(cursor).get_node("ColorRect").color = selectColor


func makeItems(itemsList: Array, columns:int=1):
	self.columns = columns
	limits[1] *= 2
	
	spells = itemsList
	for thing in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(thing)
		thing.queue_free()
	
	for i in range(int(ceil(len(itemsList) / float(columns)))):
		var newLine = bme.instantiate()
		if columns > 1:
			var hsplit = HSplitContainer.new()
			hsplit.add_child(newLine)
			var anotherNewLine = bme.instantiate()
			hsplit.add_child(anotherNewLine)
			$VBoxContainer.add_child(hsplit)
		else:
			$VBoxContainer.add_child(newLine)
		
		newLine.get_node("HSplitContainer/Icon").text = "Healing"
		newLine.get_node("HSplitContainer/HSplitContainer/Name").text = itemsList[i*columns][0].title
		newLine.get_node("HSplitContainer/HSplitContainer/SP Req").text = "x%d" % itemsList[i*columns][1]
		newLine.get_node("ColorRect").color = defaultColor
		newLine.get_node("HSplitContainer").z_index = 1
		
		if columns > 1 && (i*columns+1) < len(itemsList):
			var anotherLine = newLine.get_parent().get_child(1)
			anotherLine.get_node("HSplitContainer/Icon").text = "Healing"
			anotherLine.get_node("HSplitContainer/HSplitContainer/Name").text = itemsList[i*columns+1][0].title
			anotherLine.get_node("HSplitContainer/HSplitContainer/SP Req").text = "x%d" % itemsList[i*columns+1][1]
			anotherLine.get_node("ColorRect").color = defaultColor
			anotherLine.get_node("HSplitContainer").z_index = 1
		
		#print(itemsList[i][0].title, "\n", itemsList[i][1], "\n")
		#print(newLine.get_node("HSplitContainer/HSplitContainer/Name").text)
		#print(newLine.get_node("HSplitContainer/HSplitContainer/SP Req").text, "\n")
		
		if i > 8:
			if columns == 1:
				newLine.visible = false
			else:
				newLine.get_parent().visible = false
	cursor = 0
	if len(itemsList) > 0:
		match columns:
			1:
				$"VBoxContainer".get_child(cursor).get_node("ColorRect").color = selectColor
			2:
				$"VBoxContainer".get_child(cursor/2).get_child(cursor%2).get_node("ColorRect").color = selectColor


func _process(delta):
	if Input.is_action_just_pressed("up") and cursor > 0:
		updateCursor(-1)
		if cursor < limits[0]:
			#for _i in columns:
			$VBoxContainer.get_child(limits[1] / columns).visible = false
			limits[0] -= columns; limits[1] -= columns
			$VBoxContainer.get_child(limits[0] / columns).visible = true

	if Input.is_action_just_pressed("down") and cursor < len(spells) - 1:
		updateCursor(1)
		if cursor > limits[1]:
			#for _i in columns:
			$VBoxContainer.get_child(limits[0] / columns).visible = false
			limits[0] += columns; limits[1] += columns
			$VBoxContainer.get_child(limits[1] / columns).visible = true
	
	if Input.is_action_just_pressed("left") && columns > 1 && cursor > 0:
		updateCursor(0, -1)
		if cursor < limits[0]:
			$VBoxContainer.get_child(limits[1] / columns).visible = false
			limits[0] -= columns; limits[1] -= columns
			$VBoxContainer.get_child(limits[0] / columns).visible = true
	
	if Input.is_action_just_pressed("right") && columns > 1 && cursor < len(spells) - 1:
		updateCursor(0, 1)
		if cursor > limits[1]:
			$VBoxContainer.get_child(limits[0] / columns).visible = false
			limits[0] -= columns; limits[1] -= columns
			$VBoxContainer.get_child(limits[1] / columns).visible = true
	
	if (Input.is_action_just_pressed("confirm") || Input.is_action_just_pressed("click")) and len(spells) > 0 and cursor > -1:
		item_selection.emit(spells[cursor], self)


func is_single_col():
	return $"VBoxContainer".get_child(0) is not HBoxContainer


func updateCursor(upDir: int, leftDir=0):
	if columns == 1:
		$VBoxContainer.get_child(cursor).get_node("ColorRect").color = defaultColor
		cursor += upDir
		cursor = clamp(cursor, 0, len(spells)-1)
		$VBoxContainer.get_child(cursor).get_node("ColorRect").color = selectColor
	else:
		$"VBoxContainer".get_child(cursor/2).get_child(cursor%2).get_node("ColorRect").color = defaultColor
		cursor += (upDir * 2) + leftDir
		cursor = clamp(cursor, 0, len(spells)-1)
		$"VBoxContainer".get_child(cursor/2).get_child(cursor%2).get_node("ColorRect").color = selectColor
	
