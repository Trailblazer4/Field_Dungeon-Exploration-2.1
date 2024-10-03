extends Node

var ALL_PLAYABLE_CHARACTERS = [] # holds all references to all (playable) characters in the game
var party = load("res://Party.tscn").instantiate() # initial creation of the party container
#var collision_objects = [] # bookkeeping for collision objects (might delete later)
var partyCamera = Camera2D.new() # the camera focused on Party1 (leader of party, controlled by player)
var locationInfo: LocationInfo

# instance player characters
var cinnamoroll = load("res://PlayableCharacters/Cinnamoroll.tscn").instantiate()
var misty = load("res://PlayableCharacters/Misty.tscn").instantiate()
var link = load("res://PlayableCharacters/Link.tscn").instantiate()
var fei = load("res://PlayableCharacters/Fei.tscn").instantiate()
var rockman = load("res://PlayableCharacters/Mega Man.tscn").instantiate()
var atom = load("res://PlayableCharacters/Atom.tscn").instantiate()
var zero = load("res://PlayableCharacters/Zero.tscn").instantiate()
var clodsire = load("res://PlayableCharacters/Clodsire.tscn").instantiate()

# define status functions here followed by creating a list of funcrefs
func burn(e: Entity, effect: int, move = null):
	match effect:
		0: # called right when effect added to Entity, status_effects[i].call(self, 0)
			print(e.myName, " was burned!")
			print(e.myName, " mgdf cut in half!")
			e.multMgDf(0.5)
			var new_status_icon = get_status_icon("Burn")
			e.health_bar.get_node("StatusIconList").add_child(new_status_icon)
		1: # called right when effect popped from Entity, status_effects[i].call(self, 1)
			print(e.myName, " is no longer burned!")
			print(e.myName, " mgdf back to normal.")
			e.multMgDf(2.0)
			var icon_list = e.health_bar.get_node("StatusIconList")
			icon_list.remove_child(icon_list.get_node("Burn Symbol"))
		#2: # called at the start of every turn. Grounded doesn't do anything for this effect so it can be passed as default.
		3: # called at the end of every turn. Grounded doesn't do anything for this effect so it can be passed as default.
			e.setHP(e.getHP() - (e.getMaxHP() / 16)) # burn effect
			e.health_bar.health = e.getHP()
		4: # called when an Entity is hit with an attack/Spell/Item. checks whether the move's element has a special effect against this status.
			var effect_activated = [false]
			# possible for a Spell to have multiple elements, so check for all of them.
			if move.element == Element.WIND:
				print("x1.3 damage from ", move.title, "!")
				effect_activated = [true, 1.3, 1.6]
			return effect_activated # when calling these functions, for status in status_effects:
																	# var status_result = status.call(e, 4, move)
																	# if status_result[0]:
																	# 	status.call(e, 1) # to remove effect
																	#	e.status_effects.erase(status)
																	#	if status_result[1] is float:
																	#		dmg_mod *= status_result[1] # dmg_mod will be a float in Entity.use(),
																	#									  initialized to 1.0
																	#		chance *= status_result[2] # chance will be a float for the chance
																	#									of a move's status to land, initially set
																	#									to move's accuracy
																	#	else:
																	#		e.status_effects.append(status_result[1])
		_: # default
			pass
	return [false] # effect_activated is never set to true

func freeze(e: Entity, effect: int, move = null):
	match effect:
		0: # called right when effect added to Entity, status_effects[i].call(self, 0)
			print(e.myName, " was frozen!")
			print(e.myName, " spd cut in half!")
			e.multSpd(0.5)
		1: # called right when effect popped from Entity, status_effects[i].call(self, 1)
			print(e.myName, " is no longer frozen!")
			print(e.myName, " spd back to normal.")
			e.multSpd(2.0)
		4: # called when an Entity is hit with an attack/Spell/Item. checks whether the move's element has a special effect against this status.
			var effect_activated = [false]
			if move.element == Element.EARTH:
				print("x1.3 damage from ", move.title, "!")
				effect_activated = [true, 1.3]
			if move.element == Element.FIRE:
				effect_activated = [true, StatusDictionary["Wet"]]
			return effect_activated
		_: # default
			pass
	return [false] # effect_activated was never set to true

