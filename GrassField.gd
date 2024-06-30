extends Node2D

#var nextLevel = load("res://Dungeon.tscn") # or preload, either seems to work fine
var loadChest = load("res://Chest.tscn")

var fadeout = false

func _ready():
	#var burn = Callable(GameData, "burn")
	#GameData.ALL_PLAYABLE_CHARACTERS[2].status_effects.append(burn)
	#GameData.ALL_PLAYABLE_CHARACTERS[2].status_effects[0].call(GameData.ALL_PLAYABLE_CHARACTERS[2])
	GameData.StatusDictionary["Sick"].call(GameData.ALL_PLAYABLE_CHARACTERS[0])
	GameData.current_scene = self
	PauseMenu.current_scene = self
	var elixir: Item = load("res://ItemLibrary/Elixir.tscn").instantiate()
	#
	#var elixir_sprite = Sprite2D.new()
	#elixir_sprite.texture = elixir.get_node("Sprite2D").texture
	#elixir_sprite.scale = elixir.scale
	#$"Chest 1".add_child(elixir_sprite)
	#
	#var elixir_sprite2 = Sprite2D.new()
	#elixir_sprite2.texture = elixir.get_node("Sprite2D").texture
	#elixir_sprite2.scale = elixir.scale
	#$"Chest 1".add_child(elixir_sprite2)
	#elixir_sprite2.position.x -= 20
	#
	elixir.apply_effect(GameData.ALL_PLAYABLE_CHARACTERS[3])

	$Fade.visible = true
	add_child(GameData.party)
	
	add_child(load("res://EnemyLibrary/Slime.tscn").instantiate())
	GameData.party.position = Vector2(250, 170)
	
	GameData.locationInfo = LocationInfo.new("World")
	print(GameData.locationInfo)
	if(GameData.locationInfo):
		GameData.locationInfo.queue_free()
	GameData.locationInfo = LocationInfo.new("Grass Field")
	GameData.locationInfo.addToEnemyPool("Gibbler", 94)
	GameData.locationInfo.addToEnemyPool("The Egg", 6)
	addChests()
	print(GameData.locationInfo)
	
	$Fade/AnimationPlayer.play("fadein")


func _process(delta):
	if Input.is_key_pressed(KEY_M):
		emptyPositionData()
		remove_child(GameData.party) # remove party so it doesn't get queue_free()'d
		get_tree().change_scene_to_packed(GameData.Levels[1])
	
	if Input.is_action_just_pressed("start_battle"):
		$Fade/AnimationPlayer.play("battle_fade")
		remove_child(GameData.party)
		GameData.transition(0, 2)
		get_tree().change_scene_to_file("res://Battle.tscn")


func _physics_process(delta):
	pass


func emptyPositionData():
	var leader = GameData.party.get_child(0)
	leader.position_history.clear()


func addChests():
	var chestsHere = GameData.chests[GameData.locationInfo.locationName]
	for i in range(len(chestsHere)):
		var newChest = loadChest.instantiate()
		add_child(newChest)
		newChest.setChest(i, GameData.locationInfo.locationName, chestsHere[i][2])


# I could just use an int input with match(input) to decide effects of statuses
# 0: passive effect
# 1: modify the afflicted's damage calculation (such as burn decreasing magic defense)
# 2: check for extra effects from the opponent's attack (such as damage boost/replacement with another ailment)

# func burn(int whichEffect):
#	match(whichEffect):
#		0:
#			hp -= (hp * 1/16)
#		1:
#			attackMod /= 1.5
#		2:
#			if thisTurn(attacker).chosenSkill.element == Element.WIND:
#				thisTurn.damageCalc.magicMod *= 1.3     damage
#				thisTurn.damageCalc.chanceMod *= 1.6    status chance
#				remove burn effect
# each skill/equipment in the game can hold statuses to afflict, and every Entity in the game can hold
# statuses to be affected by
