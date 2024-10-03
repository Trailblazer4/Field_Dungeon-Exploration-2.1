#extends Node2D
extends Level

#var nextLevel = load("res://Dungeon.tscn") # or preload, either seems to work fine
var loadChest = load("res://Chest.tscn")

#var fadeout = false
var exitNumber

func _ready():
	#fadebox.play("fadein")
	
	var cin = GameData.party.member(0)
	
	#var burn = Callable(GameData, "burn")
	#GameData.ALL_PLAYABLE_CHARACTERS[2].status_effects.append(burn)
	#GameData.ALL_PLAYABLE_CHARACTERS[2].status_effects[0].call(GameData.ALL_PLAYABLE_CHARACTERS[2])
	#GameData.StatusDictionary["Sick"].call(GameData.ALL_PLAYABLE_CHARACTERS[0])
	
	#print(GameData.SpellLibrary["Au"].status_effects)
	#GameData.SpellLibrary["Au"].status_effects[0].call(GameData.ALL_PLAYABLE_CHARACTERS[3], 0)
	
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

	#$Fade.visible = true
	#add_child(GameData.party)
	
	add_child(load("res://EnemyLibrary/Slime.tscn").instantiate())
	#GameData.party.position = Vector2(250, 170)
	
	#GameData.locationInfo = LocationInfo.new("World")
	#print(GameData.locationInfo)
	#if(GameData.locationInfo):
		#GameData.locationInfo.queue_free()
	GameData.locationInfo = LocationInfo.new("Grass Field")
	GameData.locationInfo.addToEnemyPool("Gibbler", 94)
	GameData.locationInfo.addToEnemyPool("The Egg", 6)
	addChests()
	print(GameData.locationInfo)


func _process(delta):
	if Input.is_key_pressed(KEY_M):
		emptyPositionData()
		remove_child(GameData.party) # remove party so it doesn't get queue_free()'d
		get_tree().change_scene_to_packed(GameData.Levels[1])
	
	if Input.is_action_just_pressed("start_battle"):
		GameData.locationInfo.entryPoint = GameData.party.position
		for pm in GameData.party.get_children():
			GameData.locationInfo.partyLocations.append(pm.position)
			GameData.locationInfo.partyDirections.append(pm.direction)
		print(GameData.locationInfo)
		
		#$Fade/AnimationPlayer.play("battle_fade")
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


# 0: passive effect
# 1: modify the afflicted's damage calculation (such as burn decreasing magic defense)
# 2: check for extra effects from the opponent's attack (such as damage boost/replacement with another ailment)


#func _on_animation_player_animation_finished(anim_name):
	#if anim_name == "exit_zone_fadeout":
		#remove_child(GameData.party)
		#get_tree().change_scene_to_packed(GameData.Levels[1])


#func _on_area_2d_time_to_go(level, entryPoint, direction):
	#print("time to go!")
	#print(level, entryPoint, direction)