func sick(e: Entity, effect: int, move = null):
	match effect:
		0: # called right when effect added to Entity, status_effects[i].call(self, 0)
			print(e.myName, " became sick!")
			var new_status_icon = get_status_icon("Sick")
			e.health_bar.get_node("StatusIconList").add_child(new_status_icon)
		1: # called right when effect popped from Entity, status_effects[i].call(self, 1)
			print(e.myName, " is no longer sick!")
			var icon_list = e.health_bar.get_node("StatusIconList")
			icon_list.remove_child(icon_list.get_node("Sick Symbol"))
		4: # called when an Entity is hit with an attack/Spell/Item. checks whether the move's element has a special effect against this status.
			return [true, 1.0, 1.8] # dmg_mod stays the same, chance gets higher for a new status to land
		_: # default
			pass
	return [false]

func grounded(e: Entity, effect: int, move = null):
	match effect:
		0: # called right when effect added to Entity, status_effects[i].call(self, 0)
			print(e.myName, " was grounded!")
			print(e.myName, " def cut in half!")
		1: # called right when effect popped from Entity, status_effects[i].call(self, 1)
			print(e.myName, " is no longer grounded!")
			print(e.myName, " def back to normal.")
		#2: # called at the start of every turn. Grounded doesn't do anything for this effect so it can be passed as default.
		#3: # called at the end of every turn. Grounded doesn't do anything for this effect so it can be passed as default.
		4: # called when an Entity is hit with an attack/Spell/Item. checks whether the move's element has a special effect against this status.
			var effect_activated = false
			# possible for a Spell to have multiple elements, so check for all of them.
			if move.element == Element.FIRE:
				print("x1.3 damage from ", move.title, "!")
				effect_activated = true
			if move.element == Element.LIGHTNING:
				print(move.title, " negated! x0 damage.")
				effect_activated = true
			if effect_activated:
				pass # pop this status effect from Entity.status_effects
		_: # default
			pass

func wet(e: Entity, effect: int, move = null):
	match effect:
		0: # called right when effect added to Entity, status_effects[i].call(self, 0)
			print(e.myName, " was grounded!")
			print(e.myName, " def cut in half!")
		1: # called right when effect popped from Entity, status_effects[i].call(self, 1)
			print(e.myName, " is no longer grounded!")
			print(e.myName, " def back to normal.")
		#2: # called at the start of every turn. Grounded doesn't do anything for this effect so it can be passed as default.
		#3: # called at the end of every turn. Grounded doesn't do anything for this effect so it can be passed as default.
		4: # called when an Entity is hit with an attack/Spell/Item. checks whether the move's element has a special effect against this status.
			var effect_activated = false
			# possible for a Spell to have multiple elements, so check for all of them.
			if move.element == Element.FIRE:
				print("x1.3 damage from ", move.title, "!")
				effect_activated = true
			if move.element == Element.LIGHTNING:
				print(move.title, " negated! x0 damage.")
				effect_activated = true
			if effect_activated:
				pass # pop this status effect from Entity.status_effects
		_: # default
			pass

func steam(e: Entity, effect: int, move = null):
	match effect:
		0: # called right when effect added to Entity, status_effects[i].call(self, 0)
			print(e.myName, " was grounded!")
			print(e.myName, " def cut in half!")
		1: # called right when effect popped from Entity, status_effects[i].call(self, 1)
			print(e.myName, " is no longer grounded!")
			print(e.myName, " def back to normal.")
		#2: # called at the start of every turn. Grounded doesn't do anything for this effect so it can be passed as default.
		#3: # called at the end of every turn. Grounded doesn't do anything for this effect so it can be passed as default.
		4: # called when an Entity is hit with an attack/Spell/Item. checks whether the move's element has a special effect against this status.
			var effect_activated = false
			# possible for a Spell to have multiple elements, so check for all of them.
			if move.element == Element.FIRE:
				print("x1.3 damage from ", move.title, "!")
				effect_activated = true
			if move.element == Element.LIGHTNING:
				print(move.title, " negated! x0 damage.")
				effect_activated = true
			if effect_activated:
				pass # pop this status effect from Entity.status_effects
		_: # default
			pass

