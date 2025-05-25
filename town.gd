extends Level


# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: maybe delete this later. Used right now for debugging.
	GameData.current_scene = self
	
	Overlay.play("fadein_slow")
	for i in 4:
		GameData.addToParty(GameData.ALL_PLAYABLE_CHARACTERS[i], i)
	add_child(GameData.party)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
