extends Level


#var camera
#var fadebox = preload("res://fadebox.tscn").instantiate()
# Called when the node enters the scene tree for the first time.
func _ready():
	#print(get_tree().root.get_children())
	#add_child(fadebox)
	Overlay.scaleTo(Vector2(1250, 1000))
	GameData.current_scene = self
	PauseMenu.current_scene = self
	print("Dungeon start")
	#add_child(GameData.party)
	#print("added party successfully")
	#GameData.party.slot(0).position_history.clear()
	#GameData.party.teleport(Vector2(624, 960))
	#GameData.party.face(Vector2(0,-1))
	changeSize(0.3)
	print("positioned party successfully")
	#camera = GameData.party.get_child(0).get_child(2)
	GameData.partyCamera.zoom *= 2
	#fadebox.play("fadein")
	Overlay.play("fadein_zone")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#
#func placeParty(pos: Vector2):
	#GameData.party.position = pos
	#for pm in GameData.party.get_children():
		#pm.position = Vector2(0, 0)
		#pm.direction = Vector2(0, -1)

func changeSize(mod: float):
	GameData.party.scale = Vector2(mod, mod)
	GameData.party.get_child(0).SPEED *= mod