func zapped(e: Entity, effect: int, move = null):
	match effect:
		0: # called right when effect added to Entity, status_effects[i].call(self, 0)
			print(e.myName, " was grounded!")
			print(e.myName, " def cut in half!")
		1: # called right when effect popped from Entity, status_effects[i].call(self, 1)
			print(e.myName, " is no longer grounded!")
			print(e.myName, " def back to normal.")
		#2: # called at the start of every turn. Grounded doesn't do anything for this effect so it can be passed as default.
		#3: # called at the end of every turn. Grounded doesn't do anything for this effect so it can be passed as default.
		4: # called when an Entity is hit with an attack/Spell/Item. checks whether the move's element has a special effect against this status.
			var effect_activated = false
			# possible for a Spell to have multiple elements, so check for all of them.
			if move.element == Element.FIRE:
				print("x1.3 damage from ", move.title, "!")
				effect_activated = true
			if move.element == Element.LIGHTNING:
				print(move.title, " negated! x0 damage.")
				effect_activated = true
			if effect_activated:
				pass # pop this status effect from Entity.status_effects
		_: # default
			pass

func get_status_icon(status_title: String) -> TextureRect:
	var new_status_icon = TextureRect.new()
	new_status_icon.name = "%s Symbol" % status_title
	new_status_icon.texture = load("res://images/StatusIcons/%s.png" % new_status_icon.name)
	new_status_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	return new_status_icon

# when an Entity is hit with an attack, you can first check whether any of their existing status_effects have an interaction with the move
# (for status in status_effects: status.call(self, 3, move)), then run a chance on the attacking move to see whether a new status is added


var StatusDictionary: Dictionary = {
	"Burn": Callable(self, "burn"),
	"Freeze": Callable(self, "freeze"),
	"Sick": Callable(self, "sick"),
	"Grounded": Callable(self, "grounded"),
	"Wet": Callable(self, "wet"),
	"Steam": Callable(self, "steam"),
	"Zapped": Callable(self, "zapped"),
}


# reference the current scene of the game. update this in the _ready() function of each level in the game
var current_scene = null
func set_current_scene():
		current_scene = get_tree().get_root().get_child(-1)


var SpellLibrary: Dictionary = {
	"Punch": Spell.new("Punch", Element.VOID, 5, 0, Spell.weapon_types.GAUNTLETS),
	"Super Punch": Spell.new("Super Punch", Element.VOID, 12, 10, Spell.weapon_types.GAUNTLETS),
	"Ar": Spell.new("Ar", Element.FIRE, 10, 20, Spell.weapon_types.MAGIC, [StatusDictionary["Burn"]], [20]),
	"Ard": Spell.new("Ard", Element.FIRE, 20, 40, Spell.weapon_types.MAGIC, [StatusDictionary["Burn"]], [30]),
	"Au": Spell.new("Au", Element.ICE, 10, 20, Spell.weapon_types.MAGIC, [StatusDictionary["Freeze"]], [50]),
	"Re": Spell.new("Re", Element.HEAL, 10, 20, Spell.weapon_types.MAGIC),
	"Reli": Spell.new("Reli", Element.HEAL, 15, 30, Spell.weapon_types.MAGIC),
	"Temp": Spell.new("Temp", Element.WIND, 20, 40, Spell.weapon_types.MAGIC, [StatusDictionary["Sick"]], [20]),
	"Pew Pew": Spell.new("Pew Pew", Element.LIGHTNING, 15, 0, Spell.weapon_types.HANDGUN),
	"Rocket Boosters": Spell.new("Rocket Boosters", Element.LIGHTNING, 0, 20, Spell.weapon_types.MAGIC),
	"Goddess Strike": Spell.new("Goddess Strike", Element.LIGHT, 25, 40, Spell.weapon_types.BROADSWORD),
}


