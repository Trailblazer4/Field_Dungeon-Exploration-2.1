@icon("res://images/Chio Icon.png")
extends CharacterBody2D

class_name Entity


var stats
var add_mod: Array[int] = [0, 0, 0, 0, 0, 0, 0] # add_mod and mult_mod are affected by de/buffs, equipment, statuses, etc.
var mult_mod: Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

var maxHP; var maxSP
var SPEED = 100.0
var myName: String
var speedCounter: int

var level
var lvl_up_moves: Dictionary # moves to learn are defined on a character-by-character basis, in their _init() function
func level_up() -> void: # levels up character once, and checks if there is a move for them to learn
	level += 1
	print("%s reached level %d!" % [myName, level])
	if lvl_up_moves.has(level):
		print("%s learned %s!" % [myName, lvl_up_moves[level]])
		# moveset.append(GameData.SpellLibrary[lvl_up_moves[level]])

var moveset: Array[Spell] = []
#@onready var basic_attack: Spell = GameData.SpellLibrary["Punch"]
var status_effects: Array[Callable] = []

func info():
	print(myName, "\n")
	
	print("HP: %d/%d SP: %d/%d" % [getHP(), getMaxHP(), getSP(), getMaxSP()])
	print("Atk: %d   Def: %d" % [getAtk(), getDef()])
	print("Mag: %d   MgDf: %d" % [getMag(), getMgDf()])
	print("Spd: %d\n" % getSpd())
	
	for move in moveset:
		print(move.title, " ", move.element, " ", move.power)

var current_equipment = {
	"Weapon 1": Equipment.new(
		"Empty",
		Equipment.places.WEAPON,
		Equipment.weapons.NONE,
		GameData.Element.VOID,
		[0, 0, 0, 0, 0, 0, 0]
	),
	"Weapon 2": Equipment.new(
		"Empty",
		Equipment.places.WEAPON,
		Equipment.weapons.NONE,
		GameData.Element.VOID,
		[0, 0, 0, 0, 0, 0, 0]
	),
	"Head": Equipment.new(
		"Empty",
		Equipment.places.HEAD,
		Equipment.armors.NONE,
		GameData.Element.VOID,
		[0, 0, 0, 0, 0, 0, 0]
	),
	"Armor": Equipment.new(
		"Empty",
		Equipment.places.ARMOR,
		Equipment.armors.NONE,
		GameData.Element.VOID,
		[0, 0, 0, 0, 0, 0, 0]
	),
	"Legs": Equipment.new(
		"Empty",
		Equipment.places.LEG,
		Equipment.armors.NONE,
		GameData.Element.VOID,
		[0, 0, 0, 0, 0, 0, 0]
	),
	"Shoes": Equipment.new(
		"Empty",
		Equipment.places.SHOE,
		Equipment.armors.NONE,
		GameData.Element.VOID,
		[0, 0, 0, 0, 0, 0, 0]
	),
	"Gloves": Equipment.new(
		"Empty",
		Equipment.places.GLOVE,
		Equipment.armors.NONE,
		GameData.Element.VOID,
		[0, 0, 0, 0, 0, 0, 0]
	),
	"Accessory 1": Equipment.new(
		"Empty",
		Equipment.places.ACSRY,
		Equipment.armors.NONE,
		GameData.Element.VOID,
		[0, 0, 0, 0, 0, 0, 0]
	),
	"Accessory 2": Equipment.new(
		"Empty",
		Equipment.places.ACSRY,
		Equipment.armors.NONE,
		GameData.Element.VOID,
		[0, 0, 0, 0, 0, 0, 0]
	),
}

var prefs = {
	"weapons": [],
	"armors": [],
}

