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
		1: # called right when effect popped from Entity, status_effects[i].call(self, 1)
			print(e.myName, " is no longer burned!")
			print(e.myName, " mgdf back to normal.")
			e.multMgDf(2.0)
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
			print(e.myName, " was grounded!")
			print(e.myName, " def cut in half!")
		1: # called right when effect popped from Entity, status_effects[i].call(self, 1)
			print(e.myName, " is no longer grounded!")
			print(e.myName, " def back to normal.")
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


var SpellLibrary: Dictionary = {
	"Punch": Spell.new("Punch", Element.VOID, 10, 0),
	"Ar": Spell.new("Ar", Element.FIRE, 20, 20, [StatusDictionary["Burn"],]),
	"Au": Spell.new("Au", Element.ICE, 20, 20, [StatusDictionary["Freeze"],]),
	"Re": Spell.new("Re", Element.HEAL, 20, 20),
	"Reli": Spell.new("Reli", Element.HEAL, 40, 30),
	"Temp": Spell.new("Temp", Element.WIND, 40, 30),
	"Pew Pew": Spell.new("Pew Pew", Element.LIGHTNING, 15, 0),
	"Rocket Boosters": Spell.new("Rocket Boosters", Element.LIGHTNING, 0, 20),
}


# normally we would use strings to reference areas here, and create load() variables based on those strings
# when loading in an adjacent area in necessary
# for the purposes of this small project, we will just load all game assets from the get-go
var Levels = [
	load("res://GrassField.tscn"),
	load("res://Dungeon.tscn"),
]


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

var dir = DirAccess.open("user://")


enum Status{
	BRN,
	FRZ,
	GRND,
	SICK,
	WET,
	STM,
	ZAP,
}

enum Element{
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


# these functions will help us generalize/simplify exiting/entering zones
func travel_to(path: String): # path is a new level scene
	current_scene.remove_child(party) # before anything, remove the party so it's not erased
	# then fade the screen out
	get_tree().change_scene_to_file(path) # change level
	# in the _ready() function of the new scene there should be a LocationInfo made,
	# and a statement setting GameData.current_scene = self
	# fade the screen in
	addChests()
	current_scene.add_child(party)


func addChests():
	var loadChest = load("res://Chest.tscn")
	var chestsHere = chests[current_scene.locationInfo.locationName]
	for i in range(len(chestsHere)):
		var newChest = loadChest.instantiate()
		add_child(newChest)
		newChest.setChest(i, current_scene.locationInfo.locationName, chestsHere[i][2])


func enter_battle():
	# play animation for battle fade
	# current_scene.remove_child(party)
	# get_tree().change_scene_to_packed("res://Battle.tscn")
	
	# then in Battle.tscn._ready(), remove characters from GameData.party and add them to slots in Battle.party
	pass