var EquipmentLibrary: Dictionary = {
	"Primal": Equipment.new("Primal", Equipment.places.WEAPON, Equipment.weapons.BROADSWORD, Element.VOID, [25, 9, 14, 5, 0, 0, 0]),
	"Lightblotter": Equipment.new("Lightblotter", Equipment.places.WEAPON, Equipment.weapons.POLEARM, Element.DARK, [0, 11, 24, 3, 8, 0, 5]),
	"Master Sword": Equipment.new("Master Sword", Equipment.places.WEAPON, Equipment.weapons.BROADSWORD, Element.LIGHT,
	[40, 13, 28, 10, 7, 6, 0], [SpellLibrary["Goddess Strike"]]),
	"Silver Armor": Equipment.new("Silver Armor", Equipment.places.ARMOR, Equipment.armors.HEAVY, Element.VOID, [70, 0, 0, 18, 0, 6, 0]),
	"Mega Buster": Equipment.new("Mega Buster", Equipment.places.WEAPON, Equipment.weapons.HANDGUN, Element.LIGHTNING, [0, 15, 18, 0, 12, 0, 4]),
	"Yontou-Jishi": Equipment.new("Yontou-Jishi", Equipment.places.WEAPON, Equipment.weapons.KATANA, Element.VOID, [0, 9, 28, 6, 21, 4, 5]),
	"Super Suit": Equipment.new("Super Suit", Equipment.places.ARMOR, Equipment.armors.HEAVY, Element.VOID, [100, 25, 6, 30, 4, 30, 2]),
}


# normally we would use strings to reference areas here, and create load() variables based on those strings
# when loading in an adjacent area in necessary
# for the purposes of this small project, we will just load all game assets from the get-go
var Levels = [
	load("res://GrassField.tscn"),
	load("res://Dungeon.tscn"),
]

var current_level = 0


# these functions will help us generalize/simplify exiting/entering zones
# ideally, when a zone is exited from a specific area on the map that area calls travel_to(areaName)
# and also provides an entry point to that area
# whether this is stored in a nested map or something will be decided later, but for now
# we know that the user enters a particular vicinity or area on the current map, that area
# calls travel_to(place), and sets an entryPoint to make transition from this place to the next seamless

# of course, each zone has multiple neighbors so that means that each exit area on its map will
# contain a different name for travel_to() to use as a parameter, as well as a different Vector2
# for entryPoint
func travel_to(level: int, entryPoint: Vector2, direction: Vector2): # path is a new level scene
	current_level = level
	if current_scene != null:
		current_scene.remove_child(party) # before anything, remove the party so it's not erased
	# get entryPoint from newLocation and set the following:
	# party.position = entryPoint
	# for pm in party.get_children(): pm.position = 0; pm.direction = party.get_child(0).direction
	party.teleport(entryPoint)
	party.face(direction)
	party.slot(0).position_history.clear()
	
	get_tree().change_scene_to_packed(Levels[level]) # change level
	#set_current_scene()
	#print("Current scene: ", current_scene)
	# in the _ready() function of the new scene there should be a LocationInfo made,
	# and a statement setting GameData.current_scene = self
	# fade the screen in
	#addChests()
	current_scene.add_child(party)
	#current_scene.fadebox.play("fadein")


# concept: if the player is going through an exit zone with the same level as the one they're
# currently in, they do not want to unload the level and go somewhere else; instead, they just
# want to teleport/face somewhere else on the same map.
# an example being that the player walks through a door in a dungeon which takes them to another room.
# that other room can just be another part of the level already loaded in
# depending on the level we might put it in segments where different parts are loaded in separately
# if too big. in this case, however, we WOULD end up using travel_to() anyway, so the utility
# of this walk_to() function is still to be determined
#func walk_to(entryPoint: Vector2, direction: Vector2):
	#pass


# chests dictionary. Each key is a location name (obtained from current_scene.locationInfo.locationName)
# referencing a list of chests in that location
# each chest is a list of attributes: an item (object of type Item), a boolean tracking whether the chest
# has been opened, and a position on the level's map

