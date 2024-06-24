extends Entity


func _init():
	super()
	myName = "Rock Man"


# Called when the node enters the scene tree for the first time.
func _ready():
	moveset.append(GameData.SpellLibrary["Pew Pew"])
	moveset.append(GameData.SpellLibrary["Ar"])
	moveset.append(GameData.SpellLibrary["Re"])


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
	#if d.x < 0:
		#$Sprite2D.flip_h = true
	#elif d.x > 0:
		#$Sprite2D.flip_h = false


func face_left():
	$Sprite2D/AnimationPlayer.stop()
	$Sprite2D.set_frame(0)
	$Sprite2D.flip_h = true
