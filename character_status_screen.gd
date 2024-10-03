extends Node2D


var curr_char
var pause_pointer = PauseMenu.get_node("Sprites/Pointer")

# Called when the node enters the scene tree for the first time.
func make_screen_from_character(pm: Entity, todo=[0,1]):
	curr_char = pm
	
	var portrait = get_node("PauseBackground/Sprite2D")
	var name_label = get_node("PauseBackground/Name")
	var stats_labels = [get_node("PauseBackground/Stats1"), get_node("PauseBackground/Stats2")]
	var eqp = get_node("Equipment/Weapon 1")
	if 0 in todo:# 0
		print("part 0: displaying sprite")
		var new_picture = pm.get_node("Sprite2D").duplicate()
		new_picture.set_frame(0)
		portrait.texture = new_picture.texture
		portrait.vframes = new_picture.vframes
		portrait.hframes = new_picture.hframes
		portrait.set_frame(0)
		portrait.scale = Vector2(3.5, 3.5)
		name_label.text = pm.myName
	if 1 in todo:# 1
		print("part 1: display stats & equipment")
		stats_labels[0].text = '''HP: %s
		Atk: %s
		Mag: %s
		Spd: %s''' % [pm.getHP(), pm.getAtk(), pm.getMag(), pm.getSpd()]
		
		stats_labels[1].text = '''SP: %s
		Def: %s
		MgDf: %s
		''' % [pm.getSP(), pm.getDef(), pm.getMgDf()]
		
		eqp.text = '''Weapon 1: %s
		Weapon 2: %s
		Head: %s
		Armor: %s
		Legs: %s
		Shoes: %s
		Gloves: %s
		Accessory 1: %s
		Accessory 2: %s
		''' % [pm.current_equipment["Weapon 1"].title, pm.current_equipment["Weapon 2"].title, pm.current_equipment["Head"].title,
		pm.current_equipment["Armor"].title, pm.current_equipment["Legs"].title, pm.current_equipment["Shoes"].title, pm.current_equipment["Gloves"].title,
		pm.current_equipment["Accessory 1"].title, pm.current_equipment["Accessory 2"].title]


func _ready():
	make_screen_from_character(GameData.party.get_child(pause_pointer.count).get_child(0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !get_node("Pointer").visible:
		if Input.is_action_just_pressed("cancel"):
			PauseMenu.remove_child(self)
			pause_pointer.visible = true
			PauseMenu.pauseQ = 0
			self.queue_free()
		
		if Input.is_action_just_pressed("left bumper"):
			pause_pointer.count -= 1
			if pause_pointer.count < 0:
				pause_pointer.count += GameData.party.size() # % doesn't work for negative exactly?
			print(pause_pointer.count % 4)
			pause_pointer.position.y = 20 + (pause_pointer.count * 140)
			make_screen_from_character(GameData.party.get_child(pause_pointer.count).get_child(0))
		
		if Input.is_action_just_pressed("right bumper"):
			pause_pointer.count += 1
			pause_pointer.count %= GameData.party.size()
			pause_pointer.position.y = 20 + (pause_pointer.count * 140)
			make_screen_from_character(GameData.party.get_child(pause_pointer.count).get_child(0))


func on_item_selection(selection, box):
	print(selection[0])
	print("x%d" % selection[1])
	print($Pointer.keys[$Pointer.count])
	curr_char.equip($Pointer.keys[$Pointer.count], selection[0])
	curr_char.info()
	box.queue_free()
	make_screen_from_character(curr_char, [1])