# adding entries to this dictionary and properly using the addChests() method, chests can easily and cleanly
# be added to a level whenever
var chests = {
	"Grass Field": [
		["Bomb", false, Vector2(250, 300)],
		["Ultra Potion", false, Vector2(400, 375)],
		["Cookie", false, Vector2(500, 500)],
		["Elixir", false, Vector2(800, 600)],
		["Silver Sword", false, Vector2(870, 600)],
	],
	"Steampunk Showdown": [
		["Rusted Sword", false, Vector2(300,600)],
	],
}
# each chest in the game will have a script referencing
# GameData.chests[current_scene.locationInfo.locationName][chestNum]
# each chest will in its script be given a chestNum
# there will be a function open() which, if chest is closed, opens it
# and gives its item to the inventory, and sets open to true
var inventory = [
	[load("res://ItemLibrary/Elixir.tscn").instantiate(), 99],
]
func add_to_inventory(i: Item):
	for item in inventory:
		if item[0].title == i.title:
			item[1] += 1
			i.queue_free()
			return
	inventory.append([i, 1]) # items are only instantiated once in memory
																		  # paired with a counter


# handling screen fade transitions
var fadeout = false
var fadein = true
var pausing = false
var battling = false

var q = []
var number_of_states = 3

var saveDir = DirAccess.open("user://")


enum Status {
	BRN,
	FRZ,
	GRND,
	SICK,
	WET,
	STM,
	ZAP,
}

enum Element {
	VOID,
	FIRE,
	ICE,
	WIND,
	EARTH,
	DARK,
	LIGHT,
	HEAL,
	LIGHTNING,
	SNOW,
	MAGMA,
	METAL,
	SOUND,
	CLOUD,
	GRAVITY,
	UNSTABLE,
}


#var tf = ["Crimson", "Celeste", "Lyra", "Dante"]
func _ready():
	#var chars = ["Rock", "Proto", "X", "Zero"]
	#chars.insert(2, "Roll")
	#print(chars)
	
	#party.move_child(party.get_child(0), 2)
	#print(party.get_children())

	#if tf:
		#print("Truthy")
	#else:
		#print("Falsy")
	#var burn :int = Status.BRN
	#print(burn)
	# instance every character in the game once and save them to A_P_C for future use/reference
	ALL_PLAYABLE_CHARACTERS.append(cinnamoroll)
	ALL_PLAYABLE_CHARACTERS.append(misty)
	ALL_PLAYABLE_CHARACTERS.append(link)
	ALL_PLAYABLE_CHARACTERS.append(fei)
	ALL_PLAYABLE_CHARACTERS.append(rockman)
	ALL_PLAYABLE_CHARACTERS.append(atom)
	ALL_PLAYABLE_CHARACTERS.append(zero)
	ALL_PLAYABLE_CHARACTERS.append(clodsire)

	# put characters in the party
	## then, we will remove them from their parent and place them as a child of the party slot instead
	## when the character is removed from the party, move their collision object back under them before removing
	## move it back under them when swapping party placements as well
	## if the character swings a weapon it should be fine as the weapon will have its own collision shape
	#print(party.get_child(-2).get_child(0)) # negative index works with get_child, too!
	
	#addToParty(zero, 0)
	#addToParty(rockman, 1)
	#addToParty(link, 2)
	#addToParty(clodsire, 3)

	#swapParty(0, 2)
	#removeFromParty(1)

	for i in range(number_of_states):
		q.append(false)
	q[0] = true

	partyCamera.zoom = Vector2(2, 2)
	#party.get_child(0).add_child(partyCamera)
	#var co = party.get_child(0).get_child(0).get_child(1)
	#party.get_child(0).get_child(0).remove_child(co)
	#party.get_child(0).add_child(co)

	#var locationInfo = LocationInfo.new("Grass Field")
	#locationInfo.addToEnemyPool("Pircekin", 70.1)
	#locationInfo.addToEnemyPool("Iron Knight", 100)
	#print(locationInfo.locationName, " Enemy Pool: ", locationInfo.enemyPool)


func _process(delta):
	if Input.is_key_pressed(KEY_I) and q[0]:
		current_scene.get_node("Fade/AnimationPlayer").play("fadeout")
		pausing = true
		#fadeout = true
		#fadein = false
		#pausing = true