func unequip(slot: String, newEq: Equipment = Equipment.new("Empty", current_equipment[slot].place, Equipment.armors.NONE, GameData.Element.VOID, [0, 0, 0, 0, 0, 0, 0])):
	if (slot == "Weapon 1" or slot == "Weapon 2") and newEq.title == "Empty":
		newEq.type = Equipment.weapons.NONE
	
	var prev = current_equipment[slot]
	current_equipment[slot] = newEq
	
	for i in range(len(prev.stats)):
		add_mod[i] -= prev.stats[i]
	setHP(getHP() - prev.stats[0])
	setSP(getSP() - prev.stats[1])
	for j in range(len(prev.moveset)):
		moveset.erase(prev.moveset[j])
	
	for i in range(len(newEq.stats)):
		add_mod[i] += newEq.stats[i]
	setHP(getHP() + newEq.stats[0])
	setSP(getSP() + newEq.stats[1])
	for j in range(len(newEq.moveset)):
		moveset.append(newEq.moveset[j])
	
	if prev.name == "Empty":
		prev.queue_free()
	else:
		#GameData.inventory.put(prev) # put will check if that item is currently in the inventory and if it is, will add 1 to counter,
		#else will push it to inventory with count of 1
		for item in GameData.inventory:
			if item[0].title == prev.title:
				item[1] += 1
				return
		GameData.inventory.append([prev, 1])


func equip(slot: String, eq: Equipment):
	# when choosing piece to equip,
	# (separate function) for eq in inventory:
	#if eq is Equipment and eq.place == current_equipment[slot].place and (eq.type in prefs["weapons"] or eq.type in prefs["armors"]):
	#	return true (show)
	unequip(slot, eq)
	#take eq out of inventory
	for item in GameData.inventory:
		if item[0].title == eq.title:
			item[1] -= 1
			if item[1] <= 0:
				GameData.inventory.erase([item[0], item[1]])
			return


func basic_attack():
	print(myName, ": ", current_equipment["Weapon 1"].type)
	var atk_name = current_equipment["Weapon 1"].title
	if atk_name == "Empty":
		atk_name = "Punch"
	return Spell.new(atk_name, GameData.Element.VOID, 5, 0, current_equipment["Weapon 1"].type)


var defending: bool = false

var health_bar

func _init():
	level = 1 # every character is initialized at lvl 1
	stats = [180, 24, 20, 15, 13, 12, 8]
	maxHP = stats[0]; maxSP = stats[1]
	speedCounter = 0


func setHP(shp):
	stats[0] = shp

func getHP():
	return stats[0]

func setMaxHP(shp):
	maxHP = shp

func getMaxHP():
	return round((maxHP + add_mod[0]) * mult_mod[0])

func setSP(ssp: int):
	stats[1] = ssp

func getSP() -> int:
	return stats[1]

func setMaxSP(ssp):
	maxSP = ssp

func getMaxSP():
	return round((maxSP + add_mod[1]) * mult_mod[1])

func setAtk(satk):
	stats[2] = satk

func addAtk(m: int):
	add_mod[2] += m

func multAtk(m: float):
	mult_mod[2] *= m

func getAtk():
	return round((stats[2] + add_mod[2]) * mult_mod[2])

func setDef(sdef):
	stats[3] = sdef

func addDef(m: int):
	add_mod[3] += m

func multDef(m: float):
	mult_mod[3] *= m

func getDef():
	return round((stats[3] + add_mod[3]) * mult_mod[3])
	
func setMag(smag):
	stats[4] = smag

func addMag(m: int):
	add_mod[4] += m

func multMag(m: float):
	mult_mod[4] *= m

func getMag():
	return round((stats[4] + add_mod[4]) * mult_mod[4])

func setMgDf(smgdf):
	stats[5] = smgdf

func addMgDf(m: int):
	add_mod[5] += m

func multMgDf(m: float):
	mult_mod[5] *= m

func getMgDf():
	return round((stats[5] + add_mod[5]) * mult_mod[5])

func setSpd(sspd):
	stats[6] = sspd

func addSpd(m: int):
	add_mod[6] += m

func multSpd(m: float):
	mult_mod[6] *= m

func getSpd():
	return round((stats[6] + add_mod[6]) * mult_mod[6])


func updateCounter(reset: bool = false):
	if reset:
		speedCounter = 0
	else:
		#speedCounter += stats[6]
		speedCounter += getSpd()


func checkHP():
	#var old_hp = getHP()
	var new_hp = max(min(getMaxHP(), getHP()), 0)
	setHP(new_hp)


