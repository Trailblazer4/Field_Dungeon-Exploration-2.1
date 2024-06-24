extends Node2D

signal battle_over

var q: Array[bool] = [true, false, false, false, false]
func transition(i: int, j: int):
	q[i] = false
	q[j] = true
	if i == 4:
		cursorIcon.visible = false
	if j == 4:
		cursorIcon.visible = true
		if((i == 3) or (chosenMove is Spell and chosenMove.element == GameData.Element.HEAL)):
			set_target(-cursor)
	print(cursor)

@onready var battleCamera = $"Camera2D"
var enemies = []
var randy: RandomNumberGenerator = RandomNumberGenerator.new()
var turnOrder = []
var thisTurn
var turnSet: bool = false

func _ready():
	# set background to whatever locationInfo/subLocationInfo tells you is the location of the battle
	for i in range(len(GameData.party.get_children())):
		if GameData.party.get_child(i).get_child_count() > 0:
			$Party.get_child(i).add_child(GameData.removeFromParty(i))
			
			turnOrder.append($Party.get_child(i))
			var pm = $Party.get_child(i).get_child(0)
			pm.face_left()
			pm.updateCounter(true)
			
			get_node("Battle HUD/Name%d" % i).text = pm.myName
			pm.health_bar = get_node("Battle HUD/HealthBars/HealthBar%d" % i)
			pm.health_bar.visible = true
			pm.health_bar.init_health(pm.getMaxHP()) # set up health bar with Max HP
			pm.health_bar.health = pm.getHP() # set current HP to health bar value
	generateEnemies()
	for e: Entity in turnOrder:
		e.get_child(0).updateCounter()
	
	target = enemies[0].get_child(0)
	#handle_shader()
	cursorIcon = Sprite2D.new(); cursorIcon.texture = load("res://images/Cursor.png")
	cursorIcon.scale = Vector2(0.6, 0.6)
	cursorIcon.position = Vector2(-25, -5)
	target.add_child(cursorIcon)
	cursorIcon.visible = false


var decided: bool = false # was a decision made in this turn yet?
var decision: String = "" # is the decision an attack, spell, or item?
var chosenMove = null # what move or item specifically?

func _process(delta):
	if turnOrder[0].get_child(0).speedCounter >= 100:
		thisTurn = turnOrder[0]
		if !turnSet:
			turnSet = true
			$"Battle HUD/MagicMenu".makeMagic(thisTurn.get_child(0).moveset)
			$"Battle HUD/ItemsMenu".makeItems(GameData.inventory)
			for name in $"Battle HUD".get_children():
				if name is Label:
					if name.text == thisTurn.get_child(0).myName:
						name.material.shader = highlight_shader
					else:
						name.material.shader = null
			print("thisTurn set")
	else:
		thisTurn = null
		for e: Entity in turnOrder:
			e.get_child(0).updateCounter()
		speedInsertSort(turnOrder)


# the structure of the turn under "if thisTurn" is:
	# similar to a FSM, using states of the battle scene with booleans in a list,
	# and having "if q[0]... elif q[1]..." statements to determine the current "state" of battle
	if thisTurn:
		if thisTurn in $Enemies.get_children():
			enemyTurn()
		elif q[0]:
			mainScreen()
		elif q[1]:
			defendScreen()
		elif q[2]:
			magicScreen()
		elif q[3]:
			itemScreen()
		elif q[4]:
			var theresATarget = chooseScreen()
			if theresATarget:
				await thisTurn.get_child(0).use(chosenMove, target)
				if target.getHP() <= 0:
					target.setHP(0)
					target.visible = false
				elif target.getHP() > target.getMaxHP():
					target.setHP(target.getMaxHP())

				print(target.myName, ": ",target.getHP(),"/",target.getMaxHP())
				set_target(4 - cursor) # reset cursor after processing skill usage
				decided = true
		
		if decided:
			decided = false
			turnSet = false
			turnOrder[0].get_child(0).updateCounter(true)
			turnOrder.append(turnOrder.pop_front())

		#if Input.is_key_pressed(KEY_V):
			#for i in range(len($Party.get_children())):
				#if $Party.get_child(i).get_child_count() > 0:
					#var temp = $Party.get_child(i).get_child(0)
					#$Party.get_child(i).remove_child(temp)
					## party_get(i).add_child(temp)
					#GameData.addToParty(temp, i)
