extends Node2D


var pauseQ # states the pause screen can be in (main pause screen, searching through items, settings, looking at party; 4 states)
var cursor = 0
var done = false

@onready var current_scene = get_parent().get_child(get_parent().get_child_count() - 1)
# Called when the node enters the scene tree for the first time.
func _ready():
	$Fade.visible = true


func _process(delta):
	if Input.is_key_pressed(KEY_L):
		done = true
		GameData.pausing = false

	if done:
		$Fade/AnimationPlayer.play("fadeout")


func camera():
	return $Camera2D


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fadeout":
		done = false
		get_tree().paused = false
		visible = false
		current_scene.visible = true
		GameData.transition(1, 0)
		camera().enabled = false
		GameData.party.get_child(0).get_child(2).enabled = true
		cursor = 0
		$Highlight.position.y = 74

		current_scene.get_node("Fade/AnimationPlayer").play("fadein")