func use(skill, target: Entity, test = false): # skill is of type Spell or Item
	var can_go = true # for now "middle" effects just affect whether you can move.
	for effect in status_effects:
		var result = effect.call(self, 3)
		#print("Can Go Result: ", result)
		if result != null && result is bool: can_go = can_go && result
	
	if !test: print("Can Go: ", can_go) # testing can_go. works!
	if !can_go and !test: return -1
	
	var og_hp = target.getHP()
	var changes_to_apply: Array[Callable] = [] # this is the list of status changes that are recorded in handle statuses
	# and is dealt with after the attack finishes
	
	var dmg_mod: float = 1.0
	if skill is Spell:
		var chance: Array[float] = skill.status_chances.duplicate()
		#var totalDmg = (skill.power + getMag()) # - (target.getMgDf())
		var totalDmg = (skill.power / 3) * skill.damage_formula(self, target)
		if skill.element == GameData.Element.HEAL:
			if test:
				var new_hp = min(target.getMaxHP(), target.getHP() + totalDmg)
				#print("Testing ", (new_hp - og_hp), " healing")
				return new_hp - og_hp # how much they healed
				#return totalDmg
			else:
				target.setHP(target.getHP() + totalDmg)
		else:
			var initial_element = skill.element
			if skill.element == GameData.Element.VOID:
				skill.element = current_equipment["Weapon 1"].element

			var until = len(target.status_effects)
			var handle_status_res = handle_statuses(until, target, skill, dmg_mod, chance, changes_to_apply, test)
			dmg_mod = handle_status_res[0]
			chance = handle_status_res[1]

			totalDmg = int(round(totalDmg * dmg_mod))
			# target.getHP() - move.damageFormula()     instead of     totalDmg - target.getMgDf()
			if test:
				var new_hp = max(0, target.getHP() - totalDmg)
				#print("Testing ", (og_hp - new_hp), " damage on ", target.myName, ". has mgdf ", target.getMgDf())
				skill.element = initial_element
				return og_hp - new_hp # how much damage was dealt
				#return totalDmg - target.getMgDf()
			else:
				target.setHP(target.getHP() - totalDmg)
			for j in range(len(chance)):
				#print("You have a ", chance[j], "% chance to hit ", skill.status_effects[j], ".")
				if randi_range(0,99) < chance[j]:
					target.status_effects.append(skill.status_effects[j])
					skill.status_effects[j].call(target, 0)
			skill.element = initial_element

		for change in changes_to_apply:
			change.call(target, 1)
			#print(change, " reverted")
	elif skill is Item:
		skill.apply_effect(target)
	else:
		print("Error: Selected action is neither Spell nor Item")

	if target.getHP() < 0:
		target.setHP(0)
	if target.getHP() > target.getMaxHP():
		target.setHP(target.getMaxHP())
	target.health_bar.health = target.getHP()
	#print("Dealing ", og_hp - target.getHP(), " damage on", target.myName, ". has mgdf ", target.getMgDf())
	for effect in status_effects:
		effect.call(self, 4)


func handle_statuses(until: int, target: Entity, skill, dm: float, chance: Array[float], changes, test = false):
	var go_back: int = 0
	for i in range(until):
		var status = target.status_effects[i - go_back]
		var status_result = status.call(target, 5, skill)
		if status_result == null:
			print("i: ", i)
			print("Go back: ", go_back)
			print(target.status_effects)
		if status_result[0]:
			if status != GameData.StatusDictionary["Sick"]: # pop out statuses with special effects except for Sick
				if !test:
					#print("Not testing:")
					#status.call(target, 1) # to remove effect
					changes.append(status)
					target.status_effects.erase(status)
					go_back += 1
			if status_result[1] is float:
				dm *= status_result[1] # dmg_mod will be a float in Entity.use(),
											  #initialized to 1.0
				for c in range(len(chance)):
					chance[c] *= status_result[2] # chance will be a float to mult the chance
											# of a move's status to land, initially set
											# to 1.0
					#print("New status chance: ", chance[c])
			else:
				if !test:
					target.status_effects.append(status_result[1])
	print(chance)
	return [dm, chance]






'''

normalizing size to 128 x 128?

scale.x = 128 / $Sprite2D.texture.get_width()
scale.y = 128 / $Sprite2D.texture.get_height()

'''