#
			#var returnToWorld = load("res://GrassField.tscn")
			#get_tree().change_scene_to_packed(returnToWorld)
		
		# decided is set to true if some decision is made, i.e. player confirms to defend,
		# or a target for an attack, spell, or item is selected


func mainScreen(): # q[0]
	decision = "Attack"
	if Input.is_action_just_pressed("confirm"):
		chosenMove = thisTurn.get_child(0).basic_attack
		transition(0, 4)
	if Input.is_action_just_pressed("cancel"):
		transition(0, 1)
	if Input.is_action_just_pressed("openMagic"):
		$"Battle HUD/MagicMenu".visible = true
		$"Battle HUD/MagicMenu".process_mode = Node.PROCESS_MODE_INHERIT
		transition(0, 2)
	if Input.is_action_just_pressed("openItems"):
		$"Battle HUD/ItemsMenu".visible = true
		$"Battle HUD/ItemsMenu".process_mode = Node.PROCESS_MODE_INHERIT
		transition(0, 3)


func defendScreen(): # q[1]
	# display prompt asking "Do you want to defend this turn?"
	if Input.is_action_just_pressed("confirm"):
		transition(1, 0)
		thisTurn.get_child(0).defending = true
		decided = true
	if Input.is_action_just_pressed("cancel"):
		transition(1, 0)


func magicScreen(): # q[2]
	# display magicMenu, just like in Intertwined 1.5
	decision = "Magic"
	if Input.is_action_just_pressed("confirm") and len(thisTurn.get_child(0).moveset) > 0:
		$"Battle HUD/MagicMenu".process_mode = Node.PROCESS_MODE_DISABLED
		$"Battle HUD/MagicMenu".visible = false
		chosenMove = thisTurn.get_child(0).moveset[$"Battle HUD/MagicMenu".cursor]
		transition(2, 4)
	elif Input.is_action_just_pressed("cancel"):
		$"Battle HUD/MagicMenu".process_mode = Node.PROCESS_MODE_DISABLED
		$"Battle HUD/MagicMenu".visible = false
		transition(2, 0)


func itemScreen(): # q[3]
	# display itemMenu, just like in Intertwined 1.5
	decision = "Item"
	if Input.is_action_just_pressed("confirm") and len(GameData.inventory) > 0:
		$"Battle HUD/ItemsMenu".process_mode = Node.PROCESS_MODE_DISABLED
		$"Battle HUD/ItemsMenu".visible = false
		chosenMove = GameData.inventory[$"Battle HUD/ItemsMenu".cursor][0]
		transition(3, 4)
	elif Input.is_action_just_pressed("cancel"):
		$"Battle HUD/ItemsMenu".process_mode = Node.PROCESS_MODE_DISABLED
		$"Battle HUD/ItemsMenu".visible = false
		transition(3, 0)


var cursor = 4 # 4 represents enemy 0 in "enemies"
var cursorIcon
var target # set to BattleParticipants.get_child(index).get_child(0), meaning it is a character rather than a slot
var target_original_shader
var highlight_shader = load("res://highlight.gdshader")

func chooseScreen(): # q[4], called when ready to use an attack, skill, or item on a target
	if Input.is_action_just_pressed("up"): # cursor > 0
		set_target(-1)
	if Input.is_action_just_pressed("down"): # cursor < len(enemies) + 3
		set_target(1)
	if Input.is_action_just_pressed("left"): # cursor < len(enemies) + 1
		if(cursor == 0):
			set_target(4)
		else:
			set_target(3)
	if Input.is_action_just_pressed("right"): # cursor > 2
		set_target(-3)
	
	if Input.is_action_just_pressed("confirm"):
		print(thisTurn.get_child(0).myName, " used ", chosenMove.title)
		if chosenMove is Spell:
			thisTurn.get_child(0).setSP(thisTurn.get_child(0).getSP() - chosenMove.spReq)
			print(thisTurn.get_child(0).getSP(), "/",thisTurn.get_child(0).getMaxSP())
		else:
			GameData.inventory[$"Battle HUD/ItemsMenu".cursor][1] -= 1
		transition(4, 0)
		return true # return target for Entity.use(skill, target)
	elif Input.is_action_just_pressed("cancel"):
		set_target(4 - cursor)
		match(decision):
			"Attack":
				transition(4, 0)
			"Magic":
				$"Battle HUD/MagicMenu".visible = true
				$"Battle HUD/MagicMenu".process_mode = Node.PROCESS_MODE_INHERIT
				transition(4, 2)
			"Item":
				$"Battle HUD/ItemsMenu".visible = true
				$"Battle HUD/ItemsMenu".process_mode = Node.PROCESS_MODE_INHERIT
				transition(4, 3)
	return false


