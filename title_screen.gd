extends Node2D

var level0 = GameData.Levels[0]
# Called when the node enters the scene tree for the first time.
func _ready():
	$Fade.color.a = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("start"):
		$Fade/AnimationPlayer.play("fadeout")


func _on_animation_player_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://character_select.tscn")
