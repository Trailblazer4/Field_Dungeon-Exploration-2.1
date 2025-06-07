extends Node2D

var level0 = GameData.Levels[0]
# Called when the node enters the scene tree for the first time.

var moveset = ["a", "b", "c", "d", "e", "f", "g", "h", "i"]
var priority_list = [4, 14, 16, 3, 2, -1000, 1, 0, -100]

var master_sword = GameData.EquipmentLibrary["Master Sword"]
var primal = GameData.EquipmentLibrary["Primal"]

var silver_armor = GameData.EquipmentLibrary["Silver Armor"]

#var d = {
	#"a": func(): get_tree().quit()
#}

@onready var materials_req = {
	"Magic Starter Gem": 2,
	"Fire Gem": 3,
}

func can_make(materials: Dictionary, inventory: Dictionary):
	var enough = func(material): return inventory.has(material) and inventory[material] >= materials[material]
	return materials.keys().all(enough)


func consume(materials: Dictionary, inventory: Dictionary):
	for material in materials:
		inventory[material] -= materials_req[material]


@onready var combo: Array = []

func lagrange(x, start, mid, end) -> float:
	if start.x == mid.x or start.x == end.x or mid.x == end.x:
		push_error("Lagrange interpolation requires distinct x values")
		return 0.0
	
	return start.y * (x - mid.x) * (x - end.x) / ((start.x - mid.x) * (start.x - end.x)) \
			+ mid.y * (x - start.x) * (x - end.x) / ((mid.x - start.x) * (mid.x - end.x)) \
			+ end.y * (x - start.x) * (x - mid.x) / ((end.x - start.x) *(end.x - mid.x))

func _ready():
	print(lagrange(
		3,
		Vector2(1, 2),
		Vector2(2, 3),
		Vector2(4, 1)
	)) # should print out 2.67
	
	var line1: Vector2 = Vector2(0, 5)
	var line2: Vector2 = Vector2(5, 0)
	print(line1 * line2)
	print(line1.dot(line2))
	print(line2.cross(line1))
	print(line2.distance_to(line1))
	
	#add_child(cache)
	#cache.start()
	
	var inventory: Dictionary = {
		"Fire Gem": 4,
		"Magic Starter Gem": 7
	}
	
	print(inventory)
	if can_make(materials_req, inventory):
		consume(materials_req, inventory)
	print(inventory)
	
	GameData.inventory.append([GameData.EquipmentLibrary["Super Suit"], 1])
	
	var types = [null, true, 1, 1.2, "string", GameData.ALL_PLAYABLE_CHARACTERS[0]]
	for type in types:
		print(type, ":", typeof(type))
	
	#print(GameData.EquipmentLibrary.values())
	Overlay.color.a = 0
	#print(GameData.ALL_PLAYABLE_CHARACTERS[0].get1())
	
	#print(moveset)
	#print(priority_list)
	#priority_sort(moveset, priority_list)
	#print(moveset)
	#print(priority_list)
	
	#print(GameData.EquipmentLibrary["Master Sword"])
	
	var link = GameData.ALL_PLAYABLE_CHARACTERS[2]
	link.info()
	link.equip("Weapon 1", master_sword)
	link.info()
	var zero = GameData.ALL_PLAYABLE_CHARACTERS[6]
	zero.equip("Weapon 1", primal)
	zero.unequip("Weapon 1")
	zero.equip("Weapon 1", GameData.EquipmentLibrary["Mega Buster"])
	zero.unequip("Weapon 1")
	zero.equip("Weapon 1", GameData.EquipmentLibrary["Yontou-Jishi"])
	zero.unequip("Weapon 1")
	#link.unequip("Weapon 1")
	#link.info()

	GameData.ALL_PLAYABLE_CHARACTERS[0].equip("Armor", silver_armor)
	#GameData.ALL_PLAYABLE_CHARACTERS[0].unequip("Armor")
	#link.equip("Weapon 1", GameData.EquipmentLibrary["Primal"])
	#link.info()
	#link.unequip("Weapon 1")
	#link.info()


func _input(event):
	#print(event)
	add_to_combo(event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("start") || Input.is_action_just_pressed("click"):
		Overlay.play("fadeout_menu")
		var anim_name = await Overlay.finished()
		if anim_name == "fadeout_menu":
			get_tree().change_scene_to_file("res://character_select.tscn")
	#if Input.is_action_just_pressed("up"):
		#d["a"].call()
	#else:
		#cache.add()
	#if combo == ["w", "w", "w"]:
		#get_tree().quit()

# this works pretty well and has the right idea when it comes to recording inputs
# the better way to use this, though, would be a nested Dictionary/HashMap
# this is because to check if a combo was completed one would have to see if the
# array contains some specified subarray (which would be an enormous waste of time and
# processing), while using a nested HashMap can simply travel around references
# and has the added bonus of never having to delete information or add information,
# using a continuous piece of data
func add_to_combo(event):
	if event.is_pressed() and !event.is_echo() and event is not InputEventMouseButton\
	and OS.get_keycode_string(event.keycode) != "Shift":
		var keycode = event.keycode
		if keycode == clamp(keycode, 65, 90):
			if !Input.is_key_pressed(KEY_SHIFT):
				keycode += 32
			combo.append(OS.get_keycode_string(keycode))
		elif keycode == clamp(keycode, 48, 57):
			combo.append(OS.get_keycode_string(keycode))
		print(combo)
		$ComboTracker.start()

#func add_to_combo_less_exact(event):
	#if event.is_pressed() and !event.is_echo() and event is not InputEventMouseButton:
		#var shift_or_not = combo[-1] if len(combo) > 0 else null
		#var keycode = event.keycode
		#if shift_or_not != "Shift":
			#if 65 <= keycode and keycode <= 90:
				#keycode += 32
		#else:
			#combo.pop_back()
		#combo.append(OS.get_keycode_string(keycode))
		#
		#print(combo)


func _on_animation_player_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://character_select.tscn")


func priority_sort(moves, prios):
	for i in range(1, len(prios)):
		var k: int = i
		while(k > 0 && prios[k] > prios[k - 1]):
			# swap the priority counters
			var temp = prios[k]
			prios[k] = prios[k - 1]
			prios[k - 1] = temp
			
			# then swap moves in moves
			temp = moves[k]
			moves[k] = moves[k - 1]
			moves[k - 1] = temp
			
			k -= 1


func _on_combo_tracker_timeout():
	combo.clear()
	print(combo)
	$ComboTracker.stop()


'''
the best way to deal with combos would be something like...

var fighter = some_character_in_game
fighter has a tree of combos represented by a nested dictionary of buttons like so:
	if fighter has the combos
	[Square, Square, Square] -> "Super Punch",
	[Square, Square, Triangle] -> "Fireball",
	[Square, Triangle, Triangle] -> "DP",
	then their combo tree looks like
	combo_tree = {
		"Square": {
			"Square": {
				"Square": "Super Punch",
				"Triangle": "Fireball"
			},
			"Triangle": {
				"Triangle": "DP"
			}
		}
	}
	
	var current_combo = combo_tree
	on input:
		current_combo = current_combo[input]
		if current_combo == null:
			current_combo = combo_tree
		elif current_combo is String:
			perform(current_combo)
		$ComboTimer.start()
	
	_on_combo_timer_timeout():
		current_combo = combo_tree

'''