func set_target(move_amount: int):
	#target.get_node("Sprite2D").material.shader = target_original_shader
	target.remove_child(cursorIcon)

	cursor += move_amount
	if cursor < 0:
		cursor = 0
	elif cursor >= len(enemies) + 4:
		cursor = len(enemies) + 3
	
	if cursor < 4:
		target = party_get(cursor).get_child(0)
		# add a highlight, probably play an animation that animates the color getting lighter
	else:
		target = enemies[cursor - 4].get_child(0)

	target.add_child(cursorIcon)
	#handle_shader()


#func handle_shader():
	#if !target.get_node("Sprite2D").material:
		#target.get_node("Sprite2D").material = ShaderMaterial.new()
	#target_original_shader = target.get_node("Sprite2D").material.shader
	#target.get_node("Sprite2D").material.shader = highlight_shader


# func battleOver():
# get_tree().change_scene_to_file(res://battle_info.locationName.tscn)
# use location data to set player locations right
# for i in range(len(get_node("Party").get_children())):
#	var pm = get_node("Party").get_child(i).get_child(0)
#	get_node("Party").get_child(i).remove_child(pm)			must remove children so they don't get queue_free()'d
# GameData.addToParty(pm, i)
# battle_info.queue_free()


func enemyTurn():
	decided = true
	pass


func party_get(index: int):
	if index < -4 or index > 3:
		return -1
	return $Party.get_child(index)

var hb_data = load("res://health_bar.tscn")
func generateEnemies():
	# get location info for battle, run calculations for number of enemies and which enemies to instance
	
	# now, for setting the enemies, get a random number from 1 to 5
	var number_of_enemies = randy.randi_range(1, 5)
	var i = 0
	var enemyPool = GameData.locationInfo.enemyPool
	while len(enemies) < number_of_enemies:
		var enemyInfo = enemyPool[i % len(enemyPool)]	# ([enemy_name, enemy_prcnt])
		if randy.randi_range(0, 99) < enemyInfo[1]:
			var enemy = load("res://EnemyLibrary/%s.tscn" % enemyInfo[0]).instantiate()
			var enemyContainer = Entity.new()
			enemyContainer.add_child(enemy)

			enemies.append(enemyContainer)
			get_node("Enemies").add_child(enemyContainer)
			turnOrder.append(enemyContainer)

			place_position(enemyContainer, len(enemies) - 1)
			
			var hb = hb_data.instantiate()
			enemy.add_child(hb)
			enemy.health_bar = hb
			hb.position.x -= 25
			hb.position.y -= 35
			hb.scale *= 0.3
			hb.init_health(enemy.getMaxHP())
			hb.health = enemy.getHP()
			hb.get_node("Label1").visible = false; hb.get_node("Label2").visible = false; hb.get_node("Label3").visible = false;
		i += 1


func place_position(nme: Entity, currAmount: int):
	# place nme in a position on screen using some ratio between total and curr amount
	# if this is the first enemy, and there are four total enemies, then it should be placed
	# somewhere accordingly
	
	# works for up to 12 enemies on screen
	
	match(currAmount % 3):
		0:
			nme.position.y = -150
		1:
			nme.position.y = 0
		2:
			nme.position.y = 150
	
	match(currAmount / 3):
		0:
			nme.position.x = 0
		1:
			nme.position.x = -100
		2:
			nme.position.x = -200
		3:
			nme.position.x = -300
	nme.position.x -= (currAmount % 3) * 25


# although mergeSort is technically more time efficient on average, insertionSort is more space efficient
# only affecting the input array as opposed to creating a new array

# in addition, because turnOrder is usually going to be mostly sorted after each turn, insertionSort's
# average use per battle will have a time complexity closer to O(n) (faster than mergeSort's O(nlogn))

func speedInsertSort(turnOrder):
	for i in range(1, len(turnOrder)):
		var k: int = i
		while(k > 0 && turnOrder[k].get_child(0).speedCounter > turnOrder[k - 1].get_child(0).speedCounter):
			var temp = turnOrder[k]
			turnOrder[k] = turnOrder[k - 1]
			turnOrder[k - 1] = temp
			k -= 1
