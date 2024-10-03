extends Sprite2D


var count = 0
var keys = ["Weapon 1", "Weapon 2", "Head", "Armor", "Gloves", "Legs", "Shoes", "Accessory 1", "Accessory 2"]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !visible:
		if Input.is_action_just_pressed("confirm"):
			visible = true
	elif visible and !get_parent().get_node_or_null("EquipPopup"):
		if Input.is_action_just_pressed("cancel"):
			visible = false
			count = 0
			position.y = 102
		if Input.is_action_just_pressed("up") and count > 0:
			count -= 1
			position.y -= 36
		if Input.is_action_just_pressed("down") and count < 8:
			count += 1
			position.y += 36
		if Input.is_action_just_pressed("confirm"):
			var this_slot = keys[count]
			#print(this_slot, ": ", get_parent().curr_char.current_equipment[this_slot].title)
			var show_equip = []
			for item in GameData.inventory:
				if item[0] is Equipment:
					if count < 2 and item[0].place == Equipment.places.WEAPON and item[0].type in get_parent().curr_char.prefs["weapons"]:
						show_equip.append(item)
					elif count >= 2 and item[0].place != Equipment.places.WEAPON and item[0].type in get_parent().curr_char.prefs["armors"]:
						show_equip.append(item)
			var eq_pop = load("res://BattleMenu.tscn").instantiate()
			eq_pop.makeItems(show_equip)
			get_parent().add_child(eq_pop)
			eq_pop.position = Vector2(850, 200)
			eq_pop.name = "EquipPopup"
		if Input.is_action_just_pressed("remove_equipment"):
			get_parent().curr_char.unequip(keys[count])
			get_parent().make_screen_from_character(get_parent().curr_char, [1])
	
	if get_parent().get_node_or_null("EquipPopup"):
		if Input.is_action_just_pressed("cancel"):
			get_parent().get_node("EquipPopup").queue_free()
		#if Input.is_action_just_pressed("confirm"):
			# = get_node("EquipPopup").cursor
