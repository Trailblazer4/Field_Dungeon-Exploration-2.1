extends Node2D

var level0 = GameData.Levels[0]
# Called when the node enters the scene tree for the first time.

var moveset = ["a", "b", "c", "d", "e", "f", "g", "h", "i"]
var priority_list = [4, 14, 16, 3, 2, -1000, 1, 0, -100]

var master_sword = GameData.EquipmentLibrary["Master Sword"]
var primal = GameData.EquipmentLibrary["Primal"]

var silver_armor = GameData.EquipmentLibrary["Silver Armor"]

#var cache: ComboCache = ComboCache.new()

func _ready():
	#add_child(cache)
	#cache.start()
	
	GameData.inventory.append([GameData.EquipmentLibrary["Super Suit"], 1])
	
	var types = [null, true, 1, 1.2, "string", GameData.ALL_PLAYABLE_CHARACTERS[0]]
	for type in types:
		print(type, ":", typeof(type))
	
	#print(GameData.EquipmentLibrary.values())
	$Fade.color.a = 0
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("start"):
		$Fade/AnimationPlayer.play("fadeout")
	#else:
		#cache.add()


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
