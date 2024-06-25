extends Entity


func _init():
	super()
	myName = "Clodsire"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func walk(v: Vector2):
	if v.x < 0:
		$Sprite2D/AnimationPlayer.play("walk_left")
	if v.x > 0:
		$Sprite2D/AnimationPlayer.play("walk_right")
	if v.y < 0:
		$Sprite2D/AnimationPlayer.play("walk_up")
	if v.y > 0:
		$Sprite2D/AnimationPlayer.play("walk_down")


func face(d: Vector2):
	$Sprite2D/AnimationPlayer.stop()
	if d.x < 0:
		$Sprite2D.set_frame(4)
	elif d.x > 0:
		$Sprite2D.set_frame(8)
	elif d.y < 0:
		$Sprite2D.set_frame(12)
	elif d.y > 0:
		$Sprite2D.set_frame(0)


func face_left():
	$Sprite2D/AnimationPlayer.stop()
	$Sprite2D.set_frame(4)