## I just realized: why go through the trouble of coding this animation with booleans and whatever
## in _process() when I could do it with an animation player
	#if fadein:
		#fadeIn(current_scene, delta)
		#if current_scene.get_node("Fade").color.a <= 0:
			#fadein = false
	#if fadeout:
		#fadeOut(current_scene, delta)
	if pausing and current_scene.get_node("Fade").color.a >= 1:
		pause(current_scene)
	
	if Input.is_action_just_pressed("switch"):
		GameData.rotateParty()

signal pause_menu_open
func pause(scene):
	#var pauseScreen = scene.get_node("PauseScreen")
	#scene.visible = false
	# pauseScreen.visible = true
	#pauseScreen.process_mode = PROCESS_MODE_WHEN_PAUSED
	#scene.process_mode = PROCESS_MODE_DISABLED
	scene.visible = false
	PauseMenu.visible = true
	party.get_child(0).get_child(2).enabled = false
	PauseMenu.camera().enabled = true
	get_tree().paused = true
	transition(0, 1)
	PauseMenu.get_node("Fade/AnimationPlayer").play("fadein")
	pause_menu_open.emit()
	#print("paused")


#func fadeScreen(area):
	#return area.get_node("Fade")
#
#
#func fadeOut(area, delta):
	#var fadeout = fadeScreen(area)
	#if fadeout.color.a < 1:
		#fadeout.color.a += delta * 4
#
#func fadeIn(area, delta):
	#var fadeout = fadeScreen(area)
	#if fadeout.color.a > 0:
		#fadeout.color.a -= delta * 4


func transition(i, j):
	q[i] = false
	q[j] = true


func rotateParty(): # rotate the party so that character 1 is now in slot 4, character 4 is in slot 3, etc.
	var tempParty = []
	for i in range(len(party.get_children())):
		if party.get_child(i).get_child_count() > 0:
			tempParty.append(removeFromParty(i))

	for i in range(len(tempParty)):
		var index = i - 1
		if index < 0:
			var offset: int = party.get_child_count() - len(tempParty)
			index -= offset 
		addToParty(tempParty[i], index)
	
	print("Temp Party: ", tempParty)
	print("Party:")
	for slot in party.get_children():
		print(slot.get_children())


func swapParty(i: int, j: int): # swap places of two characters in party
	var pm1 = removeFromParty(i)
	var pm2 = removeFromParty(j)
	addToParty(pm2, i)
	addToParty(pm1, j)


func addToParty(e: Entity, index: int):
	if index < -4 or index > 3:
		print("Invalid index")
		return
	party.get_child(index).add_child(e)
	var co = e.get_child(1) # collision object
	#collision_objects.append(co)
	e.remove_child(co)
	party.get_child(index).add_child(co)
	if index == 0:
		party.get_child(index).add_child(partyCamera) # if adding character to slot 1,
													  # give a camera after giving character
	# note: parent.move_child(node, position) could also be useful for these kinds of tree setups
		party.get_child(index).move_child(partyCamera, 2)


func removeFromParty(index: int):
	if index < -4 or index > 3:
		print("Invalid index")
		return
	var pm = party.get_child(index).get_child(0)
	party.get_child(index).remove_child(pm)
	var co = party.get_child(index).get_child(0)
	party.get_child(index).remove_child(co)
	pm.add_child(co)
	pm.move_child(co, 1)
	if index == 0:
		party.get_child(index).remove_child(partyCamera)
	return pm # after removing character at specified slot from the tree,
			  # a reference to the character is returned


#func addChests(): # TODO currently unused. Should be refactored
	#var loadChest = load("res://Chest.tscn")
	#var chestsHere = chests[current_scene.locationInfo.locationName]
	#for i in range(len(chestsHere)):
		#var newChest = loadChest.instantiate()
		#add_child(newChest)
		#newChest.setChest(i, current_scene.locationInfo.locationName, chestsHere[i][2])


func enter_battle():
	# play animation for battle fade
	# current_scene.remove_child(party)
	# get_tree().change_scene_to_packed("res://Battle.tscn")
	
	# then in Battle.tscn._ready(), remove characters from GameData.party and add them to slots in Battle.party
	pass
