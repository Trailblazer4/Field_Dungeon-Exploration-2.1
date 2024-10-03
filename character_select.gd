extends Node2D


@onready var cursor = 0
@onready var cursor_icon = Sprite2D.new()
@export var chosen_color: Color
@export var MINIMUM_PARTY_SIZE = 4

var selection = []
# Called when the node enters the scene tree for the first time.
func _ready():
	await init_screen()
	$FadeWhite/AnimationPlayer.play("fadein")
	
	#GameData.party.addAt(GameData.ALL_PLAYABLE_CHARACTERS[0], 0)
	#GameData.party.add(GameData.ALL_PLAYABLE_CHARACTERS[1])
	#print(GameData.party.treeView() + "\n\n\n")
	#GameData.party.remove(0)
	#GameData.party.swap(0, 1)
	#print(GameData.party.treeView())
	
	#var rem = GameData.party.remove(0)
	#print(rem); print(rem.get_children())
	#print(GameData.party.treeView())
	#GameData.party.add(GameData.ALL_PLAYABLE_CHARACTERS[0])
	#GameData.party.add(GameData.ALL_PLAYABLE_CHARACTERS[1])
	#GameData.party.add(GameData.ALL_PLAYABLE_CHARACTERS[2])
	#print("success" if GameData.party.add(GameData.ALL_PLAYABLE_CHARACTERS[3]) else "failure")
	##print(GameData.party.clear())
	##GameData.party.remove(1)
	#print(GameData.party.treeView() + "\n\n\n")
	#GameData.party.remove(0)
	##GameData.party.remove(2)
	##print("success" if GameData.party.add(GameData.ALL_PLAYABLE_CHARACTERS[4]) else "failure")
	#print(GameData.party.viewSlots()[0].get_child(2))
	#print(GameData.party.viewSlots()[1].get_child(1))
	#print(GameData.party.viewMembers())
	#print(GameData.party.treeView())

func init_screen():
	for i in range(len(GameData.ALL_PLAYABLE_CHARACTERS)):
		GameData.ALL_PLAYABLE_CHARACTERS[i].face(Vector2(0, 1))
		add_portrait(i)
	cursor_icon.texture = load("res://images/Cursor.png")
	$Sprites.get_child(0).get_child(1).add_child(cursor_icon)
	cursor_icon.position += Vector2(-17, 15)
	$FadeWhite.color = Color.BLACK


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("left"):
		set_cursor(-1)
	if Input.is_action_just_pressed("right"):
		set_cursor(1)
	if Input.is_action_just_pressed("up"):
		set_cursor(-4)
	if Input.is_action_just_pressed("down"):
		set_cursor(4)
	
	if Input.is_action_just_pressed("confirm"):
		if len(selection) < MINIMUM_PARTY_SIZE and !(GameData.ALL_PLAYABLE_CHARACTERS[cursor] in selection):
			selection.append(GameData.ALL_PLAYABLE_CHARACTERS[cursor])
			$Sprites.get_child(cursor).get_child(1).set("theme_override_colors/font_color", chosen_color)
		if len(selection) >= MINIMUM_PARTY_SIZE:
			$StartPrompt.visible = true
			$StartPrompt/AnimationPlayer.play("flash")
		print(selection)

	if Input.is_action_just_pressed("cancel"):
		if len(selection) > 0:
			var colorful = GameData.ALL_PLAYABLE_CHARACTERS.find(selection.pop_back(), 0)
			$Sprites.get_child(colorful).get_child(1).set("theme_override_colors/font_color", Color.WHITE)
		$StartPrompt.visible = false
		$StartPrompt/AnimationPlayer.stop()
		print(selection)
	
	if Input.is_action_just_pressed("start") and $StartPrompt.visible:
		$FadeWhite/AnimationPlayer.play("fadeout")
		for i in range(len(selection)):
			GameData.addToParty(selection[i], i)


func add_portrait(index: int):
	var sprite = GameData.ALL_PLAYABLE_CHARACTERS[index].get_node("Sprite2D").duplicate()
	var name = GameData.ALL_PLAYABLE_CHARACTERS[index].myName
	if name == "Zero":
		sprite.flip_h = true
		sprite.get_node("AnimationPlayer").play("idle")
	$Sprites.add_child(sprite)
	sprite.scale *= 2
	
	match(index % 4): # decide x position
		0:
			sprite.position.x = 150
		1:
			sprite.position.x = 400
		2:
			sprite.position.x = 720
		3:
			sprite.position.x = 1000

	sprite.position.y = 60 + 150 * (index / 4)
	var l = Label.new()
	sprite.add_child(l)
	l.text = name
	l.position.x = -3 * len(name)
	l.position.y = 20
	l.scale /= sprite.scale
	l.scale *= 1.5
	l.set("theme_override_colors/font_shadow_color", Color.BLACK)
	l.set("theme_override_constants/shadow_outline_size", 12)


func set_cursor(place: int):
	$Sprites.get_child(cursor).get_child(1).remove_child(cursor_icon)
	cursor += place
	cursor = cursor % $Sprites.get_child_count()
	$Sprites.get_child(cursor).get_child(1).add_child(cursor_icon)
	print(cursor)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fadeout":
		#get_tree().change_scene_to_packed(GameData.Levels[0])
		GameData.travel_to(0, Vector2(250, 170), Vector2(1, 0))
