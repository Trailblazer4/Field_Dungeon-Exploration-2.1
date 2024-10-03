extends Sprite2D


var count = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		if Input.is_action_just_pressed("up") and position.y > 20:
			position.y -= 140
		if Input.is_action_just_pressed("down") and position.y < 440:
			position.y += 140
		if Input.is_action_just_pressed("left"):
			visible = false
			position.y = 20
			get_parent().get_parent().get_node("Highlight").visible = true
		if Input.is_action_just_pressed("confirm"):
			count = roundi((position.y - 20) / 140)
			visible = false
			#GameData.party.get_child(count).get_child(0).info()
			var status_screen = load("res://character_status_screen.tscn").instantiate()
			PauseMenu.add_child(status_screen)
			PauseMenu.pauseQ = 1
