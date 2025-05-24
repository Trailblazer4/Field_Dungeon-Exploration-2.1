extends Node2D


var pauseQ = 0 # states the pause screen can be in (main pause screen, searching through items, settings, looking at party; 4 states)
var cursor = 0
var done = false


@onready var current_scene = get_parent().get_child(get_parent().get_child_count() - 1)
# Called when the node enters the scene tree for the first time.
func on_pause_menu_open():
	print("Pause menu opened successfully")
	
	var sprite_list = get_node("Sprites")
	var pointer = sprite_list.get_node("Pointer")
	sprite_list.remove_child(pointer)
	for child in sprite_list.get_children():
		child.queue_free()
	sprite_list.add_child(pointer)

	var yPos = 0
	for pm in GameData.party.get_children():
		var party_member = pm.get_child(0)
		var new_sprite = party_member.get_node("Sprite2D").duplicate()
		new_sprite.set_frame(0)
		sprite_list.add_child(new_sprite)
		new_sprite.position.y = yPos
		yPos += 140
		new_sprite.scale = Vector2(2, 2)
		
		var new_sprite_label = Label.new()
		new_sprite_label.text = party_member.myName
		new_sprite.add_child(new_sprite_label)
		new_sprite_label.position = Vector2(20, 20)


func _ready():
	#$Fade.visible = true
	Overlay.get_node("AnimationPlayer").connect("animation_finished", _on_animation_player_animation_finished)
	await get_tree().create_timer(2).timeout
	#var player1_sprite = GameData.party.get_child(0).get_child(0)
	#print(player1_sprite)
	GameData.pause_menu_open.connect(on_pause_menu_open)


func _process(delta):
	if Input.is_action_just_pressed("cancel") and pauseQ == 0:
		done = true
		GameData.pausing = false
		
	#if Input.is_action_just_pressed("cancel") and pauseQ == 1:
		#pauseQ = 0

	if done:
		#$Fade/AnimationPlayer.play("fadeout")
		Overlay.play("fadeout_menu")


func camera():
	return $Camera2D


func _on_animation_player_animation_finished(anim_name):
	print("doneee")
	if anim_name == "fadeout_menu" and GameData.q[1]: # and GameData.q[1] is new
		done = false
		get_tree().paused = false
		visible = false
		current_scene.visible = true
		GameData.transition(1, 0)
		camera().enabled = false
		GameData.party.get_child(0).get_child(2).enabled = true
		cursor = 0
		$Highlight.position.y = 74
		$Sprites/Pointer.position.y = 20
		$Highlight.visible = true
		$Sprites/Pointer.visible = false

		Overlay.play("fadein_menu")
