extends Entity


func _init():
	super()
	myName = "Atom"


# Called when the node enters the scene tree for the first time.
func _ready():
	moveset.append(GameData.SpellLibrary["Rocket Boosters"])
	# lets Atom fly, or something like that


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func walk(v: Vector2):
	if v.x < 0:
		$Sprite2D.flip_h = true
	elif v.x > 0:
		$Sprite2D.flip_h = false
	$Sprite2D/AnimationPlayer.play("run")


func face(d: Vector2):
	$Sprite2D/AnimationPlayer.stop()
	$Sprite2D.set_frame(0)


func face_left():
	$Sprite2D/AnimationPlayer.stop()
	$Sprite2D.set_frame(0)
	$Sprite2D.flip_h = true
